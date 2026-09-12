import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';
import 'clinic_receipt_generator.dart';

/// Modal Dialog rendering a true thermal receipt preview on screen with 1-tap print action.
class ClinicReceiptDialog extends StatelessWidget {
  final ClinicVisit visit;
  final PatientProfile? patient;
  final double amountPaid;
  final StoreBlueprint blueprint;

  const ClinicReceiptDialog({
    super.key,
    required this.visit,
    this.patient,
    required this.amountPaid,
    required this.blueprint,
  });

  @override
  Widget build(BuildContext context) {
    final visitDate = visit.completionTime ?? visit.checkInTime;
    final totalFee = visit.totalFee;
    final hasInsurance = (patient?.insuranceProvider?.trim().isNotEmpty ?? false) || visit.insurancePaid > 0.001;
    final copayRatio = hasInsurance ? (patient?.defaultCopayPercentage ?? 1.0) : 1.0;
    final patientShare = visit.patientCopay > 0 ? visit.patientCopay : (totalFee * copayRatio);
    final insuranceShare = hasInsurance ? (visit.insurancePaid > 0 ? visit.insurancePaid : (totalFee - patientShare)) : 0.0;
    final remainingDebt = (patientShare - amountPaid).clamp(0.0, double.infinity);
    final isFullyPaid = remainingDebt <= 0.001;
    final shortId = visit.id.length > 8 ? visit.id.substring(0, 8).toUpperCase() : visit.id.toUpperCase();

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TOP HEADER ──
            Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.checkCheck, color: AppColors.success, size: 28),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                blueprint.storeName.toUpperCase(),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Center(
              child: Text(
                '${blueprint.storeBranch} • Medical Reception Desk',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFCBD5E1), thickness: 1),

            // ── RECEIPT META ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Receipt #REC-$shortId',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(visitDate),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Patient: ${visit.patientName}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            if (patient != null && patient!.phone.isNotEmpty)
              Text(
                'Phone: ${patient!.phone}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            Text(
              'Attending: ${visit.doctorName} (${visit.roomNumber})',
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
            ),
            if (visit.diagnosis != null && visit.diagnosis!.isNotEmpty)
              Text(
                'Diagnosis: ${visit.diagnosis}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF334155), fontWeight: FontWeight.w500),
              ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFCBD5E1), thickness: 1),

            // ── PROCEDURES LIST ──
            const Text(
              'PROCEDURES & CONSULTATION',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B), letterSpacing: 0.5),
            ),
            const SizedBox(height: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 140),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    if (visit.appliedProcedures.isNotEmpty)
                      ...visit.appliedProcedures.map(
                        (proc) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  proc.name,
                                  style: const TextStyle(fontSize: 11.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                                ),
                              ),
                              Text(
                                '${proc.standardFee.toStringAsFixed(2)} ${blueprint.currency}',
                                style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.5),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Text(
                                'Clinical Consultation & Evaluation',
                                style: TextStyle(fontSize: 11.5, color: Color(0xFF1E293B), fontWeight: FontWeight.w500),
                              ),
                            ),
                            Text(
                              '${totalFee.toStringAsFixed(2)} ${blueprint.currency}',
                              style: const TextStyle(fontSize: 11.5, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFCBD5E1), thickness: 1),

            // ── FINANCIAL SUMMARY ──
            _buildSummaryRow('Total Fee', '${totalFee.toStringAsFixed(2)} ${blueprint.currency}'),
            if (insuranceShare > 0)
              _buildSummaryRow('Insurance Claim', '- ${insuranceShare.toStringAsFixed(2)} ${blueprint.currency}', isSub: true),
            _buildSummaryRow('Patient Share', '${patientShare.toStringAsFixed(2)} ${blueprint.currency}', isBold: true),
            _buildSummaryRow('Amount Collected', '${amountPaid.toStringAsFixed(2)} ${blueprint.currency}', isBold: true, isHighlight: true),
            if (remainingDebt > 0)
              _buildSummaryRow('Remaining Debt', '${remainingDebt.toStringAsFixed(2)} ${blueprint.currency}', isAlert: true),

            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: isFullyPaid ? AppColors.success.withValues(alpha: 0.1) : AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Center(
                child: Text(
                  isFullyPaid ? '★ SETTLED & PAID IN FULL ★' : '⚠ PARTIAL PAYMENT (DEBT APPLIED) ⚠',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isFullyPaid ? AppColors.success : AppColors.warning,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── ACTION BUTTONS ──
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                      side: const BorderSide(color: Color(0xFFCBD5E1)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () async {
                      await ClinicReceiptGenerator.printReceipt(
                        visit: visit,
                        patient: patient,
                        amountPaid: amountPaid,
                        blueprint: blueprint,
                      );
                    },
                    icon: const Icon(LucideIcons.printer, size: 15),
                    label: const Text('Print Receipt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Done', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isSub = false, bool isHighlight = false, bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 12 : 11,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: isSub ? const Color(0xFF64748B) : const Color(0xFF334155),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 12.5 : 11,
              fontWeight: isBold || isAlert ? FontWeight.bold : FontWeight.w600,
              fontFamily: 'monospace',
              color: isAlert
                  ? AppColors.error
                  : isHighlight
                      ? AppColors.success
                      : const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}
