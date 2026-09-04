import 'dart:ui';
import 'procedure_item.dart';
export 'procedure_item.dart';

enum SpecialtyPracticeVertical {
  clinic,
  dentalClinic,
  optometryClinic,
  physiotherapyRehab,
  veterinaryClinic,
}

enum AnatomicalPathologyType {
  // Orthopedic & Skeletal
  transverseFracture,
  compoundFracture,
  amputationTruncation, // Straight cut-line with stump rendering
  boneGraft,
  internalFixationPlate,
  jointDislocation,
  osteophyteSpur,

  // Dental & Odontology
  cariesCavity, // Surface-specific (O, M, D, B, L)
  rootCanalTreated,
  fullCeramicCrown,
  implantPost,
  horizontalRootFracture, // Cut-line across root
  periapicalAbscess,
  extractedMissing,

  // Ophthalmology / Optometry
  cornealAbrasion,
  cataractNuclearSclerosis,
  retinalTearOrDetachment, // Interactive boundary tracing
  vitreousHemorrhage,
  pterygiumGrowth,

  // Dermatology & Mannequin Triage
  incisionalWound, // Linear cut with length/depth annotation
  burnDegreeZone, // Area polygon fill (1st, 2nd, 3rd degree)
  lacerationSutured,
  subcutaneousHematoma,

  // Cardiology & Vascular
  stenosisOcclusion, // Percentage slider (e.g., 75% LAD occlusion)
  aneurysmDilation,
  stentPlacement,
}

class CutPlaneAnnotation {
  final Offset startNormalized; // 0.0 to 1.0 screen coordinates
  final Offset endNormalized;
  final double angleRadians;
  final String label;

  const CutPlaneAnnotation({
    required this.startNormalized,
    required this.endNormalized,
    required this.angleRadians,
    this.label = 'Truncation / Osteotomy Line',
  });

  Map<String, dynamic> toJson() => {
        'startX': startNormalized.dx,
        'startY': startNormalized.dy,
        'endX': endNormalized.dx,
        'endY': endNormalized.dy,
        'angleRadians': angleRadians,
        'label': label,
      };

  factory CutPlaneAnnotation.fromJson(Map<String, dynamic> json) {
    return CutPlaneAnnotation(
      startNormalized: Offset(
        (json['startX'] as num).toDouble(),
        (json['startY'] as num).toDouble(),
      ),
      endNormalized: Offset(
        (json['endX'] as num).toDouble(),
        (json['endY'] as num).toDouble(),
      ),
      angleRadians: (json['angleRadians'] as num).toDouble(),
      label: json['label'] as String? ?? 'Truncation / Osteotomy Line',
    );
  }
}

class AnatomicalConditionPayload {
  final AnatomicalPathologyType pathology;
  final double severityScore; // 0.0 to 1.0 (or percentage like 70% occlusion)
  final CutPlaneAnnotation? cutPlane; // For amputations, fractures, osteotomies
  final List<Offset> surfaceContourPoints; // Freehand boundary (burns, lesions, grafts)
  final String notes;
  final List<String> tiedProcedureCodes; // Auto-attach consumables to billing cart

  const AnatomicalConditionPayload({
    required this.pathology,
    this.severityScore = 1.0,
    this.cutPlane,
    this.surfaceContourPoints = const [],
    this.notes = '',
    this.tiedProcedureCodes = const [],
  });

  Map<String, dynamic> toJson() => {
        'pathology': pathology.name,
        'severityScore': severityScore,
        'cutPlane': cutPlane?.toJson(),
        'surfaceContourPoints': surfaceContourPoints
            .map((p) => {'x': p.dx, 'y': p.dy})
            .toList(),
        'notes': notes,
        'tiedProcedureCodes': tiedProcedureCodes,
      };

