import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:empos/features/pos/data/models/order_model.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:empos/features/shift/data/models/cash_transaction_model.dart';
import 'package:empos/features/shift/data/models/shift_model.dart';
import 'package:empos/features/shift/data/models/z_report_model.dart';
import 'package:empos/features/shift/data/repositories/shift_repository_impl.dart';
import 'package:empos/features/shift/domain/entities/cash_transaction.dart';
import 'package:empos/features/shift/domain/entities/shift.dart';

class MockShiftLocalDataSource extends Mock implements ShiftLocalDataSource {}
class MockPosLocalDataSource extends Mock implements PosLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ShiftModel(
        id: 'fallback',
        cashierId: 'cashier',
        startTime: DateTime.now(),
        startingCash: 0.0,
      ),
    );
    registerFallbackValue(
      CashTransactionModel(
        id: 'fallback',
        shiftId: 'fallback',
        type: CashTransactionType.payIn,
        amount: 0.0,
        reason: 'fallback',
        timestamp: DateTime.now(),
      ),
    );
  });

  group('Shift Models & JSON Serializers', () {
    test('ShiftModel correctly serializes and deserializes', () {
      final shift = ShiftModel(
        id: 'SHIFT-001',
        cashierId: 'cashier-1',
        cashierName: 'Ahmed',
        startTime: DateTime(2026, 8, 27, 8, 0),
        startingCash: 500.0,
        expectedCash: 1200.0,
        actualCash: 1200.0,
        difference: 0.0,
        status: ShiftStatus.closed,
        notes: 'Balanced morning shift',
      );

      final json = shift.toJson();
      final restored = ShiftModel.fromJson(json);

      expect(restored.id, equals('SHIFT-001'));
      expect(restored.cashierName, equals('Ahmed'));
      expect(restored.startingCash, equals(500.0));
      expect(restored.difference, equals(0.0));
      expect(restored.status, equals(ShiftStatus.closed));
    });

    test('CashTransactionModel correctly serializes PayIn and PayOut', () {
      final payIn = CashTransactionModel(
        id: 'CTX-1',
        shiftId: 'SHIFT-001',
        type: CashTransactionType.payIn,
        amount: 200.0,
        reason: 'Additional change coins',
        timestamp: DateTime(2026, 8, 27, 9, 30),
      );

      final json = payIn.toJson();
      final restored = CashTransactionModel.fromJson(json);

      expect(restored.type, equals(CashTransactionType.payIn));
      expect(restored.amount, equals(200.0));
      expect(restored.reason, equals('Additional change coins'));
    });

    test('ZReportModel correctly serializes full financial audit report', () {
      final shift = ShiftModel(
        id: 'SHIFT-001',
        cashierId: 'cashier-1',
        startTime: DateTime(2026, 8, 27, 8, 0),
        startingCash: 500.0,
      );

      final report = ZReportModel(
        shift: shift,
        totalOrdersCount: 15,
        grossSales: 3500.0,
        netSales: 3400.0,
        totalDiscounts: 100.0,
        totalTax: 420.0,
        totalCashSales: 2000.0,
        totalCardSales: 1400.0,
        totalPayIns: 100.0,
        totalPayOuts: 50.0,
        totalRefunds: 0.0,
        openingCash: 500.0,
        expectedCash: 2550.0,
        actualCash: 2550.0,
        difference: 0.0,
        generatedAt: DateTime(2026, 8, 27, 16, 0),
      );

      final json = report.toJson();
      final restored = ZReportModel.fromJson(json);

      expect(restored.totalOrdersCount, equals(15));
      expect(restored.totalCashSales, equals(2000.0));
      expect(restored.totalCardSales, equals(1400.0));
      expect(restored.expectedCash, equals(2550.0));
    });
  });

  group('ShiftRepositoryImpl Drawer Cash & Z-Report Math Verification', () {
    late MockShiftLocalDataSource mockShiftDataSource;
    late MockPosLocalDataSource mockPosDataSource;
    late ShiftRepositoryImpl repository;

    const tProduct = Product(
      id: 'p-1',
      nameEn: 'Espresso',
      categoryId: 'cat-1',
      price: 50.0,
      stock: 100,
      barcode: '622100',
    );

    setUp(() {
      mockShiftDataSource = MockShiftLocalDataSource();
      mockPosDataSource = MockPosLocalDataSource();
      repository = ShiftRepositoryImpl(
        localDataSource: mockShiftDataSource,
        posLocalDataSource: mockPosDataSource,
      );
    });

    test('accurately calculates Expected Cash = Starting Cash + Cash Sales + PayIns - PayOuts', () async {
      final shiftStartTime = DateTime(2026, 8, 27, 8, 0);

      final activeShift = ShiftModel(
        id: 'SHIFT-TEST',
        cashierId: 'cashier-1',
        cashierName: 'Kareem',
        startTime: shiftStartTime,
        startingCash: 500.0, // Starting float
      );

      // 1. Completed Cash Order 1: 100 EGP (Paid 100 cash, 0 change)
      final order1 = PosOrderModel(
        id: 'ord-1',
        orderNumber: 'TXN-001',
        cart: const Cart(
          items: [CartItem(product: tProduct, quantity: 2, unitPrice: 50.0)],
        ),
        payments: const [
          PaymentDetail(tenderType: TenderType.cash, amount: 100.0),
        ],
        changeGiven: 0.0,
        createdAt: shiftStartTime.add(const Duration(minutes: 30)),
      );

      // 2. Completed Cash Order 2: 200 EGP (Paid 300 cash, 100 change given -> Net cash in drawer: +200)
      final order2 = PosOrderModel(
        id: 'ord-2',
        orderNumber: 'TXN-002',
        cart: const Cart(
          items: [CartItem(product: tProduct, quantity: 4, unitPrice: 50.0)],
        ),
        payments: const [
          PaymentDetail(tenderType: TenderType.cash, amount: 300.0),
        ],
        changeGiven: 100.0,
        createdAt: shiftStartTime.add(const Duration(hours: 1)),
      );

      // 3. Completed Card Order 3: 150 EGP (Card tender -> Does not affect physical cash drawer)
      final order3 = PosOrderModel(
        id: 'ord-3',
        orderNumber: 'TXN-003',
        cart: const Cart(
          items: [CartItem(product: tProduct, quantity: 3, unitPrice: 50.0)],
        ),
        payments: const [
          PaymentDetail(tenderType: TenderType.card, amount: 150.0),
        ],
        createdAt: shiftStartTime.add(const Duration(hours: 2)),
      );

      // 4. Pay-In (Change added to drawer): +50.0
      final payInTx = CashTransactionModel(
        id: 'CTX-1',
        shiftId: 'SHIFT-TEST',
        type: CashTransactionType.payIn,
        amount: 50.0,
        reason: 'Change coins added',
        timestamp: shiftStartTime.add(const Duration(hours: 3)),
      );

      // 5. Pay-Out (Petty cash expense): -30.0
      final payOutTx = CashTransactionModel(
        id: 'CTX-2',
        shiftId: 'SHIFT-TEST',
        type: CashTransactionType.payOut,
        amount: 30.0,
        reason: 'Cleaning supplies',
        timestamp: shiftStartTime.add(const Duration(hours: 4)),
      );

      when(() => mockShiftDataSource.getShiftById('SHIFT-TEST'))
          .thenAnswer((_) async => activeShift);
      when(() => mockPosDataSource.getOrders())
          .thenAnswer((_) async => [order1, order2, order3]);
      when(() => mockShiftDataSource.getCashTransactionsForShift('SHIFT-TEST'))
          .thenAnswer((_) async => [payInTx, payOutTx]);
      when(() => mockShiftDataSource.saveShift(any()))
          .thenAnswer((_) async {});
      when(() => mockShiftDataSource.setActiveShiftId(null))
          .thenAnswer((_) async {});

      // Expected Cash Math:
      // Starting Float: 500.0
      // Cash Sales: +100.0 (Order 1) + 200.0 (Order 2: 300 received - 100 change) = 300.0
      // Pay-Ins: +50.0
      // Pay-Outs: -30.0
      // Expected Drawer Cash = 500 + 300 + 50 - 30 = 820.0 EGP

      final zReportResult = await repository.generateZReport('SHIFT-TEST');

      expect(zReportResult.isRight(), isTrue);
      zReportResult.fold(
        (f) => fail(f.message),
        (report) {
          expect(report.totalOrdersCount, equals(3));
          expect(report.totalCashSales, equals(300.0));
          expect(report.totalCardSales, equals(150.0));
          expect(report.totalPayIns, equals(50.0));
          expect(report.totalPayOuts, equals(30.0));
          expect(report.expectedCash, equals(820.0));
        },
      );

      // Closing shift with Actual Counted Cash = 800.0 EGP (20 EGP Shortage)
      final closeResult = await repository.closeShift(
        shiftId: 'SHIFT-TEST',
        actualCash: 800.0,
        notes: 'End of day closing',
      );

      expect(closeResult.isRight(), isTrue);
      closeResult.fold(
        (f) => fail(f.message),
        (closedShift) {
          expect(closedShift.status, equals(ShiftStatus.closed));
          expect(closedShift.expectedCash, equals(820.0));
          expect(closedShift.actualCash, equals(800.0));
          expect(closedShift.difference, equals(-20.0)); // Shortage of 20
          expect(closedShift.isShortage, isTrue);
        },
      );
    });
  });
}
