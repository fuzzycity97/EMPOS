import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';
import 'dental_tooth_matrix_widget.dart';
import '../../domain/entities/tooth_chart_entry.dart';

/// Deep Read-Only Medical History & Consultation Drill-Down Dialog.
/// 100% [StatelessWidget] following Clean Architecture.
class HistoricalVisitDetailsDialog extends StatelessWidget {
  final ClinicVisit visit;
  final StoreBlueprint blueprint;
  final PatientProfile? patient;
  final List<ToothChartEntry>? cumulativeToothChart;

  const HistoricalVisitDetailsDialog({
    super.key,
    required this.visit,
    required this.blueprint,
    this.patient,
    this.cumulativeToothChart,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateStr = DateFormat('EEEE, MMM d, yyyy • hh:mm a').format(visit.checkInTime);
    final isPediatric = (patient?.calculatedAge != null && patient!.calculatedAge! < 12) ||
        visit.chiefComplaint.toLowerCase().contains('pediatric') ||
        visit.chiefComplaint.toLowerCase().contains('child');
    final effectiveToothChart = visit.toothChart.isNotEmpty
        ? visit.toothChart
        : (cumulativeToothChart ?? []);

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                              child: const Icon(LucideIcons.fileText, color: AppColors.primaryLight, size: 20),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Historical Medical Record: ${visit.patientName}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    dateStr,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: visit.status == ClinicVisitStatus.completed
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: Text(
                          visit.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: visit.status == ClinicVisitStatus.completed
                                ? AppColors.success
                                : AppColors.primaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textSecondaryDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),

              // Scrollable Details Body
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Clinical Vitals Recorded at Visit
                      _buildVitalsCard(isDark),
                      const SizedBox(height: 16),

                      // 2. Chief Complaint & Clinical Diagnosis
                      _buildClinicalSummary(isDark),
                      const SizedBox(height: 16),

                      // 3. Odontogram / Tooth Chart (Dental Blueprint or if teeth entries exist)
                      if (blueprint.isDental || effectiveToothChart.isNotEmpty) ...[
                        _buildSectionHeader('Dental Odontogram State', LucideIcons.smile),
                        const SizedBox(height: 8),
                        DentalToothMatrixWidget(
                          toothChart: effectiveToothChart,
                          isPediatric: isPediatric,
                          onToothUpdated: null, // Read-only mode
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 4. Structured Laboratory & Bloodwork Tracking Panel
                      _buildLaboratorySection(isDark),
                      const SizedBox(height: 16),

                      // 5. Diagnostic Attachments & Lightbox Preview
                      _buildDiagnosticAttachmentsSection(context, isDark),
                      const SizedBox(height: 16),

                      // 6. Prescriptions & Procedures
                      _buildPrescriptionsAndProcedures(isDark),
                      const SizedBox(height: 16),

                      // 7. Financial & Billing Summary
                      _buildFinancialSummary(isDark),
                    ],
                  ),
                ),
              ),

