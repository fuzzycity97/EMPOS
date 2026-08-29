import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/customers/data/datasources/customer_local_data_source.dart';
import 'package:empos/features/customers/data/models/customer_ledger_entry_model.dart';
import 'package:empos/features/customers/data/models/customer_model.dart';
import 'package:empos/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:empos/features/customers/domain/entities/customer_ledger_entry.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:empos/features/shift/data/models/cash_transaction_model.dart';
import 'package:empos/features/shift/data/models/shift_model.dart';
import 'package:empos/features/shift/domain/entities/cash_transaction.dart';

class MockCustomerLocalDataSource extends Mock implements CustomerLocalDataSource {}
class MockShiftLocalDataSource extends Mock implements ShiftLocalDataSource {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      CustomerModel(
        id: 'fallback',
        name: 'fallback',
        phone: '01000000000',
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      CustomerLedgerEntryModel(
        id: 'fallback',
        customerId: 'fallback',
        type: CustomerLedgerType.debtCharge,
        amount: 0.0,
        timestamp: DateTime.now(),
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

  group('Customer Models & JSON / fromRaw Serializers', () {
    test('CustomerModel correctly serializes and parses from JSON and raw String', () {
      final customer = CustomerModel(
        id: 'CUST-001',
        name: 'Mohamed Ali',
        phone: '01012345678',
        address: '15 Tahrir Square, Cairo',
        totalDebt: 350.50,
        loyaltyPoints: 120,
        notes: 'VIP Client',
        createdAt: DateTime(2026, 8, 28, 10, 0),
      );

      final json = customer.toJson();
      final fromJson = CustomerModel.fromJson(json);

      expect(fromJson.id, equals('CUST-001'));
      expect(fromJson.name, equals('Mohamed Ali'));
      expect(fromJson.phone, equals('01012345678'));
      expect(fromJson.totalDebt, equals(350.50));
      expect(fromJson.loyaltyPoints, equals(120));

      final fromRawStr = CustomerModel.fromRaw(
        '{"id":"CUST-002","name":"Sara Ahmed","phone":"01198765432","totalDebt":0.0,"loyaltyPoints":50,"createdAt":"2026-08-28T10:00:00.000"}',
      );
      expect(fromRawStr.id, equals('CUST-002'));
      expect(fromRawStr.name, equals('Sara Ahmed'));
    });

    test('CustomerLedgerEntryModel correctly serializes and parses from JSON', () {
      final entry = CustomerLedgerEntryModel(
        id: 'LEDGER-001',
        customerId: 'CUST-001',
        type: CustomerLedgerType.debtCharge,
        amount: 150.0,
        relatedOrderId: 'ORD-100',
        notes: 'POS Account Sale',
        timestamp: DateTime(2026, 8, 28, 11, 0),
      );

      final json = entry.toJson();
      final restored = CustomerLedgerEntryModel.fromJson(json);

      expect(restored.id, equals('LEDGER-001'));
      expect(restored.type, equals(CustomerLedgerType.debtCharge));
      expect(restored.amount, equals(150.0));
      expect(restored.relatedOrderId, equals('ORD-100'));
    });
  });

  group('CustomerRepositoryImpl Business Logic & Shift PayIn Verification', () {
    late MockCustomerLocalDataSource mockCustomerDataSource;
    late MockShiftLocalDataSource mockShiftDataSource;
    late CustomerRepositoryImpl repository;

    final tCustomer = CustomerModel(
      id: 'CUST-100',
      name: 'Ahmed Youssef',
      phone: '01234567890',
      totalDebt: 500.0,
      loyaltyPoints: 80,
      createdAt: DateTime(2026, 8, 28, 9, 0),
    );

    final tActiveShift = ShiftModel(
      id: 'SHIFT-001',
      cashierId: 'cashier-1',
      startTime: DateTime(2026, 8, 28, 8, 0),
      startingCash: 500.0,
    );

    setUp(() {
      mockCustomerDataSource = MockCustomerLocalDataSource();
      mockShiftDataSource = MockShiftLocalDataSource();

      repository = CustomerRepositoryImpl(
        localDataSource: mockCustomerDataSource,
        shiftLocalDataSource: mockShiftDataSource,
      );
    });

    test('getCustomers filters customers by name or phone query', () async {
      when(() => mockCustomerDataSource.getCustomers())
          .thenAnswer((_) async => [tCustomer]);

      final result = await repository.getCustomers(searchQuery: 'Ahmed');
      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail(f.message),
        (customers) => expect(customers.first.name, equals('Ahmed Youssef')),
      );

      final phoneResult = await repository.getCustomers(searchQuery: '0123456');
      expect(phoneResult.isRight(), isTrue);
      phoneResult.fold(
        (f) => fail(f.message),
        (customers) => expect(customers.first.phone, equals('01234567890')),
      );
    });

    test('chargeCustomerDebt increases totalDebt and records a debtCharge ledger entry', () async {
      when(() => mockCustomerDataSource.getCustomerById('CUST-100'))
          .thenAnswer((_) async => tCustomer);
      when(() => mockCustomerDataSource.saveCustomer(any()))
          .thenAnswer((_) async {});
      when(() => mockCustomerDataSource.saveLedgerEntry(any()))
          .thenAnswer((_) async {});

      final result = await repository.chargeCustomerDebt(
        customerId: 'CUST-100',
        amount: 200.0,
        relatedOrderId: 'ORD-555',
        notes: 'Grocery store tab charge',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail(f.message),
        (entry) {
          expect(entry.type, equals(CustomerLedgerType.debtCharge));
          expect(entry.amount, equals(200.0));
          expect(entry.relatedOrderId, equals('ORD-555'));
        },
      );

      // Verify customer saved with 500 + 200 = 700 debt
      verify(() => mockCustomerDataSource.saveCustomer(any(that: predicate<CustomerModel>((c) => c.totalDebt == 700.0)))).called(1);
      verify(() => mockCustomerDataSource.saveLedgerEntry(any(that: predicate<CustomerLedgerEntryModel>((e) => e.type == CustomerLedgerType.debtCharge)))).called(1);
    });

    test('processDebtPayment reduces debt and records Shift PayIn if payment tender is Cash', () async {
      when(() => mockCustomerDataSource.getCustomerById('CUST-100'))
          .thenAnswer((_) async => tCustomer);
      when(() => mockCustomerDataSource.saveCustomer(any()))
          .thenAnswer((_) async {});
      when(() => mockCustomerDataSource.saveLedgerEntry(any()))
          .thenAnswer((_) async {});
      when(() => mockShiftDataSource.getActiveShift())
          .thenAnswer((_) async => tActiveShift);
      when(() => mockShiftDataSource.saveCashTransaction(any()))
          .thenAnswer((_) async {});

      final result = await repository.processDebtPayment(
        customerId: 'CUST-100',
        amount: 300.0,
        paymentTender: TenderType.cash,
        notes: 'Cash payment towards debt',
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail(f.message),
        (entry) {
          expect(entry.type, equals(CustomerLedgerType.debtPayment));
          expect(entry.amount, equals(300.0));
        },
      );

      // 1. Verify customer total debt reduced: 500 - 300 = 200
      verify(() => mockCustomerDataSource.saveCustomer(any(that: predicate<CustomerModel>((c) => c.totalDebt == 200.0)))).called(1);

      // 2. Verify ledger payment entry recorded
      verify(() => mockCustomerDataSource.saveLedgerEntry(any(that: predicate<CustomerLedgerEntryModel>((e) => e.type == CustomerLedgerType.debtPayment)))).called(1);

      // 3. Verify cash entered Shift Drawer via PayIn
      verify(() => mockShiftDataSource.saveCashTransaction(any(that: predicate<CashTransactionModel>((tx) => tx.type == CashTransactionType.payIn && tx.amount == 300.0)))).called(1);
    });
  });
}
