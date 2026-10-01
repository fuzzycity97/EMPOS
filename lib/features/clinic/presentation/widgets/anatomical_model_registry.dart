import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/localization/app_language.dart';
import 'multi_specialty_anatomy_canvas_widget.dart';

/// Represents a distinct 3D anatomical model variant/option available for a clinical discipline or body part.
class AnatomicalModelOption {
  final String id;
  final String labelEn;
  final String labelAr;
  final String assetPath;
  final IconData icon;
  final String? subtitleEn;
  final String? subtitleAr;

  const AnatomicalModelOption({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    required this.assetPath,
    this.icon = LucideIcons.box,
    this.subtitleEn,
    this.subtitleAr,
  });

  String get localizedLabel => AppLanguage.isArabic ? labelAr : labelEn;
  String? get localizedSubtitle => AppLanguage.isArabic ? subtitleAr : subtitleEn;
}

/// Central registry of all multi-model 3D options for clinical specialties and skeletal parts.
class AnatomicalModelRegistry {
  AnatomicalModelRegistry._();

  // ───────────────────────────────────────────────────────────────────────────
  // SKELETAL & ORTHOPEDIC SYSTEM MULTI-MODEL OPTIONS
  // ───────────────────────────────────────────────────────────────────────────

  /// Global whole-skeleton options
  static const List<AnatomicalModelOption> wholeSkeletonModels = [
    AnatomicalModelOption(
      id: 'male_skeleton',
      labelEn: 'Male Full Skeleton (1850mm)',
      labelAr: 'هيكل عظمي كامل (ذكر)',
      assetPath: 'assets/models/orthopedics/male_skeleton.glb',
      icon: LucideIcons.user,
      subtitleEn: 'Standard adult male osteological reference',
      subtitleAr: 'المرجع العظمي القياسي للبالغ الذكر',
    ),
    AnatomicalModelOption(
      id: 'female_skeleton',
      labelEn: 'Female Full Skeleton',
      labelAr: 'هيكل عظمي كامل (أنثى)',
      assetPath: 'assets/models/orthopedics/female_skeleton.glb',
      icon: LucideIcons.userCheck,
      subtitleEn: 'Adult female osteology with gynecoid pelvis',
      subtitleAr: 'هيكل أنثوي مع خصائص الحوض الولادي',
    ),
    AnatomicalModelOption(
      id: 'skull_anatomy',
      labelEn: 'Cranial & Facial Skull',
      labelAr: 'عظام الجمجمة والوجه الكاملة',
      assetPath: 'assets/models/orthopedics/skull_anatomy.glb',
      icon: LucideIcons.scanFace,
      subtitleEn: 'High-detail skull with calvaria and sutures',
      subtitleAr: 'تفاصيل دقيقة لقبة الجمجمة والدرزات العظمية',
    ),
    AnatomicalModelOption(
      id: 'spine_column',
      labelEn: 'Spinal Column & Vertebrae',
      labelAr: 'العمود الفقري والفقرات',
      assetPath: 'assets/models/orthopedics/spine_column.glb',
      icon: LucideIcons.gitCommitVertical,
      subtitleEn: 'Cervical, thoracic and lumbar vertebrae',
      subtitleAr: 'الفقرات العنقية والصدرية والقطنية',
    ),
    AnatomicalModelOption(
      id: 'rib_cage',
      labelEn: 'Thoracic Rib Cage & Sternum',
      labelAr: 'القفص الصدري والقص والأضلاع',
      assetPath: 'assets/models/orthopedics/rib_cage.glb',
      icon: LucideIcons.shield,
      subtitleEn: 'Costal arches and thoracic cavity',
      subtitleAr: 'الأقواس الضلعية وتجويف الصدر',
    ),
  ];

