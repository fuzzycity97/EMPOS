import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/localization/app_language.dart';
import '../../domain/entities/clinical_anatomy_status_entry.dart';
import 'specialty_3d_anatomical_models.dart';
import 'specialty_glb_mesh_library.dart';
import 'gpu_glb_viewer.dart';
import 'anatomical_model_registry.dart';
import 'multi_specialty_anatomy_canvas_widget.dart';

/// Universal Clinical Age Progression Stages for all medical disciplines
enum ClinicalAgeStage {
  infant('Infant / Neonate', 'رضيع / حديث الولادة', '0 - 12 Months', 'خصائص ولادية ونمو أولي'),
  child('Child / Pediatric', 'طفل', '1 - 11 Years', 'مرحلة الطفولة وتطور الأنسجة'),
  adolescent('Adolescent / Youth', 'يافع / مراهق', '12 - 18 Years', 'اكتمال التمايز الهيكلي والهرموني'),
  adult('Mature Adult', 'بالغ مكتمل', '19 - 64 Years', 'الكتلة التشريحية النموذجية'),
  geriatric('Geriatric / Senior', 'مسن / كبير السن', '65+ Years', 'تغيرات الشيخوخة والضمور والصلابة');

  final String titleEn;
  final String titleAr;
  final String ageRange;
  final String descAr;

  const ClinicalAgeStage(this.titleEn, this.titleAr, this.ageRange, this.descAr);

  String get localizedTitle => AppLanguage.isArabic ? titleAr : titleEn;
}

/// Real-time 3D Graphics Performance and Statistics Tracker across all clinical disciplines
class Clinical3dPerformanceTracker {
  static final Clinical3dPerformanceTracker instance = Clinical3dPerformanceTracker._();
  Clinical3dPerformanceTracker._();

  int _frameCount = 0;
  int _lastTimeMicros = 0;
  double fps = 60.0;
  int lastFrameTimeMs = 1;
  int lastTriangles = 0;
  int lastDrawCalls = 1;

  void recordFrame(int triangles, int drawCalls, int frameTimeMs) {
    lastTriangles = triangles;
    lastDrawCalls = drawCalls;
    lastFrameTimeMs = frameTimeMs;

    _frameCount++;
    final now = DateTime.now().microsecondsSinceEpoch;
    if (_lastTimeMicros == 0) {
      _lastTimeMicros = now;
      return;
    }
    final elapsed = now - _lastTimeMicros;
    if (elapsed >= 400000) {
      fps = (_frameCount * 1000000.0 / elapsed).clamp(1.0, 60.0);
      _frameCount = 0;
      _lastTimeMicros = now;
    }
  }
}

/// Simple 3D point with vector operations and rotation
class Point3D {
  final double x;
  final double y;
  final double z;

  const Point3D(this.x, this.y, this.z);

  Point3D operator +(Point3D other) => Point3D(x + other.x, y + other.y, z + other.z);
  Point3D operator -(Point3D other) => Point3D(x - other.x, y - other.y, z - other.z);
  Point3D operator *(double scalar) => Point3D(x * scalar, y * scalar, z * scalar);

  double dot(Point3D o) => x * o.x + y * o.y + z * o.z;

  Point3D cross(Point3D o) => Point3D(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  double get length => math.sqrt(x * x + y * y + z * z);

  Point3D normalized() {
    final len = length;
    if (len < 0.000001) return const Point3D(0, 1, 0);
    return Point3D(x / len, y / len, z / len);
  }

  Point3D rotateX(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Point3D(x, y * cosA - z * sinA, y * sinA + z * cosA);
  }

  Point3D rotateY(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Point3D(x * cosA + z * sinA, y, -x * sinA + z * cosA);
  }

  Point3D rotateZ(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Point3D(x * cosA - y * sinA, x * sinA + y * cosA, z);
  }

  Point3D rotateEuler(double yaw, double pitch) {
    final p = rotateX(pitch);
    return p.rotateY(yaw);
  }

  Offset toScreen(Size size, double scale, {double fov = 400.0}) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final dist = fov / (fov + z + 200.0);
    return Offset(cx + x * scale * dist, cy + y * scale * dist);
  }
}

/// 3D Polygonal or Parametric Mesh Face
class MeshFace3D {
  final List<Point3D> vertices;
  final Color baseColor;
  final String? partKey;
  final String? partNameEn;
  final String? partNameAr;
  final bool isWireframe;

  MeshFace3D({
    required this.vertices,
    required this.baseColor,
    this.partKey,
    this.partNameEn,
    this.partNameAr,
    this.isWireframe = false,
  });

  Point3D get centroid {
    double sx = 0, sy = 0, sz = 0;
    for (final v in vertices) {
      sx += v.x;
      sy += v.y;
      sz += v.z;
    }
    final n = vertices.length;
    return Point3D(sx / n, sy / n, sz / n);
  }

  Point3D computeNormal() {
    if (vertices.length < 3) return const Point3D(0, 0, 1);
    final v0 = vertices[0];
    final v1 = vertices[1];
    final v2 = vertices[2];
    return (v1 - v0).cross(v2 - v0).normalized();
  }
}

/// High-performance flat vertex buffer produced once at GLB load time.
/// The painter reads directly from typed arrays — zero per-frame allocations,
/// no `List<Point3D>` construction, no depth sort (budget is kept small enough
/// that painter-order is visually acceptable).
class GlbMeshBuffer {
  /// Flat vertex array: [x0,y0,z0, x1,y1,z1, x2,y2,z2, ...] per triangle
  final Float32List verts;
  /// Packed ARGB color per triangle
  final Int32List colors;
  /// Pre-computed face normals: [nx,ny,nz, ...] per triangle
  final Float32List norms;
  /// Part index per triangle (indexes into partKeys)
  final Int32List partIds;
  final List<String?> partKeys;
  final List<String?> partNamesEn;
  final List<String?> partNamesAr;
  final int triCount;

  const GlbMeshBuffer({
    required this.verts,
    required this.colors,
    required this.norms,
    required this.partIds,
    required this.partKeys,
    required this.partNamesEn,
    required this.partNamesAr,
    required this.triCount,
  });
}

/// Interactive 3D Anatomical Scene Viewer Widget with Solo Part Inspection & 3D Medical Instruments
class Clinical3dSceneViewer extends StatefulWidget {
  final List<MeshFace3D> Function(
    ClinicalAgeStage ageStage, {
    SpecialtyInstrument? instrument,
    bool isSoloMode,
    String? soloPartKey,
  }) sceneMeshBuilder;
  final void Function(String partKey, String nameEn, String nameAr)? onPartSelected;
  final void Function(String partKey, String nameEn, String nameAr, Offset globalPos)? onPartSecondaryTap;
  final Map<String, ClinicalAnatomyStatusEntry>? activeStatuses;
  final ClinicalAgeStage initialAgeStage;
  final void Function(ClinicalAgeStage stage)? onAgeStageChanged;
  final String specialtyTitle;
  final String specialtyTitleAr;
  final IconData specialtyIcon;
  final Color primaryColor;
  final double initialZoom;
  final double initialPitch;
  final double initialYaw;
  final double height;
  final List<SpecialtyInstrument> availableInstruments;
  final Widget? overlayBottomWidget;
  final String? glbAssetPath;
  final ClinicalSpecialtyDiscipline? discipline;

  const Clinical3dSceneViewer({
    super.key,
    required this.sceneMeshBuilder,
    this.onPartSelected,
    this.onPartSecondaryTap,
    this.activeStatuses,
    this.initialAgeStage = ClinicalAgeStage.adult,
    this.onAgeStageChanged,
    required this.specialtyTitle,
    required this.specialtyTitleAr,
    required this.specialtyIcon,
    required this.primaryColor,
    this.initialZoom = 1.0,
    this.initialPitch = 0.2,
    this.initialYaw = 0.3,
    this.height = 370,
    this.availableInstruments = const [],
    this.overlayBottomWidget,
    this.glbAssetPath,
    this.discipline,
  });

