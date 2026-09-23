// ignore_for_file: unused_element
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../domain/entities/anatomical_annotation_models.dart';
import '../../domain/entities/procedure_item.dart';
import '../../domain/entities/tooth_chart_entry.dart';
import 'cardiology_vascular_action_widget.dart';
import 'clinical_status_inspector_modal.dart';
import 'dental_tooth_matrix_widget.dart';
import 'dermatology_action_widget.dart';
import 'ophthalmology_action_widget.dart';
import 'skeletal_bone_3d_canvas_widget.dart';
import 'clinical_3d_engine_core.dart';
import 'specialty_3d_anatomical_models.dart';
import '../../domain/entities/clinical_anatomy_status_entry.dart';
import '../../domain/entities/specialty_instrument_registry.dart';
import 'doctor_attachments_lightbox.dart';
import '../../../../core/localization/app_language.dart';

/// Supported Clinical Anatomical Disciplines across 7 Major Medical Groups
enum ClinicalSpecialtyDiscipline {
  // 1. Head, Brain & Neurological Specialties
  neurology,
  neuroOtology,
  neuroPsychiatry,

  // 2. Eye, ENT, Dental & Face Clinics
  ophthalmology,
  rhinologyEnt,
  dental,

  // 3. Cardiovascular, Thoracic & Vein Clinics
  cardiology,
  vascularVein,
  pulmonology,
  endocrinology,

  // 4. Abdominal, Pelvic & Endocrine Clinics
  gastroenterology,
  urology,
  obgyn,

  // 5. Musculoskeletal, Sports & Physical Rehab
  orthopedics,
  physiotherapy,
  podiatry,

  // 6. Plastic Surgery, Aesthetics & Dermatology
  plasticSurgery,
  medicalAesthetics,
  dermatology,

  // 7. Interventional Pain, Anesthesia & Allied Specialties
  painManagement,
  acupuncture,
  speechPathology,

  // 8. Specialized, Laboratory & Allied Professions
  veterinary,
  diagnosticLab,
  mentalHealth,
  pediatrics,

  // Universal
  general;

  String get renderMode => SpecialtyInstrumentRegistry.getRenderMode(this);
  bool get is3D => renderMode == '3D';
  bool get is2D => renderMode == '2D';
}

/// Eye Anatomical Layer Filter (Ophthalmology)
enum EyeAnatomicalLayer {
  all('All Layers (كل الطبقات)', 'Comprehensive composite ocular structure'),
  fibrous('1. Fibrous Outer Layer (الطبقة الليفية الخارجية)', 'Cornea & Sclera (القرنية والصلبة)'),
  uvea('2. Vascular Uvea (الطبقة الوعائية المتوسطة)', 'Iris, Ciliary Body & Choroid (القزحية والجسم الهدبي والمشيمية)'),
  retina('3. Sensory Retina (الطبقة العصبية الداخلية)', 'Retina, Macula, Fovea & Optic Nerve (الشبكية والبقعة الصفراء والعصب البصري)'),
  media('4. Optical Media (الأوساط الكاسرة الداخلية)', 'Crystalline Lens & Vitreous Body (العدسة البلورية والجسم الزجاجي)');

  final String rawLabel;
  final String rawDescription;
  const EyeAnatomicalLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Neurology & Neurosurgery Layer Filter
enum NeurologyLayer {
  all('All Layers (جميع الطبقات)', 'Complete intracranial brain & cerebrovascular system'),
  cortical('1. Cortical Lobes (فصوص القشرة المخية)', 'Frontal, Parietal, Temporal & Occipital lobes'),
  ventricular('2. Ventricles & CSF (البطينات المخية وسائله)', 'Lateral, 3rd & 4th Ventricles and CSF pathways'),
  basalGanglia('3. Basal Ganglia (العقد القاعدية والمهاد)', 'Caudate, Putamen, Globus Pallidus & Thalamus'),
  cranialNerves('4. Cranial Nerves I–XII (الأعصاب القحفية)', 'Olfactory to Hypoglossal nerve roots & brainstem'),
  vascular('5. Circle of Willis (الدورة الدماغية ويلس)', 'Internal Carotid, MCA, ACA, Basilar & Vertebral net');

  final String rawLabel;
  final String rawDescription;
  const NeurologyLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Neuro-Otology & Balance Layer Filter
enum NeuroOtologyLayer {
  all('All Structures (كل الأجهزة)', 'Complete vestibular apparatus & temporal bone'),
  cochlea('1. Cochlea & Hearing (القوقعة والعضو السمعي)', 'Organ of Corti & basilar membrane'),
  canals('2. Semicircular Canals (القنوات الهلالية)', 'Anterior, Posterior & Horizontal canals'),
  otoliths('3. Otolith Organs (أعضاء التوازن الصخرية)', 'Utricle & Saccule balance crystals'),
  nerve('4. Vestibulocochlear CN VIII (عصب التوازن)', 'Vestibular & acoustic nerve trunks');

  final String rawLabel;
  final String rawDescription;
  const NeuroOtologyLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Neuro-Psychiatry & TMS Layer Filter
enum NeuroPsychiatryLayer {
  all('All Networks (جميع الشبكات)', 'Functional neuro-behavioral brain networks'),
  prefrontal('1. Prefrontal Cortex (القشرة الجبهية DLPFC)', 'Executive control & depression TMS target'),
  limbic('2. Limbic System (الجهاز النطاقي والوجداني)', 'Amygdala, Hippocampus & emotional processing'),
  dmn('3. Default Mode Network (شبكة الوضع الافتراضي)', 'Self-referential thought & rumination circuits');

  final String rawLabel;
  final String rawDescription;
  const NeuroPsychiatryLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Rhinology & Sinus (ENT) Layer Filter
enum RhinologyLayer {
  all('All Airway Structures (كل المسالك الأنفية)', 'Complete paranasal sinuses & nasal cavity'),
  septum('1. Nasal Septum (الحاجز الأنفي)', 'Cartilaginous & bony septum partition'),
  turbinates('2. Turbinates (القرنيات الأنفية)', 'Inferior, Middle & Superior turbinates'),
  sinuses('3. Paranasal Sinuses (الجيوب الأنفية الأربعة)', 'Maxillary, Frontal, Ethmoid & Sphenoid sinuses'),
  nasopharynx('4. Nasopharynx (البلعوم الأنفي)', 'Eustachian tube orifice & adenoid bed');

  final String rawLabel;
  final String rawDescription;
  const RhinologyLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Pulmonology & Respiratory Layer Filter
enum PulmonologyLayer {
  all('All Bronchopulmonary (الجهاز التنفسي كاملاً)', 'Complete tracheobronchial tree & lung parenchyma'),
  airways('1. Conductive Airways (الشعب والقصبة الهوائية)', 'Trachea, Carina & Mainstem Bronchi'),
  parenchyma('2. Lung Segments (أنسجة وفصوص الرئتين)', 'Upper, Middle & Lower lobes and alveoli'),
  vasculature('3. Pulmonary Vasculature (أوعية الرئة)', 'Pulmonary arterial branches & venous return'),
  pleura('4. Pleural Space & Diaphragm (الغشاء البلوري)', 'Visceral & Parietal pleura and diaphragm dome');

  final String rawLabel;
  final String rawDescription;
  const PulmonologyLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Urology & Men\'s Health Layer Filter
enum UrologyLayer {
  all('All Genitourinary (الجهاز البولي والتناسلي)', 'Complete urinary tract & male pelvis'),
  kidney('1. Renal Cortex & Pelvis (الكلية وحوضها)', 'Glomerular cortex, pyramids & collecting calyces'),
  uretersBladder('2. Ureters & Bladder (الحالب والمثانة)', 'Ureteric peristaltic tubes & detrusor wall'),
  prostate('3. Prostate Zonal Anatomy (غدة البروستاتا)', 'Peripheral, Transition & Central zones');

  final String rawLabel;
  final String rawDescription;
  const UrologyLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Obstetrics, Gynecology & Fertility (REI) Layer Filter
enum ObGynLayer {
  all('All Pelvic & Fetal (الأعضاء الحوضية والجنين)', 'Complete female reproductive system & fetal model'),
  uterus('1. Uterine Wall & Cavity (الرحم وبطانته)', 'Myometrium muscle & endometrial lining'),
  adnexa('2. Ovaries & Tubes (المبيضان وقناتا فالوب)', 'Antral follicles, corpus luteum & fimbriae'),
  pelvicFloor('3. Pelvic Floor & Cervix (قاع الحوض وعنق الرحم)', 'Levator ani support & cervical os'),
  fetal('4. Multi-Stage Fetal Growth (تطور الجنين)', '1st, 2nd & 3rd Trimester biometric tracking');

  final String rawLabel;
  final String rawDescription;
  const ObGynLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Plastic Surgery & Aesthetics Layer Filter
enum PlasticAestheticsLayer {
  all('All Soft Tissue Layers (كل طبقات الأنسجة الرخوة)', 'Complete craniofacial anatomical strata'),
  skin('1. Cutaneous Skin (الجلد والطبقات السطحية)', 'Epidermis, Dermis & skin tension lines'),
  fatPads('2. Facial Fat Compartments (الوسائد الدهنية)', 'Superficial & deep malar fat pads'),
  smas('3. SMAS & Mimetic Muscles (طبقة سماص والعضلات)', 'Superficial Muscular Aponeurotic System'),
  dangerZones('4. Neurovascular Danger Zones (مناطق الخطر)', 'Facial/Angular arteries & motor nerve branches');

  final String rawLabel;
  final String rawDescription;
  const PlasticAestheticsLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Interventional Pain & Acupuncture Layer Filter
enum PainAcupunctureLayer {
  all('All Spinal & Meridian (العمود الفقري ومسارات الطاقة)', 'Neuro-spinal axis & acupuncture meridians'),
  spine('1. Vertebrae & Facets (الفقرات والمفاصل الوجيهية)', 'Spinal column, pedicles & facet joints'),
  epidural('2. Epidural & Nerve Roots (الفضاء فوق الجافية)', 'Epidural space, dura mater & dorsal root ganglia'),
  meridians('3. Acupuncture Meridians (مسارات وخز الإبر)', 'Traditional meridians, acupoints & trigger points');

  final String rawLabel;
  final String rawDescription;
  const PainAcupunctureLayer(this.rawLabel, this.rawDescription);

  String get label {
    if (AppLanguage.isArabic) {
      return rawLabel;
    } else {
      if (rawLabel.contains('(')) {
        return rawLabel.split('(')[0].trim();
      }
      return rawLabel;
    }
  }

  String get description {
    if (AppLanguage.isArabic) {
      return rawDescription;
    } else {
      if (rawDescription.contains('(')) {
        return rawDescription.split('(')[0].trim();
      }
      return rawDescription;
    }
  }
}

/// Veterinary Quadruped Layer Filter
enum VeterinaryLayer {
  all('All Anatomical Systems (جميع الأجهزة التشريحية)', 'Composite quadruped musculoskeletal & visceral frame'),
  skeletal('1. Skeletal & Axial Frame (الهيكل العظمي المحوري)', 'Canine/feline skull, cervical spine, ribs & limbs'),
  visceral('2. Visceral Organs (الأحشاء والصدر)', 'Cardiopulmonary silhouette, liver, stomach & kidneys'),
  dental('3. Veterinary Dentition (أسنان الحيوان)', 'Canine 42-tooth / Feline 30-tooth dental formula');

  final String rawLabel;
  final String rawDescription;
  const VeterinaryLayer(this.rawLabel, this.rawDescription);

  String get label => AppLanguage.isArabic ? rawLabel : (rawLabel.contains('(') ? rawLabel.split('(')[0].trim() : rawLabel);
  String get description => AppLanguage.isArabic ? rawDescription : (rawDescription.contains('(') ? rawDescription.split('(')[0].trim() : rawDescription);
}

/// Diagnostic Laboratory & Pathology Layer Filter
enum DiagnosticLabLayer {
  all('All Diagnostic Views (جميع الفحوصات التشخيصية)', 'Cellular cytology, biopsy histology & DICOM slices'),
  cytology('1. Cytology Smear (مسحة الخلايا الدموية)', 'Differential count, RBC morphology & blast evaluation'),
  histology('2. Tissue Histology (الأنسجة المرضية)', 'Biopsy micro-architecture & surgical margin evaluation'),
  dicom('3. DICOM Multi-Slice (شرائح التصوير الطبي)', 'Multi-planar reconstruction (Axial, Coronal, Sagittal)');

  final String rawLabel;
  final String rawDescription;
  const DiagnosticLabLayer(this.rawLabel, this.rawDescription);

  String get label => AppLanguage.isArabic ? rawLabel : (rawLabel.contains('(') ? rawLabel.split('(')[0].trim() : rawLabel);
  String get description => AppLanguage.isArabic ? rawDescription : (rawDescription.contains('(') ? rawDescription.split('(')[0].trim() : rawDescription);
}

/// Mental Health & Neuro-Cognitive Layer Filter
enum MentalHealthLayer {
  all('All Neuro-Cognitive Networks (جميع الشبكات العصبية المعرفية)', 'dlPFC, Limbic, Hippocampus & Brainstem circuits'),
  executive('1. Prefrontal Cortex dlPFC (القشرة الجبهية التنفيذية)', 'Executive function, working memory & behavioral inhibition'),
  limbic('2. Limbic & Amygdala (الجهاز النطاقي واللوزة)', 'Emotional reactivity, trauma response & anxiety circuits'),
  memory('3. Hippocampus & Circuitry (قرن آمون والذاكرة)', 'Episodic memory, neuroplasticity & stress regulation');

  final String rawLabel;
  final String rawDescription;
  const MentalHealthLayer(this.rawLabel, this.rawDescription);

  String get label => AppLanguage.isArabic ? rawLabel : (rawLabel.contains('(') ? rawLabel.split('(')[0].trim() : rawLabel);
  String get description => AppLanguage.isArabic ? rawDescription : (rawDescription.contains('(') ? rawDescription.split('(')[0].trim() : rawDescription);
}

/// Pediatric & Child Development Layer Filter
enum PediatricLayer {
  all('All Pediatric Milestones (جميع المؤشرات التطورية)', 'Growth curves, cranial fontanelles & deciduous teeth'),
  growth('1. WHO Growth Percentiles (منحنيات النمو القياسية)', 'Weight, stature & head circumference percentiles'),
  cranial('2. Cranial Fontanelles (اليافوخ وعظام الجمجمة)', 'Anterior & posterior fontanelle closure, cranial sutures'),
  dentition('3. Primary Deciduous Teeth (الأسنان اللبنية)', '20-tooth primary dental eruption timeline & caries');

  final String rawLabel;
  final String rawDescription;
  const PediatricLayer(this.rawLabel, this.rawDescription);

  String get label => AppLanguage.isArabic ? rawLabel : (rawLabel.contains('(') ? rawLabel.split('(')[0].trim() : rawLabel);
  String get description => AppLanguage.isArabic ? rawDescription : (rawDescription.contains('(') ? rawDescription.split('(')[0].trim() : rawDescription);
}

/// Master Multi-Specialty 3D Anatomical Canvas & Clinical Action Matrix.
/// Persistent stateful architecture with reactive [ValueNotifier] state bindings.
class MultiSpecialtyAnatomyCanvasWidget extends StatefulWidget {
  final StoreBlueprint blueprint;
  final ClinicalSpecialtyDiscipline? initialDiscipline;
  final String doctorName;
  final List<ToothChartEntry>? toothChart;
  final bool isPediatric;
  final void Function(ToothChartEntry updatedEntry)? onToothUpdated;
  final void Function(ProcedureItem procedure, String clinicalNote)? onProcedureApplied;
  final ValueNotifier<ClinicalSpecialtyDiscipline>? disciplineNotifier;
  final ValueNotifier<Map<String, ClinicalAnatomyStatusEntry>>? partStatusesNotifier;
  final ValueNotifier<double>? eyeCdRatioOdNotifier;
  final ValueNotifier<double>? eyeCdRatioOsNotifier;
  final ValueNotifier<List<MedicalAttachment>>? attachmentsNotifier;
  final void Function(ClinicalSpecialtyDiscipline discipline)? onDisciplineChanged;

  const MultiSpecialtyAnatomyCanvasWidget({
    super.key,
    required this.blueprint,
    this.initialDiscipline,
    this.doctorName = 'Dr. Specialist',
    this.toothChart,
    this.isPediatric = false,
    this.onToothUpdated,
    this.onProcedureApplied,
    this.disciplineNotifier,
    this.partStatusesNotifier,
    this.eyeCdRatioOdNotifier,
    this.eyeCdRatioOsNotifier,
    this.attachmentsNotifier,
    this.onDisciplineChanged,
  });

  static ClinicalSpecialtyDiscipline inferDiscipline(StoreBlueprint bp) {
    if (bp.isDental) return ClinicalSpecialtyDiscipline.dental;
    if (bp.isOphthalmology) return ClinicalSpecialtyDiscipline.ophthalmology;
    if (bp.isNeuroOtology) return ClinicalSpecialtyDiscipline.neuroOtology;
    if (bp.isNeuroPsychiatry) return ClinicalSpecialtyDiscipline.neuroPsychiatry;
    if (bp.isNeurology) return ClinicalSpecialtyDiscipline.neurology;
    if (bp.isRhinologySinus || bp.isENT) return ClinicalSpecialtyDiscipline.rhinologyEnt;
    if (bp.isCardiology) return ClinicalSpecialtyDiscipline.cardiology;
    if (bp.isVascularVein) return ClinicalSpecialtyDiscipline.vascularVein;
    if (bp.isPulmonology) return ClinicalSpecialtyDiscipline.pulmonology;
    if (bp.isEndocrinology) return ClinicalSpecialtyDiscipline.endocrinology;
    if (bp.isGastroenterology) return ClinicalSpecialtyDiscipline.gastroenterology;
    if (bp.isUrology) return ClinicalSpecialtyDiscipline.urology;
    if (bp.isObGyn) return ClinicalSpecialtyDiscipline.obgyn;
    if (bp.isOrthopedics) return ClinicalSpecialtyDiscipline.orthopedics;
    if (bp.isPhysiotherapy) return ClinicalSpecialtyDiscipline.physiotherapy;
    if (bp.isPodiatry) return ClinicalSpecialtyDiscipline.podiatry;
    if (bp.isPlasticSurgery) return ClinicalSpecialtyDiscipline.plasticSurgery;
    if (bp.isMedicalAesthetics) return ClinicalSpecialtyDiscipline.medicalAesthetics;
    if (bp.isDermatology) return ClinicalSpecialtyDiscipline.dermatology;
    if (bp.isPainManagement) return ClinicalSpecialtyDiscipline.painManagement;
    if (bp.isAcupuncture) return ClinicalSpecialtyDiscipline.acupuncture;
    if (bp.isSpeechPathology) return ClinicalSpecialtyDiscipline.speechPathology;
    if (bp.isVeterinary) return ClinicalSpecialtyDiscipline.veterinary;
    if (bp.isDiagnosticLab) return ClinicalSpecialtyDiscipline.diagnosticLab;
    if (bp.isMentalHealth) return ClinicalSpecialtyDiscipline.mentalHealth;
    if (bp.isPediatric) return ClinicalSpecialtyDiscipline.pediatrics;
    return ClinicalSpecialtyDiscipline.general;
  }

  @override
  State<MultiSpecialtyAnatomyCanvasWidget> createState() => _MultiSpecialtyAnatomyCanvasWidgetState();
}

class _MultiSpecialtyAnatomyCanvasWidgetState extends State<MultiSpecialtyAnatomyCanvasWidget> {
  StoreBlueprint get blueprint => widget.blueprint;
  String get doctorName => widget.doctorName;
  List<ToothChartEntry>? get toothChart => widget.toothChart;
  bool get isPediatric => widget.isPediatric;
  void Function(ToothChartEntry updatedEntry)? get onToothUpdated => widget.onToothUpdated;
  void Function(ProcedureItem procedure, String clinicalNote)? get onProcedureApplied => widget.onProcedureApplied;

  late ValueNotifier<ClinicalSpecialtyDiscipline> _activeDisciplineNotifier;
  bool _ownsDisciplineNotifier = false;

  late final ValueNotifier<EyeAnatomicalLayer> _eyeLayerNotifier;
  late final ValueNotifier<bool> _eyeRightEyeNotifier;
  late ValueNotifier<double> _eyeCdRatioOdNotifier;
  bool _ownsEyeCdRatioOdNotifier = false;
  late ValueNotifier<double> _eyeCdRatioOsNotifier;
  bool _ownsEyeCdRatioOsNotifier = false;
  late final ValueNotifier<bool> _eyeVisualFieldNotifier;
  late final ValueNotifier<bool> _eyeOctScanNotifier;
  late final ValueNotifier<double> _eyeYawNotifier;
  late final ValueNotifier<double> _eyePitchNotifier;
  late final ValueNotifier<int> _eyeViewModeNotifier;
  late final ValueNotifier<double> _eyeLayerSeparationNotifier;
  late final ValueNotifier<bool> _pinNoteModeNotifier;
  late final ValueNotifier<NeurologyLayer> _neurologyLayerNotifier;
  late final ValueNotifier<NeuroOtologyLayer> _neuroOtologyLayerNotifier;
  late final ValueNotifier<NeuroPsychiatryLayer> _neuroPsychiatryLayerNotifier;
  late final ValueNotifier<RhinologyLayer> _rhinologyLayerNotifier;
  late final ValueNotifier<PulmonologyLayer> _pulmonologyLayerNotifier;
  late final ValueNotifier<UrologyLayer> _urologyLayerNotifier;
  late final ValueNotifier<ObGynLayer> _obGynLayerNotifier;
  late final ValueNotifier<PlasticAestheticsLayer> _plasticLayerNotifier;
  late final ValueNotifier<PainAcupunctureLayer> _painLayerNotifier;
  late final ValueNotifier<VeterinaryLayer> _vetLayerNotifier;
  late final ValueNotifier<bool> _vetIsCanineNotifier;
  late final ValueNotifier<double> _vetYawNotifier;
  late final ValueNotifier<double> _vetPitchNotifier;
  late final ValueNotifier<DiagnosticLabLayer> _labLayerNotifier;
  late final ValueNotifier<String> _labMagNotifier;
  late final ValueNotifier<double> _labFocusDepthNotifier;
  late final ValueNotifier<MentalHealthLayer> _mentalLayerNotifier;
  late final ValueNotifier<double> _mentalYawNotifier;
  late final ValueNotifier<double> _mentalPitchNotifier;
  late final ValueNotifier<int> _mentalPhq9Notifier;
  late final ValueNotifier<int> _mentalGad7Notifier;
  late final ValueNotifier<PediatricLayer> _pediatricLayerNotifier;
  late final ValueNotifier<int> _pediatricAgeMonthsNotifier;
  late final ValueNotifier<double> _pediatricYawNotifier;
  late final ValueNotifier<double> _pediatricPitchNotifier;
  late final ValueNotifier<ClinicalAgeStage> _activeAgeStageNotifier;
  late final ValueNotifier<String?> _selectedPartNotifier;
  late ValueNotifier<Map<String, ClinicalAnatomyStatusEntry>> _partStatusesNotifier;
  bool _ownsPartStatusesNotifier = false;
  late ValueNotifier<List<MedicalAttachment>> _attachmentsNotifier;
  bool _ownsAttachmentsNotifier = false;
  late final ValueNotifier<bool> _showInstrumentTrayNotifier;
  late final ValueNotifier<ClinicalInstrumentCategory?> _selectedInstrumentCategoryNotifier;
  late final ValueNotifier<String?> _selectedInstrumentIdNotifier;

  @override
  void initState() {
    super.initState();
    if (widget.disciplineNotifier != null) {
      _activeDisciplineNotifier = widget.disciplineNotifier!;
      _ownsDisciplineNotifier = false;
    } else {
      _activeDisciplineNotifier = ValueNotifier<ClinicalSpecialtyDiscipline>(
        widget.initialDiscipline ?? MultiSpecialtyAnatomyCanvasWidget.inferDiscipline(widget.blueprint),
      );
      _ownsDisciplineNotifier = true;
    }

    if (widget.partStatusesNotifier != null) {
      _partStatusesNotifier = widget.partStatusesNotifier!;
      _ownsPartStatusesNotifier = false;
    } else {
      _partStatusesNotifier = ValueNotifier<Map<String, ClinicalAnatomyStatusEntry>>({});
      _ownsPartStatusesNotifier = true;
    }

    if (widget.attachmentsNotifier != null) {
      _attachmentsNotifier = widget.attachmentsNotifier!;
      _ownsAttachmentsNotifier = false;
    } else {
      _attachmentsNotifier = ValueNotifier<List<MedicalAttachment>>(_createDefaultMedicalAttachments());
      _ownsAttachmentsNotifier = true;
    }

    if (widget.eyeCdRatioOdNotifier != null) {
      _eyeCdRatioOdNotifier = widget.eyeCdRatioOdNotifier!;
      _ownsEyeCdRatioOdNotifier = false;
    } else {
      _eyeCdRatioOdNotifier = ValueNotifier<double>(0.40);
      _ownsEyeCdRatioOdNotifier = true;
    }

    if (widget.eyeCdRatioOsNotifier != null) {
      _eyeCdRatioOsNotifier = widget.eyeCdRatioOsNotifier!;
      _ownsEyeCdRatioOsNotifier = false;
    } else {
      _eyeCdRatioOsNotifier = ValueNotifier<double>(0.40);
      _ownsEyeCdRatioOsNotifier = true;
    }

    _eyeLayerNotifier = ValueNotifier<EyeAnatomicalLayer>(EyeAnatomicalLayer.all);
    _eyeRightEyeNotifier = ValueNotifier<bool>(true);
    _eyeVisualFieldNotifier = ValueNotifier<bool>(false);
    _eyeOctScanNotifier = ValueNotifier<bool>(false);
    _eyeYawNotifier = ValueNotifier<double>(0.0);
    _eyePitchNotifier = ValueNotifier<double>(0.0);
    _eyeViewModeNotifier = ValueNotifier<int>(0);
    _eyeLayerSeparationNotifier = ValueNotifier<double>(0.35);
    _pinNoteModeNotifier = ValueNotifier<bool>(false);
    _neurologyLayerNotifier = ValueNotifier<NeurologyLayer>(NeurologyLayer.all);
    _neuroOtologyLayerNotifier = ValueNotifier<NeuroOtologyLayer>(NeuroOtologyLayer.all);
    _neuroPsychiatryLayerNotifier = ValueNotifier<NeuroPsychiatryLayer>(NeuroPsychiatryLayer.all);
    _rhinologyLayerNotifier = ValueNotifier<RhinologyLayer>(RhinologyLayer.all);
    _pulmonologyLayerNotifier = ValueNotifier<PulmonologyLayer>(PulmonologyLayer.all);
    _urologyLayerNotifier = ValueNotifier<UrologyLayer>(UrologyLayer.all);
    _obGynLayerNotifier = ValueNotifier<ObGynLayer>(ObGynLayer.all);
    _plasticLayerNotifier = ValueNotifier<PlasticAestheticsLayer>(PlasticAestheticsLayer.all);
    _painLayerNotifier = ValueNotifier<PainAcupunctureLayer>(PainAcupunctureLayer.all);
    _vetLayerNotifier = ValueNotifier<VeterinaryLayer>(VeterinaryLayer.all);
    _vetIsCanineNotifier = ValueNotifier<bool>(true);
    _vetYawNotifier = ValueNotifier<double>(0.0);
    _vetPitchNotifier = ValueNotifier<double>(0.0);
    _labLayerNotifier = ValueNotifier<DiagnosticLabLayer>(DiagnosticLabLayer.all);
    _labMagNotifier = ValueNotifier<String>('40x');
    _labFocusDepthNotifier = ValueNotifier<double>(25.0);
    _mentalLayerNotifier = ValueNotifier<MentalHealthLayer>(MentalHealthLayer.all);
    _mentalYawNotifier = ValueNotifier<double>(0.0);
    _mentalPitchNotifier = ValueNotifier<double>(0.0);
    _mentalPhq9Notifier = ValueNotifier<int>(4);
    _mentalGad7Notifier = ValueNotifier<int>(3);
    _pediatricLayerNotifier = ValueNotifier<PediatricLayer>(PediatricLayer.all);
    _pediatricAgeMonthsNotifier = ValueNotifier<int>(18);
    _pediatricYawNotifier = ValueNotifier<double>(0.0);
    _pediatricPitchNotifier = ValueNotifier<double>(0.0);
    _selectedPartNotifier = ValueNotifier<String?>(null);
    _activeAgeStageNotifier = ValueNotifier<ClinicalAgeStage>(
      widget.isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
    );
    _showInstrumentTrayNotifier = ValueNotifier<bool>(false);
    _selectedInstrumentCategoryNotifier = ValueNotifier<ClinicalInstrumentCategory?>(null);
    _selectedInstrumentIdNotifier = ValueNotifier<String?>(null);
  }

  @override
  void didUpdateWidget(covariant MultiSpecialtyAnatomyCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.disciplineNotifier != oldWidget.disciplineNotifier) {
      if (_ownsDisciplineNotifier) {
        _activeDisciplineNotifier.dispose();
      }
      if (widget.disciplineNotifier != null) {
        _activeDisciplineNotifier = widget.disciplineNotifier!;
        _ownsDisciplineNotifier = false;
      } else {
        _activeDisciplineNotifier = ValueNotifier<ClinicalSpecialtyDiscipline>(
          widget.initialDiscipline ?? oldWidget.initialDiscipline ?? MultiSpecialtyAnatomyCanvasWidget.inferDiscipline(widget.blueprint),
        );
        _ownsDisciplineNotifier = true;
      }
    } else if (widget.initialDiscipline != null && widget.initialDiscipline != oldWidget.initialDiscipline) {
      _activeDisciplineNotifier.value = widget.initialDiscipline!;
    } else if (widget.blueprint != oldWidget.blueprint && _ownsDisciplineNotifier) {
      _activeDisciplineNotifier.value = widget.initialDiscipline ?? MultiSpecialtyAnatomyCanvasWidget.inferDiscipline(widget.blueprint);
    }

    if (widget.partStatusesNotifier != oldWidget.partStatusesNotifier) {
      if (_ownsPartStatusesNotifier) {
        _partStatusesNotifier.dispose();
      }
      if (widget.partStatusesNotifier != null) {
        _partStatusesNotifier = widget.partStatusesNotifier!;
        _ownsPartStatusesNotifier = false;
      } else {
        _partStatusesNotifier = ValueNotifier<Map<String, ClinicalAnatomyStatusEntry>>({});
        _ownsPartStatusesNotifier = true;
      }
    }

    if (widget.attachmentsNotifier != oldWidget.attachmentsNotifier) {
      if (_ownsAttachmentsNotifier) {
        _attachmentsNotifier.dispose();
      }
      if (widget.attachmentsNotifier != null) {
        _attachmentsNotifier = widget.attachmentsNotifier!;
        _ownsAttachmentsNotifier = false;
      } else {
        _attachmentsNotifier = ValueNotifier<List<MedicalAttachment>>(_createDefaultMedicalAttachments());
        _ownsAttachmentsNotifier = true;
      }
    }

    if (widget.eyeCdRatioOdNotifier != oldWidget.eyeCdRatioOdNotifier) {
      if (_ownsEyeCdRatioOdNotifier) {
        _eyeCdRatioOdNotifier.dispose();
      }
      if (widget.eyeCdRatioOdNotifier != null) {
        _eyeCdRatioOdNotifier = widget.eyeCdRatioOdNotifier!;
        _ownsEyeCdRatioOdNotifier = false;
      } else {
        _eyeCdRatioOdNotifier = ValueNotifier<double>(0.40);
        _ownsEyeCdRatioOdNotifier = true;
      }
    }

    if (widget.eyeCdRatioOsNotifier != oldWidget.eyeCdRatioOsNotifier) {
      if (_ownsEyeCdRatioOsNotifier) {
        _eyeCdRatioOsNotifier.dispose();
      }
      if (widget.eyeCdRatioOsNotifier != null) {
        _eyeCdRatioOsNotifier = widget.eyeCdRatioOsNotifier!;
        _ownsEyeCdRatioOsNotifier = false;
      } else {
        _eyeCdRatioOsNotifier = ValueNotifier<double>(0.40);
        _ownsEyeCdRatioOsNotifier = true;
      }
    }
  }

  @override
  void dispose() {
    if (_ownsDisciplineNotifier) {
      _activeDisciplineNotifier.dispose();
    }
    if (_ownsPartStatusesNotifier) {
      _partStatusesNotifier.dispose();
    }
    if (_ownsAttachmentsNotifier) {
      _attachmentsNotifier.dispose();
    }
    if (_ownsEyeCdRatioOdNotifier) {
      _eyeCdRatioOdNotifier.dispose();
    }
    if (_ownsEyeCdRatioOsNotifier) {
      _eyeCdRatioOsNotifier.dispose();
    }
    _eyeLayerNotifier.dispose();
    _eyeRightEyeNotifier.dispose();
    _eyeVisualFieldNotifier.dispose();
    _eyeOctScanNotifier.dispose();
    _eyeYawNotifier.dispose();
    _eyePitchNotifier.dispose();
    _eyeViewModeNotifier.dispose();
    _pinNoteModeNotifier.dispose();
    _neurologyLayerNotifier.dispose();
    _neuroOtologyLayerNotifier.dispose();
    _neuroPsychiatryLayerNotifier.dispose();
    _rhinologyLayerNotifier.dispose();
    _pulmonologyLayerNotifier.dispose();
    _urologyLayerNotifier.dispose();
    _obGynLayerNotifier.dispose();
    _plasticLayerNotifier.dispose();
    _painLayerNotifier.dispose();
    _vetLayerNotifier.dispose();
    _vetIsCanineNotifier.dispose();
    _vetYawNotifier.dispose();
    _vetPitchNotifier.dispose();
    _labLayerNotifier.dispose();
    _labMagNotifier.dispose();
    _labFocusDepthNotifier.dispose();
    _mentalLayerNotifier.dispose();
    _mentalYawNotifier.dispose();
    _mentalPitchNotifier.dispose();
    _mentalPhq9Notifier.dispose();
    _mentalGad7Notifier.dispose();
    _pediatricLayerNotifier.dispose();
    _pediatricAgeMonthsNotifier.dispose();
    _pediatricYawNotifier.dispose();
    _pediatricPitchNotifier.dispose();
    _selectedPartNotifier.dispose();
    _activeAgeStageNotifier.dispose();
    _showInstrumentTrayNotifier.dispose();
    _selectedInstrumentCategoryNotifier.dispose();
    _selectedInstrumentIdNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, currentLocale, _) {
        return _buildCanvasContent(context);
      },
    );
  }

