import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'clinical_3d_engine_core.dart';

/// 3D Anatomical Mesh Generators for Medical Disciplines with Age Progression
class Specialty3dAnatomicalModels {
  // ─────────────────────────────────────────────────────────────────────────
  // 1. CARDIOLOGY & CORONARY TREE 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildCardiologyMesh(ClinicalAgeStage stage) {
    final faces = <MeshFace3D>[];

    // Age-specific geometry factors
    final double hypertrophy = stage == ClinicalAgeStage.geriatric ? 1.25 : (stage == ClinicalAgeStage.infant ? 0.75 : 1.0);
    final double calcification = stage == ClinicalAgeStage.geriatric ? 1.0 : 0.0;
    final bool isInfant = stage == ClinicalAgeStage.infant;

    // Aorta color shifts towards yellowish/calcified in geriatric
    final Color aortaColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFFE2A06E) : const Color(0xFFDC2626);
    final Color myocardiumColor = stage == ClinicalAgeStage.geriatric ? const Color(0xFF991B1B) : const Color(0xFFB91C1C);

    // Left Ventricle (LV) & Myocardium
    final lvRadius = 45.0 * hypertrophy;
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(18, 25, 0),
      rx: lvRadius * 0.85,
      ry: lvRadius * 1.15,
      rz: lvRadius * 0.9,
      color: myocardiumColor,
      partKey: 'cardio_lv',
      nameEn: 'Left Ventricle & Myocardium',
      nameAr: 'البطين الأيسر وعضلة القلب',
      latSteps: 8,
      lonSteps: 12,
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

    // Infant: Patent Ductus Arteriosus (PDA) link between pulmonary trunk & aorta
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
    // Left Anterior Descending (LAD) traversing the anterior interventricular groove
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

    // Left Circumflex (LCx)
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

    // Right Coronary Artery (RCA)
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

    // Heart Valves (Mitral & Aortic)
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

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. PHYSIOTHERAPY & KINETIC MUSCULAR 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildPhysiotherapyMesh(ClinicalAgeStage stage) {
    final faces = <MeshFace3D>[];

    // Muscle bulk factor by age
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

    // Rectus Abdominis & Core (6-pack blocks)
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

    // Gluteus & Pelvis
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-18 * bulk, 32, -10),
      rx: 19 * bulk,
      ry: 18 * bulk,
      rz: 15 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97140_glut',
      nameEn: 'Gluteus Maximus & Medius',
      nameAr: 'عضلات المقعدة والحوض',
      latSteps: 6,
      lonSteps: 8,
    ));
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(18 * bulk, 32, -10),
      rx: 19 * bulk,
      ry: 18 * bulk,
      rz: 15 * bulk,
      color: muscleColor,
      partKey: 'physio_PT-97140_glut',
      nameEn: 'Gluteus Maximus & Medius',
      nameAr: 'عضلات المقعدة والحوض',
      latSteps: 6,
      lonSteps: 8,
    ));

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

    // Gastrocnemius & Achilles Tendon
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

    // Achilles Tendon insertion
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

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. GASTROENTEROLOGY & DIGESTIVE SYSTEM 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildGastroenterologyMesh(ClinicalAgeStage stage) {
    final faces = <MeshFace3D>[];

    // Infant stomach is more horizontal and higher; geriatric stomach has atrophic folds and colonic diverticula
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

    // Stomach (Curved J-shaped pouch)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-18, -25 + (stomachTilt * 20), 8),
      rx: 28,
      ry: 24,
      rz: 20,
      color: stomachColor,
      partKey: 'gi_GI-43239',
      nameEn: 'Stomach (المعدة)',
      nameAr: 'المعدة والحرقة الهضمية',
      latSteps: 7,
      lonSteps: 10,
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

    // Liver (Right Lobe & Left Lobe)
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

    // Gallbladder (Pear-shaped green reservoir under the liver)
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

    // Pancreas (Retroperitoneal gland behind the stomach)
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

    // Large Intestines (Colon: Ascending, Transverse, Descending)
    // Ascending Colon
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
    // Transverse Colon
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
    // Descending & Sigmoid Colon
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
    faces.addAll(_buildCylinderMesh(
      p1: Point3D(-34, 42, 0),
      p2: Point3D(-6, 68, -4),
      radius: 10,
      color: const Color(0xFFD97706),
      partKey: 'gi_GI-45385',
      nameEn: 'Large Intestines (Colon)',
      nameAr: 'القولون والأمعاء الغليظة',
      steps: 8,
    ));

    // Cecum & Appendix (Lower right quadrant)
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

    // Central Small Intestines (Jejunum & Ileum convoluted coils)
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(0, 24, 6),
      rx: 24,
      ry: 22,
      rz: 14,
      color: const Color(0xFFFDE68A),
      partKey: 'gi_GI-44360',
      nameEn: 'Duodenum & Small Bowel',
      nameAr: 'الاثني عشر والأمعاء الدقيقة',
      latSteps: 6,
      lonSteps: 9,
    ));

    return faces;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. DERMATOLOGY & SKIN CROSS-SECTION 3D MESH GENERATOR
  // ─────────────────────────────────────────────────────────────────────────
  static List<MeshFace3D> buildDermatologyMesh(ClinicalAgeStage stage) {
    final faces = <MeshFace3D>[];

    // Thickness & wrinkle factors
    final double epidermalThickness = stage == ClinicalAgeStage.infant ? 4.0 : (stage == ClinicalAgeStage.geriatric ? 5.0 : 8.0);
    final double dermalThickness = stage == ClinicalAgeStage.geriatric ? 28.0 : (stage == ClinicalAgeStage.child ? 30.0 : 42.0);
    final double fatThickness = stage == ClinicalAgeStage.geriatric ? 22.0 : (stage == ClinicalAgeStage.infant ? 38.0 : 32.0);

    final double width = 110.0;
    final double depth = 70.0;

    // 1. Stratum Corneum & Epidermis Layer (Top)
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

    // 2. Dermis (Collagen & Elastin network)
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

    // 3. Hypodermis / Subcutaneous Fat (Adipose tissue)
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

    // 4. Hair Follicle & Hair Shaft
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
    // Hair Bulb
    faces.addAll(_buildEllipsoidMesh(
      center: Point3D(-12, dermalThickness * 0.4 + 4, 0),
      rx: 6.5,
      ry: 7.5,
      rz: 6.5,
      color: const Color(0xFF78350F),
      partKey: 'derma_scalp',
      nameEn: 'Scalp & Hair Follicles',
      nameAr: 'فروة الرأس وبصيلات الشعر',
      latSteps: 5,
      lonSteps: 7,
    ));

    // 5. Sebaceous Gland (Attached to follicle)
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

    // 6. Eccrine Sweat Gland (Coiled tubule in deep dermis)
    faces.addAll(_buildTubeRibbonMesh(
      points: [
        Point3D(24, -dermalThickness * 0.5 - 4, 10),
        Point3D(26, -dermalThickness * 0.1, 12),
        Point3D(22, dermalThickness * 0.2, 10),
        Point3D(28, dermalThickness * 0.4, 14),
        Point3D(24, dermalThickness * 0.5, 8),
      ],
      thickness: 3.0,
      color: const Color(0xFF38BDF8),
      partKey: 'derma_trunk',
      nameEn: 'Eccrine Sweat Gland Tubule',
      nameAr: 'الغدد العرقية الأنبوبية',
    ));

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
      ));
    }

    // Caps
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
      MeshFace3D(vertices: [p0, p1, p2, p3], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr), // back
      MeshFace3D(vertices: [p4, p5, p6, p7], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr), // front
      MeshFace3D(vertices: [p0, p4, p7, p3], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr), // left
      MeshFace3D(vertices: [p1, p5, p6, p2], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr), // right
      MeshFace3D(vertices: [p0, p1, p5, p4], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr), // top
      MeshFace3D(vertices: [p3, p2, p6, p7], baseColor: color, partKey: partKey, partNameEn: nameEn, partNameAr: nameAr), // bottom
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
