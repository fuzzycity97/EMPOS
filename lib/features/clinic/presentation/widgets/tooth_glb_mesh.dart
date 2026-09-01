import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';

import '../../domain/entities/tooth_chart_entry.dart';

/// A lightweight triangle mesh extracted from a GLB asset.
class ToothGlbMesh {
  final List<Float32List> vertices;
  final List<int> indices;
  final double crownY;
  final double rootY;
  final double maxRadius;

  const ToothGlbMesh({
    required this.vertices,
    required this.indices,
    required this.crownY,
    required this.rootY,
    required this.maxRadius,
  });
}

/// Loads and caches CC0 category tooth GLB meshes from assets.
class ToothGlbMeshLibrary {
  ToothGlbMeshLibrary._();

  static final Map<ToothCategory, ToothGlbMesh> _cache = {};
  static Future<void>? _preloadFuture;

  static Future<void> preloadAll() {
    return _preloadFuture ??= () async {
      for (final category in ToothCategory.values) {
        await meshFor(category);
      }
    }();
  }

  static Future<ToothGlbMesh> meshFor(ToothCategory category) async {
    final cached = _cache[category];
    if (cached != null) return cached;

    final assetPath = 'assets/models/teeth/${category.name}.glb';
    final data = await rootBundle.load(assetPath);
    final mesh = _parseGlb(data.buffer.asUint8List());
    _cache[category] = mesh;
    return mesh;
  }

  static bool get isReady => _cache.length == ToothCategory.values.length;

  static ToothGlbMesh meshForSync(ToothCategory category) {
    final mesh = _cache[category];
    if (mesh == null) {
      throw StateError('Tooth GLB meshes not preloaded for $category');
    }
    return mesh;
  }

  static ToothGlbMesh _parseGlb(Uint8List bytes) {
    if (bytes.length < 20) {
      throw const FormatException('GLB file too small');
    }
    final magic = String.fromCharCodes(bytes.sublist(0, 4));
    if (magic != 'glTF') {
      throw FormatException('Invalid GLB magic: $magic');
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
