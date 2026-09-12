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
}
