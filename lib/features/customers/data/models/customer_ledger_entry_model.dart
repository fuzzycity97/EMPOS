import 'dart:convert';
import '../../domain/entities/customer_ledger_entry.dart';

class CustomerLedgerEntryModel extends CustomerLedgerEntry {
  const CustomerLedgerEntryModel({
    required super.id,
    required super.customerId,
    required super.type,
    required super.amount,
    super.relatedOrderId,
    super.notes,
    required super.timestamp,
  });

  factory CustomerLedgerEntryModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse CustomerLedgerEntryModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return CustomerLedgerEntryModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return CustomerLedgerEntryModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for CustomerLedgerEntryModel: ${raw.runtimeType}');
  }

  factory CustomerLedgerEntryModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString().toLowerCase();
    CustomerLedgerType type = CustomerLedgerType.debtCharge;
    if (typeStr == 'debtpayment' || typeStr == 'payment') {
      type = CustomerLedgerType.debtPayment;
    }

    return CustomerLedgerEntryModel(
      id: json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      type: type,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      relatedOrderId: json['relatedOrderId']?.toString(),
      notes: json['notes']?.toString(),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'type': type.name,
      'amount': amount,
      'relatedOrderId': relatedOrderId,
      'notes': notes,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CustomerLedgerEntryModel.fromEntity(CustomerLedgerEntry entity) {
    return CustomerLedgerEntryModel(
      id: entity.id,
      customerId: entity.customerId,
      type: entity.type,
      amount: entity.amount,
      relatedOrderId: entity.relatedOrderId,
      notes: entity.notes,
      timestamp: entity.timestamp,
    );
  }
}
