import 'package:flutter/material.dart';
import '../../../../core/localization/app_language.dart';
import 'procedure_item.dart';

/// Clinical Status Pathology Category
enum ClinicalStatusCategory {
  all('All Statuses', 'جميع الحالات'),
  healthy('Normal / Healthy', 'سليم وطبيعي'),
  trauma('Trauma & Fractures', 'إصابات وكسور وتمزق'),
  inflammation('Inflammation & Infection', 'التهابات وعدوى'),
  degenerative('Degenerative & Chronic', 'تنكس وأمراض مزمنة'),
  vascular('Vascular & Ischemic', 'تروية وأوعية وانسداد'),
  surgical('Surgical & Post-Op', 'جراحة وزراعة ومعالج'),
  neoplasm('Lesion & Neoplasm', 'أورام وآفات نسيجية'),
  neoplastic('Neoplasm & Tumor', 'أورام وتنشؤات'),
  structural('Structural & Alignment', 'بنية وتشريح ومحاذاة'),
  functional('Functional & Physiological', 'وظائفي وسلوكي'),
  obstruction('Obstruction & Stenosis', 'انسداد وتضيق مجرى'),
  fluid('Fluid & Effusion', 'انصباب وارتشاح سوائل'),
  hypertrophy('Hypertrophy & Enlargement', 'تضخم وتضخم نسيجي'),
  procedural('Procedural & Safety Zone', 'مناطق الخطر وإجرائي'),
  ulcerative('Ulcerative & Erosive', 'تقرح وتآكل'),
  intractable('Intractable & Chronic Pain', 'آلام معندة ومزمنة');

  final String labelEn;
  final String labelAr;
  const ClinicalStatusCategory(this.labelEn, this.labelAr);

  String get label => AppLanguage.isArabic ? '$labelEn ($labelAr)' : labelEn;

  static ClinicalStatusCategory fromString(String? val) {
    if (val == null) return ClinicalStatusCategory.all;
    final lower = val.toLowerCase().trim();
    for (final c in ClinicalStatusCategory.values) {
      if (c.name.toLowerCase() == lower) return c;
    }
    return ClinicalStatusCategory.all;
  }
}

/// Clinical Severity Level
enum ClinicalSeverityLevel {
  normal('Normal Baseline', 'طبيعي وسليم', Color(0xFF10B981)), // Emerald
  mild('Mild', 'طفيف', Color(0xFF3B82F6)),                     // Blue
  moderate('Moderate', 'متوسط', Color(0xFFF59E0B)),            // Amber
  severe('Severe', 'شديد', Color(0xFFEF4444)),                 // Red
  critical('Critical', 'حرج / إسعافي', Color(0xFFDC2626));     // Crimson

  final String labelEn;
  final String labelAr;
  final Color color;
  const ClinicalSeverityLevel(this.labelEn, this.labelAr, this.color);

  String get label => AppLanguage.isArabic ? labelAr : labelEn;

  static ClinicalSeverityLevel fromString(String? val) {
    if (val == null) return ClinicalSeverityLevel.normal;
    final lower = val.toLowerCase().trim();
    for (final s in ClinicalSeverityLevel.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return ClinicalSeverityLevel.normal;
  }
}

/// Definition of a clinical status in the master catalog
class ClinicalStatusDefinition {
  final String id;
  final String title;
  final String titleAr;
  final String icd10Code;
  final ClinicalStatusCategory category;
  final ClinicalSeverityLevel severity;
  final String description;
  final ProcedureItem suggestedProcedure;

  const ClinicalStatusDefinition({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.icd10Code,
    required this.category,
    required this.severity,
    required this.description,
    required this.suggestedProcedure,
  });

  bool matchesQuery(String query) {
    if (query.isEmpty) return true;
    final q = query.toLowerCase().trim();
    return title.toLowerCase().contains(q) ||
        titleAr.toLowerCase().contains(q) ||
        icd10Code.toLowerCase().contains(q) ||
        description.toLowerCase().contains(q) ||
        suggestedProcedure.name.toLowerCase().contains(q) ||
        suggestedProcedure.code.toLowerCase().contains(q);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'titleAr': titleAr,
        'icd10Code': icd10Code,
        'category': category.name,
        'severity': severity.name,
        'description': description,
        'suggestedProcedure': {
          'id': suggestedProcedure.id,
          'code': suggestedProcedure.code,
          'name': suggestedProcedure.name,
          'standardFee': suggestedProcedure.standardFee,
          'insuranceCoveragePercentage': suggestedProcedure.insuranceCoveragePercentage,
          'requiredConsumables': suggestedProcedure.requiredConsumables,
        },
      };