  factory AnatomicalConditionPayload.fromJson(Map<String, dynamic> json) {
    return AnatomicalConditionPayload(
      pathology: AnatomicalPathologyType.values.firstWhere(
        (p) => p.name == json['pathology'],
        orElse: () => AnatomicalPathologyType.cariesCavity,
      ),
      severityScore: (json['severityScore'] as num?)?.toDouble() ?? 1.0,
      cutPlane: json['cutPlane'] != null
          ? CutPlaneAnnotation.fromJson(Map<String, dynamic>.from(json['cutPlane'] as Map))
          : null,
      surfaceContourPoints: (json['surfaceContourPoints'] as List? ?? [])
          .map((item) {
            final m = item as Map;
            return Offset((m['x'] as num).toDouble(), (m['y'] as num).toDouble());
          })
          .toList(),
      notes: json['notes'] as String? ?? '',
      tiedProcedureCodes: List<String>.from(json['tiedProcedureCodes'] as List? ?? []),
    );
  }
}

enum SpatialToolType {
  cutPlaneLinear,      // Straight-line amputation / osteotomy
  splineGraftVector,   // Vascular bypass / nerve conduit / tendon transfer
  polygonContourArea,  // Resection flap, craniotomy, burn surface, melanoma
  radialCaliperGauge,  // Stenosis %, hernia ring, cervical dilation
  localizedDosagePin,  // Botox/Filler injection, laser barrier spot
  hardwareMeshLattice, // Orthopedic plate, stent, prosthetic hernia mesh
}

class AdvancedPathologyEntry {
  final String id;
  final String organNodeId;
  final SpatialToolType toolType;
  final String pathologyName;
  final Map<String, dynamic> geometricParameters; // Angles, coords, lengths, dosages
  final List<String> autoCartProcedureSkus;       // Inventory & billing bindings

