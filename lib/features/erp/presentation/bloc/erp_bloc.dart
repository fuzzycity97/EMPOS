import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/business_partner.dart';
import '../../domain/entities/cash_advance.dart';
import '../../domain/entities/dividend_payout.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/net_profit_report.dart';
import '../../domain/entities/net_salary_slip.dart';
import '../../domain/usecases/add_capital_injection_usecase.dart';
import '../../domain/usecases/add_cash_advance_usecase.dart';
import '../../domain/usecases/calculate_net_profit_report_usecase.dart';
import '../../domain/usecases/calculate_salary_slip_usecase.dart';
import '../../domain/usecases/delete_employee_usecase.dart';
import '../../domain/usecases/delete_partner_usecase.dart';
import '../../domain/usecases/get_cash_advances_usecase.dart';
import '../../domain/usecases/get_dividend_payouts_usecase.dart';
import '../../domain/usecases/get_employees_usecase.dart';
import '../../domain/usecases/get_expenses_usecase.dart';
import '../../domain/usecases/get_partners_usecase.dart';
import '../../domain/usecases/record_dividend_payout_usecase.dart';
import '../../domain/usecases/record_expense_usecase.dart';
import '../../domain/usecases/save_employee_usecase.dart';
import '../../domain/usecases/save_partner_usecase.dart';
import 'erp_event.dart';
import 'erp_state.dart';

class ErpBloc extends Bloc<ErpEvent, ErpState> {
  final GetEmployeesUseCase getEmployeesUseCase;
  final SaveEmployeeUseCase saveEmployeeUseCase;
  final DeleteEmployeeUseCase deleteEmployeeUseCase;
  final AddCashAdvanceUseCase addCashAdvanceUseCase;
  final GetCashAdvancesUseCase getCashAdvancesUseCase;
  final RecordExpenseUseCase recordExpenseUseCase;
  final GetExpensesUseCase getExpensesUseCase;
  final CalculateSalarySlipUseCase calculateSalarySlipUseCase;

  final GetPartnersUseCase getPartnersUseCase;
  final SavePartnerUseCase savePartnerUseCase;
  final DeletePartnerUseCase deletePartnerUseCase;
  final AddCapitalInjectionUseCase addCapitalInjectionUseCase;
  final RecordDividendPayoutUseCase recordDividendPayoutUseCase;
  final GetDividendPayoutsUseCase getDividendPayoutsUseCase;
  final CalculateNetProfitReportUseCase calculateNetProfitReportUseCase;

  ErpBloc({
    required this.getEmployeesUseCase,
    required this.saveEmployeeUseCase,
    required this.deleteEmployeeUseCase,
    required this.addCashAdvanceUseCase,
    required this.getCashAdvancesUseCase,
    required this.recordExpenseUseCase,
    required this.getExpensesUseCase,
    required this.calculateSalarySlipUseCase,
    required this.getPartnersUseCase,
    required this.savePartnerUseCase,
    required this.deletePartnerUseCase,
    required this.addCapitalInjectionUseCase,
    required this.recordDividendPayoutUseCase,
    required this.getDividendPayoutsUseCase,
    required this.calculateNetProfitReportUseCase,
  }) : super(const ErpInitial()) {
    on<LoadErpDataEvent>(_onLoadErpData);
    on<SaveEmployeeEvent>(_onSaveEmployee);
    on<DeleteEmployeeEvent>(_onDeleteEmployee);
    on<AddCashAdvanceEvent>(_onAddCashAdvance);
    on<RecordExpenseEvent>(_onRecordExpense);
    on<DeleteExpenseEvent>(_onDeleteExpense);
    on<CalculatePayrollEvent>(_onCalculatePayroll);
    on<SwitchErpSubTabEvent>(_onSwitchSubTab);
    on<SavePartnerEvent>(_onSavePartner);
    on<DeletePartnerEvent>(_onDeletePartner);
    on<AddCapitalInjectionEvent>(_onAddCapitalInjection);
    on<RecordDividendPayoutEvent>(_onRecordDividendPayout);
    on<GenerateNetProfitReportEvent>(_onGenerateNetProfitReport);
  }

