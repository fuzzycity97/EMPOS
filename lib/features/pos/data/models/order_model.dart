import 'dart:convert';
import '../../domain/entities/order.dart';
import 'cart_model.dart';
import 'payment_detail_model.dart';

class PosOrderModel extends PosOrder {
  const PosOrderModel({
    required super.id,
    required super.orderNumber,
    required super.cart,
    required super.payments,
    super.status = OrderStatus.paid,
    super.cashierId,
    super.customerPhone,
    super.customerName,
    super.changeGiven = 0.0,
    required super.createdAt,
  });

  factory PosOrderModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse PosOrderModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return PosOrderModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return PosOrderModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for PosOrderModel: ${raw.runtimeType}');
  }

  factory PosOrderModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status']?.toString().toLowerCase();
    OrderStatus status = OrderStatus.paid;
    if (statusStr == 'refunded') {
      status = OrderStatus.refunded;
    } else if (statusStr == 'partiallyrefunded') {
      status = OrderStatus.partiallyRefunded;
    } else if (statusStr == 'pending') {
      status = OrderStatus.pending;
    }

    final rawPayments = json['payments'] as List<dynamic>? ?? [];
    final payments = rawPayments.map((p) {
      if (p is String) {
        return PaymentDetailModel.fromJson(Map<String, dynamic>.from(jsonDecode(p) as Map));
      }
      return PaymentDetailModel.fromJson(Map<String, dynamic>.from(p as Map));
    }).toList();

    CartModel cartModel;
    final rawCart = json['cart'];
    if (rawCart is String) {
      cartModel = CartModel.fromJson(Map<String, dynamic>.from(jsonDecode(rawCart) as Map));
    } else if (rawCart is Map) {
      cartModel = CartModel.fromJson(Map<String, dynamic>.from(rawCart));
    } else {
      cartModel = const CartModel();
    }

    return PosOrderModel(
      id: json['id']?.toString() ?? '',
      orderNumber: json['orderNumber']?.toString() ?? 'ORD-000',
      cart: cartModel,
      payments: payments,
      status: status,
      cashierId: json['cashierId']?.toString(),
      customerPhone: json['customerPhone']?.toString(),
      customerName: json['customerName']?.toString(),
      changeGiven: (json['changeGiven'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'cart': CartModel.fromEntity(cart).toJson(),
      'payments': payments.map((p) => PaymentDetailModel.fromEntity(p).toJson()).toList(),
      'status': status.name,
      'cashierId': cashierId,
      'customerPhone': customerPhone,
      'customerName': customerName,
      'changeGiven': changeGiven,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PosOrderModel.fromEntity(PosOrder entity) {
    return PosOrderModel(
      id: entity.id,
      orderNumber: entity.orderNumber,
      cart: entity.cart,
      payments: entity.payments,
      status: entity.status,
      cashierId: entity.cashierId,
      customerPhone: entity.customerPhone,
      customerName: entity.customerName,
      changeGiven: entity.changeGiven,
      createdAt: entity.createdAt,
    );
  }
}
