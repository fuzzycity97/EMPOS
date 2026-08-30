import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';

class ChargeCustomerDebtDialog extends StatelessWidget {
  final Customer customer;
  final TextEditingController amountController;
  final TextEditingController notesController;

  const ChargeCustomerDebtDialog._({
    super.key,
    required this.customer,
    required this.amountController,
    required this.notesController,
  });

  factory ChargeCustomerDebtDialog({
    Key? key,
    required Customer customer,
  }) {
    return ChargeCustomerDebtDialog._(
      key: key,
      customer: customer,
      amountController: TextEditingController(),
      notesController: TextEditingController(),
    );
  }

  void _submit(BuildContext context) {
    final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
    final notes = notesController.text.trim();

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid charge amount.')),
      );
      return;
    }

    context.read<CustomerBloc>().add(
          ChargeDebtEvent(
            customerId: customer.id,
            amount: amount,
            notes: notes.isNotEmpty ? notes : 'Manual Account Debit Charge',
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
        width: 480,
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
                    color: AppColors.danger.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: const Icon(
                    LucideIcons.filePlus2,
                    color: AppColors.danger,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                const Text(
                  'Debit Account / Add Debt Charge',
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
                        'Current Debt Balance',
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

            // Charge Amount Input
            const Text(
              'Charge / Debit Amount *',
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
                  color: AppColors.danger,
                  fontFamily: 'monospace',
                ),
                decoration: const InputDecoration(
                  prefixIcon: Icon(LucideIcons.plus, size: 18, color: AppColors.danger),
                  hintText: '0.00',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Notes / Reason
            const Text(
              'Reason / Description *',
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
                  hintText: 'e.g. Unpaid clinic copay, store credit purchase, or manual adjustment',
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
                  backgroundColor: AppColors.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                onPressed: () => _submit(context),
                icon: const Icon(LucideIcons.check, size: 18),
                label: const Text(
                  'CONFIRM CHARGE & DEBIT ACCOUNT',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
