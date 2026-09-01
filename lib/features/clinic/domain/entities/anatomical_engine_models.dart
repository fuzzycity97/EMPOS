import 'dart:ui';
import 'package:flutter/material.dart';

enum AnatomicalSeverity { normal, mild, moderate, severe, critical, treated }

class Anatomical3dVector {
  final double x;
  final double y;
  final double z;

  const Anatomical3dVector(this.x, this.y, this.z);
}

class AnatomicalRegionData {
  final String id;
  final String labelEn;
  final String labelAr;
  final Anatomical3dVector centroid;
  final double radius;
  final AnatomicalSeverity severity;
  final Map<String, dynamic> metadata;

  const AnatomicalRegionData({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    required this.centroid,
    required this.radius,
    this.severity = AnatomicalSeverity.normal,
    this.metadata = const {},
  });

  AnatomicalRegionData copyWith({
    AnatomicalSeverity? severity,
    Map<String, dynamic>? metadata,
  }) {
    return AnatomicalRegionData(
      id: id,
      labelEn: labelEn,
      labelAr: labelAr,
      centroid: centroid,
      radius: radius,
      severity: severity ?? this.severity,
      metadata: metadata ?? this.metadata,
    );
  }
}

class Specialty3DProfile {
  final String verticalId;
  final String titleEn;
  final String titleAr;
  final List<AnatomicalRegionData> regions;
  final Map<String, Anatomical3dVector> cameraPresets;
  final double defaultFov;

  const Specialty3DProfile({
    required this.verticalId,
    required this.titleEn,
    required this.titleAr,
    required this.regions,
    required this.cameraPresets,
    this.defaultFov = 45.0,
  });
}

class SpecialtyAnatomicalRegistry {
  SpecialtyAnatomicalRegistry._();

  static Specialty3DProfile getProfile(String verticalOrSpecialty) {
    final lower = verticalOrSpecialty.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');

    if (lower.contains('physio') || lower.contains('rehab') || lower.contains('ortho')) {
      return _physiotherapyProfile;
    }
    if (lower.contains('eye') || lower.contains('optom') || lower.contains('ophthal')) {
      return _optometryProfile;
    }
    if (lower.contains('vet') || lower.contains('animal')) {
      return _veterinaryProfile;
    }
    if (lower.contains('clinic') && !lower.contains('dental')) {
      return _generalClinicProfile;
    }
    return _dentalProfile;
  }

