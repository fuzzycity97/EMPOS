# Third-Party Licenses and Asset Attributions

This document records license and attribution metadata for assets, procedural models, and mathematical engines used in EMPOS.

---

## 1. 3D Dental Odontogram Category Tooth Meshes (GLB)
- **Assets**: `assets/models/teeth/incisor.glb`, `canine.glb`, `premolar.glb`, `molar.glb`
- **Generator**: `tools/generate_tooth_glb.py` (EMPOS anatomical lathe-mesh generator)
- **Design Reference**: Meshy.ai dental/tooth gallery category conventions (incisor, canine, premolar, molar crown/root proportions)
- **License**: **CC0 1.0 (Public Domain)** — no attribution required
- **Usage**: One reusable base mesh per `ToothCategory`, status-tinted at render time in `DentalTooth3dCanvasWidget` via `ToothGlbMeshLibrary`
- **Loader**: `lib/features/clinic/presentation/widgets/tooth_glb_mesh.dart`

---

## 2. 3D Dental Odontogram Spatial Projection Engine
- **Component**: `lib/features/clinic/presentation/widgets/dental_tooth_3d_canvas_widget.dart`
- **Asset / Mathematical Spec**: Parabolic 3D dental arch coordinate transforms, GLB mesh vertex projection, depth-sorted triangle rasterization, and FDI ISO 3950 two-digit mapping.
- **License**: MIT / CC0 (Public Domain Equivalent)
- **Attribution**: Pure-Flutter projection mathematics with CC0 category tooth GLB assets.

---

## 3. Industry Taxonomies & FDI Dental Classification
- **Standard**: FDI World Dental Federation two-digit system (ISO 3950) & Universal Numbering System (1–32 / A–T).
- **License**: Open Standard / Public Domain Educational & Clinical Reference.

---

## 4. Flutter & Open-Source Dart Packages
All dependencies listed in `pubspec.yaml` are governed by their respective open-source licenses (MIT, BSD-3-Clause, Apache-2.0). Run Flutter's built-in `showLicensePage(context: context)` to view full dependency licenses.