  @override
  State<Clinical3dSceneViewer> createState() => _Clinical3dSceneViewerState();
}

class _Clinical3dSceneViewerState extends State<Clinical3dSceneViewer> with SingleTickerProviderStateMixin {
  late ClinicalAgeStage _currentAgeStage;
  late final ValueNotifier<double> _yawNotifier;
  late final ValueNotifier<double> _pitchNotifier;
  late final ValueNotifier<double> _zoomNotifier;
  late final ValueNotifier<bool> _showStatsNotifier;
  List<MeshFace3D> _cachedFaces = const [];
  GlbMeshBuffer? _cachedGlbBuffer;
  Offset? _lastPanPos;
  String? _hoveredPartKey;
  String? _selectedPartKey;
  String? _selectedPartNameEn;
  String? _selectedPartNameAr;
  bool _isSoloMode = false;
  bool _autoRotate = false;
  late final AnimationController _autoRotController;
  Timer? _singleTapTimer;
  Offset? _pendingTapPos;
  bool _useGpuViewer = true;
  String? _resolvedGlbAsset;
  String? _customSelectedModelAsset;

  ClinicalSpecialtyDiscipline _deduceDiscipline() {
    if (widget.discipline != null) return widget.discipline!;
    final title = widget.specialtyTitle.toLowerCase();
    if (title.contains('cardio') || title.contains('heart') || title.contains('vascular')) {
      return ClinicalSpecialtyDiscipline.cardiology;
    }
    if (title.contains('dental') || title.contains('oral') || title.contains('tooth') || title.contains('teeth')) {
      return ClinicalSpecialtyDiscipline.dental;
    }
    if (title.contains('neuro') || title.contains('brain')) {
      return ClinicalSpecialtyDiscipline.neurology;
    }
    if (title.contains('ent') || title.contains('ear') || title.contains('sinus') || title.contains('rhino') || title.contains('otology') || title.contains('larynx')) {
      return ClinicalSpecialtyDiscipline.rhinologyEnt;
    }
    if (title.contains('pulmon') || title.contains('lung') || title.contains('respir') || title.contains('chest')) {
      return ClinicalSpecialtyDiscipline.pulmonology;
    }
    if (title.contains('gastro') || title.contains('digest') || title.contains('liver') || title.contains('pancrea') || title.contains('colon') || title.contains('bowel')) {
      return ClinicalSpecialtyDiscipline.gastroenterology;
    }
    if (title.contains('uro') || title.contains('kidney') || title.contains('bladder') || title.contains('prostate')) {
      return ClinicalSpecialtyDiscipline.urology;
    }
    if (title.contains('obgyn') || title.contains('gynec') || title.contains('uterus') || title.contains('pelvic') || title.contains('obstetric')) {
      return ClinicalSpecialtyDiscipline.obgyn;
    }
    if (title.contains('ophthalm') || title.contains('eye') || title.contains('retina') || title.contains('vision')) {
      return ClinicalSpecialtyDiscipline.ophthalmology;
    }
    if (title.contains('derma') || title.contains('skin') || title.contains('aesthetic') || title.contains('plastic')) {
      return ClinicalSpecialtyDiscipline.dermatology;
    }
    if (title.contains('ortho') || title.contains('bone') || title.contains('skelet')) {
      return ClinicalSpecialtyDiscipline.orthopedics;
    }
    return ClinicalSpecialtyDiscipline.general;
  }

