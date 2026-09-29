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

  static final Map<ClinicalSpecialtyDiscipline, List<MeshFace3D>> _cache = {};
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
      final faces = _parseGlbToMeshFaces(bytes, d);

      _cache[d] = faces;
      _notify();
      return faces;
    } catch (e) {
      debugPrint('Could not load 3D GLB model for $d from $assetPath: $e');
      return [];
    } finally {
      _loadingFutures.remove(d);
    }
  }

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

  static List<MeshFace3D> _parseGlbToMeshFaces(Uint8List bytes, ClinicalSpecialtyDiscipline discipline) {
    if (bytes.length < 20) return [];

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

    // 1. Calculate Global Bounding Box across all primitives
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
      maxX = 1; maxY = 1; maxZ = 1;
    }

    final centerX = (minX + maxX) / 2.0;
    final centerY = (minY + maxY) / 2.0;
    final centerZ = (minZ + maxZ) / 2.0;

    final dimX = (maxX - minX).abs();
    final dimY = (maxY - minY).abs();
    final dimZ = (maxZ - minZ).abs();
    final maxDim = math.max(dimX, math.max(dimY, dimZ));
    final scale = maxDim > 0.00001 ? (190.0 / maxDim) : 1.0;

    final faces = <MeshFace3D>[];
    final colorPalette = _getColorPaletteForDiscipline(discipline);

    for (var mIdx = 0; mIdx < meshes.length; mIdx++) {
      final m = meshes[mIdx];
      final meshName = m['name'] as String? ?? 'part_$mIdx';
      final primitives = (m['primitives'] as List).cast<Map<String, dynamic>>();
      final baseColor = colorPalette[mIdx % colorPalette.length];

      final partInfo = _getPartLabels(discipline, mIdx, meshName);

      for (final prim in primitives) {
        final attrs = prim['attributes'] as Map<String, dynamic>;
        if (!attrs.containsKey('POSITION')) continue;

        final posAccIdx = attrs['POSITION'] as int;
        final posAcc = accessors[posAccIdx];
        final posBv = bufferViews[posAcc['bufferView'] as int];
        final posOffset = (posBv['byteOffset'] as int? ?? 0) + (posAcc['byteOffset'] as int? ?? 0);
        final posCount = posAcc['count'] as int;

        final positions = List<Point3D>.generate(posCount, (i) {
          final base = posOffset + i * 12;
          final rx = _readFloat32(binBytes, base);
          final ry = _readFloat32(binBytes, base + 4);
          final rz = _readFloat32(binBytes, base + 8);

          return Point3D(
            (rx - centerX) * scale,
            -(ry - centerY) * scale, // Flip Y for standard screen coordinates
            (rz - centerZ) * scale,
          );
        });

        if (!prim.containsKey('indices')) {
          for (var i = 0; i + 2 < positions.length; i += 3) {
            faces.add(MeshFace3D(
              vertices: [positions[i], positions[i + 1], positions[i + 2]],
              baseColor: baseColor,
              partKey: partInfo.key,
              partNameEn: partInfo.nameEn,
              partNameAr: partInfo.nameAr,
            ));
          }
          continue;
        }

        final idxAccIdx = prim['indices'] as int;
        final idxAcc = accessors[idxAccIdx];
        final idxBv = bufferViews[idxAcc['bufferView'] as int];
        final idxOffset = (idxBv['byteOffset'] as int? ?? 0) + (idxAcc['byteOffset'] as int? ?? 0);
        final idxCount = idxAcc['count'] as int;
        final compType = idxAcc['componentType'] as int? ?? 5125;

        final rawIndices = <int>[];
        if (compType == 5123) {
          for (var i = 0; i < idxCount; i++) {
            final p = idxOffset + i * 2;
            rawIndices.add(binBytes[p] | (binBytes[p + 1] << 8));
          }
        } else {
          for (var i = 0; i < idxCount; i++) {
            rawIndices.add(_readUint32(binBytes, idxOffset + i * 4));
          }
        }

        // Subsample large meshes for buttery smooth 60 FPS
        final stride = rawIndices.length > 24000 ? 6 : (rawIndices.length > 12000 ? 3 : 1);

        for (var i = 0; i + 2 < rawIndices.length; i += 3 * stride) {
          final i0 = rawIndices[i];
          final i1 = rawIndices[i + 1];
          final i2 = rawIndices[i + 2];

          if (i0 >= positions.length || i1 >= positions.length || i2 >= positions.length) {
            continue;
          }

          faces.add(MeshFace3D(
            vertices: [positions[i0], positions[i1], positions[i2]],
            baseColor: baseColor,
            partKey: partInfo.key,
            partNameEn: partInfo.nameEn,
            partNameAr: partInfo.nameAr,
          ));
        }
      }
    }

    return faces;
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
}

class _PartInfo {
  final String key;
  final String nameEn;
  final String nameAr;
  const _PartInfo(this.key, this.nameEn, this.nameAr);
}
