import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'skeletal_bone_3d_canvas_widget.dart';

/// Loads and parses the high-fidelity GLB skeletal anatomy models (`male_skeleton.glb` and `female_skeleton.glb`)
/// into anatomical `BoneSegment3D` meshes for true 3D rendering.
class SkeletalGlbMeshLibrary {
  SkeletalGlbMeshLibrary._();

  static List<BoneSegment3D>? _cachedMaleBones;
  static List<BoneSegment3D>? _cachedFemaleBones;
  static Future<List<BoneSegment3D>>? _loadingFuture;

  static bool get isLoaded => _cachedMaleBones != null;

  /// Returns cached bones if available, or null if loading.
  static List<BoneSegment3D>? getCachedBones({bool female = false}) {
    return female ? (_cachedFemaleBones ?? _cachedMaleBones) : _cachedMaleBones;
  }

  /// Asynchronously loads, parses, and classifies the full GLB skeleton model.
  static Future<List<BoneSegment3D>> loadSkeleton({bool female = false}) async {
    if (female && _cachedFemaleBones != null) return _cachedFemaleBones!;
    if (!female && _cachedMaleBones != null) return _cachedMaleBones!;

    if (_loadingFuture != null) return _loadingFuture!;

    _loadingFuture = _doLoadSkeleton(female: female);
    return _loadingFuture!;
  }

  static Future<List<BoneSegment3D>> _doLoadSkeleton({bool female = false}) async {
    try {
      final assetPath = female
          ? 'assets/models/orthopedics/female_skeleton.glb'
          : 'assets/models/orthopedics/male_skeleton.glb';

      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      final bones = _parseGlbSkeleton(bytes);

      if (female) {
        _cachedFemaleBones = bones;
      } else {
        _cachedMaleBones = bones;
      }
      return bones;
    } catch (e, st) {
      debugPrint('Failed to load skeletal GLB model: $e\n$st');
      return [];
    } finally {
      _loadingFuture = null;
    }
  }