  /// Global repository of dedicated standalone 3D models for isolated solo viewing across all specialties
  static const Map<String, String> _dedicatedSpecialtySoloGlbs = {
    // 1. Dental / Dentistry (Individual standalone teeth GLBs)
    'arch': 'assets/models/teeth/lower_dental_arch.glb',
    'dentition': 'assets/models/teeth/upper_lower_permanent_teeth.glb',
    'canine': 'assets/models/teeth/canine.glb',
    'incisor': 'assets/models/teeth/incisor.glb',
    'premolar': 'assets/models/teeth/premolar.glb',
    'molar_second': 'assets/models/teeth/molar_second.glb',
    'molar_third': 'assets/models/teeth/molar_third.glb',
    'molar': 'assets/models/teeth/molar.glb',
    'tooth_11': 'assets/models/teeth/incisor.glb',
    'tooth_12': 'assets/models/teeth/incisor.glb',
    'tooth_13': 'assets/models/teeth/canine.glb',
    'tooth_14': 'assets/models/teeth/premolar.glb',
    'tooth_15': 'assets/models/teeth/premolar.glb',
    'tooth_16': 'assets/models/teeth/molar.glb',
    'tooth_17': 'assets/models/teeth/molar_second.glb',
    'tooth_18': 'assets/models/teeth/molar_third.glb',
    'tooth_21': 'assets/models/teeth/incisor.glb',
    'tooth_22': 'assets/models/teeth/incisor.glb',
    'tooth_23': 'assets/models/teeth/canine.glb',
    'tooth_24': 'assets/models/teeth/premolar.glb',
    'tooth_25': 'assets/models/teeth/premolar.glb',
    'tooth_26': 'assets/models/teeth/molar.glb',
    'tooth_27': 'assets/models/teeth/molar_second.glb',
    'tooth_28': 'assets/models/teeth/molar_third.glb',
    'tooth_31': 'assets/models/teeth/incisor.glb',
    'tooth_32': 'assets/models/teeth/incisor.glb',
    'tooth_33': 'assets/models/teeth/canine.glb',
    'tooth_34': 'assets/models/teeth/premolar.glb',
    'tooth_35': 'assets/models/teeth/premolar.glb',
    'tooth_36': 'assets/models/teeth/molar.glb',
    'tooth_37': 'assets/models/teeth/molar_second.glb',
    'tooth_38': 'assets/models/teeth/molar_third.glb',
    'tooth_41': 'assets/models/teeth/incisor.glb',
    'tooth_42': 'assets/models/teeth/incisor.glb',
    'tooth_43': 'assets/models/teeth/canine.glb',
    'tooth_44': 'assets/models/teeth/premolar.glb',
    'tooth_45': 'assets/models/teeth/premolar.glb',
    'tooth_46': 'assets/models/teeth/molar.glb',
    'tooth_47': 'assets/models/teeth/molar_second.glb',
    'tooth_48': 'assets/models/teeth/molar_third.glb',

    // 2. Cardiology & Vascular
    'coronary': 'assets/models/cardiology/coronary_arteries.glb',
    'lad': 'assets/models/cardiology/coronary_arteries.glb',
    'rca': 'assets/models/cardiology/coronary_arteries.glb',
    'lcx': 'assets/models/cardiology/coronary_arteries.glb',
    'aorta': 'assets/models/cardiology/aortic_arch.glb',
    'aortic_arch': 'assets/models/cardiology/aortic_arch.glb',
    'valve': 'assets/models/cardiology/aortic_valve.glb',
    'aortic_valve': 'assets/models/cardiology/aortic_valve.glb',
    'artery': 'assets/models/cardiology/artery_vein_system.glb',
    'vein': 'assets/models/cardiology/artery_vein_system.glb',
    'vascular': 'assets/models/cardiology/artery_vein_system.glb',
    'varicose': 'assets/models/cardiology/varicose_veins.glb',
    'saphenous': 'assets/models/cardiology/varicose_veins.glb',

    // 3. Neurology
    'circle_of_willis': 'assets/models/neurology/circle_of_willis.glb',
    'willis': 'assets/models/neurology/circle_of_willis.glb',
    'cranial_nerve': 'assets/models/neurology/cranial_nerves.glb',
    'cranial': 'assets/models/neurology/cranial_nerves.glb',
    'foramina': 'assets/models/neurology/cranial_nerves_foramina.glb',
    'skull_base': 'assets/models/neurology/cranial_nerves_foramina.glb',
    'neuro_nerves': 'assets/models/neurology/nerves_skeletal_cross_section.glb',
    'nerves_skeletal': 'assets/models/neurology/nerves_skeletal_cross_section.glb',
    'nervous_system': 'assets/models/neurology/nervous_system.glb',
    'neuro_brain': 'assets/models/neurology/brain.glb',
    'brain': 'assets/models/neurology/brain.glb',

    // 4. ENT / Otolaryngology
    'cochlea': 'assets/models/ent/inner_ear.glb',
    'inner_ear_apparatus': 'assets/models/ent/inner_ear_apparatus.glb',
    'labyrinth': 'assets/models/ent/inner_ear_apparatus.glb',
    'semicircular': 'assets/models/ent/inner_ear_apparatus.glb',
    'inner_ear': 'assets/models/ent/inner_ear.glb',
    'ossicle': 'assets/models/ent/middle_ear_ossicles.glb',
    'malleus': 'assets/models/ent/middle_ear_ossicles.glb',
    'incus': 'assets/models/ent/middle_ear_ossicles.glb',
    'stapes': 'assets/models/ent/middle_ear_ossicles.glb',
    'middle_ear': 'assets/models/ent/middle_ear_ossicles.glb',
    'ear': 'assets/models/ent/ear_structures.glb',
    'sinus': 'assets/models/ent/paranasal_sinuses.glb',
    'paranasal': 'assets/models/ent/paranasal_sinuses.glb',
    'larynx': 'assets/models/ent/larynx_muscles_ligaments.glb',
    'vocal': 'assets/models/ent/larynx_muscles_ligaments.glb',
    'epiglottis': 'assets/models/ent/larynx_anatomy.glb',

    // 5. Respiratory / Pulmonology
    'trachea': 'assets/models/respiratory/tracheobronchial_tree.glb',
    'bronchi': 'assets/models/respiratory/tracheobronchial_tree.glb',
    'bronchiole': 'assets/models/respiratory/bronchioles_alveoli.glb',
    'alveoli': 'assets/models/respiratory/bronchioles_alveoli.glb',
    'alveolar': 'assets/models/respiratory/alveolar_sacs.glb',
    'lungs': 'assets/models/respiratory/lungs.glb',

    // 6. Gastroenterology & Hepatobiliary
    'liver': 'assets/models/gastroenterology/liver_gallbladder.glb',
    'hepatic': 'assets/models/gastroenterology/liver_gallbladder.glb',
    'gallbladder': 'assets/models/gastroenterology/gallbladder.glb',
    'biliary': 'assets/models/gastroenterology/gallbladder.glb',
    'spleen': 'assets/models/gastroenterology/pancreas_duodenum_spleen.glb',
    'pancreas': 'assets/models/gastroenterology/pancreas_duodenum.glb',
    'duodenum': 'assets/models/gastroenterology/pancreas_duodenum.glb',
    'colon': 'assets/models/gastroenterology/colon_anatomy.glb',
    'large_intestine': 'assets/models/gastroenterology/large_intestine.glb',
    'bowel': 'assets/models/gastroenterology/bowel_anatomy.glb',
    'jejunum': 'assets/models/gastroenterology/bowel_anatomy.glb',
    'ileum': 'assets/models/gastroenterology/bowel_anatomy.glb',
    'digestive': 'assets/models/gastroenterology/digestive.glb',

    // 7. Urology & Nephrology
    'kidney': 'assets/models/urology/kidney.glb',
    'renal': 'assets/models/urology/kidney.glb',
    'urinary_system': 'assets/models/urology/urinary_system.glb',
    'urinary': 'assets/models/urology/urinary_tract.glb',
    'ureter': 'assets/models/urology/urinary_tract.glb',
    'bladder': 'assets/models/urology/bladder_prostate.glb',
    'prostate': 'assets/models/urology/bladder_prostate_cross_section.glb',

    // 8. Obstetrics & Gynecology (OB/GYN)
    'uterus': 'assets/models/obgyn/uterus_cross_section.glb',
    'endometrium': 'assets/models/obgyn/uterus_endometrium.glb',
    'pelvic_floor': 'assets/models/obgyn/pelvic_floor_muscles_3d.glb',
    'levator': 'assets/models/obgyn/pelvic_floor_muscles_3d.glb',
    'perineal': 'assets/models/obgyn/pelvic_floor_muscles.glb',
    'female_reproductive': 'assets/models/obgyn/female_reproductive.glb',

    // 9. Ophthalmology
    'eye_muscle': 'assets/models/ophthalmology/extraocular_muscles.glb',
    'extraocular': 'assets/models/ophthalmology/extraocular_muscles.glb',
    'retina': 'assets/models/ophthalmology/retinal_layers.glb',
    'macula': 'assets/models/ophthalmology/stargardt_macula.glb',
    'stargardt': 'assets/models/ophthalmology/stargardt_macula.glb',
    'cornea': 'assets/models/ophthalmology/eye_model_unmc.glb',
    'unmc': 'assets/models/ophthalmology/eye_model_unmc.glb',
    'eye': 'assets/models/ophthalmology/eye.glb',

    // 10. Aesthetics & Dermatology
    'skin': 'assets/models/dermatology/skin_anatomy.glb',
    'hair': 'assets/models/dermatology/hair_follicle.glb',
    'follicle': 'assets/models/dermatology/hair_follicle.glb',
    'facial_expression': 'assets/models/aesthetics/facial_expression_muscles.glb',
    'facial_muscle': 'assets/models/aesthetics/facial_expression_muscles.glb',
    'botox': 'assets/models/aesthetics/facial_expression_muscles.glb',
    'head_muscle': 'assets/models/aesthetics/head_muscles.glb',

    // 11. Orthopedics / Musculoskeletal
    'skull': 'assets/models/orthopedics/skull_anatomy.glb',
    'cranium': 'assets/models/orthopedics/skull_anatomy.glb',
    'rib': 'assets/models/orthopedics/rib_cage.glb',
    'sternum': 'assets/models/orthopedics/rib_cage.glb',
    'femur': 'assets/models/orthopedics/femur.glb',
    'thigh': 'assets/models/orthopedics/femur.glb',
    'tibia': 'assets/models/orthopedics/tibia_fibula.glb',
    'fibula': 'assets/models/orthopedics/tibia_fibula.glb',
    'spine': 'assets/models/orthopedics/spine_column.glb',
    'cervical': 'assets/models/orthopedics/spine_column.glb',
    'lumbar': 'assets/models/orthopedics/spine_column.glb',
    'thoracic': 'assets/models/orthopedics/spine_column.glb',
    'knee': 'assets/models/orthopedics/knee_bones.glb',
    'patella': 'assets/models/orthopedics/knee_bones.glb',
    'foot': 'assets/models/orthopedics/foot_bones.glb',
    'ankle': 'assets/models/orthopedics/foot_bones.glb',
    'hand': 'assets/models/orthopedics/hand_bones.glb',
    'wrist': 'assets/models/orthopedics/hand_bones.glb',
    'rotator': 'assets/models/orthopedics/rotator_cuff.glb',
    'scapula': 'assets/models/orthopedics/rotator_cuff.glb',
    'shoulder': 'assets/models/orthopedics/rotator_cuff.glb',
    'humerus': 'assets/models/orthopedics/humerus.glb',
    'elbow': 'assets/models/orthopedics/elbow_joint.glb',
    'radius': 'assets/models/orthopedics/radius_ulna.glb',
    'ulna': 'assets/models/orthopedics/radius_ulna.glb',
    'hip': 'assets/models/orthopedics/hip_bone.glb',
    'pelvis': 'assets/models/orthopedics/hip_bone.glb',
  };

