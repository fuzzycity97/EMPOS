import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/net_salary_slip.dart';

class SalarySlipsDialog extends StatelessWidget {
  final int month;
  final int year;
  final List<NetSalarySlip> salarySlips;

  const SalarySlipsDialog({
    super.key,
    required this.month,
    required this.year,
    required this.salarySlips,
  });

  @override
  Widget build(BuildContext context) {
    final totalPayroll = salarySlips.fold(0.0, (s, slip) => s + slip.netPayable);
    final totalBase = salarySlips.fold(0.0, (s, slip) => s + slip.baseSalary);
    final totalAdvances = salarySlips.fold(0.0, (s, slip) => s + slip.totalAdvances);

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        width: 780,
        height: 600,
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
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
                        color: AppColors.emerald.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: Icon(LucideIcons.fileSpreadsheet, color: AppColors.emerald, size: 22),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Staff Payroll & Net Salary Slips ($month/$year)',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Comprehensive breakdown of base salary, mid-month cash advances, and final net payable balance.',
                          style: TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                        ),
                      ],
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

            // Summary Metric Chips
            Row(
              children: [
                _metricChip('Total Base Salaries', CurrencyFormatter.format(totalBase), AppColors.primary),
                const SizedBox(width: AppDimensions.space12),
                _metricChip('Deducted Advances', CurrencyFormatter.format(totalAdvances), AppColors.warning),
                const SizedBox(width: AppDimensions.space12),
                _metricChip('Net Payable Payout', CurrencyFormatter.format(totalPayroll), AppColors.emerald),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppDimensions.radiusMedium),
                  topRight: Radius.circular(AppDimensions.radiusMedium),
                ),
                border: Border(bottom: BorderSide(color: AppColors.borderDark)),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text('EMPLOYEE', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('BASE SALARY', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('ADVANCES', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('BONUS / DEDUCT', style: _headerStyle)),
                  Expanded(flex: 2, child: Text('NET PAYABLE', style: _headerStyle, textAlign: TextAlign.right)),
                ],
              ),
            ),

            // Table Content
            Expanded(
              child: salarySlips.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.userX, size: 40, color: AppColors.textMutedDark.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'No active employees found for this payroll period.',
                            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: salarySlips.length,
                      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.borderDark),
                      itemBuilder: (context, index) {
                        final slip = salarySlips[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          color: index.isEven ? AppColors.surfaceDark : AppColors.surfaceElevatedDark.withValues(alpha: 0.5),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 3,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                      ),
                                      child: const Icon(LucideIcons.user, size: 14, color: AppColors.primary),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        slip.employeeName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimaryDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  CurrencyFormatter.format(slip.baseSalary),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimaryDark,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  slip.totalAdvances > 0
                                      ? '-${CurrencyFormatter.format(slip.totalAdvances)}'
                                      : '0.00 EGP',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: slip.totalAdvances > 0 ? AppColors.warning : AppColors.textMutedDark,
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  '+${slip.bonuses.toStringAsFixed(0)} / -${slip.deductions.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMutedDark,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  CurrencyFormatter.format(slip.netPayable),
                                  textAlign: TextAlign.right,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.emerald,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Footer actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${salarySlips.length} Employees in this payroll cycle',
                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.surfaceElevatedDark,
                    foregroundColor: AppColors.textPrimaryDark,
                    side: const BorderSide(color: AppColors.borderDark),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                  ),
                  icon: const Icon(LucideIcons.printer, size: 16),
                  label: const Text('PRINT ALL PAYROLL VOUCHERS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sent payroll slips for $month/$year to receipt/A4 printer.')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metricChip(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace'),
            ),
          ],
        ),
      ),
    );
  }
}

const TextStyle _headerStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: AppColors.textSecondaryDark,
  letterSpacing: 0.5,
);
