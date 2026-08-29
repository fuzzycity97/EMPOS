import '../../domain/entities/cash_transaction.dart';

class CashTransactionModel extends CashTransaction {
  const CashTransactionModel({
    required super.id,
    required super.shiftId,
    required super.type,
    required super.amount,
    required super.reason,
    required super.timestamp,
  });

  factory CashTransactionModel.fromJson(Map<String, dynamic> json) {
    return CashTransactionModel(
      id: json['id'] as String,
      shiftId: json['shiftId'] as String,
      type: CashTransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CashTransactionType.payIn,
      ),
      amount: (json['amount'] as num).toDouble(),
      reason: json['reason'] as String? ?? '',
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shiftId': shiftId,
      'type': type.name,
      'amount': amount,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CashTransactionModel.fromEntity(CashTransaction entity) {
    return CashTransactionModel(
      id: entity.id,
      shiftId: entity.shiftId,
      type: entity.type,
      amount: entity.amount,
      reason: entity.reason,
      timestamp: entity.timestamp,
    );
  }
}
