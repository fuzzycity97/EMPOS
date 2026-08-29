import 'package:equatable/equatable.dart';

enum CustomerLedgerType { debtCharge, debtPayment }

class CustomerLedgerEntry extends Equatable {
  final String id;
  final String customerId;
  final CustomerLedgerType type;
  final double amount;
  final String? relatedOrderId;
  final String? notes;
  final DateTime timestamp;

  const CustomerLedgerEntry({
    required this.id,
    required this.customerId,
    required this.type,
    required this.amount,
    this.relatedOrderId,
    this.notes,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        customerId,
        type,
        amount,
        relatedOrderId,
        notes,
        timestamp,
      ];
}
