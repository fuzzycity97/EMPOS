import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/cash_transaction.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';

class CashTransactionDialog extends StatelessWidget {
  final String shiftId;
  final ValueNotifier<CashTransactionType> typeNotifier;
  final TextEditingController amountController;
  final TextEditingController reasonController;

  const CashTransactionDialog._({
    super.key,
    required this.shiftId,
    required this.typeNotifier,
    required this.amountController,
    required this.reasonController,
  });

  factory CashTransactionDialog({
    Key? key,
    required String shiftId,
    CashTransactionType initialType = CashTransactionType.payIn,
  }) {
    return CashTransactionDialog._(
      key: key,
      shiftId: shiftId,
      typeNotifier: ValueNotifier<CashTransactionType>(initialType),
      amountController: TextEditingController(),
      reasonController: TextEditingController(),
    );
  }

  void _submit(BuildContext context) {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    final reason = reasonController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0.')),
      );
      return;
    }

    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason or description.')),
      );
      return;
    }

    context.read<ShiftBloc>().add(
          AddCashTxEvent(
            shiftId: shiftId,
            type: typeNotifier.value,
            amount: amount,
            reason: reason,
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
        constraints: const BoxConstraints(maxWidth: 480),
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
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: const Icon(
                          LucideIcons.arrowLeftRight,
                          size: 20,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Text(
                        'Cash Drawer Entry',
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

              // Type Selector Toggle (Pay-In vs Pay-Out)
              ValueListenableBuilder<CashTransactionType>(
                valueListenable: typeNotifier,
                builder: (context, currentType, _) {
                  return Row(
                    children: [
                      Expanded(
                        child: _TypeSelectCard(
                          label: 'PAY-IN (+ Cash)',
                          subtitle: 'Add Change / Float Injection',
                          icon: LucideIcons.arrowDownLeft,
                          isSelected: currentType == CashTransactionType.payIn,
                          activeColor: AppColors.success,
                          onTap: () => typeNotifier.value = CashTransactionType.payIn,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TypeSelectCard(
                          label: 'PAY-OUT (− Cash)',
                          subtitle: 'Expense / Supplier Payout',
                          icon: LucideIcons.arrowUpRight,
                          isSelected: currentType == CashTransactionType.payOut,
                          activeColor: AppColors.danger,
                          onTap: () => typeNotifier.value = CashTransactionType.payOut,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space16),

              // Amount
              const Text(
                'Amount (EGP)',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  prefixIcon: Icon(LucideIcons.banknote, size: 16),
                  hintText: '0.00',
                ),
              ),
              const SizedBox(height: 8),

              // Quick Presets
              Wrap(
                spacing: 6,
                children: [50.0, 100.0, 200.0, 500.0].map((amt) {
                  return OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      side: const BorderSide(color: AppColors.borderDark),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                    ),
                    onPressed: () {
                      amountController.text = amt.toStringAsFixed(2);
                    },
                    child: Text(
                      '${amt.toInt()} EGP',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Reason
              const Text(
                'Reason / Audit Description',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Added change coins or Supplier milk payout',
                ),
              ),
              const SizedBox(height: 8),

              // Quick Reason Chips
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  'Change float addition',
                  'Supplier payout',
                  'Cleaning supplies',
                  'Petty cash expense',
                  'Customer change correction',
                ].map((reason) {
                  return ActionChip(
                    label: Text(reason, style: const TextStyle(fontSize: 10.5)),
                    backgroundColor: AppColors.surfaceElevatedDark,
                    side: const BorderSide(color: AppColors.borderDark),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    onPressed: () => reasonController.text = reason,
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Submit Button
              ValueListenableBuilder<CashTransactionType>(
                valueListenable: typeNotifier,
                builder: (context, currentType, _) {
                  final isPayIn = currentType == CashTransactionType.payIn;
                  return SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isPayIn ? AppColors.success : AppColors.danger,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                      ),
                      onPressed: () => _submit(context),
                      icon: Icon(
                        isPayIn ? LucideIcons.plusCircle : LucideIcons.minusCircle,
                        size: 18,
                      ),
                      label: Text(
                        isPayIn
                            ? 'RECORD PAY-IN (CASH IN)'
                            : 'RECORD PAY-OUT (CASH OUT)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TypeSelectCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _TypeSelectCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(AppDimensions.space12),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderDark,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: isSelected ? activeColor : AppColors.textMutedDark),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? activeColor : AppColors.textSecondaryDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 10, color: AppColors.textMutedDark),
            ),
          ],
        ),
      ),
    );
  }
}
