import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'clinical_3d_engine_core.dart';
import 'multi_specialty_anatomy_canvas_widget.dart';

/// Loads, parses, and normalizes high-fidelity 3D GLB anatomical models for all clinical disciplines.
class SpecialtyGlbMeshLibrary {
  SpecialtyGlbMeshLibrary._();

  // Hard face budget: at 3 000 faces the painter does ~9 000 vertex transforms
  // at 60 Hz = 540 000 ops/s, which Dart handles well within 16ms.
  static const int _kMaxFaces = 3000;

  static final Map<ClinicalSpecialtyDiscipline, List<MeshFace3D>>   _cache   = {};
  static final Map<ClinicalSpecialtyDiscipline, GlbMeshBuffer>      _bufCache = {};
  static final Map<ClinicalSpecialtyDiscipline, Future<List<MeshFace3D>>> _loadingFutures = {};
  static final List<VoidCallback> _listeners = [];

  static void addListener(VoidCallback cb) => _listeners.add(cb);
  static void removeListener(VoidCallback cb) => _listeners.remove(cb);

  static void _notify() {
    for (final cb in List.of(_listeners)) {
      try {
        cb();
      } catch (_) {}
    }
  }

  static bool hasDisciplineLoaded(ClinicalSpecialtyDiscipline d) => _cache.containsKey(d);

  static bool isLoaded(ClinicalSpecialtyDiscipline d) => _cache.containsKey(d) && _cache[d]!.isNotEmpty;

  static void preload(ClinicalSpecialtyDiscipline d) {
    loadDisciplineMesh(d);
  }

  static List<MeshFace3D>? getCachedMesh(ClinicalSpecialtyDiscipline d) => _cache[d];

