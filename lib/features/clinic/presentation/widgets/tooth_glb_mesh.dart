import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../domain/entities/tooth_chart_entry.dart';

/// A lightweight triangle mesh extracted from a GLB asset or procedural generator.
class ToothGlbMesh {
  final List<Float32List> vertices;
  final List<int> indices;
  final double crownY;
  final double rootY;
  final double maxRadius;
  final bool isProcedural;

  const ToothGlbMesh({
    required this.vertices,
    required this.indices,
    required this.crownY,
    required this.rootY,
    required this.maxRadius,
    this.isProcedural = false,
  });
}

/// Loads and caches category tooth GLB meshes from assets with synchronous procedural fallbacks.
class ToothGlbMeshLibrary {
  ToothGlbMeshLibrary._();

  static final Map<ToothCategory, ToothGlbMesh> _realCache = {};
  static final Map<ToothCategory, ToothGlbMesh> _proceduralCache = {};
  static Future<void>? _preloadFuture;

  static bool get isReady => _realCache.length == ToothCategory.values.length;

  /// Returns true if the high-fidelity GLB mesh asset has finished loading.
  static bool isRealModelLoaded(ToothCategory category) => _realCache.containsKey(category);

  /// Synchronous retrieval: returns the real high-fidelity GLB mesh if already cached,
  /// or immediately returns a deterministic parametric procedural fallback mesh.
  /// Guarantees zero blocking and zero render stalls on frame 0 and camera switches.
  static ToothGlbMesh meshForSync(ToothCategory category) {
    final real = _realCache[category];
    if (real != null) return real;
    return _proceduralCache.putIfAbsent(category, () => _generateProceduralMesh(category));
  }

  /// Asynchronously loads and parses the real category GLB asset.
  /// Seamlessly swaps the real GLB mesh into cache once ready.
  /// Protected with a timeout to guarantee it never hangs indefinitely.
  static Future<ToothGlbMesh> meshFor(ToothCategory category) async {
    final cached = _realCache[category];
    if (cached != null) return cached;

    try {
      final assetPath = 'assets/models/teeth/${category.name}.glb';
      final data = await rootBundle.load(assetPath).timeout(const Duration(milliseconds: 750));
      final mesh = _parseGlb(data.buffer.asUint8List());
      _realCache[category] = mesh;
      return mesh;
    } catch (_) {
      // Robust procedural fallback: generate parametric category mesh instantly
      return _proceduralCache.putIfAbsent(category, () => _generateProceduralMesh(category));
    }
  }

  static Future<void> preloadAll() {
    return _preloadFuture ??= () async {
      for (final category in ToothCategory.values) {
        await meshFor(category);
      }
    }();
  }

  /// Reset cache for testing or simulating procedural fallbacks
  @visibleForTesting
  static void resetCache() {
    _realCache.clear();
    _proceduralCache.clear();
    _preloadFuture = null;
  }

  static ToothGlbMesh _generateProceduralMesh(ToothCategory category) {
    final vertices = <Float32List>[];
    final indices = <int>[];
    final isMolar = category == ToothCategory.molar || category == ToothCategory.premolar;
    final radius = isMolar ? 7.0 : 5.0;
    const height = 18.0;

    // Generate 8-segment cylinder/lathe procedural mesh
    const segments = 8;
    for (var ring = 0; ring <= 2; ring++) {
      final y = (ring - 1) * (height / 2);
      final r = (ring == 1) ? radius : radius * 0.7;
      for (var s = 0; s < segments; s++) {
        final angle = (s / segments) * 2 * math.pi;
        final x = r * math.cos(angle);
        final z = r * math.sin(angle);
        vertices.add(Float32List.fromList([x, y, z]));
      }
    }

    // Connect rings with triangle indices
    for (var ring = 0; ring < 2; ring++) {
      final base = ring * segments;
      final nextBase = (ring + 1) * segments;
      for (var s = 0; s < segments; s++) {
        final current = base + s;
        final next = base + ((s + 1) % segments);
        final topCurrent = nextBase + s;
        final topNext = nextBase + ((s + 1) % segments);

        indices.addAll([current, topCurrent, next]);
        indices.addAll([next, topCurrent, topNext]);
      }
    }

    return ToothGlbMesh(
      vertices: vertices,
      indices: indices,
      crownY: height / 2,
      rootY: -height / 2,
      maxRadius: radius,
      isProcedural: true,
    );
  }

  static ToothGlbMesh _parseGlb(Uint8List bytes) {
    if (bytes.length < 20) {
      throw const FormatException('GLB file too small');
    }
    final magic = String.fromCharCodes(bytes.sublist(0, 4));
    if (magic != 'glTF') {
      throw FormatException('Invalid GLB magic: ');
    }

    var offset = 12;
    final jsonLength = _readUint32(bytes, offset);
    offset += 8;
    final jsonBytes = bytes.sublist(offset, offset + jsonLength);
    offset += jsonLength + ((4 - (jsonLength % 4)) % 4);

    final binLength = _readUint32(bytes, offset);
    offset += 8;
    final binBytes = bytes.sublist(offset, offset + binLength);

    final gltf = jsonDecode(utf8.decode(jsonBytes)) as Map<String, dynamic>;
    final accessors = (gltf['accessors'] as List).cast<Map<String, dynamic>>();
    final bufferViews = (gltf['bufferViews'] as List).cast<Map<String, dynamic>>();

    final positionAccessor = accessors[0];
    final indexAccessor = accessors[1];
    final positionView = bufferViews[positionAccessor['bufferView'] as int];
    final indexView = bufferViews[indexAccessor['bufferView'] as int];

    final posOffset = positionView['byteOffset'] as int? ?? 0;
    final posLength = positionAccessor['count'] as int;
    const posStride = 12;

    final vertices = <Float32List>[];
    var crownY = double.negativeInfinity;
    var rootY = double.infinity;
    var maxRadius = 0.0;

    for (var i = 0; i < posLength; i++) {
      final base = posOffset + i * posStride;
      final x = _readFloat32(binBytes, base);
      final y = _readFloat32(binBytes, base + 4);
      final z = _readFloat32(binBytes, base + 8);
      vertices.add(Float32List.fromList([x, y, z]));
      if (y > crownY) crownY = y;
      if (y < rootY) rootY = y;
      final r = math.sqrt(x * x + z * z);
      if (r > maxRadius) maxRadius = r;
    }

    final indexOffset = indexView['byteOffset'] as int? ?? 0;
    final indexCount = indexAccessor['count'] as int;
    final indices = <int>[];
    for (var i = 0; i < indexCount; i++) {
      indices.add(_readUint32(binBytes, indexOffset + i * 4));
    }

    return ToothGlbMesh(
      vertices: vertices,
      indices: indices,
      crownY: crownY,
      rootY: rootY,
      maxRadius: maxRadius > 0 ? maxRadius : 1.0,
      isProcedural: false,
    );
  }

  static int _readUint32(Uint8List bytes, int offset) {
    return bytes[offset] |
        (bytes[offset + 1] << 8) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 3] << 24);
  }

  static double _readFloat32(Uint8List bytes, int offset) {
    return ByteData.sublistView(bytes, offset, offset + 4).getFloat32(0, Endian.little);
  }
}