  Future<void> _onLoadErpData(
    LoadErpDataEvent event,
    Emitter<ErpState> emit,
  ) async {
    final now = DateTime.now();
    final month = event.month ?? now.month;
    final year = event.year ?? now.year;

    emit(const ErpLoading());

    final empRes = await getEmployeesUseCase();
    final expRes = await getExpensesUseCase();
    final advRes = await getCashAdvancesUseCase();
    final slipsRes = await calculateSalarySlipUseCase.calculateAll(
      month: month,
      year: year,
    );
    final partnersRes = await getPartnersUseCase();
    final dividendsRes = await getDividendPayoutsUseCase();
    final profitRes = await calculateNetProfitReportUseCase(
      month: month,
      year: year,
    );

    List<Employee> employees = [];
    List<Expense> expenses = [];
    List<CashAdvance> advances = [];
    List<NetSalarySlip> slips = [];
    List<BusinessPartner> partners = [];
    List<DividendPayout> dividends = [];
    NetProfitReport? profitReport;

    empRes.fold((_) {}, (list) => employees = list);
    expRes.fold((_) {}, (list) => expenses = list);
    advRes.fold((_) {}, (list) => advances = list);
    slipsRes.fold((_) {}, (list) => slips = list);
    partnersRes.fold((_) {}, (list) => partners = list);
    dividendsRes.fold((_) {}, (list) => dividends = list);
    profitRes.fold((_) {}, (report) => profitReport = report);

    emit(
      ErpLoaded(
        employees: employees,
        expenses: expenses,
        cashAdvances: advances,
        salarySlips: slips,
        partners: partners,
        dividends: dividends,
        netProfitReport: profitReport,
        selectedMonth: month,
        selectedYear: year,
      ),
    );
  }

