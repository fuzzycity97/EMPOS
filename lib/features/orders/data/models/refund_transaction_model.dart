import 'dart:convert';
import '../../../pos/data/models/cart_item_model.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../../domain/entities/refund_transaction.dart';

class RefundTransactionModel extends RefundTransaction {
  const RefundTransactionModel({
    required super.id,
    required super.refundNumber,
    required super.originalOrderId,
    required super.originalOrderNumber,
    required super.refundedItems,
    required super.refundTotal,
    required super.refundTender,
    required super.reason,
    super.cashierId,
    required super.createdAt,
  });

  factory RefundTransactionModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse RefundTransactionModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return RefundTransactionModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return RefundTransactionModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for RefundTransactionModel: ${raw.runtimeType}');
  }

  factory RefundTransactionModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['refundedItems'] as List<dynamic>? ?? [];
    final items = rawItems.map((i) {
      if (i is String) {
        return CartItemModel.fromJson(Map<String, dynamic>.from(jsonDecode(i) as Map));
      }
      return CartItemModel.fromJson(Map<String, dynamic>.from(i as Map));
    }).toList();

    return RefundTransactionModel(
      id: json['id']?.toString() ?? '',
      refundNumber: json['refundNumber']?.toString() ?? 'RET-000',
      originalOrderId: json['originalOrderId']?.toString() ?? '',
      originalOrderNumber: json['originalOrderNumber']?.toString() ?? '',
      refundedItems: items,
      refundTotal: (json['refundTotal'] as num?)?.toDouble() ?? 0.0,
      refundTender: TenderType.values.firstWhere(
        (e) => e.name == json['refundTender'],
        orElse: () => TenderType.cash,
      ),
      reason: json['reason']?.toString() ?? '',
      cashierId: json['cashierId']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'refundNumber': refundNumber,
      'originalOrderId': originalOrderId,
      'originalOrderNumber': originalOrderNumber,
      'refundedItems': refundedItems
          .map((i) => CartItemModel.fromEntity(i).toJson())
          .toList(),
      'refundTotal': refundTotal,
      'refundTender': refundTender.name,
      'reason': reason,
      'cashierId': cashierId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RefundTransactionModel.fromEntity(RefundTransaction entity) {
    return RefundTransactionModel(
      id: entity.id,
      refundNumber: entity.refundNumber,
      originalOrderId: entity.originalOrderId,
      originalOrderNumber: entity.originalOrderNumber,
      refundedItems: entity.refundedItems,
      refundTotal: entity.refundTotal,
      refundTender: entity.refundTender,
      reason: entity.reason,
      cashierId: entity.cashierId,
      createdAt: entity.createdAt,
    );
  }
}
