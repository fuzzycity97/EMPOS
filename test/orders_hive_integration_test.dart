import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:empos/features/orders/data/models/refund_transaction_model.dart';
import 'package:empos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:empos/features/pos/data/models/order_model.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/order.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';

void main() {
  late Directory tempDir;
  late PosLocalDataSource posDataSource;
  late OrdersLocalDataSource ordersDataSource;

  const tProduct = Product(
    id: 'prod-001',
    nameEn: 'Americano Large',
    categoryId: 'cat-coffee',
    price: 35.0,
    stock: 50,
    barcode: '622000000001',
  );

  final tOrder = PosOrderModel(
    id: 'ORD-999',
    orderNumber: 'TXN-999',
    cart: const Cart(
      items: [
        CartItem(product: tProduct, quantity: 2, unitPrice: 35.0),
      ],
      taxRate: 0.14,
    ),
    payments: const [
      PaymentDetail(tenderType: TenderType.cash, amount: 79.80),
    ],
    status: OrderStatus.paid,
    cashierId: 'cashier-1',
    createdAt: DateTime(2026, 8, 28, 15, 0),
  );

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('empos_hive_test_');
    Hive.init(tempDir.path);

    posDataSource = PosLocalDataSourceImpl();
    ordersDataSource = OrdersLocalDataSourceImpl();
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Hive Box Sharing & Resilient JSON Parsing Integration', () {
    test('PosLocalDataSource saves order as JSON string, and OrdersLocalDataSource reads it seamlessly', () async {
      // 1. Save order via POS data source
      await posDataSource.saveOrder(tOrder);

      // 2. Read order via Orders data source (sharing the same box)
      final allOrders = await ordersDataSource.getAllOrders();
      expect(allOrders.length, equals(1));
      expect(allOrders.first.id, equals('ORD-999'));
      expect(allOrders.first.orderNumber, equals('TXN-999'));
      expect(allOrders.first.cart.items.length, equals(1));
      expect(allOrders.first.cart.items.first.product.nameEn, equals('Americano Large'));
      expect(allOrders.first.payments.first.tenderType, equals(TenderType.cash));

      // 3. Update order to refunded via Orders data source
      final updated = PosOrderModel(
        id: tOrder.id,
        orderNumber: tOrder.orderNumber,
        cart: tOrder.cart,
        payments: tOrder.payments,
        status: OrderStatus.refunded,
        cashierId: tOrder.cashierId,
        createdAt: tOrder.createdAt,
      );
      await ordersDataSource.updateOrder(updated);

      // 4. Verify POS data source retrieves the updated order
      final reloadedPos = await posDataSource.getOrders();
      expect(reloadedPos.first.status, equals(OrderStatus.refunded));
    });

    test('RefundTransactionModel fromRaw handles both String and Map dynamically', () {
      final refund = RefundTransactionModel(
        id: 'REF-001',
        refundNumber: 'RET-001',
        originalOrderId: 'ORD-999',
        originalOrderNumber: 'TXN-999',
        refundedItems: const [
          CartItem(product: tProduct, quantity: 1, unitPrice: 35.0),
        ],
        refundTotal: 39.90,
        refundTender: TenderType.cash,
        reason: 'Wrong beverage',
        createdAt: DateTime(2026, 8, 28, 15, 30),
      );

      // Test parsing from Map
      final fromMap = RefundTransactionModel.fromRaw(refund.toJson());
      expect(fromMap.refundNumber, equals('RET-001'));
      expect(fromMap.refundTotal, equals(39.90));

      // Test parsing from JSON String
      final jsonStr = '{"id":"REF-002","refundNumber":"RET-002","originalOrderId":"ORD-999","originalOrderNumber":"TXN-999","refundedItems":[],"refundTotal":79.80,"refundTender":"cash","reason":"Returned","createdAt":"2026-08-28T15:35:00.000"}';
      final fromString = RefundTransactionModel.fromRaw(jsonStr);
      expect(fromString.refundNumber, equals('RET-002'));
      expect(fromString.refundTotal, equals(79.80));
    });
  });
}
