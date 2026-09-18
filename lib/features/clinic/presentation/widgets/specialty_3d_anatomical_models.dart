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
  microneedle('Microneedling Dermaroller', 'بكرة الإبر الدقيقة للجلد');

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
    final faces = <MeshFace3D>[];
    final grid = <List<Point3D>>[];

    for (int i = 0; i <= latSteps; i++) {
      final lat = -math.pi / 2 + (i / latSteps) * math.pi;
      final row = <Point3D>[];
      for (int j = 0; j <= lonSteps; j++) {
        final lon = (j / lonSteps) * 2 * math.pi;
        final x = center.x + rx * math.cos(lat) * math.cos(lon);
        final y = center.y + ry * math.sin(lat);
        final z = center.z + rz * math.cos(lat) * math.sin(lon);
        row.add(Point3D(x, y, z));
      }
      grid.add(row);
    }

    for (int i = 0; i < latSteps; i++) {
      for (int j = 0; j < lonSteps; j++) {
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

    for (int i = 0; i < steps; i++) {
      final theta = (i / steps) * 2 * math.pi;
      final offset = (u * math.cos(theta) + v * math.sin(theta)) * radius;
      ring1.add(p1 + offset);
      ring2.add(p2 + offset);
    }

    for (int i = 0; i < steps; i++) {
      final next = (i + 1) % steps;
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
        steps: 6,
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
    int steps = 8,
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
