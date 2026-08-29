import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/expense.dart';

class ExpenseDialog extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final ValueNotifier<ExpenseCategory> categoryNotifier;
  final ValueNotifier<bool> paidFromDrawerNotifier;

  const ExpenseDialog._({
    super.key,
    required this.amountController,
    required this.descriptionController,
    required this.categoryNotifier,
    required this.paidFromDrawerNotifier,
  });

  factory ExpenseDialog({
    Key? key,
  }) {
    return ExpenseDialog._(
      key: key,
      amountController: TextEditingController(),
      descriptionController: TextEditingController(),
      categoryNotifier: ValueNotifier<ExpenseCategory>(ExpenseCategory.utilities),
      paidFromDrawerNotifier: ValueNotifier<bool>(true),
    );
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
                        padding: const EdgeInsets.all(AppDimensions.space10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: Icon(LucideIcons.receipt, color: AppColors.error, size: 20),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      const Text(
                        'Record Store Expense',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AppColors.textMutedDark, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space20),

              // Expense Category Dropdown
              const Text(
                'EXPENSE CATEGORY *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              ValueListenableBuilder<ExpenseCategory>(
                valueListenable: categoryNotifier,
                builder: (context, selectedCategory, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevatedDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<ExpenseCategory>(
                        value: selectedCategory,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceElevatedDark,
                        items: ExpenseCategory.values.map((cat) {
                          return DropdownMenuItem<ExpenseCategory>(
                            value: cat,
                            child: Row(
                              children: [
                                Icon(_getCategoryIcon(cat), size: 16, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Text(
                                  cat.name.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (newCat) {
                          if (newCat != null) categoryNotifier.value = newCat;
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space16),

              // Amount
              const Text(
                'EXPENSE AMOUNT (EGP) *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  hintStyle: const TextStyle(color: AppColors.textMutedDark),
                  prefixIcon: Icon(LucideIcons.banknote, size: 18, color: AppColors.error),
                  filled: true,
                  fillColor: AppColors.surfaceElevatedDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: BorderSide(color: AppColors.error, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Description / Purpose
              const Text(
                'DESCRIPTION / VENDOR NOTE *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              TextField(
                controller: descriptionController,
                maxLines: 2,
                style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Paid Electricity Bill for August or Cleaning supplies invoice',
                  hintStyle: const TextStyle(color: AppColors.textMutedDark),
                  filled: true,
                  fillColor: AppColors.surfaceElevatedDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Paid from Drawer Toggle
              ValueListenableBuilder<bool>(
                valueListenable: paidFromDrawerNotifier,
                builder: (context, paidFromDrawer, _) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: paidFromDrawer
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.surfaceElevatedDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                        color: paidFromDrawer
                            ? AppColors.warning.withValues(alpha: 0.4)
                            : AppColors.borderDark,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: paidFromDrawer,
                          activeColor: AppColors.warning,
                          onChanged: (val) => paidFromDrawerNotifier.value = val ?? false,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Paid from Cash Register Till (Shift Pay-Out)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                paidFromDrawer
                                    ? 'Will automatically log a Pay-Out in the active cashier shift and reduce expected drawer cash balance.'
                                    : 'Paid externally (Bank transfer, Boss personal funds, or corporate card). Does not affect shift cash till.',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMutedDark,
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
              const SizedBox(height: AppDimensions.space24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCEL', style: TextStyle(color: AppColors.textMutedDark, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                    ),
                    icon: const Icon(LucideIcons.check, size: 18),
                    label: const Text(
                      'RECORD EXPENSE',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: () {
                      final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                      final description = descriptionController.text.trim();

                      if (amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid expense amount greater than zero.')),
                        );
                        return;
                      }

                      if (description.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a description or purpose for the expense.')),
                        );
                        return;
                      }

                      Navigator.of(context).pop({
                        'category': categoryNotifier.value,
                        'amount': amount,
                        'description': description,
                        'paidFromDrawer': paidFromDrawerNotifier.value,
                      });
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

  IconData _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.rent:
        return LucideIcons.building;
      case ExpenseCategory.utilities:
        return LucideIcons.zap;
      case ExpenseCategory.logistics:
        return LucideIcons.truck;
      case ExpenseCategory.maintenance:
        return LucideIcons.wrench;
      case ExpenseCategory.supplies:
        return LucideIcons.package;
      case ExpenseCategory.other:
        return LucideIcons.circleDollarSign;
    }
  }
}
