import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:empos/features/customers/data/datasources/customer_local_data_source.dart';
import 'package:empos/features/customers/data/models/customer_ledger_entry_model.dart';
import 'package:empos/features/customers/data/models/customer_model.dart';
import 'package:empos/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:empos/features/customers/domain/entities/customer.dart';
import 'package:empos/features/customers/domain/entities/customer_ledger_entry.dart';
import 'package:empos/features/customers/presentation/bloc/customer_bloc.dart';
import 'package:empos/features/customers/presentation/bloc/customer_state.dart';
import 'package:empos/features/customers/presentation/widgets/customer_ledger_dialog.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/shift/data/datasources/shift_local_data_source.dart';

class MockCustomerLocalDataSource extends Mock implements CustomerLocalDataSource {}
class MockShiftLocalDataSource extends Mock implements ShiftLocalDataSource {}
class MockCustomerBloc extends Mock implements CustomerBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      CustomerModel(
        id: 'fallback',
        name: 'fallback',
        phone: '000',
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      CustomerLedgerEntryModel(
        id: 'fallback_entry',
        customerId: 'fallback',
        type: CustomerLedgerType.debtPayment,
        amount: 100.0,
        timestamp: DateTime.now(),
      ),
    );
  });

  group('Customer Account Ledger — Partial Payment & Audit Trail Integrity', () {
    late MockCustomerLocalDataSource mockLocalDataSource;
    late MockShiftLocalDataSource mockShiftDataSource;
    late CustomerRepositoryImpl repository;

    final customerId = 'CUST-001';
    final customerPhone = '01111000011000';
    final initialCustomer = CustomerModel(
      id: customerId,
      name: 'Ahmed Ibrahim III',
      phone: customerPhone,
      totalDebt: 5000.0,
      createdAt: DateTime.now(),
    );

    setUp(() {
      mockLocalDataSource = MockCustomerLocalDataSource();
      mockShiftDataSource = MockShiftLocalDataSource();
      repository = CustomerRepositoryImpl(
        localDataSource: mockLocalDataSource,
        shiftLocalDataSource: mockShiftDataSource,
      );

      when(() => mockShiftDataSource.getActiveShift()).thenAnswer((_) async => null);
    });

    test('1. Save customer with 5000 debt auto-seeds initial ledger charge if no entries exist', () async {
      when(() => mockLocalDataSource.saveCustomer(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.getLedgerEntries(customerId)).thenAnswer((_) async => []);
      when(() => mockLocalDataSource.saveLedgerEntry(any())).thenAnswer((_) async {});

      final result = await repository.saveCustomer(initialCustomer);

      expect(result.isRight(), isTrue);
      verify(() => mockLocalDataSource.saveCustomer(any())).called(1);
      verify(() => mockLocalDataSource.saveLedgerEntry(any(that: predicate<CustomerLedgerEntryModel>((e) {
        return e.customerId == customerId &&
            e.type == CustomerLedgerType.debtCharge &&
            e.amount == 5000.0 &&
            e.notes!.contains('Opening');
      })))).called(1);
    });

    test('2. Partial payment of 800 EGP against 5000 debt reduces balance to 4200 and records ledger payment entry', () async {
      when(() => mockLocalDataSource.getCustomerById(customerId)).thenAnswer((_) async => initialCustomer);
      when(() => mockLocalDataSource.saveCustomer(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveLedgerEntry(any())).thenAnswer((_) async {});

      final result = await repository.processDebtPayment(
        customerId: customerId,
        amount: 800.0,
        paymentTender: TenderType.cash,
        notes: 'Partial Debt Payment (CASH)',
      );

      expect(result.isRight(), isTrue);
      final entry = result.getOrElse(() => throw Exception());
      expect(entry.amount, 800.0);
      expect(entry.type, CustomerLedgerType.debtPayment);

      // Verify saved customer has exact 4,200.00 debt
      verify(() => mockLocalDataSource.saveCustomer(any(that: predicate<CustomerModel>((c) {
        return c.id == customerId && (c.totalDebt - 4200.0).abs() < 0.001;
      })))).called(1);

      // Verify saved ledger payment entry
      verify(() => mockLocalDataSource.saveLedgerEntry(any(that: predicate<CustomerLedgerEntryModel>((e) {
        return e.customerId == customerId &&
            e.type == CustomerLedgerType.debtPayment &&
            e.amount == 800.0;
      })))).called(1);
    });

    test('3. Subsequent payment of 1000 EGP reduces 4200 balance to 3200', () async {
      final customerWith4200Debt = initialCustomer.copyWith(totalDebt: 4200.0);
      when(() => mockLocalDataSource.getCustomerById(customerId)).thenAnswer((_) async => customerWith4200Debt);
      when(() => mockLocalDataSource.saveCustomer(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveLedgerEntry(any())).thenAnswer((_) async {});

      final result = await repository.processDebtPayment(
        customerId: customerId,
        amount: 1000.0,
        paymentTender: TenderType.instapay,
        notes: 'Instapay Transfer',
      );

      expect(result.isRight(), isTrue);
      verify(() => mockLocalDataSource.saveCustomer(any(that: predicate<CustomerModel>((c) {
        return c.id == customerId && (c.totalDebt - 3200.0).abs() < 0.001;
      })))).called(1);
    });

    test('4. Full settlement of remaining 3200 EGP reduces debt to 0.00 (CLEARED)', () async {
      final customerWith3200Debt = initialCustomer.copyWith(totalDebt: 3200.0);
      when(() => mockLocalDataSource.getCustomerById(customerId)).thenAnswer((_) async => customerWith3200Debt);
      when(() => mockLocalDataSource.saveCustomer(any())).thenAnswer((_) async {});
      when(() => mockLocalDataSource.saveLedgerEntry(any())).thenAnswer((_) async {});

      final result = await repository.processDebtPayment(
        customerId: customerId,
        amount: 3200.0,
        paymentTender: TenderType.card,
        notes: 'Final Visa Settlement',
      );

      expect(result.isRight(), isTrue);
      verify(() => mockLocalDataSource.saveCustomer(any(that: predicate<CustomerModel>((c) {
        return c.id == customerId && c.totalDebt == 0.0;
      })))).called(1);
    });
  });

  group('CustomerBloc & Dialog Presentation Tests', () {
    testWidgets('CustomerLedgerDialog renders 4200.00 balance, PARTIALLY SETTLED badge, and audit entry', (tester) async {
      final mockBloc = MockCustomerBloc();
      final customer = Customer(
        id: 'CUST-001',
        name: 'Ahmed Ibrahim III',
        phone: '01111000011000',
        totalDebt: 4200.0,
        createdAt: DateTime.now(),
      );

      final ledgerEntries = [
        CustomerLedgerEntry(
          id: 'LEDGER-PAY-1',
          customerId: 'CUST-001',
          type: CustomerLedgerType.debtPayment,
          amount: 800.0,
          notes: 'Partial Debt Payment (CASH)',
          timestamp: DateTime.now(),
        ),
        CustomerLedgerEntry(
          id: 'LEDGER-CHG-1',
          customerId: 'CUST-001',
          type: CustomerLedgerType.debtCharge,
          amount: 5000.0,
          notes: 'Opening / Initial Debt Balance',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ];

      final state = CustomersLoaded(
        allCustomers: [customer],
        displayedCustomers: [customer],
        selectedCustomer: customer,
        selectedCustomerLedger: ledgerEntries,
      );

      final controller = StreamController<CustomerState>.broadcast();
      addTearDown(() => controller.close());

      when(() => mockBloc.state).thenReturn(state);
      when(() => mockBloc.stream).thenAnswer((_) => controller.stream);
      when(() => mockBloc.close()).thenAnswer((_) async {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<CustomerBloc>.value(
              value: mockBloc,
              child: CustomerLedgerDialog(customer: customer),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Outstanding Debt Balance is 4,200.00
      expect(find.textContaining('4,200.00'), findsWidgets);
      // Verify Partial Badge
      expect(find.textContaining('PARTIALLY SETTLED'), findsOneWidget);
      // Verify Audit history count
      expect(find.text('Transaction Audit History (2 entries)'), findsOneWidget);
      // Verify payment entry and charge entry rows
      expect(find.text('DEBT PAYMENT'), findsOneWidget);
      expect(find.text('CHARGE (+DEBT)'), findsOneWidget);
      expect(find.text('-EGP 800.00'), findsOneWidget);
      expect(find.text('+EGP 5,000.00'), findsOneWidget);
    });
  });
}
