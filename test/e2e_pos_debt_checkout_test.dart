import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:empos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:empos/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:empos/features/customers/data/repositories/customer_repository_impl.dart';
import 'package:empos/features/customers/data/datasources/customer_local_data_source.dart';
import 'package:empos/features/customers/data/models/customer_model.dart';
import 'package:empos/features/customers/data/models/customer_ledger_entry_model.dart';
import 'package:empos/features/customers/domain/entities/customer_ledger_entry.dart';
import 'package:empos/features/pos/data/models/order_model.dart';
import 'package:empos/features/shift/data/datasources/shift_local_data_source.dart';

class MockPosLocalDataSource extends Mock implements PosLocalDataSource {}
class MockCatalogLocalDataSource extends Mock implements CatalogLocalDataSource {}
class MockCustomerLocalDataSource extends Mock implements CustomerLocalDataSource {}
class MockShiftLocalDataSource extends Mock implements ShiftLocalDataSource {}

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
        type: CustomerLedgerType.debtCharge,
        amount: 100.0,
        timestamp: DateTime.now(),
      ),
    );
    registerFallbackValue(
      PosOrderModel(
        id: 'fallback_order',
        orderNumber: 'ORD-000',
        cart: const Cart(),
        payments: const [],
        createdAt: DateTime.now(),
      ),
    );
  });

  testWidgets('E2E Clinical Procedure POS Checkout & Debt Ledger Badge Sync', (WidgetTester tester) async {
    final mockPosDataSource = MockPosLocalDataSource();
    final mockCatalogDataSource = MockCatalogLocalDataSource();
    final mockCustDataSource = MockCustomerLocalDataSource();
    final mockShiftDataSource = MockShiftLocalDataSource();

    final Map<String, CustomerModel> memoryCustomers = {};
    final List<CustomerLedgerEntryModel> memoryLedger = [];

    when(() => mockCustDataSource.getCustomerById(any())).thenAnswer((inv) async {
      final id = inv.positionalArguments[0] as String;
      return memoryCustomers[id];
    });

    when(() => mockCustDataSource.saveCustomer(any())).thenAnswer((inv) async {
      final cust = inv.positionalArguments[0] as CustomerModel;
      memoryCustomers[cust.id] = cust;
    });

    when(() => mockCustDataSource.getCustomers()).thenAnswer((_) async => memoryCustomers.values.toList());

    when(() => mockCustDataSource.getLedgerEntries(any())).thenAnswer((inv) async {
      final id = inv.positionalArguments[0] as String;
      return memoryLedger.where((e) => e.customerId == id).toList();
    });

    when(() => mockCustDataSource.saveLedgerEntry(any())).thenAnswer((inv) async {
      final entry = inv.positionalArguments[0] as CustomerLedgerEntryModel;
      memoryLedger.add(entry);
    });

    when(() => mockPosDataSource.saveOrder(any())).thenAnswer((_) async {});
    when(() => mockPosDataSource.clearActiveCart()).thenAnswer((_) async {});
    when(() => mockCatalogDataSource.updateStock(any(), any())).thenAnswer((_) async {});

    final customerRepo = CustomerRepositoryImpl(
      localDataSource: mockCustDataSource,
      shiftLocalDataSource: mockShiftDataSource,
    );

    final posRepo = PosRepositoryImpl(
      localDataSource: mockPosDataSource,
      catalogLocalDataSource: mockCatalogDataSource,
      customerRepository: customerRepo,
    );

    // 1. Save patient with 0.00 debt
    final patient = CustomerModel(
      id: 'patient-991',
      name: 'Youssef Ahmed (Ortho Patient)',
      phone: '01012345678',
      totalDebt: 0.0,
      loyaltyPoints: 0,
      createdAt: DateTime.now(),
    );
    await customerRepo.saveCustomer(patient);

    final initialCust = (await customerRepo.getCustomerById(patient.id)).getOrElse(() => throw 'error');
    expect(initialCust.totalDebt, 0.0);

    // 2. Build Cart with 8000 EGP clinical procedure
    const product = Product(
      id: 'proc-ortho-1',
      nameEn: 'Distal Femur Osteotomy & Fixation',
      barcode: 'PROC01',
      price: 8000.0,
      cost: 2000.0,
      stock: 10,
      categoryId: 'cat-ortho',
      trackQty: false,
    );

    const cart = Cart(
      items: [
        CartItem(
          product: product,
          quantity: 1,
          unitPrice: 8000.0,
        ),
      ],
      taxRate: 0.0,
    );
    expect(cart.grandTotal, 8000.0);

    // 3. Partial cash payment of 2,000 EGP
    final payments = [
      const PaymentDetail(
        tenderType: TenderType.cash,
        amount: 2000.0,
      ),
    ];

    // 4. Process checkout
    final result = await posRepo.processCheckout(
      cart: cart,
      payments: payments,
      cashierId: 'cashier-1',
      customerPhone: patient.phone,
      customerName: patient.name,
      changeGiven: 0.0,
    );

    expect(result.isRight(), isTrue);

    // 5. Assert patient debt is updated to 6,000 EGP (8,000 Total - 2,000 Paid)
    final updatedCust = (await customerRepo.getCustomerById(patient.id)).getOrElse(() => throw 'error');
    expect(updatedCust.totalDebt, 6000.0);

    // 6. Assert ledger entry is recorded
    final ledgerEntries = (await customerRepo.getCustomerLedger(patient.id)).getOrElse(() => []);
    expect(ledgerEntries.isNotEmpty, isTrue);
    expect(ledgerEntries.last.amount, 6000.0);
    expect(ledgerEntries.last.notes?.contains('Partial payment remaining balance') ?? false, isTrue);
  });
}
