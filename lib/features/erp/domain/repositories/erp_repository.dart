import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/business_partner.dart';
import '../entities/cash_advance.dart';
import '../entities/dividend_payout.dart';
import '../entities/employee.dart';
import '../entities/expense.dart';
import '../entities/net_profit_report.dart';
import '../entities/net_salary_slip.dart';

abstract class ErpRepository {
  Future<Either<Failure, List<Employee>>> getEmployees({bool? activeOnly});

  Future<Either<Failure, Employee>> getEmployeeById(String employeeId);

  Future<Either<Failure, Employee>> saveEmployee(Employee employee);

  Future<Either<Failure, void>> deleteEmployee(String employeeId);

  Future<Either<Failure, CashAdvance>> addCashAdvance({
    required String employeeId,
    required double amount,
    required String reason,
    bool deductFromShiftDrawer = true,
  });

  Future<Either<Failure, List<CashAdvance>>> getCashAdvances({
    String? employeeId,
    int? month,
    int? year,
  });

  Future<Either<Failure, Expense>> recordExpense({
    required ExpenseCategory category,
    required double amount,
    required String description,
    required DateTime date,
    bool paidFromDrawer = false,
  });

  Future<Either<Failure, List<Expense>>> getExpenses({
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, void>> deleteExpense(String expenseId);

  Future<Either<Failure, NetSalarySlip>> calculateNetSalarySlip({
    required String employeeId,
    required int month,
    required int year,
    double bonuses = 0.0,
    double deductions = 0.0,
  });

  Future<Either<Failure, List<NetSalarySlip>>> calculateAllSalarySlips({
    required int month,
    required int year,
  });

  // Business Partners & Equity Profit Sharing
  Future<Either<Failure, List<BusinessPartner>>> getPartners();

  Future<Either<Failure, BusinessPartner>> getPartnerById(String partnerId);

  Future<Either<Failure, BusinessPartner>> savePartner(BusinessPartner partner);

  Future<Either<Failure, void>> deletePartner(String partnerId);

  Future<Either<Failure, BusinessPartner>> addCapitalInjection({
    required String partnerId,
    required double amount,
  });

  Future<Either<Failure, DividendPayout>> recordDividendPayout({
    required String partnerId,
    required double amount,
    required DateTime payoutDate,
    bool isPaidFromDrawer = false,
    String? notes,
  });

  Future<Either<Failure, List<DividendPayout>>> getDividendPayouts({
    String? partnerId,
    int? month,
    int? year,
  });

  Future<Either<Failure, NetProfitReport>> calculateNetProfitReport({
    required int month,
    required int year,
  });
}