  factory ClinicalStatusDefinition.fromJson(Map<String, dynamic> json) {
    final procJson = json['suggestedProcedure'] as Map<String, dynamic>? ?? {};
    return ClinicalStatusDefinition(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      titleAr: json['titleAr']?.toString() ?? '',
      icd10Code: json['icd10Code']?.toString() ?? '',
      category: ClinicalStatusCategory.fromString(json['category']?.toString()),
      severity: ClinicalSeverityLevel.fromString(json['severity']?.toString()),
      description: json['description']?.toString() ?? '',
      suggestedProcedure: ProcedureItem(
        id: procJson['id']?.toString() ?? '',
        code: procJson['code']?.toString() ?? '',
        name: procJson['name']?.toString() ?? '',
        standardFee: (procJson['standardFee'] as num?)?.toDouble() ?? 0.0,
        insuranceCoveragePercentage: (procJson['insuranceCoveragePercentage'] as num?)?.toDouble() ?? 0.0,
        requiredConsumables: (procJson['requiredConsumables'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      ),
    );
  }
}

/// Active status applied to a specific anatomical structure in the 3D model
class ClinicalAnatomyStatusEntry {
  final String partKey;
  final String partName;
  final String partNameAr;
  final ClinicalStatusDefinition status;
  final DateTime appliedAt;
  final String clinicalNote;
  final double? normalizedX;
  final double? normalizedY;
  final double? x3d;
  final double? y3d;
  final double? z3d;
  final String? attachedToothCode;

  const ClinicalAnatomyStatusEntry({
    required this.partKey,
    required this.partName,
    required this.partNameAr,
    required this.status,
    required this.appliedAt,
    this.clinicalNote = '',
    this.normalizedX,
    this.normalizedY,
    this.x3d,
    this.y3d,
    this.z3d,
    this.attachedToothCode,
  });

  bool get isCustomPin =>
      (normalizedX != null && normalizedY != null) ||
      x3d != null ||
      attachedToothCode != null;
  Color get visualColor => status.severity.color;
  String get icd10Code => status.icd10Code;
  String get displayTitle => AppLanguage.isArabic ? status.titleAr : status.title;

  Map<String, dynamic> toJson() => {
        'partKey': partKey,
        'partName': partName,
        'partNameAr': partNameAr,
        'status': status.toJson(),
        'appliedAt': appliedAt.toIso8601String(),
        'clinicalNote': clinicalNote,
        'normalizedX': normalizedX,
        'normalizedY': normalizedY,
        'x3d': x3d,
        'y3d': y3d,
        'z3d': z3d,
        'attachedToothCode': attachedToothCode,
      };

  factory ClinicalAnatomyStatusEntry.fromJson(Map<String, dynamic> json) {
    return ClinicalAnatomyStatusEntry(
      partKey: json['partKey']?.toString() ?? '',
      partName: json['partName']?.toString() ?? '',
      partNameAr: json['partNameAr']?.toString() ?? '',
      status: ClinicalStatusDefinition.fromJson(
        Map<String, dynamic>.from(json['status'] as Map? ?? {}),
      ),
      appliedAt: DateTime.tryParse(json['appliedAt']?.toString() ?? '') ?? DateTime.now(),
      clinicalNote: json['clinicalNote']?.toString() ?? '',
      normalizedX: (json['normalizedX'] as num?)?.toDouble(),
      normalizedY: (json['normalizedY'] as num?)?.toDouble(),
      x3d: (json['x3d'] as num?)?.toDouble(),
      y3d: (json['y3d'] as num?)?.toDouble(),
      z3d: (json['z3d'] as num?)?.toDouble(),
      attachedToothCode: json['attachedToothCode']?.toString(),
    );
  }
}
