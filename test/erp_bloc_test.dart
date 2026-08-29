import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/erp/domain/entities/business_partner.dart';
import 'package:empos/features/erp/domain/entities/employee.dart';
import 'package:empos/features/erp/domain/entities/expense.dart';
import 'package:empos/features/erp/domain/entities/net_profit_report.dart';
import 'package:empos/features/erp/domain/usecases/add_capital_injection_usecase.dart';
import 'package:empos/features/erp/domain/usecases/add_cash_advance_usecase.dart';
import 'package:empos/features/erp/domain/usecases/calculate_net_profit_report_usecase.dart';
import 'package:empos/features/erp/domain/usecases/calculate_salary_slip_usecase.dart';
import 'package:empos/features/erp/domain/usecases/delete_employee_usecase.dart';
import 'package:empos/features/erp/domain/usecases/delete_partner_usecase.dart';
import 'package:empos/features/erp/domain/usecases/get_cash_advances_usecase.dart';
import 'package:empos/features/erp/domain/usecases/get_dividend_payouts_usecase.dart';
import 'package:empos/features/erp/domain/usecases/get_employees_usecase.dart';
import 'package:empos/features/erp/domain/usecases/get_expenses_usecase.dart';
import 'package:empos/features/erp/domain/usecases/get_partners_usecase.dart';
import 'package:empos/features/erp/domain/usecases/record_dividend_payout_usecase.dart';
import 'package:empos/features/erp/domain/usecases/record_expense_usecase.dart';
import 'package:empos/features/erp/domain/usecases/save_employee_usecase.dart';
import 'package:empos/features/erp/domain/usecases/save_partner_usecase.dart';
import 'package:empos/features/erp/presentation/bloc/erp_bloc.dart';
import 'package:empos/features/erp/presentation/bloc/erp_event.dart';
import 'package:empos/features/erp/presentation/bloc/erp_state.dart';

class MockGetEmployeesUseCase extends Mock implements GetEmployeesUseCase {}
class MockSaveEmployeeUseCase extends Mock implements SaveEmployeeUseCase {}
class MockDeleteEmployeeUseCase extends Mock implements DeleteEmployeeUseCase {}
class MockAddCashAdvanceUseCase extends Mock implements AddCashAdvanceUseCase {}
class MockGetCashAdvancesUseCase extends Mock implements GetCashAdvancesUseCase {}
class MockRecordExpenseUseCase extends Mock implements RecordExpenseUseCase {}
class MockGetExpensesUseCase extends Mock implements GetExpensesUseCase {}
class MockCalculateSalarySlipUseCase extends Mock implements CalculateSalarySlipUseCase {}
class MockGetPartnersUseCase extends Mock implements GetPartnersUseCase {}
class MockSavePartnerUseCase extends Mock implements SavePartnerUseCase {}
class MockDeletePartnerUseCase extends Mock implements DeletePartnerUseCase {}
class MockAddCapitalInjectionUseCase extends Mock implements AddCapitalInjectionUseCase {}
class MockRecordDividendPayoutUseCase extends Mock implements RecordDividendPayoutUseCase {}
class MockGetDividendPayoutsUseCase extends Mock implements GetDividendPayoutsUseCase {}
class MockCalculateNetProfitReportUseCase extends Mock implements CalculateNetProfitReportUseCase {}

