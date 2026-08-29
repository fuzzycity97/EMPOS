import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';

class DebtPaymentDialog extends StatelessWidget {
  final Customer customer;
  final TextEditingController amountController;
  final TextEditingController notesController;
  final ValueNotifier<TenderType> selectedTenderNotifier;

  const DebtPaymentDialog._({
    super.key,
    required this.customer,
    required this.amountController,
    required this.notesController,
    required this.selectedTenderNotifier,
  });

  factory DebtPaymentDialog({
    Key? key,
    required Customer customer,
  }) {
    return DebtPaymentDialog._(
      key: key,
      customer: customer,
      amountController: TextEditingController(
        text: customer.totalDebt.toStringAsFixed(2),
      ),
      notesController: TextEditingController(),
      selectedTenderNotifier: ValueNotifier<TenderType>(TenderType.cash),
    );
  }

  void _submit(BuildContext context) {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    final tender = selectedTenderNotifier.value;
    final notes = notesController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid payment amount.')),
      );
      return;
    }

    if (amount > customer.totalDebt + 0.01) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Payment amount (${CurrencyFormatter.format(amount)}) cannot exceed total debt (${CurrencyFormatter.format(customer.totalDebt)}).',
          ),
        ),
      );
      return;
    }

    context.read<CustomerBloc>().add(
          ProcessDebtPaymentEvent(
            customerId: customer.id,
            amount: amount,
            paymentTender: tender,
            notes: notes.isNotEmpty ? notes : 'Debt Settlement (${tender.name.toUpperCase()})',
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: const Icon(
                    LucideIcons.handCoins,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                const Text(
                  'Settle Debt & Collect Payment',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimaryDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Customer Summary Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        customer.phone,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Total Outstanding Debt',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(customer.totalDebt),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.danger,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Amount Input & Quick Presets
            const Text(
              'Payment Amount *',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.success,
                  fontFamily: 'monospace',
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(LucideIcons.dollarSign, size: 18, color: AppColors.success),
                  hintText: '0.00',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Quick Preset Buttons
            Row(
              children: [
                _presetButton('Pay 25%', customer.totalDebt * 0.25),
                const SizedBox(width: 8),
                _presetButton('Pay 50%', customer.totalDebt * 0.50),
                const SizedBox(width: 8),
                _presetButton('Pay Full Debt', customer.totalDebt),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Payment Tender Selector
            const Text(
              'Payment Tender *',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 6),
            ValueListenableBuilder<TenderType>(
              valueListenable: selectedTenderNotifier,
              builder: (context, selectedTender, _) {
                return Row(
                  children: [
                    _tenderOption(TenderType.cash, 'Cash', LucideIcons.banknote, selectedTender),
                    const SizedBox(width: 8),
                    _tenderOption(TenderType.card, 'Card', LucideIcons.creditCard, selectedTender),
                    const SizedBox(width: 8),
                    _tenderOption(TenderType.instapay, 'Instapay', LucideIcons.zap, selectedTender),
                    const SizedBox(width: 8),
                    _tenderOption(TenderType.vodafoneCash, 'V-Cash', LucideIcons.smartphone, selectedTender),
                  ],
                );
              },
            ),
            const SizedBox(height: 4),
            ValueListenableBuilder<TenderType>(
              valueListenable: selectedTenderNotifier,
              builder: (context, selectedTender, _) {
                if (selectedTender == TenderType.cash) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Text(
                      '⚡ Cash payments will be automatically logged as Pay-In into active shift drawer.',
                      style: TextStyle(fontSize: 11, color: AppColors.primaryLight),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(height: AppDimensions.space16),

            // Notes
            const Text(
              'Notes (Optional)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: TextField(
                controller: notesController,
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryDark),
                decoration: const InputDecoration(
                  hintText: 'e.g. Received by cashier on duty',
                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                onPressed: () => _submit(context),
                icon: const Icon(LucideIcons.checkCheck, size: 18),
                label: const Text(
                  'CONFIRM SETTLEMENT & COLLECT PAYMENT',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetButton(String label, double amount) {
    return Expanded(
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6),
          side: const BorderSide(color: AppColors.borderDark),
          backgroundColor: AppColors.surfaceElevatedDark,
        ),
        onPressed: () {
          amountController.text = amount.toStringAsFixed(2);
        },
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textPrimaryDark),
        ),
      ),
    );
  }

  Widget _tenderOption(
    TenderType type,
    String label,
    IconData icon,
    TenderType selected,
  ) {
    final isSelected = type == selected;
    return Expanded(
      child: InkWell(
        onTap: () => selectedTenderNotifier.value = type,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.surfaceElevatedDark,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderDark,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textSecondaryDark,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