  const AdvancedPathologyEntry({
    required this.id,
    required this.organNodeId,
    required this.toolType,
    required this.pathologyName,
    required this.geometricParameters,
    this.autoCartProcedureSkus = const [],
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'organNodeId': organNodeId,
        'toolType': toolType.name,
        'pathologyName': pathologyName,
        'geometricParameters': geometricParameters,
        'autoCartProcedureSkus': autoCartProcedureSkus,
      };

  factory AdvancedPathologyEntry.fromJson(Map<String, dynamic> json) {
    return AdvancedPathologyEntry(
      id: json['id'] as String,
      organNodeId: json['organNodeId'] as String,
      toolType: SpatialToolType.values.firstWhere(
        (t) => t.name == json['toolType'],
        orElse: () => SpatialToolType.cutPlaneLinear,
      ),
      pathologyName: json['pathologyName'] as String,
      geometricParameters: Map<String, dynamic>.from(json['geometricParameters'] as Map? ?? {}),
      autoCartProcedureSkus: List<String>.from(json['autoCartProcedureSkus'] as List? ?? []),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specialty 1: Dental 5-Surface MODBL Annotation & Billing Binding
// ─────────────────────────────────────────────────────────────────────────────

enum DentalModblSurface {
  mesial('M', 'Mesial Surface'),
  occlusal('O', 'Occlusal Surface'),
  distal('D', 'Distal Surface'),
  buccal('B', 'Buccal Surface'),
  lingual('L', 'Lingual Surface');

  final String code;
  final String label;
  const DentalModblSurface(this.code, this.label);

  static DentalModblSurface? fromCode(String code) {
    for (final s in DentalModblSurface.values) {
      if (s.code.toUpperCase() == code.toUpperCase()) return s;
    }
    return null;
  }
}

class DentalModblAnnotation {
  final int toothNumberFdi;
  final Set<DentalModblSurface> selectedSurfaces;
  final String compositeResinShade;

  const DentalModblAnnotation({
    required this.toothNumberFdi,
    this.selectedSurfaces = const {},
    this.compositeResinShade = 'A2',
  });

  String get surfaceCodeString {
    final list = selectedSurfaces.map((s) => s.code).toList()..sort();
    return list.join();
  }

  List<ProcedureItem> getGeneratedBillingItems() {
    if (selectedSurfaces.isEmpty) return const [];
    final count = selectedSurfaces.length;
    if (count == 1) {
      return [
        ProcedureItem(
          id: 'proc_resin_1s_${toothNumberFdi}_$surfaceCodeString',
          code: 'D2391',
          name: 'Composite Resin 1-Surface ($surfaceCodeString) - Tooth #$toothNumberFdi',
          standardFee: 120.0,
          requiredConsumables: [
            'Microhybrid Composite Resin ($compositeResinShade)',
            'Etching Gel & Primer Bond',
            'Finishing & Polishing Disc',
          ],
        ),
      ];
    } else if (count == 2) {
      return [
        ProcedureItem(
          id: 'proc_resin_2s_${toothNumberFdi}_$surfaceCodeString',
          code: 'D2392',
          name: 'Composite Resin 2-Surface ($surfaceCodeString) - Tooth #$toothNumberFdi',
          standardFee: 200.0,
          requiredConsumables: [
            'Microhybrid Composite Resin ($compositeResinShade)',
            'Sectional Matrix Band & Ring',
            'Etching Gel & Primer Bond',
          ],
        ),
      ];
    } else {
      return [
        ProcedureItem(
          id: 'proc_resin_complex_${toothNumberFdi}_$surfaceCodeString',
          code: 'D2393',
          name: 'Composite Resin Complex $count-Surface ($surfaceCodeString) - Tooth #$toothNumberFdi',
          standardFee: 280.0,
          requiredConsumables: [
            'Bulk-Fill & Universal Composite ($compositeResinShade)',
            'Sectional Matrix Band Kit',
            'Bonding Agent & Curing Shield',
            'Diamond Finishing Carbide Bur',
          ],
        ),
      ];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specialty 2: Cardiology / Vascular Caliper & Stent Spline
// ─────────────────────────────────────────────────────────────────────────────

enum VascularInterventionType {
  balloonAngioplasty,
  drugElutingStent,
  bypassGraftSpline,
}

class CardiologyVascularAnnotation {
  final String vesselName; // e.g., 'LAD', 'RCA', 'LCx'
  final double stenosisPercentage; // 10% to 100%
  final VascularInterventionType interventionType;
  final List<Offset> splineControlPoints;

  const CardiologyVascularAnnotation({
    required this.vesselName,
    required this.stenosisPercentage,
    this.interventionType = VascularInterventionType.drugElutingStent,
    this.splineControlPoints = const [],
  });

  bool get isCriticalStenosis => stenosisPercentage >= 70.0;

  List<ProcedureItem> getGeneratedBillingItems() {
    final pct = stenosisPercentage.toStringAsFixed(0);
    if (interventionType == VascularInterventionType.bypassGraftSpline) {
      return [
        ProcedureItem(
          id: 'proc_card_cabg_${vesselName.toLowerCase()}',
          code: 'CARD-33510',
          name: 'Coronary Artery Bypass Graft (CABG Spline) - $vesselName ($pct% Occlusion)',
          standardFee: 3500.0,
          requiredConsumables: const [
            'Saphenous Vein / LIMA Harvest Kit',
            'Cardiopulmonary Cannula Pack',
            'Vascular Anastomosis Sutures 7-0 Prolene',
          ],
        ),
      ];
    } else if (stenosisPercentage >= 50.0 || interventionType == VascularInterventionType.drugElutingStent) {
      return [
        ProcedureItem(
          id: 'proc_card_pci_${vesselName.toLowerCase()}',
          code: 'CARD-92928',
          name: 'Percutaneous Coronary Intervention (PCI) with Drug-Eluting Stent - $vesselName ($pct% Stenosis)',
          standardFee: 1800.0,
          requiredConsumables: const [
            'Drug-Eluting Coronary Stent (3.0mm x 18mm)',
            'Rapid-Exchange PTCA Balloon Catheter',
            'Coronary Steerable Guidewire 0.014"',
            'Sterile Angiography Drape & Contrast',
          ],
        ),
      ];
    } else {
      return [
        ProcedureItem(
          id: 'proc_card_diag_${vesselName.toLowerCase()}',
          code: 'CARD-93458',
          name: 'Diagnostic Left Heart Angiogram & Quantitative Stenosis Caliper - $vesselName ($pct%)',
          standardFee: 350.0,
          requiredConsumables: const [
            'Diagnostic Radial/Femoral Sheath 5F',
            'Judkins Left/Right Diagnostic Catheter',
            'Non-Ionic Low Osmolar Contrast (100mL)',
          ],
        ),
      ];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specialty 3: Ophthalmology Cup-to-Disc (C:D) Dial & Follow-Up Suggestions
// ─────────────────────────────────────────────────────────────────────────────

class OphthalmologyCupDiscAnnotation {
  final double cupToDiscRatio; // 0.1 to 1.0
  final bool rightEyeOD;
  final bool requestVisualFieldTest;
  final bool requestOctScan;

  const OphthalmologyCupDiscAnnotation({
    required this.cupToDiscRatio,
    this.rightEyeOD = true,
    this.requestVisualFieldTest = false,
    this.requestOctScan = false,
  });

  String get eyeSide => rightEyeOD ? 'OD (Right Eye)' : 'OS (Left Eye)';
  bool get isGlaucomaSuspect => cupToDiscRatio > 0.5;

  List<ProcedureItem> getGeneratedBillingItems() {
    final List<ProcedureItem> items = [];
    final cdStr = cupToDiscRatio.toStringAsFixed(2);

    items.add(
      ProcedureItem(
        id: 'proc_oph_fundus_${rightEyeOD ? "od" : "os"}',
        code: 'OPH-92014',
        name: 'Comprehensive Ophthalmic Slit-Lamp & Disc Exam - $eyeSide (C:D $cdStr)',
        standardFee: 95.0,
      ),
    );

    if (requestVisualFieldTest || isGlaucomaSuspect) {
      items.add(
        ProcedureItem(
          id: 'proc_oph_hvf_${rightEyeOD ? "od" : "os"}',
          code: 'OPH-92083',
          name: 'Humphrey Visual Field 24-2 Automated Perimetry - $eyeSide (Glaucoma Protocol)',
          standardFee: 140.0,
          requiredConsumables: const ['Visual Field Thermal Printout & Eyepatch'],
        ),
      );
    }

    if (requestOctScan || isGlaucomaSuspect) {
      items.add(
        ProcedureItem(
          id: 'proc_oph_oct_${rightEyeOD ? "od" : "os"}',
          code: 'OPH-92134',
          name: 'OCT Retinal Nerve Fiber Layer (RNFL) & Ganglion Cell Complex - $eyeSide',
          standardFee: 180.0,
          requiredConsumables: const ['OCT Diagnostic Protocol & Cloud Archival'],
        ),
      );
    }

    return items;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specialty 4: Orthopedics / Trauma Cut-Plane & Joint Goniometer
// ─────────────────────────────────────────────────────────────────────────────

class OrthopedicsCutPlaneGoniometerAnnotation {
  final String targetLimbOrJoint; // e.g. 'Right Femur', 'Knee Joint', 'Left Tibia'
  final CutPlaneAnnotation? cutPlane;
  final bool fadeDistalToWireframe;
  final double? goniometerAngleDegrees; // 0° to 180°
  final String jointMotionType; // e.g. 'Flexion', 'Extension', 'Abduction'

  const OrthopedicsCutPlaneGoniometerAnnotation({
    required this.targetLimbOrJoint,
    this.cutPlane,
    this.fadeDistalToWireframe = true,
    this.goniometerAngleDegrees,
    this.jointMotionType = 'Flexion',
  });

  List<ProcedureItem> getGeneratedBillingItems() {
    final List<ProcedureItem> items = [];

    if (cutPlane != null) {
      items.add(
        ProcedureItem(
          id: 'proc_ortho_cutplane_${targetLimbOrJoint.replaceAll(" ", "_").toLowerCase()}',
          code: 'ORTHO-27705',
          name: 'Surgical Osteotomy / Truncation Planning - $targetLimbOrJoint',
          standardFee: 1250.0,
          requiredConsumables: const [
            'Oscillating Bone Saw Blade (sterile)',
            'Surgical Drape & Irrigation System',
            'Temporary Fixation K-Wire Set',
            'Wound Drainage & Monofilament Suture Kit',
          ],
        ),
      );
    }

    if (goniometerAngleDegrees != null) {
      final angleStr = goniometerAngleDegrees!.toStringAsFixed(0);
      items.add(
        ProcedureItem(
          id: 'proc_ortho_goniometer_${targetLimbOrJoint.replaceAll(" ", "_").toLowerCase()}',
          code: 'ORTHO-95851',
          name: 'Joint Range of Motion (ROM) Goniometry - $targetLimbOrJoint ($jointMotionType: $angleStr°)',
          standardFee: 110.0,
          requiredConsumables: const ['Clinical Goniometric Chart Documentation'],
        ),
      );
    }

    return items;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Specialty 5: Dermatology Rule-of-Nines & Suture Marker
// ─────────────────────────────────────────────────────────────────────────────

enum BodyBurnRegion {
  head(9.0, 'Head & Neck'),
  chest(9.0, 'Anterior Chest'),
  abdomen(9.0, 'Anterior Abdomen'),
  upperBack(9.0, 'Upper Back'),
  lowerBack(9.0, 'Lower Back & Buttocks'),
  leftArm(9.0, 'Left Upper Extremity'),
  rightArm(9.0, 'Right Upper Extremity'),
  leftLeg(18.0, 'Left Lower Extremity'),
  rightLeg(18.0, 'Right Lower Extremity'),
  perineum(1.0, 'Perineum & Genitalia');

  final double percentage;
  final String label;
  const BodyBurnRegion(this.percentage, this.label);
}

class DermatologyBurnAreaSutureAnnotation {
  final Set<BodyBurnRegion> affectedBurnRegions;
  final double? incisionLengthCm;
  final int sutureCount;

  const DermatologyBurnAreaSutureAnnotation({
    this.affectedBurnRegions = const {},
    this.incisionLengthCm,
    this.sutureCount = 0,
  });

  double get totalTbsaPercentage =>
      affectedBurnRegions.fold(0.0, (acc, r) => acc + r.percentage);

  List<ProcedureItem> getGeneratedBillingItems() {
    final List<ProcedureItem> items = [];

    if (affectedBurnRegions.isNotEmpty) {
      final tbsa = totalTbsaPercentage.toStringAsFixed(0);
      items.add(
        ProcedureItem(
          id: 'proc_derm_burn_tbsa_${affectedBurnRegions.length}',
          code: 'DERM-16020',
          name: 'Burn Surface Debridement & Critical Dressing (TBSA: $tbsa%)',
          standardFee: 450.0,
          requiredConsumables: const [
            'Silver Sulfadiazine Cream (400g)',
            'Non-Adherent Sterile Paraffin Gauze Dressing',
            'Burn Triage Hydrogel Dressing Kit',
            'Sterile Trauma Bandage Rolls',
          ],
        ),
      );
    }

    if (incisionLengthCm != null && incisionLengthCm! > 0) {
      final len = incisionLengthCm!.toStringAsFixed(1);
      items.add(
        ProcedureItem(
          id: 'proc_derm_suture_${sutureCount}_stitches',
          code: 'DERM-12002',
          name: 'Linear Wound Closure & Layered Suture ($len cm, $sutureCount stitches)',
          standardFee: 220.0,
          requiredConsumables: const [
            '3-0 Prolene Monofilament Suture Pack',
            'Local Anesthetic Lidocaine 2% with Epinephrine',
            'Sterile Minor Surgical Tray & Needle Holder',
          ],
        ),
      );
    }

    return items;
  }
}