  /// Returns the high-performance flat vertex buffer for the given discipline.
  /// Prefer this over [getMesh] in the paint() hot-path.
  static GlbMeshBuffer? getMeshBuffer(
    ClinicalSpecialtyDiscipline d, {
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    final buf = _bufCache[d];
    if (buf == null) return null;
    if (!isSoloMode || soloPartKey == null) return buf;
    // Solo mode: rebuild a filtered buffer (cheap — only happens on double-click)
    final allKeys = buf.partKeys;
    final soloIdx = allKeys.indexOf(soloPartKey);
    if (soloIdx < 0) return buf;
    final kept = <int>[];
    for (var i = 0; i < buf.triCount; i++) {
      if (buf.partIds[i] == soloIdx) kept.add(i);
    }
    if (kept.isEmpty) return buf;
    final n = kept.length;
    final v2 = Float32List(n * 9);
    final c2 = Int32List(n);
    final nm2 = Float32List(n * 3);
    final p2 = Int32List(n);
    for (var j = 0; j < n; j++) {
      final i = kept[j];
      v2.setRange(j * 9, j * 9 + 9, buf.verts, i * 9);
      c2[j] = buf.colors[i];
      nm2.setRange(j * 3, j * 3 + 3, buf.norms, i * 3);
      p2[j] = buf.partIds[i];
    }
    return GlbMeshBuffer(
      verts: v2, colors: c2, norms: nm2, partIds: p2,
      partKeys: allKeys, partNamesEn: buf.partNamesEn, partNamesAr: buf.partNamesAr,
      triCount: n,
    );
  }

  /// Returns cached high-fidelity 3D mesh faces for the given discipline,
  /// with automatic filtering if solo mode is active.
  static List<MeshFace3D>? getMesh(
    ClinicalSpecialtyDiscipline d, {
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    final cached = _cache[d];
    if (cached == null || cached.isEmpty) return null;
    if (!isSoloMode || soloPartKey == null) return cached;
    final filtered = cached.where((f) => f.partKey == soloPartKey).toList();
    return filtered.isNotEmpty ? filtered : cached;
  }

  /// Finds the [GlbMeshBuffer] that corresponds to a given list of [MeshFace3D]
  /// faces by matching the first face's partKey against each cached discipline.
  /// Called by the painter to avoid a direct dependency on [ClinicalSpecialtyDiscipline].
  static GlbMeshBuffer? findBufferForFaces(
    List<MeshFace3D> faces, {
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    if (faces.isEmpty) return null;
    final firstKey = faces.first.partKey;
    for (final entry in _cache.entries) {
      final cached = entry.value;
      if (cached.isNotEmpty && cached.first.partKey == firstKey) {
        return getMeshBuffer(entry.key, isSoloMode: isSoloMode, soloPartKey: soloPartKey);
      }
    }
    return null;
  }

  /// Asynchronously loads the high-fidelity GLB 3D model for the given discipline.
  static Future<List<MeshFace3D>> loadDisciplineMesh(ClinicalSpecialtyDiscipline d) {
    if (_cache.containsKey(d)) return Future.value(_cache[d]!);
    if (_loadingFutures.containsKey(d)) return _loadingFutures[d]!;

    final future = _loadMeshFromAsset(d);
    _loadingFutures[d] = future;
    return future;
  }

  static Future<List<MeshFace3D>> _loadMeshFromAsset(ClinicalSpecialtyDiscipline d) async {
    final assetPath = _getAssetPathForDiscipline(d);
    if (assetPath == null) {
      _loadingFutures.remove(d);
      return [];
    }

    try {
      final byteData = await rootBundle.load(assetPath);
      final bytes = byteData.buffer.asUint8List();
      final (faces, buffer) = _parseGlbToMeshFaces(bytes, d);

      _cache[d] = faces;
      _bufCache[d] = buffer;
      _notify();
      return faces;
    } catch (e) {
      debugPrint('Could not load 3D GLB model for $d from $assetPath: $e');
      return [];
    } finally {
      _loadingFutures.remove(d);
    }
  }

  static String? getAssetPathForDiscipline(ClinicalSpecialtyDiscipline d) => _getAssetPathForDiscipline(d);

  static String? _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline d) {
    switch (d) {
      case ClinicalSpecialtyDiscipline.cardiology:
      case ClinicalSpecialtyDiscipline.vascularVein:
        return 'assets/models/cardiology/heart.glb';
      case ClinicalSpecialtyDiscipline.neurology:
      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
      case ClinicalSpecialtyDiscipline.mentalHealth:
        return 'assets/models/neurology/brain.glb';
      case ClinicalSpecialtyDiscipline.dermatology:
      case ClinicalSpecialtyDiscipline.plasticSurgery:
      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return 'assets/models/dermatology/skin_anatomy.glb';
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
      case ClinicalSpecialtyDiscipline.neuroOtology:
      case ClinicalSpecialtyDiscipline.speechPathology:
        return 'assets/models/ent/inner_ear.glb';
      case ClinicalSpecialtyDiscipline.ophthalmology:
        return 'assets/models/ophthalmology/eye.glb';
      case ClinicalSpecialtyDiscipline.pulmonology:
        return 'assets/models/respiratory/lungs.glb';
      case ClinicalSpecialtyDiscipline.urology:
        return 'assets/models/urology/kidney.glb';
      case ClinicalSpecialtyDiscipline.gastroenterology:
      case ClinicalSpecialtyDiscipline.endocrinology:
        return 'assets/models/gastroenterology/digestive.glb';
      case ClinicalSpecialtyDiscipline.obgyn:
        return 'assets/models/obgyn/female_reproductive.glb';
      case ClinicalSpecialtyDiscipline.general:
      case ClinicalSpecialtyDiscipline.physiotherapy:
      case ClinicalSpecialtyDiscipline.pediatrics:
      case ClinicalSpecialtyDiscipline.painManagement:
      case ClinicalSpecialtyDiscipline.acupuncture:
      case ClinicalSpecialtyDiscipline.veterinary:
      case ClinicalSpecialtyDiscipline.diagnosticLab:
      case ClinicalSpecialtyDiscipline.podiatry:
        return 'assets/models/general/full_body_anatomy.glb';
      case ClinicalSpecialtyDiscipline.orthopedics:
        return 'assets/models/orthopedics/male_skeleton.glb';
      case ClinicalSpecialtyDiscipline.dental:
        return 'assets/models/teeth/molar.glb';
    }
  }

  /// Parses a GLB binary blob into both a legacy MeshFace3D list (for procedural
  /// fallback compatibility) and a high-performance GlbMeshBuffer.
  ///
  /// Hard budget: _kMaxFaces triangles maximum to guarantee <=16ms paint().
  static (List<MeshFace3D>, GlbMeshBuffer) _parseGlbToMeshFaces(
      Uint8List bytes, ClinicalSpecialtyDiscipline discipline) {
    if (bytes.length < 20) {
      return (<MeshFace3D>[], _emptyBuffer());
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
    final meshes = (gltf['meshes'] as List).cast<Map<String, dynamic>>();

    // 1. Global bounding box for uniform normalisation
    var minX = double.infinity, minY = double.infinity, minZ = double.infinity;
    var maxX = double.negativeInfinity, maxY = double.negativeInfinity, maxZ = double.negativeInfinity;

    for (final acc in accessors) {
      if (acc['type'] == 'VEC3' && acc.containsKey('min') && acc.containsKey('max')) {
        final mn = (acc['min'] as List).cast<num>();
        final mx = (acc['max'] as List).cast<num>();
        minX = math.min(minX, mn[0].toDouble());
        minY = math.min(minY, mn[1].toDouble());
        minZ = math.min(minZ, mn[2].toDouble());
        maxX = math.max(maxX, mx[0].toDouble());
        maxY = math.max(maxY, mx[1].toDouble());
        maxZ = math.max(maxZ, mx[2].toDouble());
      }
    }

    if (minX == double.infinity) {
      minX = -1; minY = -1; minZ = -1;
      maxX = 1;  maxY = 1;  maxZ = 1;
    }

    final centerX = (minX + maxX) / 2.0;
    final centerY = (minY + maxY) / 2.0;
    final centerZ = (minZ + maxZ) / 2.0;
    final maxDim = math.max((maxX-minX).abs(), math.max((maxY-minY).abs(), (maxZ-minZ).abs()));
    final scale  = maxDim > 0.00001 ? (190.0 / maxDim) : 1.0;

    // 2. Count total triangles across all primitives to set adaptive stride
    var totalRawTris = 0;
    for (final m in meshes) {
      for (final prim in (m['primitives'] as List).cast<Map<String, dynamic>>()) {
        if (prim.containsKey('indices')) {
          final idxAcc = accessors[prim['indices'] as int];
          totalRawTris += (idxAcc['count'] as int) ~/ 3;
        } else {
          final attrs = prim['attributes'] as Map<String, dynamic>;
          if (attrs.containsKey('POSITION')) {
            totalRawTris += (accessors[attrs['POSITION'] as int]['count'] as int) ~/ 3;
          }
        }
      }
    }

    // Adaptive stride so we always land at or below the hard budget
    final stride = math.max(1, (totalRawTris / _kMaxFaces).ceil());

    final colorPalette = _getColorPaletteForDiscipline(discipline);

    // 3. Preallocate flat typed arrays (oversized; trimmed after)
    final maxExpected = math.min(totalRawTris, _kMaxFaces);
    final vertsArr  = Float32List(maxExpected * 9);
    final colorsArr = Int32List(maxExpected);
    final normsArr  = Float32List(maxExpected * 3);
    final partIdsArr= Int32List(maxExpected);

    final partKeys    = <String?>[];
    final partNamesEn = <String?>[];
    final partNamesAr = <String?>[];

    // Legacy MeshFace3D list (small, for tap hit-testing)
    final faces = <MeshFace3D>[];

    var faceIdx = 0;

    for (var mIdx = 0; mIdx < meshes.length; mIdx++) {
      if (faceIdx >= _kMaxFaces) break;
      final m = meshes[mIdx];
      final meshName = m['name'] as String? ?? 'part_$mIdx';
      final primitives = (m['primitives'] as List).cast<Map<String, dynamic>>();
      final baseColor = colorPalette[mIdx % colorPalette.length];
      final partInfo  = _getPartLabels(discipline, mIdx, meshName);

      // Register part
      int partId = partKeys.indexOf(partInfo.key);
      if (partId < 0) {
        partId = partKeys.length;
        partKeys.add(partInfo.key);
        partNamesEn.add(partInfo.nameEn);
        partNamesAr.add(partInfo.nameAr);
      }

      for (final prim in primitives) {
        if (faceIdx >= _kMaxFaces) break;
        final attrs = prim['attributes'] as Map<String, dynamic>;
        if (!attrs.containsKey('POSITION')) continue;

        final posAccIdx = attrs['POSITION'] as int;
        final posAcc = accessors[posAccIdx];
        final posBv  = bufferViews[posAcc['bufferView'] as int];
        final posOffset = (posBv['byteOffset'] as int? ?? 0) + (posAcc['byteOffset'] as int? ?? 0);
        final posCount  = posAcc['count'] as int;

        // Read raw positions into a flat double array (avoids Point3D allocation)
        final rawPos = Float64List(posCount * 3);
        for (var i = 0; i < posCount; i++) {
          final base = posOffset + i * 12;
          rawPos[i*3]   = (_readFloat32(binBytes, base)     - centerX) * scale;
          rawPos[i*3+1] = -(_readFloat32(binBytes, base + 4) - centerY) * scale;
          rawPos[i*3+2] = (_readFloat32(binBytes, base + 8)  - centerZ) * scale;
        }

        final br = (baseColor.r * 255).round();
        final bg = (baseColor.g * 255).round();
        final bb = (baseColor.b * 255).round();
        final ba = baseColor.a > 0.05 ? (baseColor.a * 255).round() : 255;
        final colorARGB = (ba << 24) | (br << 16) | (bg << 8) | bb;

        void storeTri(int i0, int i1, int i2) {
          if (faceIdx >= _kMaxFaces) return;
          final b0 = i0*3, b1 = i1*3, b2 = i2*3;
          final vBase = faceIdx * 9;

          vertsArr[vBase]   = rawPos[b0];   vertsArr[vBase+1] = rawPos[b0+1]; vertsArr[vBase+2] = rawPos[b0+2];
          vertsArr[vBase+3] = rawPos[b1];   vertsArr[vBase+4] = rawPos[b1+1]; vertsArr[vBase+5] = rawPos[b1+2];
          vertsArr[vBase+6] = rawPos[b2];   vertsArr[vBase+7] = rawPos[b2+1]; vertsArr[vBase+8] = rawPos[b2+2];

          colorsArr[faceIdx]  = colorARGB;
          partIdsArr[faceIdx] = partId;

          // Face normal (cross product)
          final ax = rawPos[b1]-rawPos[b0], ay = rawPos[b1+1]-rawPos[b0+1], az = rawPos[b1+2]-rawPos[b0+2];
          final bx = rawPos[b2]-rawPos[b0], by = rawPos[b2+1]-rawPos[b0+1], bz = rawPos[b2+2]-rawPos[b0+2];
          var nx = ay*bz - az*by;
          var ny = az*bx - ax*bz;
          var nz = ax*by - ay*bx;
          final len = math.sqrt(nx*nx + ny*ny + nz*nz);
          if (len > 1e-9) { nx /= len; ny /= len; nz /= len; }
          normsArr[faceIdx*3]   = nx;
          normsArr[faceIdx*3+1] = ny;
          normsArr[faceIdx*3+2] = nz;

          // Also store in legacy list for hit-testing (keep small)
          if (faces.length < 500) {
            faces.add(MeshFace3D(
              vertices: [
                Point3D(rawPos[b0], rawPos[b0+1], rawPos[b0+2]),
                Point3D(rawPos[b1], rawPos[b1+1], rawPos[b1+2]),
                Point3D(rawPos[b2], rawPos[b2+1], rawPos[b2+2]),
              ],
              baseColor: baseColor,
              partKey: partInfo.key,
              partNameEn: partInfo.nameEn,
              partNameAr: partInfo.nameAr,
            ));
          }
          faceIdx++;
        }

        if (!prim.containsKey('indices')) {
          for (var i = 0; i + 2 < posCount && faceIdx < _kMaxFaces; i += 3 * stride) {
            storeTri(i, i + 1, i + 2);
          }
          continue;
        }

        final idxAccIdx = prim['indices'] as int;
        final idxAcc    = accessors[idxAccIdx];
        final idxBv     = bufferViews[idxAcc['bufferView'] as int];
        final idxOffset = (idxBv['byteOffset'] as int? ?? 0) + (idxAcc['byteOffset'] as int? ?? 0);
        final idxCount  = idxAcc['count'] as int;
        final compType  = idxAcc['componentType'] as int? ?? 5125;

        for (var i = 0; i + 2 < idxCount && faceIdx < _kMaxFaces; i += 3 * stride) {
          int r0, r1, r2;
          if (compType == 5123) {
            final p = idxOffset + i * 2;
            r0 = binBytes[p]   | (binBytes[p+1] << 8);
            r1 = binBytes[p+2] | (binBytes[p+3] << 8);
            r2 = binBytes[p+4] | (binBytes[p+5] << 8);
          } else {
            r0 = _readUint32(binBytes, idxOffset + i * 4);
            r1 = _readUint32(binBytes, idxOffset + (i+1) * 4);
            r2 = _readUint32(binBytes, idxOffset + (i+2) * 4);
          }
          if (r0 < posCount && r1 < posCount && r2 < posCount) {
            storeTri(r0, r1, r2);
          }
        }
      }
    }

    // Trim typed arrays to actual face count
    final buf = GlbMeshBuffer(
      verts:    Float32List.sublistView(vertsArr,   0, faceIdx * 9),
      colors:   Int32List.sublistView(colorsArr,    0, faceIdx),
      norms:    Float32List.sublistView(normsArr,   0, faceIdx * 3),
      partIds:  Int32List.sublistView(partIdsArr,   0, faceIdx),
      partKeys: partKeys,
      partNamesEn: partNamesEn,
      partNamesAr: partNamesAr,
      triCount: faceIdx,
    );

    return (faces, buf);
  }

  static GlbMeshBuffer _emptyBuffer() => GlbMeshBuffer(
    verts: Float32List(0), colors: Int32List(0), norms: Float32List(0), partIds: Int32List(0),
    partKeys: [], partNamesEn: [], partNamesAr: [], triCount: 0,
  );

  static int _readUint32(Uint8List bytes, int offset) {
    return bytes[offset] |
        (bytes[offset + 1] << 8) |
        (bytes[offset + 2] << 16) |
        (bytes[offset + 3] << 24);
  }

  static double _readFloat32(Uint8List bytes, int offset) {
    return ByteData.sublistView(bytes, offset, offset + 4).getFloat32(0, Endian.little);
  }

  static List<Color> _getColorPaletteForDiscipline(ClinicalSpecialtyDiscipline d) {
    switch (d) {
      case ClinicalSpecialtyDiscipline.cardiology:
      case ClinicalSpecialtyDiscipline.vascularVein:
        return const [
          Color(0xFFDC2626), // Myocardium
          Color(0xFFEF4444), // Right ventricle
          Color(0xFFE11D48), // Aorta
          Color(0xFF2563EB), // Pulmonary artery
          Color(0xFFB91C1C), // Left atrium
          Color(0xFF991B1B), // Coronary branch
        ];
      case ClinicalSpecialtyDiscipline.neurology:
      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
      case ClinicalSpecialtyDiscipline.mentalHealth:
        return const [
          Color(0xFFE2B4BD), // Cerebral Cortex
          Color(0xFFD4A373), // Cerebellum
          Color(0xFFCCD5AE), // Brainstem
        ];
      case ClinicalSpecialtyDiscipline.dermatology:
      case ClinicalSpecialtyDiscipline.plasticSurgery:
      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return const [
          Color(0xFFFDBA74), // Epidermis
          Color(0xFFFB7185), // Dermis
          Color(0xFFFACC15), // Hypodermis
          Color(0xFF78350F), // Hair follicle
        ];
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
      case ClinicalSpecialtyDiscipline.neuroOtology:
      case ClinicalSpecialtyDiscipline.speechPathology:
        return const [
          Color(0xFFE0E7FF), // Cochlea
          Color(0xFF38BDF8), // Semicircular canals
          Color(0xFFBAE6FD), // Tympanic membrane
        ];
      case ClinicalSpecialtyDiscipline.ophthalmology:
        return const [
          Color(0xFFF8FAFC), // Sclera
          Color(0xFF38BDF8), // Cornea
          Color(0xFF0284C7), // Iris
          Color(0xFF0F172A), // Pupil
        ];
      case ClinicalSpecialtyDiscipline.pulmonology:
        return const [
          Color(0xFFFDA4AF), // Right lung
          Color(0xFFFB7185), // Left lung
          Color(0xFF94A3B8), // Tracheobronchial tree
        ];
      case ClinicalSpecialtyDiscipline.urology:
        return const [
          Color(0xFF991B1B), // Renal cortex
          Color(0xFF7F1D1D), // Medullary pyramids
          Color(0xFFFED7AA), // Renal pelvis
          Color(0xFFFDE68A), // Ureter
        ];
      case ClinicalSpecialtyDiscipline.gastroenterology:
      case ClinicalSpecialtyDiscipline.endocrinology:
        return const [
          Color(0xFF881337), // Liver
          Color(0xFF059669), // Gallbladder
          Color(0xFFFBBF24), // Stomach
          Color(0xFFFB923C), // Pancreas
          Color(0xFFEA580C), // Duodenum
        ];
      case ClinicalSpecialtyDiscipline.obgyn:
        return const [
          Color(0xFFE11D48), // Uterus
          Color(0xFFFECDD3), // Ovaries
          Color(0xFFFDA4AF), // Fallopian tubes
          Color(0xFFBE123C), // Cervix
        ];
      default:
        return const [
          Color(0xFFE2E8F0),
          Color(0xFF38BDF8),
          Color(0xFF0D9488),
          Color(0xFFF59E0B),
        ];
    }
  }

  static _PartInfo _getPartLabels(ClinicalSpecialtyDiscipline d, int idx, String name) {
    final prefix = d.name.toLowerCase();
    final key = '${prefix}_part_$idx';

    switch (d) {
      case ClinicalSpecialtyDiscipline.cardiology:
        final namesEn = ['Left Ventricle', 'Right Ventricle', 'Aortic Arch', 'Pulmonary Artery', 'Left Atrium', 'Right Atrium'];
        final namesAr = ['البطين الأيسر', 'البطين الأيمن', 'القوس الأبهري', 'الشريان الرئوي', 'الأذين الأيسر', 'الأذين الأيمن'];
        return _PartInfo(key, namesEn[idx % namesEn.length], namesAr[idx % namesAr.length]);
      case ClinicalSpecialtyDiscipline.neurology:
        return const _PartInfo('neuro_brain', 'Cerebral Cortex & Hemispheres', 'القشرة المخية وفصوص الدماغ');
      case ClinicalSpecialtyDiscipline.ophthalmology:
        final namesEn = ['Cornea & Lens', 'Iris & Pupil', 'Sclera & Choroid', 'Sensory Retina'];
        final namesAr = ['القرنية والعدسة', 'القزحية والحدقة', 'الصلبة والمشيمية', 'الشبكية البصرية'];
        return _PartInfo(key, namesEn[idx % namesEn.length], namesAr[idx % namesAr.length]);
      case ClinicalSpecialtyDiscipline.pulmonology:
        final namesEn = ['Right Lung Lobes', 'Left Lung Lobes', 'Tracheobronchial Tree'];
        final namesAr = ['فصوص الرئة اليمنى', 'فصوص الرئة اليسرى', 'الشجرة الرغامية القصبية'];
        return _PartInfo(key, namesEn[idx % namesEn.length], namesAr[idx % namesAr.length]);
      case ClinicalSpecialtyDiscipline.urology:
        final namesEn = ['Renal Cortex', 'Medullary Pyramids', 'Renal Pelvis', 'Ureter', 'Renal Artery', 'Renal Vein'];
        final namesAr = ['القشرة الكلوية', 'الأهرامات اللبية', 'حويضة الكلية', 'الحالب', 'الشريان الكلوي', 'الوريد الكلوي'];
        return _PartInfo(key, namesEn[idx % namesEn.length], namesAr[idx % namesAr.length]);
      case ClinicalSpecialtyDiscipline.gastroenterology:
        final namesEn = ['Liver (Right/Left Lobes)', 'Gallbladder & Cystic Duct', 'Stomach (Cardia/Antrum)', 'Pancreas', 'Duodenum'];
        final namesAr = ['الكبد (الفص الأيمن والأيسر)', 'المرارة والقناة المرارية', 'المعدة', 'البنكرياس', 'الاثني عشر'];
        return _PartInfo(key, namesEn[idx % namesEn.length], namesAr[idx % namesAr.length]);
      case ClinicalSpecialtyDiscipline.obgyn:
        final namesEn = ['Uterine Body (Myometrium)', 'Ovaries (Left/Right)', 'Fallopian Tubes (Oviducts)', 'Cervical Canal & Vagina'];
        final namesAr = ['جسم الرحم وعضلته', 'المبيضان (الأيمن والأيسر)', 'قناتا فالوب', 'عنق الرحم والمهبل'];
        return _PartInfo(key, namesEn[idx % namesEn.length], namesAr[idx % namesAr.length]);
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
        final namesEn = ['Cochlea & Organ of Corti', 'Semicircular Canals', 'Vestibular Nerve & Ossicles', 'Tympanic Membrane'];
        final namesAr = ['القوقعة وعضو كورتي', 'القنوات الهلالية', 'العصب الدهليزي وعظيمات السمع', 'طبلة الأذن'];
        return _PartInfo(key, namesEn[idx % namesEn.length], namesAr[idx % namesAr.length]);
      case ClinicalSpecialtyDiscipline.dermatology:
        final namesEn = ['Epidermal Stratum Corneum', 'Dermis (Papillary/Reticular)', 'Subcutaneous Adipose Tissue', 'Hair Follicle & Sebaceous Gland'];
        final namesAr = ['الطبقة المتقرنة للبشرة', 'الأدمة الحليمية والشبكية', 'النسيج الدهني تحت الجلدي', 'جريب الشعرة والغدة الزهمية'];
        return _PartInfo(key, namesEn[idx % namesEn.length], namesAr[idx % namesAr.length]);
      default:
        return _PartInfo(key, name, name);
    }
  }

  /// Automatically identifies the GLB asset file associated with the given face list.
  static String? findAssetPathForFaces(List<MeshFace3D> faces) {
    if (faces.isEmpty) return null;
    for (final face in faces) {
      final key = face.partKey;
      if (key == null) continue;
      final lower = key.toLowerCase();
      if (lower.startsWith('cardio')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.cardiology);
      if (lower.startsWith('neuro')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.neurology);
      if (lower.startsWith('pulm') || lower.startsWith('lung')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.pulmonology);
      if (lower.startsWith('uro') || lower.startsWith('kidney')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.urology);
      if (lower.startsWith('gastro') || lower.startsWith('digest')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.gastroenterology);
      if (lower.startsWith('obgyn') || lower.startsWith('uterus')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.obgyn);
      if (lower.startsWith('ent') || lower.startsWith('ear')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.rhinologyEnt);
      if (lower.startsWith('eye') || lower.startsWith('ophthal')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.ophthalmology);
      if (lower.startsWith('derma') || lower.startsWith('skin')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.dermatology);
      if (lower.startsWith('tooth') || lower.startsWith('dental')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.dental);
      if (lower.startsWith('ortho') || lower.startsWith('bone')) return _getAssetPathForDiscipline(ClinicalSpecialtyDiscipline.orthopedics);
      for (final d in ClinicalSpecialtyDiscipline.values) {
        final prefix = d.name.toLowerCase();
        if (lower.startsWith(prefix) || lower.contains(prefix)) {
          return _getAssetPathForDiscipline(d);
        }
      }
    }
    return null;
  }
}

class _PartInfo {
  final String key;
  final String nameEn;
  final String nameAr;
  const _PartInfo(this.key, this.nameEn, this.nameAr);
}
