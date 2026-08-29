import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../pos/data/models/order_model.dart';
import '../models/refund_transaction_model.dart';

abstract class OrdersLocalDataSource {
  Future<List<PosOrderModel>> getAllOrders();
  Future<PosOrderModel?> getOrderById(String orderId);
  Future<void> updateOrder(PosOrderModel order);

  Future<void> saveRefund(RefundTransactionModel refund);
  Future<List<RefundTransactionModel>> getAllRefunds();
}

class OrdersLocalDataSourceImpl implements OrdersLocalDataSource {
  static const String ordersBoxName = 'empos_orders_box';
  static const String refundsBoxName = 'empos_refunds_box';

  Future<Box<dynamic>> _openOrdersBox() async {
    if (Hive.isBoxOpen(ordersBoxName)) {
      return Hive.box<dynamic>(ordersBoxName);
    }
    return await Hive.openBox<dynamic>(ordersBoxName);
  }

  Future<Box<dynamic>> _openRefundsBox() async {
    if (Hive.isBoxOpen(refundsBoxName)) {
      return Hive.box<dynamic>(refundsBoxName);
    }
    return await Hive.openBox<dynamic>(refundsBoxName);
  }

  @override
  Future<List<PosOrderModel>> getAllOrders() async {
    final box = await _openOrdersBox();
    final List<PosOrderModel> orders = [];

    for (final raw in box.values) {
      if (raw != null) {
        orders.add(PosOrderModel.fromRaw(raw));
      }
    }

    orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return orders;
  }

  @override
  Future<PosOrderModel?> getOrderById(String orderId) async {
    final box = await _openOrdersBox();
    final raw = box.get(orderId);
    if (raw == null) return null;

    return PosOrderModel.fromRaw(raw);
  }

  @override
  Future<void> updateOrder(PosOrderModel order) async {
    final box = await _openOrdersBox();
    await box.put(order.id, jsonEncode(order.toJson()));
  }

  @override
  Future<void> saveRefund(RefundTransactionModel refund) async {
    final box = await _openRefundsBox();
    await box.put(refund.id, jsonEncode(refund.toJson()));
  }

  @override
  Future<List<RefundTransactionModel>> getAllRefunds() async {
    final box = await _openRefundsBox();
    final List<RefundTransactionModel> refunds = [];

    for (final raw in box.values) {
      if (raw != null) {
        refunds.add(RefundTransactionModel.fromRaw(raw));
      }
    }

    refunds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return refunds;
  }
}
