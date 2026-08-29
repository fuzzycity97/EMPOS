import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/employee.dart';

class CashAdvanceDialog extends StatelessWidget {
  final List<Employee> employees;
  final TextEditingController amountController;
  final TextEditingController reasonController;
  final ValueNotifier<Employee?> selectedEmployeeNotifier;
  final ValueNotifier<bool> deductFromDrawerNotifier;

  const CashAdvanceDialog._({
    super.key,
    required this.employees,
    required this.amountController,
    required this.reasonController,
    required this.selectedEmployeeNotifier,
    required this.deductFromDrawerNotifier,
  });

  factory CashAdvanceDialog({
    Key? key,
    required List<Employee> employees,
    Employee? initialEmployee,
  }) {
    final activeEmployees = employees.where((e) => e.isActive).toList();
    final defaultEmployee = initialEmployee ?? (activeEmployees.isNotEmpty ? activeEmployees.first : null);

    return CashAdvanceDialog._(
      key: key,
      employees: activeEmployees,
      amountController: TextEditingController(),
      reasonController: TextEditingController(),
      selectedEmployeeNotifier: ValueNotifier<Employee?>(defaultEmployee),
      deductFromDrawerNotifier: ValueNotifier<bool>(true),
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
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: const Icon(LucideIcons.handCoins, color: AppColors.warning, size: 20),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      const Text(
                        'Issue Staff Cash Advance',
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

              // Employee Dropdown
              const Text(
                'SELECT EMPLOYEE *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              ValueListenableBuilder<Employee?>(
                valueListenable: selectedEmployeeNotifier,
                builder: (context, selectedEmployee, _) {
                  if (employees.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevatedDark,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: const Text(
                        'No active employees found. Please add employees first.',
                        style: TextStyle(color: AppColors.error, fontSize: 13),
                      ),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevatedDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<Employee>(
                        value: selectedEmployee,
                        isExpanded: true,
                        dropdownColor: AppColors.surfaceElevatedDark,
                        items: employees.map((emp) {
                          return DropdownMenuItem<Employee>(
                            value: emp,
                            child: Row(
                              children: [
                                const Icon(LucideIcons.user, size: 16, color: AppColors.primary),
                                const SizedBox(width: 10),
                                Text(
                                  emp.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    emp.role.name.toUpperCase(),
                                    style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (emp) {
                          if (emp != null) selectedEmployeeNotifier.value = emp;
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space16),

              // Advance Amount
              const Text(
                'ADVANCE AMOUNT (EGP) *',
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
                  prefixIcon: const Icon(LucideIcons.banknote, size: 18, color: AppColors.warning),
                  filled: true,
                  fillColor: AppColors.surfaceElevatedDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.warning, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Reason
              const Text(
                'REASON / ADVANCE NOTE *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'e.g. Mid-month personal advance, urgent transport loan',
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

              // Deduct from Drawer Toggle
              ValueListenableBuilder<bool>(
                valueListenable: deductFromDrawerNotifier,
                builder: (context, deductFromDrawer, _) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: deductFromDrawer
                          ? AppColors.warning.withValues(alpha: 0.1)
                          : AppColors.surfaceElevatedDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(
                        color: deductFromDrawer
                            ? AppColors.warning.withValues(alpha: 0.4)
                            : AppColors.borderDark,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: deductFromDrawer,
                          activeColor: AppColors.warning,
                          onChanged: (val) => deductFromDrawerNotifier.value = val ?? false,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hand Cash from Shift Till (Shift Pay-Out)',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                deductFromDrawer
                                    ? 'Will automatically record a Pay-Out in the active cashier shift and reduce expected drawer cash balance.'
                                    : 'Paid directly by Store Owner or via Bank Transfer. Shift till balance remains unchanged.',
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
                      backgroundColor: AppColors.warning,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                    ),
                    icon: const Icon(LucideIcons.handCoins, size: 18),
                    label: const Text(
                      'ISSUE ADVANCE',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: () {
                      final selectedEmployee = selectedEmployeeNotifier.value;
                      if (selectedEmployee == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please select an employee.')),
                        );
                        return;
                      }

                      final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                      final reason = reasonController.text.trim();

                      if (amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter an amount greater than zero.')),
                        );
                        return;
                      }

                      if (reason.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a reason for this cash advance.')),
                        );
                        return;
                      }

                      Navigator.of(context).pop({
                        'employeeId': selectedEmployee.id,
                        'amount': amount,
                        'reason': reason,
                        'deductFromShiftDrawer': deductFromDrawerNotifier.value,
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
}