  static List<BoneSegment3D> _parseGlbSkeleton(Uint8List bytes) {
    if (bytes.length < 20) return [];

    // 1. Unpack GLB Header
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
    final meshes = (gltf['meshes'] as List).cast<Map<String, dynamic>>();

    const scaleFactor = 305.0 / 1850.0; // Normalizes 1850mm skeleton to canvas units (~305)

    // Buckets for the 12 clinical bones
    final bucketVerts = <String, List<BonePoint3D>>{};
    final bucketFaces = <String, List<List<int>>>{};

    for (final boneId in _boneMetadata.keys) {
      bucketVerts[boneId] = <BonePoint3D>[];
      bucketFaces[boneId] = <List<int>>[];
    }

    for (final m in meshes) {
      final name = m['name'] as String? ?? '';
      final primitives = (m['primitives'] as List).cast<Map<String, dynamic>>();
      if (primitives.isEmpty) continue;
      final prim = primitives.first;

      final attrs = prim['attributes'] as Map<String, dynamic>;
      if (!attrs.containsKey('POSITION')) continue;

      final posAccIdx = attrs['POSITION'] as int;
      final posAcc = accessors[posAccIdx];
      final posBv = bufferViews[posAcc['bufferView'] as int];
      final posOffset = (posBv['byteOffset'] as int? ?? 0) + (posAcc['byteOffset'] as int? ?? 0);
      final posCount = posAcc['count'] as int;

      // Extract positions
      final positions = List<BonePoint3D>.generate(posCount, (i) {
        final base = posOffset + i * 12;
        final x = _readFloat32(binBytes, base) * scaleFactor;
        final rawY = _readFloat32(binBytes, base + 4);
        final y = (rawY - 1000.0) * scaleFactor;
        final z = _readFloat32(binBytes, base + 8) * scaleFactor;
        return BonePoint3D(x, y, z);
      });

      // Extract indices
      if (!prim.containsKey('indices')) continue;
      final idxAccIdx = prim['indices'] as int;
      final idxAcc = accessors[idxAccIdx];
      final idxBv = bufferViews[idxAcc['bufferView'] as int];
      final idxOffset = (idxBv['byteOffset'] as int? ?? 0) + (idxAcc['byteOffset'] as int? ?? 0);
      final idxCount = idxAcc['count'] as int;
      final compType = idxAcc['componentType'] as int? ?? 5125;

      final rawIndices = <int>[];
      if (compType == 5123) {
        // uint16
        for (var i = 0; i < idxCount; i++) {
          final pos = idxOffset + i * 2;
          rawIndices.add(binBytes[pos] | (binBytes[pos + 1] << 8));
        }
      } else {
        // uint32
        for (var i = 0; i < idxCount; i++) {
          rawIndices.add(_readUint32(binBytes, idxOffset + i * 4));
        }
      }

      // Stride for high-polygon parts to maintain buttery 60 FPS in full skeleton view
      final isHighPoly = name.contains('Cranium') || name.contains('Teeth');
      final stride = isHighPoly ? 6 : 3;

      for (var i = 0; i + 2 < rawIndices.length; i += stride) {
        final i0 = rawIndices[i];
        final i1 = rawIndices[i + 1];
        final i2 = rawIndices[i + 2];

        if (i0 >= positions.length || i1 >= positions.length || i2 >= positions.length) {
          continue;
        }

        final p0 = positions[i0];
        final p1 = positions[i1];
        final p2 = positions[i2];

        final cyRaw = (p0.y / scaleFactor) + 1000.0;
        final cx = (p0.x + p1.x + p2.x) / 3.0;

        // Classify triangle into target bone segment
        String boneId;
        if (name.contains('Cranium') || name.contains('Mandible') || name.contains('Teeth') || name.contains('Hyoid')) {
          boneId = 'bone_cranium';
        } else if (name.contains('Ribs') || name.contains('Sternum') || name.contains('RibCartilage')) {
          boneId = 'bone_thoracic_ribs';
        } else if (name.contains('Sacrum') || name.contains('HipCartilage')) {
          boneId = 'bone_pelvis';
        } else if (name.contains('Discs')) {
          boneId = 'bone_thoracic_ribs';
        } else if (name.contains('Spine')) {
          if (cyRaw >= 1560) {
            boneId = 'bone_cervical';
          } else if (cyRaw >= 1200) {
            boneId = 'bone_thoracic_ribs';
          } else {
            boneId = 'bone_lumbar';
          }
        } else if (name.contains('ArmsHands')) {
          if (cyRaw >= 1400 && cx.abs() < 36.0) {
            boneId = 'bone_clavicle_scapula';
          } else if (cyRaw >= 1100) {
            boneId = 'bone_humerus';
          } else {
            boneId = 'bone_radius_ulna';
          }
        } else if (name.contains('HipsLegs')) {
          if (cyRaw >= 850) {
            boneId = 'bone_pelvis';
          } else if (cyRaw >= 450) {
            boneId = 'bone_femur';
          } else if (cyRaw >= 380) {
            boneId = 'bone_patella_knee';
          } else if (cyRaw >= 80) {
            boneId = 'bone_tibia_fibula';
          } else {
            boneId = 'bone_ankle_foot';
          }
        } else {
          continue;
        }

        final targetVerts = bucketVerts[boneId];
        final targetFaces = bucketFaces[boneId];
        if (targetVerts != null && targetFaces != null) {
          final baseIdx = targetVerts.length;
          targetVerts.add(p0);
          targetVerts.add(p1);
          targetVerts.add(p2);
          targetFaces.add([baseIdx, baseIdx + 1, baseIdx + 2]);
        }
      }
    }

    // Assemble the 12 BoneSegment3D models
    final resultBones = <BoneSegment3D>[];
    for (final entry in _boneMetadata.entries) {
      final id = entry.key;
      final meta = entry.value;
      final verts = bucketVerts[id] ?? [];
      final faces = bucketFaces[id] ?? [];

      if (verts.isEmpty) continue;

      // Compute centroid
      var sumX = 0.0;
      var sumY = 0.0;
      var sumZ = 0.0;
      for (final v in verts) {
        sumX += v.x;
        sumY += v.y;
        sumZ += v.z;
      }
      final center = BonePoint3D(sumX / verts.length, sumY / verts.length, sumZ / verts.length);

      resultBones.add(BoneSegment3D(
        id: id,
        code: meta.code,
        nameEn: meta.nameEn,
        nameAr: meta.nameAr,
        region: meta.region,
        vertices: verts,
        faces: faces,
        center: center,
        hitRadius: meta.hitRadius,
        hasPediatricGrowthPlate: meta.hasPediatricGrowthPlate,
        hasGeriatricSpurRisk: meta.hasGeriatricSpurRisk,
        boneDensityTScore: meta.boneDensityTScore,
      ));
    }

    return resultBones;
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

  static final Map<String, _BoneMeta> _boneMetadata = {
    'bone_cranium': const _BoneMeta('21310', 'Cranium & Facial Bones', 'الجمجمة وعظام الوجه', SkeletalRegionFocus.cranial, 32.0, false, false, 0.8),
    'bone_cervical': const _BoneMeta('22551', 'Cervical Spine (C1-C7)', 'الفقرات العنقية', SkeletalRegionFocus.spine, 18.0, false, true, 0.4),
    'bone_thoracic_ribs': const _BoneMeta('21820', 'Thoracic Spine & Ribs', 'القفص الصدري والفقرات الصدرية', SkeletalRegionFocus.thoracic, 40.0, false, false, 0.2),
    'bone_clavicle_scapula': const _BoneMeta('23500', 'Clavicle & Scapula', 'الترقوة ولوح الكتف', SkeletalRegionFocus.upperLimbs, 24.0, true, false, 0.5),
    'bone_lumbar': const _BoneMeta('22612', 'Lumbar Spine (L1-L5)', 'الفقرات القطنية', SkeletalRegionFocus.spine, 25.0, false, true, -0.6),
    'bone_humerus': const _BoneMeta('24500', 'Humerus (Arm)', 'عظم العضد', SkeletalRegionFocus.upperLimbs, 26.0, true, false, 0.6),
    'bone_radius_ulna': const _BoneMeta('25500', 'Radius & Ulna (Forearm)', 'عظما الكعبرة والزند', SkeletalRegionFocus.upperLimbs, 24.0, true, false, 0.3),
    'bone_pelvis': const _BoneMeta('27197', 'Pelvis & Hip Joint', 'الحوض ومفصل الورك', SkeletalRegionFocus.pelvis, 38.0, false, false, -0.3),
    'bone_femur': const _BoneMeta('27506', 'Femur (Thigh Bone)', 'عظم الفخذ', SkeletalRegionFocus.lowerLimbs, 28.0, true, false, 0.1),
    'bone_patella_knee': const _BoneMeta('27560', 'Patella & Knee Joint', 'الرضفة ومفصل الركبة', SkeletalRegionFocus.lowerLimbs, 20.0, false, true, 0.2),
    'bone_tibia_fibula': const _BoneMeta('27750', 'Tibia & Fibula (Leg)', 'عظما القصبة والشظية', SkeletalRegionFocus.lowerLimbs, 26.0, true, false, 0.4),
    'bone_ankle_foot': const _BoneMeta('28400', 'Ankle & Foot Metatarsals', 'الكاحل ومشط القدم', SkeletalRegionFocus.lowerLimbs, 24.0, false, false, 0.2),
  };
}

class _BoneMeta {
  final String code;
  final String nameEn;
  final String nameAr;
  final SkeletalRegionFocus region;
  final double hitRadius;
  final bool hasPediatricGrowthPlate;
  final bool hasGeriatricSpurRisk;
  final double boneDensityTScore;

  const _BoneMeta(
    this.code,
    this.nameEn,
    this.nameAr,
    this.region,
    this.hitRadius,
    this.hasPediatricGrowthPlate,
    this.hasGeriatricSpurRisk,
    this.boneDensityTScore,
  );
}