  // 1. General Clinic / Triage Mannequin Profile
  static const _generalClinicProfile = Specialty3DProfile(
    verticalId: 'clinic',
    titleEn: '3D Clinical Triage Mannequin',
    titleAr: 'مانيكان الفحص السريري ثلاثي الأبعاد',
    defaultFov: 45.0,
    cameraPresets: {
      'Front Full': Anatomical3dVector(0.0, 0.0, 0.0),
      'Thorax & Abdomen': Anatomical3dVector(0.15, 0.0, 0.0),
      'Posterior View': Anatomical3dVector(0.0, 3.14159, 0.0),
      'Right Lateral': Anatomical3dVector(0.0, 1.5708, 0.0),
      'Left Lateral': Anatomical3dVector(0.0, -1.5708, 0.0),
    },
    regions: [
      AnatomicalRegionData(
        id: 'zone_head',
        labelEn: 'Cranial & Facial Zone',
        labelAr: 'منطقة الرأس والوجه',
        centroid: Anatomical3dVector(0.0, -120.0, 0.0),
        radius: 28.0,
      ),
      AnatomicalRegionData(
        id: 'zone_thorax',
        labelEn: 'Thorax & Cardiopulmonary',
        labelAr: 'الصدر والجهاز التنفسي/القلبي',
        centroid: Anatomical3dVector(0.0, -60.0, 10.0),
        radius: 35.0,
      ),
      AnatomicalRegionData(
        id: 'zone_ruq',
        labelEn: 'Right Upper Quadrant (RUQ)',
        labelAr: 'الربع العلوي الأيمن (الكبد والمرارة)',
        centroid: Anatomical3dVector(-22.0, -10.0, 12.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'zone_luq',
        labelEn: 'Left Upper Quadrant (LUQ)',
        labelAr: 'الربع العلوي الأيسر (المعدة والطحال)',
        centroid: Anatomical3dVector(22.0, -10.0, 12.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'zone_rlq',
        labelEn: 'Right Lower Quadrant (RLQ - Appendix)',
        labelAr: 'الربع السفلي الأيمن (الزائدة الدودية)',
        centroid: Anatomical3dVector(-22.0, 30.0, 12.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'zone_llq',
        labelEn: 'Left Lower Quadrant (LLQ)',
        labelAr: 'الربع السفلي الأيسر (القولون النازل)',
        centroid: Anatomical3dVector(22.0, 30.0, 12.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'zone_pelvis',
        labelEn: 'Pelvis & Reproductive Anatomy',
        labelAr: 'منطقة الحوض',
        centroid: Anatomical3dVector(0.0, 70.0, 5.0),
        radius: 30.0,
      ),
      AnatomicalRegionData(
        id: 'zone_arm_r',
        labelEn: 'Right Upper Extremity',
        labelAr: 'الطرف العلوي الأيمن',
        centroid: Anatomical3dVector(-75.0, -20.0, 0.0),
        radius: 24.0,
      ),
      AnatomicalRegionData(
        id: 'zone_arm_l',
        labelEn: 'Left Upper Extremity',
        labelAr: 'الطرف العلوي الأيسر',
        centroid: Anatomical3dVector(75.0, -20.0, 0.0),
        radius: 24.0,
      ),
      AnatomicalRegionData(
        id: 'zone_leg_r',
        labelEn: 'Right Lower Extremity',
        labelAr: 'الطرف السفلي الأيمن',
        centroid: Anatomical3dVector(-35.0, 140.0, 0.0),
        radius: 28.0,
      ),
      AnatomicalRegionData(
        id: 'zone_leg_l',
        labelEn: 'Left Lower Extremity',
        labelAr: 'الطرف السفلي الأيسر',
        centroid: Anatomical3dVector(35.0, 140.0, 0.0),
        radius: 28.0,
      ),
    ],
  );

  // 2. Physiotherapy & Orthopedic Kinetic Chain Profile
  static const _physiotherapyProfile = Specialty3DProfile(
    verticalId: 'physiotherapy_rehab',
    titleEn: 'Articulated Kinetic Skeletal Chain',
    titleAr: 'السلسلة الحركية الهيكلية المفصلية',
    defaultFov: 45.0,
    cameraPresets: {
      'Full Kinetic Chain': Anatomical3dVector(0.0, 0.0, 0.0),
      'Spine Sagittal': Anatomical3dVector(0.15, 1.5708, 0.0),
      'Upper Limbs': Anatomical3dVector(0.2, 0.0, 0.0),
      'Lower Kinetic': Anatomical3dVector(-0.2, 0.0, 0.0),
    },
    regions: [
      AnatomicalRegionData(
        id: 'spine_cervical',
        labelEn: 'Cervical Spine (C1-C7)',
        labelAr: 'الفقرات العنقية (C1-C7)',
        centroid: Anatomical3dVector(0.0, -95.0, -5.0),
        radius: 18.0,
      ),
      AnatomicalRegionData(
        id: 'spine_thoracic',
        labelEn: 'Thoracic Spine (T1-T12)',
        labelAr: 'الفقرات الصدرية (T1-T12)',
        centroid: Anatomical3dVector(0.0, -45.0, -8.0),
        radius: 25.0,
      ),
      AnatomicalRegionData(
        id: 'spine_lumbar',
        labelEn: 'Lumbar Spine (L1-L5) & Sacrum',
        labelAr: 'الفقرات القطنية والعجزية (L1-L5)',
        centroid: Anatomical3dVector(0.0, 20.0, -6.0),
        radius: 22.0,
      ),
      AnatomicalRegionData(
        id: 'joint_shoulder_r',
        labelEn: 'Right Glenohumeral Joint (Shoulder)',
        labelAr: 'مفصل الكتف الأيمن',
        centroid: Anatomical3dVector(-60.0, -65.0, 0.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'joint_shoulder_l',
        labelEn: 'Left Glenohumeral Joint (Shoulder)',
        labelAr: 'مفصل الكتف الأيسر',
        centroid: Anatomical3dVector(60.0, -65.0, 0.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'joint_elbow_r',
        labelEn: 'Right Humeroulnar Joint (Elbow)',
        labelAr: 'مفصل الكوع الأيمن',
        centroid: Anatomical3dVector(-85.0, -10.0, 0.0),
        radius: 16.0,
      ),
      AnatomicalRegionData(
        id: 'joint_elbow_l',
        labelEn: 'Left Humeroulnar Joint (Elbow)',
        labelAr: 'مفصل الكوع الأيسر',
        centroid: Anatomical3dVector(85.0, -10.0, 0.0),
        radius: 16.0,
      ),
      AnatomicalRegionData(
        id: 'joint_hip_r',
        labelEn: 'Right Coxafemoral Joint (Hip)',
        labelAr: 'مفصل الفخذ الأيمن',
        centroid: Anatomical3dVector(-35.0, 65.0, 0.0),
        radius: 22.0,
      ),
      AnatomicalRegionData(
        id: 'joint_hip_l',
        labelEn: 'Left Coxafemoral Joint (Hip)',
        labelAr: 'مفصل الفخذ الأيسر',
        centroid: Anatomical3dVector(35.0, 65.0, 0.0),
        radius: 22.0,
      ),
      AnatomicalRegionData(
        id: 'joint_knee_r',
        labelEn: 'Right Tibiofemoral & Patella (Knee)',
        labelAr: 'مفصل الركبة الأيمن والصابونة',
        centroid: Anatomical3dVector(-40.0, 130.0, 5.0),
        radius: 18.0,
      ),
      AnatomicalRegionData(
        id: 'joint_knee_l',
        labelEn: 'Left Tibiofemoral & Patella (Knee)',
        labelAr: 'مفصل الركبة الأيسر والصابونة',
        centroid: Anatomical3dVector(40.0, 130.0, 5.0),
        radius: 18.0,
      ),
      AnatomicalRegionData(
        id: 'joint_ankle_r',
        labelEn: 'Right Talocrural Joint & Foot',
        labelAr: 'مفصل الكاحل والقدم الأيمن',
        centroid: Anatomical3dVector(-42.0, 190.0, 0.0),
        radius: 16.0,
      ),
      AnatomicalRegionData(
        id: 'joint_ankle_l',
        labelEn: 'Left Talocrural Joint & Foot',
        labelAr: 'مفصل الكاحل والقدم الأيسر',
        centroid: Anatomical3dVector(42.0, 190.0, 0.0),
        radius: 16.0,
      ),
    ],
  );

  // 3. Ophthalmology & Optometry Ocular Globe Cross-Section Profile
  static const _optometryProfile = Specialty3DProfile(
    verticalId: 'optometry_clinic',
    titleEn: 'Sagittal Ocular Globe Cross-Section',
    titleAr: 'مقطع سهمي للكرة العينية',
    defaultFov: 40.0,
    cameraPresets: {
      'Sagittal Cross-Section': Anatomical3dVector(0.0, 0.0, 0.0),
      'Anterior Segment': Anatomical3dVector(0.2, 0.4, 0.0),
      'Posterior Pole & Retina': Anatomical3dVector(0.0, -1.2, 0.0),
      'Oblique Perspective': Anatomical3dVector(0.35, 0.65, 0.0),
    },
    regions: [
      AnatomicalRegionData(
        id: 'eye_cornea',
        labelEn: 'Cornea & Epithelium',
        labelAr: 'القرنية والظهارة',
        centroid: Anatomical3dVector(90.0, 0.0, 0.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'eye_anterior_chamber',
        labelEn: 'Anterior Chamber & Trabecular Meshwork',
        labelAr: 'الغرفة الأمامية وزاوية التصريف',
        centroid: Anatomical3dVector(70.0, 0.0, 0.0),
        radius: 16.0,
      ),
      AnatomicalRegionData(
        id: 'eye_iris_pupil',
        labelEn: 'Iris & Pupil Aperture',
        labelAr: 'القزحية وبؤبؤ العين',
        centroid: Anatomical3dVector(55.0, 18.0, 0.0),
        radius: 14.0,
      ),
      AnatomicalRegionData(
        id: 'eye_lens',
        labelEn: 'Crystalline Lens & Zonules',
        labelAr: 'العدسة البلورية والأربطة المعلقة',
        centroid: Anatomical3dVector(40.0, 0.0, 0.0),
        radius: 18.0,
      ),
      AnatomicalRegionData(
        id: 'eye_vitreous',
        labelEn: 'Vitreous Humor Body',
        labelAr: 'الجسم الزجاجي',
        centroid: Anatomical3dVector(-15.0, 0.0, 0.0),
        radius: 35.0,
      ),
      AnatomicalRegionData(
        id: 'eye_retina',
        labelEn: 'Retinal Layer & Choroid',
        labelAr: 'طبقة الشبكية والمشيمية',
        centroid: Anatomical3dVector(-75.0, 25.0, 0.0),
        radius: 22.0,
      ),
      AnatomicalRegionData(
        id: 'eye_macula',
        labelEn: 'Macula & Fovea Centralis',
        labelAr: 'البقعة الصفراء والنقرة المركزية',
        centroid: Anatomical3dVector(-85.0, 0.0, 0.0),
        radius: 14.0,
      ),
      AnatomicalRegionData(
        id: 'eye_optic_nerve',
        labelEn: 'Optic Nerve Disc (CN II)',
        labelAr: 'العصب البصري والقرص البصري',
        centroid: Anatomical3dVector(-115.0, -20.0, 0.0),
        radius: 18.0,
      ),
    ],
  );

  // 4. Veterinary Quadruped Profile
  static const _veterinaryProfile = Specialty3DProfile(
    verticalId: 'veterinary_clinic',
    titleEn: 'Quadruped Anatomical Silhouette',
    titleAr: 'الهيكل التشريحي للحيوانات الأليفة',
    defaultFov: 45.0,
    cameraPresets: {
      'Lateral Profile': Anatomical3dVector(0.0, 0.0, 0.0),
      'Dorsal View': Anatomical3dVector(1.4, 0.0, 0.0),
      'Cranial/Facial': Anatomical3dVector(0.2, 1.2, 0.0),
      'Caudal/Pelvic': Anatomical3dVector(0.2, -1.2, 0.0),
    },
    regions: [
      AnatomicalRegionData(
        id: 'vet_cranial',
        labelEn: 'Cranial & Muzzle Zone',
        labelAr: 'منطقة الرأس والفك',
        centroid: Anatomical3dVector(110.0, -45.0, 0.0),
        radius: 24.0,
      ),
      AnatomicalRegionData(
        id: 'vet_cervical',
        labelEn: 'Cervical Spine & Neck',
        labelAr: 'الرقبة والفقرات العنقية',
        centroid: Anatomical3dVector(75.0, -25.0, 0.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'vet_thoracic',
        labelEn: 'Thorax, Heart & Lungs',
        labelAr: 'القفص الصدري والرئتين',
        centroid: Anatomical3dVector(35.0, -5.0, 0.0),
        radius: 30.0,
      ),
      AnatomicalRegionData(
        id: 'vet_abdominal',
        labelEn: 'Abdominal Viscera',
        labelAr: 'الأحشاء البطنية',
        centroid: Anatomical3dVector(-25.0, -2.0, 0.0),
        radius: 28.0,
      ),
      AnatomicalRegionData(
        id: 'vet_pelvic',
        labelEn: 'Pelvis & Caudal Spine',
        labelAr: 'الحوض والذيل',
        centroid: Anatomical3dVector(-85.0, -20.0, 0.0),
        radius: 25.0,
      ),
      AnatomicalRegionData(
        id: 'vet_forelimb_r',
        labelEn: 'Right Forelimb & Paw',
        labelAr: 'الطرف الأمامي الأيمن',
        centroid: Anatomical3dVector(45.0, 60.0, -15.0),
        radius: 18.0,
      ),
      AnatomicalRegionData(
        id: 'vet_forelimb_l',
        labelEn: 'Left Forelimb & Paw',
        labelAr: 'الطرف الأمامي الأيسر',
        centroid: Anatomical3dVector(45.0, 60.0, 15.0),
        radius: 18.0,
      ),
      AnatomicalRegionData(
        id: 'vet_hindlimb_r',
        labelEn: 'Right Hindlimb & Hock',
        labelAr: 'الطرف الخلفي الأيمن',
        centroid: Anatomical3dVector(-75.0, 65.0, -15.0),
        radius: 20.0,
      ),
      AnatomicalRegionData(
        id: 'vet_hindlimb_l',
        labelEn: 'Left Hindlimb & Hock',
        labelAr: 'الطرف الخلفي الأيسر',
        centroid: Anatomical3dVector(-75.0, 65.0, 15.0),
        radius: 20.0,
      ),
    ],
  );

  // 5. Default Dental Profile fallback
  static const _dentalProfile = Specialty3DProfile(
    verticalId: 'dental_clinic',
    titleEn: '3D Odontogram Arch',
    titleAr: 'مخطط الأسنان ثلاثي الأبعاد',
    defaultFov: 45.0,
    cameraPresets: {
      'Front 3D': Anatomical3dVector(0.35, 0.0, 0.0),
      'Upper Arch': Anatomical3dVector(1.15, 0.0, 0.0),
      'Lower Arch': Anatomical3dVector(-1.15, 0.0, 0.0),
      'Right Sagittal': Anatomical3dVector(0.15, 1.35, 0.0),
      'Left Sagittal': Anatomical3dVector(0.15, -1.35, 0.0),
    },
    regions: [],
  );
}