  Future<void> _onSaveEmployee(
    SaveEmployeeEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await saveEmployeeUseCase(event.employee);

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to save staff: ${failure.message}',
          ),
        );
      },
      (saved) {
        final updated = List<Employee>.from(currentState.employees);
        final index = updated.indexWhere((e) => e.id == saved.id);
        if (index >= 0) {
          updated[index] = saved;
        } else {
          updated.add(saved);
        }
        emit(
          currentState.copyWith(
            employees: updated,
            isProcessing: false,
            toastMessage: 'Employee profile updated successfully.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onDeleteEmployee(
    DeleteEmployeeEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await deleteEmployeeUseCase(event.employeeId);

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to delete staff: ${failure.message}',
          ),
        );
      },
      (_) {
        final updated = currentState.employees.where((e) => e.id != event.employeeId).toList();
        emit(
          currentState.copyWith(
            employees: updated,
            isProcessing: false,
            toastMessage: 'Staff profile removed.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onAddCashAdvance(
    AddCashAdvanceEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await addCashAdvanceUseCase(
      AddCashAdvanceParams(
        employeeId: event.employeeId,
        amount: event.amount,
        reason: event.reason,
        deductFromShiftDrawer: event.deductFromShiftDrawer,
      ),
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to issue advance: ${failure.message}',
          ),
        );
      },
      (advance) {
        final updated = List<CashAdvance>.from(currentState.cashAdvances)..insert(0, advance);
        emit(
          currentState.copyWith(
            cashAdvances: updated,
            isProcessing: false,
            toastMessage: 'Cash advance issued successfully.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onRecordExpense(
    RecordExpenseEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await recordExpenseUseCase(
      RecordExpenseParams(
        category: event.category,
        amount: event.amount,
        description: event.description,
        date: event.date,
        paidFromDrawer: event.paidFromDrawer,
      ),
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to record expense: ${failure.message}',
          ),
        );
      },
      (expense) {
        final updated = List<Expense>.from(currentState.expenses)..insert(0, expense);
        emit(
          currentState.copyWith(
            expenses: updated,
            isProcessing: false,
            toastMessage: 'Store expense logged.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onDeleteExpense(
    DeleteExpenseEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await recordExpenseUseCase.repository.deleteExpense(event.expenseId);

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to delete expense: ${failure.message}',
          ),
        );
      },
      (_) {
        final updated = currentState.expenses.where((e) => e.id != event.expenseId).toList();
        emit(
          currentState.copyWith(
            expenses: updated,
            isProcessing: false,
            toastMessage: 'Expense entry deleted.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onCalculatePayroll(
    CalculatePayrollEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await calculateSalarySlipUseCase.calculateAll(
      month: event.month,
      year: event.year,
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to compute payroll: ${failure.message}',
          ),
        );
      },
      (slips) {
        emit(
          currentState.copyWith(
            salarySlips: slips,
            selectedMonth: event.month,
            selectedYear: event.year,
            isProcessing: false,
            toastMessage: 'Payroll calculated for ${event.month}/${event.year}.',
          ),
        );
      },
    );
  }

  void _onSwitchSubTab(
    SwitchErpSubTabEvent event,
    Emitter<ErpState> emit,
  ) {
    if (state is ErpLoaded) {
      final currentState = state as ErpLoaded;
      emit(currentState.copyWith(activeSubTabIndex: event.subTabIndex));
    }
  }

  // ---------------------------------------------------------------------------
  // Partners & Equity Event Handlers
  // ---------------------------------------------------------------------------
  Future<void> _onSavePartner(
    SavePartnerEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await savePartnerUseCase(event.partner);

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to save partner: ${failure.message}',
          ),
        );
      },
      (saved) {
        final updated = List<BusinessPartner>.from(currentState.partners);
        final index = updated.indexWhere((p) => p.id == saved.id);
        if (index >= 0) {
          updated[index] = saved;
        } else {
          updated.add(saved);
        }
        emit(
          currentState.copyWith(
            partners: updated,
            isProcessing: false,
            toastMessage: 'Business partner saved successfully.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onDeletePartner(
    DeletePartnerEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await deletePartnerUseCase(event.partnerId);

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to delete partner: ${failure.message}',
          ),
        );
      },
      (_) {
        final updated = currentState.partners.where((p) => p.id != event.partnerId).toList();
        emit(
          currentState.copyWith(
            partners: updated,
            isProcessing: false,
            toastMessage: 'Business partner removed.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onAddCapitalInjection(
    AddCapitalInjectionEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await addCapitalInjectionUseCase(
      partnerId: event.partnerId,
      amount: event.amount,
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to inject capital: ${failure.message}',
          ),
        );
      },
      (updatedPartner) {
        final updated = List<BusinessPartner>.from(currentState.partners);
        final index = updated.indexWhere((p) => p.id == updatedPartner.id);
        if (index >= 0) {
          updated[index] = updatedPartner;
        }
        emit(
          currentState.copyWith(
            partners: updated,
            isProcessing: false,
            toastMessage: 'Capital injection recorded successfully.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onRecordDividendPayout(
    RecordDividendPayoutEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    emit(currentState.copyWith(isProcessing: true));

    final result = await recordDividendPayoutUseCase(
      RecordDividendPayoutParams(
        partnerId: event.partnerId,
        amount: event.amount,
        payoutDate: event.payoutDate,
        isPaidFromDrawer: event.isPaidFromDrawer,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to process dividend payout: ${failure.message}',
          ),
        );
      },
      (payout) {
        final updatedPayouts = List<DividendPayout>.from(currentState.dividends)..insert(0, payout);
        emit(
          currentState.copyWith(
            dividends: updatedPayouts,
            isProcessing: false,
            toastMessage: 'Dividend payout distributed successfully.',
          ),
        );
        add(LoadErpDataEvent(month: currentState.selectedMonth, year: currentState.selectedYear));
      },
    );
  }

  Future<void> _onGenerateNetProfitReport(
    GenerateNetProfitReportEvent event,
    Emitter<ErpState> emit,
  ) async {
    if (state is! ErpLoaded) return;
    final currentState = state as ErpLoaded;

    final month = event.month ?? currentState.selectedMonth;
    final year = event.year ?? currentState.selectedYear;

    emit(currentState.copyWith(isProcessing: true));

    final result = await calculateNetProfitReportUseCase(
      month: month,
      year: year,
    );

    result.fold(
      (failure) {
        emit(
          currentState.copyWith(
            isProcessing: false,
            toastMessage: 'Failed to generate profit report: ${failure.message}',
          ),
        );
      },
      (report) {
        emit(
          currentState.copyWith(
            netProfitReport: report,
            selectedMonth: month,
            selectedYear: year,
            isProcessing: false,
            toastMessage: 'Executive Profit Report updated for $month/$year.',
          ),
        );
      },
    );
  }
}