  bool _hasDedicatedSoloGlb(String? partKey) {
    if (partKey == null) return false;
    final lower = partKey.toLowerCase();
    for (final k in _dedicatedSpecialtySoloGlbs.keys) {
      if (lower.contains(k)) return true;
    }
    return false;
  }

  String? _resolveDedicatedSoloGlb(String? partKey) {
    if (partKey == null) return null;
    final lower = partKey.toLowerCase();
    for (final entry in _dedicatedSpecialtySoloGlbs.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return null;
  }

  void _rebuildFaces() {
    _cachedFaces = widget.sceneMeshBuilder(
      _currentAgeStage,
      instrument: SpecialtyInstrument.none,
      isSoloMode: _isSoloMode,
      soloPartKey: _selectedPartKey,
    );
    // Auto-resolve GLB model asset path for GPU WebGL 60 FPS viewer
    _resolvedGlbAsset = widget.glbAssetPath ?? SpecialtyGlbMeshLibrary.findAssetPathForFaces(_cachedFaces);
    // Try to get a pre-built flat buffer from the GLB library for the fast path.
    // We identify the discipline by checking all loaded disciplines and matching
    // against the faces that the scene builder returned.
    _cachedGlbBuffer = _findGlbBuffer();
  }

  GlbMeshBuffer? _findGlbBuffer() {
    // Delegate to the library which has access to ClinicalSpecialtyDiscipline.
    return SpecialtyGlbMeshLibrary.findBufferForFaces(
      _cachedFaces,
      isSoloMode: _isSoloMode,
      soloPartKey: _selectedPartKey,
    );
  }

  @override
  void initState() {
    super.initState();
    _currentAgeStage = widget.initialAgeStage;
    _yawNotifier = ValueNotifier<double>(widget.initialYaw);
    _pitchNotifier = ValueNotifier<double>(widget.initialPitch);
    _zoomNotifier = ValueNotifier<double>(widget.initialZoom);
    _showStatsNotifier = ValueNotifier<bool>(false);
    _rebuildFaces();

    SpecialtyGlbMeshLibrary.addListener(_onGlbMeshUpdated);

    _autoRotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(() {
        if (_autoRotate) {
          var y = _yawNotifier.value + 0.015;
          if (y > math.pi * 2) y -= math.pi * 2;
          _yawNotifier.value = y;
        }
      });
  }

  void _onGlbMeshUpdated() {
    if (mounted) {
      setState(() {
        _rebuildFaces();
      });
    }
  }

  @override
  void dispose() {
    SpecialtyGlbMeshLibrary.removeListener(_onGlbMeshUpdated);
    _singleTapTimer?.cancel();
    _singleTapTimer = null;
    _autoRotController.dispose();
    _yawNotifier.dispose();
    _pitchNotifier.dispose();
    _zoomNotifier.dispose();
    _showStatsNotifier.dispose();
    super.dispose();
  }

  void _resetCamera() {
    _yawNotifier.value = widget.initialYaw;
    _pitchNotifier.value = widget.initialPitch;
    _zoomNotifier.value = widget.initialZoom;
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
      if (_autoRotate) {
        _autoRotController.repeat();
      } else {
        _autoRotController.stop();
      }
    });
  }

  void _enterSoloMode() {
    if (_selectedPartKey != null) {
      setState(() {
        _isSoloMode = true;
        _zoomNotifier.value = 1.6;
        _rebuildFaces();
      });
    }
  }

  void _exitSoloMode() {
    setState(() {
      _isSoloMode = false;
      _zoomNotifier.value = widget.initialZoom;
      _rebuildFaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final faces = _cachedFaces;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSoloMode
              ? Colors.amberAccent
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: _isSoloMode ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP HEADER WITH SPECIALTY BADGE & CONTROLS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D34) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.specialtyIcon, color: widget.primaryColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _isSoloMode
                                  ? '${AppLanguage.tr('SOLO 3D VIEW: ', 'عرض ثلاثي الأبعاد منفرد: ')}${AppLanguage.isArabic ? (_selectedPartNameAr ?? '') : (_selectedPartNameEn ?? '')}'
                                  : (AppLanguage.isArabic ? widget.specialtyTitleAr : widget.specialtyTitle),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isSoloMode ? Colors.amberAccent : (isDark ? Colors.white : const Color(0xFF0F172A)),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isSoloMode) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: (_hasDedicatedSoloGlb(_selectedPartKey) ? const Color(0xFF059669) : Colors.amberAccent).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: (_hasDedicatedSoloGlb(_selectedPartKey) ? const Color(0xFF059669) : Colors.amberAccent).withValues(alpha: 0.5),
                                  width: 0.8,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    _hasDedicatedSoloGlb(_selectedPartKey) ? LucideIcons.sparkles : LucideIcons.scan,
                                    size: 10,
                                    color: _hasDedicatedSoloGlb(_selectedPartKey) ? const Color(0xFF059669) : Colors.amberAccent,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    _hasDedicatedSoloGlb(_selectedPartKey)
                                        ? (AppLanguage.isArabic ? 'نموذج مخصص' : 'DEDICATED 3D')
                                        : (AppLanguage.isArabic ? 'عزل تلقائي' : 'SOLO FOCUS'),
                                    style: TextStyle(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                      color: _hasDedicatedSoloGlb(_selectedPartKey) ? const Color(0xFF059669) : Colors.amberAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _isSoloMode
                            ? AppLanguage.tr('Isolated realistic 3D organ view with instruments', 'معاينة العضو منفرداً بدقة عالية مع الأدوات الطبية')
                            : 'Interactive 3D Anatomical Projection (3D مجسم تفاعلي)',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Solo Mode Toggle button
                if (_isSoloMode)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 14),
                    label: Text(AppLanguage.tr('Full View', 'العرض الكامل')),
                    onPressed: _exitSoloMode,
                  )
                else if (_selectedPartKey != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(LucideIcons.maximize2, size: 13),
                    label: Text(AppLanguage.tr('Solo 3D', 'عرض منفرد 3D')),
                    onPressed: _enterSoloMode,
                  ),

                // Model Switcher (available when specialty or part has multiple models)
                Builder(
                  builder: (context) {
                    final currentDiscipline = _deduceDiscipline();
                    final models = _isSoloMode && _selectedPartKey != null
                        ? AnatomicalModelRegistry.getModelsForSpecialtyPart(currentDiscipline, _selectedPartKey)
                        : AnatomicalModelRegistry.getModelsForDiscipline(currentDiscipline);

                    if (models.length <= 1) return const SizedBox.shrink();

                    final dedicatedSoloModel = (_isSoloMode && _selectedPartKey != null)
                        ? _resolveDedicatedSoloGlb(_selectedPartKey)
                        : null;
                    final activeAsset = _customSelectedModelAsset ?? dedicatedSoloModel ?? _resolvedGlbAsset;
                    final selectedOption = models.firstWhere(
                      (m) => m.assetPath == activeAsset,
                      orElse: () => models.first,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: PopupMenuButton<AnatomicalModelOption>(
                        key: const ValueKey('btn_model_switcher_popup'),
                        tooltip: AppLanguage.isArabic ? 'اختيار النموذج ثلاثي الأبعاد' : 'Select 3D Model Variant',
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        color: isDark ? const Color(0xFF1E293B) : Colors.white,
                        onSelected: (option) {
                          setState(() {
                            _customSelectedModelAsset = option.assetPath;
                          });
                        },
                        itemBuilder: (context) {
                          return models.map((opt) {
                            final isSelected = (opt.assetPath == activeAsset);
                            return PopupMenuItem<AnatomicalModelOption>(
                              value: opt,
                              child: Row(
                                children: [
                                  Icon(
                                    opt.icon,
                                    size: 16,
                                    color: isSelected ? const Color(0xFF10B981) : (isDark ? Colors.white70 : Colors.black87),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          opt.localizedLabel,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                            color: isSelected ? const Color(0xFF10B981) : (isDark ? Colors.white : Colors.black87),
                                          ),
                                        ),
                                        if (opt.localizedSubtitle != null)
                                          Text(
                                            opt.localizedSubtitle!,
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              color: isDark ? Colors.white38 : Colors.black45,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    const Icon(Icons.check_circle, size: 14, color: Color(0xFF10B981)),
                                ],
                              ),
                            );
                          }).toList();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: widget.primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: widget.primaryColor.withValues(alpha: 0.4),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(LucideIcons.layers, size: 13, color: widget.primaryColor),
                              const SizedBox(width: 5),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 130),
                                child: Text(
                                  selectedOption.localizedLabel,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: widget.primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 2),
                              Icon(Icons.arrow_drop_down, size: 16, color: widget.primaryColor),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                if (_resolvedGlbAsset != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () => setState(() => _useGpuViewer = !_useGpuViewer),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _useGpuViewer
                              ? const Color(0xFF10B981).withValues(alpha: 0.18)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _useGpuViewer
                                ? const Color(0xFF10B981)
                                : (isDark ? Colors.white24 : Colors.black26),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _useGpuViewer ? LucideIcons.sparkles : LucideIcons.grid,
                              size: 13,
                              color: _useGpuViewer
                                  ? const Color(0xFF10B981)
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _useGpuViewer ? 'GPU 60 FPS' : 'CAD Mesh',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _useGpuViewer
                                    ? const Color(0xFF10B981)
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    _autoRotate ? Icons.pause_circle_filled : Icons.play_circle_outline,
                    size: 20,
                    color: _autoRotate ? widget.primaryColor : (isDark ? Colors.white70 : Colors.black54),
                  ),
                  tooltip: 'Auto Rotate (دوران تلقائي)',
                  onPressed: _toggleAutoRotate,
                ),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                  tooltip: 'Reset View (إعادة ضبط)',
                  onPressed: _resetCamera,
                ),
                ValueListenableBuilder<bool>(
                  valueListenable: _showStatsNotifier,
                  builder: (context, showStats, _) {
                    return IconButton(
                      icon: Icon(
                        LucideIcons.activity,
                        size: 18,
                        color: showStats ? const Color(0xFF10B981) : (isDark ? Colors.white70 : Colors.black54),
                      ),
                      tooltip: 'Toggle 3D FPS & GPU Performance HUD',
                      onPressed: () => _showStatsNotifier.value = !_showStatsNotifier.value,
                    );
                  },
                ),
              ],
            ),
          ),

          // 2. UNIVERSAL AGE PROGRESSION SELECTOR BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.clock, size: 14, color: widget.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        AppLanguage.tr('Age Stage:', 'المرحلة العمرية:'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  ...ClinicalAgeStage.values.map((stage) {
                    final isSel = stage == _currentAgeStage;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _currentAgeStage = stage;
                            _rebuildFaces();
                          });
                          widget.onAgeStageChanged?.call(stage);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel
                                ? widget.primaryColor
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? widget.primaryColor
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                stage.localizedTitle,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${stage.ageRange})',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSel
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : (isDark ? Colors.white38 : Colors.black38),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 3. MAIN 3D INTERACTIVE CANVAS VIEWPORT (GPU WebGL 60 FPS or CPU CAD)
          SizedBox(
            height: widget.height,
            child: (_useGpuViewer && _resolvedGlbAsset != null)
                ? () {
                    final dedicatedSoloModel = (_isSoloMode && _selectedPartKey != null)
                        ? _resolveDedicatedSoloGlb(_selectedPartKey)
                        : null;
                    final activeGlbAsset = _customSelectedModelAsset ?? dedicatedSoloModel ?? _resolvedGlbAsset!;
                    final hasDedicated = (dedicatedSoloModel != null || _customSelectedModelAsset != null);

                    return GpuGlbViewer(
                      key: ValueKey('gpu_viewer_${activeGlbAsset}_${_isSoloMode}_${hasDedicated ? "" : _selectedPartKey}'),
                      glbAsset: activeGlbAsset,
                      primaryColor: widget.primaryColor,
                      title: widget.specialtyTitle,
                      isDark: isDark,
                      height: widget.height,
                      isSolo: _isSoloMode,
                      soloBoneId: hasDedicated ? null : _selectedPartKey,
                      pins: widget.activeStatuses?.entries.map((e) {
                        final entry = e.value;
                        final c = entry.visualColor;
                        final hex = '#${(c.r * 255).round().toRadixString(16).padLeft(2, '0')}${(c.g * 255).round().toRadixString(16).padLeft(2, '0')}${(c.b * 255).round().toRadixString(16).padLeft(2, '0')}';
                        return {
                          'id': e.key,
                          'type': 'clinicalPin',
                          'color': hex,
                          'label': AppLanguage.isArabic ? entry.status.titleAr : entry.status.title,
                          'x': 0.0,
                          'y': 0.0,
                          'z': 0.0,
                        };
                      }).toList(),
                      onPinTapped: (pinId) {
                        final entry = widget.activeStatuses?[pinId];
                        if (entry != null) {
                          final nameEn = entry.status.title;
                          final nameAr = entry.status.titleAr;
                          setState(() {
                            _selectedPartKey = pinId;
                            _selectedPartNameEn = nameEn;
                            _selectedPartNameAr = nameAr;
                          });
                          widget.onPartSelected?.call(pinId, nameEn, nameAr);
                        }
                      },
                      onPartTapped: (partName) {
                        final lower = partName.toLowerCase();
                        MeshFace3D? match;
                        for (final f in faces) {
                          if (f.partNameEn?.toLowerCase().contains(lower) == true ||
                              f.partNameAr?.toLowerCase().contains(lower) == true ||
                              f.partKey?.toLowerCase().contains(lower) == true) {
                            match = f;
                            break;
                          }
                        }
                        final key = match?.partKey ?? 'gpu_$partName';
                        final nameEn = match?.partNameEn ?? partName;
                        final nameAr = match?.partNameAr ?? partName;
                        setState(() {
                          _selectedPartKey = key;
                          _selectedPartNameEn = nameEn;
                          _selectedPartNameAr = nameAr;
                        });
                        widget.onPartSelected?.call(key, nameEn, nameAr);
                      },
                      onPartDoubleTapped: (partName) {
                        if (_isSoloMode) {
                          _exitSoloMode();
                          return;
                        }
                        if (partName.isNotEmpty) {
                          final lower = partName.toLowerCase();
                          MeshFace3D? match;
                          for (final f in faces) {
                            if (f.partNameEn?.toLowerCase().contains(lower) == true ||
                                f.partNameAr?.toLowerCase().contains(lower) == true ||
                                f.partKey?.toLowerCase().contains(lower) == true) {
                              match = f;
                              break;
                            }
                          }
                          final key = match?.partKey ?? 'gpu_$partName';
                          final nameEn = match?.partNameEn ?? partName;
                          final nameAr = match?.partNameAr ?? partName;
                          setState(() {
                            _selectedPartKey = key;
                            _selectedPartNameEn = nameEn;
                            _selectedPartNameAr = nameAr;
                            _isSoloMode = true;
                          });
                          widget.onPartSelected?.call(key, nameEn, nameAr);
                        }
                      },
                      onFallbackRequested: () {
                        setState(() {
                          _useGpuViewer = false;
                        });
                      },
                    );
                  }()
                : LayoutBuilder(
              builder: (context, constraints) {
                final actualW = (constraints.maxWidth.isFinite && constraints.maxWidth > 0)
                    ? constraints.maxWidth
                    : 600.0;
                final viewportSize = Size(actualW, widget.height);

                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onPanStart: (details) {
                          _singleTapTimer?.cancel();
                          _singleTapTimer = null;
                          _pendingTapPos = null;
                          _lastPanPos = details.localPosition;
                        },
                        onPanUpdate: (details) {
                          if (_lastPanPos != null) {
                            final dx = details.localPosition.dx - _lastPanPos!.dx;
                            final dy = details.localPosition.dy - _lastPanPos!.dy;
                            _yawNotifier.value += dx * 0.012;
                            _pitchNotifier.value = (_pitchNotifier.value + dy * 0.012).clamp(-1.4, 1.4);
                            _lastPanPos = details.localPosition;
                          }
                        },
                        onPanEnd: (_) => _lastPanPos = null,
                        onTapUp: (details) {
                          if (_singleTapTimer != null && _singleTapTimer!.isActive) {
                            _singleTapTimer!.cancel();
                            _singleTapTimer = null;
                            _pendingTapPos = null;
                            _handleCanvasDoubleTap(details.localPosition, faces, viewportSize);
                          } else {
                            _pendingTapPos = details.localPosition;
                            _singleTapTimer = Timer(const Duration(milliseconds: 500), () {
                              if (mounted && _pendingTapPos != null) {
                                final pos = _pendingTapPos!;
                                _pendingTapPos = null;
                                _singleTapTimer = null;
                                _handleCanvasTap(pos, faces, viewportSize);
                              }
                            });
                          }
                        },
                        onSecondaryTapUp: (details) {
                          _singleTapTimer?.cancel();
                          _singleTapTimer = null;
                          _pendingTapPos = null;
                          _handleCanvasSecondaryTap(details.localPosition, details.globalPosition, faces, viewportSize);
                        },
                        onLongPressStart: (details) {
                          _singleTapTimer?.cancel();
                          _singleTapTimer = null;
                          _pendingTapPos = null;
                          _handleCanvasSecondaryTap(details.localPosition, details.globalPosition, faces, viewportSize);
                        },
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_yawNotifier, _pitchNotifier, _zoomNotifier]),
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _Generic3DScenePainter(
                                faces: faces,
                                glbBuffer: _cachedGlbBuffer,
                                yaw: _yawNotifier.value,
                                pitch: _pitchNotifier.value,
                                zoom: _zoomNotifier.value,
                                isDark: isDark,
                                primaryColor: widget.primaryColor,
                                activeStatuses: widget.activeStatuses,
                                hoveredPartKey: _hoveredPartKey,
                                selectedPartKey: _selectedPartKey,
                              ),
                              size: Size.infinite,
                            );
                          },
                        ),
                      ),
                    ),

                // Floating zoom buttons
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFloatingCircleBtn(
                        icon: Icons.add,
                        tooltip: 'Zoom In',
                        onTap: () => _zoomNotifier.value = (_zoomNotifier.value * 1.15).clamp(0.4, 4.0),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      _buildFloatingCircleBtn(
                        icon: Icons.remove,
                        tooltip: 'Zoom Out',
                        onTap: () => _zoomNotifier.value = (_zoomNotifier.value / 1.15).clamp(0.4, 4.0),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // Real-time 3D Performance & FPS Stats HUD
                ValueListenableBuilder<bool>(
                  valueListenable: _showStatsNotifier,
                  builder: (context, showStats, _) {
                    if (!showStats) return const SizedBox.shrink();
                    final tracker = Clinical3dPerformanceTracker.instance;
                    return Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.88),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF10B981), width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              '${tracker.fps.toStringAsFixed(0)} FPS | ${tracker.lastDrawCalls} Call | ${tracker.lastTriangles} Tris | ${tracker.lastFrameTimeMs}ms',
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF34D399),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Hint overlay pill
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.hand, size: 12, color: widget.primaryColor),
                        const SizedBox(width: 5),
                        Text(
                          _isSoloMode
                              ? AppLanguage.tr('Solo Mode active • Double-click to exit • Drag to rotate', 'الوضع المنفرد نشط • انقر مرتين للخروج • اسحب للتدوير')
                              : AppLanguage.tr('Tap to select • Double-click for Solo 3D • Drag to rotate', 'انقر للتحديد • انقر مرتين للعرض المنفرد 3D • اسحب للتدوير'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

          if (widget.overlayBottomWidget != null) widget.overlayBottomWidget!,
        ],
      ),
    );
  }

  MeshFace3D? _findClosestFace(Offset tapPos, List<MeshFace3D> faces, Size size, {double maxDist = 75.0}) {
    final scale = 1.0 * _zoomNotifier.value;

    MeshFace3D? closestFace;
    double minSqDist = maxDist * maxDist;

    for (final face in faces) {
      if (face.partKey == null) continue;
      final rotC = face.centroid.rotateEuler(_yawNotifier.value, _pitchNotifier.value);
      final screenPos = rotC.toScreen(size, scale);
      final distSq = (screenPos.dx - tapPos.dx) * (screenPos.dx - tapPos.dx) +
          (screenPos.dy - tapPos.dy) * (screenPos.dy - tapPos.dy);
      if (distSq < minSqDist) {
        minSqDist = distSq;
        closestFace = face;
      }
    }
    return closestFace;
  }

  void _handleCanvasTap(Offset tapPos, List<MeshFace3D> faces, Size size) {
    final closestFace = _findClosestFace(tapPos, faces, size, maxDist: 75.0);

    if (closestFace != null) {
      setState(() {
        _hoveredPartKey = closestFace.partKey;
        _selectedPartKey = closestFace.partKey;
        _selectedPartNameEn = closestFace.partNameEn ?? closestFace.partKey!;
        _selectedPartNameAr = closestFace.partNameAr ?? closestFace.partNameEn ?? closestFace.partKey!;
      });
      widget.onPartSelected?.call(
        closestFace.partKey!,
        closestFace.partNameEn ?? closestFace.partKey!,
        closestFace.partNameAr ?? closestFace.partNameEn ?? closestFace.partKey!,
      );
    }
  }

  void _handleCanvasDoubleTap(Offset tapPos, List<MeshFace3D> faces, Size size) {
    final closestFace = _findClosestFace(tapPos, faces, size, maxDist: 100.0);

    if (closestFace != null && closestFace.partKey != null) {
      final key = closestFace.partKey!;
      final en = closestFace.partNameEn ?? key;
      final ar = closestFace.partNameAr ?? en;
      setState(() {
        _hoveredPartKey = key;
        _selectedPartKey = key;
        _selectedPartNameEn = en;
        _selectedPartNameAr = ar;
        // Toggle solo mode
        if (_isSoloMode && _selectedPartKey == key) {
          _isSoloMode = false;
          _zoomNotifier.value = widget.initialZoom;
        } else {
          _isSoloMode = true;
          _zoomNotifier.value = 1.6;
        }
        _rebuildFaces();
      });
    } else if (_isSoloMode) {
      // Double clicking outside or background exits solo mode
      _exitSoloMode();
    }
  }

  void _handleCanvasSecondaryTap(Offset tapPos, Offset globalPos, List<MeshFace3D> faces, Size size) {
    final scale = 1.0 * _zoomNotifier.value;

    MeshFace3D? closestFace;
    double minSqDist = 120.0 * 120.0;

    for (final face in faces) {
      if (face.partKey == null) continue;
      final rotC = face.centroid.rotateEuler(_yawNotifier.value, _pitchNotifier.value);
      final screenPos = rotC.toScreen(size, scale);
      final distSq = (screenPos.dx - tapPos.dx) * (screenPos.dx - tapPos.dx) +
          (screenPos.dy - tapPos.dy) * (screenPos.dy - tapPos.dy);
      if (distSq < minSqDist) {
        minSqDist = distSq;
        closestFace = face;
      }
    }

    if (closestFace != null) {
      final key = closestFace.partKey!;
      final en = closestFace.partNameEn ?? key;
      final ar = closestFace.partNameAr ?? en;
      setState(() {
        _hoveredPartKey = key;
        _selectedPartKey = key;
        _selectedPartNameEn = en;
        _selectedPartNameAr = ar;
      });
      widget.onPartSecondaryTap?.call(key, en, ar, globalPos);
    }
  }

  Widget _buildFloatingCircleBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
      ),
    );
  }
}

