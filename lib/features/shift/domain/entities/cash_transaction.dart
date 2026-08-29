import 'package:equatable/equatable.dart';

enum CashTransactionType {
  payIn, // Added change float or cash injection
  payOut, // Petty cash expense or cash withdrawal
}

class CashTransaction extends Equatable {
  final String id;
  final String shiftId;
  final CashTransactionType type;
  final double amount;
  final String reason;
  final DateTime timestamp;

  const CashTransaction({
    required this.id,
    required this.shiftId,
    required this.type,
    required this.amount,
    required this.reason,
    required this.timestamp,
  });

  bool get isPayIn => type == CashTransactionType.payIn;
  bool get isPayOut => type == CashTransactionType.payOut;

  @override
  List<Object?> get props => [id, shiftId, type, amount, reason, timestamp];
}
