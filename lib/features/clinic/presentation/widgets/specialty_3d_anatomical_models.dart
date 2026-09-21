import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import 'clinical_3d_engine_core.dart';

/// Available 3D Medical Instruments & Surgical Tools across Clinical Disciplines
enum SpecialtyInstrument {
  none('None (Normal Anatomy)', 'بدون أدوات (تشريح طبيعي)'),
  // Cardiology
  coronaryStent('Drug-Eluting Stent (DES)', 'دعامة شريانية دوائية (DES)'),
  angioplastyBalloon('Balloon Angioplasty', 'قسطرة بالونية توسيعية'),
  tavrValve('TAVR Aortic Valve', 'صمام أبهري عبر القسطرة (TAVR)'),
  pacemakerLead('Pacemaker / ICD Lead', 'سلك منظم ضربات القلب'),
  // Physiotherapy
  kinesioTape('Kinesiology Dynamic Tape', 'شريط كينيسيولوجي حركي'),
  dryNeedle('Dry Needling Filiform Needle', 'إبرة جافة علاجية'),
  cuppingDome('Vacuum Cupping Cup', 'كأس حجامة مفرغ من الهواء'),
  tensPad('TENS Electrotherapy Pads', 'لصقات التحفيز الكهربائي TENS'),
  // Gastroenterology
  biopsyForceps('Endoscopic Biopsy Forceps', 'ملقط أخذ عينة بالمنظار'),
  hemoclip('Hemostatic Endoclip', 'كليب وقف النزيف بالمنظار'),
  biliaryStent('Biliary Wallstent', 'دعامة القنوات المرارية والبنكرياس'),
  laparoscopicTrocar('Laparoscopic Trocar Cannula', 'مدخل جراحة المنظار (تروكار)'),
  // Dermatology
  punchBiopsy('4mm Punch Biopsy Trephine', 'مشرط الخزعة الدائري (Punch)'),
  intradermalSuture('Intradermal Suture Line', 'غرز جراحية تجميلية دقيقة'),
  cryoSpray('Cryotherapy Liquid Nitrogen Nozzle', 'بخاخ التجميد بالنيتروجين'),
  microneedle('Microneedling Dermaroller', 'بكرة الإبر الدقيقة للجلد'),
  // Neurology
  stereotacticBurrhole('Stereotactic Burr Hole & Frame', 'إطار التوجيه التجسيمي وثقب الجمجمة'),
  dbsElectrode('Deep Brain Stimulation (DBS) Electrode', 'قطب التحفيز الدماغي العميق (DBS)'),
  aneurysmClip('Titanium Aneurysm Clip', 'كليب تمدد الأوعية الدماغية'),
  // Neuro-Otology
  audiometricProbe('Vestibular Caloric/Impedance Probe', 'مسبار فحص التوازن والسمع'),
  tympanostomyTube('Tympanostomy Ventilation Tube', 'أنبوب تهوية طبلة الأذن'),
  // Neuro-Psychiatry
  tmsFigure8Coil('TMS Figure-8 Magnetic Coil', 'ملف التحفيز المغناطيسي TMS شكل-8'),
  eegCapElectrode('10-20 EEG Sensor Montage', 'أقطاب تخطيط الدماغ الكهربائي EEG'),
  // Rhinology & Sinus ENT
  sinusEndoscope('0°/30° Rigid Sinus Endoscope', 'منظار الجيوب الأنفية الصلب'),
  sinusBalloon('Balloon Sinuplasty Dilator', 'بالون توسيع فتحات الجيوب الأنفية'),
  // Urology
  rigidCystoscope('Rigid/Flexible Cystoscope', 'منظار المثانة ومجرى البول'),
  doubleJStent('Double-J (JJ) Ureteral Stent', 'دعامة الحالب المزدوجة JJ'),
  prostateNeedle('Transrectal Prostate Biopsy Needle', 'إبرة خزعة البروستاتا الموجهة'),
  // OB/GYN
  hysteroscopyShaft('Diagnostic Hysteroscope Shaft', 'منظار تجويف الرحم التشخيصي'),
  iudDevice('Intrauterine Contraceptive Device (IUD)', 'اللولب الرحمي المانع للحمل'),
  follicleAspirationNeedle('IVF Oocyte Pick-Up Needle', 'إبرة سحب البويضات للحقن المجهري'),
  // Pulmonology
  flexibleBronchoscope('Flexible Fiberoptic Bronchoscope', 'منظار القصبات الهوائية المرن'),
  chestTube('Intercostal Chest Drainage Tube', 'أنبوب الصدر لنزح السائل والهواء'),
  endobronchialValve('Zephyr Endobronchial Valve', 'صمام القصبات الهوائية لانتفاخ الرئة'),
  // Podiatry
  orthoticInsole('Custom Biomechanical Orthotic Insole', 'نعل طبي تقويمي مخصص'),
  fasciotomyBlade('Plantar Fasciotomy Release Blade', 'مبضع تسليك اللفافة الأخمصية'),
  // Plastic Surgery
  vectorLiftThread('Barbed PDO Vector Lifting Thread', 'خيوط الشد الجراحي التجميلي PDO'),
  liposuctionCannula('Tumescent Liposuction Cannula', 'قنية شفط الدهون ونحت القوام'),
  // Medical Aesthetics
  microCannula('27G Blunt Aesthetic Micro-Cannula', 'قنية الحقن التجميلي غير الحادة 27G'),
  botoxSyringe('32G Ultra-Fine Neuromodulator Needle', 'إبرة حقن البوتوكس فائقة الدقة 32G'),
  // Pain Management
  tuohyEpiduralNeedle('18G Tuohy Epidural Needle', 'إبرة التخدير وحقن فوق الجافية Tuohy'),
  rfAblationElectrode('Radiofrequency (RF) Facet Electrode', 'قطب التردد الحراري لمفاصل الفقرات'),
  // Acupuncture
  filiformNeedle('Stainless Filiform Acupoint Needle', 'إبرة وخز صينية مرنة معقمة'),
  moxibustionCone('Smokeless Moxibustion Cup', 'كأس الموكسا الحرارية للعلاج الصيني'),
  // Speech Pathology
  feesLaryngoscope('FEES Flexible Nasopharyngoscope', 'منظار تقييم البلع والحبال الصوتية FEES'),
  passyMuirValve('Passy-Muir Tracheostomy Speaking Valve', 'صمام الكلام لأنبوب شق القصبة الهوائية'),
  // Veterinary
  vetBonePlate('Veterinary Dynamic Compression Plate (DCP)', 'شريحة تثبيت العظام البيطرية DCP'),
  vetDentalScaler('Veterinary Ultrasonic Dental Scaler', 'جهاز تنظيف الأسنان البيطري بالموجات'),
  // Vascular / Vein
  evlaLaserFiber('EVLA Endovenous Laser Fiber', 'ألياف الليزر الوريدي EVLA'),
  scleroMicroNeedle('Sclerotherapy 30G Micro-Needle', 'إبرة حقن تصليب الأوردة 30G');

  final String titleEn;
  final String titleAr;
  const SpecialtyInstrument(this.titleEn, this.titleAr);

  String get localizedTitle => AppLanguage.isArabic ? titleAr : titleEn;
}

/// 3D Anatomical Mesh Generators for Medical Disciplines with Age Progression & Specialized Instruments
class Specialty3dAnatomicalModels {
  // ─────────────────────────────────────────────────────────────────────────
  // 1. CARDIOLOGY & CORONARY TREE 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildCardiologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    // Age-specific geometry factors
    final double hypertrophy = stage == ClinicalAgeStage.geriatric ? 1.25 : (stage == ClinicalAgeStage.infant ? 0.75 : 1.0);
    final double calcification = stage == ClinicalAgeStage.geriatric ? 1.0 : 0.0;
    final bool isInfant = stage == ClinicalAgeStage.infant;

