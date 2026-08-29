import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/business_partner_model.dart';
import '../models/cash_advance_model.dart';
import '../models/dividend_payout_model.dart';
import '../models/employee_model.dart';
import '../models/expense_model.dart';

abstract class ErpLocalDataSource {
  Future<List<EmployeeModel>> getEmployees();
  Future<EmployeeModel?> getEmployeeById(String employeeId);
  Future<void> saveEmployee(EmployeeModel employee);
  Future<void> deleteEmployee(String employeeId);

  Future<List<CashAdvanceModel>> getCashAdvances();
  Future<void> saveCashAdvance(CashAdvanceModel advance);

  Future<List<ExpenseModel>> getExpenses();
  Future<void> saveExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);

  Future<List<BusinessPartnerModel>> getPartners();
  Future<BusinessPartnerModel?> getPartnerById(String partnerId);
  Future<void> savePartner(BusinessPartnerModel partner);
  Future<void> deletePartner(String partnerId);

  Future<List<DividendPayoutModel>> getDividendPayouts();
  Future<void> saveDividendPayout(DividendPayoutModel payout);
}

class ErpLocalDataSourceImpl implements ErpLocalDataSource {
  static const String employeesBoxName = 'empos_employees_box';
  static const String advancesBoxName = 'empos_cash_advances_box';
  static const String expensesBoxName = 'empos_expenses_box';
  static const String partnersBoxName = 'empos_business_partners_box';
  static const String dividendsBoxName = 'empos_dividend_payouts_box';

  Future<Box<dynamic>> _openBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return await Hive.openBox<dynamic>(boxName);
  }

  Future<Box<dynamic>> get _employeesBox async => _openBox(employeesBoxName);
  Future<Box<dynamic>> get _advancesBox async => _openBox(advancesBoxName);
  Future<Box<dynamic>> get _expensesBox async => _openBox(expensesBoxName);
  Future<Box<dynamic>> get _partnersBox async => _openBox(partnersBoxName);
  Future<Box<dynamic>> get _dividendsBox async => _openBox(dividendsBoxName);

  @override
  Future<List<EmployeeModel>> getEmployees() async {
    try {
      final box = await _employeesBox;
      final List<EmployeeModel> employees = [];

      for (final raw in box.values) {
        if (raw != null) {
          employees.add(EmployeeModel.fromRaw(raw));
        }
      }

      employees.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return employees;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve employees: $e');
    }
  }

  @override
  Future<EmployeeModel?> getEmployeeById(String employeeId) async {
    try {
      final box = await _employeesBox;
      final raw = box.get(employeeId);
      if (raw == null) return null;

      return EmployeeModel.fromRaw(raw);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve employee $employeeId: $e');
    }
  }

  @override
  Future<void> saveEmployee(EmployeeModel employee) async {
    try {
      final box = await _employeesBox;
      await box.put(employee.id, jsonEncode(employee.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save employee: $e');
    }
  }

  @override
  Future<void> deleteEmployee(String employeeId) async {
    try {
      final box = await _employeesBox;
      await box.delete(employeeId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete employee: $e');
    }
  }

  @override
  Future<List<CashAdvanceModel>> getCashAdvances() async {
    try {
      final box = await _advancesBox;
      final List<CashAdvanceModel> advances = [];

      for (final raw in box.values) {
        if (raw != null) {
          advances.add(CashAdvanceModel.fromRaw(raw));
        }
      }

      advances.sort((a, b) => b.date.compareTo(a.date));
      return advances;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve cash advances: $e');
    }
  }

  @override
  Future<void> saveCashAdvance(CashAdvanceModel advance) async {
    try {
      final box = await _advancesBox;
      await box.put(advance.id, jsonEncode(advance.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save cash advance: $e');
    }
  }

  @override
  Future<List<ExpenseModel>> getExpenses() async {
    try {
      final box = await _expensesBox;
      final List<ExpenseModel> expenses = [];

      for (final raw in box.values) {
        if (raw != null) {
          expenses.add(ExpenseModel.fromRaw(raw));
        }
      }

      expenses.sort((a, b) => b.date.compareTo(a.date));
      return expenses;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve expenses: $e');
    }
  }

  @override
  Future<void> saveExpense(ExpenseModel expense) async {
    try {
      final box = await _expensesBox;
      await box.put(expense.id, jsonEncode(expense.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save expense: $e');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      final box = await _expensesBox;
      await box.delete(expenseId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete expense: $e');
    }
  }

  @override
  Future<List<BusinessPartnerModel>> getPartners() async {
    try {
      final box = await _partnersBox;
      final List<BusinessPartnerModel> partners = [];

      for (final raw in box.values) {
        if (raw != null) {
          partners.add(BusinessPartnerModel.fromRaw(raw));
        }
      }

      partners.sort((a, b) => b.equityPercentage.compareTo(a.equityPercentage));
      return partners;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve business partners: $e');
    }
  }

  @override
  Future<BusinessPartnerModel?> getPartnerById(String partnerId) async {
    try {
      final box = await _partnersBox;
      final raw = box.get(partnerId);
      if (raw == null) return null;

      return BusinessPartnerModel.fromRaw(raw);
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve partner $partnerId: $e');
    }
  }

  @override
  Future<void> savePartner(BusinessPartnerModel partner) async {
    try {
      final box = await _partnersBox;
      await box.put(partner.id, jsonEncode(partner.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save business partner: $e');
    }
  }

  @override
  Future<void> deletePartner(String partnerId) async {
    try {
      final box = await _partnersBox;
      await box.delete(partnerId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete business partner: $e');
    }
  }

  @override
  Future<List<DividendPayoutModel>> getDividendPayouts() async {
    try {
      final box = await _dividendsBox;
      final List<DividendPayoutModel> payouts = [];

      for (final raw in box.values) {
        if (raw != null) {
          payouts.add(DividendPayoutModel.fromRaw(raw));
        }
      }

      payouts.sort((a, b) => b.payoutDate.compareTo(a.payoutDate));
      return payouts;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve dividend payouts: $e');
    }
  }

  @override
  Future<void> saveDividendPayout(DividendPayoutModel payout) async {
    try {
      final box = await _dividendsBox;
      await box.put(payout.id, jsonEncode(payout.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save dividend payout: $e');
    }
  }
}