  Widget _buildCanvasContent(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<ClinicalSpecialtyDiscipline>(
      valueListenable: _activeDisciplineNotifier,
      builder: (context, discipline, _) {
        return ValueListenableBuilder<Map<String, ClinicalAnatomyStatusEntry>>(
          valueListenable: _partStatusesNotifier,
          builder: (context, activeStatuses, _) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0B132B) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── SPECIALTY DISCIPLINE HEADER ────────────────────────────────
                  _buildHeader(context, discipline, isDark),
                  _buildUniversalAgeStageBar(context, discipline, isDark),

                  // ── SPECIALTY SPECIFIC ANATOMICAL WORKBENCH ─────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ValueListenableBuilder<bool>(
                          valueListenable: _pinNoteModeNotifier,
                          builder: (context, pinActive, _) {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    _buildSpecialtyContent(context, discipline, isDark, activeStatuses),
                                    if (pinActive && discipline != ClinicalSpecialtyDiscipline.dental)
                                      Positioned.fill(
                                        child: GestureDetector(
                                          behavior: HitTestBehavior.translucent,
                                          onTapUp: (details) {
                                            final w = (constraints.maxWidth.isFinite && constraints.maxWidth > 0) ? constraints.maxWidth : 400.0;
                                            final h = (constraints.maxHeight.isFinite && constraints.maxHeight > 0) ? constraints.maxHeight : 380.0;
                                            final normX = (details.localPosition.dx / w).clamp(0.05, 0.95);
                                            final normY = (details.localPosition.dy / h).clamp(0.05, 0.95);
                                            _openAddCustomPinNoteDialog(context, normX: normX, normY: normY, discipline: discipline);
                                            _pinNoteModeNotifier.value = false;
                                          },
                                          child: Container(
                                            color: _getDisciplineColor(discipline).withValues(alpha: 0.08),
                                            alignment: Alignment.topCenter,
                                            padding: const EdgeInsets.all(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                              decoration: BoxDecoration(
                                                color: _getDisciplineColor(discipline),
                                                borderRadius: BorderRadius.circular(20),
                                                boxShadow: [
                                                  BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8),
                                                ],
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(LucideIcons.crosshair, color: Colors.white, size: 14),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Text(
                                                      AppLanguage.tr('Click anywhere on 3D model to place pin note', 'انقر في أي موضع لتثبيت دبوس الملاحظة (Click anywhere to Pin Note)'),
                                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    // Custom pins placed on the active anatomical model / workbench
                                    if (discipline != ClinicalSpecialtyDiscipline.ophthalmology && discipline != ClinicalSpecialtyDiscipline.dental)
                                      ...activeStatuses.values.where((e) => e.isCustomPin).map((pin) {
                                        final w = (constraints.maxWidth.isFinite && constraints.maxWidth > 0) ? constraints.maxWidth : 400.0;
                                        final h = (constraints.maxHeight.isFinite && constraints.maxHeight > 0) ? constraints.maxHeight : 380.0;
                                        final px = (pin.normalizedX ?? 0.5) * w;
                                        final py = (pin.normalizedY ?? 0.5) * h;
                                        return Positioned(
                                          left: (px - 14).clamp(4.0, (w - 110.0).clamp(4.0, double.infinity)),
                                          top: (py - 14).clamp(4.0, (h - 32.0).clamp(4.0, double.infinity)),
                                          child: _buildCustomPinMarker(context, pin, isDark),
                                        );
                                      }),
                                  ],
                                );
                              },
                            );
                          },
                        ),
                        _buildActiveStatusesTray(context, activeStatuses, isDark),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HEADER WITH SPECIALTY BADGE & MULTI-SPECIALTY SELECTOR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, ClinicalSpecialtyDiscipline discipline, bool isDark) {
    final title = _getDisciplineTitle(discipline);
    final icon = _getDisciplineIcon(discipline);
    final accentColor = _getDisciplineColor(discipline);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D38) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '3D CLINICAL ANATOMY',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  _getDisciplineSubtitle(discipline),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          // Pin Note Mode Button
          ValueListenableBuilder<bool>(
            valueListenable: _pinNoteModeNotifier,
            builder: (context, pinActive, _) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () => _pinNoteModeNotifier.value = !_pinNoteModeNotifier.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: pinActive
                          ? accentColor.withValues(alpha: 0.25)
                          : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: pinActive ? accentColor : (isDark ? Colors.white12 : Colors.black12),
                        width: pinActive ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.pin, size: 13, color: pinActive ? accentColor : (isDark ? Colors.white70 : Colors.black87)),
                        const SizedBox(width: 6),
                        Text(
                          pinActive ? AppLanguage.tr('Pin Mode (Active)', 'وضع الدبوس (نشط)') : AppLanguage.tr('Drop 3D Pin', 'تثبيت دبوس ملاحظة (Pin)'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: pinActive ? accentColor : (isDark ? Colors.white70 : Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Multi-Discipline Switcher (for General Clinics / Polyclinics)
          if (blueprint.isGeneralClinic || !blueprint.isDental)
            PopupMenuButton<ClinicalSpecialtyDiscipline>(
              tooltip: 'Switch Clinical Specialty Viewer',
              icon: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.repeat, size: 13),
                    const SizedBox(width: 6),
                    Text(
                      'Specialty',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              onSelected: (disc) {
                _activeDisciplineNotifier.value = disc;
                widget.onDisciplineChanged?.call(disc);
              },
              itemBuilder: (context) => [
                _buildMenuItem(ClinicalSpecialtyDiscipline.neurology, 'Neurology & Neurosurgery', LucideIcons.brain),
                _buildMenuItem(ClinicalSpecialtyDiscipline.neuroOtology, 'Neuro-Otology & Balance', LucideIcons.ear),
                _buildMenuItem(ClinicalSpecialtyDiscipline.neuroPsychiatry, 'Neuro-Psychiatry & TMS', LucideIcons.activity),
                _buildMenuItem(ClinicalSpecialtyDiscipline.ophthalmology, 'Ophthalmology (3D Eye & Layers)', LucideIcons.eye),
                _buildMenuItem(ClinicalSpecialtyDiscipline.rhinologyEnt, 'Rhinology & Sinus (ENT)', LucideIcons.wind),
                _buildMenuItem(ClinicalSpecialtyDiscipline.dental, 'Dental (FDI Odontogram)', LucideIcons.smile),
                _buildMenuItem(ClinicalSpecialtyDiscipline.cardiology, 'Cardiology (3D Heart & Vessels)', LucideIcons.heartPulse),
                _buildMenuItem(ClinicalSpecialtyDiscipline.vascularVein, 'Vein & Vascular (Phlebology)', LucideIcons.gitFork),
                _buildMenuItem(ClinicalSpecialtyDiscipline.pulmonology, 'Pulmonology (3D Lungs & Airways)', LucideIcons.wind),
                _buildMenuItem(ClinicalSpecialtyDiscipline.endocrinology, 'Endocrinology & Glands', LucideIcons.dna),
                _buildMenuItem(ClinicalSpecialtyDiscipline.gastroenterology, 'Gastroenterology (Digestive Tract)', LucideIcons.utensils),
                _buildMenuItem(ClinicalSpecialtyDiscipline.urology, 'Urology & Men\'s Health', LucideIcons.droplets),
                _buildMenuItem(ClinicalSpecialtyDiscipline.obgyn, 'OB/GYN & Fertility (REI)', LucideIcons.baby),
                _buildMenuItem(ClinicalSpecialtyDiscipline.orthopedics, 'Orthopedics (3D Skeleton & Bones)', LucideIcons.bone),
                _buildMenuItem(ClinicalSpecialtyDiscipline.physiotherapy, 'Physiotherapy & Muscular Rehab', LucideIcons.activity),
                _buildMenuItem(ClinicalSpecialtyDiscipline.podiatry, 'Podiatry & Orthotics (P&O)', LucideIcons.footprints),
                _buildMenuItem(ClinicalSpecialtyDiscipline.plasticSurgery, 'Cosmetic Plastic Surgery', LucideIcons.wand2),
                _buildMenuItem(ClinicalSpecialtyDiscipline.medicalAesthetics, 'Medical Aesthetics (Injectors)', LucideIcons.syringe),
                _buildMenuItem(ClinicalSpecialtyDiscipline.dermatology, 'Dermatology & Skin Lesions', LucideIcons.sparkles),
                _buildMenuItem(ClinicalSpecialtyDiscipline.painManagement, 'Interventional Pain Management', LucideIcons.zap),
                _buildMenuItem(ClinicalSpecialtyDiscipline.acupuncture, 'Acupuncture & Eastern Medicine', LucideIcons.compass),
                _buildMenuItem(ClinicalSpecialtyDiscipline.speechPathology, 'Speech-Language Pathology (SLP)', LucideIcons.mic),
                _buildMenuItem(ClinicalSpecialtyDiscipline.veterinary, 'Veterinary (3D Animal Anatomy)', LucideIcons.heartHandshake),
                _buildMenuItem(ClinicalSpecialtyDiscipline.diagnosticLab, 'Diagnostic Lab (3D Pathology/DICOM)', LucideIcons.flaskConical),
                _buildMenuItem(ClinicalSpecialtyDiscipline.mentalHealth, 'Mental Health (3D Brain Axis)', LucideIcons.smilePlus),
                _buildMenuItem(ClinicalSpecialtyDiscipline.pediatrics, 'Pediatrics (3D Growth & Development)', LucideIcons.baby),
              ],
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UNIVERSAL AGE PROGRESSION SELECTOR BAR (FOR ALL SPECIALTIES)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUniversalAgeStageBar(
    BuildContext context,
    ClinicalSpecialtyDiscipline discipline,
    bool isDark,
  ) {
    return ValueListenableBuilder<ClinicalAgeStage>(
      valueListenable: _activeAgeStageNotifier,
      builder: (context, currentStage, _) {
        final accentColor = _getDisciplineColor(discipline);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
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
                    Icon(LucideIcons.clock, size: 14, color: accentColor),
                    const SizedBox(width: 6),
                    Text(
                      AppLanguage.tr('Patient Age Progression:', 'المرحلة العمرية للمريض:'),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 10),
                ...ClinicalAgeStage.values.map((stage) {
                  final isSel = stage == currentStage;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InkWell(
                      onTap: () {
                        _activeAgeStageNotifier.value = stage;
                        if (stage == ClinicalAgeStage.infant) {
                          _pediatricAgeMonthsNotifier.value = 6;
                        } else if (stage == ClinicalAgeStage.child) {
                          _pediatricAgeMonthsNotifier.value = 36;
                        } else if (stage == ClinicalAgeStage.adolescent) {
                          _pediatricAgeMonthsNotifier.value = 168;
                        }
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSel
                              ? accentColor
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? accentColor
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
                                    ? Colors.white.withValues(alpha: 0.85)
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
        );
      },
    );
  }

  PopupMenuItem<ClinicalSpecialtyDiscipline> _buildMenuItem(
    ClinicalSpecialtyDiscipline disc,
    String label,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: disc,
      child: Row(
        children: [
          Icon(icon, size: 16, color: _getDisciplineColor(disc)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  static List<ToothChartEntry> _getEffectiveToothChart(List<ToothChartEntry>? chart, bool isPediatric) {
    if (chart != null && chart.isNotEmpty) return chart;
    if (isPediatric) {
      return ToothChartEntry.primaryToothCodes.asMap().entries.map((entry) {
        return ToothChartEntry(
          toothNumber: entry.key + 1,
          toothCode: entry.value,
          isDeciduous: true,
          state: ToothState.healthy,
        );
      }).toList();
    }
    return List.generate(
      32,
      (index) => ToothChartEntry(
        toothNumber: index + 1,
        toothCode: '${index + 1}',
        isDeciduous: false,
        state: ToothState.healthy,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // ROUTE TO APPROPRIATE SPECIALTY WORKBENCH
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSpecialtyContent(
    BuildContext context,
    ClinicalSpecialtyDiscipline discipline,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    switch (discipline) {
      case ClinicalSpecialtyDiscipline.dental:
        return DentalToothMatrixWidget(
          toothChart: _getEffectiveToothChart(toothChart, isPediatric),
          isPediatric: isPediatric,
          doctorName: doctorName,
          onToothUpdated: onToothUpdated,
          activeStatuses: activeStatuses,
          isPinMode: _pinNoteModeNotifier.value,
          onCanvasTapToPin: (normX, normY, {toothCode, partName, x3d, y3d, z3d}) {
            _openAddCustomPinNoteDialog(
              context,
              normX: normX,
              normY: normY,
              discipline: ClinicalSpecialtyDiscipline.dental,
              toothCode: toothCode,
              partName: partName,
              x3d: x3d,
              y3d: y3d,
              z3d: z3d,
            );
            _pinNoteModeNotifier.value = false;
          },
          onPinTap: (pin) => _openStatusInspector(
            context,
            partKey: pin.partKey,
            partName: pin.partName,
            partNameAr: pin.partNameAr,
            discipline: ClinicalSpecialtyDiscipline.dental,
          ),
        );

      case ClinicalSpecialtyDiscipline.neurology:
        return _buildNeurologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.neuroOtology:
        return _buildNeuroOtologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
        return _buildNeuroPsychiatryViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.ophthalmology:
        return _buildOphthalmologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.rhinologyEnt:
        return _buildRhinologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.cardiology:
        return _buildCardiologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.vascularVein:
        return _buildVascularVeinViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.pulmonology:
        return _buildPulmonologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.endocrinology:
        return _buildEndocrinologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.gastroenterology:
        return _buildGastroenterologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.urology:
        return _buildUrologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.obgyn:
        return _buildObGynViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.orthopedics:
        return _buildOrthopedicsViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.physiotherapy:
        return _buildPhysiotherapyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.podiatry:
        return _buildPodiatryViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.plasticSurgery:
        return _buildPlasticSurgeryViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return _buildMedicalAestheticsViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.dermatology:
        return _buildDermatologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.painManagement:
        return _buildPainManagementViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.acupuncture:
        return _buildAcupunctureViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.speechPathology:
        return _buildSpeechPathologyViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.veterinary:
        return _buildVeterinaryViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.diagnosticLab:
        return _buildDiagnosticLabViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.mentalHealth:
        return _buildMentalHealthViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.pediatrics:
        return _buildPediatricsViewer(context, isDark, activeStatuses);

      case ClinicalSpecialtyDiscipline.general:
        return _buildGeneralMultiSystemViewer(context, isDark, activeStatuses);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 1. OPHTHALMOLOGY: 3D EYE ANATOMY WITH MULTI-LAYER SWITCHER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOphthalmologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: _eyeRightEyeNotifier,
      builder: (context, isRightEye, _) {
        final activeCdNotifier = isRightEye ? _eyeCdRatioOdNotifier : _eyeCdRatioOsNotifier;

        return ValueListenableBuilder<double>(
          valueListenable: activeCdNotifier,
          builder: (context, cdRatio, _) {
            return ValueListenableBuilder<EyeAnatomicalLayer>(
              valueListenable: _eyeLayerNotifier,
              builder: (context, activeLayer, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: _eyeViewModeNotifier,
                  builder: (context, viewMode, _) {
                    return ValueListenableBuilder<double>(
                      valueListenable: _eyeYawNotifier,
                      builder: (context, yaw, _) {
                        return ValueListenableBuilder<double>(
                          valueListenable: _eyePitchNotifier,
                          builder: (context, pitch, _) {
                            return ValueListenableBuilder<double>(
                              valueListenable: _eyeLayerSeparationNotifier,
                              builder: (context, layerSeparation, _) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // EYE SELECTION (OD vs OS) & 3D VIEW MODE BAR
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF131D38) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Wrap(
                                            alignment: WrapAlignment.spaceBetween,
                                            crossAxisAlignment: WrapCrossAlignment.center,
                                            spacing: 12,
                                            runSpacing: 8,
                                            children: [
                                              // OD / OS Toggle (Independent C:D ratios)
                                              Wrap(
                                                crossAxisAlignment: WrapCrossAlignment.center,
                                                spacing: 8,
                                                runSpacing: 4,
                                                children: [
                                                  const Icon(LucideIcons.eye, size: 16, color: Color(0xFF0284C7)),
                                                  Text(
                                                    AppLanguage.tr('Target Examined Eye:', 'العين المفحوصة:'),
                                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                  ),
                                                  _buildOphEyeToggleChip(
                                                    label: AppLanguage.tr('Right Eye (OD)', 'OD (اليمنى - Right)'),
                                                    selected: isRightEye,
                                                    onSelected: () => _eyeRightEyeNotifier.value = true,
                                                    isDark: isDark,
                                                  ),
                                                  _buildOphEyeToggleChip(
                                                    label: AppLanguage.tr('Left Eye (OS)', 'OS (اليسرى - Left)'),
                                                    selected: !isRightEye,
                                                    onSelected: () => _eyeRightEyeNotifier.value = false,
                                                    isDark: isDark,
                                                  ),
                                                ],
                                              ),
                                              // 3D Reset view button
                                              TextButton.icon(
                                                style: TextButton.styleFrom(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                  visualDensity: VisualDensity.compact,
                                                ),
                                                icon: const Icon(LucideIcons.rotateCcw, size: 13, color: Color(0xFF0284C7)),
                                                label: Text(AppLanguage.tr('Reset 3D View', 'إعادة ضبط زاوية 3D'), style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                                                onPressed: () {
                                                  _eyeYawNotifier.value = 0.0;
                                                  _eyePitchNotifier.value = 0.0;
                                                  _eyeLayerSeparationNotifier.value = 0.35;
                                                },
                                              ),
                                            ],
                                          ),
                                      const SizedBox(height: 10),
                                      // 3D View Mode tabs
                                      Row(
                                        children: [
                                          Text(
                                            AppLanguage.tr('3D View Mode:', 'نمط العرض ثلاثي الأبعاد:'),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Wrap(
                                              spacing: 6,
                                              runSpacing: 4,
                                              children: [
                                                _buildViewModeChip(
                                                  mode: 0,
                                                  label: AppLanguage.tr('1. 3D Globe', '1. الكرة العينية 3D (Globe)'),
                                                  currentMode: viewMode,
                                                  isDark: isDark,
                                                ),
                                                _buildViewModeChip(
                                                  mode: 1,
                                                  label: AppLanguage.tr('2. 3D Sliced Layers', '2. مقطع مجسم للطبقات (3D Layers)'),
                                                  currentMode: viewMode,
                                                  isDark: isDark,
                                                ),
                                                _buildViewModeChip(
                                                  mode: 2,
                                                  label: AppLanguage.tr('3. Fundus & C:D Ratio', '3. قاع العين وعمق التقعر (Fundus & C:D)'),
                                                  currentMode: viewMode,
                                                  isDark: isDark,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // OCULAR LAYER SWITCHER CONTROLS
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.layers, size: 14, color: Color(0xFF0284C7)),
                                          const SizedBox(width: 6),
                                          Text(
                                            AppLanguage.tr('Ocular Layers Switcher:', 'طبقات العين التشريحية (Ocular Layers Switcher):'),
                                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          Text(
                                            activeLayer.name.toUpperCase(),
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Wrap(
                                        spacing: 6,
                                        runSpacing: 6,
                                        children: EyeAnatomicalLayer.values.map((layer) {
                                          final isSelected = layer == activeLayer;
                                          return ChoiceChip(
                                            label: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  layer.label,
                                                  style: TextStyle(
                                                    fontSize: 10.5,
                                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                                  ),
                                                ),
                                                Text(
                                                  layer.description,
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    color: isSelected ? Colors.white70 : (isDark ? Colors.white54 : Colors.black54),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            selected: isSelected,
                                            selectedColor: const Color(0xFF0284C7),
                                            backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                                            onSelected: (selected) {
                                              if (selected) _eyeLayerNotifier.value = layer;
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      if (viewMode == 1) ...[
                                        const SizedBox(height: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.6) : const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.2)),
                                          ),
                                          child: Row(
                                            children: [
                                              const Icon(LucideIcons.cuboid, size: 13, color: Color(0xFF0284C7)),
                                              const SizedBox(width: 6),
                                              Text(
                                                AppLanguage.tr('3D Layer Separation:', 'انفصال الطبقات 3D:'),
                                                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: SliderTheme(
                                                  data: SliderTheme.of(context).copyWith(
                                                    trackHeight: 3,
                                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                                  ),
                                                  child: Slider(
                                                    value: layerSeparation,
                                                    min: 0.0,
                                                    max: 1.0,
                                                    activeColor: const Color(0xFF0284C7),
                                                    onChanged: (val) {
                                                      _eyeLayerSeparationNotifier.value = val;
                                                    },
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                '${(layerSeparation * 100).toInt()}%',
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0284C7)),
                                              ),
                                              const SizedBox(width: 8),
                                              _buildLayerSepChip(
                                                label: AppLanguage.tr('Compact', 'مدمج'),
                                                selected: layerSeparation == 0.0,
                                                onTap: () => _eyeLayerSeparationNotifier.value = 0.0,
                                                isDark: isDark,
                                              ),
                                              const SizedBox(width: 4),
                                              _buildLayerSepChip(
                                                label: AppLanguage.tr('Layers', 'طبقات'),
                                                selected: layerSeparation > 0.1 && layerSeparation < 0.7,
                                                onTap: () => _eyeLayerSeparationNotifier.value = 0.45,
                                                isDark: isDark,
                                              ),
                                              const SizedBox(width: 4),
                                              _buildLayerSepChip(
                                                label: AppLanguage.tr('Exploded', 'منفصل'),
                                                selected: layerSeparation >= 0.7,
                                                onTap: () => _eyeLayerSeparationNotifier.value = 1.0,
                                                isDark: isDark,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // INTERACTIVE 3D EYE GRAPHICAL CANVAS WITH PAN ROTATION & CLICK-TO-PIN
                                Container(
                                  height: 280,
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF050B18) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF0284C7).withValues(alpha: 0.3)),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Stack(
                                      children: [
                                        // 3D Custom Painter with Pan Rotation & Direct Click-to-Pin
                                        Positioned.fill(
                                          child: LayoutBuilder(
                                            builder: (ctx, eyeConstraints) {
                                              final eyeW = eyeConstraints.maxWidth > 0 ? eyeConstraints.maxWidth : 400.0;
                                              final eyeH = eyeConstraints.maxHeight > 0 ? eyeConstraints.maxHeight : 280.0;
                                              return GestureDetector(
                                                behavior: HitTestBehavior.opaque,
                                                onPanUpdate: (details) {
                                                  _eyeYawNotifier.value = (_eyeYawNotifier.value + details.delta.dx * 0.015);
                                                  _eyePitchNotifier.value = (_eyePitchNotifier.value - details.delta.dy * 0.015)
                                                      .clamp(-math.pi * 0.48, math.pi * 0.48);
                                                },
                                                onDoubleTap: () {
                                                  _eyeYawNotifier.value = 0.0;
                                                  _eyePitchNotifier.value = 0.0;
                                                  _eyeLayerSeparationNotifier.value = 0.35;
                                                },
                                                onTapUp: (details) {
                                                  final normX = (details.localPosition.dx / eyeW).clamp(0.05, 0.95);
                                                  final normY = (details.localPosition.dy / eyeH).clamp(0.05, 0.95);
                                                  _openAddCustomPinNoteDialog(
                                                    context,
                                                    normX: normX,
                                                    normY: normY,
                                                    discipline: ClinicalSpecialtyDiscipline.ophthalmology,
                                                  );
                                                },
                                                child: CustomPaint(
                                                  painter: _Eye3DPainter(
                                                    activeLayer: activeLayer,
                                                    isDark: isDark,
                                                    isRightEye: isRightEye,
                                                    yaw: yaw,
                                                    pitch: pitch,
                                                    viewMode: viewMode,
                                                    cdRatio: cdRatio,
                                                    layerSeparation: layerSeparation,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                          // Orientation HUD Banner
                                          Positioned(
                                            top: 8,
                                            left: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.65),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(LucideIcons.eye, size: 12, color: isRightEye ? const Color(0xFF38BDF8) : const Color(0xFFF472B6)),
                                                  const SizedBox(width: 5),
                                                  Text(
                                                    isRightEye ? (AppLanguage.isArabic ? 'OD: العين اليمنى' : 'OD: Right Eye') : (AppLanguage.isArabic ? 'OS: العين اليسرى' : 'OS: Left Eye'),
                                                    style: TextStyle(
                                                      color: isRightEye ? const Color(0xFF38BDF8) : const Color(0xFFF472B6),
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'C:D = ${cdRatio.toStringAsFixed(2)}',
                                                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // 3D Rotation hint
                                          Positioned(
                                            bottom: 8,
                                            left: 12,
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withValues(alpha: 0.5),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(LucideIcons.move, size: 10, color: Colors.white60),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    AppLanguage.tr('Drag to rotate 3D • Click to add pin', 'اسحب للتدوير 3D • انقر لإضافة دبوس'),
                                                    style: const TextStyle(color: Colors.white70, fontSize: 9),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          // Add Pin Note Button inside canvas
                                          Positioned(
                                            top: 8,
                                            right: 12,
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFF0284C7),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                visualDensity: VisualDensity.compact,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              icon: const Icon(LucideIcons.pin, size: 12),
                                              label: Text(AppLanguage.tr('Add Pin Note', 'إضافة دبوس ملاحظة'), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                              onPressed: () {
                                                _openAddCustomPinNoteDialog(
                                                  context,
                                                  normX: 0.5,
                                                  normY: 0.5,
                                                  discipline: ClinicalSpecialtyDiscipline.ophthalmology,
                                                );
                                              },
                                            ),
                                          ),
                                          // Clickable anatomical hotspots with live status inspector
                                          Positioned.fill(
                                            child: LayoutBuilder(
                                              builder: (ctx, constraints) {
                                                final w = constraints.maxWidth;
                                                final h = constraints.maxHeight;
                                                final cx = w * 0.48;
                                                final cy = h * 0.50;

                                                return Stack(
                                                  children: [
                                                    // Cornea Hotspot
                                                    if (activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.fibrous)
                                                      _buildHotspot(
                                                        context,
                                                        partKey: 'oph_cornea',
                                                        x: cx - 115,
                                                        y: cy,
                                                        label: 'Cornea (القرنية)',
                                                        sublabel: 'Fibrous Dome',
                                                        partName: 'Cornea',
                                                        partNameAr: 'القرنية',
                                                        discipline: ClinicalSpecialtyDiscipline.ophthalmology,
                                                        activeStatuses: activeStatuses,
                                                        onApply: () => _openOphthalmologyActionSheet(
                                                          context,
                                                          structure: 'Cornea (القرنية)',
                                                          defaultCode: 'OPH-65756',
                                                          defaultProc: 'Corneal Pachymetry & Endothelial Microscopy',
                                                          defaultFee: 350.0,
                                                        ),
                                                      ),

                                                    // Iris & Pupil Hotspot
                                                    if (activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.uvea)
                                                      _buildHotspot(
                                                        context,
                                                        partKey: 'oph_iris',
                                                        x: cx - 60,
                                                        y: cy - 40,
                                                        label: 'Iris & Pupil (القزحية والبؤبؤ)',
                                                        sublabel: 'Aperture / Laser Iridotomy',
                                                        partName: 'Iris & Pupil',
                                                        partNameAr: 'القزحية والبؤبؤ',
                                                        discipline: ClinicalSpecialtyDiscipline.ophthalmology,
                                                        activeStatuses: activeStatuses,
                                                        onApply: () => _openOphthalmologyActionSheet(
                                                          context,
                                                          structure: 'Iris & Pupil (القزحية والبؤبؤ)',
                                                          defaultCode: 'OPH-66761',
                                                          defaultProc: 'Laser Peripheral Iridotomy (LPI)',
                                                          defaultFee: 950.0,
                                                        ),
                                                      ),

                                                    // Crystalline Lens Hotspot
                                                    if (activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.media)
                                                      _buildHotspot(
                                                        context,
                                                        partKey: 'oph_lens',
                                                        x: cx - 35,
                                                        y: cy,
                                                        label: 'Crystalline Lens (العدسة)',
                                                        sublabel: 'Phaco Cataract & IOL',
                                                        partName: 'Crystalline Lens',
                                                        partNameAr: 'العدسة البلورية',
                                                        discipline: ClinicalSpecialtyDiscipline.ophthalmology,
                                                        activeStatuses: activeStatuses,
                                                        onApply: () => _openOphthalmologyActionSheet(
                                                          context,
                                                          structure: 'Crystalline Lens (العدسة البلورية)',
                                                          defaultCode: 'OPH-66984',
                                                          defaultProc: 'Phacoemulsification with Foldable IOL',
                                                          defaultFee: 3800.0,
                                                        ),
                                                      ),

                                                    // Vitreous Body Hotspot
                                                    if (activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.media)
                                                      _buildHotspot(
                                                        context,
                                                        partKey: 'oph_vitreous',
                                                        x: cx + 45,
                                                        y: cy - 20,
                                                        label: 'Vitreous Chamber (الجسم الزجاجي)',
                                                        sublabel: 'Intravitreal Injection',
                                                        partName: 'Vitreous Chamber',
                                                        partNameAr: 'الجسم الزجاجي',
                                                        discipline: ClinicalSpecialtyDiscipline.ophthalmology,
                                                        activeStatuses: activeStatuses,
                                                        onApply: () => _openOphthalmologyActionSheet(
                                                          context,
                                                          structure: 'Vitreous Chamber (الجسم الزجاجي)',
                                                          defaultCode: 'OPH-67028',
                                                          defaultProc: 'Intravitreal Anti-VEGF Injection',
                                                          defaultFee: 1400.0,
                                                        ),
                                                      ),

                                                    // Retina & Macula Hotspot
                                                    if (activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.retina)
                                                      _buildHotspot(
                                                        context,
                                                        partKey: 'oph_retina',
                                                        x: cx + 110,
                                                        y: cy - 25,
                                                        label: 'Retina & Macula (الشبكية والبقعة)',
                                                        sublabel: 'OCT & Laser Retinopexy',
                                                        partName: 'Retina & Macula',
                                                        partNameAr: 'الشبكية والبقعة الصفراء',
                                                        discipline: ClinicalSpecialtyDiscipline.ophthalmology,
                                                        activeStatuses: activeStatuses,
                                                        onApply: () => _openOphthalmologyActionSheet(
                                                          context,
                                                          structure: 'Retina & Macula (الشبكية والبقعة الصفراء)',
                                                          defaultCode: 'OPH-92134',
                                                          defaultProc: 'Macular Spectral OCT Scan',
                                                          defaultFee: 550.0,
                                                        ),
                                                      ),

                                                    // Optic Nerve Head (Glaucoma C:D Evaluation)
                                                    if (activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.retina)
                                                      _buildHotspot(
                                                        context,
                                                        partKey: 'oph_optic_disc',
                                                        x: cx + 140,
                                                        y: cy + 30,
                                                        label: 'Optic Disc (العصب البصري)',
                                                        sublabel: 'C:D Ratio & Visual Field',
                                                        partName: 'Optic Disc',
                                                        partNameAr: 'العصب البصري',
                                                        discipline: ClinicalSpecialtyDiscipline.ophthalmology,
                                                        activeStatuses: activeStatuses,
                                                        onApply: () => _openOphthalmologyActionSheet(
                                                          context,
                                                          structure: 'Optic Nerve Head (حليمة العصب البصري)',
                                                          defaultCode: 'OPH-92083',
                                                          defaultProc: 'Humphrey Visual Field 24-2',
                                                          defaultFee: 400.0,
                                                        ),
                                                      ),

                                                    // Render custom pins dropped by doctors
                                                    ...activeStatuses.values.where((e) => e.isCustomPin).map((pin) {
                                                      final px = (pin.normalizedX ?? 0.5) * w;
                                                      final py = (pin.normalizedY ?? 0.5) * h;
                                                      return Positioned(
                                                        left: (px - 14).clamp(4.0, (w - 110.0).clamp(4.0, double.infinity)),
                                                        top: (py - 14).clamp(4.0, (h - 32.0).clamp(4.0, double.infinity)),
                                                        child: _buildCustomPinMarker(context, pin, isDark),
                                                      );
                                                    }),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ),
                                const SizedBox(height: 12),

                                // EMBEDDED C:D RATIO & OCULAR PROCEDURES PANEL WITH PERSISTENT OD / OS NOTIFIERS
                                OphthalmologyActionWidget(
                                  cupDiscRatioODNotifier: _eyeCdRatioOdNotifier,
                                  cupDiscRatioOSNotifier: _eyeCdRatioOsNotifier,
                                  rightEyeNotifier: _eyeRightEyeNotifier,
                                  visualFieldNotifier: _eyeVisualFieldNotifier,
                                  octScanNotifier: _eyeOctScanNotifier,
                                  onApply: (annotation, billingItems) {
                                    for (final item in billingItems) {
                                      onProcedureApplied?.call(
                                        item,
                                        'Ophthalmology Finding [${isRightEye ? "OD" : "OS"}]: C:D Ratio ${annotation.cupToDiscRatio.toStringAsFixed(2)} - ${item.name}',
                                      );
                                    }
                                  },
                                ),
                              ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );
}

  Widget _buildOphEyeToggleChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
    required bool isDark,
  }) {
    return ChoiceChip(
      selected: selected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      selectedColor: const Color(0xFF0284C7),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildViewModeChip({
    required int mode,
    required String label,
    required int currentMode,
    required bool isDark,
  }) {
    final selected = mode == currentMode;
    return ChoiceChip(
      selected: selected,
      label: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        ),
      ),
      selectedColor: const Color(0xFF0284C7),
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      onSelected: (val) {
        if (val) _eyeViewModeNotifier.value = mode;
      },
    );
  }

  Widget _buildLayerSepChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0284C7) : (isDark ? Colors.white12 : Colors.black12),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 2. ORTHOPEDICS: 3D SKELETAL BONES & TRAUMA WORKBENCH
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildOrthopedicsViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    final bones = [
      {'name': 'Cranium & Facial Bones', 'nameAr': 'الجمجمة وعظام الوجه', 'code': 'ORTHO-21310', 'fee': 850.0, 'proc': 'Skull & Facial CT Assessment'},
      {'name': 'Cervical Spine (C1-C7)', 'nameAr': 'الفقرات العنقية', 'code': 'ORTHO-22551', 'fee': 2200.0, 'proc': 'Cervical Spine Decompression Protocol'},
      {'name': 'Thoracic Spine & Ribs', 'nameAr': 'الفقرات الصدرية والأضلاع', 'code': 'ORTHO-21820', 'fee': 600.0, 'proc': 'Rib Cage Splinting & Radiography'},
      {'name': 'Lumbar Spine (L1-L5)', 'nameAr': 'الفقرات القطنية وعرق النسا', 'code': 'ORTHO-63030', 'fee': 3500.0, 'proc': 'Lumbar Microdiscectomy Planning'},
      {'name': 'Clavicle & Scapula', 'nameAr': 'الترقوة ولوح الكتف', 'code': 'ORTHO-23515', 'fee': 1800.0, 'proc': 'ORIF Clavicle Fracture Plating'},
      {'name': 'Humerus (Arm)', 'nameAr': 'عظم العضد', 'code': 'ORTHO-24515', 'fee': 2100.0, 'proc': 'Intramedullary Nailing of Humerus'},
      {'name': 'Radius & Ulna (Forearm)', 'nameAr': 'عظمتي الكعبرة والزند', 'code': 'ORTHO-25607', 'fee': 1600.0, 'proc': 'Distal Radius ORIF Volar Plate'},
      {'name': 'Pelvis & Hip Joint', 'nameAr': 'الحوض ومفصل الورك', 'code': 'ORTHO-27130', 'fee': 5800.0, 'proc': 'Total Hip Arthroplasty (THA)'},
      {'name': 'Femur (Thigh Bone)', 'nameAr': 'عظم الفخذ', 'code': 'ORTHO-27506', 'fee': 3900.0, 'proc': 'Femoral Interlocking Nailing'},
      {'name': 'Patella & Knee Joint', 'nameAr': 'الرضفة ومفصل الركبة', 'code': 'ORTHO-29881', 'fee': 2400.0, 'proc': 'Knee Arthroscopy & Meniscectomy'},
      {'name': 'Tibia & Fibula (Leg)', 'nameAr': 'عظمتي القصبة والشظية', 'code': 'ORTHO-27758', 'fee': 2600.0, 'proc': 'Tibial Shaft ORIF Plating'},
      {'name': 'Ankle & Foot Metatarsals', 'nameAr': 'الكاحل ومشط القدم', 'code': 'ORTHO-27814', 'fee': 1950.0, 'proc': 'Bimalleolar Ankle Fracture Fixation'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.bone,
          title: '3D Skeletal Bone Explorer (النظام الهيكلي العظمي)',
          subtitle: 'Select any bone or joint to search and assign clinical statuses (fractures, tears, spurs) with live ICD-10 codes.',
          color: const Color(0xFF0D9488),
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Interactive 3D Skeletal Bone Model with Multi-Age Morphing
        SkeletalBone3dCanvasWidget(
          activeStatuses: activeStatuses,
          onBoneSelected: (code, nameEn, nameAr) {
            _openStatusInspector(
              context,
              partKey: 'ortho_$code',
              partName: nameEn,
              partNameAr: nameAr,
              discipline: ClinicalSpecialtyDiscipline.orthopedics,
            );
          },
          onBoneSecondaryTap: (code, nameEn, nameAr) {
            _openPartScanInspectionDialog(
              context,
              partKey: 'ortho_$code',
              partName: nameEn,
              partNameAr: nameAr,
            );
          },
        ),
        const SizedBox(height: 14),

        // Interactive Bone Grid with Live Status Indicators
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemCount: bones.length,
          itemBuilder: (ctx, idx) {
            final b = bones[idx];
            final boneKey = 'ortho_${b['code']}';
            final statusEntry = activeStatuses[boneKey];
            final hasStatus = statusEntry != null;
            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF0D9488);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openStatusInspector(
                  context,
                  partKey: boneKey,
                  partName: b['name'] as String,
                  partNameAr: b['nameAr'] as String,
                  discipline: ClinicalSpecialtyDiscipline.orthopedics,
                ),
                onSecondaryTap: () => _openPartScanInspectionDialog(
                  context,
                  partKey: boneKey,
                  partName: b['name'] as String,
                  partNameAr: b['nameAr'] as String,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasStatus
                        ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF132A26) : const Color(0xFFF0FDFA)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStatus ? cardColor : const Color(0xFF0D9488).withValues(alpha: 0.3),
                      width: hasStatus ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      if (hasStatus)
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.bone, color: cardColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              b['nameAr'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              b['name'] as String,
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hasStatus)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${statusEntry.status.icd10Code}: ${AppLanguage.isArabic ? statusEntry.status.titleAr : statusEntry.status.title}',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: cardColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: cardColor),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 3. PHYSIOTHERAPY: 3D MUSCULAR SYSTEM & REHAB WORKBENCH
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPhysiotherapyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    final muscles = [
      {'name': 'Trapezius & Cervical Musculature', 'nameAr': 'عضلة الترابيزيوس والعنق', 'code': 'PT-97140', 'fee': 250.0, 'proc': 'Manual Cervical Myofascial Release'},
      {'name': 'Deltoids & Rotator Cuff', 'nameAr': 'عضلات الكتف والكفة المدورة', 'code': 'PT-97110', 'fee': 300.0, 'proc': 'Therapeutic Rotator Cuff Kinematic Exercises'},
      {'name': 'Pectoralis Major & Chest', 'nameAr': 'عضلات الصدر البكتوراليس', 'code': 'PT-97035', 'fee': 220.0, 'proc': 'Ultrasound Therapy 1MHz (Pectoral)'},
      {'name': 'Biceps & Triceps (Arms)', 'nameAr': 'عضلات البايسبس والترايسبس', 'code': 'PT-97014', 'fee': 200.0, 'proc': 'TENS Neuromuscular Electrical Stimulation'},
      {'name': 'Rectus Abdominis & Core', 'nameAr': 'عضلات البطن والجذع (الكور)', 'code': 'PT-97112', 'fee': 280.0, 'proc': 'Neuromuscular Core Re-Education'},
      {'name': 'Latissimus Dorsi (Back)', 'nameAr': 'عضلات الظهر العريضة', 'code': 'PT-20560', 'fee': 350.0, 'proc': 'Dry Needling (1-2 Trigger Points)'},
      {'name': 'Gluteus Maximus & Medius', 'nameAr': 'عضلات المقعدة والحوض', 'code': 'PT-97140', 'fee': 290.0, 'proc': 'Deep Gluteal Tissue Decompression'},
      {'name': 'Quadriceps Femoris (Thigh)', 'nameAr': 'العضلة رباعية الرؤوس (الفخذ)', 'code': 'PT-97110', 'fee': 260.0, 'proc': 'Isokinetic Quad Strengthening Protocol'},
      {'name': 'Hamstrings Group', 'nameAr': 'العضلات الخلفية للفخذ', 'code': 'PT-29530', 'fee': 180.0, 'proc': 'Kinesiology Taping (Hamstrings)'},
      {'name': 'Gastrocnemius & Achilles Tendon', 'nameAr': 'عضلة السمانة ووتر أخيل', 'code': 'PT-97035', 'fee': 240.0, 'proc': 'Therapeutic Shockwave / Ultrasound'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.activity,
          title: '3D Muscular Anatomy & Kinetic Matrix (النظام العضلي والحركي)',
          subtitle: 'Select any muscle group to search and assign clinical statuses (strains, ruptures, trigger points, atrophy).',
          color: const Color(0xFF10B981),
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Interactive 3D Muscular Anatomy & Kinetic Matrix with Age Stages
        Clinical3dSceneViewer(
          specialtyTitle: '3D Muscular Anatomy & Kinetic Matrix',
          specialtyTitleAr: 'المجسم العضلي الحركي ثلاثي الأبعاد وتحديد الإصابات',
          specialtyIcon: LucideIcons.activity,
          primaryColor: const Color(0xFF10B981),
          initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
          activeStatuses: activeStatuses,
          availableInstruments: const [
            SpecialtyInstrument.kinesioTape,
            SpecialtyInstrument.dryNeedle,
            SpecialtyInstrument.cuppingDome,
            SpecialtyInstrument.tensPad,
          ],
          sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
              Specialty3dAnatomicalModels.buildPhysiotherapyMesh(
                stage,
                instrument: instrument,
                isSoloMode: isSoloMode,
                soloPartKey: soloPartKey,
              ),
          onPartSelected: (partKey, nameEn, nameAr) {
            _openStatusInspector(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
              discipline: ClinicalSpecialtyDiscipline.physiotherapy,
            );
          },
          onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
            _openPartScanInspectionDialog(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
            );
          },
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: muscles.length,
          itemBuilder: (ctx, idx) {
            final m = muscles[idx];
            final muscleKey = 'physio_${m['code']}';
            final statusEntry = activeStatuses[muscleKey];
            final hasStatus = statusEntry != null;
            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF10B981);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openStatusInspector(
                  context,
                  partKey: muscleKey,
                  partName: m['name'] as String,
                  partNameAr: m['nameAr'] as String,
                  discipline: ClinicalSpecialtyDiscipline.physiotherapy,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasStatus
                        ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF122C24) : const Color(0xFFF0FDF4)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStatus ? cardColor : const Color(0xFF10B981).withValues(alpha: 0.3),
                      width: hasStatus ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      if (hasStatus)
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.activity, color: cardColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              m['nameAr'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              m['name'] as String,
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hasStatus)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${statusEntry.status.icd10Code}: ${AppLanguage.isArabic ? statusEntry.status.titleAr : statusEntry.status.title}',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: cardColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: cardColor),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 4. GASTROENTEROLOGY: 3D DIGESTIVE & INTESTINAL SYSTEM
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGastroenterologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    final giOrgans = [
      {'name': 'Esophagus (المريء)', 'nameAr': 'المريء وقاع المعدة', 'code': 'GI-43235', 'fee': 1200.0, 'proc': 'Diagnostic EGD Esophagoscopy'},
      {'name': 'Stomach (المعدة)', 'nameAr': 'المعدة والحرقة الهضمية', 'code': 'GI-43239', 'fee': 1500.0, 'proc': 'Gastroscopy with Mucosal Biopsy'},
      {'name': 'Duodenum & Small Bowel', 'nameAr': 'الاثني عشر والأمعاء الدقيقة', 'code': 'GI-44360', 'fee': 1800.0, 'proc': 'Small Bowel Enteroscopy'},
      {'name': 'Large Intestines (Colon)', 'nameAr': 'القولون والأمعاء الغليظة', 'code': 'GI-45385', 'fee': 2200.0, 'proc': 'Colonoscopy with Polypectomy Snare'},
      {'name': 'Appendix & Cecum', 'nameAr': 'الزائدة الدودية والأعور', 'code': 'GI-44970', 'fee': 3800.0, 'proc': 'Laparoscopic Appendectomy Protocol'},
      {'name': 'Liver (الكبد)', 'nameAr': 'الكبد والإنزيمات الكبدية', 'code': 'GI-47000', 'fee': 1600.0, 'proc': 'Percutaneous Liver Biopsy'},
      {'name': 'Gallbladder & Biliary Tree', 'nameAr': 'المرارة والقنوات المرارية', 'code': 'GI-47562', 'fee': 4200.0, 'proc': 'Laparoscopic Cholecystectomy'},
      {'name': 'Pancreas (البنكرياس)', 'nameAr': 'البنكرياس والإنزيمات الهاضمة', 'code': 'GI-43260', 'fee': 2900.0, 'proc': 'Diagnostic ERCP Pancreatic Duct'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.utensils,
          title: '3D Digestive & Intestinal Matrix (الجهاز الهضمي والأمعاء)',
          subtitle: 'Select any digestive organ to search and assign clinical statuses (peptic ulcers, polyps, colitis, gallstones).',
          color: const Color(0xFFF59E0B),
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Interactive 3D Digestive & Visceral Organ Matrix with Age Stages
        Clinical3dSceneViewer(
          specialtyTitle: '3D Digestive Tract & Visceral Organ Matrix',
          specialtyTitleAr: 'الجهاز الهضمي والأحشاء الباطنية ثلاثي الأبعاد',
          specialtyIcon: LucideIcons.utensils,
          primaryColor: const Color(0xFFF59E0B),
          initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
          activeStatuses: activeStatuses,
          availableInstruments: const [
            SpecialtyInstrument.biopsyForceps,
            SpecialtyInstrument.hemoclip,
            SpecialtyInstrument.biliaryStent,
            SpecialtyInstrument.laparoscopicTrocar,
          ],
          sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
              Specialty3dAnatomicalModels.buildGastroenterologyMesh(
                stage,
                instrument: instrument,
                isSoloMode: isSoloMode,
                soloPartKey: soloPartKey,
              ),
          onPartSelected: (partKey, nameEn, nameAr) {
            _openStatusInspector(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
              discipline: ClinicalSpecialtyDiscipline.gastroenterology,
            );
          },
          onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
            _openPartScanInspectionDialog(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
            );
          },
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: giOrgans.length,
          itemBuilder: (ctx, idx) {
            final g = giOrgans[idx];
            final organKey = 'gi_${g['code']}';
            final statusEntry = activeStatuses[organKey];
            final hasStatus = statusEntry != null;
            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFF59E0B);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openStatusInspector(
                  context,
                  partKey: organKey,
                  partName: g['name'] as String,
                  partNameAr: g['nameAr'] as String,
                  discipline: ClinicalSpecialtyDiscipline.gastroenterology,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasStatus
                        ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF33200B) : const Color(0xFFFFFBEB)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStatus ? cardColor : const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      width: hasStatus ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      if (hasStatus)
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.utensils, color: cardColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              g['nameAr'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              g['name'] as String,
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hasStatus)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${statusEntry.status.icd10Code}: ${AppLanguage.isArabic ? statusEntry.status.titleAr : statusEntry.status.title}',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: cardColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: cardColor),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 5. CARDIOLOGY: 3D HEART & VASCULAR STENT CALIPER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildCardiologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    final cardioVessels = [
      {'key': 'cardio_lad', 'name': 'Left Anterior Descending (LAD)', 'nameAr': 'الشريان التاجي الأيسر النازل', 'code': 'CAR-92928'},
      {'key': 'cardio_lcx', 'name': 'Left Circumflex (LCx)', 'nameAr': 'الشريان الدائري المنعطف', 'code': 'CAR-92929'},
      {'key': 'cardio_rca', 'name': 'Right Coronary Artery (RCA)', 'nameAr': 'الشريان التاجي الأيمن', 'code': 'CAR-92930'},
      {'key': 'cardio_aorta', 'name': 'Ascending Aorta & Root', 'nameAr': 'الشريان الأبهر الصاعد وجذره', 'code': 'CAR-71275'},
      {'key': 'cardio_lv', 'name': 'Left Ventricle & Myocardium', 'nameAr': 'البطين الأيسر وعضلة القلب', 'code': 'CAR-93306'},
      {'key': 'cardio_valves', 'name': 'Mitral & Aortic Valves', 'nameAr': 'الصمام الميترالي والأبهري', 'code': 'CAR-93312'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.heartPulse,
          title: '3D Cardiovascular & Coronary Matrix (القلب والشرايين التاجية)',
          subtitle: 'Select any vessel or chamber to search and assign clinical statuses (stenosis, STEMI, aneurysm, regurgitation).',
          color: const Color(0xFFEF4444),
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Interactive 3D Beating / Morphing Heart & Coronary Tree with Age Stages
        Clinical3dSceneViewer(
          specialtyTitle: '3D Cardiovascular Chambers & Coronary Artery Tree',
          specialtyTitleAr: 'المجسم القلبي ثلاثي الأبعاد والشرايين التاجية',
          specialtyIcon: LucideIcons.heartPulse,
          primaryColor: const Color(0xFFEF4444),
          initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
          activeStatuses: activeStatuses,
          availableInstruments: const [
            SpecialtyInstrument.coronaryStent,
            SpecialtyInstrument.angioplastyBalloon,
            SpecialtyInstrument.tavrValve,
            SpecialtyInstrument.pacemakerLead,
          ],
          sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
              Specialty3dAnatomicalModels.buildCardiologyMesh(
                stage,
                instrument: instrument,
                isSoloMode: isSoloMode,
                soloPartKey: soloPartKey,
              ),
          onPartSelected: (partKey, nameEn, nameAr) {
            _openStatusInspector(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
              discipline: ClinicalSpecialtyDiscipline.cardiology,
            );
          },
          onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
            _openPartScanInspectionDialog(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
            );
          },
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemCount: cardioVessels.length,
          itemBuilder: (ctx, idx) {
            final c = cardioVessels[idx];
            final vesselKey = c['key'] as String;
            final statusEntry = activeStatuses[vesselKey];
            final hasStatus = statusEntry != null;
            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFEF4444);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openStatusInspector(
                  context,
                  partKey: vesselKey,
                  partName: c['name'] as String,
                  partNameAr: c['nameAr'] as String,
                  discipline: ClinicalSpecialtyDiscipline.cardiology,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasStatus
                        ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF2C1318) : const Color(0xFFFEF2F2)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStatus ? cardColor : const Color(0xFFEF4444).withValues(alpha: 0.3),
                      width: hasStatus ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      if (hasStatus)
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.heartPulse, color: cardColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              c['nameAr'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              c['name'] as String,
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hasStatus)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${statusEntry.status.icd10Code}: ${AppLanguage.isArabic ? statusEntry.status.titleAr : statusEntry.status.title}',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: cardColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: cardColor),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        CardiologyVascularActionWidget(
          onApply: (annotation, billingItems) {
            for (final item in billingItems) {
              onProcedureApplied?.call(
                item,
                'Cardiology Intervention: ${annotation.vesselName} (${annotation.stenosisPercentage.toStringAsFixed(0)}% Stenosis) - ${item.name}',
              );
            }
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 6. DERMATOLOGY: 3D SKIN DERMATOMES & RULE-OF-NINES
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDermatologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    final dermaZones = [
      {'key': 'derma_face', 'name': 'Facial & Forehead Cutis', 'nameAr': 'جلد الوجه والجبهة', 'code': 'DER-11606'},
      {'key': 'derma_trunk', 'name': 'Trunk & Thoracolumbar Back', 'nameAr': 'جلد الجذع والظهر', 'code': 'DER-96910'},
      {'key': 'derma_arms', 'name': 'Upper Extremities & Forearms', 'nameAr': 'الطرفين العلويين والساعدين', 'code': 'DER-16020'},
      {'key': 'derma_legs', 'name': 'Lower Extremities & Pretibial', 'nameAr': 'الطرفين السفليين والساقين', 'code': 'DER-11900'},
      {'key': 'derma_scalp', 'name': 'Scalp & Hair Follicles', 'nameAr': 'فروة الرأس وبصيلات الشعر', 'code': 'DER-96900'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.sparkles,
          title: '3D Dermatology & Skin Surface (الجلدية والتجميل)',
          subtitle: 'Select any skin zone to search and assign clinical statuses (melanoma, psoriasis, burns, keloids) or calculate TBSA.',
          color: const Color(0xFFEC4899),
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        // Interactive 3D Dermatology & Skin Cutis Cross-Section with Age Stages
        Clinical3dSceneViewer(
          specialtyTitle: '3D Dermatology & Skin Cutis Cross-Section',
          specialtyTitleAr: 'طبقات الجلد والبشرة والنسيج الشحمي ثلاثية الأبعاد',
          specialtyIcon: LucideIcons.sparkles,
          primaryColor: const Color(0xFFEC4899),
          initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
          activeStatuses: activeStatuses,
          availableInstruments: const [
            SpecialtyInstrument.punchBiopsy,
            SpecialtyInstrument.intradermalSuture,
            SpecialtyInstrument.cryoSpray,
            SpecialtyInstrument.microneedle,
          ],
          sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
              Specialty3dAnatomicalModels.buildDermatologyMesh(
                stage,
                instrument: instrument,
                isSoloMode: isSoloMode,
                soloPartKey: soloPartKey,
              ),
          onPartSelected: (partKey, nameEn, nameAr) {
            _openStatusInspector(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
              discipline: ClinicalSpecialtyDiscipline.dermatology,
            );
          },
          onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
            _openPartScanInspectionDialog(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
            );
          },
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.1,
          ),
          itemCount: dermaZones.length,
          itemBuilder: (ctx, idx) {
            final d = dermaZones[idx];
            final zoneKey = d['key'] as String;
            final statusEntry = activeStatuses[zoneKey];
            final hasStatus = statusEntry != null;
            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFEC4899);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openStatusInspector(
                  context,
                  partKey: zoneKey,
                  partName: d['name'] as String,
                  partNameAr: d['nameAr'] as String,
                  discipline: ClinicalSpecialtyDiscipline.dermatology,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasStatus
                        ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF2C1322) : const Color(0xFFFDF2F8)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStatus ? cardColor : const Color(0xFFEC4899).withValues(alpha: 0.3),
                      width: hasStatus ? 2.0 : 1.0,
                    ),
                    boxShadow: [
                      if (hasStatus)
                        BoxShadow(
                          color: cardColor.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(LucideIcons.sparkles, color: cardColor, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              d['nameAr'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              d['name'] as String,
                              style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (hasStatus)
                              Container(
                                margin: const EdgeInsets.only(top: 2),
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: cardColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${statusEntry.status.icd10Code}: ${AppLanguage.isArabic ? statusEntry.status.titleAr : statusEntry.status.title}',
                                  style: TextStyle(
                                    fontSize: 8.5,
                                    fontWeight: FontWeight.bold,
                                    color: cardColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: cardColor),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 14),

        DermatologyActionWidget(
          onApply: (annotation, billingItems) {
            for (final item in billingItems) {
              onProcedureApplied?.call(
                item,
                'Dermatology Procedure: TBSA ${annotation.totalTbsaPercentage.toStringAsFixed(0)}% - ${item.name}',
              );
            }
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 7. GENERAL CLINIC MULTI-SYSTEM SELECTOR
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildGeneralMultiSystemViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    final systems = [
      {'disc': ClinicalSpecialtyDiscipline.neurology, 'name': 'Neurology & Neurosurgery', 'nameAr': 'المخ والأعصاب وجراحة المخ', 'icon': LucideIcons.brain, 'color': const Color(0xFF8B5CF6)},
      {'disc': ClinicalSpecialtyDiscipline.neuroOtology, 'name': 'Neuro-Otology & Balance', 'nameAr': 'طب التوازن والأذن الداخلية', 'icon': LucideIcons.ear, 'color': const Color(0xFF6366F1)},
      {'disc': ClinicalSpecialtyDiscipline.neuroPsychiatry, 'name': 'Neuro-Psychiatry & TMS', 'nameAr': 'الطب النفسي العصبي وتحفيز المخ', 'icon': LucideIcons.activity, 'color': const Color(0xFFA855F7)},
      {'disc': ClinicalSpecialtyDiscipline.ophthalmology, 'name': 'Ophthalmology (Eye)', 'nameAr': 'العيون وجراحة البصر', 'icon': LucideIcons.eye, 'color': const Color(0xFF06B6D4)},
      {'disc': ClinicalSpecialtyDiscipline.rhinologyEnt, 'name': 'Rhinology & Sinus (ENT)', 'nameAr': 'الأنف والجيوب الأنفية', 'icon': LucideIcons.wind, 'color': const Color(0xFF14B8A6)},
      {'disc': ClinicalSpecialtyDiscipline.dental, 'name': 'Dental & Odontogram', 'nameAr': 'الأسنان وطب الفم والفكين', 'icon': LucideIcons.smile, 'color': const Color(0xFF0284C7)},
      {'disc': ClinicalSpecialtyDiscipline.cardiology, 'name': 'Cardiology (Heart)', 'nameAr': 'القلب والأوعية التاجية', 'icon': LucideIcons.heartPulse, 'color': const Color(0xFFEF4444)},
      {'disc': ClinicalSpecialtyDiscipline.vascularVein, 'name': 'Vein & Vascular (Phlebology)', 'nameAr': 'الأوردة وجراحة الأوعية', 'icon': LucideIcons.gitFork, 'color': const Color(0xFFDC2626)},
      {'disc': ClinicalSpecialtyDiscipline.pulmonology, 'name': 'Pulmonology (Respiratory)', 'nameAr': 'الصدرية والجهاز التنفسي', 'icon': LucideIcons.wind, 'color': const Color(0xFF0EA5E9)},
      {'disc': ClinicalSpecialtyDiscipline.endocrinology, 'name': 'Endocrinology & Glands', 'nameAr': 'الغدد الصماء والدرقية', 'icon': LucideIcons.dna, 'color': const Color(0xFFD97706)},
      {'disc': ClinicalSpecialtyDiscipline.gastroenterology, 'name': 'Gastroenterology (Digestive)', 'nameAr': 'الجهاز الهضمي والمناظير', 'icon': LucideIcons.utensils, 'color': const Color(0xFFF59E0B)},
      {'disc': ClinicalSpecialtyDiscipline.urology, 'name': 'Urology & Men\'s Health', 'nameAr': 'المسالك البولية وصحة الرجل', 'icon': LucideIcons.droplets, 'color': const Color(0xFF3B82F6)},
      {'disc': ClinicalSpecialtyDiscipline.obgyn, 'name': 'OB/GYN & Fertility (REI)', 'nameAr': 'النساء والتوليد والخصوبة', 'icon': LucideIcons.baby, 'color': const Color(0xFFF43F5E)},
      {'disc': ClinicalSpecialtyDiscipline.orthopedics, 'name': 'Orthopedics (Bones)', 'nameAr': 'جراحة العظام والكسور', 'icon': LucideIcons.bone, 'color': const Color(0xFF0D9488)},
      {'disc': ClinicalSpecialtyDiscipline.physiotherapy, 'name': 'Physiotherapy & Rehab', 'nameAr': 'العلاج الطبيعي والتأهيل', 'icon': LucideIcons.activity, 'color': const Color(0xFF10B981)},
      {'disc': ClinicalSpecialtyDiscipline.podiatry, 'name': 'Podiatry & Orthotics (P&O)', 'nameAr': 'طب القدم وتصحيح القوام', 'icon': LucideIcons.footprints, 'color': const Color(0xFF84CC16)},
      {'disc': ClinicalSpecialtyDiscipline.plasticSurgery, 'name': 'Cosmetic Plastic Surgery', 'nameAr': 'جراحة التجميل ونحت القوام', 'icon': LucideIcons.wand2, 'color': const Color(0xFFE11D48)},
      {'disc': ClinicalSpecialtyDiscipline.medicalAesthetics, 'name': 'Medical Aesthetics (Injectors)', 'nameAr': 'الحقن التجميلي والبوتوكس', 'icon': LucideIcons.syringe, 'color': const Color(0xFFF472B6)},
      {'disc': ClinicalSpecialtyDiscipline.dermatology, 'name': 'Dermatology & Skin Lesions', 'nameAr': 'الجلدية وزراعة الشعر', 'icon': LucideIcons.sparkles, 'color': const Color(0xFFEC4899)},
      {'disc': ClinicalSpecialtyDiscipline.painManagement, 'name': 'Interventional Pain Care', 'nameAr': 'علاج الألم التداخلي', 'icon': LucideIcons.zap, 'color': const Color(0xFFF97316)},
      {'disc': ClinicalSpecialtyDiscipline.acupuncture, 'name': 'Acupuncture & Eastern Med', 'nameAr': 'الوخز بالإبر ومسارات الطاقة', 'icon': LucideIcons.compass, 'color': const Color(0xFF10B981)},
      {'disc': ClinicalSpecialtyDiscipline.speechPathology, 'name': 'Speech-Language Pathology', 'nameAr': 'التخاطب وأمراض البلع والصوت', 'icon': LucideIcons.mic, 'color': const Color(0xFF38BDF8)},
      {'disc': ClinicalSpecialtyDiscipline.veterinary, 'name': 'Veterinary Medicine', 'nameAr': 'الطب والجراحة البيطرية', 'icon': LucideIcons.heartHandshake, 'color': const Color(0xFF10B981)},
      {'disc': ClinicalSpecialtyDiscipline.diagnosticLab, 'name': 'Diagnostic Pathology & Lab', 'nameAr': 'المختبرات والتشخيص المرضي', 'icon': LucideIcons.flaskConical, 'color': const Color(0xFF8B5CF6)},
      {'disc': ClinicalSpecialtyDiscipline.mentalHealth, 'name': 'Mental & Behavioral Health', 'nameAr': 'الصحة النفسية والعصبية السلوكية', 'icon': LucideIcons.smilePlus, 'color': const Color(0xFF06B6D4)},
      {'disc': ClinicalSpecialtyDiscipline.pediatrics, 'name': 'Pediatrics & Child Health', 'nameAr': 'طب الأطفال والتطور النمائي', 'icon': LucideIcons.baby, 'color': const Color(0xFFF59E0B)},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.stethoscope,
          title: 'General Clinical Multi-System Explorer (الاستكشاف الطبي متعدد التخصصات)',
          subtitle: 'Select any medical specialty or anatomical system to access its interactive 3D visualizer and procedure matrix.',
          color: const Color(0xFF6366F1),
          isDark: isDark,
        ),
        const SizedBox(height: 14),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.7,
          ),
          itemCount: systems.length,
          itemBuilder: (ctx, idx) {
            final s = systems[idx];
            final color = s['color'] as Color;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  final disc = s['disc'] as ClinicalSpecialtyDiscipline;
                  _activeDisciplineNotifier.value = disc;
                  widget.onDisciplineChanged?.call(disc);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? color.withValues(alpha: 0.12) : color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(s['icon'] as IconData, color: color, size: 18),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              s['nameAr'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              s['name'] as String,
                              style: TextStyle(fontSize: 9.5, color: isDark ? Colors.white60 : Colors.black54),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios, size: 12, color: color),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // GENERIC LAYER SWITCHER BUILDER
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLayerSwitcher<T extends Enum>({
    required String title,
    required String titleAr,
    required List<T> values,
    required T selected,
    required ValueChanged<T> onSelected,
    required String Function(T) getLabel,
    required String Function(T) getDescription,
    required bool isDark,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.layers, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  AppLanguage.isArabic ? '$title ($titleAr):' : '$title:',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                selected.name.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: values.map((val) {
              final isSel = val == selected;
              return ChoiceChip(
                label: Text(
                  () {
                    final raw = getLabel(val);
                    if (AppLanguage.isArabic) {
                      return raw;
                    } else {
                      if (raw.contains('(')) return raw.split('(')[0].trim();
                      return raw;
                    }
                  }(),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    color: isSel ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                selected: isSel,
                selectedColor: color,
                backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
                onSelected: (s) {
                  if (s) onSelected(val);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 4),
          Text(
            () {
              final raw = getDescription(selected);
              if (AppLanguage.isArabic) {
                if (raw.contains('(') && raw.contains(')')) {
                  final start = raw.indexOf('(') + 1;
                  final end = raw.lastIndexOf(')');
                  return raw.substring(start, end).trim();
                }
                return raw;
              } else {
                if (raw.contains('(')) return raw.split('(')[0].trim();
                return raw;
              }
            }(),
            style: TextStyle(fontSize: 10, color: isDark ? Colors.white54 : Colors.black54, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 8. NEUROLOGY & NEUROSURGERY: 3D BRAIN & SKULL BASE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNeurologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<NeurologyLayer>(
      valueListenable: _neurologyLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.brain,
              title: 'Neurology & Neurosurgery 3D Visualizer (المخ وجراحة الأعصاب)',
              subtitle: 'Multi-layer intracranial visualizer: Lobes, Ventricles/CSF, Basal Ganglia, Cranial Nerves, Circle of Willis.',
              color: const Color(0xFF8B5CF6),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<NeurologyLayer>(
              title: 'Neurological Layers',
              titleAr: 'الطبقات العصبية الدماغية',
              values: NeurologyLayer.values,
              selected: activeLayer,
              onSelected: (l) => _neurologyLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Neurology & Neurosurgery Intracranial Matrix',
              specialtyTitleAr: 'المجسم الدماغي والجهاز العصبي ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.brain,
              primaryColor: const Color(0xFF8B5CF6),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.stereotacticBurrhole,
                SpecialtyInstrument.dbsElectrode,
                SpecialtyInstrument.aneurysmClip,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildNeurologyMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.neurology,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.3,
              ),
              itemCount: 5,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'neuro_cortex', 'name': 'Cerebral Cortical Lobes', 'nameAr': 'فصوص القشرة المخية'},
                  {'key': 'neuro_ventricles', 'name': 'Ventricular System & CSF', 'nameAr': 'البطينات الدماغية وسائله'},
                  {'key': 'neuro_basal_ganglia', 'name': 'Deep Basal Ganglia', 'nameAr': 'العقد القاعدية والمهاد'},
                  {'key': 'neuro_cranial_nerves', 'name': 'Cranial Nerves (I–XII)', 'nameAr': 'الأعصاب القحفية وجذع المخ'},
                  {'key': 'neuro_circle_of_willis', 'name': 'Circle of Willis', 'nameAr': 'الدورة الدماغية ويلس'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF8B5CF6);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.neurology,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF1E1333) : const Color(0xFFF5F3FF)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFF8B5CF6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF8B5CF6)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 9. NEURO-OTOLOGY & BALANCE: VESTIBULAR SYSTEM
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNeuroOtologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<NeuroOtologyLayer>(
      valueListenable: _neuroOtologyLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.ear,
              title: 'Neuro-Otology & Balance 3D Explorer (التوازن والأذن الداخلية)',
              subtitle: 'Vestibular labyrinth visualizer: Cochlea, Canals, Otoliths (Utricle/Saccule), and CN VIII.',
              color: const Color(0xFF6366F1),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<NeuroOtologyLayer>(
              title: 'Vestibular Layers',
              titleAr: 'أجهزة التوازن والسمع',
              values: NeuroOtologyLayer.values,
              selected: activeLayer,
              onSelected: (l) => _neuroOtologyLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFF6366F1),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Neuro-Otology & Vestibular Labyrinth',
              specialtyTitleAr: 'مجسم التوازن والقوقعة والقنوات الهلالية ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.ear,
              primaryColor: const Color(0xFF6366F1),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.audiometricProbe,
                SpecialtyInstrument.tympanostomyTube,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildNeuroOtologyMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.neuroOtology,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: 4,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'otol_cochlea', 'name': 'Cochlea & Hearing Organ', 'nameAr': 'القوقعة والعضو السمعي'},
                  {'key': 'otol_post_canal', 'name': 'Posterior Semicircular Canal', 'nameAr': 'القناة الهلالية الخلفية'},
                  {'key': 'otol_otoliths', 'name': 'Otolith Organs', 'nameAr': 'أعضاء التوازن الصخرية'},
                  {'key': 'otol_cn8', 'name': 'Vestibulocochlear Nerve (CN VIII)', 'nameAr': 'عصب التوازن والسمع القحفي'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF6366F1);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.neuroOtology,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF13152C) : const Color(0xFFEEF2FF)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFF6366F1).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF6366F1)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 10. NEURO-PSYCHIATRY & TMS: FUNCTIONAL BRAIN NETWORKS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildNeuroPsychiatryViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<NeuroPsychiatryLayer>(
      valueListenable: _neuroPsychiatryLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.activity,
              title: 'Neuro-Psychiatry & TMS Network Map (الطب النفسي والتحفيز المغناطيسي)',
              subtitle: 'Target mapping: Prefrontal DLPFC, Limbic System (Amygdala/Hippocampus), Default Mode Network (DMN).',
              color: const Color(0xFFA855F7),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<NeuroPsychiatryLayer>(
              title: 'Neuro-Psychiatric Networks',
              titleAr: 'الشبكات الوظيفية الدماغية',
              values: NeuroPsychiatryLayer.values,
              selected: activeLayer,
              onSelected: (l) => _neuroPsychiatryLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFFA855F7),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Neuro-Psychiatry & TMS Brain Surface',
              specialtyTitleAr: 'مجسم القشرة الدماغية والشبكات العصبية وجلسات TMS',
              specialtyIcon: LucideIcons.sparkles,
              primaryColor: const Color(0xFFA855F7),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.tmsFigure8Coil,
                SpecialtyInstrument.eegCapElectrode,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildNeuroPsychiatryMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.neuroPsychiatry,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.3,
              ),
              itemCount: 3,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'psych_dlpfc', 'name': 'Dorsolateral Prefrontal Cortex', 'nameAr': 'القشرة الجبهية الظهرانية'},
                  {'key': 'psych_limbic', 'name': 'Limbic Amygdala & Hippocampus', 'nameAr': 'اللوزة الدماغية والحصين'},
                  {'key': 'psych_dmn', 'name': 'Default Mode Network', 'nameAr': 'شبكة الوضع الافتراضي'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFA855F7);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.neuroPsychiatry,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF1B0F2A) : const Color(0xFFFAF5FF)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFFA855F7).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFFA855F7)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 11. RHINOLOGY & SINUS (ENT): PARANASAL SINUSES & UPPER AIRWAY
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildRhinologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<RhinologyLayer>(
      valueListenable: _rhinologyLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.wind,
              title: 'Rhinology & Sinus 3D Visualizer (الأنف والجيوب الأنفية)',
              subtitle: 'Sinus anatomy: Nasal Septum, Turbinates, Maxillary/Frontal/Ethmoid/Sphenoid Sinuses & FESS Vectors.',
              color: const Color(0xFF14B8A6),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<RhinologyLayer>(
              title: 'Airway & Sinus Layers',
              titleAr: 'طبقات المسالك والجيوب الأنفية',
              values: RhinologyLayer.values,
              selected: activeLayer,
              onSelected: (l) => _rhinologyLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFF14B8A6),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Paranasal Sinuses & Turbinates Architecture',
              specialtyTitleAr: 'مجسم الجيوب الأنفية والقرينات ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.wind,
              primaryColor: const Color(0xFF14B8A6),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.sinusEndoscope,
                SpecialtyInstrument.sinusBalloon,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildRhinologyMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.rhinologyEnt,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.3,
              ),
              itemCount: 6,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'rhino_septum', 'name': 'Nasal Septum', 'nameAr': 'الحاجز الأنفي'},
                  {'key': 'rhino_turbinates', 'name': 'Inferior Turbinates', 'nameAr': 'القرينات الأنفية'},
                  {'key': 'rhino_maxillary', 'name': 'Maxillary Sinus', 'nameAr': 'الجيب الأنفي الفكي'},
                  {'key': 'rhino_frontal', 'name': 'Frontal Sinus', 'nameAr': 'الجيب الأنفي الجبهي'},
                  {'key': 'rhino_ethmoid', 'name': 'Ethmoid Air Cells', 'nameAr': 'الخلايا الغربالية'},
                  {'key': 'rhino_sphenoid', 'name': 'Sphenoid Sinus', 'nameAr': 'الجيب الوتدي'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF14B8A6);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.rhinologyEnt,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF041816) : const Color(0xFFF0FDFA)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFF14B8A6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF14B8A6)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 12. VEIN & VASCULAR (PHLEBOLOGY): PERIPHERAL ANGIOGRAM & VEINS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildVascularVeinViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.gitFork,
          title: 'Vein & Vascular 3D Visualizer (الأوردة وجراحة الأوعية)',
          subtitle: 'Peripheral angiogram: Great Saphenous Vein (GSV), EVLA paths, Sclerotherapy, DVT clot mapping, Carotid.',
          color: const Color(0xFFDC2626),
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        Clinical3dSceneViewer(
          specialtyTitle: '3D Peripheral Vascular & Venous Matrix',
          specialtyTitleAr: 'مجسم الأوعية الدموية والأوردة السطحية والعميقة',
          specialtyIcon: LucideIcons.gitFork,
          primaryColor: const Color(0xFFDC2626),
          initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
          activeStatuses: activeStatuses,
          availableInstruments: const [
            SpecialtyInstrument.evlaLaserFiber,
            SpecialtyInstrument.scleroMicroNeedle,
          ],
          sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
              Specialty3dAnatomicalModels.buildVascularVeinMesh(
                stage,
                instrument: instrument,
                isSoloMode: isSoloMode,
                soloPartKey: soloPartKey,
              ),
          onPartSelected: (partKey, nameEn, nameAr) {
            _openStatusInspector(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
              discipline: ClinicalSpecialtyDiscipline.vascularVein,
            );
          },
          onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
            _openPartScanInspectionDialog(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
            );
          },
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: 4,
          itemBuilder: (ctx, idx) {
            final parts = [
              {'key': 'vasc_sfj', 'name': 'Saphenofemoral Junction', 'nameAr': 'المفصل الصافني الفخذي'},
              {'key': 'vasc_gsv', 'name': 'Great Saphenous Vein', 'nameAr': 'الوريد الصافن الكبير'},
              {'key': 'vasc_spider', 'name': 'Spider & Reticular Veins', 'nameAr': 'الأوردة الشبكية والعنكبوتية'},
              {'key': 'vasc_dvt_site', 'name': 'Deep Femoral Vein (DVT)', 'nameAr': 'الوريد الفخذي العميق (خثرة DVT)'},
            ];
            final p = parts[idx];
            final partKey = p['key']!;
            final statusEntry = activeStatuses[partKey];
            final hasStatus = statusEntry != null;
            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFDC2626);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: p['name']!,
                  partNameAr: p['nameAr']!,
                  discipline: ClinicalSpecialtyDiscipline.vascularVein,
                ),
                onSecondaryTap: () => _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: p['name']!,
                  partNameAr: p['nameAr']!,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasStatus
                        ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF1E0707) : const Color(0xFFFEF2F2)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStatus ? cardColor : const Color(0xFFDC2626).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p['name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p['nameAr']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFFDC2626)),
                      ),
                      if (hasStatus) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 13. PULMONOLOGY: TRACHEOBRONCHIAL TREE & LUNG PARENCHYMA
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPulmonologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<PulmonologyLayer>(
      valueListenable: _pulmonologyLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.wind,
              title: 'Pulmonology & Respiratory 3D Visualizer (الصدرية والرئتين)',
              subtitle: 'Respiratory architecture: Tracheobronchial Tree, Lung Segments, EBUS Biopsy Vectors, Pleural Drainage.',
              color: const Color(0xFF0EA5E9),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<PulmonologyLayer>(
              title: 'Pulmonary Layers',
              titleAr: 'طبقات الجهاز التنفسي',
              values: PulmonologyLayer.values,
              selected: activeLayer,
              onSelected: (l) => _pulmonologyLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFF0EA5E9),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Tracheobronchial Tree & Pleural Architecture',
              specialtyTitleAr: 'مجسم الشجرة الرغامية القصبية والرئتين ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.wind,
              primaryColor: const Color(0xFF0EA5E9),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.flexibleBronchoscope,
                SpecialtyInstrument.chestTube,
                SpecialtyInstrument.endobronchialValve,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildPulmonologyMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.pulmonology,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: 4,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'pulm_trachea', 'name': 'Trachea & Carina', 'nameAr': 'القصبة الهوائية والمهماز'},
                  {'key': 'pulm_right_lung', 'name': 'Right Lung Parenchyma', 'nameAr': 'فصوص الرئة اليمنى'},
                  {'key': 'pulm_left_lung', 'name': 'Left Lung Parenchyma', 'nameAr': 'فصوص الرئة اليسرى'},
                  {'key': 'pulm_pleural', 'name': 'Pleural Cavity', 'nameAr': 'التجويف والغشاء البلوري'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF0EA5E9);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.pulmonology,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF061424) : const Color(0xFFF0F9FF)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFF0EA5E9).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF0EA5E9)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 14. ENDOCRINOLOGY: THYROID, PARATHYROID & ADRENALS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildEndocrinologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.dna,
          title: 'Endocrinology & Glands 3D Visualizer (الغدد الصماء والهرمونات)',
          subtitle: 'Glandular mapping: Thyroid lobes, TIRADS Scoring, Parathyroid adenomas, Adrenal Incidentalomas.',
          color: const Color(0xFFD97706),
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        Container(
          height: 270,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1105) : const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFD97706).withValues(alpha: 0.3)),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _EndocrinologyPainter(isDark: isDark),
                ),
              ),
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    final w = constraints.maxWidth;
                    final h = constraints.maxHeight;
                    final cx = w * 0.5;
                    final cy = h * 0.5;

                    return Stack(
                      children: [
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (details) {
                              final normX = (details.localPosition.dx / w).clamp(0.05, 0.95);
                              final normY = (details.localPosition.dy / h).clamp(0.05, 0.95);
                              _openAddCustomPinNoteDialog(
                                context,
                                normX: normX,
                                normY: normY,
                                discipline: ClinicalSpecialtyDiscipline.endocrinology,
                              );
                            },
                          ),
                        ),
                        _buildHotspot(
                          context,
                          partKey: 'endo_thyroid_right',
                          x: cx - 120,
                          y: cy - 40,
                          label: 'Thyroid Right Lobe (الفص الدرقي الأيمن)',
                          sublabel: 'TIRADS-5 & FNA Target',
                          partName: 'Thyroid Right Lobe',
                          partNameAr: 'الفص الدرقي الأيمن',
                          discipline: ClinicalSpecialtyDiscipline.endocrinology,
                          activeStatuses: activeStatuses,
                        ),
                        _buildHotspot(
                          context,
                          partKey: 'endo_thyroid_left',
                          x: cx + 20,
                          y: cy - 40,
                          label: 'Thyroid Left Lobe (الفص الدرقي الأيسر)',
                          sublabel: 'Colloid Goiter / Nodule',
                          partName: 'Thyroid Left Lobe',
                          partNameAr: 'الفص الدرقي الأيسر',
                          discipline: ClinicalSpecialtyDiscipline.endocrinology,
                          activeStatuses: activeStatuses,
                        ),
                        _buildHotspot(
                          context,
                          partKey: 'endo_parathyroid',
                          x: cx - 60,
                          y: cy + 30,
                          label: 'Parathyroid Glands (جارات الدرقية)',
                          sublabel: 'Adenoma Sestamibi Scan',
                          partName: 'Parathyroid Glands',
                          partNameAr: 'الغدد جار الدرقية',
                          discipline: ClinicalSpecialtyDiscipline.endocrinology,
                          activeStatuses: activeStatuses,
                        ),
                        _buildHotspot(
                          context,
                          partKey: 'endo_adrenal',
                          x: cx + 70,
                          y: cy + 30,
                          label: 'Adrenal Glands (الغدة الكظرية)',
                          sublabel: 'Incidentaloma Washout CT',
                          partName: 'Adrenal Cortex & Medulla',
                          partNameAr: 'الغدة الكظرية (فوق الكلوية)',
                          discipline: ClinicalSpecialtyDiscipline.endocrinology,
                          activeStatuses: activeStatuses,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 15. UROLOGY & MEN\'S HEALTH: GENITOURINARY VISCERA
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildUrologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<UrologyLayer>(
      valueListenable: _urologyLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.droplets,
              title: 'Urology & Men\'s Health 3D Visualizer (المسالك البولية وصحة الرجل)',
              subtitle: 'Genitourinary model: Renal Cortex/Pelvis, Ureters, Bladder, Prostate (Peripheral vs. Transition Zones).',
              color: const Color(0xFF3B82F6),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<UrologyLayer>(
              title: 'Urological Layers',
              titleAr: 'طبقات الجهاز البولي والتناسلي',
              values: UrologyLayer.values,
              selected: activeLayer,
              onSelected: (l) => _urologyLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFF3B82F6),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Genitourinary System & Prostate Zonal Anatomy',
              specialtyTitleAr: 'مجسم الجهاز البولي والبروستاتا ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.droplets,
              primaryColor: const Color(0xFF3B82F6),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.rigidCystoscope,
                SpecialtyInstrument.doubleJStent,
                SpecialtyInstrument.prostateNeedle,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildUrologyMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.urology,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: 4,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'uro_kidneys', 'name': 'Bilateral Kidneys', 'nameAr': 'الكليتان والنيفرون'},
                  {'key': 'uro_ureters', 'name': 'Bilateral Ureters', 'nameAr': 'الحالبان ومسار الحصوة'},
                  {'key': 'uro_bladder', 'name': 'Urinary Bladder', 'nameAr': 'المثانة البولية'},
                  {'key': 'uro_prostate', 'name': 'Prostate Zonal Gland', 'nameAr': 'غدة البروستاتا التشريحية'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF3B82F6);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.urology,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF071226) : const Color(0xFFEFF6FF)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF3B82F6)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 16. OBSTETRICS, GYNECOLOGY & FERTILITY (REI): PELVIC VISCERA & FETAL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildObGynViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<ObGynLayer>(
      valueListenable: _obGynLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.baby,
              title: 'OB/GYN & Fertility 3D Visualizer (النساء والتوليد والخصوبة)',
              subtitle: 'Pelvic organs & Fetal tracker: Uterus (FIGO fibroid grading), Ovaries (Endometrioma), IUI/IVF catheter path.',
              color: const Color(0xFFF43F5E),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<ObGynLayer>(
              title: 'Reproductive & Fetal Layers',
              titleAr: 'طبقات الجهاز التناسلي والجنين',
              values: ObGynLayer.values,
              selected: activeLayer,
              onSelected: (l) => _obGynLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFFF43F5E),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Female Reproductive System & Pelvic Anatomy',
              specialtyTitleAr: 'مجسم الجهاز التناسلي الأنثوي والرحم والمبيض ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.baby,
              primaryColor: const Color(0xFFF43F5E),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.hysteroscopyShaft,
                SpecialtyInstrument.iudDevice,
                SpecialtyInstrument.follicleAspirationNeedle,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildObGynMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.obgyn,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: 4,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'obgyn_uterus', 'name': 'Uterus & Myometrium', 'nameAr': 'الرحم وعضلات المايومتريوم'},
                  {'key': 'obgyn_tubes', 'name': 'Fallopian Tubes', 'nameAr': 'قناتا فالوب'},
                  {'key': 'obgyn_ovaries', 'name': 'Bilateral Ovaries', 'nameAr': 'المبيضان والجريبات'},
                  {'key': 'obgyn_cervix', 'name': 'Cervix & Os', 'nameAr': 'عنق الرحم'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFF43F5E);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.obgyn,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF1E0610) : const Color(0xFFFFF1F2)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFFF43F5E).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFFF43F5E)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 17. PODIATRY & ORTHOTICS: 3D FOOT BIOMECHANICS & GAIT
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPodiatryViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.footprints,
          title: 'Podiatry & Orthotics 3D Visualizer (طب القدم وتصحيح المشية)',
          subtitle: 'Foot biomechanics: Calcaneus, Plantar Fascia injection points, Hallux Valgus bunion angles, Pressure distribution.',
          color: const Color(0xFF84CC16),
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        Clinical3dSceneViewer(
          specialtyTitle: '3D Podiatry, Tarsal/Metatarsal & Gait Kinetic Matrix',
          specialtyTitleAr: 'مجسم عظام وأوتار القدم وتوزيع الضغط الحركي ثلاثي الأبعاد',
          specialtyIcon: LucideIcons.footprints,
          primaryColor: const Color(0xFF84CC16),
          initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
          activeStatuses: activeStatuses,
          availableInstruments: const [
            SpecialtyInstrument.orthoticInsole,
            SpecialtyInstrument.fasciotomyBlade,
          ],
          sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
              Specialty3dAnatomicalModels.buildPodiatryMesh(
                stage,
                instrument: instrument,
                isSoloMode: isSoloMode,
                soloPartKey: soloPartKey,
              ),
          onPartSelected: (partKey, nameEn, nameAr) {
            _openStatusInspector(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
              discipline: ClinicalSpecialtyDiscipline.podiatry,
            );
          },
          onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
            _openPartScanInspectionDialog(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
            );
          },
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: 4,
          itemBuilder: (ctx, idx) {
            final parts = [
              {'key': 'pod_calcaneus', 'name': 'Plantar Fascia & Calcaneus', 'nameAr': 'اللفافة الأخمصية وعظم الكعب'},
              {'key': 'pod_first_mtp', 'name': '1st MTP Joint & Bunion', 'nameAr': 'مفصل إبهام القدم والوكنة'},
              {'key': 'pod_metatarsals', 'name': 'Metatarsal Arch & Heads', 'nameAr': 'رؤوس مشط القدم والضغط الحركي'},
              {'key': 'podiatry_hindfoot', 'name': 'Hindfoot, Talus & Navicular', 'nameAr': 'القدم الخلفية وعظم الكاحل'},
            ];
            final p = parts[idx];
            final partKey = p['key']!;
            final statusEntry = activeStatuses[partKey];
            final hasStatus = statusEntry != null;
            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF84CC16);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: p['name']!,
                  partNameAr: p['nameAr']!,
                  discipline: ClinicalSpecialtyDiscipline.podiatry,
                ),
                onSecondaryTap: () => _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: p['name']!,
                  partNameAr: p['nameAr']!,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF101904) : const Color(0xFFF7FEE7)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStatus ? cardColor : const Color(0xFF84CC16).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p['name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p['nameAr']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF84CC16)),
                      ),
                      if (hasStatus) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 18. COSMETIC PLASTIC SURGERY: SOFT TISSUE LAYERING
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPlasticSurgeryViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<PlasticAestheticsLayer>(
      valueListenable: _plasticLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.wand2,
              title: 'Cosmetic Plastic Surgery 3D Visualizer (جراحة التجميل ونحت الوجه والجسم)',
              subtitle: 'Soft tissue stratification: Cutaneous Skin, Adipose Compartments, SMAS Plication, Danger Zones.',
              color: const Color(0xFFE11D48),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<PlasticAestheticsLayer>(
              title: 'Surgical Layers',
              titleAr: 'طبقات الأنسجة التجميلية',
              values: PlasticAestheticsLayer.values,
              selected: activeLayer,
              onSelected: (l) => _plasticLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFFE11D48),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Aesthetic Facial Subunits & Surgical Flap Planning',
              specialtyTitleAr: 'مجسم وحدات التجميل الجراحي وخطوط الشد ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.scissors,
              primaryColor: const Color(0xFFE11D48),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.vectorLiftThread,
                SpecialtyInstrument.liposuctionCannula,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildPlasticSurgeryMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.plasticSurgery,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: 4,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'plast_nasal_dorsum', 'name': 'Nasal Vault & Dorsum', 'nameAr': 'حدبة الأنف والغضاريف'},
                  {'key': 'plast_smas_midface', 'name': 'SMAS Midface Vector', 'nameAr': 'طبقة سماص الوجهية'},
                  {'key': 'plast_lipo_zone', 'name': 'Subcutaneous Adipose', 'nameAr': 'الوسائد الدهنية العميقة'},
                  {'key': 'plastic_neck', 'name': 'Cervical Platysma & Neck', 'nameAr': 'عضلات العنق والبلاتيزما'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFE11D48);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.plasticSurgery,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF1E060D) : const Color(0xFFFFF1F2)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFFE11D48).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFFE11D48)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 19. MEDICAL AESTHETICS (INJECTORS): VASCULAR DANGER ZONES
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMedicalAestheticsViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<PlasticAestheticsLayer>(
      valueListenable: _plasticLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.syringe,
              title: 'Medical Aesthetics 3D Visualizer (الحقن التجميلي ومناطق الخطر)',
              subtitle: 'Injector guide: Neurotoxin botox units, Hyaluronic acid filler vectors, Facial/Angular artery danger zones.',
              color: const Color(0xFFF472B6),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<PlasticAestheticsLayer>(
              title: 'Facial Anatomy & Danger Layers',
              titleAr: 'طبقات الوجه ومناطق الخطر الشريانية',
              values: PlasticAestheticsLayer.values,
              selected: activeLayer,
              onSelected: (l) => _plasticLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFFF472B6),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Facial Danger Zones & Injection Plane Matrix',
              specialtyTitleAr: 'مجسم مناطق الخطر وحقن الفيلر والبوتوكس ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.sparkles,
              primaryColor: const Color(0xFFF472B6),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.microCannula,
                SpecialtyInstrument.botoxSyringe,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildMedicalAestheticsMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.medicalAesthetics,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: 4,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'aesth_danger_glabella', 'name': 'Glabella / Supratrochlear', 'nameAr': 'منطقة خطر ما بين الحاجبين'},
                  {'key': 'aesth_danger_nasolabial', 'name': 'Nasolabial / Facial Artery', 'nameAr': 'منطقة خطر الشريان الوجهي'},
                  {'key': 'aesth_danger_temple', 'name': 'Temple / Superficial Temporal', 'nameAr': 'منطقة خطر الشريان الصدغي'},
                  {'key': 'aesth_danger_infraorbital', 'name': 'Infraorbital / Tear Trough', 'nameAr': 'منطقة خطر تحت الحجاج'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFF472B6);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.medicalAesthetics,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF1E0715) : const Color(0xFFFDF2F8)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFFF472B6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFFF472B6)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 20. INTERVENTIONAL PAIN: SPINE, FACETS & EPIDURAL SPACE
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPainManagementViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<PainAcupunctureLayer>(
      valueListenable: _painLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.zap,
              title: 'Interventional Pain 3D Visualizer (علاج الألم التداخلي)',
              subtitle: 'Neuro-axial spine: Vertebral column, Facet Joints, Epidural space, DRG, Spinal Cord Stimulator (SCS).',
              color: const Color(0xFFF97316),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<PainAcupunctureLayer>(
              title: 'Spinal & Pain Layers',
              titleAr: 'طبقات العمود الفقري والأعصاب',
              values: PainAcupunctureLayer.values,
              selected: activeLayer,
              onSelected: (l) => _painLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFFF97316),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Spinal Column, Facet Joints & Epidural Target Matrix',
              specialtyTitleAr: 'مجسم الفقرات القطنية والعجزية وحقن الألم والتردد الحراري',
              specialtyIcon: LucideIcons.zap,
              primaryColor: const Color(0xFFF97316),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.tuohyEpiduralNeedle,
                SpecialtyInstrument.rfAblationElectrode,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildPainManagementMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.painManagement,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: 4,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'pain_l4_l5_epidural', 'name': 'L4-L5 Epidural Interspace', 'nameAr': 'الفضاء فوق الجافية L4-L5'},
                  {'key': 'pain_facet_joint', 'name': 'Lumbar Facet Joint & MB', 'nameAr': 'المفصل الفقرى الوجيهي'},
                  {'key': 'pain_scs_target', 'name': 'Spinal Dorsal Column (SCS)', 'nameAr': 'الحبل الشوكي ومحفز SCS'},
                  {'key': 'pain_si_joint', 'name': 'Sacroiliac (SI) Joint', 'nameAr': 'المفصل العجزي الحرقفي'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFFF97316);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.painManagement,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF1E0E05) : const Color(0xFFFFF7ED)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFFF97316).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFFF97316)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 21. ACUPUNCTURE & EASTERN MEDICINE: MERIDIAN MAPS & SAFETY
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAcupunctureViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<PainAcupunctureLayer>(
      valueListenable: _painLayerNotifier,
      builder: (context, activeLayer, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoBanner(
              icon: LucideIcons.compass,
              title: 'Acupuncture & Eastern Medicine 3D Map (الوخز بالإبر ومسارات الطاقة)',
              subtitle: 'Meridian pathways: Acupoints (Hegu LI4, Zusanli ST36), Apical safety checks (Pneumothorax avoidance), Moxa.',
              color: const Color(0xFF10B981),
              isDark: isDark,
            ),
            const SizedBox(height: 12),
            _buildLayerSwitcher<PainAcupunctureLayer>(
              title: 'Meridian & Safety Layers',
              titleAr: 'طبقات مسارات الطاقة والسلامة',
              values: PainAcupunctureLayer.values,
              selected: activeLayer,
              onSelected: (l) => _painLayerNotifier.value = l,
              getLabel: (l) => l.label,
              getDescription: (l) => l.description,
              isDark: isDark,
              color: const Color(0xFF10B981),
            ),
            const SizedBox(height: 14),
            Clinical3dSceneViewer(
              specialtyTitle: '3D Acupuncture Meridians & Deep Tissue Danger Zones',
              specialtyTitleAr: 'مجسم مسارات الطاقة الصينية ونقاط الوخز والأمان ثلاثي الأبعاد',
              specialtyIcon: LucideIcons.compass,
              primaryColor: const Color(0xFF10B981),
              initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
              activeStatuses: activeStatuses,
              availableInstruments: const [
                SpecialtyInstrument.filiformNeedle,
                SpecialtyInstrument.moxibustionCone,
              ],
              sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                  Specialty3dAnatomicalModels.buildAcupunctureMesh(
                    stage,
                    instrument: instrument,
                    isSoloMode: isSoloMode,
                    soloPartKey: soloPartKey,
                  ),
              onPartSelected: (partKey, nameEn, nameAr) {
                _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                  discipline: ClinicalSpecialtyDiscipline.acupuncture,
                );
              },
              onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: nameEn,
                  partNameAr: nameAr,
                );
              },
            ),
            const SizedBox(height: 14),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: 4,
              itemBuilder: (ctx, idx) {
                final parts = [
                  {'key': 'acu_hegu_li4', 'name': 'Hegu (LI4)', 'nameAr': 'نقطة هيكو LI4'},
                  {'key': 'acu_zusanli_st36', 'name': 'Zusanli (ST36)', 'nameAr': 'نقطة تسوسانلي ST36'},
                  {'key': 'acu_jianjing_gb21', 'name': 'Jianjing (GB21)', 'nameAr': 'نقطة جيانجينغ GB21'},
                  {'key': 'acu_taichong_lv3', 'name': 'Taichong (LV3)', 'nameAr': 'نقطة تايتشونغ LV3'},
                ];
                final p = parts[idx];
                final partKey = p['key']!;
                final statusEntry = activeStatuses[partKey];
                final hasStatus = statusEntry != null;
                final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF10B981);

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(10),
                    onTap: () => _openStatusInspector(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                      discipline: ClinicalSpecialtyDiscipline.acupuncture,
                    ),
                    onSecondaryTap: () => _openPartScanInspectionDialog(
                      context,
                      partKey: partKey,
                      partName: p['name']!,
                      partNameAr: p['nameAr']!,
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: hasStatus
                            ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                            : (isDark ? const Color(0xFF041812) : const Color(0xFFECFDF5)),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: hasStatus ? cardColor : const Color(0xFF10B981).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            p['name']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            p['nameAr']!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9.5, color: Color(0xFF10B981)),
                          ),
                          if (hasStatus) ...[
                            const SizedBox(height: 2),
                            Text(
                              '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 22. SPEECH-LANGUAGE PATHOLOGY (SLP): SWALLOWING & VOCAL APPARATUS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSpeechPathologyViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildInfoBanner(
          icon: LucideIcons.mic,
          title: 'Speech-Language Pathology 3D Visualizer (التخاطب وأمراض البلع والصوت)',
          subtitle: 'Deglutition & Phonation: Tongue Musculature, Velopharyngeal seal, Epiglottis/Valleculae, Vocal Cord Nodules.',
          color: const Color(0xFF38BDF8),
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        Clinical3dSceneViewer(
          specialtyTitle: '3D Vocal Tract, Larynx & Deglutition Apparatus',
          specialtyTitleAr: 'مجسم الحنجرة والحبال الصوتية وعضلات البلع ثلاثي الأبعاد',
          specialtyIcon: LucideIcons.mic,
          primaryColor: const Color(0xFF38BDF8),
          initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
          activeStatuses: activeStatuses,
          availableInstruments: const [
            SpecialtyInstrument.feesLaryngoscope,
            SpecialtyInstrument.passyMuirValve,
          ],
          sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
              Specialty3dAnatomicalModels.buildSpeechPathologyMesh(
                stage,
                instrument: instrument,
                isSoloMode: isSoloMode,
                soloPartKey: soloPartKey,
              ),
          onPartSelected: (partKey, nameEn, nameAr) {
            _openStatusInspector(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
              discipline: ClinicalSpecialtyDiscipline.speechPathology,
            );
          },
          onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
            _openPartScanInspectionDialog(
              context,
              partKey: partKey,
              partName: nameEn,
              partNameAr: nameAr,
            );
          },
        ),
        const SizedBox(height: 14),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.8,
          ),
          itemCount: 4,
          itemBuilder: (ctx, idx) {
            final parts = [
              {'key': 'slp_tongue', 'name': 'Lingual Motor Apparatus', 'nameAr': 'عضلات اللسان والدفع الحركي'},
              {'key': 'slp_soft_palate', 'name': 'Velopharyngeal Seal', 'nameAr': 'الحنك الرخو والصمام اللهاتي'},
              {'key': 'slp_valleculae', 'name': 'Valleculae & Epiglottis', 'nameAr': 'فوهة لسان المزمار'},
              {'key': 'slp_vocal_cords', 'name': 'True Vocal Folds & Glottis', 'nameAr': 'الحبال الصوتية الحقيقية والمزمار'},
            ];
            final p = parts[idx];
            final partKey = p['key']!;
            final statusEntry = activeStatuses[partKey];
            final hasStatus = statusEntry != null;
            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF38BDF8);

            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openStatusInspector(
                  context,
                  partKey: partKey,
                  partName: p['name']!,
                  partNameAr: p['nameAr']!,
                  discipline: ClinicalSpecialtyDiscipline.speechPathology,
                ),
                onSecondaryTap: () => _openPartScanInspectionDialog(
                  context,
                  partKey: partKey,
                  partName: p['name']!,
                  partNameAr: p['nameAr']!,
                ),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: hasStatus
                        ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                        : (isDark ? const Color(0xFF071424) : const Color(0xFFF0F9FF)),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: hasStatus ? cardColor : const Color(0xFF38BDF8).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        p['name']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p['nameAr']!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF38BDF8)),
                      ),
                      if (hasStatus) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }


  Widget _buildVitalStatChip(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 23. VETERINARY: 3D QUADRUPED SKELETON, VISCERAL & DENTAL
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildVeterinaryViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: _vetIsCanineNotifier,
      builder: (context, isCanine, _) {
        return ValueListenableBuilder<VeterinaryLayer>(
          valueListenable: _vetLayerNotifier,
          builder: (context, activeLayer, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _vetYawNotifier,
              builder: (context, yaw, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: _vetPitchNotifier,
                  builder: (context, pitch, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoBanner(
                          icon: LucideIcons.heartHandshake,
                          title: AppLanguage.tr(
                            'Veterinary 3D Anatomy & Surgical Suite',
                            'جناح الجراحة والتشريح البيطري ثلاثي الأبعاد',
                          ),
                          subtitle: AppLanguage.tr(
                            'Canine (Dog) & Feline (Cat) Multidimensional Skeletal, Visceral & Dental Matrix.',
                            'الهيكل العظمي، الأحشاء والصيغة السنية للكلاب والقطط مع المؤشرات الحيوية.',
                          ),
                          color: const Color(0xFF10B981),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF062319) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  const Icon(LucideIcons.pawPrint, size: 16, color: Color(0xFF10B981)),
                                  Text(
                                    AppLanguage.tr('Species Model:', 'نوع الحيوان:'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  _buildOphEyeToggleChip(
                                    label: AppLanguage.tr('Canine (Dog)', 'كلب (Canine)'),
                                    selected: isCanine,
                                    onSelected: () => _vetIsCanineNotifier.value = true,
                                    isDark: isDark,
                                  ),
                                  _buildOphEyeToggleChip(
                                    label: AppLanguage.tr('Feline (Cat)', 'قط (Feline)'),
                                    selected: !isCanine,
                                    onSelected: () => _vetIsCanineNotifier.value = false,
                                    isDark: isDark,
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: const Color(0xFF10B981),
                                ),
                                icon: const Icon(LucideIcons.rotateCcw, size: 14),
                                label: Text(
                                  AppLanguage.tr('Reset 3D View', 'إعادة ضبط المنظور'),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  _vetYawNotifier.value = 0.0;
                                  _vetPitchNotifier.value = 0.0;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Layer Filter Chips
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              AppLanguage.tr('Anatomical Layers:', 'الطبقات التشريحية:'),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            ...VeterinaryLayer.values.map(
                              (lyr) => ChoiceChip(
                                label: Text(lyr.label, style: const TextStyle(fontSize: 11)),
                                selected: activeLayer == lyr,
                                onSelected: (sel) {
                                  if (sel) _vetLayerNotifier.value = lyr;
                                },
                                selectedColor: const Color(0xFF10B981).withValues(alpha: 0.25),
                                checkmarkColor: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 3D Canvas
                        Clinical3dSceneViewer(
                          specialtyTitle: isCanine
                              ? '3D Canine (Dog) Quadruped Skeleton & Viscera'
                              : '3D Feline (Cat) Quadruped Skeleton & Viscera',
                          specialtyTitleAr: isCanine
                              ? 'مجسم الهيكل العظمي والأحشاء للكلاب ثلاثي الأبعاد'
                              : 'مجسم الهيكل العظمي والأحشاء للقطط ثلاثي الأبعاد',
                          specialtyIcon: LucideIcons.pawPrint,
                          primaryColor: const Color(0xFF10B981),
                          initialAgeStage: isPediatric ? ClinicalAgeStage.child : ClinicalAgeStage.adult,
                          activeStatuses: activeStatuses,
                          availableInstruments: const [
                            SpecialtyInstrument.vetBonePlate,
                            SpecialtyInstrument.vetDentalScaler,
                          ],
                          sceneMeshBuilder: (stage, {instrument, isSoloMode = false, soloPartKey}) =>
                              Specialty3dAnatomicalModels.buildVeterinaryMesh(
                                stage,
                                instrument: instrument,
                                isSoloMode: isSoloMode,
                                soloPartKey: soloPartKey,
                              ),
                          onPartSelected: (partKey, nameEn, nameAr) {
                            _openStatusInspector(
                              context,
                              partKey: partKey,
                              partName: nameEn,
                              partNameAr: nameAr,
                              discipline: ClinicalSpecialtyDiscipline.veterinary,
                            );
                          },
                          onPartSecondaryTap: (partKey, nameEn, nameAr, globalPos) {
                            _openPartScanInspectionDialog(
                              context,
                              partKey: partKey,
                              partName: nameEn,
                              partNameAr: nameAr,
                            );
                          },
                        ),
                        const SizedBox(height: 14),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 10,
                            crossAxisSpacing: 10,
                            childAspectRatio: 2.3,
                          ),
                          itemCount: 6,
                          itemBuilder: (ctx, idx) {
                            final parts = [
                              {'key': 'vet_cranial', 'name': 'Cranial & Dental', 'nameAr': 'الجمجمة والأسنان'},
                              {'key': 'vet_cervical', 'name': 'Cervical Spine', 'nameAr': 'الفقرات العنقية'},
                              {'key': 'vet_thoracic', 'name': 'Thorax & Lungs', 'nameAr': 'الصدر والرئتين'},
                              {'key': 'vet_abdominal', 'name': 'Abdominal Viscera', 'nameAr': 'الأحشاء والبطن'},
                              {'key': 'vet_pelvic', 'name': 'Pelvis & Hip', 'nameAr': 'الحوض والورك'},
                              {'key': 'vet_hindlimb_r', 'name': 'Hindlimb & Stifle', 'nameAr': 'الطرف الخلفي والركبة'},
                            ];
                            final p = parts[idx];
                            final partKey = p['key']!;
                            final statusEntry = activeStatuses[partKey];
                            final hasStatus = statusEntry != null;
                            final cardColor = hasStatus ? statusEntry.visualColor : const Color(0xFF10B981);

                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(10),
                                onTap: () => _openStatusInspector(
                                  context,
                                  partKey: partKey,
                                  partName: p['name']!,
                                  partNameAr: p['nameAr']!,
                                  discipline: ClinicalSpecialtyDiscipline.veterinary,
                                ),
                                onSecondaryTap: () => _openPartScanInspectionDialog(
                                  context,
                                  partKey: partKey,
                                  partName: p['name']!,
                                  partNameAr: p['nameAr']!,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: hasStatus
                                        ? cardColor.withValues(alpha: isDark ? 0.2 : 0.1)
                                        : (isDark ? const Color(0xFF041811) : const Color(0xFFF0FDF4)),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: hasStatus ? cardColor : const Color(0xFF10B981).withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        p['name']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11,
                                          color: isDark ? Colors.white : const Color(0xFF1E293B),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        p['nameAr']!,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 9.5, color: Color(0xFF10B981)),
                                      ),
                                      if (hasStatus) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          '${statusEntry.status.title} (${statusEntry.status.icd10Code})',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(fontSize: 9, color: cardColor, fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        // Veterinary Vital Biometrics Panel
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF062319) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLanguage.tr('Veterinary Vital Biometrics & Clinical Triage:', 'المؤشرات الحيوية البيطرية والفرز السريري:'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 14,
                                runSpacing: 8,
                                children: [
                                  _buildVitalStatChip('HR', isCanine ? '90 bpm' : '160 bpm', isDark),
                                  _buildVitalStatChip('RR', '24 rpm', isDark),
                                  _buildVitalStatChip('CRT', '< 2.0 sec', isDark),
                                  _buildVitalStatChip('Temp', '38.6 °C', isDark),
                                  _buildVitalStatChip('BCS', '5/9 Ideal', isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 24. DIAGNOSTIC LAB & PATHOLOGY: 3D SPECIMEN, CYTOLOGY & DICOM
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildDiagnosticLabViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<String>(
      valueListenable: _labMagNotifier,
      builder: (context, mag, _) {
        return ValueListenableBuilder<DiagnosticLabLayer>(
          valueListenable: _labLayerNotifier,
          builder: (context, activeLayer, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _labFocusDepthNotifier,
              builder: (context, focusDepth, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoBanner(
                      icon: LucideIcons.flaskConical,
                      title: AppLanguage.tr(
                        'Diagnostic Pathology & Microscopy Lab',
                        'مختبر التشخيص الباثولوجي والفحص المجهري ثلاثي الأبعاد',
                      ),
                      subtitle: AppLanguage.tr(
                        'Cellular Cytology, Tissue Biopsy Histopathology & Multi-Slice DICOM Lightbox.',
                        'فحص مسحات الخلايا، عينات الأنسجة المجهرية وشرائح التصوير الطبي متعدد المستويات.',
                      ),
                      color: const Color(0xFF8B5CF6),
                      isDark: isDark,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1538) : const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            children: [
                              const Icon(LucideIcons.zoomIn, size: 16, color: Color(0xFF8B5CF6)),
                              Text(
                                AppLanguage.tr('Objective Power:', 'قوة التكبير المجهري:'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              ...['10x', '40x', '100x Oil'].map(
                                (m) => _buildOphEyeToggleChip(
                                  label: m,
                                  selected: mag == m,
                                  onSelected: () => _labMagNotifier.value = m,
                                  isDark: isDark,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppLanguage.tr('Z-Plane Depth: ${focusDepth.toStringAsFixed(0)}µm', 'عمق البؤرة Z: ${focusDepth.toStringAsFixed(0)} ميكرون'),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 110,
                                child: Slider(
                                  value: focusDepth,
                                  min: 0.0,
                                  max: 100.0,
                                  activeColor: const Color(0xFF8B5CF6),
                                  onChanged: (v) => _labFocusDepthNotifier.value = v,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Layer Switcher
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          AppLanguage.tr('Diagnostic Modes:', 'أوضاع الفحص:'),
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                        ),
                        ...DiagnosticLabLayer.values.map(
                          (lyr) => ChoiceChip(
                            label: Text(lyr.label, style: const TextStyle(fontSize: 11)),
                            selected: activeLayer == lyr,
                            onSelected: (sel) {
                              if (sel) _labLayerNotifier.value = lyr;
                            },
                            selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                            checkmarkColor: const Color(0xFF8B5CF6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Canvas
                    Container(
                      height: 290,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF130E26) : const Color(0xFFFAF5FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _DiagnosticLabSpecimenPainter(
                                isDark: isDark,
                                magnification: mag,
                                focusDepth: focusDepth,
                                activeLayer: activeLayer,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            child: LayoutBuilder(
                              builder: (ctx, constraints) {
                                final w = constraints.maxWidth;
                                final h = constraints.maxHeight;
                                final cx = w * 0.5;
                                final cy = h * 0.5;

                                return Stack(
                                  children: [
                                    _buildHotspot(
                                      context,
                                      partKey: 'lab_rbc',
                                      x: cx - 80,
                                      y: cy - 40,
                                      label: AppLanguage.tr('Erythrocyte Morphology', 'مورفولوجيا كريات الدم الحمراء'),
                                      sublabel: 'Normochromic / Microcytic',
                                      partName: 'Red Blood Cell Morphology',
                                      partNameAr: 'شكل كريات الدم الحمراء وخضاب الدم',
                                      discipline: ClinicalSpecialtyDiscipline.diagnosticLab,
                                      activeStatuses: activeStatuses,
                                    ),
                                    _buildHotspot(
                                      context,
                                      partKey: 'lab_wbc',
                                      x: cx + 40,
                                      y: cy - 50,
                                      label: AppLanguage.tr('Leukocyte Differential', 'التعداد التفريقي للكريات البيضاء'),
                                      sublabel: 'Neutrophil / Band Shift',
                                      partName: 'White Blood Cell Differential',
                                      partNameAr: 'تعداد كريات الدم البيضاء والعدلات',
                                      discipline: ClinicalSpecialtyDiscipline.diagnosticLab,
                                      activeStatuses: activeStatuses,
                                    ),
                                    _buildHotspot(
                                      context,
                                      partKey: 'lab_plt',
                                      x: cx - 20,
                                      y: cy + 45,
                                      label: AppLanguage.tr('Platelet Aggregation', 'تراكم ولزوجة الصفائح الدموية'),
                                      sublabel: 'Clump Count & MPV Index',
                                      partName: 'Thrombocyte / Platelets',
                                      partNameAr: 'الصفائح الدموية ومؤشر التخثر',
                                      discipline: ClinicalSpecialtyDiscipline.diagnosticLab,
                                      activeStatuses: activeStatuses,
                                    ),
                                    _buildHotspot(
                                      context,
                                      partKey: 'lab_margin',
                                      x: cx + 75,
                                      y: cy + 30,
                                      label: AppLanguage.tr('Surgical Margin', 'حد الأمان الجراحي النسيجي'),
                                      sublabel: 'Clear > 2mm Margin Verified',
                                      partName: 'Histopathologic Margin',
                                      partNameAr: 'حد الاستئصال الجراحي النسيجي',
                                      discipline: ClinicalSpecialtyDiscipline.diagnosticLab,
                                      activeStatuses: activeStatuses,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Automated CBC & Pathology Summary Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1538) : const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLanguage.tr('Automated Hemogram & Specimen Metrics:', 'مؤشرات التعداد الآلي ومعايير العينة:'),
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 14,
                            runSpacing: 8,
                            children: [
                              _buildVitalStatChip('RBC', '4.85 M/µL', isDark),
                              _buildVitalStatChip('HGB', '14.2 g/dL', isDark),
                              _buildVitalStatChip('WBC', '6.8 K/µL', isDark),
                              _buildVitalStatChip('PLT', '245 K/µL', isDark),
                              _buildVitalStatChip('Specimen', 'Biopsy Negative', isDark),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 25. MENTAL HEALTH & PSYCHOMETRICS: 3D BRAIN AXIS & PHQ/GAD
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildMentalHealthViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<MentalHealthLayer>(
      valueListenable: _mentalLayerNotifier,
      builder: (context, activeLayer, _) {
        return ValueListenableBuilder<double>(
          valueListenable: _mentalYawNotifier,
          builder: (context, yaw, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _mentalPitchNotifier,
              builder: (context, pitch, _) {
                return ValueListenableBuilder<int>(
                  valueListenable: _mentalPhq9Notifier,
                  builder: (context, phq9, _) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _mentalGad7Notifier,
                      builder: (context, gad7, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildInfoBanner(
                              icon: LucideIcons.smilePlus,
                              title: AppLanguage.tr(
                                'Mental Health & Neuro-Cognitive Suite',
                                'جناح الصحة النفسية والشبكات العصبية المعرفية',
                              ),
                              subtitle: AppLanguage.tr(
                                'Prefrontal Cortex (dlPFC), Limbic Amygdala Fear Circuitry & Validated Psychometrics (PHQ-9 / GAD-7).',
                                'القشرة الجبهية، الجهاز النطاقي واللوزة مع المقاييس النفسية المعتمدة للاكتئاب والقلق.',
                              ),
                              color: const Color(0xFF06B6D4),
                              isDark: isDark,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF082630) : const Color(0xFFECFEFF),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLanguage.tr('Neuro-Cognitive Brain Axis (3D)', 'المحور الدماغي العصبي المعرفي 3D'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  TextButton.icon(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      foregroundColor: const Color(0xFF06B6D4),
                                    ),
                                    icon: const Icon(LucideIcons.rotateCcw, size: 14),
                                    label: Text(
                                      AppLanguage.tr('Reset 3D View', 'إعادة ضبط المنظور'),
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                    onPressed: () {
                                      _mentalYawNotifier.value = 0.0;
                                      _mentalPitchNotifier.value = 0.0;
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Layer Switcher
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  AppLanguage.tr('Neural Networks:', 'الشبكات العصبية:'),
                                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                ),
                                ...MentalHealthLayer.values.map(
                                  (lyr) => ChoiceChip(
                                    label: Text(lyr.label, style: const TextStyle(fontSize: 11)),
                                    selected: activeLayer == lyr,
                                    onSelected: (sel) {
                                      if (sel) _mentalLayerNotifier.value = lyr;
                                    },
                                    selectedColor: const Color(0xFF06B6D4).withValues(alpha: 0.25),
                                    checkmarkColor: const Color(0xFF06B6D4),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // 3D Brain Canvas
                            Container(
                              height: 290,
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF051B22) : const Color(0xFFF0FDFA),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.3)),
                              ),
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onPanUpdate: (d) {
                                        _mentalYawNotifier.value += d.delta.dx * 0.01;
                                        _mentalPitchNotifier.value = (_mentalPitchNotifier.value + d.delta.dy * 0.01).clamp(-0.8, 0.8);
                                      },
                                      child: CustomPaint(
                                        painter: _MentalHealthBrainAxisPainter(
                                          isDark: isDark,
                                          activeLayer: activeLayer,
                                          yaw: yaw,
                                          pitch: pitch,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: LayoutBuilder(
                                      builder: (ctx, constraints) {
                                        final w = constraints.maxWidth;
                                        final h = constraints.maxHeight;
                                        final cx = w * 0.5;
                                        final cy = h * 0.5;

                                        return Stack(
                                          children: [
                                            _buildHotspot(
                                              context,
                                              partKey: 'mental_dlpfc',
                                              x: cx - 75,
                                              y: cy - 45,
                                              label: AppLanguage.tr('Dorsolateral PFC (dlPFC)', 'القشرة الجبهية الظهرية الجانبية'),
                                              sublabel: 'Executive Control & Attention',
                                              partName: 'Left dlPFC Executive Network',
                                              partNameAr: 'القشرة الجبهية والتحكم المعرفي',
                                              discipline: ClinicalSpecialtyDiscipline.mentalHealth,
                                              activeStatuses: activeStatuses,
                                            ),
                                            _buildHotspot(
                                              context,
                                              partKey: 'mental_amygdala',
                                              x: cx + 15,
                                              y: cy + 10,
                                              label: AppLanguage.tr('Amygdala & Limbic Hub', 'اللوزة الدماغية والمحور النطاقي'),
                                              sublabel: 'Fight-Flight Emotional Salience',
                                              partName: 'Amygdala Fear & Anxiety Complex',
                                              partNameAr: 'اللوزة الدماغية واستجابة الخوف',
                                              discipline: ClinicalSpecialtyDiscipline.mentalHealth,
                                              activeStatuses: activeStatuses,
                                            ),
                                            _buildHotspot(
                                              context,
                                              partKey: 'mental_hippocampus',
                                              x: cx + 55,
                                              y: cy + 25,
                                              label: AppLanguage.tr('Hippocampus Circuit', 'قرن آمون وتشفير الذاكرة'),
                                              sublabel: 'Memory Consolidation & Stress Axis',
                                              partName: 'Hippocampal Neuroplasticity Axis',
                                              partNameAr: 'قرن آمون والذاكرة الانفعالية',
                                              discipline: ClinicalSpecialtyDiscipline.mentalHealth,
                                              activeStatuses: activeStatuses,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Clinical Psychometrics (PHQ-9 & GAD-7)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF082630) : const Color(0xFFECFEFF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF06B6D4).withValues(alpha: 0.25)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    AppLanguage.tr('Standardized Psychometric Assessment Scales:', 'مقاييس التقييم النفسي القياسية:'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF06B6D4)),
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLanguage.tr('PHQ-9 Depression Index: $phq9 / 27', 'مؤشر الاكتئاب PHQ-9: $phq9 / 27'),
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                            Slider(
                                              value: phq9.toDouble(),
                                              min: 0,
                                              max: 27,
                                              divisions: 27,
                                              activeColor: const Color(0xFF06B6D4),
                                              onChanged: (v) => _mentalPhq9Notifier.value = v.toInt(),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLanguage.tr('GAD-7 Anxiety Index: $gad7 / 21', 'مؤشر القلق GAD-7: $gad7 / 21'),
                                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                            Slider(
                                              value: gad7.toDouble(),
                                              min: 0,
                                              max: 21,
                                              divisions: 21,
                                              activeColor: const Color(0xFF0EA5E9),
                                              onChanged: (v) => _mentalGad7Notifier.value = v.toInt(),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // 26. PEDIATRICS: 3D INFANT GROWTH, CRANIAL FONTANELLES & DECIDUOUS
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPediatricsViewer(
    BuildContext context,
    bool isDark,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
  ) {
    return ValueListenableBuilder<int>(
      valueListenable: _pediatricAgeMonthsNotifier,
      builder: (context, ageMonths, _) {
        return ValueListenableBuilder<PediatricLayer>(
          valueListenable: _pediatricLayerNotifier,
          builder: (context, activeLayer, _) {
            return ValueListenableBuilder<double>(
              valueListenable: _pediatricYawNotifier,
              builder: (context, yaw, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: _pediatricPitchNotifier,
                  builder: (context, pitch, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildInfoBanner(
                          icon: LucideIcons.baby,
                          title: AppLanguage.tr(
                            'Pediatrics & Child Development Suite',
                            'جناح طب الأطفال والنمو والتطور السريري ثلاثي الأبعاد',
                          ),
                          subtitle: AppLanguage.tr(
                            'Infant 3D Body Proportion, Cranial Fontanelles, Primary Deciduous Dentition & WHO Percentiles.',
                            'تناسب جسم الرضيع ثلاثي الأبعاد، يافوخ الجمجمة، الأسنان اللبنية ومنحنيات النمو القياسية.',
                          ),
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2E1C05) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                          ),
                          child: Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                children: [
                                  const Icon(LucideIcons.calendar, size: 16, color: Color(0xFFF59E0B)),
                                  Text(
                                    AppLanguage.tr('Patient Age Cohort:', 'الفئة العمرية للطفل:'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  ...[6, 12, 18, 24, 36].map(
                                    (m) => _buildOphEyeToggleChip(
                                      label: '$m m',
                                      selected: ageMonths == m,
                                      onSelected: () => _pediatricAgeMonthsNotifier.value = m,
                                      isDark: isDark,
                                    ),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  visualDensity: VisualDensity.compact,
                                  foregroundColor: const Color(0xFFF59E0B),
                                ),
                                icon: const Icon(LucideIcons.rotateCcw, size: 14),
                                label: Text(
                                  AppLanguage.tr('Reset 3D View', 'إعادة ضبط المنظور'),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                onPressed: () {
                                  _pediatricYawNotifier.value = 0.0;
                                  _pediatricPitchNotifier.value = 0.0;
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Layer Switcher
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              AppLanguage.tr('Developmental Milestones:', 'المعالم التطورية:'),
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                            ),
                            ...PediatricLayer.values.map(
                              (lyr) => ChoiceChip(
                                label: Text(lyr.label, style: const TextStyle(fontSize: 11)),
                                selected: activeLayer == lyr,
                                onSelected: (sel) {
                                  if (sel) _pediatricLayerNotifier.value = lyr;
                                },
                                selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.25),
                                checkmarkColor: const Color(0xFFF59E0B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 3D Pediatric Canvas
                        Container(
                          height: 290,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1E1303) : const Color(0xFFFEFCE8),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onPanUpdate: (d) {
                                    _pediatricYawNotifier.value += d.delta.dx * 0.01;
                                    _pediatricPitchNotifier.value = (_pediatricPitchNotifier.value + d.delta.dy * 0.01).clamp(-0.8, 0.8);
                                  },
                                  child: CustomPaint(
                                    painter: _PediatricDevelopmentPainter(
                                      isDark: isDark,
                                      ageMonths: ageMonths,
                                      activeLayer: activeLayer,
                                      yaw: yaw,
                                      pitch: pitch,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: LayoutBuilder(
                                  builder: (ctx, constraints) {
                                    final w = constraints.maxWidth;
                                    final h = constraints.maxHeight;
                                    final cx = w * 0.5;
                                    final cy = h * 0.5;

                                    return Stack(
                                      children: [
                                        _buildHotspot(
                                          context,
                                          partKey: 'peds_fontanelle',
                                          x: cx - 15,
                                          y: cy - 90,
                                          label: AppLanguage.tr('Anterior Fontanelle', 'اليافوخ الأمامي وقبة الجمجمة'),
                                          sublabel: 'Soft & Flat (<18m Norm)',
                                          partName: 'Anterior Fontanelle & Bregma',
                                          partNameAr: 'اليافوخ الأمامي وقبة الجمجمة',
                                          discipline: ClinicalSpecialtyDiscipline.pediatrics,
                                          activeStatuses: activeStatuses,
                                        ),
                                        _buildHotspot(
                                          context,
                                          partKey: 'peds_teeth',
                                          x: cx - 15,
                                          y: cy - 45,
                                          label: AppLanguage.tr('Deciduous Teeth (20)', 'الأسنان اللبنية (20 سن)'),
                                          sublabel: 'Primary Incisors & Molars',
                                          partName: 'Deciduous Primary Dentition',
                                          partNameAr: 'الأسنان اللبنية للأطفال',
                                          discipline: ClinicalSpecialtyDiscipline.pediatrics,
                                          activeStatuses: activeStatuses,
                                        ),
                                        _buildHotspot(
                                          context,
                                          partKey: 'peds_abdomen',
                                          x: cx - 15,
                                          y: cy + 15,
                                          label: AppLanguage.tr('Abdomen & Umbilicus', 'بطن الطفل وسرة الوليد'),
                                          sublabel: 'No Hernia / Soft Viscera',
                                          partName: 'Pediatric Abdominal Wall',
                                          partNameAr: 'جدار البطن والسرة للأطفال',
                                          discipline: ClinicalSpecialtyDiscipline.pediatrics,
                                          activeStatuses: activeStatuses,
                                        ),
                                        _buildHotspot(
                                          context,
                                          partKey: 'peds_hips',
                                          x: cx - 15,
                                          y: cy + 70,
                                          label: AppLanguage.tr('Hips & Extremities', 'مفصلي الورك والأطراف'),
                                          sublabel: 'Barlow & Ortolani Negative',
                                          partName: 'Infant Hip Joints & Lower Limbs',
                                          partNameAr: 'مفاصل الورك والأطراف السفلية',
                                          discipline: ClinicalSpecialtyDiscipline.pediatrics,
                                          activeStatuses: activeStatuses,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // WHO Growth Percentiles Card
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF2E1C05) : const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.25)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLanguage.tr('WHO Standard Growth Percentiles (18-Month Baseline):', 'منحنيات النمو المعيارية لمنظمة الصحة العالمية:'),
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 14,
                                runSpacing: 8,
                                children: [
                                  _buildVitalStatChip('Weight', '11.2 kg (65th %)', isDark),
                                  _buildVitalStatChip('Length', '82.4 cm (58th %)', isDark),
                                  _buildVitalStatChip('Head Circ', '47.1 cm (50th %)', isDark),
                                  _buildVitalStatChip('BMI-for-Age', '16.5 (Normal)', isDark),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInfoBanner({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLanguage.isArabic
                      ? title
                      : (title.contains('(') ? title.split('(')[0].trim() : title),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // VISUAL ACTIVE STATUSES & DIAGNOSTIC FINDINGS TRAY
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildActiveStatusesTray(
    BuildContext context,
    Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
    bool isDark,
  ) {
    if (activeStatuses.isEmpty) return const SizedBox.shrink();

    final totalFee = activeStatuses.values.fold<double>(
      0.0,
      (sum, entry) => sum + entry.status.suggestedProcedure.standardFee,
    );

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF0284C7).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.stethoscope, color: Color(0xFF0284C7), size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Active 4D/3D Diagnoses & Pathological Statuses (${activeStatuses.length})',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'Total Procedures: ${totalFee.toStringAsFixed(0)} EGP',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _partStatusesNotifier.value = {},
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.white54 : Colors.black54,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: activeStatuses.values.map((entry) {
              final sevColor = entry.visualColor;
              return Container(
                constraints: const BoxConstraints(maxWidth: 360),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131D38) : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: sevColor.withValues(alpha: 0.7), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: sevColor.withValues(alpha: 0.15),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: sevColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  AppLanguage.isArabic ? '${entry.partNameAr} (${entry.partName})' : entry.partName,
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (entry.isCustomPin) ...[
                                const SizedBox(width: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: const Text('[📍 Pin]', style: TextStyle(fontSize: 8.5, color: Colors.amber, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            '${entry.status.icd10Code} • ${entry.status.title}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sevColor),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (entry.clinicalNote.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2, bottom: 2),
                              child: Text(
                                '${AppLanguage.tr('Note:', 'ملاحظة:')} ${entry.clinicalNote}',
                                style: TextStyle(fontSize: 9.5, fontStyle: FontStyle.italic, color: isDark ? Colors.white70 : Colors.black87),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          Text(
                            '${entry.status.suggestedProcedure.name} (${entry.status.suggestedProcedure.standardFee.toStringAsFixed(0)} EGP)',
                            style: TextStyle(fontSize: 9.5, color: isDark ? Colors.white60 : Colors.black54),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(LucideIcons.edit2, size: 13),
                      tooltip: 'Change Status (Search Catalog)',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () => _openStatusInspector(
                        context,
                        partKey: entry.partKey,
                        partName: entry.partName,
                        partNameAr: entry.partNameAr,
                        discipline: _activeDisciplineNotifier.value,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 13, color: Colors.redAccent),
                      tooltip: 'Remove',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () {
                        final updated = Map<String, ClinicalAnatomyStatusEntry>.from(_partStatusesNotifier.value);
                        updated.remove(entry.partKey);
                        _partStatusesNotifier.value = updated;
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SPECIALTY INSTRUMENTS & CLINICAL HARDWARE TRAY
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSpecialtyInstrumentTray(
    BuildContext context,
    ClinicalSpecialtyDiscipline discipline,
    bool isDark,
  ) {
    final entry = SpecialtyInstrumentRegistry.getEntry(discipline);
    final accentColor = _getDisciplineColor(discipline);

    return ValueListenableBuilder<ClinicalInstrumentCategory?>(
      valueListenable: _selectedInstrumentCategoryNotifier,
      builder: (context, selectedCategory, _) {
        final filteredTools = selectedCategory == null
            ? entry.tools
            : entry.tools.where((t) => t.category == selectedCategory).toList();

        final diagnosticCount = entry.tools.where((t) => t.category == ClinicalInstrumentCategory.diagnostic).length;
        final proceduralCount = entry.tools.where((t) => t.category == ClinicalInstrumentCategory.procedural).length;
        final surgicalCount = entry.tools.where((t) => t.category == ClinicalInstrumentCategory.surgical).length;
        final assessmentCount = entry.tools.where((t) => t.category == ClinicalInstrumentCategory.assessment).length;

        return Container(
          margin: const EdgeInsets.only(top: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Row with Title, Tool Count, and Collapse Toggle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(LucideIcons.wrench, color: accentColor, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                AppLanguage.isArabic
                                    ? 'مجموعة أدوات التخصص: ${entry.specialtyNameAr}'
                                    : 'Specialty Instrument Set: ${entry.specialtyNameEn}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${entry.tools.length} ${AppLanguage.tr("Tools", "أداة")}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          AppLanguage.isArabic
                              ? 'أدوات تشخيصية وإجرائية وجراحية معتمدة للتخصص السريري'
                              : 'Exhaustive diagnostic, procedural & surgical clinical hardware kit',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.chevronUp, size: 16),
                    tooltip: AppLanguage.tr('Collapse Tool Tray', 'إخفاء حقيبة الأدوات'),
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(4),
                    onPressed: () => _showInstrumentTrayNotifier.value = false,
                  ),
                ],
              ),

              // Assessment-driven Callout Banner (if applicable e.g. Mental Health or Lab)
              if (entry.isAssessmentDriven && entry.localizedClinicalNotes != null) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.info, color: Color(0xFF8B5CF6), size: 14),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.localizedClinicalNotes!,
                          style: TextStyle(
                            fontSize: 10.5,
                            color: isDark ? const Color(0xFFDDD6FE) : const Color(0xFF5B21B6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Category Filter Pills
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildCategoryPill(
                      label: AppLanguage.tr('All Tools (${entry.tools.length})', 'الكل (${entry.tools.length})'),
                      isSelected: selectedCategory == null,
                      color: accentColor,
                      onTap: () => _selectedInstrumentCategoryNotifier.value = null,
                      isDark: isDark,
                    ),
                    if (diagnosticCount > 0)
                      _buildCategoryPill(
                        label: AppLanguage.tr('Diagnostic ($diagnosticCount)', 'تشخيصي ($diagnosticCount)'),
                        isSelected: selectedCategory == ClinicalInstrumentCategory.diagnostic,
                        color: ClinicalInstrumentCategory.diagnostic.color,
                        onTap: () => _selectedInstrumentCategoryNotifier.value = ClinicalInstrumentCategory.diagnostic,
                        isDark: isDark,
                      ),
                    if (proceduralCount > 0)
                      _buildCategoryPill(
                        label: AppLanguage.tr('Procedural ($proceduralCount)', 'إجرائي ($proceduralCount)'),
                        isSelected: selectedCategory == ClinicalInstrumentCategory.procedural,
                        color: ClinicalInstrumentCategory.procedural.color,
                        onTap: () => _selectedInstrumentCategoryNotifier.value = ClinicalInstrumentCategory.procedural,
                        isDark: isDark,
                      ),
                    if (surgicalCount > 0)
                      _buildCategoryPill(
                        label: AppLanguage.tr('Surgical ($surgicalCount)', 'جراحي ($surgicalCount)'),
                        isSelected: selectedCategory == ClinicalInstrumentCategory.surgical,
                        color: ClinicalInstrumentCategory.surgical.color,
                        onTap: () => _selectedInstrumentCategoryNotifier.value = ClinicalInstrumentCategory.surgical,
                        isDark: isDark,
                      ),
                    if (assessmentCount > 0)
                      _buildCategoryPill(
                        label: AppLanguage.tr('Assessment ($assessmentCount)', 'تقييم ($assessmentCount)'),
                        isSelected: selectedCategory == ClinicalInstrumentCategory.assessment,
                        color: ClinicalInstrumentCategory.assessment.color,
                        onTap: () => _selectedInstrumentCategoryNotifier.value = ClinicalInstrumentCategory.assessment,
                        isDark: isDark,
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // List of Instruments
              ValueListenableBuilder<String?>(
                valueListenable: _selectedInstrumentIdNotifier,
                builder: (context, selectedId, _) {
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 280),
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: filteredTools.map((tool) {
                          final isSelected = tool.id == selectedId;
                          return _buildInstrumentCard(context, tool, isSelected, isDark);
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryPill({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.white70 : Colors.black87),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstrumentCard(
    BuildContext context,
    ClinicalInstrumentItem tool,
    bool isSelected,
    bool isDark,
  ) {
    final catColor = tool.category.color;

    return InkWell(
      onTap: () {
        _selectedInstrumentIdNotifier.value =
            _selectedInstrumentIdNotifier.value == tool.id ? null : tool.id;
      },
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: isSelected
              ? catColor.withValues(alpha: isDark ? 0.22 : 0.12)
              : (isDark ? const Color(0xFF131D38) : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? catColor : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            width: isSelected ? 1.6 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: catColor.withValues(alpha: 0.2),
                blurRadius: 6,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(tool.icon, size: 13, color: catColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLanguage.isArabic ? tool.nameAr : tool.nameEn,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (AppLanguage.isArabic)
                        Text(
                          tool.nameEn,
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDark ? Colors.white54 : Colors.black45,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: catColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tool.category.localizedTitle.split(' ')[0],
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: catColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              tool.localizedDescription,
              style: TextStyle(
                fontSize: 9.5,
                color: isDark ? Colors.white70 : Colors.black87,
                height: 1.25,
              ),
              maxLines: isSelected ? 6 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (tool.isNonInvasive) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.circleCheck, size: 10, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text(
                    AppLanguage.tr('Non-Invasive Diagnostic Tool', 'أداة تشخيصية غير تداخلية'),
                    style: const TextStyle(
                      fontSize: 8.5,
                      color: Color(0xFF10B981),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // HELPER WIDGETS & PROCEDURAL MODALS
  // ─────────────────────────────────────────────────────────────────────────
  void _openStatusInspector(
    BuildContext context, {
    required String partKey,
    required String partName,
    required String partNameAr,
    required ClinicalSpecialtyDiscipline discipline,
  }) {
    final current = _partStatusesNotifier.value[partKey];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ClinicalStatusInspectorModal(
        partKey: partKey,
        partName: partName,
        partNameAr: partNameAr,
        discipline: discipline,
        currentStatus: current,
        onStatusSelected: (statusDef) {
          final updated = Map<String, ClinicalAnatomyStatusEntry>.from(_partStatusesNotifier.value);
          updated[partKey] = ClinicalAnatomyStatusEntry(
            partKey: partKey,
            partName: partName,
            partNameAr: partNameAr,
            status: statusDef,
            appliedAt: DateTime.now(),
          );
          _partStatusesNotifier.value = updated;

          onProcedureApplied?.call(
            statusDef.suggestedProcedure,
            'Diagnosis: ${statusDef.title} (${statusDef.icd10Code}) on $partName ($partNameAr)',
          );
        },
        onClearStatus: () {
          final updated = Map<String, ClinicalAnatomyStatusEntry>.from(_partStatusesNotifier.value);
          updated.remove(partKey);
          _partStatusesNotifier.value = updated;
        },
      ),
    );
  }

  void _openPartScanInspectionDialog(
    BuildContext context, {
    required String partKey,
    required String partName,
    required String partNameAr,
  }) {
    showDialog(
      context: context,
      builder: (ctx) {
        return ValueListenableBuilder<List<MedicalAttachment>>(
          valueListenable: _attachmentsNotifier,
          builder: (dialogCtx, attachments, _) {
            final partScans = attachments
                .where((a) => a.anatomicalPartKey == partKey)
                .toList();

            return Dialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF38BDF8), width: 1.5),
              ),
              insetPadding: const EdgeInsets.all(24),
              child: Container(
                width: 680,
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(LucideIcons.scanLine, color: Color(0xFF38BDF8), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$partName ($partNameAr)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '3D Anatomical Scan & Imaging Inspector • Part ID: $partKey',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white70),
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFF334155), height: 1),
                    const SizedBox(height: 14),

                    // Explanatory badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF475569)),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.info, color: Color(0xFF38BDF8), size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Viewing scans, X-rays, and radiology files specifically attached to this 3D anatomical structure. General lab results and blood work are displayed in the standard clinical attachments dock below.',
                              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Scans list or empty state
                    if (partScans.isEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF090D16),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1E293B)),
                        ),
                        child: Column(
                          children: [
                            const Icon(LucideIcons.scan, color: Color(0xFF64748B), size: 40),
                            const SizedBox(height: 10),
                            Text(
                              'No imaging scans currently attached to $partName',
                              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Attach X-ray, CT/MRI DICOM series, or ultrasound scans directly to this organ part.',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    else
                      SizedBox(
                        height: 165,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: partScans.length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (ctx, i) {
                            final scan = partScans[i];
                            final IconData scanIcon;
                            final Color iconColor;
                            final String modalityLabel;

                            switch (scan.type) {
                              case MedicalAttachmentType.xrayRadiograph:
                                scanIcon = LucideIcons.scanLine;
                                iconColor = const Color(0xFF38BDF8);
                                modalityLabel = 'X-Ray Radiograph';
                                break;
                              case MedicalAttachmentType.dicomScan:
                                scanIcon = LucideIcons.scan;
                                iconColor = const Color(0xFFA78BFA);
                                modalityLabel = 'CT / MRI Scan';
                                break;
                              case MedicalAttachmentType.ultrasound:
                                scanIcon = LucideIcons.waves;
                                iconColor = const Color(0xFF2DD4BF);
                                modalityLabel = 'Ultrasound (US)';
                                break;
                              case MedicalAttachmentType.labReport:
                                scanIcon = LucideIcons.flaskConical;
                                iconColor = const Color(0xFFFBBF24);
                                modalityLabel = 'Lab Panel';
                                break;
                              case MedicalAttachmentType.prescriptionPhoto:
                                scanIcon = LucideIcons.camera;
                                iconColor = const Color(0xFF34D399);
                                modalityLabel = 'Clinical Photo';
                                break;
                            }

                            return Container(
                              width: 260,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: iconColor.withValues(alpha: 0.6), width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.25),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: iconColor.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Icon(scanIcon, color: iconColor, size: 14),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              scan.title,
                                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              modalityLabel,
                                              style: TextStyle(color: iconColor, fontSize: 9, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(LucideIcons.trash2, size: 13, color: Colors.redAccent),
                                        tooltip: 'Remove',
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(4),
                                        onPressed: () {
                                          final updated = List<MedicalAttachment>.from(_attachmentsNotifier.value);
                                          updated.removeWhere((a) => a.id == scan.id);
                                          _attachmentsNotifier.value = updated;
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    scan.doctorNotes,
                                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Spacer(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          scan.fileSize,
                                          style: const TextStyle(color: Color(0xFF64748B), fontSize: 9.5),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      InkWell(
                                        onTap: () => DoctorAttachmentsLightbox.openLightbox(context, scan),
                                        borderRadius: BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: iconColor.withValues(alpha: 0.18),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'View Lightbox',
                                                style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(LucideIcons.arrowUpRight, color: iconColor, size: 11),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    const SizedBox(height: 18),

                    // Actions
                    Wrap(
                      alignment: WrapAlignment.end,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogCtx).pop(),
                          child: const Text('Close', style: TextStyle(color: Colors.white70)),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0284C7),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(LucideIcons.plus, size: 16),
                          label: Text('Attach File / X-Ray to $partName'),
                          onPressed: () {
                            _showAddPartScanDialog(
                              context,
                              partKey: partKey,
                              partName: partName,
                              partNameAr: partNameAr,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddPartScanDialog(
    BuildContext context, {
    required String partKey,
    required String partName,
    required String partNameAr,
  }) {
    final titleCtrl = TextEditingController(text: '$partName X-Ray / Scan');
    final notesCtrl = TextEditingController(text: 'Attached to $partName ($partNameAr) via 3D Inspector');
    MedicalAttachmentType selectedType = MedicalAttachmentType.xrayRadiograph;
    PlatformFile? pickedFile;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0F172A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFF0284C7)),
              ),
              title: Row(
                children: [
                  const Icon(LucideIcons.upload, color: Color(0xFF38BDF8), size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Attach Medical File to $partName',
                      style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // File Picker Button
                      InkWell(
                        onTap: () async {
                          try {
                            final result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'dcm', 'dicom'],
                            );
                            if (result != null && result.files.isNotEmpty) {
                              setDialogState(() {
                                pickedFile = result.files.first;
                                if (titleCtrl.text.trim().isEmpty || titleCtrl.text == '$partName X-Ray / Scan') {
                                  titleCtrl.text = pickedFile!.name.split('.').first;
                                }
                              });
                            }
                          } catch (_) {}
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: pickedFile != null ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                              width: pickedFile != null ? 1.5 : 1.0,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                pickedFile != null ? LucideIcons.fileCheck : LucideIcons.uploadCloud,
                                size: 18,
                                color: const Color(0xFF38BDF8),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  pickedFile != null
                                      ? '${pickedFile!.name} (${(pickedFile!.size / 1024).toStringAsFixed(1)} KB)'
                                      : 'Browse / Choose File (X-Ray, DICOM, CT, PDF)...',
                                  style: TextStyle(
                                    color: pickedFile != null ? Colors.white : const Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: pickedFile != null ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0284C7).withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'Browse',
                                  style: TextStyle(fontSize: 10, color: Color(0xFF38BDF8), fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: titleCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'File / Scan Title',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF334155))),
                        ),
                      ),
                      const SizedBox(height: 12),

                      DropdownButtonFormField<MedicalAttachmentType>(
                        initialValue: selectedType,
                        dropdownColor: const Color(0xFF1E293B),
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Imaging Modality / File Category',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: MedicalAttachmentType.xrayRadiograph,
                            child: Text('Digital X-Ray Radiograph'),
                          ),
                          DropdownMenuItem(
                            value: MedicalAttachmentType.dicomScan,
                            child: Text('CT / MRI DICOM Scan'),
                          ),
                          DropdownMenuItem(
                            value: MedicalAttachmentType.ultrasound,
                            child: Text('High-Res Ultrasound (US)'),
                          ),
                          DropdownMenuItem(
                            value: MedicalAttachmentType.labReport,
                            child: Text('Laboratory Panel / Pathology Report'),
                          ),
                          DropdownMenuItem(
                            value: MedicalAttachmentType.prescriptionPhoto,
                            child: Text('Clinical Photography / Document'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => selectedType = val);
                        },
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: const InputDecoration(
                          labelText: 'Clinical Notes / Radiologist Findings',
                          labelStyle: TextStyle(color: Color(0xFF94A3B8)),
                          enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF334155))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0284C7)),
                  onPressed: () {
                    final sizeStr = pickedFile != null
                        ? (pickedFile!.size > 1024 * 1024
                            ? '${(pickedFile!.size / (1024 * 1024)).toStringAsFixed(1)} MB'
                            : '${(pickedFile!.size / 1024).toStringAsFixed(1)} KB')
                        : '4.8 MB';

                    final newAttachment = MedicalAttachment(
                      id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
                      title: titleCtrl.text.trim().isEmpty ? '$partName Scan' : titleCtrl.text.trim(),
                      type: selectedType,
                      uploadDate: DateTime.now(),
                      fileSize: sizeStr,
                      filePath: pickedFile?.path,
                      doctorNotes: notesCtrl.text.trim(),
                      anatomicalPartKey: partKey,
                      anatomicalPartNameEn: partName,
                      anatomicalPartNameAr: partNameAr,
                      disciplineKey: _activeDisciplineNotifier.value.name,
                    );
                    _attachmentsNotifier.value = [
                      ..._attachmentsNotifier.value,
                      newAttachment,
                    ];
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Attached file to $partName.'),
                        backgroundColor: const Color(0xFF0284C7),
                      ),
                    );
                  },
                  child: const Text('Attach File', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static List<MedicalAttachment> _createDefaultMedicalAttachments() {
    return [
      MedicalAttachment(
        id: 'att_femur_1',
        title: 'Right Femur AP/Lateral Digital Radiograph',
        type: MedicalAttachmentType.xrayRadiograph,
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '6.2 MB',
        doctorNotes: 'Mid-shaft cortical alignment intact. Trace callus formation without dislocation.',
        anatomicalPartKey: 'ortho_ORTHO-27506',
        anatomicalPartNameEn: 'Femur (Thigh Bone)',
        anatomicalPartNameAr: 'عظم الفخذ',
        disciplineKey: 'orthopedics',
      ),
      MedicalAttachment(
        id: 'att_pelvis_1',
        title: 'Pelvis & Bilateral Hip Joints AP Survey',
        type: MedicalAttachmentType.xrayRadiograph,
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        fileSize: '8.4 MB',
        doctorNotes: 'Normal acetabular roof angle and joint space. No subcapital fracture.',
        anatomicalPartKey: 'ortho_ORTHO-27130',
        anatomicalPartNameEn: 'Pelvis & Hip Joint',
        anatomicalPartNameAr: 'الحوض ومفصل الورك',
        disciplineKey: 'orthopedics',
      ),
      MedicalAttachment(
        id: 'att_cardio_lv',
        title: 'Transthoracic Echocardiogram (TTE) 4-Chamber Cine',
        type: MedicalAttachmentType.ultrasound,
        uploadDate: DateTime.now().subtract(const Duration(hours: 5)),
        fileSize: '14.2 MB',
        doctorNotes: 'Left Ventricular ejection fraction 62%. Normal basal septal thickness.',
        anatomicalPartKey: 'cardio_leftVentricle',
        anatomicalPartNameEn: 'Left Ventricle',
        anatomicalPartNameAr: 'البطين الأيسر',
        disciplineKey: 'cardiology',
      ),
      MedicalAttachment(
        id: 'att_neuro_1',
        title: 'Brain MRI T1/T2 Axial FLAIR Series',
        type: MedicalAttachmentType.dicomScan,
        uploadDate: DateTime.now().subtract(const Duration(days: 3)),
        fileSize: '32.1 MB',
        doctorNotes: 'Frontal cortex gray-white differentiation preserved. No acute intracranial hemorrhage.',
        anatomicalPartKey: 'neuro_frontal',
        anatomicalPartNameEn: 'Frontal Cortex',
        anatomicalPartNameAr: 'الفص الجبهي',
        disciplineKey: 'neurology',
      ),
      MedicalAttachment(
        id: 'att_oph_retina',
        title: 'High-Resolution Macular Spectral-Domain OCT',
        type: MedicalAttachmentType.dicomScan,
        uploadDate: DateTime.now().subtract(const Duration(days: 2)),
        fileSize: '11.8 MB',
        doctorNotes: 'Central foveal pit architecture preserved. No subretinal fluid or macular edema.',
        anatomicalPartKey: 'oph_retina',
        anatomicalPartNameEn: 'Retina & Macula',
        anatomicalPartNameAr: 'الشبكية والبقعة الصفراء',
        disciplineKey: 'ophthalmology',
      ),
      MedicalAttachment(
        id: 'att_uro_kidneys',
        title: 'Renal High-Resolution Ultrasound & Color Doppler',
        type: MedicalAttachmentType.ultrasound,
        uploadDate: DateTime.now().subtract(const Duration(days: 1)),
        fileSize: '9.6 MB',
        doctorNotes: 'Bilateral renal length 11.2 cm. No hydronephrosis or acoustic shadow calculus.',
        anatomicalPartKey: 'uro_kidneys',
        anatomicalPartNameEn: 'Bilateral Kidneys',
        anatomicalPartNameAr: 'الكليتان',
        disciplineKey: 'urology',
      ),
      MedicalAttachment(
        id: 'att_dental_19',
        title: 'Periapical Digital Radiograph Tooth #19',
        type: MedicalAttachmentType.xrayRadiograph,
        uploadDate: DateTime.now().subtract(const Duration(hours: 8)),
        fileSize: '3.8 MB',
        doctorNotes: 'Distal occlusal radiolucency approaching pulp horn. Periodontal ligament intact.',
        anatomicalPartKey: 'tooth_19',
        anatomicalPartNameEn: 'Tooth #19',
        anatomicalPartNameAr: 'السن رقم 19',
        disciplineKey: 'dental',
      ),
    ];
  }

  Widget _buildHotspot(
    BuildContext context, {
    required String partKey,
    required double x,
    required double y,
    required String label,
    required String sublabel,
    required String partName,
    required String partNameAr,
    required ClinicalSpecialtyDiscipline discipline,
    required Map<String, ClinicalAnatomyStatusEntry> activeStatuses,
    VoidCallback? onApply,
  }) {
    final statusEntry = activeStatuses[partKey];
    final hasStatus = statusEntry != null;
    final activeColor = hasStatus ? statusEntry.visualColor : const Color(0xFF0284C7);

    return Positioned(
      left: x,
      top: y,
      child: InkWell(
        onTap: () {
          _openStatusInspector(
            context,
            partKey: partKey,
            partName: partName,
            partNameAr: partNameAr,
            discipline: discipline,
          );
        },
        onSecondaryTap: () {
          _openPartScanInspectionDialog(
            context,
            partKey: partKey,
            partName: partName,
            partNameAr: partNameAr,
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: activeColor, width: hasStatus ? 2.0 : 1.5),
            boxShadow: [
              BoxShadow(
                color: activeColor.withValues(alpha: hasStatus ? 0.6 : 0.35),
                blurRadius: hasStatus ? 10 : 6,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: hasStatus ? activeColor : const Color(0xFF38BDF8),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    AppLanguage.isArabic
                        ? (label.contains('(')
                            ? label
                            : (partNameAr.isNotEmpty ? '$partName ($partNameAr)' : label))
                        : (label.contains('(') ? label.split('(')[0].trim() : (partName.isNotEmpty ? partName : label)),
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              if (hasStatus) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: activeColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '${statusEntry.status.icd10Code}: ${AppLanguage.isArabic ? statusEntry.status.titleAr : statusEntry.status.title}',
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.bold,
                      color: activeColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _openAddCustomPinNoteDialog(
    BuildContext context, {
    required double normX,
    required double normY,
    required ClinicalSpecialtyDiscipline discipline,
    String? toothCode,
    String? partName,
    double? x3d,
    double? y3d,
    double? z3d,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController(text: partName ?? '');
    final noteController = TextEditingController();
    final codeController = TextEditingController();
    final feeController = TextEditingController();
    final severityNotifier = ValueNotifier<ClinicalSeverityLevel>(ClinicalSeverityLevel.moderate);
    final categoryNotifier = ValueNotifier<ClinicalStatusCategory>(ClinicalStatusCategory.all);

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.pin, color: Color(0xFF0284C7), size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLanguage.tr('Add 3D Pin Note', 'إضافة ملاحظة موضعية ثلاثية الأبعاد (3D Pin Note)'),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5),
                            ),
                            if (toothCode != null || partName != null)
                              Text(
                                '📍 ${AppLanguage.tr('Anchored to', 'مثبت على')}: ${partName ?? 'Tooth #$toothCode'} (3D)',
                                style: const TextStyle(fontSize: 11, color: Color(0xFF0284C7), fontWeight: FontWeight.bold),
                              )
                            else
                              Text(
                                '${AppLanguage.tr('Pin Coordinates', 'إحداثيات الموضع')}: X: ${(normX * 100).toStringAsFixed(1)}% | Y: ${(normY * 100).toStringAsFixed(1)}%',
                                style: const TextStyle(fontSize: 10.5, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const Divider(height: 20),
                  // Finding title
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('Finding Title / Anatomical Part', 'عنوان الملاحظة / الجزء التشريحي'),
                      hintText: AppLanguage.tr('e.g. Pain point, localized edema, tissue lesion...', 'مثال: نقطة ألم، وذمة موضعية، آفة نسيجية...'),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Clinical notes
                  TextField(
                    controller: noteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: AppLanguage.tr('Clinical Notes & Diagnosis', 'الملاحظات والتشخيص السريري'),
                      hintText: AppLanguage.tr('Enter clinical notes or treatment recommendation...', 'اكتب الملاحظات الطبية أو التوصية العلاجية...'),
                      isDense: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Severity Selector
                  Text(AppLanguage.tr('Severity Level:', 'درجة الخطورة:'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<ClinicalSeverityLevel>(
                    valueListenable: severityNotifier,
                    builder: (context, currentSev, _) {
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: ClinicalSeverityLevel.values.map((sev) {
                          final isSel = sev == currentSev;
                          return ChoiceChip(
                            selected: isSel,
                            label: Text(sev.label, style: TextStyle(fontSize: 10, color: isSel ? Colors.white : sev.color)),
                            selectedColor: sev.color,
                            backgroundColor: sev.color.withValues(alpha: 0.1),
                            onSelected: (val) {
                              if (val) severityNotifier.value = sev;
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Category Selector
                  Text(AppLanguage.tr('Pathology Category:', 'التصنيف المرضي:'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  ValueListenableBuilder<ClinicalStatusCategory>(
                    valueListenable: categoryNotifier,
                    builder: (context, currentCat, _) {
                      return DropdownButtonFormField<ClinicalStatusCategory>(
                        initialValue: currentCat,
                        isDense: true,
                        isExpanded: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        ),
                        items: ClinicalStatusCategory.values.map((cat) {
                          return DropdownMenuItem(
                            value: cat,
                            child: Text(
                              cat.label,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (cat) {
                          if (cat != null) categoryNotifier.value = cat;
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  // Optional Code & Fee
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: codeController,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('Procedure Code / ICD (Optional)', 'كود الإجراء / ICD (اختياري)'),
                            hintText: 'PIN-01',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: feeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: AppLanguage.tr('Fee (EGP)', 'السعر (ج.م)'),
                            hintText: '0.00',
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Buttons
                  Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: Text(AppLanguage.tr('Cancel', 'إلغاء'))),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(LucideIcons.save, size: 15),
                        label: Text(AppLanguage.tr('Save Pin Note', 'حفظ الملاحظة والدبوس'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () {
                          final title = titleController.text.trim();
                          final note = noteController.text.trim();
                          final code = codeController.text.trim();
                          final fee = double.tryParse(feeController.text.trim()) ?? 0.0;
                          final sev = severityNotifier.value;
                          final cat = categoryNotifier.value;

                          final key = toothCode != null
                              ? 'pin_tooth_${toothCode}_${DateTime.now().millisecondsSinceEpoch}'
                              : 'custom_pin_${DateTime.now().millisecondsSinceEpoch}';
                          final displayTitle = title.isNotEmpty ? title : (partName ?? AppLanguage.tr('Custom Pin', 'ملاحظة موضعية'));
                          final entry = ClinicalAnatomyStatusEntry(
                            partKey: key,
                            partName: displayTitle,
                            partNameAr: displayTitle,
                            status: ClinicalStatusDefinition(
                              id: 'def_$key',
                              title: displayTitle,
                              titleAr: displayTitle,
                              icd10Code: code.isNotEmpty ? code : 'OBS-01',
                              category: cat,
                              severity: sev,
                              description: note.isNotEmpty ? note : AppLanguage.tr('Localized anatomical note', 'ملاحظة تشريحية موضعية'),
                              suggestedProcedure: ProcedureItem(
                                id: 'proc_$key',
                                code: code.isNotEmpty ? code : 'OBS-01',
                                name: note.isNotEmpty ? note : displayTitle,
                                standardFee: fee,
                              ),
                            ),
                            appliedAt: DateTime.now(),
                            clinicalNote: note,
                            normalizedX: normX,
                            normalizedY: normY,
                            x3d: x3d,
                            y3d: y3d,
                            z3d: z3d,
                            attachedToothCode: toothCode,
                          );

                          _partStatusesNotifier.value = {
                            ..._partStatusesNotifier.value,
                            key: entry,
                          };

                          if (fee > 0) {
                            onProcedureApplied?.call(
                              entry.status.suggestedProcedure,
                              'Custom Pin Finding: $displayTitle - $note',
                            );
                          }

                          Navigator.pop(ctx);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCustomPinMarker(BuildContext context, ClinicalAnatomyStatusEntry pin, bool isDark) {
    final color = pin.visualColor;
    final fee = pin.status.suggestedProcedure.standardFee;
    return Tooltip(
      key: ValueKey('tooltip_${pin.partKey}'),
      message: '${pin.partName}: ${pin.clinicalNote.isNotEmpty ? pin.clinicalNote : pin.status.title}${fee > 0 ? " (${fee.toStringAsFixed(2)} EGP)" : ""}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: ValueKey('pin_${pin.partKey}'),
          onTap: () => _openStatusInspector(
            context,
            partKey: pin.partKey,
            partName: pin.partName,
            partNameAr: pin.partNameAr,
            discipline: _activeDisciplineNotifier.value,
          ),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(LucideIcons.mapPin, size: 10, color: Colors.white),
                ),
                const SizedBox(width: 5),
                Text(
                  pin.partName,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (fee > 0) ...[
                  const SizedBox(width: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${fee.toStringAsFixed(0)} EGP',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF34D399),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openOphthalmologyActionSheet(
    BuildContext context, {
    required String structure,
    required String defaultCode,
    required String defaultProc,
    required double defaultFee,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.eye, color: Color(0xFF0284C7), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ocular Structure: $structure',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const Text(
                          'Select clinical procedure to add to consultation visit',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(defaultProc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('CPT Code: $defaultCode', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                    Text(
                      'EGP ${defaultFee.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0284C7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0284C7),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text('Apply Procedure to Consultation Cart', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  onProcedureApplied?.call(
                    ProcedureItem(
                      id: 'proc_${DateTime.now().millisecondsSinceEpoch}',
                      code: defaultCode,
                      name: defaultProc,
                      standardFee: defaultFee,
                    ),
                    'Ocular Procedure Applied: $structure - $defaultProc',
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper metadata
  String _getDisciplineTitle(ClinicalSpecialtyDiscipline disc) {
    switch (disc) {
      case ClinicalSpecialtyDiscipline.neurology:
        return 'Neurology & Neurosurgery';
      case ClinicalSpecialtyDiscipline.neuroOtology:
        return 'Neuro-Otology & Balance';
      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
        return 'Neuro-Psychiatry & TMS';
      case ClinicalSpecialtyDiscipline.ophthalmology:
        return 'Ophthalmology & Eye Care';
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
        return 'Rhinology & Sinus (ENT)';
      case ClinicalSpecialtyDiscipline.dental:
        return 'Dental & Oral Surgery';
      case ClinicalSpecialtyDiscipline.cardiology:
        return 'Cardiology & Cardiovascular';
      case ClinicalSpecialtyDiscipline.vascularVein:
        return 'Vein & Vascular (Phlebology)';
      case ClinicalSpecialtyDiscipline.pulmonology:
        return 'Pulmonology & Respiratory';
      case ClinicalSpecialtyDiscipline.endocrinology:
        return 'Endocrinology & Glands';
      case ClinicalSpecialtyDiscipline.gastroenterology:
        return 'Gastroenterology & Intestinal Health';
      case ClinicalSpecialtyDiscipline.urology:
        return 'Urology & Men\'s Health';
      case ClinicalSpecialtyDiscipline.obgyn:
        return 'Obstetrics, Gynecology & Fertility (REI)';
      case ClinicalSpecialtyDiscipline.orthopedics:
        return 'Orthopedics & Bone Surgery';
      case ClinicalSpecialtyDiscipline.physiotherapy:
        return 'Physiotherapy & Musculoskeletal';
      case ClinicalSpecialtyDiscipline.podiatry:
        return 'Podiatry & Orthotics (P&O)';
      case ClinicalSpecialtyDiscipline.plasticSurgery:
        return 'Cosmetic Plastic Surgery';
      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return 'Medical Aesthetics (Injectors)';
      case ClinicalSpecialtyDiscipline.dermatology:
        return 'Dermatology & Hair Restoration';
      case ClinicalSpecialtyDiscipline.painManagement:
        return 'Interventional Pain Management';
      case ClinicalSpecialtyDiscipline.acupuncture:
        return 'Acupuncture & Eastern Medicine';
      case ClinicalSpecialtyDiscipline.speechPathology:
        return 'Speech-Language Pathology (SLP)';
      case ClinicalSpecialtyDiscipline.veterinary:
        return 'Veterinary Medicine & Surgery';
      case ClinicalSpecialtyDiscipline.diagnosticLab:
        return 'Diagnostic Pathology & Laboratory';
      case ClinicalSpecialtyDiscipline.mentalHealth:
        return 'Mental Health & Behavioral Counseling';
      case ClinicalSpecialtyDiscipline.pediatrics:
        return 'Pediatrics & Child Health';
      case ClinicalSpecialtyDiscipline.general:
        return 'General Medical Practice';
    }
  }

  String _getDisciplineSubtitle(ClinicalSpecialtyDiscipline disc) {
    switch (disc) {
      case ClinicalSpecialtyDiscipline.neurology:
        return '3D Brain & Skull Base with Circle of Willis & DBS Trajectories';
      case ClinicalSpecialtyDiscipline.neuroOtology:
        return 'Vestibular System, Semicircular Canals & Epley Particle Tracker';
      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
        return 'Functional Brain Networks (DLPFC, DMN) & rTMS Coil Mapping';
      case ClinicalSpecialtyDiscipline.ophthalmology:
        return 'Ocular Spherical Cross-Section with Interactive Layer Switcher';
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
        return 'Paranasal Sinuses, Nasal Septum & Balloon Sinuplasty Vectors';
      case ClinicalSpecialtyDiscipline.dental:
        return 'FDI 2-Digit Universal Odontogram with 3D Tooth Matrix';
      case ClinicalSpecialtyDiscipline.cardiology:
        return 'Coronary Tree (LAD/LCx/RCA), Valves & TAVR Landing Zone';
      case ClinicalSpecialtyDiscipline.vascularVein:
        return 'Peripheral Angiogram, EVLA Laser Paths & DVT Clot Mapping';
      case ClinicalSpecialtyDiscipline.pulmonology:
        return 'Tracheobronchial Tree, EBUS Biopsy Vectors & Pleural Drainage';
      case ClinicalSpecialtyDiscipline.endocrinology:
        return 'Thyroid TIRADS Scoring, Parathyroid & Adrenal 3D Localization';
      case ClinicalSpecialtyDiscipline.gastroenterology:
        return 'Digestive Tract & Endoscopy/Colonoscopy Action Matrix';
      case ClinicalSpecialtyDiscipline.urology:
        return 'Renal Lithotripsy, MRI-TRUS Fusion Biopsy & HoLEP Laser Paths';
      case ClinicalSpecialtyDiscipline.obgyn:
        return 'Pelvic Organs, Uterine FIGO Mapping & Embryo Transfer Vectors';
      case ClinicalSpecialtyDiscipline.orthopedics:
        return 'Full 3D Skeletal Frame with Osteotomy Cut-Planes & Goniometry';
      case ClinicalSpecialtyDiscipline.physiotherapy:
        return 'Major Muscular Systems with Myofascial Kinetic Taping';
      case ClinicalSpecialtyDiscipline.podiatry:
        return 'Foot Biomechanics, Plantar Fascia & Bunion Osteotomy Angles';
      case ClinicalSpecialtyDiscipline.plasticSurgery:
        return 'Craniofacial Soft Tissue Layers, SMAS Vectors & Rhinoplasty';
      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return 'Facial Danger Zones, Botox Units & Dermal Filler Depth Vectors';
      case ClinicalSpecialtyDiscipline.dermatology:
        return 'Dermatome Rule-of-Nines, Whole-Body Moles & FUE Hair Grafts';
      case ClinicalSpecialtyDiscipline.painManagement:
        return 'Fluoroscopy Epidural Needle Paths, Facet RFA & SCS Leads';
      case ClinicalSpecialtyDiscipline.acupuncture:
        return 'Meridian Maps, Acupoints & Organ Depth Safety Checks';
      case ClinicalSpecialtyDiscipline.speechPathology:
        return 'Swallowing Apparatus, Vocal Cord Nodules & Aspiration Paths';
      case ClinicalSpecialtyDiscipline.veterinary:
        return 'Canine & Feline 3D Skeletal Frame, Dental Formula & Vital Biometrics';
      case ClinicalSpecialtyDiscipline.diagnosticLab:
        return '3D Specimen Histology, Microscopic Cytology & Multi-Slice DICOM Lightbox';
      case ClinicalSpecialtyDiscipline.mentalHealth:
        return '3D Neuro-Cognitive Brain Axis, Limbic Circuits & Psychometric Scales';
      case ClinicalSpecialtyDiscipline.pediatrics:
        return '3D Developmental Anatomy, Cranial Fontanelles & WHO Growth Percentiles';
      case ClinicalSpecialtyDiscipline.general:
        return 'Integrated Multi-Disciplinary Anatomical Operating Suite';
    }
  }

  IconData _getDisciplineIcon(ClinicalSpecialtyDiscipline disc) {
    switch (disc) {
      case ClinicalSpecialtyDiscipline.neurology:
        return LucideIcons.brain;
      case ClinicalSpecialtyDiscipline.neuroOtology:
        return LucideIcons.ear;
      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
        return LucideIcons.activity;
      case ClinicalSpecialtyDiscipline.ophthalmology:
        return LucideIcons.eye;
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
        return LucideIcons.wind;
      case ClinicalSpecialtyDiscipline.dental:
        return LucideIcons.smile;
      case ClinicalSpecialtyDiscipline.cardiology:
        return LucideIcons.heartPulse;
      case ClinicalSpecialtyDiscipline.vascularVein:
        return LucideIcons.gitFork;
      case ClinicalSpecialtyDiscipline.pulmonology:
        return LucideIcons.wind;
      case ClinicalSpecialtyDiscipline.endocrinology:
        return LucideIcons.dna;
      case ClinicalSpecialtyDiscipline.gastroenterology:
        return LucideIcons.utensils;
      case ClinicalSpecialtyDiscipline.urology:
        return LucideIcons.droplets;
      case ClinicalSpecialtyDiscipline.obgyn:
        return LucideIcons.baby;
      case ClinicalSpecialtyDiscipline.orthopedics:
        return LucideIcons.bone;
      case ClinicalSpecialtyDiscipline.physiotherapy:
        return LucideIcons.activity;
      case ClinicalSpecialtyDiscipline.podiatry:
        return LucideIcons.footprints;
      case ClinicalSpecialtyDiscipline.plasticSurgery:
        return LucideIcons.wand2;
      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return LucideIcons.syringe;
      case ClinicalSpecialtyDiscipline.dermatology:
        return LucideIcons.sparkles;
      case ClinicalSpecialtyDiscipline.painManagement:
        return LucideIcons.zap;
      case ClinicalSpecialtyDiscipline.acupuncture:
        return LucideIcons.compass;
      case ClinicalSpecialtyDiscipline.speechPathology:
        return LucideIcons.mic;
      case ClinicalSpecialtyDiscipline.veterinary:
        return LucideIcons.heartHandshake;
      case ClinicalSpecialtyDiscipline.diagnosticLab:
        return LucideIcons.flaskConical;
      case ClinicalSpecialtyDiscipline.mentalHealth:
        return LucideIcons.smilePlus;
      case ClinicalSpecialtyDiscipline.pediatrics:
        return LucideIcons.baby;
      case ClinicalSpecialtyDiscipline.general:
        return LucideIcons.stethoscope;
    }
  }

  Color _getDisciplineColor(ClinicalSpecialtyDiscipline disc) {
    switch (disc) {
      case ClinicalSpecialtyDiscipline.neurology:
        return const Color(0xFF8B5CF6);
      case ClinicalSpecialtyDiscipline.neuroOtology:
        return const Color(0xFF6366F1);
      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
        return const Color(0xFFA855F7);
      case ClinicalSpecialtyDiscipline.ophthalmology:
        return const Color(0xFF06B6D4);
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
        return const Color(0xFF14B8A6);
      case ClinicalSpecialtyDiscipline.dental:
        return const Color(0xFF0284C7);
      case ClinicalSpecialtyDiscipline.cardiology:
        return const Color(0xFFEF4444);
      case ClinicalSpecialtyDiscipline.vascularVein:
        return const Color(0xFFDC2626);
      case ClinicalSpecialtyDiscipline.pulmonology:
        return const Color(0xFF0EA5E9);
      case ClinicalSpecialtyDiscipline.endocrinology:
        return const Color(0xFFD97706);
      case ClinicalSpecialtyDiscipline.gastroenterology:
        return const Color(0xFFF59E0B);
      case ClinicalSpecialtyDiscipline.urology:
        return const Color(0xFF3B82F6);
      case ClinicalSpecialtyDiscipline.obgyn:
        return const Color(0xFFF43F5E);
      case ClinicalSpecialtyDiscipline.orthopedics:
        return const Color(0xFF0D9488);
      case ClinicalSpecialtyDiscipline.physiotherapy:
        return const Color(0xFF10B981);
      case ClinicalSpecialtyDiscipline.podiatry:
        return const Color(0xFF84CC16);
      case ClinicalSpecialtyDiscipline.plasticSurgery:
        return const Color(0xFFE11D48);
      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return const Color(0xFFF472B6);
      case ClinicalSpecialtyDiscipline.dermatology:
        return const Color(0xFFEC4899);
      case ClinicalSpecialtyDiscipline.painManagement:
        return const Color(0xFFF97316);
      case ClinicalSpecialtyDiscipline.acupuncture:
        return const Color(0xFF10B981);
      case ClinicalSpecialtyDiscipline.speechPathology:
        return const Color(0xFF38BDF8);
      case ClinicalSpecialtyDiscipline.veterinary:
        return const Color(0xFF10B981);
      case ClinicalSpecialtyDiscipline.diagnosticLab:
        return const Color(0xFF8B5CF6);
      case ClinicalSpecialtyDiscipline.mentalHealth:
        return const Color(0xFF06B6D4);
      case ClinicalSpecialtyDiscipline.pediatrics:
        return const Color(0xFFF59E0B);
      case ClinicalSpecialtyDiscipline.general:
        return const Color(0xFF6366F1);
    }
  }
}

/// 3D Vector Point with 3D Matrix/Euler Transformation and Perspective Projection
class _EyePoint3D {
  final double x;
  final double y;
  final double z;

  const _EyePoint3D(this.x, this.y, this.z);

  _EyePoint3D rotateY(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return _EyePoint3D(
      x * cosA + z * sinA,
      y,
      -x * sinA + z * cosA,
    );
  }

  _EyePoint3D rotateX(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return _EyePoint3D(
      x,
      y * cosA - z * sinA,
      y * sinA + z * cosA,
    );
  }

  _EyePoint3D transform(double yaw, double pitch) {
    // 3D rotation: Yaw around Y axis, then Pitch around X axis
    return rotateY(yaw).rotateX(pitch);
  }

  _EyePoint3D translate(_EyePoint3D offset) => _EyePoint3D(x + offset.x, y + offset.y, z + offset.z);
  _EyePoint3D operator +(_EyePoint3D other) => _EyePoint3D(x + other.x, y + other.y, z + other.z);
  _EyePoint3D operator -(_EyePoint3D other) => _EyePoint3D(x - other.x, y - other.y, z - other.z);
  _EyePoint3D operator *(double scalar) => _EyePoint3D(x * scalar, y * scalar, z * scalar);
}

/// Interactive 3D Eye Custom Painter with Real 3D Perspective Projection,
/// 3D Globe, 3D Sliced Layers with Physical Layer Separation Explosion,
/// and 3D Fundus with C:D Depth Calipers.
class _Eye3DPainter extends CustomPainter {
  final EyeAnatomicalLayer activeLayer;
  final bool isDark;
  final bool isRightEye;
  final double yaw;
  final double pitch;
  final int viewMode; // 0: 3D Globe, 1: 3D Sliced Layers, 2: 3D Fundus & Caliper Depth
  final double cdRatio;
  final double layerSeparation;

  const _Eye3DPainter({
    required this.activeLayer,
    required this.isDark,
    required this.isRightEye,
    required this.yaw,
    required this.pitch,
    required this.viewMode,
    required this.cdRatio,
    required this.layerSeparation,
  });

  // Perspective projection helper
  Offset _project(_EyePoint3D p, double cx, double cy, {double fov = 580.0}) {
    final scale = fov / (fov + p.z);
    return Offset(cx + p.x * scale, cy - p.y * scale);
  }

  double _scaleFactor(_EyePoint3D p, {double fov = 580.0}) {
    return fov / (fov + p.z);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.48;
    final cy = size.height * 0.50;
    final r = math.min(size.width, size.height) * 0.38;

    switch (viewMode) {
      case 0:
        _draw3DGlobe(canvas, cx, cy, r);
        break;
      case 1:
        _draw3DSlicedLayers(canvas, cx, cy, r);
        break;
      case 2:
      default:
        _draw3DFundus(canvas, cx, cy, r);
        break;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VIEW MODE 0: TRUE 3D GLOBE WITH ORBITING CORNEA & OPTIC NERVE
  // ═══════════════════════════════════════════════════════════════════════════
  void _draw3DGlobe(Canvas canvas, double cx, double cy, double r) {
    final isOD = isRightEye;
    final nasalSign = isOD ? -1.0 : 1.0;

    // 1. Dynamic 3D Spherical Sclera Shading
    // Light source positioned at upper-left-front in world space
    final lightWorld = const _EyePoint3D(-0.45, 0.55, 0.70);
    final lightTrans = lightWorld.transform(-yaw * 0.5, -pitch * 0.5);
    final scleraShader = RadialGradient(
      center: Alignment(lightTrans.x.clamp(-0.75, 0.75), (-lightTrans.y).clamp(-0.75, 0.75)),
      radius: 0.95,
      colors: isDark
          ? [const Color(0xFFF8FAFC), const Color(0xFF94A3B8), const Color(0xFF1E293B)]
          : [const Color(0xFFFFFFFF), const Color(0xFFE2E8F0), const Color(0xFF64748B)],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawCircle(Offset(cx, cy), r, Paint()..shader = scleraShader);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke,
    );

    // 2. Posterior Optic Nerve Trunk (Visible when eye turns around in 3D)
    final opticRootLocal = _EyePoint3D(nasalSign * r * 0.30, 0.08 * r, -r * 0.92);
    final opticExitLocal = _EyePoint3D(nasalSign * r * 0.55, 0.16 * r, -r * 1.55);
    final opticRootTrans = opticRootLocal.transform(yaw, pitch);
    final opticExitTrans = opticExitLocal.transform(yaw, pitch);

    if (opticRootTrans.z < opticExitTrans.z || opticRootTrans.z < 0) {
      // Optic nerve is partially or fully visible from posterior angle
      final pRoot = _project(opticRootTrans, cx, cy);
      final pExit = _project(opticExitTrans, cx, cy);
      final nerveWidth = 18.0 * _scaleFactor(opticExitTrans);

      final nervePaint = Paint()
        ..color = const Color(0xFFD97706)
        ..strokeWidth = nerveWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(pRoot, pExit, nervePaint);

      // Central retinal artery & vein in nerve sheath
      canvas.drawLine(pRoot, pExit, Paint()..color = Colors.redAccent..strokeWidth = 2.5);
      canvas.drawLine(Offset(pRoot.dx + 2, pRoot.dy + 2), Offset(pExit.dx + 2, pExit.dy + 2), Paint()..color = Colors.blueAccent..strokeWidth = 2.0);
    }

    // 3. Episcleral Vascularization (Rotates with the globe in 3D)
    final vesselPaint = Paint()
      ..color = Colors.red.withValues(alpha: isDark ? 0.35 : 0.25)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi / 4);
      final v1 = _EyePoint3D(math.cos(angle) * r * 0.65, math.sin(angle) * r * 0.65, r * 0.35).transform(yaw, pitch);
      final v2 = _EyePoint3D(math.cos(angle + 0.18) * r * 0.82, math.sin(angle + 0.18) * r * 0.82, r * 0.25).transform(yaw, pitch);
      final v3 = _EyePoint3D(math.cos(angle) * r * 0.96, math.sin(angle) * r * 0.96, r * 0.10).transform(yaw, pitch);

      if (v1.z > -r * 0.3) {
        final p1 = _project(v1, cx, cy);
        final p2 = _project(v2, cx, cy);
        final p3 = _project(v3, cx, cy);
        final vp = Path()..moveTo(p1.dx, p1.dy)..quadraticBezierTo(p2.dx, p2.dy, p3.dx, p3.dy);
        canvas.drawPath(vp, vesselPaint);
      }
    }

    // 4. 4 Rectus Muscle Tendon Insertions Orbiting in 3D
    final muscleTendons = [
      _EyePoint3D(0, r * 0.96, -r * 0.10), // Superior Rectus
      _EyePoint3D(0, -r * 0.96, -r * 0.10), // Inferior Rectus
      _EyePoint3D(nasalSign * r * 0.96, 0, -r * 0.10), // Medial Rectus
      _EyePoint3D(-nasalSign * r * 0.96, 0, -r * 0.10), // Lateral Rectus
    ];

    final tendonPaint = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.75)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    for (final tendon in muscleTendons) {
      final tTrans = tendon.transform(yaw, pitch);
      if (tTrans.z > -r * 0.4) {
        final pt = _project(tTrans, cx, cy);
        canvas.drawCircle(pt, 5.0, tendonPaint);
      }
    }

    // 5. 3D Cornea Dome Protrusion & Limbus
    final corneaCenterLocal = _EyePoint3D(0, 0, r * 0.92);
    final corneaApexLocal = _EyePoint3D(0, 0, r * 1.25);
    final corneaCenterTrans = corneaCenterLocal.transform(yaw, pitch);
    final corneaApexTrans = corneaApexLocal.transform(yaw, pitch);

    final corneaFacing = corneaCenterTrans.z > -r * 0.35;

    if (corneaFacing) {
      final pCorneaCenter = _project(corneaCenterTrans, cx, cy);
      final pCorneaApex = _project(corneaApexTrans, cx, cy);
      final corneaScale = _scaleFactor(corneaCenterTrans);
      final corneaR = r * 0.48 * corneaScale;

      // Corneal Limbus 3D Ellipse
      final limbusPath = Path();
      const numLimbusPoints = 28;
      for (int i = 0; i < numLimbusPoints; i++) {
        final t = i * 2 * math.pi / numLimbusPoints;
        final lp = _EyePoint3D(math.cos(t) * r * 0.48, math.sin(t) * r * 0.48, r * 0.90).transform(yaw, pitch);
        final sc = _project(lp, cx, cy);
        if (i == 0) {
          limbusPath.moveTo(sc.dx, sc.dy);
        } else {
          limbusPath.lineTo(sc.dx, sc.dy);
        }
      }
      limbusPath.close();

      // Transparent Cornea Glass Dome Fill
      final corneaShader = RadialGradient(
        center: Alignment(
          ((pCorneaApex.dx - pCorneaCenter.dx) / (corneaR + 1e-3)).clamp(-0.6, 0.6),
          ((pCorneaApex.dy - pCorneaCenter.dy) / (corneaR + 1e-3)).clamp(-0.6, 0.6),
        ),
        radius: 0.9,
        colors: [
          const Color(0xFF38BDF8).withValues(alpha: 0.48),
          const Color(0xFF0284C7).withValues(alpha: 0.28),
          const Color(0xFF0369A1).withValues(alpha: 0.12),
        ],
      ).createShader(Rect.fromCircle(center: pCorneaCenter, radius: corneaR));

      canvas.drawPath(limbusPath, Paint()..shader = corneaShader);
      canvas.drawPath(
        limbusPath,
        Paint()
          ..color = const Color(0xFF0284C7).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );

      // 6. 3D Iris with 3D Foreshortened Perspective
      final irisCenterLocal = _EyePoint3D(0, 0, r * 0.85);
      final irisCenterTrans = irisCenterLocal.transform(yaw, pitch);
      final pIrisCenter = _project(irisCenterTrans, cx, cy);
      final irisScale = _scaleFactor(irisCenterTrans);
      final irisR = corneaR * 0.88;

      final irisPath = Path();
      final pupilPath = Path();
      for (int i = 0; i < numLimbusPoints; i++) {
        final t = i * 2 * math.pi / numLimbusPoints;
        final ip = _EyePoint3D(math.cos(t) * r * 0.42, math.sin(t) * r * 0.42, r * 0.85).transform(yaw, pitch);
        final pp = _EyePoint3D(math.cos(t) * r * 0.15, math.sin(t) * r * 0.15, r * 0.85).transform(yaw, pitch);
        final p1 = _project(ip, cx, cy);
        final p2 = _project(pp, cx, cy);
        if (i == 0) {
          irisPath.moveTo(p1.dx, p1.dy);
          pupilPath.moveTo(p2.dx, p2.dy);
        } else {
          irisPath.lineTo(p1.dx, p1.dy);
          pupilPath.lineTo(p2.dx, p2.dy);
        }
      }
      irisPath.close();
      pupilPath.close();

      final irisShader = RadialGradient(
        colors: const [Color(0xFF0284C7), Color(0xFF0369A1), Color(0xFF075985)],
        stops: const [0.2, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: pIrisCenter, radius: irisR));

      canvas.drawPath(irisPath, Paint()..shader = irisShader);

      // Radial Iris Striae in 3D
      final striaePaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.55)
        ..strokeWidth = 1.0;
      for (int i = 0; i < 20; i++) {
        final a = i * math.pi / 10;
        final pIn = _project(_EyePoint3D(math.cos(a) * r * 0.16, math.sin(a) * r * 0.16, r * 0.85).transform(yaw, pitch), cx, cy);
        final pOut = _project(_EyePoint3D(math.cos(a) * r * 0.40, math.sin(a) * r * 0.40, r * 0.85).transform(yaw, pitch), cx, cy);
        canvas.drawLine(pIn, pOut, striaePaint);
      }

      // Pupil (Central Black Aperture in 3D)
      canvas.drawPath(pupilPath, Paint()..color = const Color(0xFF020617));
      canvas.drawPath(
        pupilPath,
        Paint()
          ..color = const Color(0xFF0EA5E9).withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4,
      );

      // Specular Highlight on Cornea (Purkinje Image)
      final specLocal = _EyePoint3D(-r * 0.18, r * 0.18, r * 1.15).transform(yaw, pitch);
      final pSpec = _project(specLocal, cx, cy);
      canvas.drawOval(
        Rect.fromCenter(center: pSpec, width: 14 * irisScale, height: 9 * irisScale),
        Paint()..color = Colors.white.withValues(alpha: 0.8),
      );
    }

    // Anatomical Orientation Badges
    final nLabel = AppLanguage.isArabic ? 'أنفي (Medial)' : 'Nasal (Medial)';
    final tLabel = AppLanguage.isArabic ? 'صدغي (Lateral)' : 'Temporal (Lateral)';
    final nasalOnLeft = isRightEye;
    _drawText(
      canvas,
      nasalOnLeft ? nLabel : tLabel,
      Offset(cx - r - 8, cy + r + 12),
      isDark ? Colors.white60 : Colors.black54,
      fontSize: 9.5,
      alignRight: true,
    );
    _drawText(
      canvas,
      nasalOnLeft ? tLabel : nLabel,
      Offset(cx + r + 8, cy + r + 12),
      isDark ? Colors.white60 : Colors.black54,
      fontSize: 9.5,
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VIEW MODE 1: TRUE 3D SLICED LAYERS WITH 3D EXPLOSION & ROTATION
  // ═══════════════════════════════════════════════════════════════════════════
  void _draw3DSlicedLayers(Canvas canvas, double cx, double cy, double r) {
    final isOD = isRightEye;
    final nasalSign = isOD ? -1.0 : 1.0;

    // 1. 3D Separation Vector in Eye Space
    // Displaces layers along an anatomical axis so all 4 layers float visibly
    final sepUnitX = nasalSign * 0.82;
    const sepUnitY = 0.28;
    const sepUnitZ = 0.50;
    final sepLen = math.sqrt(sepUnitX * sepUnitX + sepUnitY * sepUnitY + sepUnitZ * sepUnitZ);
    final sepDir = _EyePoint3D(sepUnitX / sepLen, sepUnitY / sepLen, sepUnitZ / sepLen);

    final spreadDist = layerSeparation * r * 1.15;

    // 4 Distinct Anatomical Layers:
    // 0: Outer Fibrous (Sclera & Cornea)
    // 1: Middle Vascular (Choroid, Ciliary Body & Iris)
    // 2: Inner Sensory (Retina & Ora Serrata)
    // 3: Optical Media (Crystalline Lens & Vitreous Body)
    final layerOffsetsLocal = [
      sepDir * (-1.5 * spreadDist),
      sepDir * (-0.5 * spreadDist),
      sepDir * (0.5 * spreadDist),
      sepDir * (1.5 * spreadDist),
    ];

    // Transform each layer's 3D center by Yaw and Pitch
    final transformedCenters = <_EyePoint3D>[];
    final screenCenters = <Offset>[];
    final scaleFactors = <double>[];

    for (int i = 0; i < 4; i++) {
      final tc = layerOffsetsLocal[i].transform(yaw, pitch);
      transformedCenters.add(tc);
      screenCenters.add(_project(tc, cx, cy));
      scaleFactors.add(_scaleFactor(tc));
    }

    // 2. Draw 3D Guide Rail connecting exploded layer centers
    if (layerSeparation > 0.05) {
      final railPaint = Paint()
        ..color = const Color(0xFF06B6D4).withValues(alpha: 0.45)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;

      final railPath = Path();
      railPath.moveTo(screenCenters[0].dx, screenCenters[0].dy);
      for (int i = 1; i < 4; i++) {
        railPath.lineTo(screenCenters[i].dx, screenCenters[i].dy);
      }
      canvas.drawPath(railPath, railPaint);

      // Draw subtle glowing coordinate nodes at each layer center
      for (int i = 0; i < 4; i++) {
        canvas.drawCircle(screenCenters[i], 3.5, Paint()..color = const Color(0xFF38BDF8));
      }
    }

    // 3. Back-to-Front Z-Sorting (Painter's Algorithm)
    // Ensures farthest layers in 3D are rendered first, closest rendered last
    final sortedIndices = [0, 1, 2, 3];
    sortedIndices.sort((a, b) => transformedCenters[a].z.compareTo(transformedCenters[b].z));

    // Light source in eye coordinates
    final lightWorld = const _EyePoint3D(-0.4, 0.6, 0.7);
    final lightTrans = lightWorld.transform(-yaw * 0.4, -pitch * 0.4);

    // 4. Render each layer in sorted 3D depth order
    for (final layerIdx in sortedIndices) {
      final lCenter = screenCenters[layerIdx];
      final lScale = scaleFactors[layerIdx];
      final lTrans = transformedCenters[layerIdx];
      final lOffsetLocal = layerOffsetsLocal[layerIdx];

      switch (layerIdx) {
        case 0:
          _drawLayerFibrous(canvas, cx, cy, r, lCenter, lScale, lTrans, lOffsetLocal, lightTrans, isOD);
          break;
        case 1:
          _drawLayerUvea(canvas, cx, cy, r, lCenter, lScale, lTrans, lOffsetLocal, lightTrans, isOD);
          break;
        case 2:
          _drawLayerRetina(canvas, cx, cy, r, lCenter, lScale, lTrans, lOffsetLocal, lightTrans, isOD);
          break;
        case 3:
          _drawLayerMedia(canvas, cx, cy, r, lCenter, lScale, lTrans, lOffsetLocal, lightTrans, isOD);
          break;
      }
    }

    // 5. 3D Floating Layer Identification Callout Tags (when exploded)
    if (layerSeparation > 0.22) {
      _drawLayerFloatingBadge(canvas, screenCenters[0], AppLanguage.isArabic ? '1. الغلاف الصلب (الصلبة والقرنية)' : '1. Fibrous (Sclera 1.0mm)', const Color(0xFF94A3B8));
      _drawLayerFloatingBadge(canvas, screenCenters[1], AppLanguage.isArabic ? '2. الغلاف الوعائي (المشيمية والقزحية)' : '2. Uvea (Choroid 0.2mm)', const Color(0xFFF43F5E));
      _drawLayerFloatingBadge(canvas, screenCenters[2], AppLanguage.isArabic ? '3. الغلاف العصبي (الشبكية)' : '3. Retina (Sensory 0.2mm)', const Color(0xFFF97316));
      _drawLayerFloatingBadge(canvas, screenCenters[3], AppLanguage.isArabic ? '4. الوسط البصري (العدسة والزجاجي)' : '4. Media (Lens & Vitreous)', const Color(0xFF38BDF8));
    }

    // 6. Anatomical Orientation Badges
    final nLabel = AppLanguage.isArabic ? 'أنفي (Medial)' : 'Nasal (Medial)';
    final tLabel = AppLanguage.isArabic ? 'صدغي (Lateral)' : 'Temporal (Lateral)';
    final nasalX = isOD ? (cx - r - 16) : (cx + r + 16);
    final temporalX = isOD ? (cx + r + 16) : (cx - r - 16);

    _drawText(
      canvas,
      isOD
          ? '${AppLanguage.tr('Right Eye (OD)', 'OD (اليمنى)')}: $nLabel'
          : '${AppLanguage.tr('Left Eye (OS)', 'OS (اليسرى)')}: $nLabel',
      Offset(nasalX, cy + r + 12),
      isDark ? Colors.white70 : Colors.black87,
      fontSize: 9.5,
      isBold: true,
      alignRight: isOD,
    );
    _drawText(
      canvas,
      tLabel,
      Offset(temporalX, cy + r + 12),
      isDark ? Colors.white60 : Colors.black54,
      fontSize: 9.5,
      alignRight: !isOD,
    );
  }

  // ── LAYER 0: SCLERA & CORNEA (OUTER FIBROUS TUNIC) ─────────────────────────
  void _drawLayerFibrous(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Offset center,
    double scale,
    _EyePoint3D transCenter,
    _EyePoint3D offsetLocal,
    _EyePoint3D lightTrans,
    bool isOD,
  ) {
    final isSelected = activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.fibrous;
    final alphaMul = isSelected ? 1.0 : (activeLayer == EyeAnatomicalLayer.all ? 0.9 : 0.22);
    final layerR = r * 1.0 * scale;

    // 1. Outer Convex Scleral Hemispherical Bowl
    final scleraShader = RadialGradient(
      center: Alignment(lightTrans.x.clamp(-0.7, 0.7), (-lightTrans.y).clamp(-0.7, 0.7)),
      radius: 0.95,
      colors: isDark
          ? [
              const Color(0xFFF1F5F9).withValues(alpha: alphaMul),
              const Color(0xFF94A3B8).withValues(alpha: alphaMul),
              const Color(0xFF334155).withValues(alpha: alphaMul),
            ]
          : [
              const Color(0xFFFFFFFF).withValues(alpha: alphaMul),
              const Color(0xFFE2E8F0).withValues(alpha: alphaMul),
              const Color(0xFF94A3B8).withValues(alpha: alphaMul),
            ],
      stops: const [0.0, 0.65, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: layerR));

    canvas.drawCircle(center, layerR, Paint()..shader = scleraShader);

    // 2. 3D Cutaway Rim Ellipse (1.0 mm Anatomical Scleral Wall Thickness)
    final rimPath = Path();
    const numPoints = 32;
    for (int i = 0; i < numPoints; i++) {
      final t = i * 2 * math.pi / numPoints;
      // Cut plane circle in local space, offset by layer position
      final pLocal = _EyePoint3D(0, math.cos(t) * r * 1.0, math.sin(t) * r * 1.0) + offsetLocal;
      final pt = _project(pLocal.transform(yaw, pitch), cx, cy);
      if (i == 0) {
        rimPath.moveTo(pt.dx, pt.dy);
      } else {
        rimPath.lineTo(pt.dx, pt.dy);
      }
    }
    rimPath.close();

    final rimPaint = Paint()
      ..color = (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF64748B)).withValues(alpha: alphaMul)
      ..strokeWidth = 6.0 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawPath(rimPath, rimPaint);

    final bevelPaint = Paint()
      ..color = Colors.white.withValues(alpha: (isDark ? 0.4 : 0.7) * alphaMul)
      ..strokeWidth = 1.8 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawPath(rimPath, bevelPaint);

    // 3. Protruding 3D Cornea Dome on Sclera Layer
    final corneaApexLocal = offsetLocal + const _EyePoint3D(0, 0, 1.22) * r;
    final corneaApexTrans = corneaApexLocal.transform(yaw, pitch);
    final pCorneaApex = _project(corneaApexTrans, cx, cy);

    final corneaP1Local = offsetLocal + const _EyePoint3D(0, 0.50, 0.90) * r;
    final corneaP2Local = offsetLocal + const _EyePoint3D(0, -0.50, 0.90) * r;
    final pC1 = _project(corneaP1Local.transform(yaw, pitch), cx, cy);
    final pC2 = _project(corneaP2Local.transform(yaw, pitch), cx, cy);

    final corneaPath = Path()
      ..moveTo(pC1.dx, pC1.dy)
      ..quadraticBezierTo(pCorneaApex.dx, pCorneaApex.dy, pC2.dx, pC2.dy);

    final corneaStroke = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: alphaMul * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.5 * scale
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(corneaPath, corneaStroke);

    // 4. Highlight glow when active
    if (activeLayer == EyeAnatomicalLayer.fibrous) {
      _drawActiveHalo(canvas, center, layerR + 4, const Color(0xFF38BDF8));
    }
  }

  // ── LAYER 1: CHOROID, IRIS & CILIARY BODY (MIDDLE VASCULAR UVEA) ───────────
  void _drawLayerUvea(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Offset center,
    double scale,
    _EyePoint3D transCenter,
    _EyePoint3D offsetLocal,
    _EyePoint3D lightTrans,
    bool isOD,
  ) {
    final isSelected = activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.uvea;
    final alphaMul = isSelected ? 1.0 : (activeLayer == EyeAnatomicalLayer.all ? 0.9 : 0.20);
    final layerR = r * 0.91 * scale;

    // 1. Uveal Vascular Mantle Bowl
    final choroidShader = RadialGradient(
      center: Alignment(lightTrans.x.clamp(-0.6, 0.6), (-lightTrans.y).clamp(-0.6, 0.6)),
      colors: [
        const Color(0xFF9D174D).withValues(alpha: alphaMul),
        const Color(0xFF4C0519).withValues(alpha: alphaMul),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: layerR));

    canvas.drawCircle(center, layerR, Paint()..shader = choroidShader);

    // 2. 3D Cutaway Rim of Choroid (0.2 mm thickness)
    final rimPath = Path();
    const numPoints = 32;
    for (int i = 0; i < numPoints; i++) {
      final t = i * 2 * math.pi / numPoints;
      final pLocal = _EyePoint3D(0, math.cos(t) * r * 0.91, math.sin(t) * r * 0.91) + offsetLocal;
      final pt = _project(pLocal.transform(yaw, pitch), cx, cy);
      if (i == 0) {
        rimPath.moveTo(pt.dx, pt.dy);
      } else {
        rimPath.lineTo(pt.dx, pt.dy);
      }
    }
    rimPath.close();

    final rimPaint = Paint()
      ..color = const Color(0xFFBE123C).withValues(alpha: alphaMul)
      ..strokeWidth = 4.5 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawPath(rimPath, rimPaint);

    // 3. 3D Choriocapillaris Micro-vascular Network
    if (isSelected) {
      final chorioVesselPaint = Paint()
        ..color = const Color(0xFFF43F5E).withValues(alpha: 0.45 * alphaMul)
        ..strokeWidth = 1.2 * scale
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 16; i++) {
        final a = (i * math.pi / 8);
        final p1 = _project((_EyePoint3D(0, math.cos(a) * r * 0.88, math.sin(a) * r * 0.88) + offsetLocal).transform(yaw, pitch), cx, cy);
        final p2 = _project((_EyePoint3D(0, math.cos(a) * r * 0.93, math.sin(a) * r * 0.93) + offsetLocal).transform(yaw, pitch), cx, cy);
        canvas.drawLine(p1, p2, chorioVesselPaint);
      }
    }

    // 4. Anterior 3D Iris Ring & Ciliary Body
    final irisPath = Path();
    final pupilPath = Path();
    for (int i = 0; i < 24; i++) {
      final t = i * 2 * math.pi / 24;
      final ip = _EyePoint3D(math.cos(t) * r * 0.45, math.sin(t) * r * 0.45, 0.75 * r) + offsetLocal;
      final pp = _EyePoint3D(math.cos(t) * r * 0.16, math.sin(t) * r * 0.16, 0.75 * r) + offsetLocal;
      final p1 = _project(ip.transform(yaw, pitch), cx, cy);
      final p2 = _project(pp.transform(yaw, pitch), cx, cy);
      if (i == 0) {
        irisPath.moveTo(p1.dx, p1.dy);
        pupilPath.moveTo(p2.dx, p2.dy);
      } else {
        irisPath.lineTo(p1.dx, p1.dy);
        pupilPath.lineTo(p2.dx, p2.dy);
      }
    }
    irisPath.close();
    pupilPath.close();

    canvas.drawPath(
      irisPath,
      Paint()
        ..color = const Color(0xFF0284C7).withValues(alpha: alphaMul * 0.9)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(pupilPath, Paint()..color = const Color(0xFF020617));

    // Ciliary Processes (Corrugated Ring)
    canvas.drawPath(
      irisPath,
      Paint()
        ..color = const Color(0xFF0369A1).withValues(alpha: alphaMul)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5 * scale,
    );

    if (activeLayer == EyeAnatomicalLayer.uvea) {
      _drawActiveHalo(canvas, center, layerR + 4, const Color(0xFFF43F5E));
    }
  }

  // ── LAYER 2: SENSORY RETINA (INNER NEURAL TUNIC) ───────────────────────────
  void _drawLayerRetina(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Offset center,
    double scale,
    _EyePoint3D transCenter,
    _EyePoint3D offsetLocal,
    _EyePoint3D lightTrans,
    bool isOD,
  ) {
    final isSelected = activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.retina;
    final alphaMul = isSelected ? 1.0 : (activeLayer == EyeAnatomicalLayer.all ? 0.9 : 0.20);
    final layerR = r * 0.82 * scale;
    final nasalSign = isOD ? -1.0 : 1.0;

    // 1. Sensory Retina Concave Hemispherical Bowl
    final retinaShader = RadialGradient(
      center: Alignment(lightTrans.x.clamp(-0.5, 0.5), (-lightTrans.y).clamp(-0.5, 0.5)),
      colors: [
        const Color(0xFFFB923C).withValues(alpha: alphaMul),
        const Color(0xFFC2410C).withValues(alpha: alphaMul),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: layerR));

    canvas.drawCircle(center, layerR, Paint()..shader = retinaShader);

    // 2. 3D Cutaway Rim & Scalloped Ora Serrata
    final rimPath = Path();
    const numPoints = 32;
    for (int i = 0; i < numPoints; i++) {
      final t = i * 2 * math.pi / numPoints;
      final pLocal = _EyePoint3D(0, math.cos(t) * r * 0.82, math.sin(t) * r * 0.82) + offsetLocal;
      final pt = _project(pLocal.transform(yaw, pitch), cx, cy);
      if (i == 0) {
        rimPath.moveTo(pt.dx, pt.dy);
      } else {
        rimPath.lineTo(pt.dx, pt.dy);
      }
    }
    rimPath.close();

    final rimPaint = Paint()
      ..color = const Color(0xFFEA580C).withValues(alpha: alphaMul)
      ..strokeWidth = 3.5 * scale
      ..style = PaintingStyle.stroke;
    canvas.drawPath(rimPath, rimPaint);

    // Ora Serrata Scalloped Dentate Border
    if (isSelected) {
      final oraPaint = Paint()..color = const Color(0xFFC2410C).withValues(alpha: alphaMul)..style = PaintingStyle.fill;
      for (int i = 0; i < 16; i++) {
        final t = i * 2 * math.pi / 16;
        final pOra = _project((_EyePoint3D(0, math.cos(t) * r * 0.82, math.sin(t) * r * 0.82) + offsetLocal).transform(yaw, pitch), cx, cy);
        canvas.drawCircle(pOra, 2.5 * scale, oraPaint);
      }
    }

    // 3. 3D Optic Disc & Cup Excavation on Posterior Retina Wall
    final opticLocal = offsetLocal + _EyePoint3D(nasalSign * r * 0.28, 0.06 * r, -r * 0.72);
    final pOptic = _project(opticLocal.transform(yaw, pitch), cx, cy);
    final discR = 10.0 * scale;

    final discPaint = Paint()..color = const Color(0xFFFBBF24).withValues(alpha: alphaMul);
    canvas.drawCircle(pOptic, discR, discPaint);

    // Dynamic cup excavation driven by cdRatio
    final cupR = (discR * cdRatio.clamp(0.1, 0.95));
    final cupPaint = Paint()..color = (cdRatio > 0.5 ? const Color(0xFFFEF08A) : Colors.white).withValues(alpha: alphaMul);
    canvas.drawCircle(pOptic, cupR, cupPaint);

    // 4. Retinal Vascular Tree Arches
    if (isSelected) {
      final arcadePaint = Paint()
        ..color = const Color(0xFFEF4444).withValues(alpha: 0.85 * alphaMul)
        ..strokeWidth = 1.8 * scale
        ..style = PaintingStyle.stroke;

      final maculaLocal = offsetLocal + _EyePoint3D(-nasalSign * r * 0.22, 0.0, -r * 0.74);
      final pMacula = _project(maculaLocal.transform(yaw, pitch), cx, cy);

      // Superior & Inferior Temporal Arcs
      final arc1 = Path()
        ..moveTo(pOptic.dx, pOptic.dy)
        ..quadraticBezierTo(pOptic.dx - nasalSign * 25 * scale, pOptic.dy - 35 * scale, pMacula.dx, pMacula.dy - 20 * scale);
      final arc2 = Path()
        ..moveTo(pOptic.dx, pOptic.dy)
        ..quadraticBezierTo(pOptic.dx - nasalSign * 25 * scale, pOptic.dy + 35 * scale, pMacula.dx, pMacula.dy + 20 * scale);

      canvas.drawPath(arc1, arcadePaint);
      canvas.drawPath(arc2, arcadePaint);

      // Macula & Fovea Centralis
      canvas.drawCircle(pMacula, 8.0 * scale, Paint()..color = const Color(0xFF78350F).withValues(alpha: 0.7 * alphaMul));
      canvas.drawCircle(pMacula, 2.2 * scale, Paint()..color = const Color(0xFFFDE047).withValues(alpha: alphaMul));
    }

    if (activeLayer == EyeAnatomicalLayer.retina) {
      _drawActiveHalo(canvas, center, layerR + 4, const Color(0xFFF97316));
    }
  }

  // ── LAYER 3: OPTICAL MEDIA (LENS & VITREOUS BODY) ─────────────────────────
  void _drawLayerMedia(
    Canvas canvas,
    double cx,
    double cy,
    double r,
    Offset center,
    double scale,
    _EyePoint3D transCenter,
    _EyePoint3D offsetLocal,
    _EyePoint3D lightTrans,
    bool isOD,
  ) {
    final isSelected = activeLayer == EyeAnatomicalLayer.all || activeLayer == EyeAnatomicalLayer.media;
    final alphaMul = isSelected ? 1.0 : (activeLayer == EyeAnatomicalLayer.all ? 0.9 : 0.20);
    final layerR = r * 0.72 * scale;
    final nasalSign = isOD ? -1.0 : 1.0;

    // 1. Transparent Prismatic Vitreous Chamber Core
    final vitreousShader = RadialGradient(
      center: Alignment(lightTrans.x.clamp(-0.5, 0.5), (-lightTrans.y).clamp(-0.5, 0.5)),
      radius: 0.88,
      colors: [
        const Color(0xFF38BDF8).withValues(alpha: (isDark ? 0.15 : 0.22) * alphaMul),
        const Color(0xFF0284C7).withValues(alpha: (isDark ? 0.35 : 0.45) * alphaMul),
        const Color(0xFF0C4A6E).withValues(alpha: (isDark ? 0.55 : 0.65) * alphaMul),
      ],
      stops: const [0.0, 0.6, 1.0],
    ).createShader(Rect.fromCircle(center: center, radius: layerR));

    canvas.drawCircle(center, layerR, Paint()..shader = vitreousShader);
    canvas.drawCircle(
      center,
      layerR,
      Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6 * alphaMul)
        ..strokeWidth = 2.0 * scale
        ..style = PaintingStyle.stroke,
    );

    // 2. Cloquet's Hyaloid Canal running through center
    if (isSelected) {
      final cloquetStart = _project((offsetLocal + _EyePoint3D(nasalSign * r * 0.25, 0.05 * r, -r * 0.65)).transform(yaw, pitch), cx, cy);
      final cloquetEnd = _project((offsetLocal + const _EyePoint3D(0, 0, 0.45) * r).transform(yaw, pitch), cx, cy);
      canvas.drawLine(
        cloquetStart,
        cloquetEnd,
        Paint()
          ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.5 * alphaMul)
          ..strokeWidth = 2.2 * scale
          ..style = PaintingStyle.stroke,
      );
    }

    // 3. 3D Biconvex Crystalline Lens & Zonules of Zinn
    final lensLocal = offsetLocal + const _EyePoint3D(0, 0, 0.48) * r;
    final pLens = _project(lensLocal.transform(yaw, pitch), cx, cy);
    final cosYaw = math.cos(yaw);
    final cosPitch = math.cos(pitch);

    final lensWidth = (28.0 * (0.45 + 0.55 * cosYaw.abs()) * scale).clamp(14.0, 36.0);
    final lensHeight = r * 0.55 * (0.6 + 0.4 * cosPitch.abs()) * scale;

    final lensShader = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      colors: [
        const Color(0xFFE0F2FE).withValues(alpha: 0.95 * alphaMul),
        const Color(0xFF7DD3FC).withValues(alpha: 0.85 * alphaMul),
        const Color(0xFF0284C7).withValues(alpha: 0.50 * alphaMul),
      ],
      stops: const [0.0, 0.7, 1.0],
    ).createShader(Rect.fromCenter(center: pLens, width: lensWidth, height: lensHeight));

    canvas.drawOval(Rect.fromCenter(center: pLens, width: lensWidth, height: lensHeight), Paint()..shader = lensShader);
    canvas.drawOval(
      Rect.fromCenter(center: pLens, width: lensWidth, height: lensHeight),
      Paint()
        ..color = const Color(0xFF0284C7).withValues(alpha: 0.85 * alphaMul)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2 * scale,
    );

    // Zonules of Zinn (Delicate Suspensory Fibers)
    if (isSelected) {
      final zonulePaint = Paint()
        ..color = const Color(0xFF38BDF8).withValues(alpha: 0.65 * alphaMul)
        ..strokeWidth = 1.2 * scale;
      for (int i = -3; i <= 3; i++) {
        final topZone = Offset(pLens.dx + i * 3.5 * scale, pLens.dy - lensHeight * 0.48);
        final topAnchor = Offset(pLens.dx + i * 7.0 * scale, pLens.dy - layerR * 0.85);
        final btmZone = Offset(pLens.dx + i * 3.5 * scale, pLens.dy + lensHeight * 0.48);
        final btmAnchor = Offset(pLens.dx + i * 7.0 * scale, pLens.dy + layerR * 0.85);
        canvas.drawLine(topZone, topAnchor, zonulePaint);
        canvas.drawLine(btmZone, btmAnchor, zonulePaint);
      }
    }

    if (activeLayer == EyeAnatomicalLayer.media) {
      _drawActiveHalo(canvas, center, layerR + 4, const Color(0xFF38BDF8));
    }
  }

  // Floating HUD Badge for each exploded layer
  void _drawLayerFloatingBadge(Canvas canvas, Offset pos, String text, Color accentColor) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 8.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(pos.dx, pos.dy - 22), width: tp.width + 12, height: tp.height + 6),
      const Radius.circular(6),
    );

    canvas.drawRRect(
      badgeRect,
      Paint()..color = Colors.black.withValues(alpha: 0.75),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()
        ..color = accentColor.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - 22 - tp.height / 2));
  }

  // Active layer spotlight halo
  void _drawActiveHalo(Canvas canvas, Offset center, double radius, Color glowColor) {
    final haloPaint = Paint()
      ..color = glowColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;
    canvas.drawCircle(center, radius, haloPaint);
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // VIEW MODE 2: 3D FUNDUS & CALIPER DEPTH (PARALLAX ENHANCED)
  // ═══════════════════════════════════════════════════════════════════════════
  void _draw3DFundus(Canvas canvas, double cx, double cy, double r) {
    final isOD = isRightEye;
    final parallaxX = math.sin(yaw) * r * 0.25;
    final parallaxY = math.sin(pitch) * r * 0.25;

    // 1. 3D Concave Retinal Bowl Fundus View
    final fundusShader = RadialGradient(
      center: Alignment((parallaxX / r).clamp(-0.4, 0.4), (parallaxY / r).clamp(-0.4, 0.4)),
      radius: 0.95,
      colors: isDark
          ? [const Color(0xFF9A3412), const Color(0xFF7C2D12), const Color(0xFF431407)]
          : [const Color(0xFFEA580C), const Color(0xFFC2410C), const Color(0xFF7C2D12)],
      stops: const [0.0, 0.7, 1.0],
    ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: r));

    canvas.drawCircle(Offset(cx, cy), r, Paint()..shader = fundusShader);
    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = const Color(0xFFF97316)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke,
    );

    // 2. Disc & Macula positions based on OD vs OS with 3D Parallax
    final discBaseX = isOD ? (cx - r * 0.36) : (cx + r * 0.36);
    final discX = discBaseX + parallaxX * 0.45;
    final discY = cy + parallaxY * 0.45;

    final maculaBaseX = isOD ? (cx + r * 0.28) : (cx - r * 0.28);
    final maculaX = maculaBaseX + parallaxX * 0.65;
    final maculaY = cy + parallaxY * 0.65;

    final discR = r * 0.26;

    // 3. Retinal Vascular Arcades (Arching from disc toward macula)
    final arteryPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final veinPaint = Paint()
      ..color = const Color(0xFF991B1B)
      ..strokeWidth = 4.2
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final sDir = isOD ? 1.0 : -1.0;
    final supArc = Path()
      ..moveTo(discX, discY)
      ..quadraticBezierTo(discX + sDir * r * 0.25, discY - r * 0.65, maculaX + sDir * r * 0.2, maculaY - r * 0.45);
    final infArc = Path()
      ..moveTo(discX, discY)
      ..quadraticBezierTo(discX + sDir * r * 0.25, discY + r * 0.65, maculaX + sDir * r * 0.2, maculaY + r * 0.45);

    canvas.drawPath(supArc, veinPaint);
    canvas.drawPath(supArc, arteryPaint);
    canvas.drawPath(infArc, veinPaint);
    canvas.drawPath(infArc, arteryPaint);

    // Nasal Branches (Radiating away from macula)
    final nDir = -sDir;
    final nSupArc = Path()
      ..moveTo(discX, discY)
      ..quadraticBezierTo(discX + nDir * r * 0.18, discY - r * 0.45, discX + nDir * r * 0.35, discY - r * 0.55);
    final nInfArc = Path()
      ..moveTo(discX, discY)
      ..quadraticBezierTo(discX + nDir * r * 0.18, discY + r * 0.45, discX + nDir * r * 0.35, discY + r * 0.55);
    canvas.drawPath(nSupArc, arteryPaint);
    canvas.drawPath(nInfArc, arteryPaint);

    // 4. Macula & Fovea Centralis (Dark circular luteal pigment)
    canvas.drawCircle(Offset(maculaX, maculaY), r * 0.20, Paint()..color = const Color(0xFF451A03).withValues(alpha: 0.7));
    canvas.drawCircle(Offset(maculaX, maculaY), 3.5, Paint()..color = const Color(0xFFFDE047));

    // 5. Optic Disc (حليمة العصب البصري)
    final discShader = RadialGradient(
      colors: const [Color(0xFFFED7AA), Color(0xFFFDBA74), Color(0xFFFB923C)],
    ).createShader(Rect.fromCircle(center: Offset(discX, discY), radius: discR));
    canvas.drawCircle(Offset(discX, discY), discR, Paint()..shader = discShader);
    canvas.drawCircle(
      Offset(discX, discY),
      discR,
      Paint()
        ..color = const Color(0xFFEA580C)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke,
    );

    // 6. DYNAMIC 3D OPTIC CUP EXCAVATION (Driven by cdRatio)
    final cupR = (discR * cdRatio.clamp(0.1, 0.95));
    final isGlaucoma = cdRatio > 0.5;
    final cupColor1 = isGlaucoma ? const Color(0xFFFEF08A) : const Color(0xFFFFFFFF);
    final cupColor2 = isGlaucoma ? const Color(0xFFFDE047) : const Color(0xFFFEF3C7);
    final cupShader = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      colors: [cupColor1, cupColor2, const Color(0xFFD97706)],
    ).createShader(Rect.fromCircle(center: Offset(discX, discY), radius: cupR));

    canvas.drawCircle(Offset(discX, discY), cupR, Paint()..shader = cupShader);

    // Inner Depth Shadow for 3D Excavation
    canvas.drawCircle(
      Offset(discX, discY),
      cupR,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Lamina Cribrosa Pores (Small stippling dots at cup floor)
    final porePaint = Paint()..color = const Color(0xFFB45309).withValues(alpha: 0.5);
    for (int px = -2; px <= 2; px++) {
      for (int py = -2; py <= 2; py++) {
        if (px * px + py * py <= 4) {
          canvas.drawCircle(Offset(discX + px * (cupR * 0.28), discY + py * (cupR * 0.28)), 1.2, porePaint);
        }
      }
    }

    // Caliper Measurement Reticle Lines
    final caliperPaint = Paint()
      ..color = isGlaucoma ? const Color(0xFFEF4444) : const Color(0xFF06B6D4)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(discX - cupR, discY), Offset(discX + cupR, discY), caliperPaint);
    canvas.drawLine(Offset(discX, discY - cupR), Offset(discX, discY + cupR), caliperPaint);

    // Caliper ratio HUD label
    _drawText(
      canvas,
      '${isOD ? "OD" : "OS"} C:D = ${cdRatio.toStringAsFixed(2)}',
      Offset(discX, discY - discR - 16),
      isGlaucoma ? const Color(0xFFEF4444) : const Color(0xFF06B6D4),
      fontSize: 11,
      isBold: true,
      center: true,
    );
    _drawText(
      canvas,
      isGlaucoma ? '⚠️ Glaucoma Risk' : 'Normal C:D',
      Offset(discX, discY + discR + 6),
      isGlaucoma ? const Color(0xFFEF4444) : const Color(0xFF10B981),
      fontSize: 9.5,
      isBold: true,
      center: true,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    Color color, {
    double fontSize = 10,
    bool isBold = false,
    bool alignRight = false,
    bool center = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    double dx = offset.dx;
    if (alignRight) {
      dx -= tp.width;
    } else if (center) {
      dx -= tp.width / 2;
    }
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _Eye3DPainter oldDelegate) {
    return oldDelegate.activeLayer != activeLayer ||
        oldDelegate.isDark != isDark ||
        oldDelegate.isRightEye != isRightEye ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.viewMode != viewMode ||
        oldDelegate.cdRatio != cdRatio ||
        oldDelegate.layerSeparation != layerSeparation;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. NEUROLOGY BRAIN & CIRCLE OF WILLIS PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _NeurologyBrainPainter extends CustomPainter {
  final NeurologyLayer activeLayer;
  final bool isDark;

  const _NeurologyBrainPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.48;
    final r = math.min(size.width, size.height) * 0.38;

    // 1. CORTICAL LOBES SILHOUETTE
    if (activeLayer == NeurologyLayer.all || activeLayer == NeurologyLayer.cortical) {
      final brainPath = Path();
      brainPath.moveTo(cx - r * 0.9, cy);
      brainPath.cubicTo(cx - r * 0.9, cy - r * 0.8, cx - r * 0.3, cy - r * 0.95, cx, cy - r * 0.95);
      brainPath.cubicTo(cx + r * 0.6, cy - r * 0.95, cx + r * 0.95, cy - r * 0.6, cx + r * 0.9, cy);
      brainPath.cubicTo(cx + r * 0.9, cy + r * 0.5, cx + r * 0.5, cy + r * 0.8, cx + r * 0.1, cy + r * 0.75);
      brainPath.cubicTo(cx - r * 0.3, cy + r * 0.9, cx - r * 0.8, cy + r * 0.6, cx - r * 0.9, cy);
      brainPath.close();

      final brainFill = Paint()
        ..color = (isDark ? const Color(0xFF8B5CF6) : const Color(0xFFC4B5FD)).withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      canvas.drawPath(brainPath, brainFill);

      final brainBorder = Paint()
        ..color = const Color(0xFF8B5CF6)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(brainPath, brainBorder);

      // Sulci / Gyri convolutions
      final gyrusPaint = Paint()
        ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.45)
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx - r * 0.3, cy - r * 0.3), radius: r * 0.35), -0.5, 2.0, false, gyrusPaint);
      canvas.drawArc(Rect.fromCircle(center: Offset(cx + r * 0.3, cy - r * 0.2), radius: r * 0.4), 0.8, 1.8, false, gyrusPaint);
    }

    // 2. VENTRICULAR SYSTEM & CSF
    if (activeLayer == NeurologyLayer.all || activeLayer == NeurologyLayer.ventricular) {
      final ventPaint = Paint()
        ..color = const Color(0xFF06B6D4).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;
      final ventPath = Path();
      ventPath.moveTo(cx - 35, cy - 35);
      ventPath.cubicTo(cx - 15, cy - 60, cx + 20, cy - 50, cx + 30, cy - 25);
      ventPath.cubicTo(cx + 35, cy, cx + 10, cy + 15, cx, cy + 20);
      canvas.drawPath(ventPath, ventPaint);

      final csfPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy + 18), 5, csfPaint);
    }

    // 3. BASAL GANGLIA & THALAMUS
    if (activeLayer == NeurologyLayer.all || activeLayer == NeurologyLayer.basalGanglia) {
      final bgPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 22, cy - 5), width: 22, height: 16), bgPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 22, cy - 5), width: 22, height: 16), bgPaint);

      final stnPaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx + 15, cy + 10), 4, stnPaint); // STN DBS target
    }

    // 4. CIRCLE OF WILLIS & CEREBROVASCULAR
    if (activeLayer == NeurologyLayer.all || activeLayer == NeurologyLayer.vascular) {
      final arteryPaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      // Arterial polygon
      final willisRect = Rect.fromCenter(center: Offset(cx, cy + 45), width: 44, height: 32);
      canvas.drawOval(willisRect, arteryPaint);
      // MCA branches
      canvas.drawLine(Offset(cx - 22, cy + 45), Offset(cx - 70, cy + 30), arteryPaint);
      canvas.drawLine(Offset(cx + 22, cy + 45), Offset(cx + 70, cy + 30), arteryPaint);
      // Basilar artery
      canvas.drawLine(Offset(cx, cy + 61), Offset(cx, cy + 90), arteryPaint);
    }

    // 5. CRANIAL NERVES (I-XII) & BRAINSTEM
    if (activeLayer == NeurologyLayer.all || activeLayer == NeurologyLayer.cranialNerves) {
      final stemPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 6; i++) {
        final yOff = cy + 50 + (i * 7.0);
        canvas.drawLine(Offset(cx - 10, yOff), Offset(cx - 35, yOff + 4), stemPaint);
        canvas.drawLine(Offset(cx + 10, yOff), Offset(cx + 35, yOff + 4), stemPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _NeurologyBrainPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. NEURO-OTOLOGY VESTIBULAR LABYRINTH PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _NeuroOtologyPainter extends CustomPainter {
  final NeuroOtologyLayer activeLayer;
  final bool isDark;

  const _NeuroOtologyPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final r = math.min(size.width, size.height) * 0.35;

    // Temporal bone background halo
    final bonePaint = Paint()
      ..color = (isDark ? const Color(0xFF1E1B4B) : const Color(0xFFE0E7FF)).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), r * 1.1, bonePaint);

    // 1. SEMICIRCULAR CANALS (Anterior, Posterior, Horizontal)
    if (activeLayer == NeuroOtologyLayer.all || activeLayer == NeuroOtologyLayer.canals) {
      final canalPaint = Paint()
        ..color = const Color(0xFF6366F1)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;

      // Anterior Canal (Vertical Top)
      canvas.drawArc(Rect.fromCenter(center: Offset(cx + 15, cy - 40), width: 60, height: 75), -math.pi * 0.85, math.pi * 1.2, false, canalPaint);
      // Posterior Canal (BPPV site)
      final postPaint = Paint()
        ..color = const Color(0xFFF43F5E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5;
      canvas.drawArc(Rect.fromCenter(center: Offset(cx + 45, cy - 10), width: 65, height: 60), -0.2, math.pi * 1.1, false, postPaint);
      // Horizontal / Lateral Canal
      canvas.drawArc(Rect.fromCenter(center: Offset(cx + 35, cy + 15), width: 50, height: 35), -0.5, math.pi * 0.95, false, canalPaint);
    }

    // 2. OTOLITH ORGANS (Utricle & Saccule)
    if (activeLayer == NeuroOtologyLayer.all || activeLayer == NeuroOtologyLayer.otoliths) {
      final otolithPaint = Paint()
        ..color = const Color(0xFFEAB308)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 5, cy), width: 22, height: 16), otolithPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 8, cy + 16), width: 16, height: 14), otolithPaint);
    }

    // 3. COCHLEA (Spiral Snail Shell)
    if (activeLayer == NeuroOtologyLayer.all || activeLayer == NeuroOtologyLayer.cochlea) {
      final cochleaPaint = Paint()
        ..color = const Color(0xFF06B6D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7.0;

      final cochleaPath = Path();
      cochleaPath.moveTo(cx - 15, cy + 20);
      cochleaPath.quadraticBezierTo(cx - 50, cy + 10, cx - 65, cy + 35);
      cochleaPath.quadraticBezierTo(cx - 75, cy + 65, cx - 45, cy + 70);
      cochleaPath.quadraticBezierTo(cx - 25, cy + 70, cx - 35, cy + 45);
      canvas.drawPath(cochleaPath, cochleaPaint);
    }

    // 4. VESTIBULOCOCHLEAR NERVE (CN VIII)
    if (activeLayer == NeuroOtologyLayer.all || activeLayer == NeuroOtologyLayer.nerve) {
      final nervePaint = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawLine(Offset(cx - 20, cy + 10), Offset(cx - 90, cy + 5), nervePaint);
      canvas.drawLine(Offset(cx - 20, cy + 18), Offset(cx - 90, cy + 25), nervePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeuroOtologyPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. NEURO-PSYCHIATRY & TMS NETWORK PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _NeuroPsychiatryPainter extends CustomPainter {
  final NeuroPsychiatryLayer activeLayer;
  final bool isDark;

  const _NeuroPsychiatryPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.48;
    final r = math.min(size.width, size.height) * 0.38;

    // Cerebral boundary
    final meshPaint = Paint()
      ..color = (isDark ? const Color(0xFFA855F7) : const Color(0xFFDDD6FE)).withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: r * 2.1, height: r * 1.6), meshPaint);

    // 1. PREFRONTAL CORTEX (DLPFC - TMS Coil)
    if (activeLayer == NeuroPsychiatryLayer.all || activeLayer == NeuroPsychiatryLayer.prefrontal) {
      final dlpfcPaint = Paint()
        ..color = const Color(0xFFA855F7)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - r * 0.65, cy - r * 0.35), 14, dlpfcPaint);

      // TMS Magnetic Field Coil Vectors
      final coilPaint = Paint()
        ..color = const Color(0xFFE879F9).withValues(alpha: 0.7)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(Offset(cx - r * 0.65, cy - r * 0.35), 22, coilPaint);
      canvas.drawCircle(Offset(cx - r * 0.65, cy - r * 0.35), 32, coilPaint);
    }

    // 2. LIMBIC SYSTEM (Amygdala & Hippocampus)
    if (activeLayer == NeuroPsychiatryLayer.all || activeLayer == NeuroPsychiatryLayer.limbic) {
      final limbicPaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - 15, cy + 15), 10, limbicPaint); // Amygdala

      final hippoPaint = Paint()
        ..color = const Color(0xFFF97316)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;
      final hippoPath = Path();
      hippoPath.moveTo(cx - 15, cy + 15);
      hippoPath.quadraticBezierTo(cx + 20, cy + 40, cx + 45, cy + 10);
      canvas.drawPath(hippoPath, hippoPaint);
    }

    // 3. DEFAULT MODE NETWORK (DMN Hubs & Connections)
    if (activeLayer == NeuroPsychiatryLayer.all || activeLayer == NeuroPsychiatryLayer.dmn) {
      final dmnPaint = Paint()
        ..color = const Color(0xFF06B6D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      final p1 = Offset(cx - r * 0.6, cy - r * 0.2); // mPFC
      final p2 = Offset(cx + r * 0.5, cy - r * 0.1); // PCC / Precuneus
      final p3 = Offset(cx, cy + r * 0.4); // Angular / Inferior parietal

      canvas.drawLine(p1, p2, dmnPaint);
      canvas.drawLine(p2, p3, dmnPaint);
      canvas.drawLine(p3, p1, dmnPaint);

      final nodePaint = Paint()
        ..color = const Color(0xFF06B6D4)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p1, 7, nodePaint);
      canvas.drawCircle(p2, 7, nodePaint);
      canvas.drawCircle(p3, 7, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _NeuroPsychiatryPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. RHINOLOGY & SINUS PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _RhinologySinusPainter extends CustomPainter {
  final RhinologyLayer activeLayer;
  final bool isDark;

  const _RhinologySinusPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Outer nasal cavity
    final cavityPaint = Paint()
      ..color = (isDark ? const Color(0xFF134E48) : const Color(0xFFCCFBF1)).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 140, height: 180), cavityPaint);

    // 1. NASAL SEPTUM
    if (activeLayer == RhinologyLayer.all || activeLayer == RhinologyLayer.septum) {
      final septumPaint = Paint()
        ..color = const Color(0xFF14B8A6)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx, cy - 70), Offset(cx, cy + 60), septumPaint);
      // Spur deflection marker
      canvas.drawLine(Offset(cx, cy - 10), Offset(cx - 15, cy), septumPaint);
    }

    // 2. TURBINATES (Inferior & Middle)
    if (activeLayer == RhinologyLayer.all || activeLayer == RhinologyLayer.turbinates) {
      final turbPaint = Paint()
        ..color = const Color(0xFFF97316)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0;
      // Right & Left Inferior Turbinates
      canvas.drawArc(Rect.fromCenter(center: Offset(cx - 35, cy + 20), width: 30, height: 45), 0.5, 2.0, false, turbPaint);
      canvas.drawArc(Rect.fromCenter(center: Offset(cx + 35, cy + 20), width: 30, height: 45), -2.5, 2.0, false, turbPaint);
    }

    // 3. PARANASAL SINUSES (Frontal & Maxillary)
    if (activeLayer == RhinologyLayer.all || activeLayer == RhinologyLayer.sinuses) {
      final sinusPaint = Paint()
        ..color = const Color(0xFF0EA5E9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5;

      // Frontal Sinuses (Top)
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 25, cy - 80), width: 36, height: 26), sinusPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 25, cy - 80), width: 36, height: 26), sinusPaint);

      // Maxillary Sinuses (Lateral Cheeks)
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 75, cy + 10), width: 44, height: 55), sinusPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 75, cy + 10), width: 44, height: 55), sinusPaint);
    }

    // 4. NASOPHARYNX
    if (activeLayer == RhinologyLayer.all || activeLayer == RhinologyLayer.nasopharynx) {
      final pharynxPaint = Paint()
        ..color = const Color(0xFFEAB308)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 85), width: 40, height: 20), pharynxPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RhinologySinusPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. VEIN & VASCULAR (PHLEBOLOGY) PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _VascularVeinPainter extends CustomPainter {
  final bool isDark;

  const _VascularVeinPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Limb outline
    final legPaint = Paint()
      ..color = (isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2)).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: 180, height: 250), const Radius.circular(30)), legPaint);

    // Deep Femoral Vein (Blue main trunk)
    final deepPaint = Paint()
      ..color = const Color(0xFF1E3A8A)
      ..strokeWidth = 7.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx + 25, cy - 100), Offset(cx + 25, cy + 100), deepPaint);

    // Great Saphenous Vein (GSV)
    final gsvPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    final gsvPath = Path();
    gsvPath.moveTo(cx - 40, cy - 80);
    gsvPath.quadraticBezierTo(cx - 15, cy - 10, cx - 35, cy + 90);
    canvas.drawPath(gsvPath, gsvPaint);

    // Saphenofemoral Junction (SFJ)
    final sfjPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 20, cy - 75), 9, sfjPaint);

    // Spider / Reticular clusters
    final spiderPaint = Paint()
      ..color = const Color(0xFFEC4899)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    for (int i = 0; i < 5; i++) {
      canvas.drawLine(Offset(cx + 40, cy + 20 + i * 8.0), Offset(cx + 65, cy + 15 + i * 9.0), spiderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VascularVeinPainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. PULMONOLOGY TRACHEOBRONCHIAL TREE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _PulmonologyPainter extends CustomPainter {
  final PulmonologyLayer activeLayer;
  final bool isDark;

  const _PulmonologyPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // 1. LUNG PARENCHYMA SHAPES
    if (activeLayer == PulmonologyLayer.all || activeLayer == PulmonologyLayer.parenchyma) {
      final lungFill = Paint()
        ..color = (isDark ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD)).withValues(alpha: 0.25)
        ..style = PaintingStyle.fill;
      // Right Lung (3 lobes)
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 65, cy), width: 75, height: 160), lungFill);
      // Left Lung (2 lobes with cardiac notch)
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 65, cy), width: 70, height: 150), lungFill);
    }

    // 2. TRACHEOBRONCHIAL TREE
    if (activeLayer == PulmonologyLayer.all || activeLayer == PulmonologyLayer.airways) {
      final airPaint = Paint()
        ..color = const Color(0xFF0EA5E9)
        ..strokeWidth = 6.0
        ..style = PaintingStyle.stroke;
      // Trachea
      canvas.drawLine(Offset(cx, cy - 100), Offset(cx, cy - 35), airPaint);
      // Carina Bifurcation
      canvas.drawLine(Offset(cx, cy - 35), Offset(cx - 45, cy + 15), airPaint);
      canvas.drawLine(Offset(cx, cy - 35), Offset(cx + 45, cy + 15), airPaint);
      // Subcarinal Lymph Node Station 7
      final nodePaint = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy - 25), 6, nodePaint);
    }

    // 3. PLEURAL SPACE & DIAPHRAGM
    if (activeLayer == PulmonologyLayer.all || activeLayer == PulmonologyLayer.pleura) {
      final pleuraPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCenter(center: Offset(cx, cy + 70), width: 220, height: 80), -math.pi * 0.9, math.pi * 0.8, false, pleuraPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PulmonologyPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. ENDOCRINOLOGY GLANDS PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _EndocrinologyPainter extends CustomPainter {
  final bool isDark;

  const _EndocrinologyPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Thyroid Butterfly Gland
    final thyroidPaint = Paint()
      ..color = (isDark ? const Color(0xFFD97706) : const Color(0xFFFDE68A)).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = const Color(0xFFD97706)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final tPath = Path();
    // Right Lobe
    tPath.addOval(Rect.fromCenter(center: Offset(cx - 35, cy - 30), width: 45, height: 75));
    // Left Lobe
    tPath.addOval(Rect.fromCenter(center: Offset(cx + 35, cy - 30), width: 45, height: 75));
    // Isthmus
    tPath.addRect(Rect.fromCenter(center: Offset(cx, cy - 15), width: 40, height: 18));
    canvas.drawPath(tPath, thyroidPaint);
    canvas.drawPath(tPath, borderPaint);

    // Parathyroid glands (4 dots)
    final paraPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 45, cy - 50), 5, paraPaint);
    canvas.drawCircle(Offset(cx - 45, cy - 10), 5, paraPaint);
    canvas.drawCircle(Offset(cx + 45, cy - 50), 5, paraPaint);
    canvas.drawCircle(Offset(cx + 45, cy - 10), 5, paraPaint);

    // Adrenal cap
    final adrenalPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    final aPath = Path();
    aPath.moveTo(cx + 70, cy + 60);
    aPath.lineTo(cx + 95, cy + 30);
    aPath.lineTo(cx + 120, cy + 60);
    aPath.close();
    canvas.drawPath(aPath, adrenalPaint);
  }

  @override
  bool shouldRepaint(covariant _EndocrinologyPainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. UROLOGY & MEN\'S HEALTH PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _UrologyPelvisPainter extends CustomPainter {
  final UrologyLayer activeLayer;
  final bool isDark;

  const _UrologyPelvisPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // 1. KIDNEY & RENAL PELVIS
    if (activeLayer == UrologyLayer.all || activeLayer == UrologyLayer.kidney) {
      final kidneyPaint = Paint()
        ..color = const Color(0xFF831843)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 70, cy - 70), width: 45, height: 70), kidneyPaint);

      final pelvisPaint = Paint()
        ..color = const Color(0xFF38BDF8)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - 60, cy - 70), 8, pelvisPaint); // Pelvis funnel
    }

    // 2. URETERS & BLADDER
    if (activeLayer == UrologyLayer.all || activeLayer == UrologyLayer.uretersBladder) {
      final ureterPaint = Paint()
        ..color = const Color(0xFF0284C7)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - 60, cy - 60), Offset(cx - 20, cy + 10), ureterPaint);

      // Bladder dome
      final bladderPaint = Paint()
        ..color = (isDark ? const Color(0xFF1E3A8A) : const Color(0xFFDBEAFE)).withValues(alpha: 0.5)
        ..style = PaintingStyle.fill;
      final bladderBorder = Paint()
        ..color = const Color(0xFF2563EB)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      final bRect = Rect.fromCenter(center: Offset(cx, cy + 20), width: 75, height: 60);
      canvas.drawOval(bRect, bladderPaint);
      canvas.drawOval(bRect, bladderBorder);
    }

    // 3. PROSTATE ZONAL ANATOMY
    if (activeLayer == UrologyLayer.all || activeLayer == UrologyLayer.prostate) {
      final periPaint = Paint()
        ..color = const Color(0xFFF43F5E)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 65), width: 50, height: 35), periPaint); // Peripheral

      final transPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx, cy + 65), 10, transPaint); // Transition
    }
  }

  @override
  bool shouldRepaint(covariant _UrologyPelvisPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 9. OB/GYN & FERTILITY PELVIS PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _ObGynPelvisPainter extends CustomPainter {
  final ObGynLayer activeLayer;
  final bool isDark;

  const _ObGynPelvisPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // 1. UTERUS & ENDOMETRIAL CAVITY
    if (activeLayer == ObGynLayer.all || activeLayer == ObGynLayer.uterus) {
      final uterusPaint = Paint()
        ..color = (isDark ? const Color(0xFF881337) : const Color(0xFFFECDD3)).withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      final uPath = Path();
      uPath.moveTo(cx - 45, cy - 40);
      uPath.cubicTo(cx - 50, cy - 65, cx + 50, cy - 65, cx + 45, cy - 40);
      uPath.lineTo(cx + 20, cy + 25);
      uPath.lineTo(cx - 20, cy + 25);
      uPath.close();
      canvas.drawPath(uPath, uterusPaint);

      // Endometrial Cavity line
      final endoPaint = Paint()
        ..color = const Color(0xFFF43F5E)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx, cy - 50), Offset(cx, cy + 15), endoPaint);
    }

    // 2. OVARIES & FALLOPIAN TUBES
    if (activeLayer == ObGynLayer.all || activeLayer == ObGynLayer.adnexa) {
      final tubePaint = Paint()
        ..color = const Color(0xFFFB7185)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke;
      canvas.drawArc(Rect.fromCenter(center: Offset(cx - 65, cy - 45), width: 60, height: 40), 0.5, 2.2, false, tubePaint);
      canvas.drawArc(Rect.fromCenter(center: Offset(cx + 65, cy - 45), width: 60, height: 40), -2.7, 2.2, false, tubePaint);

      final ovaryPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 85, cy - 35), width: 22, height: 16), ovaryPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 85, cy - 35), width: 22, height: 16), ovaryPaint);
    }

    // 3. CERVIX & PELVIC FLOOR
    if (activeLayer == ObGynLayer.all || activeLayer == ObGynLayer.pelvicFloor) {
      final cervixPaint = Paint()
        ..color = const Color(0xFFBE123C)
        ..strokeWidth = 5.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(cx - 15, cy + 30), Offset(cx + 15, cy + 30), cervixPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ObGynPelvisPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 10. PODIATRY & FOOT BIOMECHANICS PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _PodiatryPainter extends CustomPainter {
  final bool isDark;

  const _PodiatryPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Foot sole contour
    final footPaint = Paint()
      ..color = (isDark ? const Color(0xFF14532D) : const Color(0xFFDCFCE7)).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    final fPath = Path();
    fPath.moveTo(cx - 80, cy);
    fPath.cubicTo(cx - 80, cy - 40, cx - 20, cy - 45, cx + 50, cy - 50); // Medial arch
    fPath.cubicTo(cx + 85, cy - 45, cx + 90, cy + 20, cx + 60, cy + 35); // Toes
    fPath.cubicTo(cx, cy + 50, cx - 70, cy + 45, cx - 80, cy); // Lateral heel
    canvas.drawPath(fPath, footPaint);

    // Calcaneus & Plantar Fascia
    final fasciaPaint = Paint()
      ..color = const Color(0xFF84CC16)
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 70, cy), Offset(cx + 40, cy - 10), fasciaPaint);

    // Calcaneal Tuberosity node
    final heelPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 70, cy), 9, heelPaint);

    // 1st MTP Joint (Bunion)
    final bunionPaint = Paint()
      ..color = const Color(0xFFF97316)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 50, cy - 35), 8, bunionPaint);
  }

  @override
  bool shouldRepaint(covariant _PodiatryPainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 11. PLASTIC SURGERY & MEDICAL AESTHETICS PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _PlasticAestheticsPainter extends CustomPainter {
  final PlasticAestheticsLayer activeLayer;
  final bool isDark;

  const _PlasticAestheticsPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Craniofacial Oval
    final facePaint = Paint()
      ..color = (isDark ? const Color(0xFF831843) : const Color(0xFFFCE7F3)).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 150, height: 210), facePaint);

    // 1. SMAS VECTORS
    if (activeLayer == PlasticAestheticsLayer.all || activeLayer == PlasticAestheticsLayer.smas) {
      final smasPaint = Paint()
        ..color = const Color(0xFFE11D48)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      // High-SMAS vector vectors
      canvas.drawLine(Offset(cx - 30, cy + 40), Offset(cx - 65, cy - 30), smasPaint);
      canvas.drawLine(Offset(cx + 30, cy + 40), Offset(cx + 65, cy - 30), smasPaint);
    }

    // 2. FAT COMPARTMENTS (Malar & Buccal)
    if (activeLayer == PlasticAestheticsLayer.all || activeLayer == PlasticAestheticsLayer.fatPads) {
      final fatPaint = Paint()
        ..color = const Color(0xFFFBBF24).withValues(alpha: 0.7)
        ..style = PaintingStyle.fill;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx - 35, cy - 10), width: 25, height: 18), fatPaint);
      canvas.drawOval(Rect.fromCenter(center: Offset(cx + 35, cy - 10), width: 25, height: 18), fatPaint);
    }

    // 3. NEUROVASCULAR DANGER ZONES (Facial & Angular Artery)
    if (activeLayer == PlasticAestheticsLayer.all || activeLayer == PlasticAestheticsLayer.dangerZones) {
      final dangerPaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      final aPath = Path();
      aPath.moveTo(cx - 50, cy + 60);
      aPath.quadraticBezierTo(cx - 35, cy + 20, cx - 20, cy - 40);
      canvas.drawPath(aPath, dangerPaint);

      final warningDot = Paint()
        ..color = const Color(0xFFEF4444)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - 20, cy - 40), 6, warningDot);
    }
  }

  @override
  bool shouldRepaint(covariant _PlasticAestheticsPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 12. INTERVENTIONAL PAIN SPINE PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _PainSpinePainter extends CustomPainter {
  final PainAcupunctureLayer activeLayer;
  final bool isDark;

  const _PainSpinePainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Vertebrae column (5 lumbar segments)
    final vertPaint = Paint()
      ..color = (isDark ? const Color(0xFF7C2D12) : const Color(0xFFFFEDD5)).withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    final vertBorder = Paint()
      ..color = const Color(0xFFF97316)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final y = cy - 80 + i * 36.0;
      final r = Rect.fromCenter(center: Offset(cx, y), width: 65, height: 22);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(5)), vertPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(r, const Radius.circular(5)), vertBorder);

      // Facet joints
      final facetPaint = Paint()
        ..color = const Color(0xFFEAB308)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(cx - 38, y), 5, facetPaint);
      canvas.drawCircle(Offset(cx + 38, y), 5, facetPaint);
    }

    // Epidural space trajectory
    final epiPaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy - 85), Offset(cx, cy + 90), epiPaint);
  }

  @override
  bool shouldRepaint(covariant _PainSpinePainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 13. ACUPUNCTURE MERIDIAN PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _AcupunctureMeridianPainter extends CustomPainter {
  final PainAcupunctureLayer activeLayer;
  final bool isDark;

  const _AcupunctureMeridianPainter({required this.activeLayer, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Body silhouette
    final bodyPaint = Paint()
      ..color = (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5)).withValues(alpha: 0.25)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(cx, cy), width: 130, height: 230), const Radius.circular(25)), bodyPaint);

    // Meridian lines (Ren & Du channels)
    final meridianPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx, cy - 90), Offset(cx, cy + 90), meridianPaint);
    canvas.drawLine(Offset(cx - 30, cy - 60), Offset(cx - 30, cy + 70), meridianPaint);
    canvas.drawLine(Offset(cx + 30, cy - 60), Offset(cx + 30, cy + 70), meridianPaint);

    // Acupoint nodes
    final acuPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy - 30), 6, acuPaint);
    canvas.drawCircle(Offset(cx - 30, cy + 20), 6, acuPaint); // LI4 / ST36
    canvas.drawCircle(Offset(cx + 30, cy - 50), 6, acuPaint); // GB21
  }

  @override
  bool shouldRepaint(covariant _AcupunctureMeridianPainter old) =>
      old.activeLayer != activeLayer || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 14. SPEECH-LANGUAGE PATHOLOGY (SLP) PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _SpeechPathologyPainter extends CustomPainter {
  final bool isDark;

  const _SpeechPathologyPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Sagittal oral-pharyngeal profile
    final oralPaint = Paint()
      ..color = (isDark ? const Color(0xFF0C4A6E) : const Color(0xFFE0F2FE)).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: 140, height: 180), oralPaint);

    // Tongue musculature
    final tonguePaint = Paint()
      ..color = const Color(0xFFFB7185)
      ..style = PaintingStyle.fill;
    final tPath = Path();
    tPath.moveTo(cx - 50, cy);
    tPath.quadraticBezierTo(cx - 10, cy - 40, cx + 30, cy);
    tPath.quadraticBezierTo(cx, cy + 30, cx - 50, cy);
    canvas.drawPath(tPath, tonguePaint);

    // Palate / Uvula
    final palatePaint = Paint()
      ..color = const Color(0xFF38BDF8)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 50, cy - 50), Offset(cx + 20, cy - 50), palatePaint);

    // Vocal folds / Larynx
    final larynxPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx + 10, cy + 40), Offset(cx + 35, cy + 40), larynxPaint);
  }

  @override
  bool shouldRepaint(covariant _SpeechPathologyPainter old) => old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// 15. VETERINARY QUADRUPED 3D PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _VeterinaryQuadrupedPainter extends CustomPainter {
  final bool isDark;
  final bool isCanine;
  final VeterinaryLayer activeLayer;
  final double yaw;
  final double pitch;

  const _VeterinaryQuadrupedPainter({
    required this.isDark,
    required this.isCanine,
    required this.activeLayer,
    required this.yaw,
    required this.pitch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5 + yaw * 30;
    final cy = size.height * 0.5 + pitch * 20;

    // Body silhouette
    final bodyPaint = Paint()
      ..color = (isDark ? const Color(0xFF064E3B) : const Color(0xFFD1FAE5)).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Quadruped torso oval
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx, cy), width: isCanine ? 170 : 150, height: isCanine ? 85 : 75),
      bodyPaint,
    );

    // Quadruped spine (axial column)
    final spinePaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;
    final spinePath = Path();
    spinePath.moveTo(cx - 80, cy - 10);
    spinePath.quadraticBezierTo(cx - 20, cy - 25, cx + 50, cy - 20);
    spinePath.quadraticBezierTo(cx + 70, cy - 35, cx + 90, cy - 40);
    canvas.drawPath(spinePath, spinePaint);

    // Skull & snout
    final headPaint = Paint()
      ..color = const Color(0xFF34D399)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 95, cy - 40), width: isCanine ? 42 : 32, height: isCanine ? 30 : 26),
      headPaint,
    );

    // Muzzle / nose
    final muzzlePaint = Paint()
      ..color = const Color(0xFF059669)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 115, cy - 38), isCanine ? 7 : 5, muzzlePaint);

    // Thoracic cage ribs
    if (activeLayer == VeterinaryLayer.all || activeLayer == VeterinaryLayer.skeletal) {
      final ribPaint = Paint()
        ..color = const Color(0xFF6EE7B7).withValues(alpha: 0.7)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      for (int i = 0; i < 5; i++) {
        final rx = cx + 30 - (i * 14);
        canvas.drawLine(Offset(rx, cy - 18), Offset(rx - 4, cy + 18), ribPaint);
      }
    }

    // Forelimbs (front legs)
    final legPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx + 40, cy + 10), Offset(cx + 35, cy + 65), legPaint);
    canvas.drawLine(Offset(cx + 25, cy + 10), Offset(cx + 20, cy + 65), legPaint);

    // Hindlimbs (back legs & stifle)
    canvas.drawLine(Offset(cx - 65, cy + 5), Offset(cx - 75, cy + 65), legPaint);
    canvas.drawLine(Offset(cx - 50, cy + 5), Offset(cx - 60, cy + 65), legPaint);

    // Tail
    final tailPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final tailPath = Path();
    tailPath.moveTo(cx - 85, cy - 10);
    tailPath.quadraticBezierTo(cx - 110, cy - 40, cx - 125, cy - 20);
    canvas.drawPath(tailPath, tailPaint);
  }

  @override
  bool shouldRepaint(covariant _VeterinaryQuadrupedPainter old) =>
      old.isDark != isDark ||
      old.isCanine != isCanine ||
      old.activeLayer != activeLayer ||
      old.yaw != yaw ||
      old.pitch != pitch;
}

// ─────────────────────────────────────────────────────────────────────────────
// 16. DIAGNOSTIC LAB SPECIMEN 3D PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _DiagnosticLabSpecimenPainter extends CustomPainter {
  final bool isDark;
  final String magnification;
  final double focusDepth;
  final DiagnosticLabLayer activeLayer;

  const _DiagnosticLabSpecimenPainter({
    required this.isDark,
    required this.magnification,
    required this.focusDepth,
    required this.activeLayer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;

    // Microscope aperture circular field of view
    final fovPaint = Paint()
      ..color = (isDark ? const Color(0xFF1E1538) : const Color(0xFFF3E8FF)).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx, cy), 115, fovPaint);

    final fovBorder = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy), 115, fovBorder);

    // Reticle crosshair
    final reticlePaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: 0.2)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - 115, cy), Offset(cx + 115, cy), reticlePaint);
    canvas.drawLine(Offset(cx, cy - 115), Offset(cx, cy + 115), reticlePaint);

    // Multi-plane cellular morphology (depth-based blur/clarity)
    final blurFactor = (focusDepth - 25.0).abs() / 100.0;
    final alphaVal = (1.0 - blurFactor).clamp(0.3, 0.95);

    // Erythrocytes (RBC disc)
    final rbcPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: alphaVal)
      ..style = PaintingStyle.fill;
    final rbcBorder = Paint()
      ..color = const Color(0xFF991B1B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final cellOffsets = [
      Offset(cx - 70, cy - 35),
      Offset(cx - 50, cy - 20),
      Offset(cx - 30, cy - 60),
      Offset(cx - 85, cy + 10),
      Offset(cx - 40, cy + 25),
      Offset(cx + 10, cy - 40),
      Offset(cx - 60, cy + 50),
    ];

    for (final offset in cellOffsets) {
      canvas.drawCircle(offset, 11, rbcPaint);
      canvas.drawCircle(offset, 11, rbcBorder);
      // Central pallor
      canvas.drawCircle(offset, 4, Paint()..color = (isDark ? const Color(0xFF130E26) : Colors.white).withValues(alpha: 0.6));
    }

    // Leukocytes (WBC with lobed nucleus)
    final wbcPaint = Paint()
      ..color = const Color(0xFF8B5CF6).withValues(alpha: alphaVal)
      ..style = PaintingStyle.fill;
    final nucleusPaint = Paint()
      ..color = const Color(0xFF4C1D95)
      ..style = PaintingStyle.fill;

    final wbcOffset = Offset(cx + 45, cy - 30);
    canvas.drawCircle(wbcOffset, 20, wbcPaint);
    canvas.drawCircle(Offset(wbcOffset.dx - 5, wbcOffset.dy - 3), 6, nucleusPaint);
    canvas.drawCircle(Offset(wbcOffset.dx + 5, wbcOffset.dy - 2), 5, nucleusPaint);
    canvas.drawCircle(Offset(wbcOffset.dx, wbcOffset.dy + 6), 5, nucleusPaint);

    // Platelet granules
    final pltPaint = Paint()
      ..color = const Color(0xFFA78BFA)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 15, cy + 40), 3, pltPaint);
    canvas.drawCircle(Offset(cx - 22, cy + 46), 2.5, pltPaint);
    canvas.drawCircle(Offset(cx - 10, cy + 48), 3, pltPaint);
  }

  @override
  bool shouldRepaint(covariant _DiagnosticLabSpecimenPainter old) =>
      old.isDark != isDark ||
      old.magnification != magnification ||
      old.focusDepth != focusDepth ||
      old.activeLayer != activeLayer;
}

// ─────────────────────────────────────────────────────────────────────────────
// 17. MENTAL HEALTH 3D BRAIN AXIS PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _MentalHealthBrainAxisPainter extends CustomPainter {
  final bool isDark;
  final MentalHealthLayer activeLayer;
  final double yaw;
  final double pitch;

  const _MentalHealthBrainAxisPainter({
    required this.isDark,
    required this.activeLayer,
    required this.yaw,
    required this.pitch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5 + yaw * 35;
    final cy = size.height * 0.5 + pitch * 25;

    // Cerebral hemisphere silhouette
    final brainPaint = Paint()
      ..color = (isDark ? const Color(0xFF0E3B43) : const Color(0xFFCFFAFE)).withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(cx - 90, cy);
    path.cubicTo(cx - 90, cy - 75, cx - 30, cy - 90, cx + 20, cy - 85);
    path.cubicTo(cx + 75, cy - 80, cx + 95, cy - 40, cx + 90, cy + 10);
    path.cubicTo(cx + 85, cy + 60, cx + 45, cy + 80, cx, cy + 75);
    path.cubicTo(cx - 40, cy + 70, cx - 85, cy + 50, cx - 90, cy);
    canvas.drawPath(path, brainPaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawPath(path, borderPaint);

    // dlPFC Executive Hub (Anterior Dorsolateral)
    final dlpfcPaint = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx - 65, cy - 40), 16, dlpfcPaint);

    // Limbic Hub / Amygdala (Medial Temporal)
    final amygdalaPaint = Paint()
      ..color = const Color(0xFFF43F5E)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(cx + 15, cy + 10), 14, amygdalaPaint);

    // Hippocampus (Curved Memory Circuit)
    final hippoPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final hippoPath = Path();
    hippoPath.moveTo(cx + 40, cy + 10);
    hippoPath.quadraticBezierTo(cx + 60, cy + 25, cx + 55, cy + 45);
    canvas.drawPath(hippoPath, hippoPaint);

    // Neural Synaptic Pathway Connectors (dlPFC -> Amygdala feedback)
    final synapsePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.6)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(cx - 50, cy - 35), Offset(cx + 5, cy + 5), synapsePaint);
    canvas.drawLine(Offset(cx + 15, cy + 15), Offset(cx + 40, cy + 20), synapsePaint);
  }

  @override
  bool shouldRepaint(covariant _MentalHealthBrainAxisPainter old) =>
      old.isDark != isDark ||
      old.activeLayer != activeLayer ||
      old.yaw != yaw ||
      old.pitch != pitch;
}

// ─────────────────────────────────────────────────────────────────────────────
// 18. PEDIATRIC DEVELOPMENT 3D PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _PediatricDevelopmentPainter extends CustomPainter {
  final bool isDark;
  final int ageMonths;
  final PediatricLayer activeLayer;
  final double yaw;
  final double pitch;

  const _PediatricDevelopmentPainter({
    required this.isDark,
    required this.ageMonths,
    required this.activeLayer,
    required this.yaw,
    required this.pitch,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5 + yaw * 25;
    final cy = size.height * 0.5 + pitch * 20;

    // Pediatric proportional infant silhouette (larger head:body ratio)
    final bodyPaint = Paint()
      ..color = (isDark ? const Color(0xFF451A03) : const Color(0xFFFEF3C7)).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;

    // Cranium / Head
    canvas.drawCircle(Offset(cx, cy - 60), 45, bodyPaint);
    final craniumBorder = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(Offset(cx, cy - 60), 45, craniumBorder);

    // Anterior Fontanelle (rhomboid soft spot at junction of coronal and sagittal sutures)
    final fontanellePaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;
    final fPath = Path();
    fPath.moveTo(cx, cy - 95);
    fPath.lineTo(cx + 10, cy - 85);
    fPath.lineTo(cx, cy - 75);
    fPath.lineTo(cx - 10, cy - 85);
    fPath.close();
    canvas.drawPath(fPath, fontanellePaint);

    // Torso / Abdomen
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 20), width: 70, height: 85), bodyPaint);
    final torsoBorder = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.7)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + 20), width: 70, height: 85), torsoBorder);

    // Umbilicus
    canvas.drawCircle(Offset(cx, cy + 20), 4, Paint()..color = const Color(0xFFD97706));

    // Deciduous Dental Arch (mouth / primary teeth dots)
    final toothPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    for (int i = -2; i <= 2; i++) {
      canvas.drawCircle(Offset(cx + (i * 7), cy - 42), 2.5, toothPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _PediatricDevelopmentPainter old) =>
      old.isDark != isDark ||
      old.ageMonths != ageMonths ||
      old.activeLayer != activeLayer ||
      old.yaw != yaw ||
      old.pitch != pitch;
}
