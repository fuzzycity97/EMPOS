import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../orders/data/datasources/orders_local_data_source.dart';
import '../../../pos/domain/entities/order.dart';
import '../../../shift/data/datasources/shift_local_data_source.dart';
import '../../../shift/data/models/cash_transaction_model.dart';
import '../../../shift/domain/entities/cash_transaction.dart';
import '../../domain/entities/business_partner.dart';
import '../../domain/entities/cash_advance.dart';
import '../../domain/entities/dividend_payout.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/net_profit_report.dart';
import '../../domain/entities/net_salary_slip.dart';
import '../../domain/repositories/erp_repository.dart';
import '../datasources/erp_local_data_source.dart';
import '../models/business_partner_model.dart';
import '../models/cash_advance_model.dart';
import '../models/dividend_payout_model.dart';
import '../models/employee_model.dart';
import '../models/expense_model.dart';

class ErpRepositoryImpl implements ErpRepository {
  final ErpLocalDataSource localDataSource;
  final ShiftLocalDataSource shiftLocalDataSource;
  final OrdersLocalDataSource ordersLocalDataSource;

  ErpRepositoryImpl({
    required this.localDataSource,
    required this.shiftLocalDataSource,
    required this.ordersLocalDataSource,
  });

  @override
  Future<Either<Failure, List<Employee>>> getEmployees({
    bool? activeOnly,
  }) async {
    try {
      final employees = await localDataSource.getEmployees();
      if (activeOnly == true) {
        return Right(employees.where((e) => e.isActive).toList());
      }
      return Right(employees);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve employees: $e'));
    }
  }

  @override
  Future<Either<Failure, Employee>> getEmployeeById(String employeeId) async {
    try {
      final employee = await localDataSource.getEmployeeById(employeeId);
      if (employee == null) {
        return const Left(CacheFailure(message: 'Employee not found.'));
      }
      return Right(employee);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve employee $employeeId: $e'));
    }
  }

