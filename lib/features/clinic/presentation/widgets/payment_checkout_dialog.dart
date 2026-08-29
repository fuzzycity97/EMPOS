import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';

/// Modal dialog for clinic reception payment checkout and partial settlement.
/// 100% [StatelessWidget] following pure Clean Architecture.
class PaymentCheckoutDialog extends StatelessWidget {
  final ClinicVisit visit;
  final PatientProfile? patient;
  final double totalFee;
  final double patientShare;
  final double insuranceShare;
  final TextEditingController amountPaidController;
  final ValueNotifier<double> remainingDebtNotifier;
  final void Function(double amountPaid) onSubmit;

  PaymentCheckoutDialog({
    super.key,
    required this.visit,
    this.patient,
    required this.totalFee,
    required this.patientShare,
    required this.insuranceShare,
    required this.onSubmit,
    TextEditingController? amountPaidController,
    ValueNotifier<double>? remainingDebtNotifier,
  })  : amountPaidController = amountPaidController ??
            TextEditingController(text: patientShare.toStringAsFixed(2)),
        remainingDebtNotifier = remainingDebtNotifier ?? ValueNotifier<double>(0.0);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.teal.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(LucideIcons.receiptText, color: Colors.teal, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Payment Checkout & Settlement',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Patient: ${visit.patientName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textSecondaryDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Fee Breakdown Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  children: [
                    _buildRow('Total Clinical Consultation Fee:', CurrencyFormatter.format(totalFee), Colors.white),
                    if (insuranceShare > 0) ...[
                      const SizedBox(height: 6),
                      _buildRow(
                        'Insurance Claim (${patient?.insuranceProvider ?? "Carrier"}):',
                        '- ${CurrencyFormatter.format(insuranceShare)}',
                        Colors.blue,
                      ),
                    ],
                    const Divider(height: 16, color: AppColors.borderDark),
                    _buildRow(
                      'Patient Copay Due:',
                      CurrencyFormatter.format(patientShare),
                      Colors.teal,
                      isBold: true,
                      fontSize: 15,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Amount Paid Input
              TextField(
                controller: amountPaidController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))],
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  labelText: 'Amount Paid by Patient (EGP) *',
                  hintText: 'Enter amount collected',
                  prefixIcon: Icon(LucideIcons.banknote, size: 18, color: Colors.teal),
                ),
                onChanged: (val) {
                  final entered = double.tryParse(val) ?? 0.0;
                  final debt = (patientShare - entered).clamp(0.0, double.infinity);
                  remainingDebtNotifier.value = debt;
                },
              ),
              const SizedBox(height: AppDimensions.space12),

              // Live Remaining Balance Box
              ValueListenableBuilder<double>(
                valueListenable: remainingDebtNotifier,
                builder: (context, remainingDebt, _) {
                  if (remainingDebt <= 0.0) {
                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(LucideIcons.checkCheck, size: 16, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('Full payment settled. Zero remaining balance.', style: TextStyle(fontSize: 12, color: Colors.teal)),
                        ],
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.triangleAlert, size: 16, color: AppColors.warning),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Partial Payment: ${CurrencyFormatter.format(remainingDebt)} will be added to Customer Account Debt.',
                            style: const TextStyle(fontSize: 12, color: AppColors.warning, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark)),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    ),
                    icon: const Icon(LucideIcons.printer, size: 16, color: Colors.white),
                    label: const Text(
                      'Pay & Print Receipt',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final entered = double.tryParse(amountPaidController.text.trim()) ?? patientShare;
                      onSubmit(entered);
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, Color color, {bool isBold = false, double fontSize = 13}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: fontSize, color: AppColors.textSecondaryDark)),
        Text(
          value,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
