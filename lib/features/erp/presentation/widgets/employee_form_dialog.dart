import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/employee.dart';

class EmployeeFormDialog extends StatelessWidget {
  final Employee? employee;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController baseSalaryController;
  final TextEditingController hourlyRateController;
  final ValueNotifier<EmployeeRole> roleNotifier;
  final ValueNotifier<bool> isActiveNotifier;

  const EmployeeFormDialog._({
    super.key,
    this.employee,
    required this.nameController,
    required this.phoneController,
    required this.baseSalaryController,
    required this.hourlyRateController,
    required this.roleNotifier,
    required this.isActiveNotifier,
  });

  factory EmployeeFormDialog({
    Key? key,
    Employee? employee,
  }) {
    return EmployeeFormDialog._(
      key: key,
      employee: employee,
      nameController: TextEditingController(text: employee?.name ?? ''),
      phoneController: TextEditingController(text: employee?.phone ?? ''),
      baseSalaryController: TextEditingController(
        text: employee != null && employee.baseSalary > 0
            ? employee.baseSalary.toStringAsFixed(2)
            : '',
      ),
      hourlyRateController: TextEditingController(
        text: employee?.hourlyRate != null && employee!.hourlyRate! > 0
            ? employee.hourlyRate!.toStringAsFixed(2)
            : '',
      ),
      roleNotifier: ValueNotifier<EmployeeRole>(employee?.role ?? EmployeeRole.cashier),
      isActiveNotifier: ValueNotifier<bool>(employee?.isActive ?? true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = employee != null;

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        width: 520,
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
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: const Icon(LucideIcons.userCheck, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Text(
                        isEditing ? 'Edit Staff Profile' : 'Add New Employee',
                        style: const TextStyle(
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

              // Full Name
              const Text(
                'FULL NAME *',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondaryDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: AppDimensions.space6),
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Mostafa Samir',
                  hintStyle: const TextStyle(color: AppColors.textMutedDark),
                  prefixIcon: const Icon(LucideIcons.user, size: 18, color: AppColors.textMutedDark),
                  filled: true,
                  fillColor: AppColors.surfaceElevatedDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Phone & Role Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PHONE NUMBER',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space6),
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: '010XXXXXXXX',
                            hintStyle: const TextStyle(color: AppColors.textMutedDark),
                            prefixIcon: const Icon(LucideIcons.phone, size: 18, color: AppColors.textMutedDark),
                            filled: true,
                            fillColor: AppColors.surfaceElevatedDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.borderDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'STORE ROLE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space6),
                        ValueListenableBuilder<EmployeeRole>(
                          valueListenable: roleNotifier,
                          builder: (context, currentRole, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevatedDark,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                border: Border.all(color: AppColors.borderDark),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<EmployeeRole>(
                                  value: currentRole,
                                  isExpanded: true,
                                  dropdownColor: AppColors.surfaceElevatedDark,
                                  items: EmployeeRole.values.map((r) {
                                    return DropdownMenuItem<EmployeeRole>(
                                      value: r,
                                      child: Text(
                                        r.name.toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimaryDark,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (newRole) {
                                    if (newRole != null) roleNotifier.value = newRole;
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Base Monthly Salary & Hourly Rate
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'BASE MONTHLY SALARY (EGP) *',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space6),
                        TextField(
                          controller: baseSalaryController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 14, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: 'e.g. 6000.00',
                            hintStyle: const TextStyle(color: AppColors.textMutedDark),
                            prefixIcon: const Icon(LucideIcons.banknote, size: 18, color: AppColors.emerald),
                            filled: true,
                            fillColor: AppColors.surfaceElevatedDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.borderDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'HOURLY OVERTIME RATE (OPTIONAL)',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondaryDark,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space6),
                        TextField(
                          controller: hourlyRateController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                          ],
                          style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 14, fontFamily: 'monospace'),
                          decoration: InputDecoration(
                            hintText: 'e.g. 40.00',
                            hintStyle: const TextStyle(color: AppColors.textMutedDark),
                            prefixIcon: Icon(LucideIcons.clock, size: 18, color: AppColors.cyan),
                            filled: true,
                            fillColor: AppColors.surfaceElevatedDark,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                              borderSide: const BorderSide(color: AppColors.borderDark),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Active Employment Status Toggle
              ValueListenableBuilder<bool>(
                valueListenable: isActiveNotifier,
                builder: (context, isActive, _) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevatedDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isActive ? LucideIcons.circleCheck : LucideIcons.circleSlash,
                              size: 18,
                              color: isActive ? AppColors.emerald : AppColors.error,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isActive ? 'Active Employee' : 'Inactive / Former Staff',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: isActive ? AppColors.textPrimaryDark : AppColors.textMutedDark,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: isActive,
                          activeThumbColor: AppColors.emerald,
                          onChanged: (val) => isActiveNotifier.value = val,
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
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                    ),
                    icon: const Icon(LucideIcons.save, size: 18),
                    label: Text(
                      isEditing ? 'SAVE CHANGES' : 'CREATE EMPLOYEE',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter an employee name.')),
                        );
                        return;
                      }

                      final baseSalary = double.tryParse(baseSalaryController.text.trim()) ?? 0.0;
                      final hourlyRate = double.tryParse(hourlyRateController.text.trim());

                      final employeeObj = Employee(
                        id: employee?.id ?? 'EMP-${DateTime.now().millisecondsSinceEpoch}',
                        name: name,
                        phone: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                        role: roleNotifier.value,
                        baseSalary: baseSalary,
                        hourlyRate: hourlyRate,
                        hireDate: employee?.hireDate ?? DateTime.now(),
                        isActive: isActiveNotifier.value,
                      );

                      Navigator.of(context).pop(employeeObj);
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
