import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/shift.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';

class CloseShiftDialog extends StatelessWidget {
  final Shift shift;
  final TextEditingController actualCashController;
  final TextEditingController notesController;
  final ValueNotifier<double> differenceNotifier;

  const CloseShiftDialog._({
    super.key,
    required this.shift,
    required this.actualCashController,
    required this.notesController,
    required this.differenceNotifier,
  });

  factory CloseShiftDialog({Key? key, required Shift shift}) {
    final defaultExpected = shift.expectedCash;
    return CloseShiftDialog._(
      key: key,
      shift: shift,
      actualCashController: TextEditingController(
        text: defaultExpected.toStringAsFixed(2),
      ),
      notesController: TextEditingController(),
      differenceNotifier: ValueNotifier<double>(0.0),
    );
  }

  void _onActualCashChanged(String value) {
    final actual = double.tryParse(value.trim()) ?? 0.0;
    differenceNotifier.value = actual - shift.expectedCash;
  }

  void _submit(BuildContext context) {
    final actual = double.tryParse(actualCashController.text.trim());
    if (actual == null || actual < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid actual cash amount.')),
      );
      return;
    }

    final notes = notesController.text.trim();

    context.read<ShiftBloc>().add(
          CloseShiftEvent(
            shiftId: shift.id,
            actualCash: actual,
            notes: notes.isNotEmpty ? notes : null,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space24),
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: const Icon(
                          LucideIcons.fileText,
                          size: 20,
                          color: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Text(
                        'End Shift & Cash Audit',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: AppDimensions.space12),

              // Drawer Expected Cash Calculation Card
              Container(
                padding: const EdgeInsets.all(AppDimensions.space16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  children: [
                    _auditRow(
                      'Opening Float:',
                      CurrencyFormatter.format(shift.startingCash),
                    ),
                    const SizedBox(height: 4),
                    _auditRow(
                      'Expected Drawer Cash:',
                      CurrencyFormatter.format(shift.expectedCash),
                      isHighlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Actual Counted Cash Input
              const Text(
                'Actual Physical Cash Counted in Drawer (EGP)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: actualCashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(LucideIcons.circleDollarSign, size: 18),
                  hintText: 'Enter physical count',
                ),
                onChanged: _onActualCashChanged,
              ),
              const SizedBox(height: AppDimensions.space16),

              // Live Difference Reconciliation Badge
              ValueListenableBuilder<double>(
                valueListenable: differenceNotifier,
                builder: (context, diff, _) {
                  Color badgeColor = AppColors.success;
                  String statusLabel = 'DRAWER BALANCED';
                  IconData statusIcon = LucideIcons.checkCheck;

                  if (diff < -0.01) {
                    badgeColor = AppColors.danger;
                    statusLabel = 'SHORTAGE: ${CurrencyFormatter.format(diff)}';
                    statusIcon = LucideIcons.trendingDown;
                  } else if (diff > 0.01) {
                    badgeColor = AppColors.warning;
                    statusLabel = 'SURPLUS: +${CurrencyFormatter.format(diff)}';
                    statusIcon = LucideIcons.trendingUp;
                  }

                  return Container(
                    padding: const EdgeInsets.all(AppDimensions.space12),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.12),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                        color: badgeColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, size: 20, color: badgeColor),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w900,
                                  color: badgeColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                diff.abs() <= 0.01
                                    ? 'Physical count exactly matches recorded sales & float.'
                                    : (diff < 0
                                        ? 'Physical drawer cash is less than expected sales calculation.'
                                        : 'Physical drawer cash exceeds calculated totals.'),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space16),

              // Closing Notes
              const Text(
                'Audit Notes / Reason for Discrepancy',
                style: TextStyle(
                  fontSize: 11.5,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Verified by Store Manager',
                ),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Finalize & Print Z-Report Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMedium),
                    ),
                  ),
                  onPressed: () => _submit(context),
                  icon: const Icon(LucideIcons.lock, size: 18),
                  label: const Text(
                    'CLOSE SHIFT & GENERATE Z-REPORT',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
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

  Widget _auditRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isHighlight ? 13 : 12,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isHighlight ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlight ? 16 : 12,
            fontWeight: FontWeight.w900,
            color: isHighlight ? AppColors.success : AppColors.textPrimaryDark,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