              const Divider(height: 24),
              // Footer Action
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceElevatedDark,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(LucideIcons.check, size: 16),
                  label: const Text('Done'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryLight),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildVitalsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Recorded Vitals', LucideIcons.activity),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _vitalChip('Heart Rate', visit.heartRate, LucideIcons.heart, Colors.red),
              _vitalChip('Blood Pressure', visit.bloodPressure, LucideIcons.gauge, Colors.purple),
              _vitalChip('SpO2', visit.spo2, LucideIcons.wind, Colors.teal),
              _vitalChip('Temperature', visit.temperature, LucideIcons.thermometer, Colors.amber),
              _vitalChip('Respiration', visit.respiratoryRate, LucideIcons.timer, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _vitalChip(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
          ),
          Text(
            value.isNotEmpty ? value : '--',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Clinical Consultation', LucideIcons.stethoscope),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CHIEF COMPLAINT',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMutedDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visit.chiefComplaint.isNotEmpty ? visit.chiefComplaint : 'Standard Consultation',
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimaryDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CLINICAL DIAGNOSIS',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMutedDark),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      visit.diagnosis != null && visit.diagnosis!.isNotEmpty
                          ? visit.diagnosis!
                          : 'No specific diagnosis recorded',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.tealAccent),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionsAndProcedures(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Prescriptions
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Prescriptions', LucideIcons.pill),
                const SizedBox(height: 8),
                if (visit.prescriptions.isEmpty)
                  const Text('No medications prescribed.', style: TextStyle(fontSize: 11, color: AppColors.textMutedDark))
                else
                  ...visit.prescriptions.map(
                    (p) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.checkCircle2, size: 12, color: AppColors.primaryLight),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(p, style: const TextStyle(fontSize: 11, color: AppColors.textPrimaryDark)),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Procedures
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Procedures Executed', LucideIcons.clipboardList),
                const SizedBox(height: 8),
                if (visit.appliedProcedures.isEmpty)
                  const Text('Standard Clinical Examination', style: TextStyle(fontSize: 11, color: AppColors.textMutedDark))
                else
                  ...visit.appliedProcedures.map(
                    (proc) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${proc.code} - ${proc.name}',
                              style: const TextStyle(fontSize: 11, color: AppColors.textPrimaryDark),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${proc.standardFee.toStringAsFixed(2)} EGP',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialSummary(bool isDark) {
    final visitDue = (visit.totalFee - visit.patientCopay - visit.insurancePaid).clamp(0.0, double.infinity);
    final isFullySettled = visitDue <= 0.001 && (visit.patientCopay > 0 || visit.insurancePaid > 0 || visit.totalFee == 0);
    final isPartiallyPaid = (visit.patientCopay > 0 || visit.insurancePaid > 0) && visitDue > 0.001;

    final String statusText;
    final Color statusColor;

    if (isFullySettled) {
      statusText = 'PAID & SETTLED';
      statusColor = AppColors.success;
    } else if (isPartiallyPaid) {
      statusText = 'PARTIAL DEBT (Due: ${visitDue.toStringAsFixed(2)} EGP)';
      statusColor = AppColors.warning;
    } else {
      statusText = 'UNPAID (Due: ${visit.totalFee.toStringAsFixed(2)} EGP)';
      statusColor = AppColors.danger;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _financeStat('Total Fee', '${visit.totalFee.toStringAsFixed(2)} EGP', AppColors.textPrimaryDark),
          _financeStat('Patient Copay', '${visit.patientCopay.toStringAsFixed(2)} EGP', AppColors.warning),
          _financeStat('Insurance Covered', '${visit.insurancePaid.toStringAsFixed(2)} EGP', AppColors.primaryLight),
          _financeStat(
            'Payment Status',
            statusText,
            statusColor,
          ),
        ],
      ),
    );
  }

  Widget _financeStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppColors.textMutedDark),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace'),
        ),
      ],
    );
  }

  Widget _buildLaboratorySection(bool isDark) {
    final hasLab = visit.labResults != null && visit.labResults!.trim().isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Laboratory Panels & Bloodwork', LucideIcons.flaskConical),
          const SizedBox(height: 10),
          if (hasLab)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Text(
                visit.labResults!,
                style: const TextStyle(fontSize: 12, color: Colors.white, height: 1.4),
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'No laboratory panels or bloodwork recorded for this consultation.',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticAttachmentsSection(BuildContext context, bool isDark) {
    final hasAttachments = visit.attachmentPaths.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Diagnostic Imaging & Attachment Records', LucideIcons.fileImage),
          const SizedBox(height: 10),
          if (hasAttachments)
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(visit.attachmentPaths.length, (idx) {
                final path = visit.attachmentPaths[idx];
                final title = idx < visit.attachmentTitles.length ? visit.attachmentTitles[idx] : 'Attachment #${idx + 1}';
                final file = File(path);
                final fileExists = file.existsSync();

                return InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    if (fileExists) {
                      _showImageDialog(context, path, title);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF030712),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(LucideIcons.image, size: 14, color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          fileExists ? LucideIcons.externalLink : LucideIcons.fileX,
                          size: 13,
                          color: fileExists ? Colors.white60 : Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No radiographs, scans, or attachments recorded for this visit session.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context, String filePath, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: const Color(0xFF090D16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: Colors.white70),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(color: Colors.white24),
              Expanded(
                child: Center(
                  child: Image.file(
                    File(filePath),
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => const Text(
                      'Failed to load image file from disk.',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
