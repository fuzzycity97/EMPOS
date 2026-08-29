import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/erp/data/datasources/erp_local_data_source.dart';
import 'package:empos/features/erp/data/models/business_partner_model.dart';
import 'package:empos/features/erp/data/models/cash_advance_model.dart';
import 'package:empos/features/erp/data/models/dividend_payout_model.dart';
import 'package:empos/features/erp/data/models/employee_model.dart';
import 'package:empos/features/erp/data/models/expense_model.dart';
import 'package:empos/features/erp/data/repositories/erp_repository_impl.dart';
import 'package:empos/features/erp/domain/entities/employee.dart';
import 'package:empos/features/erp/domain/entities/expense.dart';
import 'package:empos/features/erp/domain/entities/net_profit_report.dart';
import 'package:empos/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:empos/features/pos/data/models/order_model.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/order.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:empos/features/shift/data/models/cash_transaction_model.dart';
import 'package:empos/features/shift/data/models/shift_model.dart';
import 'package:empos/features/shift/domain/entities/cash_transaction.dart';

class MockErpLocalDataSource extends Mock implements ErpLocalDataSource {}
class MockShiftLocalDataSource extends Mock implements ShiftLocalDataSource {}
class MockOrdersLocalDataSource extends Mock implements OrdersLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      EmployeeModel(
        id: 'fallback',
        name: 'fallback',
        hireDate: DateTime.now(),
      ),
    );
    registerFallbackValue(
      CashAdvanceModel(
        id: 'fallback',
        employeeId: 'fallback',
        amount: 0.0,
        date: DateTime.now(),
        reason: 'fallback',
      ),
    );
    registerFallbackValue(
      ExpenseModel(
        id: 'fallback',
        category: ExpenseCategory.other,
        amount: 0.0,
        date: DateTime.now(),
        description: 'fallback',
      ),
    );
    registerFallbackValue(
      BusinessPartnerModel(
        id: 'fallback',
        name: 'fallback',
        equityPercentage: 50.0,
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      DividendPayoutModel(
        id: 'fallback',
        partnerId: 'fallback',
        amount: 0.0,
        payoutDate: DateTime.now(),
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
  });

  group('ERP Entities & Model Serialization', () {
    test('EmployeeModel correctly serializes and parses from JSON and raw string', () {
      final emp = EmployeeModel(
        id: 'EMP-001',
        name: 'Mostafa Kamal',
        phone: '01011223344',
        role: EmployeeRole.supervisor,
        baseSalary: 7500.0,
        hourlyRate: 45.0,
        hireDate: DateTime(2026, 1, 15),
        isActive: true,
      );

      final json = emp.toJson();
      final fromJson = EmployeeModel.fromJson(json);

      expect(fromJson.id, equals('EMP-001'));
      expect(fromJson.name, equals('Mostafa Kamal'));
      expect(fromJson.role, equals(EmployeeRole.supervisor));
      expect(fromJson.baseSalary, equals(7500.0));
    });

    test('BusinessPartnerModel correctly serializes and parses equity info', () {
      final partner = BusinessPartnerModel(
        id: 'PTR-001',
        name: 'Ahmed Hegazy',
        contactInfo: '01099887766',
        equityPercentage: 40.0,
        totalInvestedCapital: 250000.0,
        withdrawnDividends: 35000.0,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = partner.toJson();
      final fromJson = BusinessPartnerModel.fromJson(json);

      expect(fromJson.id, equals('PTR-001'));
      expect(fromJson.name, equals('Ahmed Hegazy'));
      expect(fromJson.equityPercentage, equals(40.0));
      expect(fromJson.totalInvestedCapital, equals(250000.0));
      expect(fromJson.withdrawnDividends, equals(35000.0));
    });

    test('DividendPayoutModel correctly serializes and deserializes', () {
      final payout = DividendPayoutModel(
        id: 'DIV-001',
        partnerId: 'PTR-001',
        partnerName: 'Ahmed Hegazy',
        amount: 15000.0,
        payoutDate: DateTime(2026, 8, 28),
        isPaidFromDrawer: true,
        notes: 'Q2 2026 Profit Distribution',
      );

      final json = payout.toJson();
      final fromJson = DividendPayoutModel.fromJson(json);

      expect(fromJson.id, equals('DIV-001'));
      expect(fromJson.amount, equals(15000.0));
      expect(fromJson.isPaidFromDrawer, isTrue);
    });

    test('NetProfitReport.compute accurately calculates profit waterfall & partner equity splits', () {
      final report = NetProfitReport.compute(
        month: 8,
        year: 2026,
        grossSales: 100000.0,
        refunds: 5000.0, // Net Sales = 95,000
        cogs: 40000.0, // Gross Profit = 55,000
        operatingExpenses: 15000.0,
        payrollExpenses: 20000.0,
        equityPercentages: {
          'PTR-001': 60.0, // 60%
          'PTR-002': 40.0, // 40%
        },
      );

      // Net Sales = 95,000
      expect(report.netSales, equals(95000.0));
      // Gross Profit = 95,000 - 40,000 = 55,000
      expect(report.grossProfit, equals(55000.0));
      // Net Operating Profit = 55,000 - 15,000 - 20,000 = 20,000
      expect(report.netOperatingProfit, equals(20000.0));
      // Partner 1 Share = 20,000 * 60% = 12,000
      expect(report.partnerShares['PTR-001'], equals(12000.0));
      // Partner 2 Share = 20,000 * 40% = 8,000
      expect(report.partnerShares['PTR-002'], equals(8000.0));
    });
  });

  group('ErpRepositoryImpl Partners & Net Profit Verification', () {
    late MockErpLocalDataSource mockErpDataSource;
    late MockShiftLocalDataSource mockShiftDataSource;
    late MockOrdersLocalDataSource mockOrdersDataSource;
    late ErpRepositoryImpl repository;

    final tPartner = BusinessPartnerModel(
      id: 'PTR-100',
      name: 'Tariq Mansour',
      equityPercentage: 50.0,
      totalInvestedCapital: 100000.0,
      withdrawnDividends: 10000.0,
      createdAt: DateTime(2026, 1, 1),
    );

    final tActiveShift = ShiftModel(
      id: 'SHIFT-001',
      cashierId: 'cashier-1',
      startTime: DateTime(2026, 8, 28, 8, 0),
      startingCash: 500.0,
    );

    setUp(() {
      mockErpDataSource = MockErpLocalDataSource();
      mockShiftDataSource = MockShiftLocalDataSource();
      mockOrdersDataSource = MockOrdersLocalDataSource();

      repository = ErpRepositoryImpl(
        localDataSource: mockErpDataSource,
        shiftLocalDataSource: mockShiftDataSource,
        ordersLocalDataSource: mockOrdersDataSource,
      );
    });

    test('addCapitalInjection increases totalInvestedCapital and saves partner', () async {
      when(() => mockErpDataSource.getPartnerById('PTR-100'))
          .thenAnswer((_) async => tPartner);
      when(() => mockErpDataSource.savePartner(any()))
          .thenAnswer((_) async {});

      final result = await repository.addCapitalInjection(
        partnerId: 'PTR-100',
        amount: 50000.0,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail(f.message),
        (updated) {
          expect(updated.totalInvestedCapital, equals(150000.0)); // 100,000 + 50,000
        },
      );

      verify(() => mockErpDataSource.savePartner(any(that: predicate<BusinessPartnerModel>((p) => p.totalInvestedCapital == 150000.0)))).called(1);
    });

    test('recordDividendPayout with isPaidFromDrawer logs PayOut in Shift Cash Drawer', () async {
      when(() => mockErpDataSource.getPartnerById('PTR-100'))
          .thenAnswer((_) async => tPartner);
      when(() => mockShiftDataSource.getActiveShift())
          .thenAnswer((_) async => tActiveShift);
      when(() => mockShiftDataSource.saveCashTransaction(any()))
          .thenAnswer((_) async {});
      when(() => mockErpDataSource.saveDividendPayout(any()))
          .thenAnswer((_) async {});
      when(() => mockErpDataSource.savePartner(any()))
          .thenAnswer((_) async {});

      final result = await repository.recordDividendPayout(
        partnerId: 'PTR-100',
        amount: 4000.0,
        payoutDate: DateTime(2026, 8, 28),
        isPaidFromDrawer: true,
        notes: 'August Advance Profit Cut',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail(f.message),
        (payout) {
          expect(payout.amount, equals(4000.0));
          expect(payout.isPaidFromDrawer, isTrue);
        },
      );

      // 1. Verify DividendPayout saved
      verify(() => mockErpDataSource.saveDividendPayout(any(that: predicate<DividendPayoutModel>((p) => p.amount == 4000.0)))).called(1);

      // 2. Verify Partner withdrawn dividends updated
      verify(() => mockErpDataSource.savePartner(any(that: predicate<BusinessPartnerModel>((p) => p.withdrawnDividends == 14000.0)))).called(1);

      // 3. Verify Shift Drawer PayOut recorded
      verify(() => mockShiftDataSource.saveCashTransaction(any(that: predicate<CashTransactionModel>((tx) => tx.type == CashTransactionType.payOut && tx.amount == 4000.0)))).called(1);
    });

    test('calculateNetProfitReport integrates orders, expenses, payroll, and returns net profit', () async {
      final tProduct = Product(
        id: 'P-1',
        nameEn: 'Item 1',
        categoryId: 'cat-1',
        price: 100.0,
        stock: 10,
        barcode: '123',
      );

      final tCartItem = CartItem(product: tProduct, quantity: 5, unitPrice: 100.0);
      final tCart = Cart(items: [tCartItem]);

      final tOrder = PosOrderModel(
        id: 'ORD-1',
        orderNumber: '#1001',
        cart: tCart,
        payments: const [PaymentDetail(tenderType: TenderType.cash, amount: 500.0)],
        createdAt: DateTime(2026, 8, 10),
        status: OrderStatus.paid,
      );

      final tExpense = ExpenseModel(
        id: 'EXP-1',
        category: ExpenseCategory.utilities,
        amount: 50.0,
        date: DateTime(2026, 8, 12),
        description: 'Electricity',
      );

      final tEmployee = EmployeeModel(
        id: 'EMP-1',
        name: 'Staff 1',
        baseSalary: 100.0,
        hireDate: DateTime(2026, 1, 1),
      );

      when(() => mockOrdersDataSource.getAllOrders()).thenAnswer((_) async => [tOrder]);
      when(() => mockOrdersDataSource.getAllRefunds()).thenAnswer((_) async => []);
      when(() => mockErpDataSource.getExpenses()).thenAnswer((_) async => [tExpense]);
      when(() => mockErpDataSource.getEmployees()).thenAnswer((_) async => [tEmployee]);
      when(() => mockErpDataSource.getCashAdvances()).thenAnswer((_) async => []);
      when(() => mockErpDataSource.getPartners()).thenAnswer((_) async => [tPartner]);

      final result = await repository.calculateNetProfitReport(month: 8, year: 2026);

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail(f.message),
        (report) {
          expect(report.grossSales, equals(500.0));
          expect(report.cogs, equals(300.0)); // 5 * 60.0
          expect(report.operatingExpenses, equals(50.0));
          expect(report.payrollExpenses, equals(100.0));
          // Net = 500 - 300 - 50 - 100 = 50.0
          expect(report.netOperatingProfit, equals(50.0));
          // 50% of 50.0 = 25.0
          expect(report.partnerShares['PTR-100'], equals(25.0));
        },
      );
    });
  });
}