    // Aorta color shifts towards yellowish/calcified in geriatric
    final Color aortaColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFFE2A06E) : const Color(0xFFDC2626);
    final Color myocardiumColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFF991B1B) : const Color(0xFFB91C1C);

    // Left Ventricle (LV) & Myocardium
    final lvRadius = (isSoloMode && soloPartKey == 'cardio_lv' ? 62.0 : 45.0) * hypertrophy;
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(18, 25, 0),
      rx: lvRadius * 0.85,
      ry: lvRadius * 1.15,
      rz: lvRadius * 0.9,
      color: myocardiumColor,
      partKey: 'cardio_lv',
      nameEn: 'Left Ventricle & Myocardium',
      nameAr: 'البطين الأيسر وعضلة القلب',
      latSteps: isSoloMode ? 10 : 8,
      lonSteps: isSoloMode ? 16 : 12,
    ));

    // Right Ventricle (RV)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-22, 20, 10),
      rx: 34 * hypertrophy,
      ry: 42 * hypertrophy,
      rz: 30 * hypertrophy,
      color: const Color(0xFF9A3412),
      partKey: 'cardio_rv',
      nameEn: 'Right Ventricle',
      nameAr: 'البطين الأيمن',
      latSteps: 7,
      lonSteps: 10,
    ));

    // Left Atrium (LA)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(15, -28, -12),
      rx: 28,
      ry: 24,
      rz: 25,
      color: const Color(0xFF7F1D1D),
      partKey: 'cardio_la',
      nameEn: 'Left Atrium',
      nameAr: 'الأذين الأيسر',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Right Atrium (RA)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-30, -22, 5),
      rx: 26,
      ry: 28,
      rz: 24,
      color: const Color(0xFF9A3412),
      partKey: 'cardio_ra',
      nameEn: 'Right Atrium',
      nameAr: 'الأذين الأيمن',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Ascending Aorta & Arch
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(5, -15, 0),
      p2: Point3D(0, -65, 0),
      radius: 14 + (calcification * 3.5),
      color: aortaColor,
      partKey: 'cardio_aorta',
      nameEn: 'Ascending Aorta & Root',
      nameAr: 'الشريان الأبهر الصاعد وجذره',
      steps: 10,
    ));
    // Aortic Arch Curve
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(0, -65, 0),
      p2: Point3D(-18, -80, -10),
      radius: 13 + (calcification * 3.0),
      color: aortaColor,
      partKey: 'cardio_aorta',
      nameEn: 'Ascending Aorta & Root',
      nameAr: 'الشريان الأبهر الصاعد وجذره',
      steps: 8,
    ));

    // Pulmonary Trunk & Bifurcation
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-12, -8, 12),
      p2: Point3D(-8, -48, 5),
      radius: 12,
      color: const Color(0xFF0284C7),
      partKey: 'cardio_pulm_trunk',
      nameEn: 'Pulmonary Artery Trunk',
      nameAr: 'جذع الشريان الرئوي',
      steps: 8,
    ));

    // Infant: Patent Ductus Arteriosus (PDA)
    if (isInfant) {
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(-8, -50, 5),
        p2: Point3D(-4, -68, -2),
        radius: 4.5,
        color: const Color(0xFFF59E0B),
        partKey: 'cardio_pda',
        nameEn: 'Patent Ductus Arteriosus (PDA)',
        nameAr: 'القناة الشريانية السالكة (PDA)',
        steps: 6,
      ));
    }

    // Coronary Arteries (LAD, LCx, RCA)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(6, -18, 20),
        Point3D(8, 0, 24),
        Point3D(12, 22, 22),
        Point3D(15, 42, 14),
        Point3D(12, 58, 4),
      ],
      thickness: stage == ClinicalAgeStage.geriatric ? 4.5 : 3.0,
      color: const Color(0xFFEF4444),
      partKey: 'cardio_lad',
      nameEn: 'Left Anterior Descending (LAD)',
      nameAr: 'الشريان التاجي الأيسر النازل (LAD)',
    ));

    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(8, -16, 18),
        Point3D(24, -14, 10),
        Point3D(34, -5, -4),
        Point3D(32, 16, -12),
      ],
      thickness: 2.8,
      color: const Color(0xFFF87171),
      partKey: 'cardio_lcx',
      nameEn: 'Left Circumflex (LCx)',
      nameAr: 'الشريان الدائري المنعطف (LCx)',
    ));

    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-8, -16, 15),
        Point3D(-22, -8, 22),
        Point3D(-28, 12, 20),
        Point3D(-24, 32, 12),
        Point3D(-16, 44, 2),
      ],
      thickness: 3.2,
      color: const Color(0xFFEF4444),
      partKey: 'cardio_rca',
      nameEn: 'Right Coronary Artery (RCA)',
      nameAr: 'الشريان التاجي الأيمن (RCA)',
    ));

    // Valves & Annulus Fibrosus Fibrocartilaginous Rings
    faces.addAll(_buildDiscMesh(
      center: Point3D(4, -16, 5),
      normal: Point3D(0, 1, 0.4).normalized(),
      radius: 11,
      color: stage == ClinicalAgeStage.geriatric ? const Color(0xFFFCD34D) : const Color(0xFFF1F5F9),
      partKey: 'cardio_valves',
      nameEn: 'Mitral & Aortic Valves',
      nameAr: 'الصمامات القلبية (الميترالي والأبهري)',
      steps: 8,
    ));

    // 1. Fibrous & Cartilaginous Skeleton of Heart (Annulus Fibrosus Rings)
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(8, -18, 6),
      p2: Point3D(8, -14, 6),
      radius: 12.0,
      color: const Color(0xFFCBD5E1),
      partKey: 'cardio_fibrous_skeleton',
      nameEn: 'Annulus Fibrosus & Fibrous Skeleton',
      nameAr: 'الهيكل الليفي والغضروفي للقلب (Annulus Fibrosus)',
      steps: 10,
      isWireframe: true,
    ));

    // 2. Mitral Valve Leaflets, Chordae Tendineae & Papillary Muscles
    faces.addAll(_buildPrismMesh(
      p1: Point3D(6, -15, 6),
      p2: Point3D(14, -15, 6),
      p3: Point3D(10, -5, 4),
      depth: 2.0,
      color: const Color(0xFFF8FAFC),
      partKey: 'cardio_mitral_complex',
      nameEn: 'Mitral Valve Leaflets & Chordae',
      nameAr: 'وريقات الصمام الميترالي والأوتار القلبية',
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(10, -5, 4),
        Point3D(14, 8, 4),
        Point3D(16, 20, 2),
      ],
      thickness: 1.6,
      color: const Color(0xFFF1F5F9),
      partKey: 'cardio_mitral_complex',
      nameEn: 'Chordae Tendineae (Heart Strings)',
      nameAr: 'الأوتار القلبية الوترية (Chordae Tendineae)',
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(16, 20, 2),
      p2: Point3D(18, 30, 0),
      radius: 5.5,
      color: myocardiumColor,
      partKey: 'cardio_papillary_muscles',
      nameEn: 'Myocardial Papillary Muscles',
      nameAr: 'العضلات الحليمية البطينية',
      steps: 6,
    ));

    // 3. Tricuspid Valve Complex & Right Ventricle Papillary Muscles
    faces.addAll(_buildDiscMesh(
      center: Point3D(-16, -14, 8),
      normal: Point3D(0.2, 1, 0.2).normalized(),
      radius: 10.0,
      color: const Color(0xFFF1F5F9),
      partKey: 'cardio_tricuspid_valve',
      nameEn: 'Tricuspid Valve Complex',
      nameAr: 'مجمع الصمام ثلاثي الشرفات',
      steps: 6,
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-16, -12, 8),
        Point3D(-20, 4, 8),
        Point3D(-22, 18, 6),
      ],
      thickness: 1.5,
      color: const Color(0xFFE2E8F0),
      partKey: 'cardio_tricuspid_valve',
      nameEn: 'Tricuspid Chordae Tendineae',
      nameAr: 'أوتار الصمام ثلاثي الشرفات',
    ));

    // 4. Aortic & Pulmonary Semilunar Valve Cusps
    faces.addAll(_buildDiscMesh(
      center: Point3D(4, -26, 2),
      normal: Point3D(0, 1, 0).normalized(),
      radius: 8.5,
      color: stage == ClinicalAgeStage.geriatric ? const Color(0xFFFDE68A) : const Color(0xFFF8FAFC),
      partKey: 'cardio_aortic_cusps',
      nameEn: 'Aortic Semilunar Valve Cusps',
      nameAr: 'شرفات الصمام الأبهري الهلالية',
      steps: 6,
    ));

    // 5. Great Cardiac Vein & Coronary Sinus
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(8, 0, 26),
        Point3D(14, 24, 24),
        Point3D(20, 36, 16),
        Point3D(22, 12, -8),
        Point3D(10, -10, -14),
      ],
      thickness: 3.2,
      color: const Color(0xFF3B82F6),
      partKey: 'cardio_coronary_sinus',
      nameEn: 'Great Cardiac Vein & Coronary Sinus',
      nameAr: 'الوريد القلبي الكبير والجيب التاجي',
    ));

    // 6. Cardiac Conduction System (SA Node, AV Node & Bundle of His)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-28, -32, 4),
      rx: 3.5,
      ry: 3.5,
      rz: 3.5,
      color: const Color(0xFFFACC15),
      partKey: 'cardio_conduction_system',
      nameEn: 'Sinoatrial (SA) Pacemaker Node',
      nameAr: 'العقدة الجيبية الأذينية المنظمة (SA Node)',
      latSteps: 4,
      lonSteps: 6,
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-28, -32, 4),
        Point3D(-10, -18, 0),
        Point3D(0, -6, 0),
        Point3D(4, 15, 2),
      ],
      thickness: 1.8,
      color: const Color(0xFFFACC15),
      partKey: 'cardio_conduction_system',
      nameEn: 'AV Node & Bundle of His Pathways',
      nameAr: 'العقدة الأذينية البطينية وحزم هيس الناقلة',
    ));

    // Filter for solo mode if active
    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // CARDIOLOGY 3D MEDICAL INSTRUMENTS
    // ─────────────────────────────────────────────────────────────────────────
    if (instrument == SpecialtyInstrument.coronaryStent) {
      // 3D Metallic Stent Lattice deployed inside LAD
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(10, 8, 24),
        p2: Point3D(14, 32, 18),
        radius: 4.8,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_stent',
        nameEn: 'Drug-Eluting Coronary Stent (DES)',
        nameAr: 'دعامة شريانية دوائية (DES)',
        steps: 12,
        isWireframe: true,
      ));
    } else if (instrument == SpecialtyInstrument.angioplastyBalloon) {
      // 3D Dilated Balloon Catheter
      faces.addAll(_buildEllipsoidMesh(
        center: Point3D(12, 20, 21),
        rx: 5.5,
        ry: 14.0,
        rz: 5.5,
        color: const Color(0xCC38BDF8),
        partKey: 'tool_balloon',
        nameEn: 'Angioplasty Dilatation Balloon',
        nameAr: 'بالون توسيع الشريان التاجي',
        latSteps: 6,
        lonSteps: 8,
      ));
      // Guide wire extending beyond
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(8, -6, 25),
        p2: Point3D(16, 48, 12),
        radius: 0.9,
        color: Colors.white,
        partKey: 'tool_guidewire',
        nameEn: 'Coronary Guide Wire',
        nameAr: 'سلك توجيه القسطرة',
        steps: 4,
      ));
    } else if (instrument == SpecialtyInstrument.tavrValve) {
      // 3D TAVR Valve Stent Frame & Leaflets at Aortic Root
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(4, -24, 4),
        p2: Point3D(2, -6, 6),
        radius: 14.5,
        color: const Color(0xFFFACC15),
        partKey: 'tool_tavr',
        nameEn: 'TAVR Transcatheter Aortic Valve',
        nameAr: 'صمام أبهري عبر القسطرة (TAVR)',
        steps: 12,
        isWireframe: true,
      ));
    } else if (instrument == SpecialtyInstrument.pacemakerLead) {
      // 3D Pacemaker Lead traversing through RA to RV Apex
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          Point3D(-28, -55, 0),
          Point3D(-30, -22, 5),
          Point3D(-26, 0, 12),
          Point3D(-22, 26, 12),
          Point3D(-20, 48, 10),
        ],
        thickness: 2.8,
        color: const Color(0xFF0F172A),
        partKey: 'tool_lead',
        nameEn: 'Pacemaker Transvenous Lead',
        nameAr: 'سلك جهاز تنظيم ضربات القلب',
      ));
      // Fixation tip
      faces.addAll(_buildEllipsoidMesh(
        center: Point3D(-20, 48, 10),
        rx: 3.5,
        ry: 4.5,
        rz: 3.5,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_lead_tip',
        nameEn: 'Lead Active Fixation Tip',
        nameAr: 'رأس تثبيت السلك الكهربائي',
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. PHYSIOTHERAPY & KINETIC MUSCULAR 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildPhysiotherapyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    final double bulk = stage == ClinicalAgeStage.adult
        ? 1.15
        : (stage == ClinicalAgeStage.child ? 0.72 : (stage == ClinicalAgeStage.geriatric ? 0.82 : 1.0));
    final Color muscleColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFF831843) : const Color(0xFFBE123C);
    final Color tendonColor = const Color(0xFFE2E8F0);

    // Trapezius & Cervical Muscles
    faces.addAll(_buildPrismMesh(
      p1: Point3D(-30 * bulk, -75, -5),
      p2: Point3D(30 * bulk, -75, -5),
      p3: Point3D(0, -95, 0),
      depth: 14 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97140',
      nameEn: 'Trapezius & Cervical Musculature',
      nameAr: 'عضلة الترابيزيوس والعنق',
    ));

    // Deltoids (Left & Right)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-46 * bulk, -60, 2),
      rx: 16 * bulk,
      ry: 22 * bulk,
      rz: 15 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97110',
      nameEn: 'Deltoids & Rotator Cuff',
      nameAr: 'عضلات الكتف والكفة المدورة',
      latSteps: 6,
      lonSteps: 8,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(46 * bulk, -60, 2),
      rx: 16 * bulk,
      ry: 22 * bulk,
      rz: 15 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97110',
      nameEn: 'Deltoids & Rotator Cuff',
      nameAr: 'عضلات الكتف والكفة المدورة',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Pectoralis Major & Chest
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-16 * bulk, -48, 12),
      rx: 18 * bulk,
      ry: 15 * bulk,
      rz: 10 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97035',
      nameEn: 'Pectoralis Major & Chest',
      nameAr: 'عضلات الصدر البكتوراليس',
      latSteps: 6,
      lonSteps: 8,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(16 * bulk, -48, 12),
      rx: 18 * bulk,
      ry: 15 * bulk,
      rz: 10 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97035',
      nameEn: 'Pectoralis Major & Chest',
      nameAr: 'عضلات الصدر البكتوراليس',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Biceps & Triceps (Arms)
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-48 * bulk, -46, 0),
      p2: Point3D(-50 * bulk, -12, 0),
      radius: 10 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97014',
      nameEn: 'Biceps & Triceps (Arms)',
      nameAr: 'عضلات البايسبس والترايسبس',
      steps: 8,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(48 * bulk, -46, 0),
      p2: Point3D(50 * bulk, -12, 0),
      radius: 10 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97014',
      nameEn: 'Biceps & Triceps (Arms)',
      nameAr: 'عضلات البايسبس والترايسبس',
      steps: 8,
    ));

    // Rectus Abdominis & Core
    for (int row = 0; row < 3; row++) {
      final yPos = -28.0 + row * 16.0;
      faces.addAll(_buildPrismMesh(
        p1: Point3D(-14 * bulk, yPos, 14),
        p2: Point3D(14 * bulk, yPos, 14),
        p3: Point3D(0, yPos + 12, 14),
        depth: 10 * bulk,
        color: muscleColor,
        partKey: 'physio_PT-97112',
        nameEn: 'Rectus Abdominis & Core',
        nameAr: 'عضلات البطن والجذع (الكور)',
      ));
    }

    // Quadriceps Femoris (Thigh)
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-20 * bulk, 46, 6),
      p2: Point3D(-18 * bulk, 94, 6),
      radius: 14 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97110_quad',
      nameEn: 'Quadriceps Femoris (Thigh)',
      nameAr: 'العضلة رباعية الرؤوس (الفخذ)',
      steps: 8,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(20 * bulk, 46, 6),
      p2: Point3D(18 * bulk, 94, 6),
      radius: 14 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97110_quad',
      nameEn: 'Quadriceps Femoris (Thigh)',
      nameAr: 'العضلة رباعية الرؤوس (الفخذ)',
      steps: 8,
    ));

    // Gastrocnemius & Achilles
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-18 * bulk, 110, -4),
      p2: Point3D(-16 * bulk, 145, -4),
      radius: 12 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97035_gast',
      nameEn: 'Gastrocnemius & Achilles Tendon',
      nameAr: 'عضلة السمانة ووتر أخيل',
      steps: 8,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(18 * bulk, 110, -4),
      p2: Point3D(16 * bulk, 145, -4),
      radius: 12 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97035_gast',
      nameEn: 'Gastrocnemius & Achilles Tendon',
      nameAr: 'عضلة السمانة ووتر أخيل',
      steps: 8,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-16 * bulk, 145, -4),
      p2: Point3D(-15 * bulk, 170, -8),
      radius: 4.5,
      color: tendonColor,
      partKey: 'physio_PT-97035_gast',
      nameEn: 'Gastrocnemius & Achilles Tendon',
      nameAr: 'عضلة السمانة ووتر أخيل',
      steps: 6,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(16 * bulk, 145, -4),
      p2: Point3D(15 * bulk, 170, -8),
      radius: 4.5,
      color: tendonColor,
      partKey: 'physio_PT-97035_gast',
      nameEn: 'Gastrocnemius & Achilles Tendon',
      nameAr: 'عضلة السمانة ووتر أخيل',
      steps: 6,
    ));

    // 1. Quadriceps & Patellar Tendon Complex
    faces.addAll(_buildPrismMesh(
      p1: Point3D(-22 * bulk, 94, 6),
      p2: Point3D(-14 * bulk, 94, 6),
      p3: Point3D(-18 * bulk, 108, 6),
      depth: 3.5,
      color: tendonColor,
      partKey: 'physio_patellar_tendon',
      nameEn: 'Patellar Tendon & Ligament',
      nameAr: 'وتر الرضفة والرباط الرضفي',
    ));
    faces.addAll(_buildPrismMesh(
      p1: Point3D(14 * bulk, 94, 6),
      p2: Point3D(22 * bulk, 94, 6),
      p3: Point3D(18 * bulk, 108, 6),
      depth: 3.5,
      color: tendonColor,
      partKey: 'physio_patellar_tendon',
      nameEn: 'Patellar Tendon & Ligament',
      nameAr: 'وتر الرضفة والرباط الرضفي',
    ));

    // 2. Biceps & Triceps Tendinous Insertions
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-50 * bulk, -12, 0),
        Point3D(-52 * bulk, 4, 0),
      ],
      thickness: 3.2,
      color: tendonColor,
      partKey: 'physio_arm_tendons',
      nameEn: 'Biceps & Triceps Distal Tendons',
      nameAr: 'أوتار البايسبس والترايسبس الطرفية',
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(50 * bulk, -12, 0),
        Point3D(52 * bulk, 4, 0),
      ],
      thickness: 3.2,
      color: tendonColor,
      partKey: 'physio_arm_tendons',
      nameEn: 'Biceps & Triceps Distal Tendons',
      nameAr: 'أوتار البايسبس والترايسبس الطرفية',
    ));

    // 3. Knee Joint Meniscus Fibrocartilage Pads (Medial & Lateral Menisci)
    faces.addAll(_buildDiscMesh(
      center: Point3D(-18 * bulk, 102, 3),
      normal: const Point3D(0, 1, 0),
      radius: 9.5 * bulk,
      color: const Color(0xFF38BDF8),
      partKey: 'physio_knee_menisci',
      nameEn: 'Knee Meniscus Cartilages (Medial & Lateral)',
      nameAr: 'الغضاريف الهلالية لمفصل الركبة (الإنسي والوحشي)',
      steps: 8,
    ));
    faces.addAll(_buildDiscMesh(
      center: Point3D(18 * bulk, 102, 3),
      normal: const Point3D(0, 1, 0),
      radius: 9.5 * bulk,
      color: const Color(0xFF38BDF8),
      partKey: 'physio_knee_menisci',
      nameEn: 'Knee Meniscus Cartilages (Medial & Lateral)',
      nameAr: 'الغضاريف الهلالية لمفصل الركبة (الإنسي والوحشي)',
      steps: 8,
    ));

    // 4. Intervertebral Fibrocartilaginous Discs
    for (double discY = -60.0; discY <= 20.0; discY += 15.0) {
      faces.addAll(_buildDiscMesh(
        center: Point3D(0, discY, -4),
        normal: const Point3D(0, 1, 0),
        radius: 8.0 * bulk,
        color: const Color(0xFF7DD3FC),
        partKey: 'physio_spinal_discs',
        nameEn: 'Intervertebral Cartilage Discs',
        nameAr: 'الأقراص الغضروفية بين الفقرات',
        steps: 6,
      ));
    }

    // 5. Costal Cartilages (Anterior Ribcage Chondral Junctions)
    for (double ribY = -65.0; ribY <= -35.0; ribY += 10.0) {
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          Point3D(-24 * bulk, ribY, 6),
          Point3D(0, ribY + 2, 8),
          Point3D(24 * bulk, ribY, 6),
        ],
        thickness: 2.4,
        color: const Color(0xFFBAE6FD),
        partKey: 'physio_costal_cartilages',
        nameEn: 'Costal Cartilage Ribcage Arches',
        nameAr: 'الغضاريف الضلعية للقفص الصدري',
      ));
    }

    // 6. Iliotibial (IT) Band & Fascia Lata
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-32 * bulk, 42, 2),
        Point3D(-30 * bulk, 70, 4),
        Point3D(-26 * bulk, 100, 3),
      ],
      thickness: 5.5,
      color: const Color(0xFFE2E8F0),
      partKey: 'physio_it_band',
      nameEn: 'Iliotibial (IT) Band & Fascia Lata',
      nameAr: 'الشريط الحرقفي الظنبوبي (IT Band) واللفافة',
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(32 * bulk, 42, 2),
        Point3D(30 * bulk, 70, 4),
        Point3D(26 * bulk, 100, 3),
      ],
      thickness: 5.5,
      color: const Color(0xFFE2E8F0),
      partKey: 'physio_it_band',
      nameEn: 'Iliotibial (IT) Band & Fascia Lata',
      nameAr: 'الشريط الحرقفي الظنبوبي (IT Band) واللفافة',
    ));

    // 7. Thoracolumbar Fascia & Lumbar Aponeurosis
    faces.addAll(_buildPrismMesh(
      p1: Point3D(-16 * bulk, -10, -8),
      p2: Point3D(16 * bulk, -10, -8),
      p3: Point3D(0, 25, -6),
      depth: 2.0,
      color: const Color(0xFFF1F5F9),
      partKey: 'physio_thoracolumbar_fascia',
      nameEn: 'Thoracolumbar Fascia Aponeurosis',
      nameAr: 'اللفافة الصدرية القطنية ولجام الظهر',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // PHYSIOTHERAPY 3D MEDICAL INSTRUMENTS
    // ─────────────────────────────────────────────────────────────────────────
    if (instrument == SpecialtyInstrument.kinesioTape) {
      // 3D Kinesiology Elastic Tape applied across Deltoid / Quads
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          Point3D(34 * bulk, -74, 12),
          Point3D(46 * bulk, -60, 18),
          Point3D(50 * bulk, -38, 12),
        ],
        thickness: 8.0,
        color: const Color(0xFF06B6D4), // vibrant blue athletic tape
        partKey: 'tool_tape',
        nameEn: 'Kinesiology Therapeutic Tape Strip',
        nameAr: 'شريط الكينيسيولوجي الحركي اللاصق',
      ));
    } else if (instrument == SpecialtyInstrument.dryNeedle) {
      // 3D Stainless Steel Filiform Dry Needling Pin inserted into trigger point
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(46 * bulk, -60, 35),
        p2: Point3D(46 * bulk, -60, 10),
        radius: 0.8,
        color: Colors.white,
        partKey: 'tool_needle',
        nameEn: 'Dry Needling Pin Shaft',
        nameAr: 'إبرة جافة علاجية',
        steps: 6,
      ));
      // Copper coil handle
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(46 * bulk, -60, 48),
        p2: Point3D(46 * bulk, -60, 35),
        radius: 2.0,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_needle_handle',
        nameEn: 'Needle Copper Handle',
        nameAr: 'مقبض الإبرة النحاسي',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.cuppingDome) {
      // 3D Transparent Vacuum Cupping Dome
      faces.addAll(_buildEllipsoidMesh(
        center: Point3D(0, -78, 12),
        rx: 14.0,
        ry: 14.0,
        rz: 12.0,
        color: const Color(0x7738BDF8),
        partKey: 'tool_cup',
        nameEn: 'Therapeutic Cupping Dome',
        nameAr: 'كأس حجامة مفرغ من الهواء',
        latSteps: 6,
        lonSteps: 8,
      ));
      // Top vacuum valve
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(0, -78, 22),
        p2: Point3D(0, -78, 28),
        radius: 3.5,
        color: const Color(0xFFEF4444),
        partKey: 'tool_cup_valve',
        nameEn: 'Cupping Release Valve',
        nameAr: 'صمام التفريغ',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.tensPad) {
      // Dual TENS Hydrogel Electrotherapy Pads
      faces.addAll(_buildBoxMesh(
        center: Point3D(18 * bulk, 60, 20),
        dx: 14,
        dy: 20,
        dz: 2.5,
        color: const Color(0xFF1E293B),
        partKey: 'tool_tens',
        nameEn: 'TENS Electrode Hydrogel Pad',
        nameAr: 'لصقة التحفيز الكهربائي TENS',
      ));
      faces.addAll(_buildBoxMesh(
        center: Point3D(18 * bulk, 85, 20),
        dx: 14,
        dy: 20,
        dz: 2.5,
        color: const Color(0xFF1E293B),
        partKey: 'tool_tens',
        nameEn: 'TENS Electrode Hydrogel Pad',
        nameAr: 'لصقة التحفيز الكهربائي TENS',
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. GASTROENTEROLOGY & DIGESTIVE SYSTEM 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildGastroenterologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    final double stomachTilt = stage == ClinicalAgeStage.infant ? 0.45 : 0.15;
    final Color stomachColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFFD97706) : const Color(0xFFF59E0B);

    // Esophagus
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(0, -95, -5),
      p2: Point3D(-6, -42, 0),
      radius: 7.0,
      color: const Color(0xFFFB923C),
      partKey: 'gi_GI-43235',
      nameEn: 'Esophagus (المريء)',
      nameAr: 'المريء وقاع المعدة',
      steps: 8,
    ));

    // Stomach
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-18, -25 + (stomachTilt * 20), 8),
      rx: isSoloMode && soloPartKey == 'gi_GI-43239' ? 38 : 28,
      ry: isSoloMode && soloPartKey == 'gi_GI-43239' ? 34 : 24,
      rz: isSoloMode && soloPartKey == 'gi_GI-43239' ? 28 : 20,
      color: stomachColor,
      partKey: 'gi_GI-43239',
      nameEn: 'Stomach (المعدة)',
      nameAr: 'المعدة والحرقة الهضمية',
      latSteps: 8,
      lonSteps: 12,
    ));

    // Duodenum C-Loop
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-4, -18, 10),
        Point3D(14, -14, 8),
        Point3D(18, 0, 6),
        Point3D(8, 14, 4),
        Point3D(-8, 12, 2),
      ],
      thickness: 8.0,
      color: const Color(0xFFFBBF24),
      partKey: 'gi_GI-44360',
      nameEn: 'Duodenum & Small Bowel',
      nameAr: 'الاثني عشر والأمعاء الدقيقة',
    ));

    // Liver
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(26, -35, 12),
      rx: 34,
      ry: 26,
      rz: 24,
      color: const Color(0xFF991B1B),
      partKey: 'gi_GI-47000',
      nameEn: 'Liver (الكبد)',
      nameAr: 'الكبد والإنزيمات الكبدية',
      latSteps: 7,
      lonSteps: 10,
    ));

    // Gallbladder
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(18, -18, 22),
      rx: 8,
      ry: 14,
      rz: 8,
      color: const Color(0xFF16A34A),
      partKey: 'gi_GI-47562',
      nameEn: 'Gallbladder & Biliary Tree',
      nameAr: 'المرارة والقنوات المرارية',
      latSteps: 5,
      lonSteps: 8,
    ));

    // Pancreas
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(12, -4, -4),
      p2: Point3D(-24, -10, -2),
      radius: 6.5,
      color: const Color(0xFFEAB308),
      partKey: 'gi_GI-43260',
      nameEn: 'Pancreas (البنكرياس)',
      nameAr: 'البنكرياس والإنزيمات الهاضمة',
      steps: 7,
    ));

    // Colon
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(34, 45, 0),
      p2: Point3D(34, -5, 0),
      radius: 11,
      color: const Color(0xFFD97706),
      partKey: 'gi_GI-45385',
      nameEn: 'Large Intestines (Colon)',
      nameAr: 'القولون والأمعاء الغليظة',
      steps: 8,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(34, -5, 0),
      p2: Point3D(-34, -8, 0),
      radius: 11,
      color: const Color(0xFFD97706),
      partKey: 'gi_GI-45385',
      nameEn: 'Large Intestines (Colon)',
      nameAr: 'القولون والأمعاء الغليظة',
      steps: 8,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-34, -8, 0),
      p2: Point3D(-34, 42, 0),
      radius: 11,
      color: const Color(0xFFD97706),
      partKey: 'gi_GI-45385',
      nameEn: 'Large Intestines (Colon)',
      nameAr: 'القولون والأمعاء الغليظة',
      steps: 8,
    ));

    // Appendix
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(34, 52, 2),
      rx: 12,
      ry: 12,
      rz: 10,
      color: const Color(0xFFB45309),
      partKey: 'gi_GI-44970',
      nameEn: 'Appendix & Cecum',
      nameAr: 'الزائدة الدودية والأعور',
      latSteps: 5,
      lonSteps: 7,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(34, 58, 2),
      p2: Point3D(38, 76, 6),
      radius: 3.5,
      color: const Color(0xFFEF4444),
      partKey: 'gi_GI-44970',
      nameEn: 'Appendix & Cecum',
      nameAr: 'الزائدة الدودية والأعور',
      steps: 6,
    ));

    // 1. Biliary Duct Tree (Hepatic Ducts, Cystic Duct & Common Bile Duct)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(22, -30, 16),
        Point3D(20, -22, 18),
        Point3D(16, -12, 14),
        Point3D(12, 0, 8),
      ],
      thickness: 3.4,
      color: const Color(0xFF16A34A),
      partKey: 'gi_biliary_duct_tree',
      nameEn: 'Biliary Tree & Common Bile Duct (CBD)',
      nameAr: 'شجرة القنوات المرارية والقناة الصفراوية العامة (CBD)',
    ));

    // 2. Main Pancreatic Duct of Wirsung
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-20, -10, -1),
        Point3D(-6, -6, -2),
        Point3D(8, -2, 2),
        Point3D(12, 0, 8),
      ],
      thickness: 2.2,
      color: const Color(0xFFFDE047),
      partKey: 'gi_pancreatic_duct',
      nameEn: 'Main Pancreatic Duct of Wirsung',
      nameAr: 'القناة البنكرياسية الرئيسية (Wirsung)',
    ));

    // 3. Ampulla of Vater & Sphincter of Oddi
    faces.addAll(_buildDiscMesh(
      center: Point3D(12, 0, 8),
      normal: const Point3D(-1, 0, 1).normalized(),
      radius: 5.5,
      color: const Color(0xFFEA580C),
      partKey: 'gi_sphincter_oddi',
      nameEn: 'Ampulla of Vater & Sphincter of Oddi',
      nameAr: 'أمبولة فاتر وعضلة أودي العاصرة (Sphincter of Oddi)',
      steps: 8,
    ));

    // 4. Lower Esophageal Sphincter (LES) & Pyloric Sphincter Rings
    faces.addAll(_buildDiscMesh(
      center: Point3D(-6, -42, 0),
      normal: const Point3D(0, 1, 0),
      radius: 8.5,
      color: const Color(0xFFFB923C),
      partKey: 'gi_les_sphincter',
      nameEn: 'Lower Esophageal Sphincter (LES)',
      nameAr: 'العاصرة المريئية السفلية (LES)',
      steps: 8,
    ));
    faces.addAll(_buildDiscMesh(
      center: Point3D(-4, -18, 10),
      normal: const Point3D(1, 0, 0),
      radius: 9.0,
      color: const Color(0xFFF97316),
      partKey: 'gi_pyloric_sphincter',
      nameEn: 'Pyloric Sphincter Muscular Ring',
      nameAr: 'عضلة البواب العاصرة (Pyloric Sphincter)',
      steps: 8,
    ));

    // 5. Ileocecal Valve & Mesoappendix Ligament
    faces.addAll(_buildDiscMesh(
      center: Point3D(34, 46, 2),
      normal: const Point3D(0, 1, 0),
      radius: 8.0,
      color: const Color(0xFFEA580C),
      partKey: 'gi_ileocecal_valve',
      nameEn: 'Ileocecal Valve (Sphincter of Bauhin)',
      nameAr: 'الصمام الدقاقي الأعوري (Bauhin)',
      steps: 6,
    ));
    faces.addAll(_buildPrismMesh(
      p1: Point3D(34, 58, 2),
      p2: Point3D(38, 76, 6),
      p3: Point3D(32, 68, 0),
      depth: 1.5,
      color: const Color(0xFFFDE047),
      partKey: 'gi_peritoneal_ligaments',
      nameEn: 'Mesoappendix & Peritoneal Ligaments',
      nameAr: 'مساريقا الزائدة الدودية والأربطة البريتونية',
    ));

    // 6. Gastric Rugae Mucosal Longitudinal Folds
    for (int r = -1; r <= 1; r++) {
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          Point3D(-14 + r * 6.0, -32, 10),
          Point3D(-18 + r * 5.0, -22, 12),
          Point3D(-16 + r * 4.0, -12, 10),
        ],
        thickness: 2.0,
        color: const Color(0xFFD97706),
        partKey: 'gi_gastric_rugae',
        nameEn: 'Gastric Rugae Mucosal Folds',
        nameAr: 'ثنيات الغشاء المخاطي للمعدة (Rugae)',
      ));
    }

    // 7. Taeniae Coli & Haustra Bands of Colon
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(35, 45, 5),
        Point3D(35, -5, 5),
        Point3D(-34, -8, 5),
        Point3D(-34, 42, 5),
      ],
      thickness: 3.5,
      color: const Color(0xFF92400E),
      partKey: 'gi_taeniae_coli',
      nameEn: 'Taeniae Coli Longitudinal Muscular Bands',
      nameAr: 'أشرطة القولون الطولية (Taeniae Coli)',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // GASTROENTEROLOGY 3D MEDICAL INSTRUMENTS
    // ─────────────────────────────────────────────────────────────────────────
    if (instrument == SpecialtyInstrument.biopsyForceps) {
      // 3D Endoscopic Biopsy Forceps with opening dual-jaw cups inside the stomach
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(-4, -60, 20),
        p2: Point3D(-14, -28, 12),
        radius: 1.8,
        color: const Color(0xFF94A3B8),
        partKey: 'tool_forceps_catheter',
        nameEn: 'Endoscope Flexible Biopsy Catheter',
        nameAr: 'قسطرة ملقط الخزعة المرنة',
        steps: 6,
      ));
      // Biopsy jaws
      faces.addAll(_buildEllipsoidMesh(
        center: Point3D(-14, -28, 12),
        rx: 4.0,
        ry: 4.5,
        rz: 3.0,
        color: const Color(0xFFE2E8F0),
        partKey: 'tool_forceps_jaw',
        nameEn: 'Fenestrated Biopsy Jaws',
        nameAr: 'فكي الملقط لأخذ العينة',
        latSteps: 5,
        lonSteps: 7,
      ));
    } else if (instrument == SpecialtyInstrument.hemoclip) {
      // 3D Titanium Hemostatic Endoclip deployed to stop bleeding
      faces.addAll(_buildBoxMesh(
        center: Point3D(-18, -25, 26),
        dx: 6.0,
        dy: 9.0,
        dz: 3.0,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_clip',
        nameEn: 'Titanium Hemostatic Endoclip',
        nameAr: 'كليب تيتانيوم لوقف النزيف الهضمي',
      ));
    } else if (instrument == SpecialtyInstrument.biliaryStent) {
      // 3D Self-Expanding Nitinol Biliary Stent placed in biliary tree
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(18, -14, 22),
        p2: Point3D(14, -4, 12),
        radius: 4.2,
        color: const Color(0xFFFCD34D),
        partKey: 'tool_biliary_stent',
        nameEn: 'Biliary Expandable Metallic Stent',
        nameAr: 'دعامة القنوات المرارية الشبكية',
        steps: 8,
        isWireframe: true,
      ));
    } else if (instrument == SpecialtyInstrument.laparoscopicTrocar) {
      // 3D Laparoscopic Trocar Cannula Port entering the abdominal cavity
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(0, 10, 45),
        p2: Point3D(0, 10, 15),
        radius: 6.0,
        color: const Color(0xFF0F172A),
        partKey: 'tool_trocar',
        nameEn: 'Laparoscopic Optical Trocar Port',
        nameAr: 'مدخل جراحة المنظار (تروكار 10 ملم)',
        steps: 8,
      ));
      // Valve head
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(0, 10, 45),
        p2: Point3D(0, 10, 52),
        radius: 9.0,
        color: const Color(0xFF0284C7),
        partKey: 'tool_trocar_head',
        nameEn: 'Trocar Gas Insufflation Valve',
        nameAr: 'صمام نفخ الغاز للتروكار',
        steps: 8,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. DERMATOLOGY & SKIN CROSS-SECTION 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildDermatologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    final double epidermalThickness = stage == ClinicalAgeStage.infant ? 4.0 : (stage == ClinicalAgeStage.geriatric ? 5.0 : 8.0);
    final double dermalThickness = stage == ClinicalAgeStage.geriatric ? 28.0 : (stage == ClinicalAgeStage.child ? 30.0 : 42.0);
    final double fatThickness = stage == ClinicalAgeStage.geriatric ? 22.0 : (stage == ClinicalAgeStage.infant ? 38.0 : 32.0);

    final double width = 110.0;
    final double depth = 70.0;

    // 1. Stratum Corneum & Epidermis
    final Color epiColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFFE2C9B8) : const Color(0xFFFBCFE8);
    faces.addAll(_buildBoxMesh(
      center: Point3D(0, -dermalThickness * 0.5 - epidermalThickness * 0.5, 0),
      dx: width,
      dy: epidermalThickness,
      dz: depth,
      color: epiColor,
      partKey: 'derma_face',
      nameEn: 'Epidermis & Stratum Corneum',
      nameAr: 'البشرة والطبقة القرنية الخارجية',
    ));

    // 2. Dermis
    final Color dermColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFFF472B6) : const Color(0xFFEC4899);
    faces.addAll(_buildBoxMesh(
      center: Point3D(0, 0, 0),
      dx: width,
      dy: dermalThickness,
      dz: depth,
      color: dermColor,
      partKey: 'derma_trunk',
      nameEn: 'Dermis Layer & Collagen Matrix',
      nameAr: 'الأدمة وشبكة الكولاجين والألياف',
    ));

    // 3. Hypodermis / Subcutaneous Fat
    final Color fatColor = const Color(0xFFFDE047);
    faces.addAll(_buildBoxMesh(
      center: Point3D(0, dermalThickness * 0.5 + fatThickness * 0.5, 0),
      dx: width,
      dy: fatThickness,
      dz: depth,
      color: fatColor,
      partKey: 'derma_legs',
      nameEn: 'Hypodermis & Subcutaneous Adipose',
      nameAr: 'طبقة تحت الجلد والنسيج الشحمي',
    ));

    // 4. Hair Follicle
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-16, -dermalThickness * 0.5 - 28, 0),
      p2: Point3D(-12, dermalThickness * 0.4, 0),
      radius: 3.5,
      color: stage == ClinicalAgeStage.geriatric ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B),
      partKey: 'derma_scalp',
      nameEn: 'Scalp & Hair Follicles',
      nameAr: 'فروة الرأس وبصيلات الشعر',
      steps: 8,
    ));

    // 5. Sebaceous Gland
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-4, -dermalThickness * 0.1, 4),
      rx: 8,
      ry: 9,
      rz: 7,
      color: const Color(0xFFFACC15),
      partKey: 'derma_arms',
      nameEn: 'Sebaceous Gland & Sebum',
      nameAr: 'الغدد الدهنية وإفراز الزهم',
      latSteps: 5,
      lonSteps: 7,
    ));

    // 1. Dermal-Epidermal Junction with Undulating Rete Ridges & Dermal Papillae
    for (double rx = -width * 0.4; rx <= width * 0.4; rx += 14.0) {
      faces.addAll(_buildPrismMesh(
        p1: Point3D(rx - 5.0, -dermalThickness * 0.5, -depth * 0.35),
        p2: Point3D(rx + 5.0, -dermalThickness * 0.5, -depth * 0.35),
        p3: Point3D(rx, -dermalThickness * 0.5 - 5.0, -depth * 0.35),
        depth: depth * 0.7,
        color: const Color(0xFFFDA4AF),
        partKey: 'derm_rete_ridges',
        nameEn: 'Dermal Papillae & Epidermal Rete Ridges',
        nameAr: 'الحليمات الأدمية وثنيات البشرة المتداخلة (Rete Ridges)',
      ));
    }

    // 2. Stratum Corneum Keratinized Outer Barrier
    faces.addAll(_buildBoxMesh(
      center: Point3D(0, -dermalThickness * 0.5 - epidermalThickness - 1.2, 0),
      dx: width * 0.98,
      dy: 2.2,
      dz: depth * 0.98,
      color: const Color(0xFFFED7AA),
      partKey: 'derm_stratum_corneum',
      nameEn: 'Stratum Corneum Keratin Layer',
      nameAr: 'الطبقة القرنية الكيراتينية الحامية',
    ));

    // 3. Subcutaneous Adipose Lobules with Collagenous Septa
    for (int col = -2; col <= 2; col++) {
      final cx = col * 20.0;
      faces.addAll(_buildEllipsoidMesh(
        center: Point3D(cx, dermalThickness * 0.5 + fatThickness * 0.5, 0),
        rx: 8.5,
        ry: fatThickness * 0.38,
        rz: 10.0,
        color: const Color(0xFFFEF08A),
        partKey: 'derm_adipose_septa',
        nameEn: 'Adipose Fat Lobule & Septa',
        nameAr: 'فصوص النسيج الدهني والحواجز الليفية',
        latSteps: 4,
        lonSteps: 6,
      ));
      // Interlobular Collagenous Septa Wall
      faces.addAll(_buildBoxMesh(
        center: Point3D(cx + 10.0, dermalThickness * 0.5 + fatThickness * 0.5, 0),
        dx: 2.0,
        dy: fatThickness * 0.85,
        dz: depth * 0.6,
        color: const Color(0xFFF1F5F9),
        partKey: 'derm_adipose_septa',
        nameEn: 'Fibrous Collagen Retinacula Septa',
        nameAr: 'الحواجز الكولاجينية الليفية تحت الجلد',
      ));
    }

    // 4. Cutaneous Sensory Receptors (Meissner & Pacinian Corpuscles)
    // Meissner Corpuscle (touch receptor inside dermal papilla)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(12, -dermalThickness * 0.45, 10),
      rx: 3.5,
      ry: 5.0,
      rz: 3.5,
      color: const Color(0xFF38BDF8),
      partKey: 'derm_sensory_receptors',
      nameEn: "Meissner's Tactile Touch Corpuscle",
      nameAr: 'جسيم مايسنر الحسي اللمسي (Meissner Corpuscle)',
      latSteps: 4,
      lonSteps: 6,
    ));
    // Pacinian Corpuscle (lamellated deep pressure receptor in deep dermis/hypodermis)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(28, dermalThickness * 0.45, -12),
      rx: 6.5,
      ry: 9.0,
      rz: 6.5,
      color: const Color(0xFFA855F7),
      partKey: 'derm_sensory_receptors',
      nameEn: "Pacinian Lamellated Vibration Corpuscle",
      nameAr: 'جسيم باتشيني البصلي لضغط واهتزاز الجلد (Pacinian)',
      latSteps: 5,
      lonSteps: 8,
    ));

    // 5. Dermal Microvascular Capillary Loops & Plexus
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-24, dermalThickness * 0.35, 12),
        Point3D(-24, -dermalThickness * 0.45, 12),
        Point3D(-20, -dermalThickness * 0.45, 12),
      ],
      thickness: 1.6,
      color: const Color(0xFFEF4444), // Arterial loop
      partKey: 'derm_microvascular_plexus',
      nameEn: 'Papillary Dermal Capillary Loop (Arterial)',
      nameAr: 'العروة الشعرية الشريانية في حليمات الأدمة',
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-20, -dermalThickness * 0.45, 12),
        Point3D(-20, dermalThickness * 0.35, 12),
      ],
      thickness: 1.6,
      color: const Color(0xFF3B82F6), // Venous loop
      partKey: 'derm_microvascular_plexus',
      nameEn: 'Papillary Dermal Capillary Loop (Venous)',
      nameAr: 'العروة الشعرية الوريدية في حليمات الأدمة',
    ));

    // 6. Arrector Pili Smooth Muscle Band
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-14, -dermalThickness * 0.42, 2),
        Point3D(-22, -dermalThickness * 0.1, 0),
        Point3D(-14, dermalThickness * 0.25, 0),
      ],
      thickness: 3.0,
      color: const Color(0xFFDC2626),
      partKey: 'derm_arrector_pili',
      nameEn: 'Arrector Pili Smooth Muscle',
      nameAr: 'العضلة الناصبة للشعرة (Arrector Pili)',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // ─────────────────────────────────────────────────────────────────────────
    // DERMATOLOGY 3D MEDICAL INSTRUMENTS
    // ─────────────────────────────────────────────────────────────────────────
    if (instrument == SpecialtyInstrument.punchBiopsy) {
      // 3D 4mm Circular Trephine Punch Biopsy coring through epidermis into dermis
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(18, -dermalThickness * 0.5 - 32, 0),
        p2: Point3D(18, dermalThickness * 0.3, 0),
        radius: 6.0,
        color: const Color(0xFFCBD5E1),
        partKey: 'tool_punch',
        nameEn: '4mm Circular Punch Biopsy Trephine',
        nameAr: 'مشرط أخذ الخزعة الجلدية الأنبوبية (Punch 4mm)',
        steps: 10,
        isWireframe: true,
      ));
    } else if (instrument == SpecialtyInstrument.intradermalSuture) {
      // 3D Surgical Monofilament Nylon Suture Loops
      for (int i = -1; i <= 1; i++) {
        final zOffset = i * 16.0;
        faces.addAll(_buildTubeRibbonMesh(
          points: [
            Point3D(-8, -dermalThickness * 0.5 - 2, zOffset),
            Point3D(-4, -dermalThickness * 0.5 - 6, zOffset),
            Point3D(0, -dermalThickness * 0.5 - 8, zOffset),
            Point3D(4, -dermalThickness * 0.5 - 6, zOffset),
            Point3D(8, -dermalThickness * 0.5 - 2, zOffset),
          ],
          thickness: 2.0,
          color: const Color(0xFF2563EB), // surgical blue nylon
          partKey: 'tool_suture',
          nameEn: 'Surgical Suture Loop',
          nameAr: 'غرزة جراحية تجميلية',
        ));
      }
    } else if (instrument == SpecialtyInstrument.cryoSpray) {
      // 3D Liquid Nitrogen Cryo-Spray Delivery Nozzle & Ice Plume Cone
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(0, -dermalThickness * 0.5 - 40, 20),
        p2: Point3D(0, -dermalThickness * 0.5 - 18, 10),
        radius: 2.2,
        color: const Color(0xFF0284C7),
        partKey: 'tool_cryo_nozzle',
        nameEn: 'Cryospray Liquid Nitrogen Nozzle',
        nameAr: 'فوهة بخاخ التجميد بالنيتروجين',
        steps: 6,
      ));
      // Frost Cone
      faces.addAll(_buildEllipsoidMesh(
        center: Point3D(0, -dermalThickness * 0.5 - 2, 0),
        rx: 14.0,
        ry: 4.0,
        rz: 14.0,
        color: const Color(0xCCBAE6FD),
        partKey: 'tool_cryo_frost',
        nameEn: 'Cryogenic Frozen Ice Halo',
        nameAr: 'هالة التجميد الكريوجيني',
        latSteps: 5,
        lonSteps: 8,
      ));
    } else if (instrument == SpecialtyInstrument.microneedle) {
      // 3D Microneedling Roller Head
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(-24, -dermalThickness * 0.5 - 12, 0),
        p2: Point3D(24, -dermalThickness * 0.5 - 12, 0),
        radius: 8.0,
        color: const Color(0xFF64748B),
        partKey: 'tool_roller',
        nameEn: 'Microneedling Dermaroller Barrel',
        nameAr: 'أسطوانة الوخز الدقيق (Dermaroller)',
        steps: 8,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. NEUROLOGY & NEUROSURGERY 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildNeurologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];
    final double scale = stage == ClinicalAgeStage.infant ? 0.75 : (stage == ClinicalAgeStage.geriatric ? 0.92 : 1.0);
    final Color cortexColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFF9333EA) : const Color(0xFF8B5CF6);

    // Cerebral Hemispheres (Left & Right)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-24 * scale, -10, 0),
      rx: 34 * scale,
      ry: 45 * scale,
      rz: 38 * scale,
      color: cortexColor,
      partKey: 'neuro_cortex',
      nameEn: 'Left Cerebral Hemisphere & Lobes',
      nameAr: 'نصف الكرة المخية الأيسر وفصوص القشرة',
      latSteps: 7,
      lonSteps: 10,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(24 * scale, -10, 0),
      rx: 34 * scale,
      ry: 45 * scale,
      rz: 38 * scale,
      color: cortexColor,
      partKey: 'neuro_cortex',
      nameEn: 'Right Cerebral Hemisphere & Lobes',
      nameAr: 'نصف الكرة المخية الأيمن وفصوص القشرة',
      latSteps: 7,
      lonSteps: 10,
    ));

    // Ventricular System & CSF
    final double ventScale = stage == ClinicalAgeStage.geriatric ? 1.35 : 1.0;
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-10, -5, 0),
      rx: 8 * ventScale,
      ry: 18 * ventScale,
      rz: 10 * ventScale,
      color: const Color(0xFF38BDF8),
      partKey: 'neuro_ventricles',
      nameEn: 'Lateral Ventricles & CSF Fluid',
      nameAr: 'البطينات الدماغية وسائله الشوكي',
      latSteps: 5,
      lonSteps: 7,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(10, -5, 0),
      rx: 8 * ventScale,
      ry: 18 * ventScale,
      rz: 10 * ventScale,
      color: const Color(0xFF38BDF8),
      partKey: 'neuro_ventricles',
      nameEn: 'Lateral Ventricles & CSF Fluid',
      nameAr: 'البطينات الدماغية وسائله الشوكي',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Deep Basal Ganglia & Thalamus
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(0, 8, 2),
      rx: 14 * scale,
      ry: 12 * scale,
      rz: 14 * scale,
      color: const Color(0xFFF59E0B),
      partKey: 'neuro_basal_ganglia',
      nameEn: 'Deep Basal Ganglia & Subthalamic Nucleus',
      nameAr: 'العقد القاعدية والمهاد والنواة تحت المهادية',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Brainstem & Cranial Nerves (I-XII)
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(0, 15, -4),
      p2: Point3D(0, 65, -8),
      radius: 12 * scale,
      color: const Color(0xFFE2E8F0),
      partKey: 'neuro_cranial_nerves',
      nameEn: 'Brainstem & Cranial Nerves (I–XII)',
      nameAr: 'جذع المخ والأعصاب القحفية (I–XII)',
      steps: 8,
    ));

    // Circle of Willis Arterial Ring
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-14, 20, 10),
        Point3D(0, 18, 16),
        Point3D(14, 20, 10),
        Point3D(10, 24, -2),
        Point3D(-10, 24, -2),
        Point3D(-14, 20, 10),
      ],
      thickness: 3.2,
      color: const Color(0xFFEF4444),
      partKey: 'neuro_circle_of_willis',
      nameEn: 'Circle of Willis Cerebral Arteries',
      nameAr: 'حلقة ويليس الشريانية الدماغية',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.stereotacticBurrhole) {
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(20, -45, 15),
        p2: Point3D(20, -55, 15),
        radius: 7.0,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_burrhole',
        nameEn: 'Stereotactic Burr Hole & Trephine Ring',
        nameAr: 'ثقب الجمجمة الجراحي وحلقة التوجيه التجسيمي',
        steps: 8,
        isWireframe: true,
      ));
    } else if (instrument == SpecialtyInstrument.dbsElectrode) {
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(15, -50, 12),
        p2: Point3D(4, 10, 2),
        radius: 1.2,
        color: const Color(0xFFFCD34D),
        partKey: 'tool_dbs_lead',
        nameEn: 'Deep Brain Stimulation (DBS) Quadripolar Lead',
        nameAr: 'قطب التحفيز الدماغي العميق DBS',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.aneurysmClip) {
      faces.addAll(_buildBoxMesh(
        center: Point3D(0, 18, 18),
        dx: 6.0,
        dy: 8.0,
        dz: 3.0,
        color: const Color(0xFFCBD5E1),
        partKey: 'tool_aneurysm_clip',
        nameEn: 'Titanium Cerebral Aneurysm Micro-Clip',
        nameAr: 'كليب تيتانيوم لتمدد الشرايين الدماغية',
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6. NEURO-OTOLOGY & BALANCE 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildNeuroOtologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    // Semicircular Canals (Posterior, Anterior, Lateral)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-25, -25, 0),
        Point3D(-35, -45, 10),
        Point3D(-15, -55, 15),
        Point3D(5, -45, 5),
        Point3D(0, -25, 0),
      ],
      thickness: 4.5,
      color: const Color(0xFF6366F1),
      partKey: 'otol_post_canal',
      nameEn: 'Posterior & Superior Semicircular Canals',
      nameAr: 'القنوات الهلالية الخلفية والعلوية للتوازن',
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(0, -25, 0),
        Point3D(25, -30, 20),
        Point3D(35, -15, 15),
        Point3D(15, -10, 0),
      ],
      thickness: 4.0,
      color: const Color(0xFF818CF8),
      partKey: 'otol_post_canal',
      nameEn: 'Horizontal Lateral Semicircular Canal',
      nameAr: 'القناة الهلالية الأفقية الجانبية',
    ));

    // Otolith Organs (Utricle & Saccule)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-5, -15, 2),
      rx: 10,
      ry: 12,
      rz: 9,
      color: const Color(0xFFA5B4FC),
      partKey: 'otol_otoliths',
      nameEn: 'Otolith Organs (Utricle & Saccule)',
      nameAr: 'أعضاء التوازن الصخرية (القريبة والكييس)',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Cochlea Spiral (Hearing Organ)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(-5, -5, 0),
        Point3D(-18, 10, -5),
        Point3D(-12, 28, 5),
        Point3D(8, 32, 10),
        Point3D(18, 20, 5),
        Point3D(8, 12, 0),
        Point3D(0, 18, 2),
      ],
      thickness: 5.5,
      color: const Color(0xFF4F46E5),
      partKey: 'otol_cochlea',
      nameEn: 'Cochlea Spiral & Scala Tympani',
      nameAr: 'حلزون القوقعة والسقالة الطبلية السمعية',
    ));

    // Vestibulocochlear Nerve (CN VIII)
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(0, -10, 0),
      p2: Point3D(40, -15, -20),
      radius: 4.5,
      color: const Color(0xFFFCD34D),
      partKey: 'otol_cn8',
      nameEn: 'Vestibulocochlear Nerve Trunk (CN VIII)',
      nameAr: 'عصب التوازن والسمع القحفي الثامن (CN VIII)',
      steps: 6,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.audiometricProbe) {
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(-55, -20, 15),
        p2: Point3D(-15, -15, 5),
        radius: 3.5,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_audio_probe',
        nameEn: 'Caloric Irrigation & Impedance Probe',
        nameAr: 'مسبار الفحص الحراري والمقاومة السمعية',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.tympanostomyTube) {
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(-25, 0, 20),
        p2: Point3D(-18, 5, 15),
        radius: 4.0,
        color: const Color(0xFF10B981),
        partKey: 'tool_grommet',
        nameEn: 'Fluoroplastic Tympanostomy Ventilation Tube (Grommet)',
        nameAr: 'أنبوب تهوية طبلة الأذن التفلوني (جروميت)',
        steps: 8,
        isWireframe: true,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 7. NEURO-PSYCHIATRY & TMS 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildNeuroPsychiatryMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];
    final double scale = stage == ClinicalAgeStage.infant ? 0.75 : 1.0;

    // Head / Calvarium Wireframe Silhouette
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(0, -10, 0),
      rx: 52 * scale,
      ry: 64 * scale,
      rz: 54 * scale,
      color: const Color(0x33A855F7),
      partKey: 'psych_dlpfc',
      nameEn: 'Cranial Calvarium Surface',
      nameAr: 'سطح القبوة القحفية',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Dorsolateral Prefrontal Cortex (DLPFC - Brodmann 9/46)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-28 * scale, -42 * scale, 28 * scale),
      rx: 18 * scale,
      ry: 18 * scale,
      rz: 15 * scale,
      color: const Color(0xFFA855F7),
      partKey: 'psych_dlpfc',
      nameEn: 'Left Dorsolateral Prefrontal Cortex (DLPFC F3 Target)',
      nameAr: 'القشرة الجبهية الظهرانية الوحشية (DLPFC هدف F3)',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Limbic Circuit (Amygdala & Anterior Cingulate)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-12 * scale, 0, 4 * scale),
      rx: 14 * scale,
      ry: 12 * scale,
      rz: 12 * scale,
      color: const Color(0xFFEC4899),
      partKey: 'psych_limbic',
      nameEn: 'Limbic Node (Amygdala & Subgenual Cingulate)',
      nameAr: 'العقدة الحوفية (اللوزة الدماغية والتلفيف الحزامي)',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Default Mode Network Hub (DMN / Precuneus)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(0, -25 * scale, -32 * scale),
      rx: 20 * scale,
      ry: 22 * scale,
      rz: 16 * scale,
      color: const Color(0xFF6366F1),
      partKey: 'psych_dmn',
      nameEn: 'Default Mode Network (DMN Precuneus Hub)',
      nameAr: 'شبكة الوضع الافتراضي (عقدة الوتد الخلفي DMN)',
      latSteps: 5,
      lonSteps: 7,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.tmsFigure8Coil) {
      // Figure-8 Coil Ring 1
      faces.addAll(_buildDiscMesh(
        center: Point3D(-34 * scale, -52 * scale, 34 * scale),
        normal: const Point3D(0.4, 0.6, -0.6).normalized(),
        radius: 14.0,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_tms_coil',
        nameEn: 'Figure-8 TMS Magnetic Stimulation Coil (Ring A)',
        nameAr: 'ملف التحفيز المغناطيسي الموضعي شكل-8 (حلقة أ)',
        steps: 10,
      ));
      // Figure-8 Coil Ring 2
      faces.addAll(_buildDiscMesh(
        center: Point3D(-15 * scale, -58 * scale, 38 * scale),
        normal: const Point3D(0.4, 0.6, -0.6).normalized(),
        radius: 14.0,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_tms_coil',
        nameEn: 'Figure-8 TMS Magnetic Stimulation Coil (Ring B)',
        nameAr: 'ملف التحفيز المغناطيسي الموضعي شكل-8 (حلقة ب)',
        steps: 10,
      ));
    } else if (instrument == SpecialtyInstrument.eegCapElectrode) {
      final eegNodes = [
        Point3D(-28, -42, 28),
        Point3D(28, -42, 28),
        Point3D(0, -60, 10),
        Point3D(-42, -15, 10),
        Point3D(42, -15, 10),
        Point3D(0, -25, -34),
      ];
      for (final p in eegNodes) {
        faces.addAll(_buildEllipsoidMesh(
          center: p,
          rx: 3.5,
          ry: 3.5,
          rz: 3.5,
          color: const Color(0xFF38BDF8),
          partKey: 'tool_eeg_electrode',
          nameEn: '10-20 EEG Ag/AgCl Surface Electrode',
          nameAr: 'قطب تخطيط كهربية الدماغ 10-20 السطحي',
          latSteps: 4,
          lonSteps: 6,
        ));
      }
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 8. RHINOLOGY & SINUS - ENT 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildRhinologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];
    final double sinScale = stage == ClinicalAgeStage.child ? 0.65 : 1.0;

    // Nasal Septum (Cartilaginous & Bony)
    faces.addAll(_buildBoxMesh(
      center: const Point3D(0, 5, 15),
      dx: 3.5,
      dy: 38,
      dz: 40,
      color: const Color(0xFF99F6E4),
      partKey: 'rhino_septum',
      nameEn: 'Nasal Septal Cartilage & Vomer Bone',
      nameAr: 'غضروف الحاجز الأنفي وعظم الميكعة',
    ));

    // Turbinates (Inferior & Middle, Bilateral)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(-14, 15, 18),
      rx: 6,
      ry: 16,
      rz: 10,
      color: const Color(0xFF14B8A6),
      partKey: 'rhino_turbinate',
      nameEn: 'Left Inferior & Middle Turbinates',
      nameAr: 'القرنيات الأنفية السفلية والوسطى اليسرى',
      latSteps: 5,
      lonSteps: 7,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(14, 15, 18),
      rx: 6,
      ry: 16,
      rz: 10,
      color: const Color(0xFF14B8A6),
      partKey: 'rhino_turbinate',
      nameEn: 'Right Inferior & Middle Turbinates',
      nameAr: 'القرنيات الأنفية السفلية والوسطى اليمنى',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Maxillary Sinuses (Bilateral)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-28, 12, 5),
      rx: 16 * sinScale,
      ry: 20 * sinScale,
      rz: 16 * sinScale,
      color: const Color(0xFF0D9488),
      partKey: 'rhino_maxillary',
      nameEn: 'Left Maxillary Antrum Sinus',
      nameAr: 'الجيب الأنفي الفكي الأيسر',
      latSteps: 6,
      lonSteps: 8,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(28, 12, 5),
      rx: 16 * sinScale,
      ry: 20 * sinScale,
      rz: 16 * sinScale,
      color: const Color(0xFF0D9488),
      partKey: 'rhino_maxillary',
      nameEn: 'Right Maxillary Antrum Sinus',
      nameAr: 'الجيب الأنفي الفكي الأيمن',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Frontal Sinuses (Bilateral, above orbits)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-12, -35, 10),
      rx: 12 * sinScale,
      ry: 12 * sinScale,
      rz: 10 * sinScale,
      color: const Color(0xFF2DD4BF),
      partKey: 'rhino_frontal',
      nameEn: 'Left Frontal Sinus Cavity',
      nameAr: 'الجيب الأنفي الجبهي الأيسر',
      latSteps: 5,
      lonSteps: 7,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(12, -35, 10),
      rx: 12 * sinScale,
      ry: 12 * sinScale,
      rz: 10 * sinScale,
      color: const Color(0xFF2DD4BF),
      partKey: 'rhino_frontal',
      nameEn: 'Right Frontal Sinus Cavity',
      nameAr: 'الجيب الأنفي الجبهي الأيمن',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Ethmoid Sinus Air Cells
    faces.addAll(_buildBoxMesh(
      center: const Point3D(0, -10, 0),
      dx: 18 * sinScale,
      dy: 14 * sinScale,
      dz: 16 * sinScale,
      color: const Color(0xFF5EEAD4),
      partKey: 'rhino_ethmoid',
      nameEn: 'Anterior & Posterior Ethmoid Air Cells',
      nameAr: 'الخلايا الغربالية الأنفية الأمامية والخلفية',
    ));

    // Sphenoid Sinus
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(0, -8, -25),
      rx: 14 * sinScale,
      ry: 14 * sinScale,
      rz: 12 * sinScale,
      color: const Color(0xFF0F766E),
      partKey: 'rhino_sphenoid',
      nameEn: 'Sphenoid Sinus & Sella Turcica Base',
      nameAr: 'الجيب الوتدي وقاع السرج التركي',
      latSteps: 5,
      lonSteps: 7,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.sinusEndoscope) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(8, 48, 40),
        p2: const Point3D(8, 8, 12),
        radius: 2.2,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_endoscope',
        nameEn: '4mm 30° Rigid Sinus Diagnostic Endoscope',
        nameAr: 'منظار الجيوب الأنفية الصلب 4 ملم بزاوية 30 درجة',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.sinusBalloon) {
      faces.addAll(_buildEllipsoidMesh(
        center: const Point3D(22, 10, 10),
        rx: 5.5,
        ry: 10.0,
        rz: 5.5,
        color: const Color(0xCCF59E0B),
        partKey: 'tool_sinus_balloon',
        nameEn: 'Balloon Sinuplasty Dilatation Catheter',
        nameAr: 'بالون توسيع فوهة الجيب الأنفي (Sinuplasty)',
        latSteps: 5,
        lonSteps: 7,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 9. UROLOGY & MEN'S HEALTH 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildUrologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];
    final double prostateHypertrophy = stage == ClinicalAgeStage.geriatric ? 1.45 : 1.0;

    // Right Kidney (Renal Cortex & Pelvis)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(34, -50, -4),
      rx: 16,
      ry: 26,
      rz: 15,
      color: const Color(0xFF2563EB),
      partKey: 'uro_renal_pelvis',
      nameEn: 'Right Kidney & Renal Pelvis',
      nameAr: 'الكلية اليمنى وحوض الكلية',
      latSteps: 6,
      lonSteps: 8,
    ));
    // Left Kidney
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(-34, -58, -4),
      rx: 16,
      ry: 26,
      rz: 15,
      color: const Color(0xFF2563EB),
      partKey: 'uro_renal_pelvis',
      nameEn: 'Left Kidney & Renal Pelvis',
      nameAr: 'الكلية اليسرى وحوض الكلية',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Ureters (Bilateral down to bladder)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(32, -40, -2),
        const Point3D(24, -10, 0),
        const Point3D(14, 15, 2),
      ],
      thickness: 3.0,
      color: const Color(0xFF60A5FA),
      partKey: 'uro_renal_pelvis',
      nameEn: 'Right Ureter Pathway',
      nameAr: 'الحالب الأيمن ومسار الحصوات',
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(-32, -48, -2),
        const Point3D(-24, -10, 0),
        const Point3D(-14, 15, 2),
      ],
      thickness: 3.0,
      color: const Color(0xFF60A5FA),
      partKey: 'uro_renal_pelvis',
      nameEn: 'Left Ureter Pathway',
      nameAr: 'الحالب الأيسر ومسار الحصوات',
    ));

    // Urinary Bladder (Detrusor muscle)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(0, 24, 6),
      rx: 28,
      ry: 24,
      rz: 25,
      color: const Color(0xFF3B82F6),
      partKey: 'uro_bladder',
      nameEn: 'Urinary Bladder & Detrusor Wall',
      nameAr: 'المثانة البولية وعضلة الدفتروسور',
      latSteps: 7,
      lonSteps: 9,
    ));

    // Prostate Gland: Transition Zone (surrounding urethra, BPH site)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(0, 52, 6),
      rx: 13 * prostateHypertrophy,
      ry: 11 * prostateHypertrophy,
      rz: 12 * prostateHypertrophy,
      color: const Color(0xFF1D4ED8),
      partKey: 'uro_prostate_transition',
      nameEn: 'Prostate Transition Zone (BPH Site)',
      nameAr: 'المنطقة الانتقالية للبروستاتا (تضخم BPH الحميد)',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Prostate Gland: Peripheral Zone (Posterior, cancer biopsy site)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(0, 55, -5),
      rx: 18 * prostateHypertrophy,
      ry: 14 * prostateHypertrophy,
      rz: 11 * prostateHypertrophy,
      color: const Color(0xFF1E40AF),
      partKey: 'uro_prostate_peripheral',
      nameEn: 'Prostate Peripheral Zone (TRUS Biopsy Target)',
      nameAr: 'المنطقة المحيطية للبروستاتا (موقع الخزعة والأورام)',
      latSteps: 5,
      lonSteps: 7,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.doubleJStent) {
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          const Point3D(34, -48, -2),
          const Point3D(26, -10, 0),
          const Point3D(10, 22, 4),
        ],
        thickness: 2.2,
        color: const Color(0xFFFACC15),
        partKey: 'tool_jj_stent',
        nameEn: 'Double-J (JJ) Radiopaque Ureteral Stent',
        nameAr: 'دعامة الحالب المزدوجة المعقوفة (JJ Stent)',
      ));
    } else if (instrument == SpecialtyInstrument.rigidCystoscope) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(0, 85, 8),
        p2: const Point3D(0, 32, 6),
        radius: 3.2,
        color: const Color(0xFFCBD5E1),
        partKey: 'tool_cystoscope',
        nameEn: 'Rigid Diagnostic Cystoscope Sheath & Light Guide',
        nameAr: 'منظار المثانة ومجرى البول التشخيصي الصلب',
        steps: 8,
      ));
    } else if (instrument == SpecialtyInstrument.prostateNeedle) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(0, 78, -18),
        p2: const Point3D(0, 54, -6),
        radius: 1.1,
        color: const Color(0xFFEF4444),
        partKey: 'tool_prostate_needle',
        nameEn: '18G TRUS-Guided Prostate Core Biopsy Needle',
        nameAr: 'إبرة أخذ عينات البروستاتا الموجهة بالموجات (TRUS)',
        steps: 4,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 10. OB/GYN & FERTILITY - REI 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildObGynMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];
    final bool isPreg = stage == ClinicalAgeStage.infant; // used to illustrate gestational sac if infant mode

    // Uterus: Corpus & Endometrial Cavity
    final double utScale = isPreg ? 1.4 : 1.0;
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(0, -10, 0),
      rx: 24 * utScale,
      ry: 32 * utScale,
      rz: 20 * utScale,
      color: const Color(0xFFF43F5E),
      partKey: 'obgyn_endometrium',
      nameEn: 'Uterine Corpus, Myometrium & Endometrial Cavity',
      nameAr: 'جسم الرحم وعضلته وتجويف البطانة',
      latSteps: 7,
      lonSteps: 9,
    ));

    // Fallopian Tubes (Bilateral Salpinges)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(-22, -22, 0),
        const Point3D(-42, -30, 4),
        const Point3D(-55, -20, 0),
      ],
      thickness: 3.5,
      color: const Color(0xFFFB7185),
      partKey: 'obgyn_ovary',
      nameEn: 'Left Fallopian Tube (Oviduct & Fimbriae)',
      nameAr: 'قناة فالوب اليسرى والأهداب البوقية',
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(22, -22, 0),
        const Point3D(42, -30, 4),
        const Point3D(55, -20, 0),
      ],
      thickness: 3.5,
      color: const Color(0xFFFB7185),
      partKey: 'obgyn_ovary',
      nameEn: 'Right Fallopian Tube (Oviduct & Fimbriae)',
      nameAr: 'قناة فالوب اليمنى والأهداب البوقية',
    ));

    // Ovaries & Follicles
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(-55, -16, -2),
      rx: 12,
      ry: 16,
      rz: 11,
      color: const Color(0xFFFDA4AF),
      partKey: 'obgyn_ovary',
      nameEn: 'Left Ovary & Antral Follicles',
      nameAr: 'المبيض الأيسر والحويصلات المبيضية',
      latSteps: 5,
      lonSteps: 7,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(55, -16, -2),
      rx: 12,
      ry: 16,
      rz: 11,
      color: const Color(0xFFFDA4AF),
      partKey: 'obgyn_ovary',
      nameEn: 'Right Ovary & Antral Follicles',
      nameAr: 'المبيض الأيمن والحويصلات المبيضية',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Cervix & External Os
    faces.addAll(_buildCylinderMesh(
      p1: const Point3D(0, 16, 0),
      p2: const Point3D(0, 42, 0),
      radius: 12,
      color: const Color(0xFFBE123C),
      partKey: 'obgyn_cervix',
      nameEn: 'Uterine Cervix & Transformation Zone',
      nameAr: 'عنق الرحم ومنطقة التحول الخلوي T-Zone',
      steps: 8,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.iudDevice) {
      // T-shaped IUD Copper/Levonorgestrel
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(0, -2, 0),
        p2: const Point3D(0, -26, 0),
        radius: 1.2,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_iud',
        nameEn: 'Intrauterine Device (IUD) Vertical Stem',
        nameAr: 'ساق اللولب الرحمي النحاسي/الهرموني',
        steps: 6,
      ));
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(-14, -24, 0),
        p2: const Point3D(14, -24, 0),
        radius: 1.2,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_iud',
        nameEn: 'IUD Horizontal Flexible Arms',
        nameAr: 'ذراعا اللولب الرحمي الأفقيان',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.hysteroscopyShaft) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(0, 68, 0),
        p2: const Point3D(0, 18, 0),
        radius: 2.8,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_hysteroscope',
        nameEn: 'Diagnostic Hysteroscopy Sheath',
        nameAr: 'غمد منظار تجويف الرحم التشخيصي',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.follicleAspirationNeedle) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(35, 30, 10),
        p2: const Point3D(52, -14, 0),
        radius: 1.1,
        color: const Color(0xFF10B981),
        partKey: 'tool_ivf_needle',
        nameEn: 'IVF Transvaginal Oocyte Aspiration Needle',
        nameAr: 'إبرة سحب البويضات الموجهة بالموجات للحقن المجهري',
        steps: 4,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 11. PULMONOLOGY & RESPIRATORY 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildPulmonologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];
    final double lungScale = stage == ClinicalAgeStage.infant ? 0.7 : 1.0;

    // Trachea (Cartilaginous C-rings)
    faces.addAll(_buildCylinderMesh(
      p1: const Point3D(0, -75, 0),
      p2: const Point3D(0, -25, 0),
      radius: 11,
      color: const Color(0xFF38BDF8),
      partKey: 'pulm_trachea',
      nameEn: 'Trachea & Subglottic Airway',
      nameAr: 'القصبة الهوائية والمجرى تحت الحنجري',
      steps: 8,
    ));

    // Right & Left Mainstem Bronchi (Carina Bifurcation)
    faces.addAll(_buildCylinderMesh(
      p1: const Point3D(0, -25, 0),
      p2: const Point3D(-22, 0, 0),
      radius: 8.5,
      color: const Color(0xFF0284C7),
      partKey: 'pulm_trachea',
      nameEn: 'Left Mainstem Bronchus',
      nameAr: 'الشعبة الهوائية الرئيسية اليسرى',
      steps: 6,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: const Point3D(0, -25, 0),
      p2: const Point3D(20, -5, 0),
      radius: 9.5, // slightly wider & more vertical
      color: const Color(0xFF0284C7),
      partKey: 'pulm_trachea',
      nameEn: 'Right Mainstem Bronchus & Carina',
      nameAr: 'الشعبة الهوائية الرئيسية اليمنى والمهماز',
      steps: 6,
    ));

    // Right Lung (3 Lobes: Superior, Middle, Inferior)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(34 * lungScale, 15, 0),
      rx: 28 * lungScale,
      ry: 48 * lungScale,
      rz: 28 * lungScale,
      color: const Color(0xFF0EA5E9),
      partKey: 'pulm_right_lung',
      nameEn: 'Right Lung (Superior, Middle & Inferior Lobes)',
      nameAr: 'فصوص الرئة اليمنى الثلاثة (العلوي والأوسط والسفلي)',
      latSteps: 7,
      lonSteps: 10,
    ));

    // Left Lung (2 Lobes: Superior & Inferior with Cardiac Notch)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-34 * lungScale, 15, 0),
      rx: 26 * lungScale,
      ry: 48 * lungScale,
      rz: 26 * lungScale,
      color: const Color(0xFF0EA5E9),
      partKey: 'pulm_left_lung',
      nameEn: 'Left Lung Parenchyma & Lingula',
      nameAr: 'نسيج الرئة اليسرى واللسينة والتلم القلبي',
      latSteps: 7,
      lonSteps: 10,
    ));

    // Pleural Space / Costophrenic Angle
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(60 * lungScale, 60, 5),
        Point3D(30 * lungScale, 68, 5),
        const Point3D(0, 62, 5),
        Point3D(-30 * lungScale, 68, 5),
        Point3D(-60 * lungScale, 60, 5),
      ],
      thickness: 4.0,
      color: const Color(0xFF7DD3FC),
      partKey: 'pulm_pleura',
      nameEn: 'Pleural Space & Diaphragmatic Sulcus',
      nameAr: 'التجويف الجنبي والقاع الحجابي للأضلاع',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.flexibleBronchoscope) {
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          const Point3D(0, -90, 10),
          const Point3D(0, -25, 0),
          const Point3D(18, -4, 0),
          const Point3D(28, 20, 6),
        ],
        thickness: 3.5,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_bronchoscope',
        nameEn: 'Flexible Video Bronchoscope & Biopsy Port',
        nameAr: 'منظار القصبات الهوائية المرن وقناة أخذ العينات',
      ));
    } else if (instrument == SpecialtyInstrument.chestTube) {
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(65 * lungScale, 30, 20),
        p2: Point3D(38 * lungScale, 45, 8),
        radius: 4.0,
        color: const Color(0xFFEF4444),
        partKey: 'tool_chest_tube',
        nameEn: '28Fr Intercostal Thoracostomy Chest Tube',
        nameAr: 'أنبوب الصدر لنزح السائل والهواء (Thoracostomy)',
        steps: 8,
      ));
    } else if (instrument == SpecialtyInstrument.endobronchialValve) {
      faces.addAll(_buildBoxMesh(
        center: const Point3D(18, -2, 0),
        dx: 6.0,
        dy: 6.0,
        dz: 6.0,
        color: const Color(0xFF10B981),
        partKey: 'tool_valve',
        nameEn: 'Zephyr One-Way Endobronchial Valve',
        nameAr: 'صمام القصبات الهوائية أحادي الاتجاه (Zephyr)',
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 12. PODIATRY & ORTHOTICS 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildPodiatryMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    // Calcaneus (Heel Bone & Tuberosity)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(0, 35, -20),
      rx: 18,
      ry: 22,
      rz: 28,
      color: const Color(0xFF84CC16),
      partKey: 'pod_calcaneus',
      nameEn: 'Calcaneus Heel Bone & Subtalar Joint',
      nameAr: 'عظم الكعب (Calcaneus) والمفصل تحت الكاحل',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Midfoot Tarsals & Longitudinal Arch
    faces.addAll(_buildBoxMesh(
      center: const Point3D(0, 15, 12),
      dx: 30,
      dy: 16,
      dz: 32,
      color: const Color(0xFFA3E635),
      partKey: 'pod_calcaneus',
      nameEn: 'Tarsal Bones (Navicular, Cuboid & Cuneiforms)',
      nameAr: 'عظام رسغ القدم (الزورقي والمكعب والإسفينية)',
    ));

    // Metatarsals (1st through 5th Rays)
    for (int i = -2; i <= 2; i++) {
      final double mx = i * 8.5;
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(mx * 0.7, 10, 24),
        p2: Point3D(mx, 5, 58),
        radius: i == 2 ? 4.5 : 3.0,
        color: const Color(0xFF65A30D),
        partKey: 'pod_metatarsals',
        nameEn: 'Metatarsal Ray Bones (1st–5th)',
        nameAr: 'عظام مشط القدم الخمسة',
        steps: 6,
      ));
    }

    // 1st MTP Joint & Hallux (Great Toe)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(17, 4, 62),
      rx: 7.5,
      ry: 7.5,
      rz: 9.0,
      color: const Color(0xFF4D7C0F),
      partKey: 'pod_first_mtp',
      nameEn: '1st Metatarsophalangeal (MTP) Joint & Bunion Site',
      nameAr: 'مفصل إبهام القدم الأول (MTP) وموقع الوكنة (Hallux Valgus)',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Plantar Fascia Aponeurosis
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(0, 42, -12),
        const Point3D(0, 22, 14),
        const Point3D(10, 12, 48),
      ],
      thickness: 4.5,
      color: const Color(0xFFFEF08A),
      partKey: 'pod_calcaneus',
      nameEn: 'Plantar Fascia Aponeurosis Central Band',
      nameAr: 'اللفافة الأخمصية للقدم (موقع التهاب الكعب والشوكة)',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.orthoticInsole) {
      faces.addAll(_buildBoxMesh(
        center: const Point3D(0, 26, 18),
        dx: 36,
        dy: 4.5,
        dz: 88,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_orthotic',
        nameEn: 'Custom Biomechanical EVA Orthotic Insole Footbed',
        nameAr: 'نعل طبي تقويمي مخصص لدعم القوس الأخمصي',
      ));
    } else if (instrument == SpecialtyInstrument.fasciotomyBlade) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(-18, 48, -8),
        p2: const Point3D(-2, 38, -10),
        radius: 1.5,
        color: const Color(0xFFEF4444),
        partKey: 'tool_blade',
        nameEn: 'Endoscopic Plantar Fasciotomy Release Blade',
        nameAr: 'مبضع تسليك اللفافة الأخمصية بالمنظار',
        steps: 4,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 13. COSMETIC PLASTIC SURGERY 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildPlasticSurgeryMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];
    final double laxity = stage == ClinicalAgeStage.geriatric ? 1.25 : 1.0;

    // Nasal Dorsum & Osteocartilaginous Vault (Rhinoplasty)
    faces.addAll(_buildPrismMesh(
      p1: const Point3D(-8, -25, 20),
      p2: const Point3D(8, -25, 20),
      p3: const Point3D(0, -5, 34),
      depth: 16,
      color: const Color(0xFFE11D48),
      partKey: 'plast_nasal_dorsum',
      nameEn: 'Nasal Dorsum, Tip & Cartilaginous Vault',
      nameAr: 'حدبة وقصبة وغضاريف أرنبة الأنف',
    ));

    // SMAS Layer & Midface Vectors (Left & Right)
    faces.addAll(_buildBoxMesh(
      center: Point3D(-28, 5 * laxity, 14),
      dx: 22,
      dy: 38 * laxity,
      dz: 6,
      color: const Color(0xFFFB7185),
      partKey: 'plast_smas_midface',
      nameEn: 'Superficial Musculoaponeurotic System (SMAS) Layer',
      nameAr: 'طبقة سماص الليفية العضلية لشعر وشد الوجه (SMAS)',
    ));
    faces.addAll(_buildBoxMesh(
      center: Point3D(28, 5 * laxity, 14),
      dx: 22,
      dy: 38 * laxity,
      dz: 6,
      color: const Color(0xFFFB7185),
      partKey: 'plast_smas_midface',
      nameEn: 'Superficial Musculoaponeurotic System (SMAS) Layer',
      nameAr: 'طبقة سماص الليفية العضلية لشعر وشد الوجه (SMAS)',
    ));

    // Subcutaneous Adipose Compartment & Body Contouring Zone
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(0, 48 * laxity, 10),
      rx: 44,
      ry: 26 * laxity,
      rz: 24,
      color: const Color(0xFFFDE047),
      partKey: 'plast_lipo_zone',
      nameEn: 'Subcutaneous Adipose Layer (Liposuction/Contouring Zone)',
      nameAr: 'طبقة النسيج الشحمي السطحي والعميق (نحت القوام وشفط الدهون)',
      latSteps: 6,
      lonSteps: 8,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.vectorLiftThread) {
      // Barbed PDO suspension thread
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          const Point3D(-42, -15, 10),
          const Point3D(-28, 8, 16),
          const Point3D(-14, 25, 12),
        ],
        thickness: 2.2,
        color: const Color(0xFF2563EB),
        partKey: 'tool_pdo_thread',
        nameEn: 'Barbed Polydioxanone (PDO) Cog Lifting Vector',
        nameAr: 'خيط الشد التجميلي المسنن (PDO Cog)',
      ));
    } else if (instrument == SpecialtyInstrument.liposuctionCannula) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(-35, 75, 20),
        p2: const Point3D(-5, 45, 10),
        radius: 2.5,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_lipo_cannula',
        nameEn: 'Mercedes-Tip Tumescent Liposuction Cannula',
        nameAr: 'قنية شفط الدهون ثلاثية الثقوب (Mercedes Cannula)',
        steps: 6,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 14. MEDICAL AESTHETICS (INJECTORS) 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildMedicalAestheticsMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    // Glabellar Complex (Corrugator & Procerus Muscles - Botox site)
    faces.addAll(_buildBoxMesh(
      center: const Point3D(0, -32, 22),
      dx: 24,
      dy: 14,
      dz: 5,
      color: const Color(0xFFF472B6),
      partKey: 'aes_glabella',
      nameEn: 'Glabellar Complex (Corrugator & Procerus - Botox Site)',
      nameAr: 'مجموعة عضلات ما بين الحاجبين (Corrugator & Procerus)',
    ));

    // Malar Cheek Fat Pads (Zygomatic Apex - Filler Bolus site)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(-26, -10, 16),
      rx: 14,
      ry: 12,
      rz: 10,
      color: const Color(0xFFFB7185),
      partKey: 'aes_malar_apex',
      nameEn: 'Left Malar & Zygomatic Fat Compartment',
      nameAr: 'وسادة الوجنة والخد اليسرى (موقع حقن الفيلر)',
      latSteps: 5,
      lonSteps: 7,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(26, -10, 16),
      rx: 14,
      ry: 12,
      rz: 10,
      color: const Color(0xFFFB7185),
      partKey: 'aes_malar_apex',
      nameEn: 'Right Malar & Zygomatic Fat Compartment',
      nameAr: 'وسادة الوجنة والخد اليمنى (موقع حقن الفيلر)',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Facial & Angular Artery Danger Zones (Vascular Occlusion Risk)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(-32, 28, 10),
        const Point3D(-24, 8, 14),
        const Point3D(-14, -8, 18),
        const Point3D(-10, -26, 20),
      ],
      thickness: 3.2,
      color: const Color(0xFFDC2626), // Danger Red
      partKey: 'aes_facial_artery_danger',
      nameEn: 'Facial & Angular Artery Danger Highway (High Necrosis Risk)',
      nameAr: 'مسار الشريان الوجهي والزاوي (منطقة خطر الانسداد الوعائي)',
    ));
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(32, 28, 10),
        const Point3D(24, 8, 14),
        const Point3D(14, -8, 18),
        const Point3D(10, -26, 20),
      ],
      thickness: 3.2,
      color: const Color(0xFFDC2626),
      partKey: 'aes_facial_artery_danger',
      nameEn: 'Facial & Angular Artery Danger Highway (High Necrosis Risk)',
      nameAr: 'مسار الشريان الوجهي والزاوي (منطقة خطر الانسداد الوعائي)',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.microCannula) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(-45, 12, 12),
        p2: const Point3D(-22, -8, 16),
        radius: 1.2,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_cannula',
        nameEn: '25G Blunt Aesthetic Micro-Cannula with Side-Port',
        nameAr: 'قنية الحقن التجميلي غير الحادة 25G مع فتحة جانبية',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.botoxSyringe) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(0, -48, 32),
        p2: const Point3D(0, -32, 24),
        radius: 1.8,
        color: const Color(0xFF10B981),
        partKey: 'tool_botox_needle',
        nameEn: '32G Ultra-Fine Insulin/Botox Micro-Needle',
        nameAr: 'إبرة حقن البوتوكس والميزوثيرابي فائقة الدقة 32G',
        steps: 6,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 15. INTERVENTIONAL PAIN MANAGEMENT 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildPainManagementMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    // Lumbar Vertebral Column (L1 through L5)
    for (int i = 0; i < 4; i++) {
      final double vy = -50.0 + i * 26.0;
      faces.addAll(_buildBoxMesh(
        center: Point3D(0, vy, 0),
        dx: 28,
        dy: 16,
        dz: 24,
        color: const Color(0xFFF97316),
        partKey: 'pain_l4_l5_epidural',
        nameEn: 'Lumbar Vertebral Body (L${i + 1}–L${i + 2})',
        nameAr: 'جسم الفقرة القطنية (L${i + 1}–L${i + 2})',
      ));

      // Intervertebral Disc
      faces.addAll(_buildDiscMesh(
        center: Point3D(0, vy + 11.0, 0),
        normal: const Point3D(0, 1, 0),
        radius: 13,
        color: const Color(0xFFFED7AA),
        partKey: 'pain_l4_l5_epidural',
        nameEn: 'Intervertebral Disc & Annulus Fibrosus',
        nameAr: 'القرص الغضروفي وحلقة الألياف',
      ));

      // Bilateral Facet Joints
      faces.addAll(_buildEllipsoidMesh(
        center: Point3D(-18, vy + 6.0, -12),
        rx: 5.5,
        ry: 7.0,
        rz: 5.5,
        color: const Color(0xFFEA580C),
        partKey: 'pain_facet_joint',
        nameEn: 'Left Zygapophysial Facet Joint',
        nameAr: 'المفصل الفقرى الوجيهي الأيسر',
        latSteps: 4,
        lonSteps: 6,
      ));
      faces.addAll(_buildEllipsoidMesh(
        center: Point3D(18, vy + 6.0, -12),
        rx: 5.5,
        ry: 7.0,
        rz: 5.5,
        color: const Color(0xFFEA580C),
        partKey: 'pain_facet_joint',
        nameEn: 'Right Zygapophysial Facet Joint',
        nameAr: 'المفصل الفقرى الوجيهي الأيمن',
        latSteps: 4,
        lonSteps: 6,
      ));
    }

    // Spinal Cord Dorsal Column & Epidural Space
    faces.addAll(_buildCylinderMesh(
      p1: const Point3D(0, -60, -6),
      p2: const Point3D(0, 48, -6),
      radius: 6.5,
      color: const Color(0xFFFDBA74),
      partKey: 'pain_scs_target',
      nameEn: 'Spinal Cord Dorsal Column (SCS Stimulation Target)',
      nameAr: 'الأعمدة الخلفية للحبل الشوكي (هدف محفز الألم SCS)',
      steps: 8,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.tuohyEpiduralNeedle) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(0, 15, -45),
        p2: const Point3D(0, 15, -8),
        radius: 1.5,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_tuohy',
        nameEn: '18G Tuohy Epidural Needle with Curved Huber Tip',
        nameAr: 'إبرة توهي المنحنية 18G للحقن فوق الجافية',
        steps: 6,
      ));
    } else if (instrument == SpecialtyInstrument.rfAblationElectrode) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(28, -12, -35),
        p2: const Point3D(18, -18, -12),
        radius: 1.2,
        color: const Color(0xFFEF4444),
        partKey: 'tool_rf_needle',
        nameEn: 'Radiofrequency (RF) Facet Denervation Active Electrode',
        nameAr: 'قطب التردد الحراري النشط لكي العصب المفصلي',
        steps: 6,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 16. ACUPUNCTURE & EASTERN MEDICINE 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildAcupunctureMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    // Anatomical Body Canvas Form (Torso & Head Silhouette)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(0, -60, 0),
      rx: 22,
      ry: 26,
      rz: 20,
      color: const Color(0x3310B981),
      partKey: 'acu_jianjing_gb21',
      nameEn: 'Cranial & Cervical Acupoint Grid',
      nameAr: 'الشبكة القحفية والعنقية لنقاط الوخز',
      latSteps: 5,
      lonSteps: 7,
    ));
    faces.addAll(_buildCylinderMesh(
      p1: const Point3D(0, -35, 0),
      p2: const Point3D(0, 35, 0),
      radius: 26,
      color: const Color(0x2210B981),
      partKey: 'acu_zusanli_st36',
      nameEn: 'Thoraco-Abdominal Trunk Energy Matrix',
      nameAr: 'مصفوفة طاقة الجذع الصدري والبطني',
      steps: 8,
    ));

    // Primary Meridians (Governor Vessel Du Mai & Conception Vessel Ren Mai)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(0, -82, 0),
        const Point3D(0, -60, 20),
        const Point3D(0, -20, 26),
        const Point3D(0, 20, 26),
        const Point3D(0, 55, 10),
      ],
      thickness: 2.8,
      color: const Color(0xFF10B981),
      partKey: 'acu_zusanli_st36',
      nameEn: 'Ren Mai (Conception Vessel) Meridian Channel',
      nameAr: 'مسار رين ماي (الوعاء التناسلي والمعدة)',
    ));

    // Acupoints:
    // 1. Hegu (LI4 - Hand/Forearm Analgesic Point)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(-42, 10, 8),
      rx: 6.0,
      ry: 6.0,
      rz: 6.0,
      color: const Color(0xFFF59E0B),
      partKey: 'acu_hegu_li4',
      nameEn: 'Hegu (LI4) Large Intestine Acupoint',
      nameAr: 'نقطة هيكو (LI4) في مسار القولون لتسكين الألم والصداع',
      latSteps: 4,
      lonSteps: 6,
    ));

    // 2. Zusanli (ST36 - Lower Leg Vital Energy Point)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(18, 55, 12),
      rx: 6.0,
      ry: 6.0,
      rz: 6.0,
      color: const Color(0xFFF59E0B),
      partKey: 'acu_zusanli_st36',
      nameEn: 'Zusanli (ST36) Stomach Meridian Acupoint',
      nameAr: 'نقطة تسوسانلي (ST36) في مسار المعدة لدعم المناعة',
      latSteps: 4,
      lonSteps: 6,
    ));

    // 3. Jianjing (GB21 - Shoulder Apex & Pneumothorax Safety Check)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(-24, -32, 6),
      rx: 6.5,
      ry: 6.5,
      rz: 6.5,
      color: const Color(0xFFEF4444),
      partKey: 'acu_jianjing_gb21',
      nameEn: 'Jianjing (GB21) Gallbladder Point (Lung Apex Depth Danger)',
      nameAr: 'نقطة جيانجينغ (GB21) في مسار المرارة (فحص عمق قمة الرئة)',
      latSteps: 4,
      lonSteps: 6,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.filiformNeedle) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(-42, 10, 32),
        p2: const Point3D(-42, 10, 9),
        radius: 0.8,
        color: const Color(0xFFE2E8F0),
        partKey: 'tool_needle',
        nameEn: '0.25mm Surgical Stainless Filiform Acupuncture Needle',
        nameAr: 'إبرة الوخز الصينية المرنة المعقمة 0.25 ملم',
        steps: 4,
      ));
    } else if (instrument == SpecialtyInstrument.moxibustionCone) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(18, 55, 14),
        p2: const Point3D(18, 55, 28),
        radius: 7.0,
        color: const Color(0xFF78350F),
        partKey: 'tool_moxa',
        nameEn: 'Smokeless Mugwort Moxibustion Cone (Moxa Heat)',
        nameAr: 'كأس الموكسا الحرارية للعلاج الصيني (عشبة الشيح)',
        steps: 8,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 17. SPEECH-LANGUAGE PATHOLOGY (SLP) 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildSpeechPathologyMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    // Lingual Motor Apparatus (Tongue Musculature)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(0, -35, 15),
      rx: 20,
      ry: 16,
      rz: 28,
      color: const Color(0xFF38BDF8),
      partKey: 'slp_tongue',
      nameEn: 'Lingual Motor Apparatus (Tongue Base & Oral Phase)',
      nameAr: 'عضلات اللسان وقاعدته ومرحلة البلع الفموية',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Velopharyngeal Mechanism (Soft Palate & Uvula)
    faces.addAll(_buildBoxMesh(
      center: const Point3D(0, -38, -12),
      dx: 24,
      dy: 8,
      dz: 16,
      color: const Color(0xFF0284C7),
      partKey: 'slp_soft_palate',
      nameEn: 'Velopharyngeal Seal & Levator Veli Palatini',
      nameAr: 'الحنك الرخو والصمام اللهاتي لمنع التسرب الأنفي',
    ));

    // Epiglottis & Valleculae (Aspiration Protection)
    faces.addAll(_buildPrismMesh(
      p1: const Point3D(-14, -15, 6),
      p2: const Point3D(14, -15, 6),
      p3: const Point3D(0, -2, 14),
      depth: 6.0,
      color: const Color(0xFF7DD3FC),
      partKey: 'slp_valleculae',
      nameEn: 'Epiglottis Leaflet, Valleculae & Pyriform Sinus',
      nameAr: 'لسان المزمار والوهدات لحماية مجرى التنفس أثناء البلع',
    ));

    // True & False Vocal Folds (Glottic Space)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(-12, 16, 4),
        const Point3D(0, 12, 14),
        const Point3D(12, 16, 4),
      ],
      thickness: 4.5,
      color: const Color(0xFFF0F9FF),
      partKey: 'slp_vocal_cords',
      nameEn: 'True Vocal Folds (Vocal Cords) & Phonation Chink',
      nameAr: 'الحبال الصوتية الحقيقية ومزرار التصويت',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.feesLaryngoscope) {
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          const Point3D(0, -65, 20),
          const Point3D(0, -40, 2),
          const Point3D(0, -12, 8),
        ],
        thickness: 3.2,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_fees_scope',
        nameEn: 'FEES Flexible Video Nasopharyngolaryngoscope',
        nameAr: 'منظار تقييم البلع بالفيديو المرن (FEES)',
      ));
    } else if (instrument == SpecialtyInstrument.passyMuirValve) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(0, 32, 8),
        p2: const Point3D(0, 32, 22),
        radius: 8.0,
        color: const Color(0xFF10B981),
        partKey: 'tool_pm_valve',
        nameEn: 'Passy-Muir Tracheostomy Speaking & Swallowing Valve',
        nameAr: 'صمام الكلام لشق القصبة الهوائية (Passy-Muir Valve)',
        steps: 8,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 18. VETERINARY MEDICINE 3D MESH GENERATOR (CANINE / FELINE SCALE)
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildVeterinaryMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];
    final double sz = stage == ClinicalAgeStage.infant ? 0.65 : 1.0;

    // Quadruped Skull, Muzzle & Dental Formula
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(46 * sz, -20, 0),
      rx: 22 * sz,
      ry: 16 * sz,
      rz: 18 * sz,
      color: const Color(0xFF10B981),
      partKey: 'vet_cranial',
      nameEn: 'Canine/Feline Cranium, Mandible & Carnassial Dentition',
      nameAr: 'الجمجمة والفك والصيغة السنية البيطرية',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Cervical Spine (C1-C7)
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(34 * sz, -15, 0),
      p2: Point3D(15 * sz, -5, 0),
      radius: 7.0 * sz,
      color: const Color(0xFF34D399),
      partKey: 'vet_cervical',
      nameEn: 'Cervical Vertebrae (C1–C7 Atlas/Axis)',
      nameAr: 'الفقرات العنقية C1–C7 ومفصل الأطلس',
      steps: 6,
    ));

    // Thoracic Spine, Ribs & Cardiopulmonary Viscera
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(0, 0, 0),
      rx: 24 * sz,
      ry: 22 * sz,
      rz: 20 * sz,
      color: const Color(0xFF059669),
      partKey: 'vet_thoracic',
      nameEn: 'Thorax, Ribcage, Heart & Lungs',
      nameAr: 'القفص الصدري والقلب والرئتين',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Abdominal Cavity (Stomach, Liver, Intestines)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-28 * sz, 5, 0),
      rx: 22 * sz,
      ry: 20 * sz,
      rz: 18 * sz,
      color: const Color(0xFF047857),
      partKey: 'vet_abdominal',
      nameEn: 'Abdominal Viscera (Stomach GDV site & Intestines)',
      nameAr: 'الأحشاء البطنية والمعدة والأمعاء',
      latSteps: 6,
      lonSteps: 8,
    ));

    // Pelvis & Hip Joint
    faces.addAll(_buildBoxMesh(
      center: Point3D(-52 * sz, -2, 0),
      dx: 22 * sz,
      dy: 18 * sz,
      dz: 20 * sz,
      color: const Color(0xFF065F46),
      partKey: 'vet_pelvic',
      nameEn: 'Pelvic Girdle & Coxofemoral Joint (Hip Dysplasia)',
      nameAr: 'الحوض ومفصل الفخذ الوركي (خلل التنسج الوركي)',
    ));

    // Forelimb & Paw
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(12 * sz, 12, 10),
      p2: Point3D(14 * sz, 48, 12),
      radius: 5.0 * sz,
      color: const Color(0xFF6EE7B7),
      partKey: 'vet_forelimb_r',
      nameEn: 'Forelimb (Scapula, Humerus, Radius & Paw)',
      nameAr: 'الطرف الأمامي والكتف والعضد والمخالب',
      steps: 6,
    ));

    // Hindlimb & Stifle (Knee / CCL)
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-48 * sz, 8, 10),
      p2: Point3D(-46 * sz, 50, 12),
      radius: 6.0 * sz,
      color: const Color(0xFF6EE7B7),
      partKey: 'vet_hindlimb_r',
      nameEn: 'Hindlimb & Stifle Joint (Cranial Cruciate Ligament CCL)',
      nameAr: 'الطرف الخلفي ومفصل الركبة والرباط الصليبي CCL',
      steps: 6,
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.vetBonePlate) {
      faces.addAll(_buildBoxMesh(
        center: Point3D(-46 * sz, 30, 15),
        dx: 6.0,
        dy: 24.0,
        dz: 2.0,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_vet_plate',
        nameEn: 'Veterinary Dynamic Compression Plate (DCP 3.5mm)',
        nameAr: 'شريحة تثبيت العظام البيطرية DCP 3.5 ملم',
      ));
    } else if (instrument == SpecialtyInstrument.vetDentalScaler) {
      faces.addAll(_buildCylinderMesh(
        p1: Point3D(65 * sz, -35, 10),
        p2: Point3D(48 * sz, -22, 6),
        radius: 2.0,
        color: const Color(0xFFF59E0B),
        partKey: 'tool_vet_scaler',
        nameEn: 'Veterinary Ultrasonic Piezo Dental Scaler Tip',
        nameAr: 'رأس جهاز تنظيف الأسنان البيطري بالموجات فوق الصوتية',
        steps: 6,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 19. VEIN & VASCULAR 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildVascularVeinMesh(
    ClinicalAgeStage stage, {
    SpecialtyInstrument? instrument = SpecialtyInstrument.none,
    bool isSoloMode = false,
    String? soloPartKey,
  }) {
    var faces = <MeshFace3D>[];

    // Saphenofemoral Junction (SFJ)
    faces.addAll(_buildEllipsoidMesh(
      center: const Point3D(-15, -45, 6),
      rx: 12,
      ry: 14,
      rz: 10,
      color: const Color(0xFFDC2626),
      partKey: 'vasc_sfj',
      nameEn: 'Saphenofemoral Junction (SFJ Reflux Point)',
      nameAr: 'المفصل الصافني الفخذي (SFJ نقطة القصور الصمامي)',
      latSteps: 5,
      lonSteps: 7,
    ));

    // Great Saphenous Vein (GSV - Lower Limb Trunk)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(-15, -45, 6),
        const Point3D(-16, -10, 8),
        const Point3D(-14, 25, 6),
        const Point3D(-12, 65, 4),
      ],
      thickness: 5.5,
      color: const Color(0xFFEF4444),
      partKey: 'vasc_gsv',
      nameEn: 'Great Saphenous Vein (GSV Trunk & Varicosities)',
      nameAr: 'الوريد الصافن الكبير (جذع الدوالي ومسار القسطرة)',
    ));

    // Deep Femoral Vein (DVT Site)
    faces.addAll(_buildCylinderMesh(
      p1: const Point3D(15, -55, 0),
      p2: const Point3D(16, 15, 0),
      radius: 8.0,
      color: const Color(0xFF991B1B),
      partKey: 'vasc_dvt_site',
      nameEn: 'Deep Femoral Vein (Deep Vein Thrombosis DVT Site)',
      nameAr: 'الوريد الفخذي العميق (موقع خثرة DVT الحادة)',
      steps: 8,
    ));

    // Spider & Reticular Superficial Veins
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        const Point3D(-8, 30, 12),
        const Point3D(-4, 38, 14),
        const Point3D(4, 35, 14),
        const Point3D(10, 42, 12),
      ],
      thickness: 2.0,
      color: const Color(0xFF7C3AED),
      partKey: 'vasc_spider',
      nameEn: 'Spider & Reticular Micro-Venules',
      nameAr: 'الأوردة العنكبوتية والشبكية الدقيقة',
    ));

    if (isSoloMode && soloPartKey != null) {
      faces = faces.where((f) => f.partKey == soloPartKey).toList();
    }

    // Instruments
    if (instrument == SpecialtyInstrument.evlaLaserFiber) {
      faces.addAll(_buildTubeRibbonMesh(
        points: [
          const Point3D(-12, 60, 5),
          const Point3D(-14, 25, 7),
          const Point3D(-15, -35, 7),
        ],
        thickness: 1.6,
        color: const Color(0xFFFACC15),
        partKey: 'tool_evla_fiber',
        nameEn: '1470nm Radial EVLA Laser Thermal Fiber',
        nameAr: 'ألياف الليزر الوريدي الحراري EVLA 1470nm',
      ));
    } else if (instrument == SpecialtyInstrument.scleroMicroNeedle) {
      faces.addAll(_buildCylinderMesh(
        p1: const Point3D(0, 52, 25),
        p2: const Point3D(0, 38, 14),
        radius: 1.0,
        color: const Color(0xFF38BDF8),
        partKey: 'tool_sclero_needle',
        nameEn: '30G Sclerotherapy Injection Micro-Needle',
        nameAr: 'إبرة حقن تصليب الأوردة المجهرية 30G',
        steps: 4,
      ));
    }

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3D GEOMETRIC PRIMITIVE GENERATION HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  static List<MeshFace3D> _buildEllipsoidMesh({
    required Point3D center,
    required double rx,
    required double ry,
    required double rz,
    required Color color,
    String? partKey,
    String? nameEn,
    String? nameAr,
    int latSteps = 6,
    int lonSteps = 10,
  }) {
    // Elevate subdivisions dynamically to ensure smooth, organic, realistic curvature across all disciplines
    final int effLat = math.max(latSteps * 2, 14);
    final int effLon = math.max(lonSteps * 2, 20);

    final faces = <MeshFace3D>[];
    final grid = <List<Point3D>>[];

    for (int i = 0; i <= effLat; i++) {
      final lat = -math.pi / 2 + (i / effLat) * math.pi;
      final row = <Point3D>[];
      for (int j = 0; j <= effLon; j++) {
        final lon = (j / effLon) * 2 * math.pi;
        final x = center.x + rx * math.cos(lat) * math.cos(lon);
        final y = center.y + ry * math.sin(lat);
        final z = center.z + rz * math.cos(lat) * math.sin(lon);
        row.add(Point3D(x, y, z));
      }
      grid.add(row);
    }

    for (int i = 0; i < effLat; i++) {
      for (int j = 0; j < effLon; j++) {
        final p0 = grid[i][j];
        final p1 = grid[i + 1][j];
        final p2 = grid[i + 1][j + 1];
        final p3 = grid[i][j + 1];

        faces.add(MeshFace3D(
          vertices: [p0, p1, p2, p3],
          baseColor: color,
          partKey: partKey,
          partNameEn: nameEn,
          partNameAr: nameAr,
        ));
      }
    }
    return faces;
  }

  static List<MeshFace3D> _buildCylinderMesh({
    required Point3D p1,
    required Point3D p2,
    required double radius,
    required Color color,
    String? partKey,
    String? nameEn,
    String? nameAr,
    int steps = 8,
    bool isWireframe = false,
  }) {
    // Elevate radial steps to ensure smooth non-faceted vessels, ducts, and hardware
    final int effSteps = math.max(steps * 2, 16);

    final faces = <MeshFace3D>[];
    final axis = (p2 - p1).normalized();
    Point3D perp = const Point3D(0, 1, 0);
    if ((axis.dot(perp)).abs() > 0.9) {
      perp = const Point3D(1, 0, 0);
    }
    final u = axis.cross(perp).normalized();
    final v = axis.cross(u).normalized();

    final ring1 = <Point3D>[];
    final ring2 = <Point3D>[];

    for (int i = 0; i < effSteps; i++) {
      final theta = (i / effSteps) * 2 * math.pi;
      final offset = (u * math.cos(theta) + v * math.sin(theta)) * radius;
      ring1.add(p1 + offset);
      ring2.add(p2 + offset);
    }

    for (int i = 0; i < effSteps; i++) {
      final next = (i + 1) % effSteps;
      faces.add(MeshFace3D(
        vertices: [ring1[i], ring1[next], ring2[next], ring2[i]],
        baseColor: color,
        partKey: partKey,
        partNameEn: nameEn,
        partNameAr: nameAr,
        isWireframe: isWireframe,
      ));
    }

    if (!isWireframe) {
      faces.add(MeshFace3D(
        vertices: List.from(ring1),
        baseColor: color,
        partKey: partKey,
        partNameEn: nameEn,
        partNameAr: nameAr,
      ));
      faces.add(MeshFace3D(
        vertices: List.from(ring2.reversed),
        baseColor: color,
        partKey: partKey,
        partNameEn: nameEn,
        partNameAr: nameAr,
      ));
    }

    return faces;
  }

  static List<MeshFace3D> _buildBoxMesh({
    required Point3D center,
    required double dx,
    required double dy,
    required double dz,
    required Color color,
    String? partKey,
    String? nameEn,
    String? nameAr,
  }) {
    final hx = dx * 0.5;
    final hy = dy * 0.5;
    final hz = dz * 0.5;

    final p0 = Point3D(center.x - hx, center.y - hy, center.z - hz);
    final p1 = Point3D(center.x + hx, center.y - hy, center.z - hz);
    final p2 = Point3D(center.x + hx, center.y + hy, center.z - hz);
    final p3 = Point3D(center.x - hx, center.y + hy, center.z - hz);
    final p4 = Point3D(center.x - hx, center.y - hy, center.z + hz);
    final p5 = Point3D(center.x + hx, center.y - hy, center.z + hz);
    final p6 = Point3D(center.x + hx, center.y + hy, center.z + hz);
    final p7 = Point3D(center.x - hx, center.y + hy, center.z + hz);

    return [
      MeshFace3D(vertices: [p0, p1, p2, p3], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p4, p5, p6, p7], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p0, p4, p7, p3], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p1, p5, p6, p2], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p0, p1, p5, p4], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p3, p2, p6, p7], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
    ];
  }

  static List<MeshFace3D> _buildPrismMesh({
    required Point3D p1,
    required Point3D p2,
    required Point3D p3,
    required double depth,
    required Color color,
    String? partKey,
    String? nameEn,
    String? nameAr,
  }) {
    final dOffset = Point3D(0, 0, depth);
    final p1d = p1 + dOffset;
    final p2d = p2 + dOffset;
    final p3d = p3 + dOffset;

    return [
      MeshFace3D(vertices: [p1, p2, p3], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p3d, p2d, p1d], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p1, p2, p2d, p1d], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p2, p3, p3d, p2d], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
      MeshFace3D(vertices: [p3, p1, p1d, p3d], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr),
    ];
  }

  static List<MeshFace3D> _buildTubeRibbonMesh({
    required List<Point3D> points,
    required double thickness,
    required Color color,
    String? partKey,
    String? nameEn,
    String? nameAr,
  }) {
    final faces = <MeshFace3D>[];
    if (points.length < 2) return faces;

    for (int i = 0; i < points.length - 1; i++) {
      faces.addAll(_buildCylinderMesh(
        p1: points[i],
        p2: points[i + 1],
        radius: thickness * 0.5,
        color: color,
        partKey: partKey,
        nameEn: nameEn,
        nameAr: nameAr,
        steps: 12,
      ));
    }
    return faces;
  }

  static List<MeshFace3D> _buildDiscMesh({
    required Point3D center,
    required Point3D normal,
    required double radius,
    required Color color,
    String? partKey,
    String? nameEn,
    String? nameAr,
    int steps = 16,
  }) {
    Point3D perp = const Point3D(0, 1, 0);
    if ((normal.dot(perp)).abs() > 0.9) {
      perp = const Point3D(1, 0, 0);
    }
    final u = normal.cross(perp).normalized();
    final v = normal.cross(u).normalized();

    final ring = <Point3D>[];
    for (int i = 0; i < steps; i++) {
      final theta = (i / steps) * 2 * math.pi;
      ring.add(center + (u * math.cos(theta) + v * math.sin(theta)) * radius);
    }

    return [
      MeshFace3D(
        vertices: ring,
        baseColor: color,
        partKey: partKey,
        partNameEn: nameEn,
        partNameAr: nameAr,
      ),
    ];
  }
}
