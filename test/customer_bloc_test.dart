import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/customers/domain/entities/customer.dart';
import 'package:empos/features/customers/domain/entities/customer_ledger_entry.dart';
import 'package:empos/features/customers/domain/usecases/charge_customer_debt_usecase.dart';
import 'package:empos/features/customers/domain/usecases/get_customer_by_id_usecase.dart';
import 'package:empos/features/customers/domain/usecases/get_customer_ledger_usecase.dart';
import 'package:empos/features/customers/domain/usecases/get_customers_usecase.dart';
import 'package:empos/features/customers/domain/usecases/process_debt_payment_usecase.dart';
import 'package:empos/features/customers/domain/usecases/save_customer_usecase.dart';
import 'package:empos/features/customers/presentation/bloc/customer_bloc.dart';
import 'package:empos/features/customers/presentation/bloc/customer_event.dart';
import 'package:empos/features/customers/presentation/bloc/customer_state.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';

class MockGetCustomersUseCase extends Mock implements GetCustomersUseCase {}
class MockGetCustomerByIdUseCase extends Mock implements GetCustomerByIdUseCase {}
class MockSaveCustomerUseCase extends Mock implements SaveCustomerUseCase {}
class MockChargeCustomerDebtUseCase extends Mock implements ChargeCustomerDebtUseCase {}
class MockProcessDebtPaymentUseCase extends Mock implements ProcessDebtPaymentUseCase {}
class MockGetCustomerLedgerUseCase extends Mock implements GetCustomerLedgerUseCase {}

void main() {
  late MockGetCustomersUseCase mockGetCustomers;
  late MockGetCustomerByIdUseCase mockGetCustomerById;
  late MockSaveCustomerUseCase mockSaveCustomer;
  late MockChargeCustomerDebtUseCase mockChargeCustomerDebt;
  late MockProcessDebtPaymentUseCase mockProcessDebtPayment;
  late MockGetCustomerLedgerUseCase mockGetCustomerLedger;
  late CustomerBloc bloc;

  final tCustomer = Customer(
    id: 'CUST-001',
    name: 'Karim Hassan',
    phone: '01001234567',
    totalDebt: 150.0,
    loyaltyPoints: 30,
    createdAt: DateTime(2026, 8, 28, 10, 0),
  );

  final tLedgerEntry = CustomerLedgerEntry(
    id: 'LEDGER-001',
    customerId: 'CUST-001',
    type: CustomerLedgerType.debtCharge,
    amount: 150.0,
    timestamp: DateTime(2026, 8, 28, 10, 30),
  );

  setUpAll(() {
    registerFallbackValue(
      Customer(
        id: 'fallback',
        name: 'fallback',
        phone: '01000000000',
        createdAt: DateTime.now(),
      ),
    );
    registerFallbackValue(
      const ProcessDebtPaymentParams(
        customerId: 'fallback',
        amount: 0.0,
        paymentTender: TenderType.cash,
      ),
    );
    registerFallbackValue(
      const ChargeCustomerDebtParams(
        customerId: 'fallback',
        amount: 0.0,
      ),
    );
  });

  setUp(() {
    mockGetCustomers = MockGetCustomersUseCase();
    mockGetCustomerById = MockGetCustomerByIdUseCase();
    mockSaveCustomer = MockSaveCustomerUseCase();
    mockChargeCustomerDebt = MockChargeCustomerDebtUseCase();
    mockProcessDebtPayment = MockProcessDebtPaymentUseCase();
    mockGetCustomerLedger = MockGetCustomerLedgerUseCase();

    bloc = CustomerBloc(
      getCustomersUseCase: mockGetCustomers,
      getCustomerByIdUseCase: mockGetCustomerById,
      saveCustomerUseCase: mockSaveCustomer,
      chargeCustomerDebtUseCase: mockChargeCustomerDebt,
      processDebtPaymentUseCase: mockProcessDebtPayment,
      getCustomerLedgerUseCase: mockGetCustomerLedger,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CustomerBloc Tests', () {
    test('initial state should be CustomerInitial', () {
      expect(bloc.state, equals(const CustomerInitial()));
    });

    blocTest<CustomerBloc, CustomerState>(
      'emits [CustomerLoading, CustomersLoaded] when LoadCustomersEvent succeeds',
      build: () {
        when(() => mockGetCustomers()).thenAnswer((_) async => Right([tCustomer]));
        return bloc;
      },
      act: (b) => b.add(const LoadCustomersEvent()),
      expect: () => [
        const CustomerLoading(),
        CustomersLoaded(
          allCustomers: [tCustomer],
          displayedCustomers: [tCustomer],
        ),
      ],
    );

    blocTest<CustomerBloc, CustomerState>(
      'filters displayed customers when SearchCustomersEvent is added',
      build: () => bloc,
      seed: () => CustomersLoaded(
        allCustomers: [
          tCustomer,
          Customer(
            id: 'CUST-002',
            name: 'Nour El-Din',
            phone: '01122334455',
            createdAt: DateTime.now(),
          ),
        ],
        displayedCustomers: [
          tCustomer,
          Customer(
            id: 'CUST-002',
            name: 'Nour El-Din',
            phone: '01122334455',
            createdAt: DateTime.now(),
          ),
        ],
      ),
      act: (b) => b.add(const SearchCustomersEvent('Karim')),
      expect: () => [
        isA<CustomersLoaded>().having(
          (s) => s.displayedCustomers.length,
          'displayed length',
          1,
        ),
      ],
    );

    blocTest<CustomerBloc, CustomerState>(
      'loads customer ledger when SelectCustomerEvent is triggered',
      build: () {
        when(() => mockGetCustomerById('CUST-001'))
            .thenAnswer((_) async => Right(tCustomer));
        when(() => mockGetCustomerLedger('CUST-001'))
            .thenAnswer((_) async => Right([tLedgerEntry]));
        return bloc;
      },
      seed: () => CustomersLoaded(
        allCustomers: [tCustomer],
        displayedCustomers: [tCustomer],
      ),
      act: (b) => b.add(const SelectCustomerEvent('CUST-001')),
      expect: () => [
        isA<CustomersLoaded>()
            .having((s) => s.selectedCustomer?.name, 'name', 'Karim Hassan')
            .having((s) => s.selectedCustomerLedger.length, 'ledger count', 1),
      ],
    );

    blocTest<CustomerBloc, CustomerState>(
      'saves customer and updates list when SaveCustomerEvent is added',
      build: () {
        when(() => mockSaveCustomer(any()))
            .thenAnswer((_) async => Right(tCustomer));
        when(() => mockGetCustomers())
            .thenAnswer((_) async => Right([tCustomer]));
        return bloc;
      },
      act: (b) => b.add(SaveCustomerEvent(tCustomer)),
      expect: () => [
        isA<CustomersLoaded>().having(
          (s) => s.allCustomers.length,
          'all customers count',
          1,
        ),
      ],
    );
  });
}