  /// Returns available 3D model options for a specific skeletal bone or region.
  static List<AnatomicalModelOption> getModelsForSkeletalPart(String? boneId) {
    if (boneId == null || boneId.isEmpty) {
      return wholeSkeletonModels;
    }

    final lower = boneId.toLowerCase().trim();

    // 1. Skull / Cranium / Facial
    if (lower.contains('cranium') ||
        lower.contains('skull') ||
        lower.contains('facial') ||
        lower.contains('mandible') ||
        lower.contains('maxilla') ||
        lower.contains('frontal') ||
        lower.contains('parietal') ||
        lower.contains('temporal') ||
        lower.contains('occipital')) {
      return const [
        AnatomicalModelOption(
          id: 'skull_anatomy',
          labelEn: 'The Anatomy of the Human Skull',
          labelAr: 'تشريح الجمجمة وعظام الوجه',
          assetPath: 'assets/models/orthopedics/skull_anatomy.glb',
          icon: LucideIcons.scanFace,
          subtitleEn: 'Standalone high-detail cranium & sutures',
          subtitleAr: 'نموذج مستقل فائق الدقة للجمجمة والدرزات',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 2. Spine / Vertebrae (Cervical, Thoracic, Lumbar)
    if (lower.contains('spine') ||
        lower.contains('cervical') ||
        lower.contains('thoracic') ||
        lower.contains('lumbar') ||
        lower.contains('vertebra') ||
        lower.contains('sacrum') ||
        lower.contains('coccyx')) {
      return const [
        AnatomicalModelOption(
          id: 'spine_column',
          labelEn: 'Vertebral Spinal Column & Discs',
          labelAr: 'العمود الفقري والفقرات والغضاريف',
          assetPath: 'assets/models/orthopedics/spine_column.glb',
          icon: LucideIcons.gitCommitVertical,
          subtitleEn: 'High-detail vertebral column segmentation',
          subtitleAr: 'نموذج مستقل فائق الدقة للفقرات القطنية والعنقية',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 3. Ribs & Thoracic Cage
    if (lower.contains('rib') ||
        lower.contains('costal') ||
        lower.contains('sternum') ||
        lower.contains('thoracic_ribs')) {
      return const [
        AnatomicalModelOption(
          id: 'rib_cage',
          labelEn: 'Thoracic Rib Cage & Sternum',
          labelAr: 'القفص الصدري والقص والأضلاع',
          assetPath: 'assets/models/orthopedics/rib_cage.glb',
          icon: LucideIcons.shield,
          subtitleEn: 'High-detail thoracic skeleton and costal cartilage',
          subtitleAr: 'نموذج دقيق للأضلاع والغضاريف الضلعية',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 4. Pelvis & Hip
    if (lower.contains('pelvis') ||
        lower.contains('hip') ||
        lower.contains('ilium') ||
        lower.contains('ischium') ||
        lower.contains('pubis') ||
        lower.contains('acetabulum')) {
      return const [
        AnatomicalModelOption(
          id: 'hip_bone',
          labelEn: 'Hip Bone & Pelvic Girdle',
          labelAr: 'عظام الحوض ومفصل الورك',
          assetPath: 'assets/models/orthopedics/hip_bone.glb',
          icon: LucideIcons.circleDot,
          subtitleEn: 'High-detail isolated pelvic girdle and acetabulum',
          subtitleAr: 'نموذج مستقل دقيق لعظام الحوض والحق',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 5. Femur (Thigh)
    if (lower.contains('femur') || lower.contains('thigh')) {
      return const [
        AnatomicalModelOption(
          id: 'femur',
          labelEn: 'Human Femur Bone',
          labelAr: 'عظم الفخذ المستقل',
          assetPath: 'assets/models/orthopedics/femur.glb',
          icon: LucideIcons.bone,
          subtitleEn: 'High-detail femoral head, neck, trochanters and condyles',
          subtitleAr: 'رأس وعنق ومدوري ولقمتي عظم الفخذ',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 6. Knee & Patella
    if (lower.contains('knee') || lower.contains('patella')) {
      return const [
        AnatomicalModelOption(
          id: 'knee_bones',
          labelEn: 'Knee Joint, Patella & Cartilage',
          labelAr: 'مفصل الركبة والصابونة والغضاريف',
          assetPath: 'assets/models/orthopedics/knee_bones.glb',
          icon: LucideIcons.disc,
          subtitleEn: 'Femoral-tibial articulation and patellar groove',
          subtitleAr: 'المفصل الفخذي الظنبوبي واللقمات والغضاريف الهلالية',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 7. Tibia & Fibula (Lower Leg)
    if (lower.contains('tibia') || lower.contains('fibula')) {
      return const [
        AnatomicalModelOption(
          id: 'tibia_fibula',
          labelEn: 'Tibia and Fibula Bones',
          labelAr: 'عظما القصبة والشظية (الساق)',
          assetPath: 'assets/models/orthopedics/tibia_fibula.glb',
          icon: LucideIcons.bone,
          subtitleEn: 'Crural bones, tibial plateau and malleoli',
          subtitleAr: 'هيكل الساق المستقل وهضبة القصبة والكعبين',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 8. Foot & Ankle
    if (lower.contains('foot') ||
        lower.contains('ankle') ||
        lower.contains('tarsal') ||
        lower.contains('metatarsal') ||
        lower.contains('calcaneus') ||
        lower.contains('talus')) {
      return const [
        AnatomicalModelOption(
          id: 'foot_bones',
          labelEn: 'Foot Bones, Tarsals & Ankle',
          labelAr: 'عظام القدم والكاحل ورصغ القدم',
          assetPath: 'assets/models/orthopedics/foot_bones.glb',
          icon: LucideIcons.footprints,
          subtitleEn: 'Tarsals, metatarsals and phalanges',
          subtitleAr: 'عظام الرصغ والمشط والسلاميات',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 9. Shoulder / Clavicle / Scapula / Rotator Cuff
    if (lower.contains('clavicle') ||
        lower.contains('scapula') ||
        lower.contains('shoulder') ||
        lower.contains('rotator') ||
        lower.contains('glenoid')) {
      return const [
        AnatomicalModelOption(
          id: 'rotator_cuff',
          labelEn: 'Rotator Cuff, Scapula & Clavicle',
          labelAr: 'الكفة المدورة ولوح الكتف والترقوة',
          assetPath: 'assets/models/orthopedics/rotator_cuff.glb',
          icon: LucideIcons.activity,
          subtitleEn: 'Pectoral girdle and glenohumeral articulation',
          subtitleAr: 'الحزام الصدري والمفصل الحقاني العضدي',
        ),
        AnatomicalModelOption(
          id: 'humerus',
          labelEn: 'Human Humerus Bone',
          labelAr: 'عظم العضد',
          assetPath: 'assets/models/orthopedics/humerus.glb',
          icon: LucideIcons.bone,
          subtitleEn: 'Standalone humerus bone model',
          subtitleAr: 'نموذج مستقل لعظم العضد',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 10. Humerus (Upper Arm)
    if (lower.contains('humerus')) {
      return const [
        AnatomicalModelOption(
          id: 'humerus',
          labelEn: 'Human Humerus Bone',
          labelAr: 'عظم العضد المستقل',
          assetPath: 'assets/models/orthopedics/humerus.glb',
          icon: LucideIcons.bone,
          subtitleEn: 'Greater and lesser tubercles, shaft and condyle',
          subtitleAr: 'الحديبتان الكبيرة والصغيرة واللقمات العضدية',
        ),
        AnatomicalModelOption(
          id: 'rotator_cuff',
          labelEn: 'Rotator Cuff & Shoulder Complex',
          labelAr: 'مجمع الكتف والكفة المدورة',
          assetPath: 'assets/models/orthopedics/rotator_cuff.glb',
          icon: LucideIcons.activity,
          subtitleEn: 'Scapulohumeral anatomical context',
          subtitleAr: 'السياق التشريحي الكتفي العضدي',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 11. Elbow Joint
    if (lower.contains('elbow')) {
      return const [
        AnatomicalModelOption(
          id: 'elbow_joint',
          labelEn: 'Elbow Joint Articulation',
          labelAr: 'مفصل الكوع الحركي',
          assetPath: 'assets/models/orthopedics/elbow_joint.glb',
          icon: LucideIcons.cornerDownRight,
          subtitleEn: 'Humeroulnar and humeroradial joint articulation',
          subtitleAr: 'التمفصل العضدي الزندي والعضدي الكعبري',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 12. Radius & Ulna (Forearm)
    if (lower.contains('radius') || lower.contains('ulna')) {
      return const [
        AnatomicalModelOption(
          id: 'radius_ulna',
          labelEn: 'Radius and Ulna with Landmarks',
          labelAr: 'عظما الكعبرة والزند (الساعد)',
          assetPath: 'assets/models/orthopedics/radius_ulna.glb',
          icon: LucideIcons.bone,
          subtitleEn: 'Radial head, styloid processes and interosseous margin',
          subtitleAr: 'رأس الكعبرة والنتوءان الإبريان وغشاء بين العظمين',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // 13. Hand & Wrist
    if (lower.contains('hand') ||
        lower.contains('wrist') ||
        lower.contains('carpal') ||
        lower.contains('metacarpal') ||
        lower.contains('finger') ||
        lower.contains('phalanx')) {
      return const [
        AnatomicalModelOption(
          id: 'hand_bones',
          labelEn: 'Hand Bones, Carpals & Wrist',
          labelAr: 'عظام اليد والرسغ والسلاميات',
          assetPath: 'assets/models/orthopedics/hand_bones.glb',
          icon: LucideIcons.hand,
          subtitleEn: 'Carpals, metacarpals and finger phalanges',
          subtitleAr: 'عظام الرسغ الثمانية والأمشاط والسلاميات',
        ),
        AnatomicalModelOption(
          id: 'male_skeleton_isolation',
          labelEn: 'Full Skeleton Context',
          labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
          assetPath: 'assets/models/orthopedics/male_skeleton.glb',
          icon: LucideIcons.maximize,
          subtitleEn: 'Isolated view in anatomical whole-body alignment',
          subtitleAr: 'معاينة العظم في موضعه التشريحي الكامل',
        ),
      ];
    }

    // Default for any other bone
    return const [
      AnatomicalModelOption(
        id: 'male_skeleton_isolation',
        labelEn: 'Full Skeleton Context',
        labelAr: 'معاينة ضمن الهيكل العظمي الكامل',
        assetPath: 'assets/models/orthopedics/male_skeleton.glb',
        icon: LucideIcons.maximize,
        subtitleEn: 'Isolated bone focus on whole skeleton',
        subtitleAr: 'عزل وتمييز العظم في الهيكل الكامل',
      ),
    ];
  }

  // ───────────────────────────────────────────────────────────────────────────
  // CLINICAL SPECIALTIES MULTI-MODEL REGISTRY
  // ───────────────────────────────────────────────────────────────────────────

  static const List<AnatomicalModelOption> dentalModels = [
    AnatomicalModelOption(
      id: 'upper_lower_permanent_teeth',
      labelEn: 'Complete Upper & Lower Dentition',
      labelAr: 'طقم الأسنان الدائمة العلوي والسفلي الكامل',
      assetPath: 'assets/models/teeth/upper_lower_permanent_teeth.glb',
      icon: LucideIcons.smile,
      subtitleEn: '32 permanent teeth anatomical arch arrangement',
      subtitleAr: 'ترتيب كامل لـ 32 سناً دائماً في القوسين السنيين',
    ),
    AnatomicalModelOption(
      id: 'lower_dental_arch',
      labelEn: 'Lower Mandibular Dental Arch',
      labelAr: 'القوس السني الفكي السفلي',
      assetPath: 'assets/models/teeth/lower_dental_arch.glb',
      icon: LucideIcons.shieldAlert,
      subtitleEn: 'Mandibular dental arch',
      subtitleAr: 'معاينة تفصيلية للقوس السني السفلي',
    ),
    AnatomicalModelOption(
      id: 'molar_first',
      labelEn: 'Maxillary 1st Molar',
      labelAr: 'الضرس الأول العلوي (Molar 1)',
      assetPath: 'assets/models/teeth/molar.glb',
      icon: LucideIcons.box,
      subtitleEn: 'Tri-rooted posterior molar',
      subtitleAr: 'ضرس علوي ثلاثي الجذور',
    ),
    AnatomicalModelOption(
      id: 'molar_second',
      labelEn: 'Maxillary 2nd Molar',
      labelAr: 'الضرس الثاني العلوي (Molar 2)',
      assetPath: 'assets/models/teeth/molar_second.glb',
      icon: LucideIcons.box,
      subtitleEn: 'Second maxillary molar',
      subtitleAr: 'الضرس الدائم الثاني',
    ),
    AnatomicalModelOption(
      id: 'molar_third',
      labelEn: 'Maxillary 3rd Molar (Wisdom)',
      labelAr: 'ضرس العقل العلوي (Wisdom Tooth)',
      assetPath: 'assets/models/teeth/molar_third.glb',
      icon: LucideIcons.sparkles,
      subtitleEn: 'Third wisdom molar',
      subtitleAr: 'ضرس العقل الدائم الثالث',
    ),
    AnatomicalModelOption(
      id: 'premolar',
      labelEn: 'Bicuspid Premolar',
      labelAr: 'الضاحك / النواجذ (Premolar)',
      assetPath: 'assets/models/teeth/premolar.glb',
      icon: LucideIcons.box,
      subtitleEn: 'Bicuspid crown anatomy',
      subtitleAr: 'تاج ثنائي الشرفات',
    ),
    AnatomicalModelOption(
      id: 'canine',
      labelEn: 'Canine / Cuspid Tooth',
      labelAr: 'الناب (Canine)',
      assetPath: 'assets/models/teeth/canine.glb',
      icon: LucideIcons.box,
      subtitleEn: 'Long root cuspid anchor',
      subtitleAr: 'الناب ذو الجذر الأحادي الطويل',
    ),
    AnatomicalModelOption(
      id: 'incisor',
      labelEn: 'Central Incisor',
      labelAr: 'القاطع المركزي (Central Incisor)',
      assetPath: 'assets/models/teeth/incisor.glb',
      icon: LucideIcons.box,
      subtitleEn: 'Anterior incisal blade',
      subtitleAr: 'القاطع الأمامي الحاد',
    ),
  ];

  static const List<AnatomicalModelOption> cardiologyModels = [
    AnatomicalModelOption(
      id: 'heart_standard',
      labelEn: 'Human Heart Anatomy & Chambers',
      labelAr: 'تشريح القلب وحجراته الأربعة',
      assetPath: 'assets/models/cardiology/heart.glb',
      icon: LucideIcons.heart,
      subtitleEn: 'Ventricles, atria, and great vessels',
      subtitleAr: 'البطينان والأذينان والأوعية الرئيسية',
    ),
    AnatomicalModelOption(
      id: 'coronary_arteries',
      labelEn: 'Coronary Arteries & Branches',
      labelAr: 'الشرايين التاجية وفروعها المغذية للقلب',
      assetPath: 'assets/models/cardiology/coronary_arteries.glb',
      icon: LucideIcons.gitFork,
      subtitleEn: 'LAD, LCx, and RCA arterial vasculature',
      subtitleAr: 'الشريان التاجي الأيسر والأيمن والفروع المنعطفة',
    ),
    AnatomicalModelOption(
      id: 'aortic_arch',
      labelEn: 'Aortic Arch & Great Vessels',
      labelAr: 'قوس الأبهر والأوعية الرأسية الرئيسية',
      assetPath: 'assets/models/cardiology/aortic_arch.glb',
      icon: LucideIcons.activity,
      subtitleEn: 'Ascending aorta, brachiocephalic, carotid',
      subtitleAr: 'الأبهر الصاعد والشريان العضدي الرأسي والسباتي',
    ),
    AnatomicalModelOption(
      id: 'aortic_valve',
      labelEn: 'Aortic Valve Tri-Cuspid Structure',
      labelAr: 'الصمام الأبهري ثلاثي الشرفات',
      assetPath: 'assets/models/cardiology/aortic_valve.glb',
      icon: LucideIcons.disc,
      subtitleEn: 'Aortic valve cusps and annular ring',
      subtitleAr: 'شرفات الصمام الأبهري والحلقة الصمامية',
    ),
    AnatomicalModelOption(
      id: 'artery_vein_system',
      labelEn: '3D Human Artery & Vein System',
      labelAr: 'شبكة الأوعية الدموية (شرايين وأوردة)',
      assetPath: 'assets/models/cardiology/artery_vein_system.glb',
      icon: LucideIcons.gitMerge,
      subtitleEn: 'Systemic arterial and venous circulation',
      subtitleAr: 'الدورة الدموية الشريانية والوريدية الكبرى',
    ),
    AnatomicalModelOption(
      id: 'varicose_veins',
      labelEn: 'Varicose Veins Pathology & Valvular Reflux',
      labelAr: 'دوالي الأوردة وقصور الصمامات الوريدية',
      assetPath: 'assets/models/cardiology/varicose_veins.glb',
      icon: LucideIcons.zap,
      subtitleEn: 'Venous insufficiency, tortuosity and saphenous reflux',
      subtitleAr: 'القصور الوريدي والتوسع والتفرعات المتعرجة',
    ),
  ];

  static const List<AnatomicalModelOption> neurologyModels = [
    AnatomicalModelOption(
      id: 'brain_hemispheres',
      labelEn: 'Cerebral Brain & Hemispheres',
      labelAr: 'المخ ونصفا الكرة المخية والتلافيف',
      assetPath: 'assets/models/neurology/brain.glb',
      icon: LucideIcons.brain,
      subtitleEn: 'Frontal, temporal, parietal and occipital lobes',
      subtitleAr: 'الفصوص الجبهية والصدغية والجدارية والقذالية',
    ),
    AnatomicalModelOption(
      id: 'cranial_nerves_foramina',
      labelEn: 'Cranial Nerves & Skull Base Foramina',
      labelAr: 'الأعصاب القحفية وثقوب قاعدة الجمجمة',
      assetPath: 'assets/models/neurology/cranial_nerves_foramina.glb',
      icon: LucideIcons.network,
      subtitleEn: '12 cranial nerves exiting skull foramina',
      subtitleAr: 'الأعصاب القحفية الاثنا عشر وخروجها عبر الثقوب العظمية',
    ),
    AnatomicalModelOption(
      id: 'cranial_nerves',
      labelEn: 'Cranial Nerves Pathway',
      labelAr: 'مسار الأعصاب القحفية التفصيلي',
      assetPath: 'assets/models/neurology/cranial_nerves.glb',
      icon: LucideIcons.gitPullRequest,
      subtitleEn: 'Isolated cranial nerve tracts',
      subtitleAr: 'تتبع مسارات الأعصاب الدماغية المعزولة',
    ),
    AnatomicalModelOption(
      id: 'circle_of_willis',
      labelEn: 'Circle of Willis (Cerebral Arterial Circle)',
      labelAr: 'دائرة ويليس الشريانية الدماغية',
      assetPath: 'assets/models/neurology/circle_of_willis.glb',
      icon: LucideIcons.circle,
      subtitleEn: 'Anterior and posterior cerebral communicating arteries',
      subtitleAr: 'الشرايين الموصلة والدماغية الأمامية والخلفية',
    ),
    AnatomicalModelOption(
      id: 'nervous_system',
      labelEn: 'Central & Peripheral Nervous System',
      labelAr: 'الجهاز العصبي المركزي والطرفي الكامل',
      assetPath: 'assets/models/neurology/nervous_system.glb',
      icon: LucideIcons.share2,
      subtitleEn: 'Brain, spinal cord and somatic nerve trunks',
      subtitleAr: 'الدماغ والحبل الشوكي والجذوع العصبية الطرفية',
    ),
    AnatomicalModelOption(
      id: 'nerves_cross_section',
      labelEn: 'Spinal Nerves Skeletal Cross-Section',
      labelAr: 'مقطع عرضي للأعصاب الشوكية مع الفقرات',
      assetPath: 'assets/models/neurology/nerves_skeletal_cross_section.glb',
      icon: LucideIcons.layers,
      subtitleEn: 'Spinal nerve roots passing intervertebral foramina',
      subtitleAr: 'خروج جذور الأعصاب الشوكية عبر الثقوب بين الفقرية',
    ),
  ];

  static const List<AnatomicalModelOption> entModels = [
    AnatomicalModelOption(
      id: 'inner_ear',
      labelEn: 'Inner Ear & Cochlea',
      labelAr: 'الأذن الداخلية والقوقعة',
      assetPath: 'assets/models/ent/inner_ear.glb',
      icon: LucideIcons.ear,
      subtitleEn: 'Cochlea, vestibule and acoustic nerve',
      subtitleAr: 'القوقعة والدهليز والعصب السمعي',
    ),
    AnatomicalModelOption(
      id: 'inner_ear_apparatus',
      labelEn: 'Vestibular Labyrinth & Semicircular Canals',
      labelAr: 'التيه الدهليزي والقنوات الهلالية',
      assetPath: 'assets/models/ent/inner_ear_apparatus.glb',
      icon: LucideIcons.compass,
      subtitleEn: 'Balance organs, ampullae and vestibular system',
      subtitleAr: 'أعضاء التوازن والقنوات الهلالية الثلاث',
    ),
    AnatomicalModelOption(
      id: 'middle_ear_ossicles',
      labelEn: 'Middle Ear Ossicles, Folds & Ligaments',
      labelAr: 'عظيمات الأذن الوسطى (المطرقة، السندان، الركاب)',
      assetPath: 'assets/models/ent/middle_ear_ossicles.glb',
      icon: LucideIcons.music,
      subtitleEn: 'Malleus, incus, stapes and tympanic ligaments',
      subtitleAr: 'المطرقة والسندان والركاب وأربطة الطبلة',
    ),
    AnatomicalModelOption(
      id: 'ear_structures',
      labelEn: 'Complete Ear Structures Overview',
      labelAr: 'تشريح الأذن الكامل (خارجية، وسطى، داخلية)',
      assetPath: 'assets/models/ent/ear_structures.glb',
      icon: LucideIcons.volume2,
      subtitleEn: 'Auricle, canal, tympanic cavity and labyrinth',
      subtitleAr: 'صيوان الأذن والقناة السمعية وتجويف الطبلة',
    ),
    AnatomicalModelOption(
      id: 'paranasal_sinuses',
      labelEn: 'Paranasal Sinuses & Ostia',
      labelAr: 'الجيوب الأنفية وفتحات التصريف',
      assetPath: 'assets/models/ent/paranasal_sinuses.glb',
      icon: LucideIcons.wind,
      subtitleEn: 'Maxillary, frontal, ethmoid and sphenoid sinuses',
      subtitleAr: 'الجيوب الفكية والجبهية والغربالية والوتدية',
    ),
    AnatomicalModelOption(
      id: 'paranasal_sinuses_alt',
      labelEn: 'Paranasal Sinuses (Surgical Detail)',
      labelAr: 'الجيوب الأنفية (تفاصيل منظار FESS)',
      assetPath: 'assets/models/ent/paranasal_sinuses_alt.glb',
      icon: LucideIcons.scan,
      subtitleEn: 'High-detail ostiomeatal complex landmarks',
      subtitleAr: 'معالم المجمع الفوهي الصماخي الجراحي',
    ),
    AnatomicalModelOption(
      id: 'larynx_muscles_ligaments',
      labelEn: 'Larynx with Muscles and Ligaments',
      labelAr: 'الحنجرة مع العضلات والأربطة والحبال الصوتية',
      assetPath: 'assets/models/ent/larynx_muscles_ligaments.glb',
      icon: LucideIcons.mic,
      subtitleEn: 'Thyroid, cricoid, arytenoid and intrinsic muscles',
      subtitleAr: 'الغضاريف الدرقية والحلقية وعضلات الحبال الصوتية',
    ),
    AnatomicalModelOption(
      id: 'larynx_anatomy',
      labelEn: 'Anatomy of the Laryngeal Framework',
      labelAr: 'الهيكل الغضروفي للحنجرة',
      assetPath: 'assets/models/ent/larynx_anatomy.glb',
      icon: LucideIcons.gitCommit,
      subtitleEn: 'Laryngeal cartilage architecture',
      subtitleAr: 'هيكل الغضاريف الحنجرية وتفرع القصبة',
    ),
  ];

  static const List<AnatomicalModelOption> respiratoryModels = [
    AnatomicalModelOption(
      id: 'lungs_standard',
      labelEn: 'Lungs & Bronchial Tree',
      labelAr: 'الرئتان والشجرة القصبية الكاملة',
      assetPath: 'assets/models/respiratory/lungs.glb',
      icon: LucideIcons.wind,
      subtitleEn: 'Right and left pulmonary lobes with pleura',
      subtitleAr: 'الفصوص الرئوية اليمنى واليسرى وغشاء الجنب',
    ),
    AnatomicalModelOption(
      id: 'tracheobronchial_tree',
      labelEn: 'Tracheobronchial Airway Tree',
      labelAr: 'الشجرة الرغامية القصبية الهوائية',
      assetPath: 'assets/models/respiratory/tracheobronchial_tree.glb',
      icon: LucideIcons.gitFork,
      subtitleEn: 'Trachea, main bronchi and lobar arborization',
      subtitleAr: 'القصبة الهوائية وتفرعات القصبات الرئيسية والفصية',
    ),
    AnatomicalModelOption(
      id: 'tracheobronchial_tree_branching',
      labelEn: 'Tracheobronchial Tree (Moderate Branching)',
      labelAr: 'الشجرة القصبية (تفرعات متوسطة تفصيلية)',
      assetPath: 'assets/models/respiratory/tracheobronchial_tree_branching.glb',
      icon: LucideIcons.share2,
      subtitleEn: 'Segmental and subsegmental bronchi divisions',
      subtitleAr: 'انقسامات القصبات القطعية وتحت القطعية',
    ),
    AnatomicalModelOption(
      id: 'bronchioles_alveoli',
      labelEn: 'Bronchioles & Alveoli Micro-Anatomy',
      labelAr: 'القصيبات والأسناخ الرئوية المجهرية',
      assetPath: 'assets/models/respiratory/bronchioles_alveoli.glb',
      icon: LucideIcons.sparkles,
      subtitleEn: 'Respiratory bronchioles, alveolar ducts and sacs',
      subtitleAr: 'القصيبات التنفسية وقنوات الأسناخ الرئوية',
    ),
    AnatomicalModelOption(
      id: 'alveolar_sacs',
      labelEn: 'Alveolar Sacs & Gas Exchange Capillaries',
      labelAr: 'الحويصلات الهوائية وشبكة تبادل الغازات',
      assetPath: 'assets/models/respiratory/alveolar_sacs.glb',
      icon: LucideIcons.bubbles,
      subtitleEn: 'Microscopic functional units for O2/CO2 exchange',
      subtitleAr: 'الوحدات الوظيفية المجهرية لتبادل الأكسجين',
    ),
  ];

  static const List<AnatomicalModelOption> gastroModels = [
    AnatomicalModelOption(
      id: 'digestive_overview',
      labelEn: 'Digestive Tract & Viscera Overview',
      labelAr: 'نظام الجهاز الهضمي والأحشاء الباطنية',
      assetPath: 'assets/models/gastroenterology/digestive.glb',
      icon: LucideIcons.utensils,
      subtitleEn: 'Esophagus, stomach, intestines and accessory glands',
      subtitleAr: 'المريء والمعدة والأمعاء والغدد الهضمية الملحقة',
    ),
    AnatomicalModelOption(
      id: 'liver_gallbladder',
      labelEn: 'Liver, Biliary Ducts & Gallbladder',
      labelAr: 'الكبد والقنوات الصفراوية والمرارة',
      assetPath: 'assets/models/gastroenterology/liver_gallbladder.glb',
      icon: LucideIcons.shield,
      subtitleEn: 'Hepatic lobes, portal triad and gallbladder',
      subtitleAr: 'فصوص الكبد والثالوث البابي والمرارة والقناة الجامعة',
    ),
    AnatomicalModelOption(
      id: 'gallbladder',
      labelEn: 'Gallbladder Standalone Organ',
      labelAr: 'المرارة والقناة المرارية المستقلة',
      assetPath: 'assets/models/gastroenterology/gallbladder.glb',
      icon: LucideIcons.droplet,
      subtitleEn: 'Fundus, body, neck and cystic duct',
      subtitleAr: 'قاع وجسم وعنق المرارة والقناة المرارية الكيسية',
    ),
    AnatomicalModelOption(
      id: 'pancreas_duodenum_spleen',
      labelEn: 'Pancreas, Duodenum & Spleen Complex',
      labelAr: 'البنكرياس والإثني عشر والطحال',
      assetPath: 'assets/models/gastroenterology/pancreas_duodenum_spleen.glb',
      icon: LucideIcons.component,
      subtitleEn: 'C-loop duodenum, pancreatic duct and splenic hilum',
      subtitleAr: 'قوس الإثني عشر وقناة البنكرياس وسرة الطحال',
    ),
    AnatomicalModelOption(
      id: 'pancreas_duodenum',
      labelEn: 'Pancreas and Duodenum Articulation',
      labelAr: 'البنكرياس والإثني عشر',
      assetPath: 'assets/models/gastroenterology/pancreas_duodenum.glb',
      icon: LucideIcons.layers,
      subtitleEn: 'Head, uncinate process and ampulla of Vater',
      subtitleAr: 'رأس وعنق البنكرياس ومجل أمبولة فاتر',
    ),
    AnatomicalModelOption(
      id: 'colon_anatomy',
      labelEn: 'Complete Colon & Colorectal Anatomy',
      labelAr: 'تشريح القولون الكامل والمستقيم',
      assetPath: 'assets/models/gastroenterology/colon_anatomy.glb',
      icon: LucideIcons.repeat,
      subtitleEn: 'Ascending, transverse, descending and sigmoid colon',
      subtitleAr: 'القولون الصاعد والمستعرض والهابط والسيني',
    ),
    AnatomicalModelOption(
      id: 'large_intestine',
      labelEn: 'Human Large Intestine Model',
      labelAr: 'الأمعاء الغليظة والأعور والزائدة الدودية',
      assetPath: 'assets/models/gastroenterology/large_intestine.glb',
      icon: LucideIcons.box,
      subtitleEn: 'Cecum, appendix, haustra and taeniae coli',
      subtitleAr: 'الأعور والزائدة والتجيبات وأشرطة القولون',
    ),
    AnatomicalModelOption(
      id: 'bowel_anatomy',
      labelEn: 'Bowel Anatomy (Small & Large Intestine)',
      labelAr: 'تشريح الأمعاء (الدقيقة والغليظة)',
      assetPath: 'assets/models/gastroenterology/bowel_anatomy.glb',
      icon: LucideIcons.gitBranch,
      subtitleEn: 'Jejunum, ileum and mesenteric arcade',
      subtitleAr: 'الصائم واللفائفي والأوعية المساريقية',
    ),
  ];

  static const List<AnatomicalModelOption> urologyModels = [
    AnatomicalModelOption(
      id: 'kidney_standard',
      labelEn: 'Kidney & Urinary Tract Overview',
      labelAr: 'الكلى والمسالك البولية العامة',
      assetPath: 'assets/models/urology/kidney.glb',
      icon: LucideIcons.activity,
      subtitleEn: 'Renal cortex, medulla, pelvis and ureter',
      subtitleAr: 'قشرة ونخاع وحويضة الكلية والحالب',
    ),
    AnatomicalModelOption(
      id: 'urinary_system',
      labelEn: 'Complete Human Urinary System',
      labelAr: 'الجهاز البولي البشري الكامل',
      assetPath: 'assets/models/urology/urinary_system.glb',
      icon: LucideIcons.filter,
      subtitleEn: 'Bilateral kidneys, ureters, bladder and urethra',
      subtitleAr: 'الكليتان والحالبان والمثانة ومجرى البول',
    ),
    AnatomicalModelOption(
      id: 'urinary_tract',
      labelEn: 'Urinary Tract Architecture',
      labelAr: 'بنية المسالك البولية والمثانة',
      assetPath: 'assets/models/urology/urinary_tract.glb',
      icon: LucideIcons.gitCommit,
      subtitleEn: 'Upper and lower urinary collection systems',
      subtitleAr: 'المسالك البولية العلوية والسفلية',
    ),
    AnatomicalModelOption(
      id: 'bladder_prostate',
      labelEn: 'Bladder and Prostate Anatomy',
      labelAr: 'تشريح المثانة والبروستاتا',
      assetPath: 'assets/models/urology/bladder_prostate.glb',
      icon: LucideIcons.circleDot,
      subtitleEn: 'Urinary bladder, prostate gland and seminal vesicles',
      subtitleAr: 'المثانة البولية وغدة البروستاتا والحويصلات المنوية',
    ),
    AnatomicalModelOption(
      id: 'bladder_prostate_cross_section',
      labelEn: 'Bladder & Prostate Cross-Section',
      labelAr: 'مقطع عرضي للمثانة والبروستاتا',
      assetPath: 'assets/models/urology/bladder_prostate_cross_section.glb',
      icon: LucideIcons.layers,
      subtitleEn: 'Prostatic urethra, verumontanum and bladder detrusor',
      subtitleAr: 'مجرى البول البروستاتي وعضلة المثانة العاصرة',
    ),
  ];

  static const List<AnatomicalModelOption> obgynModels = [
    AnatomicalModelOption(
      id: 'female_reproductive',
      labelEn: 'Female Reproductive System Overview',
      labelAr: 'الجهاز التناسلي الأنثوي العام',
      assetPath: 'assets/models/obgyn/female_reproductive.glb',
      icon: LucideIcons.heartHandshake,
      subtitleEn: 'Uterus, ovaries, fallopian tubes and cervix',
      subtitleAr: 'الرحم والمبيضان وقناتا فالوب وعنق الرحم',
    ),
    AnatomicalModelOption(
      id: 'uterus_cross_section',
      labelEn: 'Standard Uterus Anatomy - Cross Section',
      labelAr: 'مقطع عرضي تشريحي للرحم',
      assetPath: 'assets/models/obgyn/uterus_cross_section.glb',
      icon: LucideIcons.layers,
      subtitleEn: 'Endometrium, myometrium, and perimetrium layers',
      subtitleAr: 'طبقات بطانة الرحم وعضلة الرحم والغشاء الخارجي',
    ),
    AnatomicalModelOption(
      id: 'uterus_endometrium',
      labelEn: 'Coronal Uterus with Endometrial Cavity',
      labelAr: 'مقطع إكليلي لتجويف بطانة الرحم',
      assetPath: 'assets/models/obgyn/uterus_endometrium.glb',
      icon: LucideIcons.scan,
      subtitleEn: 'Coronal cross-section with endometrial interface',
      subtitleAr: 'معاينة تجويف الرحم والقرنين والفتحات البوقية',
    ),
    AnatomicalModelOption(
      id: 'pelvic_floor_muscles_3d',
      labelEn: '3D Pelvic Floor Muscles',
      labelAr: 'عضلات قاع الحوض ثلاثية الأبعاد',
      assetPath: 'assets/models/obgyn/pelvic_floor_muscles_3d.glb',
      icon: LucideIcons.shield,
      subtitleEn: 'Levator ani, pubococcygeus and pelvic diaphragm',
      subtitleAr: 'العضلة الرافعة للشرج والحجاب الحوضي',
    ),
    AnatomicalModelOption(
      id: 'pelvic_floor_muscles',
      labelEn: 'Female Pelvic Floor Musculature',
      labelAr: 'عضلات الحوض النسائية والرباط العجاني',
      assetPath: 'assets/models/obgyn/pelvic_floor_muscles.glb',
      icon: LucideIcons.grid,
      subtitleEn: 'Perineal membrane and urogenital hiatus',
      subtitleAr: 'الغشاء العجاني والفرجة البولية التناسلية',
    ),
  ];

  static const List<AnatomicalModelOption> ophthalmologyModels = [
    AnatomicalModelOption(
      id: 'eye_standard',
      labelEn: 'Human Eyeball Anatomy',
      labelAr: 'تشريح كرة العين والقرنية والعدسة',
      assetPath: 'assets/models/ophthalmology/eye.glb',
      icon: LucideIcons.eye,
      subtitleEn: 'Cornea, lens, iris, vitreous body and retina',
      subtitleAr: 'القرنية والعدسة والقزحية والجسم الزجاجي والشبكية',
    ),
    AnatomicalModelOption(
      id: 'extraocular_muscles',
      labelEn: 'Extraocular Muscles and Eyeball',
      labelAr: 'عضلات العين الخارجية المحركة ومحجر العين',
      assetPath: 'assets/models/ophthalmology/extraocular_muscles.glb',
      icon: LucideIcons.move,
      subtitleEn: 'Recti and oblique muscles controlling eye gaze',
      subtitleAr: 'العضلات المستقيمة والمائلة المتحكمة بحركة العين',
    ),
    AnatomicalModelOption(
      id: 'eye_muscles',
      labelEn: 'Extraocular Musculature Standalone',
      labelAr: 'عضلات العين الخارجية المعزولة',
      assetPath: 'assets/models/ophthalmology/eye_muscles.glb',
      icon: LucideIcons.activity,
      subtitleEn: 'Isolated extraocular motor muscle groups',
      subtitleAr: 'مجموعات العضلات الحركية المحيطة بالعين',
    ),
    AnatomicalModelOption(
      id: 'eye_model_unmc',
      labelEn: 'UNMC Eye Anatomical Reference',
      labelAr: 'نموذج العين التشريحي المرجعي UNMC',
      assetPath: 'assets/models/ophthalmology/eye_model_unmc.glb',
      icon: LucideIcons.scanEye,
      subtitleEn: 'High-detail ocular cross-section model',
      subtitleAr: 'نموذج أكاديمي دقيق لمقاطع العين',
    ),
    AnatomicalModelOption(
      id: 'retinal_layers',
      labelEn: 'Retinal Layers Microscopic & Schematic',
      labelAr: 'طبقات الشبكية المجهرية وقاع العين',
      assetPath: 'assets/models/ophthalmology/retinal_layers.glb',
      icon: LucideIcons.sparkles,
      subtitleEn: 'Photoreceptors, bipolar, ganglion and nerve fiber layers',
      subtitleAr: 'المستقبلات الضوئية والخلايا ثنائية القطب والعقدية',
    ),
    AnatomicalModelOption(
      id: 'stargardt_macula',
      labelEn: 'Eye Anatomy with Stargardt Macular Dystrophy',
      labelAr: 'اعتلال اللطخة الصفراء وتنكس ستارغاردت',
      assetPath: 'assets/models/ophthalmology/stargardt_macula.glb',
      icon: LucideIcons.alertTriangle,
      subtitleEn: 'Macula lutea, fovea centralis and lipofuscin flecks',
      subtitleAr: 'اللطخة الصفراء والندبات الصفراء المركزية',
    ),
  ];

  static const List<AnatomicalModelOption> aestheticsDermatologyModels = [
    AnatomicalModelOption(
      id: 'skin_anatomy',
      labelEn: 'Skin Anatomy & Dermal Cross-Section',
      labelAr: 'مقطع عرضي للجلد والبشرة والأدمة',
      assetPath: 'assets/models/dermatology/skin_anatomy.glb',
      icon: LucideIcons.layers,
      subtitleEn: 'Epidermis, dermis, hypodermis and vessels',
      subtitleAr: 'البشرة والأدمة والطبقة تحت الجلدية والأوعية',
    ),
    AnatomicalModelOption(
      id: 'hair_follicle',
      labelEn: 'Hair Follicle & Sebaceous Gland Complex',
      labelAr: 'بصيلة الشعر والغدة الدهنية المجهرية',
      assetPath: 'assets/models/dermatology/hair_follicle.glb',
      icon: LucideIcons.sparkle,
      subtitleEn: 'Dermal papilla, root sheath and arrector pili muscle',
      subtitleAr: 'الحليمة الجلدية وجذر الشعرة والعضلة الناصبة للشعر',
    ),
    AnatomicalModelOption(
      id: 'facial_expression_muscles',
      labelEn: 'Muscles of Facial Expression',
      labelAr: 'عضلات التعبير والوجه (حقن البوتوكس والفيلر)',
      assetPath: 'assets/models/aesthetics/facial_expression_muscles.glb',
      icon: LucideIcons.smile,
      subtitleEn: 'Frontalis, orbicularis oculi, zygomaticus and risorius',
      subtitleAr: 'العضلة الجبهية والدائرية العينية والوجنية والضحكية',
    ),
    AnatomicalModelOption(
      id: 'head_muscles',
      labelEn: 'Color-Coded Head & Facial Muscle Chart',
      labelAr: 'خارطة عضلات الرأس والوجه الملونة',
      assetPath: 'assets/models/aesthetics/head_muscles.glb',
      icon: LucideIcons.palette,
      subtitleEn: 'Masticatory, temporalis and superficial facial muscle chart',
      subtitleAr: 'خارطة مميزة لعضلات المضغ والصدغية والوجه السطحية',
    ),
  ];

  /// Returns the complete list of model options available for a given discipline.
  static List<AnatomicalModelOption> getModelsForDiscipline(ClinicalSpecialtyDiscipline discipline) {
    switch (discipline) {
      case ClinicalSpecialtyDiscipline.dental:
        return dentalModels;
      case ClinicalSpecialtyDiscipline.cardiology:
      case ClinicalSpecialtyDiscipline.vascularVein:
        return cardiologyModels;
      case ClinicalSpecialtyDiscipline.neurology:
      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
      case ClinicalSpecialtyDiscipline.mentalHealth:
        return neurologyModels;
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
      case ClinicalSpecialtyDiscipline.neuroOtology:
      case ClinicalSpecialtyDiscipline.speechPathology:
        return entModels;
      case ClinicalSpecialtyDiscipline.pulmonology:
        return respiratoryModels;
      case ClinicalSpecialtyDiscipline.gastroenterology:
      case ClinicalSpecialtyDiscipline.endocrinology:
        return gastroModels;
      case ClinicalSpecialtyDiscipline.urology:
        return urologyModels;
      case ClinicalSpecialtyDiscipline.obgyn:
        return obgynModels;
      case ClinicalSpecialtyDiscipline.ophthalmology:
        return ophthalmologyModels;
      case ClinicalSpecialtyDiscipline.dermatology:
      case ClinicalSpecialtyDiscipline.plasticSurgery:
      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return aestheticsDermatologyModels;
      case ClinicalSpecialtyDiscipline.orthopedics:
      case ClinicalSpecialtyDiscipline.physiotherapy:
      case ClinicalSpecialtyDiscipline.podiatry:
        return wholeSkeletonModels;
      case ClinicalSpecialtyDiscipline.general:
      case ClinicalSpecialtyDiscipline.pediatrics:
      case ClinicalSpecialtyDiscipline.painManagement:
      case ClinicalSpecialtyDiscipline.acupuncture:
      case ClinicalSpecialtyDiscipline.veterinary:
      case ClinicalSpecialtyDiscipline.diagnosticLab:
        return const [
          AnatomicalModelOption(
            id: 'general_body',
            labelEn: 'Full Body Anatomy',
            labelAr: 'تشريح الجسم الكامل',
            assetPath: 'assets/models/general/full_body_anatomy.glb',
            icon: LucideIcons.user,
            subtitleEn: 'Standard holistic anatomy model',
            subtitleAr: 'النموذج التشريحي العام للجسم',
          ),
        ];
    }
  }

  /// Resolves models available for a specific part in a discipline, or defaults to discipline models.
  static List<AnatomicalModelOption> getModelsForSpecialtyPart(
    ClinicalSpecialtyDiscipline? discipline,
    String? partKey,
  ) {
    if (discipline == null) return const [];
    return getModelsForDiscipline(discipline);
  }

  /// Checks whether a given part or discipline has more than 1 model option available.
  static bool hasMultipleModelsForSkeletalPart(String? boneId) {
    return getModelsForSkeletalPart(boneId).length > 1;
  }

  /// Checks whether a given discipline has more than 1 model option available.
  static bool hasMultipleModelsForDiscipline(ClinicalSpecialtyDiscipline? discipline) {
    if (discipline == null) return false;
    return getModelsForDiscipline(discipline).length > 1;
  }
}
