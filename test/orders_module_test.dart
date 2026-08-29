import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:empos/features/catalog/data/models/product_model.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:empos/features/orders/data/models/refund_transaction_model.dart';
import 'package:empos/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:empos/features/orders/domain/entities/orders_filter.dart';
import 'package:empos/features/pos/data/models/order_model.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/order.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:empos/features/shift/data/models/cash_transaction_model.dart';
import 'package:empos/features/shift/data/models/shift_model.dart';
import 'package:empos/features/shift/domain/entities/cash_transaction.dart';

class MockOrdersLocalDataSource extends Mock implements OrdersLocalDataSource {}
class MockCatalogLocalDataSource extends Mock implements CatalogLocalDataSource {}
class MockShiftLocalDataSource extends Mock implements ShiftLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      PosOrderModel(
        id: 'fallback',
        orderNumber: 'ORD-000',
        cart: const Cart(),
        payments: const [],
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      const ProductModel(
        id: 'fallback',
        nameEn: 'fallback',
        categoryId: 'fallback',
        price: 0.0,
        stock: 100,
        barcode: '622000000000',
      ),
    );
    registerFallbackValue(
      CashTransactionModel(
        id: 'fallback',
        shiftId: 'fallback',
        type: CashTransactionType.payOut,
        amount: 0.0,
        reason: 'fallback',
        timestamp: DateTime.now(),
      ),
    );
    registerFallbackValue(
      RefundTransactionModel(
        id: 'fallback',
        refundNumber: 'RET-000',
        originalOrderId: 'fallback',
        originalOrderNumber: 'ORD-000',
        refundedItems: const [],
        refundTotal: 0.0,
        refundTender: TenderType.cash,
        reason: 'fallback',
        createdAt: DateTime.now(),
      ),
    );
  });

  group('RefundTransactionModel & Serializers', () {
    const tProduct = Product(
      id: 'p-1',
      nameEn: 'Espresso',
      categoryId: 'cat-1',
      price: 50.0,
      stock: 100,
      barcode: '622100',
    );

    test('RefundTransactionModel correctly serializes and deserializes', () {
      final refund = RefundTransactionModel(
        id: 'REF-1',
        refundNumber: 'RET-1001',
        originalOrderId: 'ORD-1',
        originalOrderNumber: 'TXN-999',
        refundedItems: const [
          CartItem(product: tProduct, quantity: 2, unitPrice: 50.0),
        ],
        refundTotal: 100.0,
        refundTender: TenderType.cash,
        reason: 'Customer cancelled order',
        cashierId: 'cashier-1',
        createdAt: DateTime(2026, 8, 28, 10, 0),
      );

      final json = refund.toJson();
      final restored = RefundTransactionModel.fromJson(json);

      expect(restored.id, equals('REF-1'));
      expect(restored.refundNumber, equals('RET-1001'));
      expect(restored.refundTotal, equals(100.0));
      expect(restored.refundTender, equals(TenderType.cash));
      expect(restored.refundedItems.length, equals(1));
    });
  });

  group('OrdersRepositoryImpl History and 3-Step Refund Verification', () {
    late MockOrdersLocalDataSource mockOrdersDataSource;
    late MockCatalogLocalDataSource mockCatalogDataSource;
    late MockShiftLocalDataSource mockShiftDataSource;
    late OrdersRepositoryImpl repository;

    const tProductA = ProductModel(
      id: 'prod-A',
      nameEn: 'Cold Brew Coffee',
      categoryId: 'cat-beverages',
      price: 60.0,
      stock: 50,
      barcode: '622000000001',
      trackQty: true,
    );

    final tOrder = PosOrderModel(
      id: 'ORD-100',
      orderNumber: 'TXN-100',
      cart: const Cart(
        items: [
          CartItem(product: tProductA, quantity: 2, unitPrice: 60.0), // 120.0 EGP
        ],
        taxRate: 0.0,
      ),
      payments: const [
        PaymentDetail(tenderType: TenderType.cash, amount: 120.0),
      ],
      status: OrderStatus.paid,
      createdAt: DateTime(2026, 8, 28, 11, 0),
    );

    final tActiveShift = ShiftModel(
      id: 'SHIFT-001',
      cashierId: 'cashier-1',
      startTime: DateTime(2026, 8, 28, 8, 0),
      startingCash: 500.0,
    );

    setUp(() {
      mockOrdersDataSource = MockOrdersLocalDataSource();
      mockCatalogDataSource = MockCatalogLocalDataSource();
      mockShiftDataSource = MockShiftLocalDataSource();

      repository = OrdersRepositoryImpl(
        localDataSource: mockOrdersDataSource,
        catalogLocalDataSource: mockCatalogDataSource,
        shiftLocalDataSource: mockShiftDataSource,
      );
    });

    test('getOrdersHistory filters orders by search query and status', () async {
      when(() => mockOrdersDataSource.getAllOrders())
          .thenAnswer((_) async => [tOrder]);

      final result = await repository.getOrdersHistory(
        filter: const OrdersFilter(searchQuery: 'TXN-100', status: OrderStatus.paid),
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail(f.message),
        (orders) {
          expect(orders.length, equals(1));
          expect(orders.first.orderNumber, equals('TXN-100'));
        },
      );
    });

    test('processRefund performs 3-step operations (updates order, restocks catalog, logs shift payout)', () async {
      when(() => mockOrdersDataSource.getOrderById('ORD-100'))
          .thenAnswer((_) async => tOrder);
      when(() => mockOrdersDataSource.updateOrder(any()))
          .thenAnswer((_) async {});
      when(() => mockCatalogDataSource.getProductById('prod-A'))
          .thenAnswer((_) async => tProductA);
      when(() => mockCatalogDataSource.saveProduct(any()))
          .thenAnswer((_) async {});
      when(() => mockShiftDataSource.getActiveShift())
          .thenAnswer((_) async => tActiveShift);
      when(() => mockShiftDataSource.saveCashTransaction(any()))
          .thenAnswer((_) async {});
      when(() => mockOrdersDataSource.saveRefund(any()))
          .thenAnswer((_) async {});

      final refundResult = await repository.processRefund(
        orderId: 'ORD-100',
        refundedItems: const [
          CartItem(product: tProductA, quantity: 2, unitPrice: 60.0),
        ],
        refundTender: TenderType.cash,
        reason: 'Defective packaging',
      );

      expect(refundResult.isRight(), isTrue);
      refundResult.fold(
        (f) => fail(f.message),
        (refundTx) {
          expect(refundTx.refundTotal, equals(120.0));
          expect(refundTx.refundTender, equals(TenderType.cash));
          expect(refundTx.reason, equals('Defective packaging'));
        },
      );

      // Verify order status updated to refunded
      verify(() => mockOrdersDataSource.updateOrder(any(that: predicate<PosOrderModel>((o) => o.status == OrderStatus.refunded)))).called(1);

      // Verify inventory restocked (+2)
      verify(() => mockCatalogDataSource.saveProduct(any(that: predicate<ProductModel>((p) => p.stock == 52)))).called(1);

      // Verify shift cash drawer payout recorded
      verify(() => mockShiftDataSource.saveCashTransaction(any(that: predicate<CashTransactionModel>((tx) => tx.type == CashTransactionType.payOut && tx.amount == 120.0)))).called(1);
    });
  });
}
