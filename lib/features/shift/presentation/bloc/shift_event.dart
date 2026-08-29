import 'package:equatable/equatable.dart';
import '../../domain/entities/cash_transaction.dart';

abstract class ShiftEvent extends Equatable {
  const ShiftEvent();

  @override
  List<Object?> get props => [];
}

class CheckCurrentShiftEvent extends ShiftEvent {
  const CheckCurrentShiftEvent();
}

class OpenShiftEvent extends ShiftEvent {
  final String cashierId;
  final String? cashierName;
  final double startingCash;
  final String? notes;

  const OpenShiftEvent({
    required this.cashierId,
    this.cashierName,
    required this.startingCash,
    this.notes,
  });

  @override
  List<Object?> get props => [cashierId, cashierName, startingCash, notes];
}

class CloseShiftEvent extends ShiftEvent {
  final String shiftId;
  final double actualCash;
  final String? notes;

  const CloseShiftEvent({
    required this.shiftId,
    required this.actualCash,
    this.notes,
  });

  @override
  List<Object?> get props => [shiftId, actualCash, notes];
}

class AddCashTxEvent extends ShiftEvent {
  final String shiftId;
  final CashTransactionType type;
  final double amount;
  final String reason;

  const AddCashTxEvent({
    required this.shiftId,
    required this.type,
    required this.amount,
    required this.reason,
  });

  @override
  List<Object?> get props => [shiftId, type, amount, reason];
}

class GenerateZReportEvent extends ShiftEvent {
  final String shiftId;

  const GenerateZReportEvent(this.shiftId);

  @override
  List<Object?> get props => [shiftId];
}

class DismissZReportEvent extends ShiftEvent {
  const DismissZReportEvent();
}