/// Custom painter that projects 3D faces with realistic multi-light studio shading,
/// Blinn-Phong organic specular highlights, Fresnel curvature depth, and smooth face rendering.
class _Generic3DScenePainter extends CustomPainter {
  static final Paint _sharedSolidPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _sharedStrokePaint = Paint()..style = PaintingStyle.stroke;

  final List<MeshFace3D> faces;
  final GlbMeshBuffer? glbBuffer;
  final double yaw;
  final double pitch;
  final double zoom;
  final bool isDark;
  final Color primaryColor;
  final Map<String, ClinicalAnatomyStatusEntry>? activeStatuses;
  final String? hoveredPartKey;
  final String? selectedPartKey;

  _Generic3DScenePainter({
    required this.faces,
    this.glbBuffer,
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.isDark,
    required this.primaryColor,
    this.activeStatuses,
    this.selectedPartKey,
    this.hoveredPartKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stopwatch = Stopwatch()..start();
    int drawCalls = 0;

    // ── FAST PATH: use pre-built GlbMeshBuffer (zero per-frame allocations) ──
    final buf = glbBuffer;
    if (buf != null && buf.triCount > 0) {
      drawCalls = _paintFlatBuffer(canvas, size, buf);
    } else if (faces.isNotEmpty) {
      // ── SLOW FALLBACK: legacy MeshFace3D (procedural / non-GLB meshes) ──
      drawCalls = _paintLegacyFaces(canvas, size);
    } else {
      return;
    }

    stopwatch.stop();
    Clinical3dPerformanceTracker.instance.recordFrame(
      buf != null ? buf.triCount : faces.length,
      drawCalls,
      stopwatch.elapsedMilliseconds,
    );
  }

  // ── FAST FLAT-BUFFER PAINTER ──────────────────────────────────────────────
  // Reads directly from Float32List/Int32List — no object allocations inside
  // the hot loop. One drawVertices call for all solid triangles.
  int _paintFlatBuffer(Canvas canvas, Size size, GlbMeshBuffer buf) {
    final cosYaw   = math.cos(yaw);
    final sinYaw   = math.sin(yaw);
    final cosPitch = math.cos(pitch);
    final sinPitch = math.sin(pitch);

    final cx  = size.width  * 0.5;
    final cy  = size.height * 0.5;
    const fov = 400.0;
    final sc  = zoom;

    // Light constants pre-normalized (computed manually to avoid const expressions with sqrt)
    // keyLight = (-0.55, -0.65, 0.52), |keyLight| ≈ 0.9605
    const klnx = -0.5726, klny = -0.6766, klnz = 0.5413;
    // fillLight = (0.45, 0.35, 0.65), |fillLight| ≈ 0.8718
    const flnx =  0.5162, flny =  0.4015, flnz = 0.7457;
    // halfVec = normalize(-keyLight + (0,0,1)) = normalize(0.5726, 0.6766, 0.4587)
    // magnitude ≈ 0.9710
    const hnx = 0.5897, hny = 0.6968, hnz = 0.4724;

    final n       = buf.triCount;
    final verts   = buf.verts;
    final colors  = buf.colors;
    final norms   = buf.norms;
    final partIds = buf.partIds;
    final partKeys = buf.partKeys;

    // Highlight part indices
    final hovIdx = hoveredPartKey  != null ? partKeys.indexOf(hoveredPartKey)  : -1;
    final selIdx = selectedPartKey != null ? partKeys.indexOf(selectedPartKey) : -1;

    // Pre-allocate output arrays (exact size — no realloc)
    final sxArr = Float64List(n * 3); // screen x per vertex
    final syArr = Float64List(n * 3); // screen y per vertex
    final cArr  = List<Color>.filled(n * 3, const Color(0xFFFFFFFF));

    // Stroke accumulator (only for highlighted parts — tiny list)
    final strokeTris = <int>[];

    for (var i = 0; i < n; i++) {
      final vb = i * 9; // base into verts array
      final nb = i * 3; // base into norms array

      // ── Rotate 3 vertices: rotateX(pitch) then rotateY(yaw) ──
      // Inlined to avoid any heap allocation.
      double v0x = verts[vb],   v0y = verts[vb+1], v0z = verts[vb+2];
      double v1x = verts[vb+3], v1y = verts[vb+4], v1z = verts[vb+5];
      double v2x = verts[vb+6], v2y = verts[vb+7], v2z = verts[vb+8];

      // rotateX(pitch): y' = y*cos - z*sin,  z' = y*sin + z*cos
      double t;
      t = v0y*cosPitch - v0z*sinPitch; v0z = v0y*sinPitch + v0z*cosPitch; v0y = t;
      t = v1y*cosPitch - v1z*sinPitch; v1z = v1y*sinPitch + v1z*cosPitch; v1y = t;
      t = v2y*cosPitch - v2z*sinPitch; v2z = v2y*sinPitch + v2z*cosPitch; v2y = t;
      // rotateY(yaw): x' = x*cos + z*sin,  z' = -x*sin + z*cos
      t = v0x*cosYaw + v0z*sinYaw; v0z = -v0x*sinYaw + v0z*cosYaw; v0x = t;
      t = v1x*cosYaw + v1z*sinYaw; v1z = -v1x*sinYaw + v1z*cosYaw; v1x = t;
      t = v2x*cosYaw + v2z*sinYaw; v2z = -v2x*sinYaw + v2z*cosYaw; v2x = t;

      // Perspective project
      final d0 = fov / (fov + v0z + 200.0);
      final d1 = fov / (fov + v1z + 200.0);
      final d2 = fov / (fov + v2z + 200.0);
      final vb3 = i * 3;
      sxArr[vb3]   = cx + v0x * sc * d0;
      syArr[vb3]   = cy + v0y * sc * d0;
      sxArr[vb3+1] = cx + v1x * sc * d1;
      syArr[vb3+1] = cy + v1y * sc * d1;
      sxArr[vb3+2] = cx + v2x * sc * d2;
      syArr[vb3+2] = cy + v2y * sc * d2;

      // ── Rotate normal ──
      double nx = norms[nb], ny = norms[nb+1], nz = norms[nb+2];
      t = ny*cosPitch - nz*sinPitch; nz = ny*sinPitch + nz*cosPitch; ny = t;
      t = nx*cosYaw   + nz*sinYaw;   nz = -nx*sinYaw  + nz*cosYaw;   nx = t;
      // Double-sided
      if (nz < 0) { nx = -nx; ny = -ny; nz = -nz; }

      // ── Lighting ──
      final keyDot  = math.max(0.0, -(nx*klnx + ny*klny + nz*klnz));
      final fillDot = math.max(0.0, -(nx*flnx + ny*flny + nz*flnz));
      final diffuse = (0.38 + keyDot * 0.52 + fillDot * 0.20).clamp(0.0, 1.0);
      final specDot  = math.max(0.0, nx*hnx + ny*hny + nz*hnz);
      final specular = math.pow(specDot, 18.0) * 0.35;
      final absNz = nz < 0 ? -nz : nz;
      final rim  = math.pow(1.0 - absNz.clamp(0.0, 1.0), 2.6) * 0.22;

      // ── Unpack base color ──
      final packed = colors[i];
      final ba = (packed >> 24) & 0xFF;
      final br = (packed >> 16) & 0xFF;
      final bg = (packed >>  8) & 0xFF;
      final bb =  packed        & 0xFF;

      final r = (br * diffuse + 255 * specular + br * rim).toInt().clamp(0, 255);
      final g = (bg * diffuse + 255 * specular + bg * rim).toInt().clamp(0, 255);
      final b = (bb * diffuse + 255 * specular + bb * rim).toInt().clamp(0, 255);
      final c = Color.fromARGB(ba, r, g, b);
      cArr[vb3] = c; cArr[vb3+1] = c; cArr[vb3+2] = c;

      // Track highlighted triangles for outline pass
      final pid = partIds[i];
      if (pid == hovIdx || pid == selIdx) strokeTris.add(i);
    }

    // sxArr and syArr are Float64List — interleave into a Float32List for Vertices.raw()
    final rawPos = Float32List(n * 6); // [x0,y0, x1,y1, x2,y2, ...] per triangle
    final rawCol = Int32List(n * 3);   // ARGB per vertex
    for (var k = 0; k < n * 3; k++) {
      rawPos[k * 2]     = sxArr[k].toDouble();
      rawPos[k * 2 + 1] = syArr[k].toDouble();
      rawCol[k] = cArr[k].toARGB32();
    }

    final vertices = ui.Vertices.raw(
      ui.VertexMode.triangles,
      rawPos,
      colors: rawCol,
    );
    canvas.drawVertices(vertices, BlendMode.dst, _sharedSolidPaint);
    int drawCalls = 1;

    // Outline pass for hovered/selected (very few tris)
    for (final i in strokeTris) {
      final vb3 = i * 3;
      final path = Path()
        ..moveTo(sxArr[vb3],   syArr[vb3])
        ..lineTo(sxArr[vb3+1], syArr[vb3+1])
        ..lineTo(sxArr[vb3+2], syArr[vb3+2])
        ..close();
      final pid = partIds[i];
      _sharedStrokePaint
        ..color = pid == hovIdx
            ? const Color(0xFFFBBF24)
            : primaryColor.withValues(alpha: 0.95)
        ..strokeWidth = 2.2;
      canvas.drawPath(path, _sharedStrokePaint);
      drawCalls++;
    }
    return drawCalls;
  }

  // ── LEGACY FACE PAINTER (procedural meshes fallback) ──────────────────────
  int _paintLegacyFaces(Canvas canvas, Size size) {
    final keyLight = const Point3D(-0.55, -0.65, 0.52).normalized();
    final fillLight = const Point3D(0.45, 0.35, 0.65).normalized();
    final halfDir = (keyLight * -1.0 + const Point3D(0, 0, 1)).normalized();

    final transformedFaces = <_RenderFace>[];
    for (final face in faces) {
      final rotVertices = face.vertices.map((v) => v.rotateEuler(yaw, pitch)).toList();
      double sumZ = 0;
      for (final v in rotVertices) { sumZ += v.z; }
      final avgZ = sumZ / rotVertices.length;
      Point3D norm = const Point3D(0, 0, 1);
      if (rotVertices.length >= 3) {
        norm = (rotVertices[1] - rotVertices[0]).cross(rotVertices[2] - rotVertices[0]).normalized();
      }
      transformedFaces.add(_RenderFace(original: face, rotatedVertices: rotVertices, normal: norm, avgZ: avgZ));
    }
    transformedFaces.sort((a, b) => a.avgZ.compareTo(b.avgZ));
    final scale = zoom;
    final solidPositions = <Offset>[];
    final solidColors    = <Color>[];
    int drawCalls = 0;

    for (final rf in transformedFaces) {
      final face    = rf.original;
      final rotVerts = rf.rotatedVertices;
      if (rotVerts.isEmpty) continue;
      final screenPts = rotVerts.map((v) => v.toScreen(size, scale)).toList();

      Color faceColor = face.baseColor;
      if (face.partKey != null && activeStatuses != null) {
        final status = activeStatuses![face.partKey];
        if (status != null) faceColor = status.visualColor;
      }
      Point3D effNorm = rf.normal;
      if (effNorm.z < 0) effNorm = effNorm * -1.0;
      final keyDot  = math.max(0.0, -effNorm.dot(keyLight));
      final fillDot = math.max(0.0, -effNorm.dot(fillLight));
      final diffuse = (0.38 + keyDot * 0.52 + fillDot * 0.20).clamp(0.0, 1.0);
      final specDot  = math.max(0.0, effNorm.dot(halfDir));
      final specular = math.pow(specDot, 18.0) * 0.35;
      final rim      = math.pow(1.0 - effNorm.z.abs().clamp(0.0, 1.0), 2.6) * 0.22;
      final baseR = faceColor.r * 255;
      final baseG = faceColor.g * 255;
      final baseB = faceColor.b * 255;
      final r = (baseR * diffuse + 255 * specular + baseR * rim).toInt().clamp(0, 255);
      final g = (baseG * diffuse + 255 * specular + baseG * rim).toInt().clamp(0, 255);
      final b = (baseB * diffuse + 255 * specular + baseB * rim).toInt().clamp(0, 255);
      final alpha = faceColor.a > 0.05 ? (faceColor.a * 255).toInt() : 255;
      final shadedColor = Color.fromARGB(alpha, r, g, b);

      if (!face.isWireframe && screenPts.length >= 3) {
        for (int i = 1; i < screenPts.length - 1; i++) {
          solidPositions.add(screenPts[0]);
          solidPositions.add(screenPts[i]);
          solidPositions.add(screenPts[i + 1]);
          solidColors.add(shadedColor);
          solidColors.add(shadedColor);
          solidColors.add(shadedColor);
        }
      }
      final isHovered  = face.partKey != null && face.partKey == hoveredPartKey;
      final isSelected = face.partKey != null && face.partKey == selectedPartKey;
      if (face.isWireframe || isHovered || isSelected) {
        final path = Path()..moveTo(screenPts[0].dx, screenPts[0].dy);
        for (int i = 1; i < screenPts.length; i++) { path.lineTo(screenPts[i].dx, screenPts[i].dy); }
        path.close();
        _sharedStrokePaint
          ..color = isHovered ? const Color(0xFFFBBF24)
              : (isSelected ? primaryColor.withValues(alpha: 0.95) : shadedColor)
          ..strokeWidth = (isHovered || isSelected) ? 2.2 : 1.2;
        canvas.drawPath(path, _sharedStrokePaint);
        drawCalls++;
      }
    }
    if (solidPositions.isNotEmpty) {
      final vertices = ui.Vertices(ui.VertexMode.triangles, solidPositions, colors: solidColors);
      canvas.drawVertices(vertices, BlendMode.dst, _sharedSolidPaint);
      drawCalls++;
    }
    return drawCalls;
  }

  @override
  bool shouldRepaint(covariant _Generic3DScenePainter old) {
    return old.yaw != yaw ||
        old.pitch != pitch ||
        old.zoom != zoom ||
        old.isDark != isDark ||
        old.hoveredPartKey != hoveredPartKey ||
        old.selectedPartKey != selectedPartKey ||
        old.faces != faces ||
        old.glbBuffer != glbBuffer ||
        old.activeStatuses != activeStatuses;
  }
}

class _RenderFace {
  final MeshFace3D original;
  final List<Point3D> rotatedVertices;
  final Point3D normal;
  final double avgZ;

  _RenderFace({
    required this.original,
    required this.rotatedVertices,
    required this.normal,
    required this.avgZ,
  });
}
