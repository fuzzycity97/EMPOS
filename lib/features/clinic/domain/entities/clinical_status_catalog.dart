import 'clinical_anatomy_status_entry.dart';
import 'procedure_item.dart';
import '../../presentation/widgets/multi_specialty_anatomy_canvas_widget.dart' show ClinicalSpecialtyDiscipline;

/// Master Catalog of Multi-Specialty Clinical Statuses & Actions.
/// Provides exhaustive statuses per discipline and organ with full text search,
/// category filtering, severity tagging, and billing procedure linkage.
class ClinicalStatusCatalog {
  ClinicalStatusCatalog._();

  static List<ClinicalStatusDefinition> getStatusesForDiscipline({
    required ClinicalSpecialtyDiscipline discipline,
    String? partKey,
  }) {
    switch (discipline) {
      case ClinicalSpecialtyDiscipline.neurology:
        return _neurologyStatuses;
      case ClinicalSpecialtyDiscipline.neuroOtology:
        return _neuroOtologyStatuses;
      case ClinicalSpecialtyDiscipline.neuroPsychiatry:
        return _neuroPsychiatryStatuses;
      case ClinicalSpecialtyDiscipline.ophthalmology:
        return _ophthalmologyStatuses;
      case ClinicalSpecialtyDiscipline.rhinologyEnt:
        return _rhinologyStatuses;
      case ClinicalSpecialtyDiscipline.dental:
        return _dentalStatuses;
      case ClinicalSpecialtyDiscipline.cardiology:
        return _cardioStatuses;
      case ClinicalSpecialtyDiscipline.vascularVein:
        return _vascularVeinStatuses;
      case ClinicalSpecialtyDiscipline.pulmonology:
        return _pulmonologyStatuses;
      case ClinicalSpecialtyDiscipline.endocrinology:
        return _endocrinologyStatuses;
      case ClinicalSpecialtyDiscipline.gastroenterology:
        return _gastroStatuses;
      case ClinicalSpecialtyDiscipline.urology:
        return _urologyStatuses;
      case ClinicalSpecialtyDiscipline.obgyn:
        return _obGynStatuses;
      case ClinicalSpecialtyDiscipline.orthopedics:
        return _orthopedicsStatuses;
      case ClinicalSpecialtyDiscipline.physiotherapy:
        return _physiotherapyStatuses;
      case ClinicalSpecialtyDiscipline.podiatry:
        return _podiatryStatuses;
      case ClinicalSpecialtyDiscipline.plasticSurgery:
        return _plasticSurgeryStatuses;
      case ClinicalSpecialtyDiscipline.medicalAesthetics:
        return _medicalAestheticsStatuses;
      case ClinicalSpecialtyDiscipline.dermatology:
        return _dermaStatuses;
      case ClinicalSpecialtyDiscipline.painManagement:
        return _painManagementStatuses;
      case ClinicalSpecialtyDiscipline.acupuncture:
        return _acupunctureStatuses;
      case ClinicalSpecialtyDiscipline.speechPathology:
        return _speechPathologyStatuses;
      case ClinicalSpecialtyDiscipline.veterinary:
        return _veterinaryStatuses;
      case ClinicalSpecialtyDiscipline.diagnosticLab:
        return _diagnosticLabStatuses;
      case ClinicalSpecialtyDiscipline.mentalHealth:
        return _mentalHealthStatuses;
      case ClinicalSpecialtyDiscipline.pediatrics:
        return _pediatricStatuses;
      case ClinicalSpecialtyDiscipline.general:
      default:
        return _generalMedicineStatuses;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 1. OPHTHALMOLOGY & EYE CARE
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _ophthalmologyStatuses = [
    ClinicalStatusDefinition(
      id: 'oph_healthy',
      title: 'Healthy / Normal Clear Media',
      titleAr: 'سليم وأوساط كاسرة شفافة وطبيعية',
      icd10Code: 'Z01.0',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Clear cornea, transparent crystalline lens, healthy retina and cup-to-disc ratio < 0.4.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_baseline',
        code: 'OPH-92012',
        name: 'Comprehensive Eye Examination & Refraction',
        standardFee: 200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_corneal_ulcer',
      title: 'Corneal Ulcer & Microbial Keratitis',
      titleAr: 'قرحة القرنية والتهاب القرنية الميكروبي',
      icd10Code: 'H16.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'Epithelial defect with stromal infiltration, ciliary flush, and severe photophobia.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_cornea_scraping',
        code: 'OPH-65430',
        name: 'Corneal Scraping, Culture & Fortified Antibiotics',
        standardFee: 450.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_keratoconus',
      title: 'Keratoconus & Corneal Ectasia',
      titleAr: 'القرنية المخروطية والتحدب القرني اللاتناظري',
      icd10Code: 'H18.6',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Progressive thinning of the central cornea with irregular astigmatism and Fleischer ring.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_cxl',
        code: 'OPH-0402T',
        name: 'Corneal Collagen Cross-Linking (CXL)',
        standardFee: 2200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_corneal_abrasion',
      title: 'Corneal Abrasion & Foreign Body',
      titleAr: 'خدش القرنية وجسم غريب سطحي',
      icd10Code: 'T15.0',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.mild,
      description: 'Fluorescein-positive epithelial scratching with tearing and sharp foreign body sensation.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_fb_removal',
        code: 'OPH-65222',
        name: 'Corneal Foreign Body Removal & Bandage Lens',
        standardFee: 350.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_cataract_nuclear',
      title: 'Nuclear Sclerotic Cataract (Grade 3)',
      titleAr: 'الماء الأبيض / الساد النووي الصلب',
      icd10Code: 'H25.1',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Opacification and brown-yellow discoloration of the crystalline lens reducing visual acuity.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_phaco',
        code: 'OPH-66984',
        name: 'Phacoemulsification with Foldable Monofocal IOL',
        standardFee: 3800.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_anterior_uveitis',
      title: 'Acute Anterior Uveitis / Iridocyclitis',
      titleAr: 'التهاب العنبية والقزحية الأمامي الحاد',
      icd10Code: 'H20.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Cells and flare in anterior chamber, keratic precipitates (KPs), and posterior synechiae risk.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_uveitis_mgmt',
        code: 'OPH-92014',
        name: 'Complex Uveitis Evaluation & Subconjunctival Injection',
        standardFee: 400.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_acute_glaucoma',
      title: 'Acute Angle-Closure Glaucoma',
      titleAr: 'الزرق الحاد منغلق الزاوية (ارتفاع حاد بضغط العين)',
      icd10Code: 'H40.2',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.critical,
      description: 'IOP > 45 mmHg with steamy cornea, mid-dilated non-reactive pupil, severe eye pain, and nausea.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_lpi',
        code: 'OPH-66761',
        name: 'Emergency Laser Peripheral Iridotomy (LPI)',
        standardFee: 950.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_chronic_glaucoma',
      title: 'Primary Open-Angle Glaucoma (POAG)',
      titleAr: 'الماء الأزرق المزمن / ارتفاع ضغط العين المزمن',
      icd10Code: 'H40.1',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Cupping ratio > 0.7 with nerve fiber layer thinning and Humphrey visual field arcuate defect.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_slt',
        code: 'OPH-65855',
        name: 'Selective Laser Trabeculoplasty (SLT)',
        standardFee: 1100.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_retinal_detachment',
      title: 'Rhegmatogenous Retinal Detachment (RRD)',
      titleAr: 'انفصال الشبكية التمزقي الحاد',
      icd10Code: 'H33.0',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.critical,
      description: 'Retinal break with subretinal fluid elevating neurosensory retina, flashes, and dark curtain veil.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_vitrectomy',
        code: 'OPH-67108',
        name: 'Pars Plana Vitrectomy + Endolaser + Gas/Silicon Oil',
        standardFee: 6500.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_diabetic_maculopathy',
      title: 'Diabetic Macular Edema (DME)',
      titleAr: 'اعتلال الشبكية السكري والوذمة البقعية الكيسية',
      icd10Code: 'E11.3',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.severe,
      description: 'Microaneurysms, hard exudates, and central macular thickening on spectral OCT.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_antivegf',
        code: 'OPH-67028',
        name: 'Intravitreal Anti-VEGF Injection (Ranibizumab/Aflibercept)',
        standardFee: 1400.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_vitreous_hemorrhage',
      title: 'Dense Vitreous Hemorrhage',
      titleAr: 'نزيف حاد بالجسم الزجاجي',
      icd10Code: 'H43.1',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.severe,
      description: 'Extravasated blood obscuring retinal view, requiring B-scan ultrasonography rule-out.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_bscan',
        code: 'OPH-76512',
        name: 'Ophthalmic Diagnostic B-Scan Ultrasonography',
        standardFee: 300.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'oph_pterygium',
      title: 'Progressive Pterygium encroaching Cornea',
      titleAr: 'الظفرة العينية المتوغلة على القرنية',
      icd10Code: 'H11.0',
      category: ClinicalStatusCategory.neoplasm,
      severity: ClinicalSeverityLevel.mild,
      description: 'Fibrovascular subepithelial ingrowth of conjunctival tissue encroaching corneal limbus.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_oph_pterygium_excision',
        code: 'OPH-65426',
        name: 'Pterygium Excision with Conjunctival Autograft',
        standardFee: 1600.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 2. ORTHOPEDICS & BONE SURGERY
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _orthopedicsStatuses = [
    ClinicalStatusDefinition(
      id: 'ortho_intact',
      title: 'Intact Bone Cortex & Congruent Joint',
      titleAr: 'عظم سليم وقشرة عظمية متماسكة ومفصل طبيعي',
      icd10Code: 'Z01.8',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'No discontinuity in cortical margins, normal trabecular bone density, and preserved joint space.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_xray_eval',
        code: 'ORT-73030',
        name: 'Radiographic Examination & Orthopedic Assessment',
        standardFee: 180.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'ortho_transverse_fx',
      title: 'Displaced Transverse Diaphyseal Fracture',
      titleAr: 'كسر مستعرض متباعد في جسم العظم',
      icd10Code: 'S72.3',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.severe,
      description: 'Transverse cut-line across bone cortex with angulation and overriding fragments.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_orif',
        code: 'ORT-27244',
        name: 'Open Reduction & Internal Fixation (ORIF) with Locking Plate',
        standardFee: 4200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'ortho_comminuted_fx',
      title: 'High-Energy Comminuted Fracture',
      titleAr: 'كسر مفتت متعدد الشظايا شديد الإزاحة',
      icd10Code: 'S82.2',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.critical,
      description: 'Multiple splintered cortical fragments with loss of axial alignment and soft tissue compromise.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_intramedullary_nail',
        code: 'ORT-27245',
        name: 'Interlocking Intramedullary Nailing & Bone Grafting',
        standardFee: 5500.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'ortho_hairline_fx',
      title: 'Hairline / Stress Micro-Fracture',
      titleAr: 'كسر شعري إجهادي دقيق بدون إزاحة',
      icd10Code: 'M84.3',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.mild,
      description: 'Non-displaced cortical hairline line with localized periosteal tenderness and bone marrow edema.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_fiberglass_cast',
        code: 'ORT-29075',
        name: 'Rigid Fiberglass Cast Application & Splinting',
        standardFee: 450.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'ortho_osteoarthritis',
      title: 'Severe Osteoarthritis & Joint Space Loss (Grade IV)',
      titleAr: 'خشونة وتنكس مفصلي حاد وفقدان الغضروف المفصلي',
      icd10Code: 'M17.1',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.severe,
      description: 'Subchondral sclerosis, osteophyte spurs, joint space collapse, and subchondral cysts.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_prp_injection',
        code: 'ORT-20610',
        name: 'Intra-Articular Hyaluronic Acid / PRP Joint Injection',
        standardFee: 750.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'ortho_joint_dislocation',
      title: 'Acute Complete Joint Dislocation',
      titleAr: 'خلع حاد كامل في المفصل مع تمزق المحفظة',
      icd10Code: 'S83.1',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.critical,
      description: 'Loss of articular congruity with capsule tear, requiring urgent closed or open reduction.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_closed_reduction',
        code: 'ORT-27250',
        name: 'Urgent Closed Reduction under Sedation & Immobilizer',
        standardFee: 1200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'ortho_meniscus_acl_tear',
      title: 'Complex Meniscal Tear & ACL Rupture',
      titleAr: 'تمزق الغضروف الهلالي والرباط الصليبي الأمامي',
      icd10Code: 'S83.2',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.severe,
      description: 'Bucket-handle meniscal tear with joint locking and positive Lachman / pivot shift instability.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_arthroscopy',
        code: 'ORT-29881',
        name: 'Knee Diagnostic Arthroscopy & Meniscal Repair',
        standardFee: 3900.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'ortho_osteomyelitis',
      title: 'Chronic Osteomyelitis & Bone Abscess',
      titleAr: 'التهاب نقي العظم الصديدي المزمن وخراج عظمي',
      icd10Code: 'M86.1',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.critical,
      description: 'Involucrum and sequestrum formation, cortical erosion, and draining sinus tract.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_debridement',
        code: 'ORT-20005',
        name: 'Surgical Bone Debridement & Antibiotic Bead Placement',
        standardFee: 2800.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'ortho_post_orif',
      title: 'Healed Bone Post-ORIF (Hardware in Situ)',
      titleAr: 'عظم ملتحم بعد التثبيت الجراحي (شرائح ومسامير)',
      icd10Code: 'Z98.8',
      category: ClinicalStatusCategory.surgical,
      severity: ClinicalSeverityLevel.normal,
      description: 'Complete bridging callus on 4 cortices, stable internal fixation plate and screws.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_ortho_hardware_removal',
        code: 'ORT-20680',
        name: 'Elective Deep Internal Fixation Hardware Removal',
        standardFee: 1800.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 3. PHYSIOTHERAPY & MUSCULAR REHAB
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _physiotherapyStatuses = [
    ClinicalStatusDefinition(
      id: 'physio_normal',
      title: 'Optimal Muscle Tone & Symmetrical Contraction',
      titleAr: 'توتر ومرونة عضلية ممتازة وانقباض متناظر',
      icd10Code: 'Z00.0',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Full active and passive range of motion, grade 5/5 muscle power, no tender points.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_physio_assessment',
        code: 'PT-97161',
        name: 'Functional Kinesiology & Biomechanical Evaluation',
        standardFee: 180.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'physio_acute_strain',
      title: 'Acute Muscle Strain (Grade I-II)',
      titleAr: 'شد وتمطط عضلي حاد (درجة أولى وثانية)',
      icd10Code: 'S76.1',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Microscopic tear of muscle fibers with localized edema, pain on contraction, and restricted motion.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_physio_ultrasound',
        code: 'PT-97035',
        name: 'Therapeutic Ultrasound & High-Intensity Cryotherapy',
        standardFee: 220.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'physio_muscle_tear_rupture',
      title: 'Complete Muscle Tear / Rupture (Grade III)',
      titleAr: 'تمزق عضلي كامل مع فجوة مرئية (درجة ثالثة)',
      icd10Code: 'S76.9',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.severe,
      description: 'Palpable anatomical gap in muscle belly, massive ecchymosis, and loss of functional contraction.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_physio_rehab_rupture',
        code: 'PT-97110',
        name: 'Neuromuscular Re-Education & Progressive Loading Protocol',
        standardFee: 320.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'physio_trigger_point',
      title: 'Myofascial Trigger Point & Severe Spasm',
      titleAr: 'نقطة زنادية عضلية وتشنج ليفي حاد',
      icd10Code: 'M79.1',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Hyperirritable taut band in skeletal muscle with referred pain pattern and twitch response.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_physio_dry_needling',
        code: 'PT-20560',
        name: 'Dry Needling & Deep Myofascial Release Therapy',
        standardFee: 260.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'physio_tendinitis',
      title: 'Chronic Tendinopathy / Insertional Tendinitis',
      titleAr: 'التهاب وتنكس الأوتار المزمن عند الارتكاز',
      icd10Code: 'M77.9',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Collagen disorganization, neo-vascularization, and thickening at tendon-bone interface.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_physio_shockwave',
        code: 'PT-0101T',
        name: 'Extracorporeal Radial Shockwave Therapy (ESWT)',
        standardFee: 400.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'physio_atrophy',
      title: 'Disuse Muscle Atrophy & Sarcopenia',
      titleAr: 'ضمور عضلي ناتج عن نقص الاستخدام وضعف وظيفي',
      icd10Code: 'M62.5',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.mild,
      description: 'Decrease in muscle cross-sectional area and power (Grade 3/5) following prolonged immobilization.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_physio_ems',
        code: 'PT-97032',
        name: 'Electrical Muscle Stimulation (EMS) & Isometric Strengthening',
        standardFee: 240.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 4. GASTROENTEROLOGY & INTESTINAL HEALTH
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _gastroStatuses = [
    ClinicalStatusDefinition(
      id: 'gi_normal',
      title: 'Normal Intact Mucosa & Preserved Peristalsis',
      titleAr: 'مخاطية هضمية سليمة ووردية وحركة تمعجية منتظمة',
      icd10Code: 'Z01.8',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Smooth mucosal lining, no erosions, normal vascular pattern, and intact sphincters.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gi_diagnostic_egd',
        code: 'GI-43235',
        name: 'Diagnostic Upper GI Esophagogastroduodenoscopy',
        standardFee: 1200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'gi_peptic_ulcer',
      title: 'Active Peptic Gastric Ulcer (Forrest IIb)',
      titleAr: 'قرحة معدية هضمية نشطة مع تجلط قاعدي',
      icd10Code: 'K25.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'Punched-out mucosal crater > 1.5 cm with adherent clot and high risk of rebleeding.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gi_ulcer_clipping',
        code: 'GI-43255',
        name: 'Endoscopic Hemostasis with Hemoclips & Adrenaline Injection',
        standardFee: 2100.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'gi_gerd_esophagitis',
      title: 'Severe Erosive GERD Esophagitis (Los Angeles Grade C)',
      titleAr: 'التهاب المريء الارتجاعي التآكلي الشديد',
      icd10Code: 'K21.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Continuous mucosal breaks between tops of mucosal folds involving < 75% of circumference.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gi_ph_monitoring',
        code: 'GI-91038',
        name: '24-Hour Bravo Wireless pH Impedance Monitoring',
        standardFee: 1600.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'gi_colonic_polyp',
      title: 'Pedunculated Colonic Polyp (Adenomatous)',
      titleAr: 'سليلة لحمية غدية مسوقة بالقولون',
      icd10Code: 'K63.5',
      category: ClinicalStatusCategory.neoplasm,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Sessile or pedunculated adenomatous growth projecting into lumen requiring histology.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gi_polypectomy',
        code: 'GI-45385',
        name: 'Colonoscopy with Hot Snare Polypectomy & Retrieval',
        standardFee: 2600.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'gi_crohns_colitis',
      title: 'Active Crohn\'s Disease / Ulcerative Colitis',
      titleAr: 'داء كرون أو القولون التقرحي النشط مع تقرحات عميقة',
      icd10Code: 'K51.9',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'Cobblestone appearance, deep longitudinal fissures, mucosal friability, and pseudopolyps.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gi_full_colonoscopy',
        code: 'GI-45380',
        name: 'Full Colonoscopy with Multiple Stepwise Biopsies',
        standardFee: 1900.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'gi_cholelithiasis',
      title: 'Symptomatic Cholelithiasis / Cholecystitis',
      titleAr: 'حصوات المرارة مع التهاب جدار المرارة الحاد',
      icd10Code: 'K80.2',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.severe,
      description: 'Thickened gallbladder wall > 4 mm, impacted neck stone, and positive sonographic Murphy sign.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gi_abd_us',
        code: 'GI-76705',
        name: 'Targeted Hepatobiliary Ultrasound & Liver Panel',
        standardFee: 350.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 5. CARDIOLOGY & VASCULAR
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _cardioStatuses = [
    ClinicalStatusDefinition(
      id: 'cardio_normal',
      title: 'Normal Ejection Fraction & Patent Coronaries',
      titleAr: 'تروية تاجية كاملة وسليمة وكفاءة عضلة القلب > 60%',
      icd10Code: 'Z01.8',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Normal LV systolic function, EF 65%, no wall motion abnormalities, and widely patent vessels.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_cardio_echo',
        code: 'CAR-93306',
        name: 'Transthoracic 2D Echocardiography & Color Doppler',
        standardFee: 650.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'cardio_coronary_stenosis_90',
      title: 'Critical Coronary Stenosis (90% Occlusion)',
      titleAr: 'تضيق شرياني تاجي حرج (90% انسداد بالشريان)',
      icd10Code: 'I25.1',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.critical,
      description: 'Severe eccentric calcified plaque causing > 90% luminal obstruction in proximal LAD.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_cardio_ptca_stent',
        code: 'CAR-92928',
        name: 'Percutaneous Coronary Angioplasty (PTCA) + Drug-Eluting Stent',
        standardFee: 8500.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'cardio_stemi_infarction',
      title: 'Acute ST-Elevation Myocardial Infarction (STEMI)',
      titleAr: 'جلطة قلبية حادة مع ارتفاع شريحة ST (احتشاء تام)',
      icd10Code: 'I21.0',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.critical,
      description: 'Complete acute thrombotic occlusion with transmural myocardial necrosis risk.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_cardio_emergency_cath',
        code: 'CAR-93458',
        name: 'Emergency Primary Coronary Angiography & Thrombus Aspiration',
        standardFee: 9200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'cardio_aortic_aneurysm',
      title: 'Thoracoabdominal Aortic Aneurysm (5.8 cm)',
      titleAr: 'تمدد أم دم الشريان الأبهر الصدري المتسع (5.8 سم)',
      icd10Code: 'I71.2',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.critical,
      description: 'Fusiform aortic dilation > 5.5 cm with mural thrombus and high risk of rupture or dissection.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_cardio_ct_angio',
        code: 'CAR-71275',
        name: 'CT Aortography with 3D Vascular Reconstruction',
        standardFee: 1400.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'cardio_mitral_regurgitation',
      title: 'Severe Mitral Valve Regurgitation (Grade 4)',
      titleAr: 'ارتجاع حاد بالصمام الميترالي وتراجع الدم للأذين',
      icd10Code: 'I34.0',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.severe,
      description: 'Flail leaflet, vena contracta > 0.7 cm, regurgitant fraction > 50%, and enlarged left atrium.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_cardio_tee',
        code: 'CAR-93312',
        name: 'Transesophageal Echocardiography (TEE) Structural Study',
        standardFee: 1100.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'cardio_stented_patent',
      title: 'Patent Drug-Eluting Stent in Situ',
      titleAr: 'دعامة دوائية مزروعة سابقاً وتدفق دموي ممتاز',
      icd10Code: 'Z95.5',
      category: ClinicalStatusCategory.surgical,
      severity: ClinicalSeverityLevel.normal,
      description: 'Fully expanded stent strut lattice with no in-stent restenosis or neointimal hyperplasia.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_cardio_holter',
        code: 'CAR-93224',
        name: '24-Hour Ambulatory Holter ECG Monitoring',
        standardFee: 350.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 6. DERMATOLOGY & SKIN
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _dermaStatuses = [
    ClinicalStatusDefinition(
      id: 'derma_clear',
      title: 'Clear Epidermis & Intact Skin Barrier',
      titleAr: 'بشرة نضرة وسليمة وحاجز جلدي متماسك بدون آفات',
      icd10Code: 'Z01.8',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Uniform pigmentation, intact stratum corneum, normal sebum production, and no lesions.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_derma_dermoscopy',
        code: 'DER-96900',
        name: 'Total Body Dermoscopic Examination & Mole Mapping',
        standardFee: 250.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'derma_melanoma',
      title: 'Suspicious Malignant Melanoma (ABCDE Positive)',
      titleAr: 'ورم ميلانوما خبيث مشبوه غير متناظر الحواف',
      icd10Code: 'C43.9',
      category: ClinicalStatusCategory.neoplasm,
      severity: ClinicalSeverityLevel.critical,
      description: 'Asymmetry, border irregularity, color variegation, diameter > 6 mm, and rapid evolution.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_derma_wide_excision',
        code: 'DER-11606',
        name: 'Wide Local Excision with 1 cm Margin & Histopathology',
        standardFee: 1400.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'derma_psoriasis_plaque',
      title: 'Active Plaque Psoriasis with Silvery Scale',
      titleAr: 'صدفية لويحية نشطة مع قشور فضية وتسمك جلدي',
      icd10Code: 'L40.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Erythematous plaques covered with silvery-white micaceous scales and positive Auspitz sign.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_derma_phototherapy',
        code: 'DER-96910',
        name: 'Narrowband Ultraviolet B (NB-UVB) Phototherapy Session',
        standardFee: 180.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'derma_keloid_scar',
      title: 'Hypertrophic Keloid Scar Tissue',
      titleAr: 'ندبة جدرية ضخامية متجاوزة حدود الجرح الأصلي',
      icd10Code: 'L91.0',
      category: ClinicalStatusCategory.neoplasm,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Dense fibrous overgrowth extending beyond boundaries of original surgical/traumatic wound.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_derma_steroid_inj',
        code: 'DER-11900',
        name: 'Intralesional Triamcinolone Acetonide (Kenacort) Injection',
        standardFee: 320.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'derma_cutaneous_burn',
      title: 'Second-Degree Deep Partial Thickness Burn',
      titleAr: 'حروق من الدرجة الثانية العميقة مع فقاعات جلدية',
      icd10Code: 'T30.0',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.severe,
      description: 'Blistering, wet pink-white dermis, severe pain, requiring strict sterile biological dressing.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_derma_burn_debridement',
        code: 'DER-16020',
        name: 'Burn Wound Debridement & Hydrogel Silver Dressing',
        standardFee: 480.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 7. DENTAL & ODONTOLOGY
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _dentalStatuses = [
    ClinicalStatusDefinition(
      id: 'dent_sound',
      title: 'Sound Natural Tooth & Intact Enamel',
      titleAr: 'سن سليم وطبيعي ومينا صلبة خالية من التسوس',
      icd10Code: 'Z01.2',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'No cavitation, healthy gingival margin, no mobility, and sound pulp vitality.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_dent_prophy',
        code: 'D1110',
        name: 'Dental Prophylaxis & Fluoride Varnish',
        standardFee: 150.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'dent_caries_deep',
      title: 'Deep Dentinal Caries Cavity (D3-D4)',
      titleAr: 'تسوس نخر عاجي عميق ملاصق للب العصب',
      icd10Code: 'K02.1',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Demineralization and bacterial destruction penetrating inner dentin near pulp chamber.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_dent_composite',
        code: 'D2392',
        name: 'Multi-Surface Resin-Based Composite Restoration',
        standardFee: 260.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'dent_pulpitis_irreversible',
      title: 'Acute Irreversible Pulpitis',
      titleAr: 'التهاب لب السن الحاد غير الردود مع ألم ليلي نابض',
      icd10Code: 'K04.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'Spontaneous throbbing pain lingering > 30s after thermal stimuli with pulp hyper-vascularization.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_dent_rct',
        code: 'D3330',
        name: 'Endodontic Root Canal Therapy (Molar 3 Canals)',
        standardFee: 1250.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'dent_periapical_abscess',
      title: 'Acute Periapical Abscess & Swelling',
      titleAr: 'خراج ذروي صديدي حاد وتورم بالدهليز اللثوي',
      icd10Code: 'K04.7',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.critical,
      description: 'Purulent accumulation at root apex with severe tenderness to percussion and facial swelling.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_dent_incision_drainage',
        code: 'D7510',
        name: 'Incision & Drainage of Abscess + Trephination',
        standardFee: 380.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'dent_fractured_tooth',
      title: 'Crown-Root Fracture with Exposed Pulp',
      titleAr: 'كسر التاج والجذر مع انكشاف لب السن',
      icd10Code: 'S02.5',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.severe,
      description: 'Oblique structural fracture line extending below cemento-enamel junction.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_dent_crown',
        code: 'D2740',
        name: 'Zirconia / Full Ceramic Crown with Core Build-Up',
        standardFee: 1800.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'dent_implant_integrated',
      title: 'Osseointegrated Titanium Dental Implant',
      titleAr: 'زرعة أسنان تيتانيوم مندمجة عظمياً بنجاح',
      icd10Code: 'Z96.5',
      category: ClinicalStatusCategory.surgical,
      severity: ClinicalSeverityLevel.normal,
      description: 'Rigid bone anchorage with no radiolucency around titanium fixture and healthy peri-implant tissue.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_dent_implant_crown',
        code: 'D6058',
        name: 'Screw-Retained Ceramic Crown Over Implant Abutment',
        standardFee: 2400.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 8. GENERAL MEDICINE, POLYCLINIC, ENT & NEUROLOGY
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _generalMedicineStatuses = [
    ClinicalStatusDefinition(
      id: 'gen_normal',
      title: 'Normal Clinical Baseline & Vital Organ Perfusion',
      titleAr: 'فحص سريري عام سليم وتروية أعضاء حيوية طبيعية',
      icd10Code: 'Z00.0',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'All system examinations within normal limits, no focal neurological or structural deficits.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gen_consultation',
        code: 'GEN-99213',
        name: 'Specialist Clinical Consultation & Review',
        standardFee: 150.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'gen_neuropathy',
      title: 'Peripheral Nerve Entrapment / Neuropathy',
      titleAr: 'انضغاط عصبي محيطي واعتلال الأعصاب الحسي الحركي',
      icd10Code: 'G56.0',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Paresthesia, numbness, reduced nerve conduction velocity, and Tinel / Phalen sign positive.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gen_emg',
        code: 'NEU-95907',
        name: 'Nerve Conduction Study (NCS) & Electromyography (EMG)',
        standardFee: 650.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'gen_otitis_media',
      title: 'Acute Suppurative Otitis Media with Bulging Drum',
      titleAr: 'التهاب الأذن الوسطى القيحي الحاد مع احتقان الطبلة',
      icd10Code: 'H66.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Hyperemic bulging tympanic membrane, loss of light reflex, and conductive hearing dampening.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gen_otoscopy',
        code: 'ENT-69210',
        name: 'Microscopic Ear Debridement & Tympanometry',
        standardFee: 250.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'gen_purulent_sinusitis',
      title: 'Acute Maxillary Sinusitis & Mucosal Blockage',
      titleAr: 'التهاب الجيوب الأنفية الصديدي الحاد واحتقان المخاط',
      icd10Code: 'J01.9',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Facial pressure, purulent nasal discharge, and mucosal thickening of the ostiomeatal complex.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_gen_nasal_endoscopy',
        code: 'ENT-31231',
        name: 'Diagnostic Rigid Nasal Endoscopy & Sinus Lavage',
        standardFee: 400.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 9. NEUROLOGY & NEUROSURGERY
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _neurologyStatuses = [
    ClinicalStatusDefinition(
      id: 'neuro_healthy',
      title: 'Normal Intracranial Architecture & Perfusion',
      titleAr: 'سليم، تروية قشرية ودماغية طبيعية بدون آفات شاغلة',
      icd10Code: 'Z01.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Symmetric cerebral hemispheres, intact ventricular system, and patent Circle of Willis.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_neuro_consult',
        code: 'NEU-99245',
        name: 'Comprehensive Neurological Evaluation & Cranial Nerve Exam',
        standardFee: 350.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'neuro_ischemic_stroke',
      title: 'Ischemic Stroke / Middle Cerebral Artery (MCA) Occlusion',
      titleAr: 'جلطة دماغية نقص تروية وانسداد الشريان المخي الأوسط',
      icd10Code: 'I63.5',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.critical,
      description: 'Acute cytotoxic edema with diffusion restriction in the MCA territory and penumbra mismatch.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_neuro_thrombectomy',
        code: 'NEU-61645',
        name: 'Mechanical Thrombectomy & Endovascular Recanalization',
        standardFee: 8500.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'neuro_glioma',
      title: 'High-Grade Glioma / Glioblastoma Multiforme (GBM)',
      titleAr: 'ورم دبقي خبيث في الفص الصدغي / الجبهي',
      icd10Code: 'C71.9',
      category: ClinicalStatusCategory.neoplastic,
      severity: ClinicalSeverityLevel.critical,
      description: 'Ring-enhancing intra-axial mass with central necrosis, surrounding vasogenic edema, and mass effect.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_neuro_craniotomy_tumor',
        code: 'NEU-61510',
        name: 'Neuronavigation-Guided Craniotomy & Maximum Safe Resection',
        standardFee: 12000.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'neuro_aneurysm',
      title: 'Intracranial Saccular Aneurysm (Circle of Willis)',
      titleAr: 'تمدد شرياني كيسي في حلقة ويليس الدماغية',
      icd10Code: 'I67.1',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.severe,
      description: 'Saccular outpouching at the anterior communicating or basilar bifurcation with rupture risk.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_neuro_coiling',
        code: 'NEU-61624',
        name: 'Endovascular Microcatheter Guglielmi Coiling',
        standardFee: 9500.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'neuro_parkinsons_dbs',
      title: 'Parkinson\'s Disease / Subthalamic Nucleus Target',
      titleAr: 'مرض باركنسون وتحديد مسار التحفيز العميق للمخ (DBS)',
      icd10Code: 'G20',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Levodopa-responsive motor fluctuations, rigidity, and resting tremor suitable for DBS.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_neuro_dbs',
        code: 'NEU-61867',
        name: 'Deep Brain Stimulation (DBS) Stereotactic Lead Implantation',
        standardFee: 11000.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 10. NEURO-OTOLOGY & BALANCE CLINICS
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _neuroOtologyStatuses = [
    ClinicalStatusDefinition(
      id: 'otol_healthy',
      title: 'Normal Vestibular Function & Semicircular Stability',
      titleAr: 'توازن دهليزي طبيعي وأعضاء صخرية سليمة',
      icd10Code: 'Z01.10',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Intact vestibulo-ocular reflex (VOR), symmetric caloric response, and stable postural equilibrium.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_otol_vng',
        code: 'OTO-92540',
        name: 'Videonystagmography (VNG) & Balance Evaluation',
        standardFee: 320.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'otol_bppv',
      title: 'BPPV / Posterior Canal Canalithiasis Displacement',
      titleAr: 'دوار الوضعة الانتيابي الحميد وإزاحة حصوات القناة الخلفية',
      icd10Code: 'H81.1',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Displaced calcium carbonate otoconia floating inside the posterior semicircular canal inducing vertigo.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_otol_epley',
        code: 'OTO-95992',
        name: 'Epley Particle Repositioning Maneuver',
        standardFee: 180.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'otol_menieres',
      title: 'Ménière\'s Disease / Endolymphatic Hydrops',
      titleAr: 'مرض مينيير والاستسقاء اللمفاوي الداخلي للأذن',
      icd10Code: 'H81.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'Fluctuating low-frequency sensorineural hearing loss, episodic rotational vertigo, and aural fullness.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_otol_it_steroid',
        code: 'OTO-69801',
        name: 'Intratympanic Dexamethasone Injection Perfusion',
        standardFee: 420.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'otol_cochlear_loss',
      title: 'Profound Sensorineural Hearing Loss (Cochlear Loss)',
      titleAr: 'فقدان سمع حسي عصبي شديد وترشيح زراعة القوقعة',
      icd10Code: 'H90.3',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.severe,
      description: 'Bilateral severe-to-profound loss with organ of Corti hair cell loss suitable for electrode fitting.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_otol_cochlear_implant',
        code: 'OTO-69930',
        name: 'Cochlear Implant Electrode Array Fitting & Implantation',
        standardFee: 14000.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 11. NEURO-PSYCHIATRY & TMS CLINICS
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _neuroPsychiatryStatuses = [
    ClinicalStatusDefinition(
      id: 'psych_healthy',
      title: 'Balanced Prefrontal & Limbic Functional Connectivity',
      titleAr: 'توازن سليم في شبكة الفص الجبهي والجهاز الحوفي',
      icd10Code: 'Z00.4',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Normal resting-state fMRI biomarkers, balanced DMN regulation, and absence of mood disruption.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_psych_eval',
        code: 'PSY-90792',
        name: 'Neuropsychiatric Diagnostic Interview & Biomarker Review',
        standardFee: 280.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'psych_trd_mdd',
      title: 'Treatment-Resistant Major Depression (Left DLPFC Target)',
      titleAr: 'اكتئاب رئيسي معند وتحديد موضع التحفيز المغناطيسي (TMS)',
      icd10Code: 'F33.2',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.severe,
      description: 'Hypoactive Left Dorsolateral Prefrontal Cortex (DLPFC) with treatment-resistant anhedonia.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_psych_tms_session',
        code: 'PSY-90868',
        name: 'Repetitive Transcranial Magnetic Stimulation (rTMS) Session',
        standardFee: 350.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'psych_ocd_cstc',
      title: 'Severe OCD / Hyperactive CSTC Loop',
      titleAr: 'وسواس قهري شديد وفرط نشاط دائرة القشرة المخططية المهادية',
      icd10Code: 'F42.2',
      category: ClinicalStatusCategory.functional,
      severity: ClinicalSeverityLevel.severe,
      description: 'Cortico-striato-thalamo-cortical circuit hyperconnectivity with intrusive distressing obsessions.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_psych_dtms',
        code: 'PSY-90869',
        name: 'Deep TMS (H7 Coil) for Refractory OCD',
        standardFee: 420.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'psych_bitemporal_ect',
      title: 'Catatonic / Psychotic Depression (ECT Vector Target)',
      titleAr: 'اكتئاب ذهاني / تخشبي وتحديد متجهات التخليج الكهربائي',
      icd10Code: 'F32.3',
      category: ClinicalStatusCategory.functional,
      severity: ClinicalSeverityLevel.critical,
      description: 'Life-threatening catatonic inhibition requiring urgent therapeutic seizure induction.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_psych_ect',
        code: 'PSY-90870',
        name: 'Electroconvulsive Therapy (ECT) Vector Mapping & Delivery',
        standardFee: 950.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 12. RHINOLOGY & SINUS CLINICS (ENT)
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _rhinologyStatuses = [
    ClinicalStatusDefinition(
      id: 'rhino_healthy',
      title: 'Patent Nasal Airway & Clear Sinuses',
      titleAr: 'مجرى هوائي أنفي سالك وجيوب هوائية نظيفة وخالية من المخاط',
      icd10Code: 'Z01.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Midline nasal septum, pink moist mucosal turbinates, and clear ostiomeatal complexes.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_rhino_naso',
        code: 'ENT-31231',
        name: 'Diagnostic Fiberoptic Nasal Endoscopy',
        standardFee: 220.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'rhino_deviated_septum',
      title: 'Severe Deviated Septum with Septal Spur',
      titleAr: 'انحراف حاجز أنفي حاد مع بروز عظمي وانسداد مجرى التنفس',
      icd10Code: 'J34.2',
      category: ClinicalStatusCategory.structural,
      severity: ClinicalSeverityLevel.moderate,
      description: 'C-shaped cartilaginous deflection abutting the inferior turbinate causing nasal obstruction.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_rhino_septoplasty',
        code: 'ENT-30520',
        name: 'Submucosal Septoplasty & Cartilage Reshaping',
        standardFee: 3200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'rhino_polyposis',
      title: 'Chronic Rhinosinusitis with Polyps (CRSwNP)',
      titleAr: 'التهاب الجيوب الأنفية المزمن مع اللحميات الأنفية السادة',
      icd10Code: 'J33.0',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'Bilateral translucent edematous mucosal polyps obstructing maxillary and ethmoid drainage pathways.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_rhino_fess',
        code: 'ENT-31267',
        name: 'Functional Endoscopic Sinus Surgery (FESS) & Debrider Resection',
        standardFee: 4800.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'rhino_sinus_ostial_stenosis',
      title: 'Frontal / Maxillary Sinus Ostial Stenosis',
      titleAr: 'تضيق فوهة الجيب الجبهي والفك وتجمع الإفرازات',
      icd10Code: 'J32.0',
      category: ClinicalStatusCategory.obstruction,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Recurrent ostial occlusion with persistent vacuum headaches and sinus pressure.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_rhino_balloon',
        code: 'ENT-31295',
        name: 'Balloon Sinuplasty Dilation of Maxillary/Frontal Ostium',
        standardFee: 3600.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 13. VEIN & VASCULAR CLINICS (PHLEBOLOGY)
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _vascularVeinStatuses = [
    ClinicalStatusDefinition(
      id: 'vasc_healthy',
      title: 'Patent Peripheral Vessels & Competent Venous Valves',
      titleAr: 'أوعية دموية محيطية سالكة وصمامات وريدية سليمة وذات كفاءة',
      icd10Code: 'Z01.810',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Brisk peripheral pulses, competent saphenofemoral junction, and no venous reflux.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_vasc_duplex',
        code: 'VAS-93970',
        name: 'Complete Lower Extremity Venous Duplex Ultrasound',
        standardFee: 380.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'vasc_gsv_reflux',
      title: 'Great Saphenous Vein Reflux & Varicose Trunks (CEAP C3/C4)',
      titleAr: 'قصور وريدي وارتجاع الوريد الصافن الكبير مع دوالي الساقين',
      icd10Code: 'I83.9',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.severe,
      description: 'Retrograde reflux > 500ms at the saphenofemoral junction with venous hypertension and stasis.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_vasc_evla',
        code: 'VAS-36475',
        name: 'Endovenous Laser Ablation (EVLA) of Great Saphenous Vein',
        standardFee: 4200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'vasc_spider_veins',
      title: 'Telangiectasias & Reticular Vein Clusters (CEAP C1)',
      titleAr: 'الشعيرات الدموية العنكبوتية والأوردة الشبكية السطحية',
      icd10Code: 'I83.90',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.mild,
      description: 'Superficial intradermal venules < 3mm suitable for aesthetic chemical polidocanol ablation.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_vasc_sclero',
        code: 'VAS-36471',
        name: 'Ultrasound-Guided Foam Sclerotherapy Session',
        standardFee: 650.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'vasc_dvt',
      title: 'Acute Deep Vein Thrombosis (Femoro-Popliteal DVT)',
      titleAr: 'خثرة وريدية عميقة حادة في الوريد الفخذي / المأبضي',
      icd10Code: 'I82.40',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.critical,
      description: 'Non-compressible hypoechoic intraluminal thrombus with absent flow Doppler signal.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_vasc_thrombectomy',
        code: 'VAS-37184',
        name: 'Catheter-Directed Thrombolysis & IVC Filter Insertion',
        standardFee: 7800.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 14. PULMONOLOGY & RESPIRATORY CLINICS
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _pulmonologyStatuses = [
    ClinicalStatusDefinition(
      id: 'pulm_healthy',
      title: 'Clear Tracheobronchial Tree & Normal Ventilation',
      titleAr: 'شجرة تنفسية سالكة وتهوية سنخية طبيعية بدون تضيق',
      icd10Code: 'Z01.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Symmetric vesicular breath sounds, FEV1/FVC ratio > 0.75, and absence of consolidation.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pulm_pft',
        code: 'PUL-94010',
        name: 'Complete Pulmonary Function Test (Spirometry & DLCO)',
        standardFee: 310.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pulm_ebus_mediastinal_node',
      title: 'Mediastinal Lymphadenopathy (EBUS-TBNA Target)',
      titleAr: 'تضخم العقد اللمفاوية المنصفية وخزعة السونار الرئوي (EBUS)',
      icd10Code: 'R59.0',
      category: ClinicalStatusCategory.neoplastic,
      severity: ClinicalSeverityLevel.severe,
      description: 'Enlarged subcarinal (Station 7) or paratracheal lymph node requiring ultrasound needle aspiration.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pulm_ebus',
        code: 'PUL-31652',
        name: 'Endobronchial Ultrasound (EBUS) Guided Transbronchial Biopsy',
        standardFee: 3800.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pulm_asthma_remodeling',
      title: 'Severe Refractory Asthma & Smooth Muscle Hypertrophy',
      titleAr: 'ربو قصبي حاد معيد مع تضخم العضلات الملساء بالقصبات',
      icd10Code: 'J45.5',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'Chronic airway remodeling with refractory bronchospasm, mucus plugging, and frequent flares.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pulm_thermoplasty',
        code: 'PUL-31660',
        name: 'Bronchial Thermoplasty Radiofrequency Delivery',
        standardFee: 4900.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pulm_pleural_effusion',
      title: 'Large Exudative Pleural Effusion / Empyema',
      titleAr: 'انصباب بلوري ارتشاحي كبير وتجمع سوائل حول الرئة',
      icd10Code: 'J90',
      category: ClinicalStatusCategory.fluid,
      severity: ClinicalSeverityLevel.severe,
      description: 'Dependent fluid collection blunting costophrenic angles with compressive lung atelectasis.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pulm_chest_tube',
        code: 'PUL-32556',
        name: 'Pigtail Catheter / Chest Tube Insertion & Drainage',
        standardFee: 1100.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 15. ENDOCRINOLOGY CLINICS
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _endocrinologyStatuses = [
    ClinicalStatusDefinition(
      id: 'endo_healthy',
      title: 'Normal Endocrine Axis & Euthyroid Volume',
      titleAr: 'محور غددي وهرموني سليم وحجم درقي متناسق',
      icd10Code: 'Z01.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Homogeneous thyroid parenchyma, normal pituitary fossa, and unremarkable adrenal glands.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_endo_eval',
        code: 'END-99214',
        name: 'Comprehensive Endocrine Evaluation & Thyroid Sonogram',
        standardFee: 290.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'endo_tirads_nodule',
      title: 'Suspicious Thyroid Nodule (EU-TIRADS 5)',
      titleAr: 'عقدة درقية مشبوهة بتصنيف تيرادز 5 وسحب خزعة إبرية',
      icd10Code: 'E04.1',
      category: ClinicalStatusCategory.neoplastic,
      severity: ClinicalSeverityLevel.severe,
      description: 'Hypoechoic solid nodule with microcalcifications, taller-than-wide shape, and irregular margins.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_endo_fna',
        code: 'END-10021',
        name: 'Ultrasound-Guided Thyroid Fine Needle Aspiration (FNA)',
        standardFee: 750.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'endo_parathyroid_adenoma',
      title: 'Primary Hyperparathyroidism / Solitary Adenoma',
      titleAr: 'ورم غدي في الغدة جار الدرقية وفرط إفراز الكالسيوم',
      icd10Code: 'E21.0',
      category: ClinicalStatusCategory.neoplastic,
      severity: ClinicalSeverityLevel.severe,
      description: 'Hypervascular inferior parathyroid mass with elevated serum intact PTH and ionized hypercalcemia.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_endo_sestamibi',
        code: 'END-78070',
        name: 'Tc-99m Sestamibi Parathyroid SPECT/CT Mapping',
        standardFee: 1600.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'endo_adrenal_incidentaloma',
      title: 'Adrenal Cortical Adenoma / Incidentaloma',
      titleAr: 'ورم غدي في قشرة الكظر بحاجة لتقييم إفرازي واستئصال',
      icd10Code: 'D35.0',
      category: ClinicalStatusCategory.neoplastic,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Well-circumscribed lipid-rich adrenal cortical mass requiring hormonal rule-out protocol.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_endo_adrenal_ct',
        code: 'END-74170',
        name: 'Adrenal Protocol Triple-Phase CT Washout Scan',
        standardFee: 980.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 16. UROLOGY & MEN\'S HEALTH CLINICS
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _urologyStatuses = [
    ClinicalStatusDefinition(
      id: 'uro_healthy',
      title: 'Normal Renal Parenchyma & Unobstructed Urinary Tract',
      titleAr: 'جهاز بولي متناسق وتروية كلوية سليمة ومثانة مفرغة',
      icd10Code: 'Z01.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Smooth renal contours, no hydronephrosis, thin bladder wall, and normal prostate transition zone.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_uro_us',
        code: 'URO-76770',
        name: 'Complete Urological Ultrasound (KUB & Post-Void Residual)',
        standardFee: 310.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'uro_renal_calculus',
      title: 'Renal Pelvic Calculus / Obstructing Ureteral Stone',
      titleAr: 'حصوة حوض الكلى والحالب السادة مع تضخم حويضي',
      icd10Code: 'N20.0',
      category: ClinicalStatusCategory.obstruction,
      severity: ClinicalSeverityLevel.severe,
      description: 'Dense 12mm calcium oxalate stone in the upper ureter inducing acute hydroureteronephrosis.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_uro_lithotripsy',
        code: 'URO-52356',
        name: 'Ureteroscopy & Holmium Laser Lithotripsy with Double-J Stent',
        standardFee: 4600.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'uro_prostate_cancer_target',
      title: 'Prostate Carcinoma / PI-RADS 4/5 Peripheral Zone Lesion',
      titleAr: 'اشتباه ورم البروستاتا في المنطقة المحيطية وخزعة مدمجة',
      icd10Code: 'C61',
      category: ClinicalStatusCategory.neoplastic,
      severity: ClinicalSeverityLevel.critical,
      description: 'Focal restricted diffusion and hypointense T2 lesion in the right posterior peripheral zone.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_uro_fusion_biopsy',
        code: 'URO-55706',
        name: 'MRI-Transrectal Ultrasound (TRUS) Fusion Prostate Biopsy',
        standardFee: 3900.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'uro_bph_enlargement',
      title: 'Benign Prostatic Hyperplasia (BPH) with Bladder Trabeculation',
      titleAr: 'تضخم البروستاتا الحميد وتثخن جدار المثانة وانحباس البول',
      icd10Code: 'N40.1',
      category: ClinicalStatusCategory.hypertrophy,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Prostate volume > 65cc with median lobe intravesical protrusion and elevated post-void residual.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_uro_holep',
        code: 'URO-52648',
        name: 'Laser Enucleation of Prostate (HoLEP / GreenLight Vaporization)',
        standardFee: 5800.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 17. OBSTETRICS, GYNECOLOGY & FERTILITY (REI)
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _obGynStatuses = [
    ClinicalStatusDefinition(
      id: 'obgyn_healthy',
      title: 'Normal Pelvic Anatomy & Receptive Endometrium',
      titleAr: 'أعضاء حوضية سليمة، بطانة رحمية طبيعية ومبايض نشطة',
      icd10Code: 'Z01.419',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Trilaminar endometrium, bilateral normal follicular reserve, and patent fallopian tubes.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_obgyn_tvs',
        code: 'OBG-76830',
        name: 'Transvaginal Pelvic Ultrasound & Folliculometry',
        standardFee: 260.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'obgyn_uterine_fibroid',
      title: 'Symptomatic Uterine Leiomyoma (FIGO Type 2-5)',
      titleAr: 'ألياف رحمية عضلية مسببة للنزيف (تصنيف فيغو)',
      icd10Code: 'D25.1',
      category: ClinicalStatusCategory.neoplastic,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Submucosal / Intramural fibrous tumor distorting endometrial cavity and causing menorrhagia.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_obgyn_myomectomy',
        code: 'OBG-58140',
        name: 'Hysteroscopic / Laparoscopic Myomectomy Resection',
        standardFee: 5200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'obgyn_endometrioma',
      title: 'Deep Infiltrating Endometriosis & Chocolate Cyst',
      titleAr: 'بطانة الرحم المهاجرة وكيس دموي مبيضي ملتصق',
      icd10Code: 'N80.1',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'Ground-glass appearance ovarian endometrioma with pelvic adhesions and dysmenorrhea.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_obgyn_endo_excision',
        code: 'OBG-58662',
        name: 'Laparoscopic Excision of Endometriosis & Adhesiolysis',
        standardFee: 6100.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'obgyn_iui_ivf_transfer',
      title: 'Assisted Reproduction / Embryo Transfer Path Planning',
      titleAr: 'تخطيط مسار قسطرة نقل الأجنة أو الحقن داخل الرحم (IUI/IVF)',
      icd10Code: 'Z31.83',
      category: ClinicalStatusCategory.procedural,
      severity: ClinicalSeverityLevel.normal,
      description: 'Cervical angle alignment and endometrial midpoint localization for atraumatic catheter landing.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_obgyn_transfer',
        code: 'OBG-58974',
        name: 'Ultrasound-Guided Embryo Transfer / IUI Insemination',
        standardFee: 2100.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 18. PODIATRY & ORTHOTICS (P&O)
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _podiatryStatuses = [
    ClinicalStatusDefinition(
      id: 'pod_healthy',
      title: 'Neutral Foot Biomechanics & Preserved Plantar Arch',
      titleAr: 'ميكانيكا قدم محايدة، تقوس سليم وتوزيع ضغط متوازن',
      icd10Code: 'Z01.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Neutral subtalar alignment, absence of hyperpronation, and intact plantar tactile sensation.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pod_biomech',
        code: 'POD-97750',
        name: 'Computerized Plantar Pressure & Dynamic Gait Analysis',
        standardFee: 220.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pod_plantar_fasciitis',
      title: 'Chronic Plantar Fasciitis & Calcaneal Enthesophyte',
      titleAr: 'التهاب اللفافة الأخمصية المزمن مع نتوء عظمي بالكعب',
      icd10Code: 'M72.2',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Fascial thickening > 4.5mm at the medial calcaneal tuberosity with morning startup pain.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pod_eswt',
        code: 'POD-0101T',
        name: 'Extracorporeal Shockwave Therapy (ESWT) & Orthotic Fitting',
        standardFee: 480.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pod_hallux_valgus',
      title: 'Hallux Valgus Bunion Deformity (> 30° IMA)',
      titleAr: 'انحراف إبهام القدم للخارج (الوكنة) مع ألم احتكاك العظم',
      icd10Code: 'M20.1',
      category: ClinicalStatusCategory.structural,
      severity: ClinicalSeverityLevel.severe,
      description: 'Medial prominence of first metatarsal head with lateral hallux drift and bunion bursitis.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pod_osteotomy',
        code: 'POD-28296',
        name: 'Distal Chevron / Scarf Metatarsal Osteotomy & Screw Fixation',
        standardFee: 3800.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pod_diabetic_ulcer',
      title: 'Diabetic Neuropathic Forefoot Ulcer (Wagner Grade 2)',
      titleAr: 'قرحة سكرية عصبية في باطن القدم مع فقدان الإحساس',
      icd10Code: 'E11.621',
      category: ClinicalStatusCategory.ulcerative,
      severity: ClinicalSeverityLevel.critical,
      description: 'Deep plantar punch defect exposing subcutaneous fat without osteomyelitis; needs offloading.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pod_debride_tcc',
        code: 'POD-11042',
        name: 'Surgical Debridement & Total Contact Cast (TCC) Offloading',
        standardFee: 890.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 19. COSMETIC PLASTIC SURGERY
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _plasticSurgeryStatuses = [
    ClinicalStatusDefinition(
      id: 'plast_healthy',
      title: 'Normal Craniofacial Symmetry & Skin Elasticity',
      titleAr: 'تناسق وجهي وجسماني طبيعي ومرونة أنسجة سليمة',
      icd10Code: 'Z41.1',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Youthful golden ratio proportions, minimal skin ptosis, and well-distributed adipose volume.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_plast_consult',
        code: 'PLS-99204',
        name: 'Comprehensive Plastic & Aesthetic 3D Vector Consultation',
        standardFee: 350.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'plast_rhinoplasty_hump',
      title: 'Dorsal Cartilaginous/Bony Hump & Bulbous Tip',
      titleAr: 'حدبة الأنف العظمية الغضروفية وتضخم الأرنبة',
      icd10Code: 'M95.0',
      category: ClinicalStatusCategory.structural,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Prominent dorsal osteocartilaginous vault requiring rasping, spreader grafts, and tip plasty.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_plast_rhino',
        code: 'PLS-30410',
        name: 'Open Structure Preservation Rhinoplasty with Cartilage Grafting',
        standardFee: 7800.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'plast_smas_ptosis',
      title: 'Midface & Cervicomental SMAS Ptosis (Facelift Target)',
      titleAr: 'ترهل طبقة سماص الوجهية والفكية وحاجة لشد جراحي',
      icd10Code: 'L98.5',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.severe,
      description: 'Blunting of jawline contours, deep nasolabial folds, and platysmal bands.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_plast_facelift',
        code: 'PLS-15824',
        name: 'Deep-Plane / High-SMAS Rhytidectomy & Platysmaplasty',
        standardFee: 14500.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'plast_breast_hypoplasia',
      title: 'Mammary Hypoplasia / Post-Pregnancy Volume Loss',
      titleAr: 'صغر أو ضمور الثدي بعد الرضاعة وحاجة للتكبير بالحشوات',
      icd10Code: 'N64.8',
      category: ClinicalStatusCategory.structural,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Deficient upper pole projection suitable for sub-pectoral silicone cohesive gel implant.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_plast_breast_aug',
        code: 'PLS-19325',
        name: 'Dual-Plane Cohesive Silicone Breast Augmentation',
        standardFee: 9200.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 20. MEDICAL AESTHETICS (INJECTORS)
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _medicalAestheticsStatuses = [
    ClinicalStatusDefinition(
      id: 'aes_healthy',
      title: 'Optimal Facial Volume & Dynamic Line Balance',
      titleAr: 'توزيع دهني متناسق وخطوط تعبيرية مرنة بدون تجاعيد ثقيلة',
      icd10Code: 'Z41.1',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Well-supported malar fat pads, smooth periorbital transition, and no vascular compromise.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_aes_skin_booster',
        code: 'AES-11900',
        name: 'Hyaluronic Acid Skin Booster Micro-Injections',
        standardFee: 450.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'aes_glabellar_lines',
      title: 'Hyperkinetic Glabellar & Frontalis Lines (Botox Target)',
      titleAr: 'تجاعيد الجبهة وما بين الحاجبين الحركية (حقن البوتوكس)',
      icd10Code: 'L90.8',
      category: ClinicalStatusCategory.functional,
      severity: ClinicalSeverityLevel.mild,
      description: 'Overactive corrugator supercilii and procerus creating deep furrowing during concentration.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_aes_botox',
        code: 'AES-J0585',
        name: 'Botulinum Neurotoxin Type A (50 Units 3-Zone Mapping)',
        standardFee: 600.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'aes_malar_volume_loss',
      title: 'Malar & Submalar Volume Deficit (Filler Target)',
      titleAr: 'ضمور وسائد الخدين وتجويف تحت العين (حقن الفيلر العميق)',
      icd10Code: 'L98.5',
      category: ClinicalStatusCategory.structural,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Hollowing of zygomatic arch requiring supra-periosteal bolus of high G-prime hyaluronic acid.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_aes_filler',
        code: 'AES-11951',
        name: 'Cross-Linked Hyaluronic Acid Dermal Filler (2 Syringes)',
        standardFee: 1200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'aes_danger_zone_occlusion',
      title: 'Vascular Danger Zone / Impending Occlusion Protocol',
      titleAr: 'منطقة خطر شرياني (الشريان الوجهي/الزاوي) وإذابة بالهيالورونيداز',
      icd10Code: 'T81.7',
      category: ClinicalStatusCategory.vascular,
      severity: ClinicalSeverityLevel.critical,
      description: 'Blanching, livedo reticularis, or severe pain indicating accidental intra-arterial filler injection.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_aes_hyaluronidase',
        code: 'AES-J3470',
        name: 'Emergency High-Dose Hyaluronidase Infiltration Protocol',
        standardFee: 900.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 21. INTERVENTIONAL PAIN MANAGEMENT
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _painManagementStatuses = [
    ClinicalStatusDefinition(
      id: 'pain_healthy',
      title: 'Spinal Alignment Normal & Pain-Free Segmental ROM',
      titleAr: 'محاذاة فقرية طبيعية وخالية من الانضغاطات العصبية',
      icd10Code: 'Z01.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Preserved disc heights, patent neural foramina, and absence of radicular irritative signs.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pain_eval',
        code: 'PAI-99214',
        name: 'Interventional Pain Mapping & Neurological Review',
        standardFee: 280.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pain_lumbar_radiculopathy',
      title: 'L4-L5 Lumbar Radiculopathy / Disc Herniation',
      titleAr: 'انزلاق غضروفي قطني L4-L5 مع اعتلال الجذور العصبية',
      icd10Code: 'M54.16',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.severe,
      description: 'Paracentral disc extrusion compressing the exiting L5 nerve root causing sciatica.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pain_transforaminal',
        code: 'PAI-64483',
        name: 'Fluoroscopy-Guided Transforaminal Epidural Steroid Injection',
        standardFee: 1400.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pain_facet_arthropathy',
      title: 'Lumbar / Cervical Facet Arthropathy (RFA Target)',
      titleAr: 'خشونة المفاصل الفقرية الوجيهية والكي بالتردد الحراري',
      icd10Code: 'M47.817',
      category: ClinicalStatusCategory.degenerative,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Hypertrophic facet joints with axial lumbar extension pain, relieved by medial branch blocks.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pain_rfa',
        code: 'PAI-64635',
        name: 'Radiofrequency Ablation (RFA) Medial Branch Neurotomy',
        standardFee: 3200.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'pain_failed_back_scs',
      title: 'Failed Back Surgery Syndrome / Chronic Intractable Pain',
      titleAr: 'متلازمة آلام الظهر المزمنة وزراعة محفز النخاع الشوكي',
      icd10Code: 'M96.1',
      category: ClinicalStatusCategory.intractable,
      severity: ClinicalSeverityLevel.critical,
      description: 'Post-laminectomy epidural fibrosis with intractable neuropathic pain refractory to interventions.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_pain_scs_trial',
        code: 'PAI-63650',
        name: 'Percutaneous Spinal Cord Stimulation (SCS) Lead Implantation',
        standardFee: 8900.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 22. ACUPUNCTURE & EASTERN MEDICINE CLINICS
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _acupunctureStatuses = [
    ClinicalStatusDefinition(
      id: 'acu_healthy',
      title: 'Balanced Qi & Harmonious Meridian Flow',
      titleAr: 'توازن طاقة التشي وتدفق متناغم في مسارات الوخز بالإبر',
      icd10Code: 'Z00.0',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Symmetric radial pulses, tongue coat pink and moist, and unblocked meridian flow.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_acu_baseline',
        code: 'ACU-97810',
        name: 'Traditional Meridian Pulse & Tongue Diagnosis',
        standardFee: 160.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'acu_meridian_stagnation',
      title: 'Liver Qi Stagnation & Trigger Point Myofascial Knot',
      titleAr: 'ركود مسار الكبد وعقد عضلية ليفية بحاجة للوخز الجاف',
      icd10Code: 'M79.1',
      category: ClinicalStatusCategory.functional,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Hyperirritable taut bands in the trapezius and rhomboids with stress-related tension headaches.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_acu_needling',
        code: 'ACU-97811',
        name: 'Electro-Acupuncture & Myofascial Trigger Point Needling',
        standardFee: 240.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'acu_pneumothorax_danger_zone',
      title: 'Apical Danger Zone Check (GB21 / Feishu BL13)',
      titleAr: 'فحص أمان عمق الإبرة فوق قمة الرئة لتفادي الاسترواح الصدري',
      icd10Code: 'Z79.89',
      category: ClinicalStatusCategory.procedural,
      severity: ClinicalSeverityLevel.severe,
      description: 'High-risk anatomical area overlying lung apex requiring oblique shallow needle angulation.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_acu_safety_scan',
        code: 'ACU-76998',
        name: 'Ultrasound Depth Confirmation for High-Risk Acupoints',
        standardFee: 190.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'acu_meridian_heat_deficiency',
      title: 'Cold Dampness Obstruction / Bi Syndrome',
      titleAr: 'متلازمة البرودة والرطوبة في المفاصل وعلاج الموكسا',
      icd10Code: 'M25.50',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Aching joint stiffness worsening with cold, relieved by thermal moxibustion stimulation.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_acu_moxa',
        code: 'ACU-97813',
        name: 'Direct Moxibustion & Heated Needle Meridian Therapy',
        standardFee: 220.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 23. SPEECH-LANGUAGE PATHOLOGY (SLP)
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _speechPathologyStatuses = [
    ClinicalStatusDefinition(
      id: 'slp_healthy',
      title: 'Normal Vocal Fold Mucosal Wave & Safe Deglutition',
      titleAr: 'اهتزاز مخاطي طبيعي للحبال الصوتية وبلع آمن وسليم',
      icd10Code: 'Z01.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Symmetric bilateral cord adduction, clear glottic closure, and rapid airway protection during swallow.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_slp_eval',
        code: 'SLP-92523',
        name: 'Comprehensive Voice & Motor Speech Acoustic Analysis',
        standardFee: 260.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'slp_dysphagia_aspiration',
      title: 'Oropharyngeal Dysphagia with Laryngeal Penetration / Aspiration',
      titleAr: 'عسر بلع بلعومي مع تسرب السوائل لمجرى التنفس والقصبة',
      icd10Code: 'R13.12',
      category: ClinicalStatusCategory.functional,
      severity: ClinicalSeverityLevel.critical,
      description: 'Vallecular pooling with delayed swallow trigger and silent aspiration below the true vocal cords.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_slp_fees',
        code: 'SLP-92612',
        name: 'Fiberoptic Endoscopic Evaluation of Swallowing (FEES)',
        standardFee: 650.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'slp_vocal_nodules',
      title: 'Bilateral Vocal Cord Nodules (Screamer\'s Nodes)',
      titleAr: 'عقيدات الحبال الصوتية الثنائية وبحة الصوت الإجهادية',
      icd10Code: 'J38.2',
      category: ClinicalStatusCategory.structural,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Fibrotic thickening at the junction of the anterior one-third and posterior two-thirds of cords.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_slp_stroboscopy',
        code: 'SLP-31579',
        name: 'Videostroboscopy & Vocal Fold Rehabilitation Therapy',
        standardFee: 450.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'slp_velopharyngeal_incompetence',
      title: 'Velopharyngeal Incompetence & Hypernasality',
      titleAr: 'قصور الصمام اللهاتي البلعومي والرنين الأنفي المرضي',
      icd10Code: 'Q38.5',
      category: ClinicalStatusCategory.structural,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Incomplete soft palate seal during phonation causing air escape and speech intelligibility loss.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_slp_nasometry',
        code: 'SLP-92520',
        name: 'Nasometry & Palatal Elevation Biofeedback Training',
        standardFee: 310.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 23. VETERINARY MEDICINE & SURGERY
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _veterinaryStatuses = [
    ClinicalStatusDefinition(
      id: 'vet_healthy',
      title: 'Healthy Pet / Wellness Exam',
      titleAr: 'فحص صحة ووقاية دورية للحيوان الأليف',
      icd10Code: 'Z00.0',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Alert, responsive, hydrated, clear eyes/ears, normal heart and lung sounds.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_vet_wellness',
        code: 'VET-99201',
        name: 'Comprehensive Veterinary Wellness Examination',
        standardFee: 150.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'vet_rabies',
      title: 'Rabies Core Vaccination Required',
      titleAr: 'تطعيم داء الكلب الأساسي مستحق',
      icd10Code: 'Z23',
      category: ClinicalStatusCategory.procedural,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Annual or 3-year core rabies immunization with certificate registration.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_vet_rabies_shot',
        code: 'VET-90710',
        name: 'Rabies Inactivated Vaccine Administration',
        standardFee: 220.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'vet_fracture',
      title: 'Canine Femur / Humeral Fracture',
      titleAr: 'كسر عظم الفخذ أو العضد للكلب',
      icd10Code: 'S72.0',
      category: ClinicalStatusCategory.trauma,
      severity: ClinicalSeverityLevel.severe,
      description: 'Acute lameness, crepitus, and pain on limb manipulation requiring internal fixation.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_vet_ortho_plating',
        code: 'VET-27236',
        name: 'Open Reduction & Internal Plating (ORIF)',
        standardFee: 1800.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 24. DIAGNOSTIC LAB & PATHOLOGY
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _diagnosticLabStatuses = [
    ClinicalStatusDefinition(
      id: 'lab_normal_cbc',
      title: 'Normal Hemogram / Complete Blood Count',
      titleAr: 'تعداد دم كامل طبيعي ومستقر',
      icd10Code: 'Z01.7',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Normocytic, normochromic erythrocytes, normal leukocyte and platelet indices.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_lab_cbc',
        code: 'LAB-85025',
        name: 'Complete Blood Count (CBC) with Automated Differential',
        standardFee: 120.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'lab_leukocytosis',
      title: 'Severe Leukocytosis & Band Shift',
      titleAr: 'ارتفاع كريات الدم البيضاء الحاد وانحراف عصوي',
      icd10Code: 'D72.8',
      category: ClinicalStatusCategory.inflammation,
      severity: ClinicalSeverityLevel.severe,
      description: 'WBC > 25,000/µL with toxic granulation indicating severe systemic infection.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_lab_smear_review',
        code: 'LAB-85060',
        name: 'Manual Peripheral Blood Smear Examination by Pathologist',
        standardFee: 250.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'lab_margin_clear',
      title: 'Clear Surgical Resection Margin (> 2mm)',
      titleAr: 'حد أمان جراحي سليم وخالٍ من الخلايا الخبيثة',
      icd10Code: 'Z03.89',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Surgical specimen margins microscopically evaluated with ink staining and no atypia.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_lab_pathology_biopsy',
        code: 'LAB-88305',
        name: 'Surgical Pathology Gross & Microscopic Biopsy Review',
        standardFee: 650.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 25. MENTAL HEALTH & BEHAVIORAL COUNSELING
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _mentalHealthStatuses = [
    ClinicalStatusDefinition(
      id: 'mental_healthy',
      title: 'Stable Affect / Resilient Coping',
      titleAr: 'حالة وجدانية مستقرة وتوافق نفسي متوازن',
      icd10Code: 'Z00.4',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Normal euthymic mood, coherent thought processes, and intact executive control.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_mental_baseline',
        code: 'PSY-90791',
        name: 'Comprehensive Psychiatric & Behavioral Diagnostic Evaluation',
        standardFee: 250.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'mental_mdd',
      title: 'Major Depressive Episode (Moderate/Severe)',
      titleAr: 'نوبة اكتئاب جسيمة متوسطة إلى شديدة',
      icd10Code: 'F32.2',
      category: ClinicalStatusCategory.functional,
      severity: ClinicalSeverityLevel.severe,
      description: 'Depressed mood, anhedonia, sleep disturbance, PHQ-9 >= 15 requiring structured CBT.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_mental_cbt',
        code: 'PSY-90834',
        name: 'Cognitive Behavioral Psychotherapy (45 Minutes)',
        standardFee: 450.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'mental_gad',
      title: 'Generalized Anxiety Disorder (GAD-7 >= 12)',
      titleAr: 'اضطراب القلق العام المستمر والشديد',
      icd10Code: 'F41.1',
      category: ClinicalStatusCategory.functional,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Excessive uncontrollable worry, muscle tension, restlessness, and hyperarousal.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_mental_anxiety_intervention',
        code: 'PSY-90837',
        name: 'In-Depth Psychotherapy & Emotional Regulation Training',
        standardFee: 500.0,
      ),
    ),
  ];

  // ──────────────────────────────────────────────────────────────────────────
  // 26. PEDIATRICS & CHILD DEVELOPMENT
  // ──────────────────────────────────────────────────────────────────────────
  static const List<ClinicalStatusDefinition> _pediatricStatuses = [
    ClinicalStatusDefinition(
      id: 'peds_well_child',
      title: 'Well-Child Checkup & Normal Milestones',
      titleAr: 'فحص الطفل السليم وتحقيق المعالم النمائية',
      icd10Code: 'Z00.129',
      category: ClinicalStatusCategory.healthy,
      severity: ClinicalSeverityLevel.normal,
      description: 'Normal age-appropriate gross motor, speech, and WHO percentile growth trajectories.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_peds_checkup',
        code: 'PED-99382',
        name: 'Well-Child Preventive Visit (Age 1-4 Years)',
        standardFee: 180.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'peds_fontanelle_bulging',
      title: 'Bulging Anterior Fontanelle / Increased ICP',
      titleAr: 'انتفاخ اليافوخ الأمامي وارتفاع ضغط داخل القحف',
      icd10Code: 'G93.2',
      category: ClinicalStatusCategory.fluid,
      severity: ClinicalSeverityLevel.severe,
      description: 'Tense, bulging fontanelle at rest indicating urgent pediatric neuro-evaluation.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_peds_cranial_us',
        code: 'PED-76506',
        name: 'Transfontanelle Cranial Ultrasound Examination',
        standardFee: 550.0,
      ),
    ),
    ClinicalStatusDefinition(
      id: 'peds_early_caries',
      title: 'Early Childhood Caries (Deciduous Dentition)',
      titleAr: 'تسوس الأسنان اللبنية المبكر للرضع والأطفال',
      icd10Code: 'K02.9',
      category: ClinicalStatusCategory.structural,
      severity: ClinicalSeverityLevel.moderate,
      description: 'Demineralization and enamel cavitation on primary maxillary incisors.',
      suggestedProcedure: ProcedureItem(
        id: 'proc_peds_fluoride_varnish',
        code: 'PED-D1206',
        name: 'Topical Pediatric Fluoride Varnish & Sealant Application',
        standardFee: 140.0,
      ),
    ),
  ];
}
