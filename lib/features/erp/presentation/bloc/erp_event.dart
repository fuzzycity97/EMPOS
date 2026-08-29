import 'package:equatable/equatable.dart';
import '../../domain/entities/business_partner.dart';
import '../../domain/entities/employee.dart';
import '../../domain/entities/expense.dart';

abstract class ErpEvent extends Equatable {
  const ErpEvent();

  @override
  List<Object?> get props => [];
}

class LoadErpDataEvent extends ErpEvent {
  final int? month;
  final int? year;

  const LoadErpDataEvent({this.month, this.year});

  @override
  List<Object?> get props => [month, year];
}

class SaveEmployeeEvent extends ErpEvent {
  final Employee employee;

  const SaveEmployeeEvent(this.employee);

  @override
  List<Object?> get props => [employee];
}

class DeleteEmployeeEvent extends ErpEvent {
  final String employeeId;

  const DeleteEmployeeEvent(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class AddCashAdvanceEvent extends ErpEvent {
  final String employeeId;
  final double amount;
  final String reason;
  final bool deductFromShiftDrawer;

  const AddCashAdvanceEvent({
    required this.employeeId,
    required this.amount,
    required this.reason,
    this.deductFromShiftDrawer = true,
  });

  @override
  List<Object?> get props => [
        employeeId,
        amount,
        reason,
        deductFromShiftDrawer,
      ];
}

class RecordExpenseEvent extends ErpEvent {
  final ExpenseCategory category;
  final double amount;
  final String description;
  final DateTime date;
  final bool paidFromDrawer;

  const RecordExpenseEvent({
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.paidFromDrawer = false,
  });

  @override
  List<Object?> get props => [
        category,
        amount,
        description,
        date,
        paidFromDrawer,
      ];
}

class DeleteExpenseEvent extends ErpEvent {
  final String expenseId;

  const DeleteExpenseEvent(this.expenseId);

  @override
  List<Object?> get props => [expenseId];
}

class CalculatePayrollEvent extends ErpEvent {
  final int month;
  final int year;

  const CalculatePayrollEvent({
    required this.month,
    required this.year,
  });

  @override
  List<Object?> get props => [month, year];
}

class SwitchErpSubTabEvent extends ErpEvent {
  final int subTabIndex;

  const SwitchErpSubTabEvent(this.subTabIndex);

  @override
  List<Object?> get props => [subTabIndex];
}

// ---------------------------------------------------------------------------
// Business Partners & Equity Events
// ---------------------------------------------------------------------------
class SavePartnerEvent extends ErpEvent {
  final BusinessPartner partner;

  const SavePartnerEvent(this.partner);

  @override
  List<Object?> get props => [partner];
}

class DeletePartnerEvent extends ErpEvent {
  final String partnerId;

  const DeletePartnerEvent(this.partnerId);

  @override
  List<Object?> get props => [partnerId];
}

class AddCapitalInjectionEvent extends ErpEvent {
  final String partnerId;
  final double amount;

  const AddCapitalInjectionEvent({
    required this.partnerId,
    required this.amount,
  });

  @override
  List<Object?> get props => [partnerId, amount];
}

class RecordDividendPayoutEvent extends ErpEvent {
  final String partnerId;
  final double amount;
  final DateTime payoutDate;
  final bool isPaidFromDrawer;
  final String? notes;

  const RecordDividendPayoutEvent({
    required this.partnerId,
    required this.amount,
    required this.payoutDate,
    this.isPaidFromDrawer = false,
    this.notes,
  });

  @override
  List<Object?> get props => [
        partnerId,
        amount,
        payoutDate,
        isPaidFromDrawer,
        notes,
      ];
}

class GenerateNetProfitReportEvent extends ErpEvent {
  final int? month;
  final int? year;

  const GenerateNetProfitReportEvent({this.month, this.year});

  @override
  List<Object?> get props => [month, year];
}
