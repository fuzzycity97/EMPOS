#!/usr/bin/env python3
"""Generate CC0 anatomical tooth GLB meshes for EMPOS odontogram categories."""

from __future__ import annotations

import json
import struct
from pathlib import Path

import numpy as np

OUT_DIR = Path(__file__).resolve().parents[1] / "assets" / "models" / "teeth"


def lathe_mesh(
    profile: list[tuple[float, float]],
    segments: int = 28,
    rx_scale: float = 1.0,
    rz_scale: float = 1.0,
    cusp_fn=None,
) -> tuple[np.ndarray, np.ndarray]:
    """Revolve a (y, radius) profile into a triangle mesh."""
    verts: list[list[float]] = []
    rings: list[list[int]] = []

    for y, radius in profile:
        ring: list[int] = []
        for i in range(segments):
            theta = (2.0 * np.pi * i) / segments
            x = radius * rx_scale * np.cos(theta)
            z = radius * rz_scale * np.sin(theta)
            if cusp_fn is not None:
                x, z = cusp_fn(y, radius, x, z, theta)
            ring.append(len(verts))
            verts.append([float(x), float(y), float(z)])
        rings.append(ring)

    indices: list[int] = []
    for r in range(len(rings) - 1):
        a = rings[r]
        b = rings[r + 1]
        for i in range(segments):
            i2 = (i + 1) % segments
            indices.extend([a[i], b[i], b[i2], a[i], b[i2], a[i2]])

    return np.array(verts, dtype=np.float32), np.array(indices, dtype=np.uint32)


def molar_cusps(y: float, radius: float, x: float, z: float, theta: float):
    if y < 0.55:
        return x, z
    bump = 0.18 * radius * (np.cos(2 * theta) + np.cos(4 * theta))
    scale = 1.0 + bump
    return x * scale, z * scale


def premolar_cusps(y: float, radius: float, x: float, z: float, theta: float):
    if y < 0.45:
        return x, z
    bump = 0.12 * radius * np.cos(2 * theta)
    scale = 1.0 + bump
    return x * scale, z * scale


def canine_point(y: float, radius: float, x: float, z: float, theta: float):
    if y < 0.35:
        return x, z
    taper = max(0.15, 1.0 - (y - 0.35) * 1.4)
    return x * taper, z * taper


PROFILES: dict[str, dict] = {
    "incisor": {
        "profile": [
            (-1.0, 0.05),
            (-0.55, 0.14),
            (-0.15, 0.22),
            (0.15, 0.30),
            (0.45, 0.28),
            (0.62, 0.18),
            (0.72, 0.08),
        ],
        "segments": 24,
        "rx_scale": 0.55,
        "rz_scale": 1.0,
        "cusp_fn": None,
    },
    "canine": {
        "profile": [
            (-1.15, 0.04),
            (-0.65, 0.12),
            (-0.2, 0.18),
            (0.2, 0.24),
            (0.55, 0.16),
            (0.78, 0.05),
            (0.92, 0.01),
        ],
        "segments": 24,
        "rx_scale": 0.75,
        "rz_scale": 0.75,
        "cusp_fn": canine_point,
    },
    "premolar": {
        "profile": [
            (-0.85, 0.06),
            (-0.45, 0.18),
            (-0.1, 0.28),
            (0.25, 0.34),
            (0.55, 0.30),
            (0.72, 0.16),
        ],
        "segments": 28,
        "rx_scale": 0.9,
        "rz_scale": 0.9,
        "cusp_fn": premolar_cusps,
    },
    "molar": {
        "profile": [
            (-0.75, 0.08),
            (-0.35, 0.22),
            (0.0, 0.36),
            (0.35, 0.38),
            (0.62, 0.28),
            (0.78, 0.14),
        ],
        "segments": 32,
        "rx_scale": 1.0,
        "rz_scale": 1.0,
        "cusp_fn": molar_cusps,
    },
}


def write_glb(name: str, vertices: np.ndarray, indices: np.ndarray) -> None:
    positions = vertices.tobytes()
    min_vals = vertices.min(axis=0).tolist()
    max_vals = vertices.max(axis=0).tolist()

    buffer_views = [
        {"buffer": 0, "byteOffset": 0, "byteLength": len(positions), "target": 34962},
        {
            "buffer": 0,
            "byteOffset": len(positions),
            "byteLength": indices.nbytes,
            "target": 34963,
        },
    ]
    accessors = [
        {
            "bufferView": 0,
            "componentType": 5126,
            "count": len(vertices),
            "type": "VEC3",
            "min": min_vals,
            "max": max_vals,
        },
        {
            "bufferView": 1,
            "componentType": 5125,
            "count": len(indices),
            "type": "SCALAR",
            "min": [int(indices.min())],
            "max": [int(indices.max())],
        },
    ]
    gltf = {
        "asset": {"version": "2.0", "generator": "EMPOS CC0 tooth mesh generator"},
        "scene": 0,
        "scenes": [{"nodes": [0]}],
        "nodes": [{"mesh": 0}],
        "meshes": [
            {
                "name": name,
                "primitives": [
                    {
                        "attributes": {"POSITION": 0},
                        "indices": 1,
                        "mode": 4,
                    }
                ],
            }
        ],
        "accessors": accessors,
        "bufferViews": buffer_views,
        "buffers": [{"byteLength": len(positions) + indices.nbytes}],
    }

    json_chunk = json.dumps(gltf, separators=(",", ":")).encode("utf-8")
    json_pad = (4 - (len(json_chunk) % 4)) % 4
    json_chunk += b" " * json_pad

    bin_chunk = positions + indices.tobytes()
    bin_pad = (4 - (len(bin_chunk) % 4)) % 4
    bin_chunk += b"\x00" * bin_pad

    total_length = 12 + 8 + len(json_chunk) + 8 + len(bin_chunk)
    header = struct.pack("<4sII", b"glTF", 2, total_length)
    json_header = struct.pack("<I4s", len(json_chunk), b"JSON")
    bin_header = struct.pack("<I4s", len(bin_chunk), b"BIN\x00")

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    out_path = OUT_DIR / f"{name}.glb"
    out_path.write_bytes(header + json_header + json_chunk + bin_header + bin_chunk)
    print(f"Wrote {out_path} ({len(vertices)} verts, {len(indices)} indices)")


def main() -> None:
    for name, cfg in PROFILES.items():
        verts, indices = lathe_mesh(**cfg)
        write_glb(name, verts, indices)


if __name__ == "__main__":
    main()