void main() {
  late MockGetEmployeesUseCase mockGetEmployees;
  late MockSaveEmployeeUseCase mockSaveEmployee;
  late MockDeleteEmployeeUseCase mockDeleteEmployee;
  late MockAddCashAdvanceUseCase mockAddCashAdvance;
  late MockGetCashAdvancesUseCase mockGetCashAdvances;
  late MockRecordExpenseUseCase mockRecordExpense;
  late MockGetExpensesUseCase mockGetExpenses;
  late MockCalculateSalarySlipUseCase mockCalculateSalarySlip;
  late MockGetPartnersUseCase mockGetPartners;
  late MockSavePartnerUseCase mockSavePartner;
  late MockDeletePartnerUseCase mockDeletePartner;
  late MockAddCapitalInjectionUseCase mockAddCapitalInjection;
  late MockRecordDividendPayoutUseCase mockRecordDividendPayout;
  late MockGetDividendPayoutsUseCase mockGetDividendPayouts;
  late MockCalculateNetProfitReportUseCase mockCalculateNetProfitReport;
  late ErpBloc erpBloc;

  setUpAll(() {
    registerFallbackValue(
      Employee(
        id: 'fallback',
        name: 'fallback',
        hireDate: DateTime.now(),
      ),
    );
    registerFallbackValue(
      BusinessPartner(
        id: 'fallback',
        name: 'fallback',
        equityPercentage: 50.0,
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      RecordDividendPayoutParams(
        partnerId: 'fallback',
        amount: 0.0,
        payoutDate: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockGetEmployees = MockGetEmployeesUseCase();
    mockSaveEmployee = MockSaveEmployeeUseCase();
    mockDeleteEmployee = MockDeleteEmployeeUseCase();
    mockAddCashAdvance = MockAddCashAdvanceUseCase();
    mockGetCashAdvances = MockGetCashAdvancesUseCase();
    mockRecordExpense = MockRecordExpenseUseCase();
    mockGetExpenses = MockGetExpensesUseCase();
    mockCalculateSalarySlip = MockCalculateSalarySlipUseCase();
    mockGetPartners = MockGetPartnersUseCase();
    mockSavePartner = MockSavePartnerUseCase();
    mockDeletePartner = MockDeletePartnerUseCase();
    mockAddCapitalInjection = MockAddCapitalInjectionUseCase();
    mockRecordDividendPayout = MockRecordDividendPayoutUseCase();
    mockGetDividendPayouts = MockGetDividendPayoutsUseCase();
    mockCalculateNetProfitReport = MockCalculateNetProfitReportUseCase();

    erpBloc = ErpBloc(
      getEmployeesUseCase: mockGetEmployees,
      saveEmployeeUseCase: mockSaveEmployee,
      deleteEmployeeUseCase: mockDeleteEmployee,
      addCashAdvanceUseCase: mockAddCashAdvance,
      getCashAdvancesUseCase: mockGetCashAdvances,
      recordExpenseUseCase: mockRecordExpense,
      getExpensesUseCase: mockGetExpenses,
      calculateSalarySlipUseCase: mockCalculateSalarySlip,
      getPartnersUseCase: mockGetPartners,
      savePartnerUseCase: mockSavePartner,
      deletePartnerUseCase: mockDeletePartner,
      addCapitalInjectionUseCase: mockAddCapitalInjection,
      recordDividendPayoutUseCase: mockRecordDividendPayout,
      getDividendPayoutsUseCase: mockGetDividendPayouts,
      calculateNetProfitReportUseCase: mockCalculateNetProfitReport,
    );
  });

  tearDown(() {
    erpBloc.close();
  });

  final tEmployee = Employee(
    id: 'EMP-001',
    name: 'Karim Nabil',
    role: EmployeeRole.cashier,
    baseSalary: 6000.0,
    hireDate: DateTime(2026, 1, 1),
  );

  final tExpense = Expense(
    id: 'EXP-001',
    category: ExpenseCategory.utilities,
    amount: 850.0,
    date: DateTime(2026, 8, 15),
    description: 'Electricity Bill',
  );

  final tPartner = BusinessPartner(
    id: 'PTR-001',
    name: 'Ahmed Hegazy',
    equityPercentage: 50.0,
    totalInvestedCapital: 100000.0,
    createdAt: DateTime(2026, 1, 1),
  );

  final tProfitReport = NetProfitReport.compute(
    month: 8,
    year: 2026,
    grossSales: 50000.0,
    refunds: 1000.0,
    cogs: 20000.0,
    operatingExpenses: 5000.0,
    payrollExpenses: 10000.0,
    equityPercentages: {'PTR-001': 50.0},
  );

  group('ErpBloc Tests', () {
    test('initial state should be ErpInitial', () {
      expect(erpBloc.state, equals(const ErpInitial()));
    });

    test('emits [ErpLoading, ErpLoaded] when LoadErpDataEvent succeeds', () async {
      when(() => mockGetEmployees()).thenAnswer((_) async => Right([tEmployee]));
      when(() => mockGetExpenses()).thenAnswer((_) async => Right([tExpense]));
      when(() => mockGetCashAdvances()).thenAnswer((_) async => const Right([]));
      when(() => mockCalculateSalarySlip.calculateAll(month: 8, year: 2026))
          .thenAnswer((_) async => const Right([]));
      when(() => mockGetPartners()).thenAnswer((_) async => Right([tPartner]));
      when(() => mockGetDividendPayouts()).thenAnswer((_) async => const Right([]));
      when(() => mockCalculateNetProfitReport(month: 8, year: 2026))
          .thenAnswer((_) async => Right(tProfitReport));

      final expectedStates = [
        const ErpLoading(),
        isA<ErpLoaded>()
            .having((s) => s.employees.length, 'employees length', 1)
            .having((s) => s.expenses.length, 'expenses length', 1)
            .having((s) => s.partners.length, 'partners length', 1)
            .having((s) => s.netProfitReport != null, 'has report', true),
      ];

      expectLater(erpBloc.stream, emitsInOrder(expectedStates));

      erpBloc.add(const LoadErpDataEvent(month: 8, year: 2026));
    });

    test('switches active sub tab when SwitchErpSubTabEvent is added', () async {
      when(() => mockGetEmployees()).thenAnswer((_) async => Right([tEmployee]));
      when(() => mockGetExpenses()).thenAnswer((_) async => Right([tExpense]));
      when(() => mockGetCashAdvances()).thenAnswer((_) async => const Right([]));
      when(() => mockCalculateSalarySlip.calculateAll(month: 8, year: 2026))
          .thenAnswer((_) async => const Right([]));
      when(() => mockGetPartners()).thenAnswer((_) async => Right([tPartner]));
      when(() => mockGetDividendPayouts()).thenAnswer((_) async => const Right([]));
      when(() => mockCalculateNetProfitReport(month: 8, year: 2026))
          .thenAnswer((_) async => Right(tProfitReport));

      erpBloc.add(const LoadErpDataEvent(month: 8, year: 2026));
      await Future.delayed(const Duration(milliseconds: 50));

      erpBloc.add(const SwitchErpSubTabEvent(3)); // Partners Tab

      expectLater(
        erpBloc.stream,
        emits(
          isA<ErpLoaded>().having((s) => s.activeSubTabIndex, 'activeSubTabIndex', 3),
        ),
      );
    });
  });
}