  @override
  Future<Either<Failure, Employee>> saveEmployee(Employee employee) async {
    try {
      final model = EmployeeModel.fromEntity(employee);
      await localDataSource.saveEmployee(model);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save employee: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteEmployee(String employeeId) async {
    try {
      await localDataSource.deleteEmployee(employeeId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete employee: $e'));
    }
  }

  @override
  Future<Either<Failure, CashAdvance>> addCashAdvance({
    required String employeeId,
    required double amount,
    required String reason,
    bool deductFromShiftDrawer = true,
  }) async {
    try {
      final employee = await localDataSource.getEmployeeById(employeeId);
      if (employee == null) {
        return const Left(CacheFailure(message: 'Employee not found.'));
      }

      if (amount <= 0) {
        return const Left(CacheFailure(message: 'Cash advance amount must be greater than zero.'));
      }

      String? activeShiftId;
      if (deductFromShiftDrawer) {
        final activeShift = await shiftLocalDataSource.getActiveShift();
        if (activeShift != null && activeShift.isOpen) {
          activeShiftId = activeShift.id;

          // Record PayOut in active Shift Cash Drawer
          final cashTx = CashTransactionModel(
            id: 'CTX-ADV-${DateTime.now().millisecondsSinceEpoch}',
            shiftId: activeShift.id,
            type: CashTransactionType.payOut,
            amount: amount,
            reason: 'Staff Advance: ${employee.name} ($reason)',
            timestamp: DateTime.now(),
          );
          await shiftLocalDataSource.saveCashTransaction(cashTx);
        }
      }

      final advance = CashAdvanceModel(
        id: 'ADV-${DateTime.now().millisecondsSinceEpoch}',
        employeeId: employeeId,
        employeeName: employee.name,
        amount: amount,
        date: DateTime.now(),
        reason: reason,
        shiftId: activeShiftId,
        isDeducted: false,
      );
      await localDataSource.saveCashAdvance(advance);

      return Right(advance);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add cash advance: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CashAdvance>>> getCashAdvances({
    String? employeeId,
    int? month,
    int? year,
  }) async {
    try {
      var advances = await localDataSource.getCashAdvances();

      if (employeeId != null && employeeId.isNotEmpty) {
        advances = advances.where((a) => a.employeeId == employeeId).toList();
      }

      if (month != null && year != null) {
        advances = advances.where((a) => a.date.month == month && a.date.year == year).toList();
      } else if (year != null) {
        advances = advances.where((a) => a.date.year == year).toList();
      }

      return Right(advances);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve cash advances: $e'));
    }
  }

  @override
  Future<Either<Failure, Expense>> recordExpense({
    required ExpenseCategory category,
    required double amount,
    required String description,
    required DateTime date,
    bool paidFromDrawer = false,
  }) async {
    try {
      if (amount <= 0) {
        return const Left(CacheFailure(message: 'Expense amount must be greater than zero.'));
      }

      String? activeShiftId;
      if (paidFromDrawer) {
        final activeShift = await shiftLocalDataSource.getActiveShift();
        if (activeShift != null && activeShift.isOpen) {
          activeShiftId = activeShift.id;

          // Record PayOut in active Shift Drawer
          final cashTx = CashTransactionModel(
            id: 'CTX-EXP-${DateTime.now().millisecondsSinceEpoch}',
            shiftId: activeShift.id,
            type: CashTransactionType.payOut,
            amount: amount,
            reason: 'Store Expense (${category.name.toUpperCase()}): $description',
            timestamp: DateTime.now(),
          );
          await shiftLocalDataSource.saveCashTransaction(cashTx);
        }
      }

      final expense = ExpenseModel(
        id: 'EXP-${DateTime.now().millisecondsSinceEpoch}',
        category: category,
        amount: amount,
        date: date,
        description: description,
        isPaidFromDrawer: paidFromDrawer,
        shiftId: activeShiftId,
      );
      await localDataSource.saveExpense(expense);

      return Right(expense);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to record expense: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Expense>>> getExpenses({
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var expenses = await localDataSource.getExpenses();

      if (category != null) {
        expenses = expenses.where((e) => e.category == category).toList();
      }

      if (startDate != null) {
        expenses = expenses.where((e) => e.date.isAfter(startDate) || e.date.isAtSameMomentAs(startDate)).toList();
      }

      if (endDate != null) {
        expenses = expenses.where((e) => e.date.isBefore(endDate) || e.date.isAtSameMomentAs(endDate)).toList();
      }

      return Right(expenses);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve expenses: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await localDataSource.deleteExpense(expenseId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete expense: $e'));
    }
  }

  @override
  Future<Either<Failure, NetSalarySlip>> calculateNetSalarySlip({
    required String employeeId,
    required int month,
    required int year,
    double bonuses = 0.0,
    double deductions = 0.0,
  }) async {
    try {
      final employee = await localDataSource.getEmployeeById(employeeId);
      if (employee == null) {
        return const Left(CacheFailure(message: 'Employee not found.'));
      }

      final allAdvances = await localDataSource.getCashAdvances();
      final monthAdvances = allAdvances
          .where((a) => a.employeeId == employeeId && a.date.month == month && a.date.year == year)
          .toList();

      final totalAdvances = monthAdvances.fold(0.0, (sum, a) => sum + a.amount);

      final slip = NetSalarySlip.compute(
        employeeId: employee.id,
        employeeName: employee.name,
        month: month,
        year: year,
        baseSalary: employee.baseSalary,
        totalAdvances: totalAdvances,
        bonuses: bonuses,
        deductions: deductions,
      );

      return Right(slip);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to calculate salary slip: $e'));
    }
  }

  @override
  Future<Either<Failure, List<NetSalarySlip>>> calculateAllSalarySlips({
    required int month,
    required int year,
  }) async {
    try {
      final employees = await localDataSource.getEmployees();
      final activeEmployees = employees.where((e) => e.isActive).toList();
      final allAdvances = await localDataSource.getCashAdvances();

      final List<NetSalarySlip> slips = [];

      for (final employee in activeEmployees) {
        final monthAdvances = allAdvances
            .where((a) => a.employeeId == employee.id && a.date.month == month && a.date.year == year)
            .toList();
        final totalAdvances = monthAdvances.fold(0.0, (sum, a) => sum + a.amount);

        slips.add(
          NetSalarySlip.compute(
            employeeId: employee.id,
            employeeName: employee.name,
            month: month,
            year: year,
            baseSalary: employee.baseSalary,
            totalAdvances: totalAdvances,
          ),
        );
      }

      return Right(slips);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to calculate all salary slips: $e'));
    }
  }

  // ---------------------------------------------------------------------------
  // Business Partners & Equity Profit Sharing Implementation
  // ---------------------------------------------------------------------------
  @override
  Future<Either<Failure, List<BusinessPartner>>> getPartners() async {
    try {
      final partners = await localDataSource.getPartners();
      return Right(partners);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve partners: $e'));
    }
  }

  @override
  Future<Either<Failure, BusinessPartner>> getPartnerById(String partnerId) async {
    try {
      final partner = await localDataSource.getPartnerById(partnerId);
      if (partner == null) {
        return const Left(CacheFailure(message: 'Business partner not found.'));
      }
      return Right(partner);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve partner $partnerId: $e'));
    }
  }

  @override
  Future<Either<Failure, BusinessPartner>> savePartner(BusinessPartner partner) async {
    try {
      final model = BusinessPartnerModel.fromEntity(partner);
      await localDataSource.savePartner(model);
      return Right(model);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save business partner: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deletePartner(String partnerId) async {
    try {
      await localDataSource.deletePartner(partnerId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete business partner: $e'));
    }
  }

  @override
  Future<Either<Failure, BusinessPartner>> addCapitalInjection({
    required String partnerId,
    required double amount,
  }) async {
    try {
      final partner = await localDataSource.getPartnerById(partnerId);
      if (partner == null) {
        return const Left(CacheFailure(message: 'Business partner not found.'));
      }

      if (amount <= 0) {
        return const Left(CacheFailure(message: 'Capital injection must be greater than zero.'));
      }

      final updated = partner.copyWith(
        totalInvestedCapital: partner.totalInvestedCapital + amount,
      );
      await localDataSource.savePartner(updated);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to record capital injection: $e'));
    }
  }

  @override
  Future<Either<Failure, DividendPayout>> recordDividendPayout({
    required String partnerId,
    required double amount,
    required DateTime payoutDate,
    bool isPaidFromDrawer = false,
    String? notes,
  }) async {
    try {
      final partner = await localDataSource.getPartnerById(partnerId);
      if (partner == null) {
        return const Left(CacheFailure(message: 'Business partner not found.'));
      }

      if (amount <= 0) {
        return const Left(CacheFailure(message: 'Dividend payout must be greater than zero.'));
      }

      String? activeShiftId;
      if (isPaidFromDrawer) {
        final activeShift = await shiftLocalDataSource.getActiveShift();
        if (activeShift != null && activeShift.isOpen) {
          activeShiftId = activeShift.id;

          // Record PayOut in active Shift Drawer
          final cashTx = CashTransactionModel(
            id: 'CTX-DIV-${DateTime.now().millisecondsSinceEpoch}',
            shiftId: activeShift.id,
            type: CashTransactionType.payOut,
            amount: amount,
            reason: 'Partner Dividend Payout: ${partner.name}${notes != null ? " ($notes)" : ""}',
            timestamp: DateTime.now(),
          );
          await shiftLocalDataSource.saveCashTransaction(cashTx);
        }
      }

      // 1. Persist Dividend Payout
      final payout = DividendPayoutModel(
        id: 'DIV-${DateTime.now().millisecondsSinceEpoch}',
        partnerId: partnerId,
        partnerName: partner.name,
        amount: amount,
        payoutDate: payoutDate,
        isPaidFromDrawer: isPaidFromDrawer,
        shiftId: activeShiftId,
        notes: notes,
      );
      await localDataSource.saveDividendPayout(payout);

      // 2. Update partner's total withdrawn dividends
      final updatedPartner = partner.copyWith(
        withdrawnDividends: partner.withdrawnDividends + amount,
      );
      await localDataSource.savePartner(updatedPartner);

      return Right(payout);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to record dividend payout: $e'));
    }
  }

  @override
  Future<Either<Failure, List<DividendPayout>>> getDividendPayouts({
    String? partnerId,
    int? month,
    int? year,
  }) async {
    try {
      var payouts = await localDataSource.getDividendPayouts();

      if (partnerId != null && partnerId.isNotEmpty) {
        payouts = payouts.where((p) => p.partnerId == partnerId).toList();
      }

      if (month != null && year != null) {
        payouts = payouts.where((p) => p.payoutDate.month == month && p.payoutDate.year == year).toList();
      } else if (year != null) {
        payouts = payouts.where((p) => p.payoutDate.year == year).toList();
      }

      return Right(payouts);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve dividend payouts: $e'));
    }
  }

  @override
  Future<Either<Failure, NetProfitReport>> calculateNetProfitReport({
    required int month,
    required int year,
  }) async {
    try {
      // 1. Fetch Orders and Refunds from OrdersLocalDataSource
      final allOrders = await ordersLocalDataSource.getAllOrders();
      final monthOrders = allOrders
          .where((o) => o.createdAt.month == month && o.createdAt.year == year)
          .toList();

      final allRefunds = await ordersLocalDataSource.getAllRefunds();
      final monthRefunds = allRefunds
          .where((r) => r.createdAt.month == month && r.createdAt.year == year)
          .toList();
      final refunds = monthRefunds.fold(0.0, (sum, r) => sum + r.refundTotal);

      double grossSales = 0.0;
      double estimatedCogs = 0.0;

      for (final order in monthOrders) {
        if (order.status == OrderStatus.paid) {
          grossSales += order.cart.grandTotal;
          // Approximate Cost of Goods Sold (COGS: default ~60% of item cost)
          for (final item in order.cart.items) {
            final cost = item.product.price * item.quantity * 0.60;
            estimatedCogs += cost;
          }
        }
      }

      // 2. Fetch Operating Expenses for month
      final allExpenses = await localDataSource.getExpenses();
      final monthExpenses = allExpenses
          .where((e) => e.date.month == month && e.date.year == year)
          .toList();
      final totalExpenses = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);

      // 3. Fetch Payroll Expenses for month
      final employees = await localDataSource.getEmployees();
      final activeEmployees = employees.where((e) => e.isActive).toList();
      final allAdvances = await localDataSource.getCashAdvances();

      double totalPayroll = 0.0;
      for (final employee in activeEmployees) {
        final monthAdvances = allAdvances
            .where((a) => a.employeeId == employee.id && a.date.month == month && a.date.year == year)
            .toList();
        final advancesSum = monthAdvances.fold(0.0, (s, a) => s + a.amount);
        final netSalary = (employee.baseSalary - advancesSum).clamp(0.0, double.infinity);
        totalPayroll += netSalary;
      }

      // 4. Fetch Partners & Equity Percentages
      final partners = await localDataSource.getPartners();
      final Map<String, double> equityMap = {
        for (final p in partners) p.id: p.equityPercentage,
      };

      // 5. Compute Full Net Profit Report
      final report = NetProfitReport.compute(
        month: month,
        year: year,
        grossSales: grossSales,
        refunds: refunds,
        cogs: estimatedCogs,
        operatingExpenses: totalExpenses,
        payrollExpenses: totalPayroll,
        equityPercentages: equityMap,
      );

      return Right(report);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to calculate net profit report: $e'));
    }
  }
}
