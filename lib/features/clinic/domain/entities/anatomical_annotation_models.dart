import 'dart:ui';

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

