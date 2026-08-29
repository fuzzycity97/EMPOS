import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/expense.dart';
import '../bloc/erp_bloc.dart';
import '../bloc/erp_event.dart';
import '../bloc/erp_state.dart';
import '../widgets/cash_advance_dialog.dart';
import '../widgets/employee_form_dialog.dart';
import '../widgets/expense_dialog.dart';
import '../widgets/net_profit_report_widget.dart';
import '../widgets/salary_slips_dialog.dart';
import '../../../shift/presentation/widgets/consolidated_z_report_dialog.dart';

class BossPortalPage extends StatelessWidget {
  final ErpBloc? bloc;

  const BossPortalPage({
    super.key,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    ErpBloc? parentBloc;
    try {
      parentBloc = context.read<ErpBloc>();
    } catch (_) {}

    final activeBloc = bloc ?? parentBloc ?? sl<ErpBloc>();

    return BlocProvider.value(
      value: activeBloc..add(const LoadErpDataEvent()),
      child: const _BossPortalView(),
    );
  }
}

class _BossPortalView extends StatelessWidget {
  const _BossPortalView();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ErpBloc, ErpState>(
      listener: (context, state) {
        if (state is ErpLoaded && state.toastMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.toastMessage!),
              backgroundColor: AppColors.surfaceElevatedDark,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ErpLoading || state is ErpInitial) {
          return const Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (state is ErpError) {
          return Scaffold(
            backgroundColor: AppColors.backgroundDark,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.triangleAlert, color: AppColors.error, size: 48),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 16),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  ElevatedButton(
                    onPressed: () => context.read<ErpBloc>().add(const LoadErpDataEvent()),
                    child: const Text('RETRY'),
                  ),
                ],
              ),
            ),
          );
        }

        final loaded = state as ErpLoaded;

        return Scaffold(
          backgroundColor: AppColors.backgroundDark,
          body: Padding(
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header & Period Selector
                _buildHeader(context, loaded),
                const SizedBox(height: AppDimensions.space16),

                // Top 4 KPI Metrics Row
                _buildKpiMetrics(loaded),
                const SizedBox(height: AppDimensions.space16),

                // Sub-navigation Tabs
                _buildSubTabs(context, loaded),
                const SizedBox(height: AppDimensions.space12),

                // Main Sub-Tab Viewport
                Expanded(
                  child: _buildSubTabContent(context, loaded),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, ErpLoaded state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.space10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
                child: const Icon(LucideIcons.briefcase, color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: AppDimensions.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Boss Manager ERP & Payroll Hub',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Store Operational Expenses, Staff Payroll, and Cash Advances for ${state.selectedMonth}/${state.selectedYear}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            // Month Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: state.selectedMonth,
                      dropdownColor: AppColors.surfaceElevatedDark,
                      items: List.generate(12, (index) => index + 1).map((m) {
                        return DropdownMenuItem<int>(
                          value: m,
                          child: Text(
                            'Month $m',
                            style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        );
                      }).toList(),
                      onChanged: (newMonth) {
                        if (newMonth != null) {
                          context.read<ErpBloc>().add(
                                LoadErpDataEvent(month: newMonth, year: state.selectedYear),
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => ConsolidatedZReportDialog(),
                );
              },
              icon: const Icon(LucideIcons.fileSpreadsheet, size: 15),
              label: const Text('Consolidated Z-Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            IconButton(
              icon: const Icon(LucideIcons.rotateCcw, color: AppColors.textSecondaryDark, size: 18),
              tooltip: 'Refresh ERP Data',
              onPressed: () {
                context.read<ErpBloc>().add(
                      LoadErpDataEvent(month: state.selectedMonth, year: state.selectedYear),
                    );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKpiMetrics(ErpLoaded state) {
    return Row(
      children: [
        _kpiCard(
          title: 'Total Monthly Expenses',
          value: CurrencyFormatter.format(state.totalMonthlyExpenses),
          icon: LucideIcons.trendingDown,
          color: AppColors.error,
        ),
        const SizedBox(width: AppDimensions.space12),
        _kpiCard(
          title: 'Committed Net Payroll',
          value: CurrencyFormatter.format(state.totalMonthlyPayroll),
          icon: LucideIcons.users,
          color: AppColors.emerald,
        ),
        const SizedBox(width: AppDimensions.space12),
        _kpiCard(
          title: 'Deducted Staff Advances',
          value: CurrencyFormatter.format(state.totalMonthlyAdvances),
          icon: LucideIcons.handCoins,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppDimensions.space12),
        _kpiCard(
          title: 'Active Employees',
          value: '${state.totalActiveStaffCount} Staff',
          icon: LucideIcons.userCheck,
          color: AppColors.cyan,
        ),
      ],
    );
  }

  Widget _kpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubTabs(BuildContext context, ErpLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          _subTabButton(
            context: context,
            title: 'Store Operational Expenses (${state.expenses.length})',
            icon: LucideIcons.receipt,
            index: 0,
            currentIndex: state.activeSubTabIndex,
          ),
          _subTabButton(
            context: context,
            title: 'Staff & Monthly Payroll (${state.employees.length})',
            icon: LucideIcons.users,
            index: 1,
            currentIndex: state.activeSubTabIndex,
          ),
          _subTabButton(
            context: context,
            title: 'Staff Cash Advances (${state.cashAdvances.length})',
            icon: LucideIcons.handCoins,
            index: 2,
            currentIndex: state.activeSubTabIndex,
          ),
          _subTabButton(
            context: context,
            title: 'Partners & Equity (${state.partners.length})',
            icon: LucideIcons.handshake,
            index: 3,
            currentIndex: state.activeSubTabIndex,
          ),
        ],
      ),
    );
  }

  Widget _subTabButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: InkWell(
        onTap: () => context.read<ErpBloc>().add(SwitchErpSubTabEvent(index)),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : AppColors.textMutedDark,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubTabContent(BuildContext context, ErpLoaded state) {
    switch (state.activeSubTabIndex) {
      case 0:
        return _buildExpensesTab(context, state);
      case 1:
        return _buildPayrollTab(context, state);
      case 2:
        return _buildAdvancesTab(context, state);
      case 3:
        return NetProfitReportWidget(state: state);
      default:
        return _buildExpensesTab(context, state);
    }
  }

  // ── SUB-TAB 1: OPERATIONAL EXPENSES ────────────────────────────────────────
  Widget _buildExpensesTab(BuildContext context, ErpLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Operational Expense Ledger',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                ),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('RECORD EXPENSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (c) => ExpenseDialog(),
                  );

                  if (result != null && context.mounted) {
                    context.read<ErpBloc>().add(
                          RecordExpenseEvent(
                            category: result['category'] as ExpenseCategory,
                            amount: result['amount'] as double,
                            description: result['description'] as String,
                            date: DateTime.now(),
                            paidFromDrawer: result['paidFromDrawer'] as bool,
                          ),
                        );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Expenses Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevatedDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusSmall),
                topRight: Radius.circular(AppDimensions.radiusSmall),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('CATEGORY', style: _colHeaderStyle)),
                Expanded(flex: 4, child: Text('DESCRIPTION', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('PAYMENT SOURCE', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('DATE', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('AMOUNT', style: _colHeaderStyle, textAlign: TextAlign.right)),
                SizedBox(width: 40),
              ],
            ),
          ),

          // Expenses List
          Expanded(
            child: state.expenses.isEmpty
                ? const Center(
                    child: Text('No store expenses recorded yet.', style: TextStyle(color: AppColors.textMutedDark)),
                  )
                : ListView.separated(
                    itemCount: state.expenses.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.borderDark),
                    itemBuilder: (c, i) {
                      final exp = state.expenses[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        color: i.isEven ? Colors.transparent : AppColors.surfaceElevatedDark.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                exp.category.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primary),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                exp.description,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: exp.isPaidFromDrawer
                                      ? AppColors.warning.withValues(alpha: 0.15)
                                      : AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  exp.isPaidFromDrawer ? 'TILL PAY-OUT' : 'EXTERNAL',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: exp.isPaidFromDrawer ? AppColors.warning : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${exp.date.day}/${exp.date.month}/${exp.date.year}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                CurrencyFormatter.format(exp.amount),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.error,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.textMutedDark),
                              tooltip: 'Delete Expense',
                              onPressed: () => context.read<ErpBloc>().add(DeleteExpenseEvent(exp.id)),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── SUB-TAB 2: STAFF & PAYROLL ─────────────────────────────────────────────
  Widget _buildPayrollTab(BuildContext context, ErpLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Staff Profiles & Monthly Payroll',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
              ),
              Row(
                children: [
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevatedDark,
                      foregroundColor: AppColors.emerald,
                      side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                    ),
                    icon: const Icon(LucideIcons.fileSpreadsheet, size: 16),
                    label: const Text('CALCULATE / PRINT SALARY SLIPS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (c) => SalarySlipsDialog(
                          month: state.selectedMonth,
                          year: state.selectedYear,
                          salarySlips: state.salarySlips,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: AppDimensions.space10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                    ),
                    icon: const Icon(LucideIcons.userPlus, size: 16),
                    label: const Text('ADD EMPLOYEE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    onPressed: () async {
                      final newEmp = await showDialog<Employee>(
                        context: context,
                        builder: (c) => EmployeeFormDialog(),
                      );
                      if (newEmp != null && context.mounted) {
                        context.read<ErpBloc>().add(SaveEmployeeEvent(newEmp));
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Payroll Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevatedDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusSmall),
                topRight: Radius.circular(AppDimensions.radiusSmall),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('STAFF NAME', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('ROLE', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('BASE SALARY', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('PHONE', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('STATUS', style: _colHeaderStyle)),
                SizedBox(width: 80),
              ],
            ),
          ),

          // Employees List
          Expanded(
            child: state.employees.isEmpty
                ? const Center(
                    child: Text('No employees configured. Click "+ Add Employee".', style: TextStyle(color: AppColors.textMutedDark)),
                  )
                : ListView.separated(
                    itemCount: state.employees.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.borderDark),
                    itemBuilder: (c, i) {
                      final emp = state.employees[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        color: i.isEven ? Colors.transparent : AppColors.surfaceElevatedDark.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                emp.name,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimaryDark),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                emp.role.name.toUpperCase(),
                                style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                CurrencyFormatter.format(emp.baseSalary),
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimaryDark, fontFamily: 'monospace', fontWeight: FontWeight.w600),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                emp.phone ?? 'N/A',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: emp.isActive
                                      ? AppColors.emerald.withValues(alpha: 0.15)
                                      : AppColors.error.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  emp.isActive ? 'ACTIVE' : 'INACTIVE',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: emp.isActive ? AppColors.emerald : AppColors.error,
                                  ),
                                ),
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(LucideIcons.pencil, size: 16, color: AppColors.textSecondaryDark),
                                  tooltip: 'Edit Staff Profile',
                                  onPressed: () async {
                                    final updatedEmp = await showDialog<Employee>(
                                      context: context,
                                      builder: (c) => EmployeeFormDialog(employee: emp),
                                    );
                                    if (updatedEmp != null && context.mounted) {
                                      context.read<ErpBloc>().add(SaveEmployeeEvent(updatedEmp));
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.textMutedDark),
                                  tooltip: 'Delete Employee',
                                  onPressed: () => context.read<ErpBloc>().add(DeleteEmployeeEvent(emp.id)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── SUB-TAB 3: CASH ADVANCES ───────────────────────────────────────────────
  Widget _buildAdvancesTab(BuildContext context, ErpLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Staff Cash Advances & Loans Ledger',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimaryDark),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusMedium)),
                ),
                icon: const Icon(LucideIcons.plus, size: 16),
                label: const Text('ISSUE ADVANCE', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (c) => CashAdvanceDialog(employees: state.employees),
                  );

                  if (result != null && context.mounted) {
                    context.read<ErpBloc>().add(
                          AddCashAdvanceEvent(
                            employeeId: result['employeeId'] as String,
                            amount: result['amount'] as double,
                            reason: result['reason'] as String,
                            deductFromShiftDrawer: result['deductFromShiftDrawer'] as bool,
                          ),
                        );
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),

          // Advances Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: AppColors.surfaceElevatedDark,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.radiusSmall),
                topRight: Radius.circular(AppDimensions.radiusSmall),
              ),
            ),
            child: const Row(
              children: [
                Expanded(flex: 3, child: Text('EMPLOYEE', style: _colHeaderStyle)),
                Expanded(flex: 4, child: Text('REASON / NOTE', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('SHIFT DRAWER TILL', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('DATE', style: _colHeaderStyle)),
                Expanded(flex: 2, child: Text('ADVANCE AMOUNT', style: _colHeaderStyle, textAlign: TextAlign.right)),
              ],
            ),
          ),

          // Advances List
          Expanded(
            child: state.cashAdvances.isEmpty
                ? const Center(
                    child: Text('No staff cash advances recorded.', style: TextStyle(color: AppColors.textMutedDark)),
                  )
                : ListView.separated(
                    itemCount: state.cashAdvances.length,
                    separatorBuilder: (c, i) => const Divider(height: 1, color: AppColors.borderDark),
                    itemBuilder: (c, i) {
                      final adv = state.cashAdvances[i];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        color: i.isEven ? Colors.transparent : AppColors.surfaceElevatedDark.withValues(alpha: 0.3),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Text(
                                adv.employeeName ?? adv.employeeId,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textPrimaryDark),
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Text(
                                adv.reason,
                                style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: adv.shiftId != null
                                      ? AppColors.warning.withValues(alpha: 0.15)
                                      : AppColors.primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  adv.shiftId != null ? 'PAYOUT LOGGED' : 'EXTERNAL CASH',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: adv.shiftId != null ? AppColors.warning : AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '${adv.date.day}/${adv.date.month}/${adv.date.year}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '-${CurrencyFormatter.format(adv.amount)}',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.warning,
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
        ],
      ),
    );
  }
}

const TextStyle _colHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w800,
  color: AppColors.textSecondaryDark,
  letterSpacing: 0.5,
);
