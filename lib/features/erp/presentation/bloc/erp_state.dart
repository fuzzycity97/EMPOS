import 'package:equatable/equatable.dart';
import '../../domain/entities/business_partner.dart';
import '../../domain/entities/cash_advance.dart';
import '../../domain/entities/dividend_payout.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/net_profit_report.dart';
import '../../domain/entities/net_salary_slip.dart';

abstract class ErpState extends Equatable {
  const ErpState();

  @override
  List<Object?> get props => [];
}

class ErpInitial extends ErpState {
  const ErpInitial();
}

class ErpLoading extends ErpState {
  const ErpLoading();
}

class ErpLoaded extends ErpState {
  final List<Employee> employees;
  final List<Expense> expenses;
  final List<CashAdvance> cashAdvances;
  final List<NetSalarySlip> salarySlips;
  final List<BusinessPartner> partners;
  final List<DividendPayout> dividends;
  final NetProfitReport? netProfitReport;
  final int selectedMonth;
  final int selectedYear;
  final int activeSubTabIndex; // 0: Expenses, 1: Staff & Payroll, 2: Cash Advances, 3: Partners & Equity
  final bool isProcessing;
  final String? toastMessage;

  const ErpLoaded({
    required this.employees,
    required this.expenses,
    required this.cashAdvances,
    required this.salarySlips,
    this.partners = const [],
    this.dividends = const [],
    this.netProfitReport,
    required this.selectedMonth,
    required this.selectedYear,
    this.activeSubTabIndex = 0,
    this.isProcessing = false,
    this.toastMessage,
  });

  double get totalMonthlyExpenses => expenses
      .where((e) => e.date.month == selectedMonth && e.date.year == selectedYear)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get totalMonthlyPayroll => salarySlips.fold(0.0, (sum, s) => sum + s.netPayable);

  double get totalMonthlyAdvances => cashAdvances
      .where((a) => a.date.month == selectedMonth && a.date.year == selectedYear)
      .fold(0.0, (sum, a) => sum + a.amount);

  int get totalActiveStaffCount => employees.where((e) => e.isActive).length;

  double get totalPartnerEquity => partners.fold(0.0, (sum, p) => sum + p.equityPercentage);

  double get totalInvestedCapitalSum => partners.fold(0.0, (sum, p) => sum + p.totalInvestedCapital);

  double get totalDividendsDistributed => dividends.fold(0.0, (sum, d) => sum + d.amount);

  double get monthlyDividendsDistributed => dividends
      .where((d) => d.payoutDate.month == selectedMonth && d.payoutDate.year == selectedYear)
      .fold(0.0, (sum, d) => sum + d.amount);

  ErpLoaded copyWith({
    List<Employee>? employees,
    List<Expense>? expenses,
    List<CashAdvance>? cashAdvances,
    List<NetSalarySlip>? salarySlips,
    List<BusinessPartner>? partners,
    List<DividendPayout>? dividends,
    NetProfitReport? netProfitReport,
    int? selectedMonth,
    int? selectedYear,
    int? activeSubTabIndex,
    bool? isProcessing,
    String? toastMessage,
    bool clearToast = false,
  }) {
    return ErpLoaded(
      employees: employees ?? this.employees,
      expenses: expenses ?? this.expenses,
      cashAdvances: cashAdvances ?? this.cashAdvances,
      salarySlips: salarySlips ?? this.salarySlips,
      partners: partners ?? this.partners,
      dividends: dividends ?? this.dividends,
      netProfitReport: netProfitReport ?? this.netProfitReport,
      selectedMonth: selectedMonth ?? this.selectedMonth,
      selectedYear: selectedYear ?? this.selectedYear,
      activeSubTabIndex: activeSubTabIndex ?? this.activeSubTabIndex,
      isProcessing: isProcessing ?? this.isProcessing,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    );
  }

  @override
  List<Object?> get props => [
        employees,
        expenses,
        cashAdvances,
        salarySlips,
        partners,
        dividends,
        netProfitReport,
        selectedMonth,
        selectedYear,
        activeSubTabIndex,
        isProcessing,
        toastMessage,
      ];
}

class ErpError extends ErpState {
  final String message;

  const ErpError(this.message);

  @override
  List<Object?> get props => [message];
}
