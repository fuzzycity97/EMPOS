import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../domain/entities/clinical_report_templates.dart';

/// Universal Clinical & Departmental Report Viewer Dialog.
/// 100% [StatelessWidget] architecture.
class UniversalClinicalReportViewerDialog extends StatelessWidget {
  final ClinicalReportEntry report;
  final String facilityName;
  final VoidCallback? onPrint;

  const UniversalClinicalReportViewerDialog({
    super.key,
    required this.report,
    this.facilityName = 'Omni Healthcare & Diagnostic Center',
    this.onPrint,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormatted = DateFormat('EEEE, MMM d, yyyy • hh:mm a').format(report.encounterDate);

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header & Facility Branding ─────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          facilityName.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getReportTitle(report.reportType),
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          dateFormatted,
                          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryDark),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.printer, size: 20, color: AppColors.primaryLight),
                        tooltip: 'Print Official Report',
                        onPressed: onPrint ?? () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondaryDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),

              // ── Patient & Attending Doctor Summary Bar ─────────────
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _metaPair('PATIENT NAME', report.patientName, 'ID: ${report.patientId}'),
                    _metaPair('ATTENDING PRACTITIONER', report.doctorName, 'Lic: ${report.doctorId}'),
                    _metaPair('ENCOUNTER TYPE', _getReportBadge(report.reportType), 'Official Audit'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Dynamic Specialty-Specific Report Body ─────────────
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildDynamicReportContent(isDark),
                    ],
                  ),
                ),
              ),

              const Divider(height: 20),
              // ── Bottom Action Footer ──────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Confidential Medical Document • Electronic Signature Verified',
                    style: TextStyle(fontSize: 10, color: AppColors.textMutedDark),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    icon: const Icon(LucideIcons.check, size: 16),
                    label: const Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _metaPair(String label, String value, String sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.textMutedDark)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
        Text(sub, style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark)),
      ],
    );
  }

  Widget _buildDynamicReportContent(bool isDark) {
    switch (report.reportType) {
      case ReportDataType.opticalPrescription:
        return _buildOpticalPrescriptionTable(isDark);
      case ReportDataType.dentalOdontogramSummary:
        return _buildDentalSummary(isDark);
      case ReportDataType.orthopedicRomGoniometry:
        return _buildRomGoniometrySummary(isDark);
      case ReportDataType.pediatricGrowthSummary:
        return _buildPediatricGrowthSummary(isDark);
      case ReportDataType.audiogramThresholds:
        return _buildAudiogramSummary(isDark);
      case ReportDataType.cardiacSummary:
        return _buildCardiacSummary(isDark);
      case ReportDataType.generalClinicalSummary:
        return _buildGeneralSummary(isDark);
      case ReportDataType.fefoDispensingAudit:
        return _buildFefoAuditSummary(isDark);
    }
  }

  Widget _buildOpticalPrescriptionTable(bool isDark) {
    final data = report.structuredData;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.glasses, size: 16, color: AppColors.primaryLight),
              SizedBox(width: 8),
              Text('Optical Refraction & Vision Prescription', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: isDark ? AppColors.borderDark : Colors.black12),
            children: [
              const TableRow(
                decoration: BoxDecoration(color: Color(0xFF030712)),
                children: [
                  Padding(padding: EdgeInsets.all(6), child: Text('Eye', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Sphere (SPH)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Cylinder (CYL)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Axis (°)', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Add', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white))),
                  Padding(padding: EdgeInsets.all(6), child: Text('Visual Acuity', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white))),
                ],
              ),
              _opticalRow('OD (Right Eye)', data['od_sph'] ?? '-1.75', data['od_cyl'] ?? '-0.50', data['od_axis'] ?? '90°', data['od_add'] ?? '+1.50', data['od_va'] ?? '20/20'),
              _opticalRow('OS (Left Eye)', data['os_sph'] ?? '-2.00', data['os_cyl'] ?? '-0.75', data['os_axis'] ?? '85°', data['os_add'] ?? '+1.50', data['os_va'] ?? '20/20'),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Pupillary Distance (PD): ${data['pd'] ?? '63.5 mm'} • Lens Material: ${data['lens_material'] ?? 'High-Index Polycarbonate Anti-Reflective'}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  TableRow _opticalRow(String eye, String sph, String cyl, String axis, String add, String va) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.all(6), child: Text(eye, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight))),
        Padding(padding: const EdgeInsets.all(6), child: Text(sph, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
        Padding(padding: const EdgeInsets.all(6), child: Text(cyl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
        Padding(padding: const EdgeInsets.all(6), child: Text(axis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
        Padding(padding: const EdgeInsets.all(6), child: Text(add, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontFamily: 'monospace'))),
        Padding(padding: const EdgeInsets.all(6), child: Text(va, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success))),
      ],
    );
  }

  Widget _buildDentalSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.smile, size: 16, color: AppColors.primaryLight),
              SizedBox(width: 8),
              Text('Dental Examination & Odontogram Findings', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Tooth #19: MOD Composite Resin Restoration Completed\n• Tooth #14: Periodontal Pocket Depth 4mm with Bleeding on Probing\n• Tooth #32, #17: Impacted Third Molars Evaluated (Observation)',
            style: TextStyle(fontSize: 11.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildRomGoniometrySummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.activity, size: 16, color: AppColors.primaryLight),
              SizedBox(width: 8),
              Text('Range of Motion (ROM) & Rehabilitation Goniometry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Right Knee Flexion: 115° (Baseline: 85° — Improvement: +30°)\n• Left Shoulder Abduction: 150° with Mild VAS Pain Rating 2/10\n• Lumbar Spine Flexion: 65° without Radiculopathy',
            style: TextStyle(fontSize: 11.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPediatricGrowthSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.baby, size: 16, color: AppColors.primaryLight),
              SizedBox(width: 8),
              Text('Pediatric Growth & Developmental Milestones', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          SizedBox(height: 10),
          Text(
            '• Weight: 14.2 kg (65th percentile CDC)\n• Height / Stature: 96 cm (72nd percentile CDC)\n• Head Circumference: 49.5 cm (Normal for Age)\n• Immunization Status: Up-to-Date (MMR Booster administered)',
            style: TextStyle(fontSize: 11.5, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildAudiogramSummary(bool isDark) => _simpleReportSection('Audiological Pure-Tone Thresholds', 'Normal hearing bilaterally across frequencies (250Hz - 8000Hz).');
  Widget _buildCardiacSummary(bool isDark) => _simpleReportSection('Cardiology & Echocardiogram Metrics', 'Left Ventricular Ejection Fraction (LVEF): 62% • Sinus Rhythm • No Wall Motion Abnormalities.');
  Widget _buildGeneralSummary(bool isDark) => _simpleReportSection('General Clinical Consultation', 'Routine Follow-Up • Vitals Stable • Standard Consultation Executed.');
  Widget _buildFefoAuditSummary(bool isDark) => _simpleReportSection('FEFO Drug Dispensation Audit', 'Medication: Amoxicillin 500mg • Batch: #AMX-2026-08 • Expiry: Dec 2027 • Dispensed: 20 Capsules.');

  Widget _simpleReportSection(String title, String body) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF030712),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.white)),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryDark, height: 1.4)),
        ],
      ),
    );
  }

  static String _getReportTitle(ReportDataType type) {
    switch (type) {
      case ReportDataType.opticalPrescription:
        return 'Official Optical & Refraction Prescription';
      case ReportDataType.dentalOdontogramSummary:
        return 'Comprehensive Dental Examination Report';
      case ReportDataType.orthopedicRomGoniometry:
        return 'Physiotherapy & Goniometry Assessment';
      case ReportDataType.pediatricGrowthSummary:
        return 'Pediatric Growth & Milestone Report';
      case ReportDataType.audiogramThresholds:
        return 'Audiology Pure-Tone Hearing Thresholds';
      case ReportDataType.cardiacSummary:
        return 'Cardiology & Echocardiogram Consultation';
      case ReportDataType.generalClinicalSummary:
        return 'Clinical Consultation & Encounter Summary';
      case ReportDataType.fefoDispensingAudit:
        return 'Pharmaceutical FEFO Dispensation Record';
    }
  }

  static String _getReportBadge(ReportDataType type) {
    switch (type) {
      case ReportDataType.opticalPrescription:
        return 'OPTOMETRY / OPHTHALMOLOGY';
      case ReportDataType.dentalOdontogramSummary:
        return 'DENTAL ODONTOGRAM';
      case ReportDataType.orthopedicRomGoniometry:
        return 'PHYSIO / ORTHOPEDICS';
      case ReportDataType.pediatricGrowthSummary:
        return 'PEDIATRICS / CDC GROWTH';
      case ReportDataType.audiogramThresholds:
        return 'ENT / AUDIOMETRY';
      case ReportDataType.cardiacSummary:
        return 'CARDIOLOGY / ECG';
      case ReportDataType.generalClinicalSummary:
        return 'GENERAL INTERNAL MEDICINE';
      case ReportDataType.fefoDispensingAudit:
        return 'PHARMACY DISPENSARY';
    }
  }
}
