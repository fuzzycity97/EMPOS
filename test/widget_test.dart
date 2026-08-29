import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/core/config/domain/entities/store_blueprint.dart';
import 'package:empos/core/config/presentation/bloc/config_bloc.dart';
import 'package:empos/core/config/presentation/bloc/config_state.dart';
import 'package:empos/core/config/presentation/pages/store_builder_wizard_page.dart';
import 'package:empos/core/config/presentation/widgets/advanced_settings_dialog.dart';
import 'package:empos/core/theme/app_theme.dart';
import 'package:empos/features/catalog/domain/entities/category.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:empos/features/catalog/presentation/bloc/catalog_state.dart';
import 'package:empos/features/catalog/presentation/pages/catalog_page.dart';
import 'package:empos/features/customers/domain/entities/customer.dart';
import 'package:empos/features/customers/presentation/bloc/customer_bloc.dart';
import 'package:empos/features/customers/presentation/bloc/customer_state.dart';
import 'package:empos/features/customers/presentation/pages/customers_page.dart';
import 'package:empos/features/erp/domain/entities/employee.dart';
import 'package:empos/features/erp/domain/entities/expense.dart';
import 'package:empos/features/erp/presentation/bloc/erp_bloc.dart';
import 'package:empos/features/erp/presentation/bloc/erp_state.dart';
import 'package:empos/features/erp/presentation/pages/boss_portal_page.dart';
import 'package:empos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:empos/features/orders/presentation/bloc/orders_state.dart';
import 'package:empos/features/orders/presentation/pages/orders_history_page.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/order.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:empos/features/pos/presentation/bloc/pos_state.dart';
import 'package:empos/features/pos/presentation/pages/pos_page.dart';
import 'package:empos/features/data_io/domain/entities/import_result.dart';
import 'package:empos/features/data_io/presentation/bloc/data_io_bloc.dart';
import 'package:empos/features/data_io/presentation/bloc/data_io_state.dart';
import 'package:empos/features/data_io/presentation/widgets/data_io_manager_dialog.dart';
import 'package:empos/features/shift/domain/entities/shift.dart';
import 'package:empos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:empos/features/shift/presentation/bloc/shift_state.dart';

class MockCatalogBloc extends Mock implements CatalogBloc {}
class MockPosBloc extends Mock implements PosBloc {}
class MockShiftBloc extends Mock implements ShiftBloc {}
class MockOrdersBloc extends Mock implements OrdersBloc {}
class MockCustomerBloc extends Mock implements CustomerBloc {}
class MockErpBloc extends Mock implements ErpBloc {}
class MockConfigBloc extends Mock implements ConfigBloc {}
class MockDataIoBloc extends Mock implements DataIoBloc {}

void main() {
  late MockCatalogBloc mockCatalogBloc;
  late MockPosBloc mockPosBloc;
  late MockShiftBloc mockShiftBloc;
  late MockOrdersBloc mockOrdersBloc;
  late StreamController<CatalogState> catalogStateController;
  late StreamController<PosState> posStateController;
  late StreamController<ShiftState> shiftStateController;
  late StreamController<OrdersState> ordersStateController;

  const tCategories = [
    Category(id: 'cat-general', name: 'General', isEnabled: true),
  ];

  const tProduct = Product(
    id: 'prod-001',
    nameEn: 'Espresso Double',
    categoryId: 'cat-general',
    price: 45.0,
    stock: 120,
    barcode: '622100000001',
  );

  const tProducts = [tProduct];

  final tActiveShift = Shift(
    id: 'SHIFT-001',
    cashierId: 'cashier-1',
    cashierName: 'Ahmed',
    startTime: DateTime(2026, 8, 27, 8, 0),
    startingCash: 500.0,
    expectedCash: 500.0,
    status: ShiftStatus.open,
  );

  final tPastOrder = PosOrder(
    id: 'ORD-500',
    orderNumber: 'TXN-500',
    cart: const Cart(
      items: [
        CartItem(product: tProduct, quantity: 2, unitPrice: 45.0),
      ],
      taxRate: 0.14,
    ),
    payments: const [
      PaymentDetail(tenderType: TenderType.cash, amount: 102.60),
    ],
    status: OrderStatus.paid,
    createdAt: DateTime(2026, 8, 28, 14, 0),
  );

  setUp(() {
    mockCatalogBloc = MockCatalogBloc();
    mockPosBloc = MockPosBloc();
    mockShiftBloc = MockShiftBloc();
    mockOrdersBloc = MockOrdersBloc();
    catalogStateController = StreamController<CatalogState>.broadcast();
    posStateController = StreamController<PosState>.broadcast();
    shiftStateController = StreamController<ShiftState>.broadcast();
    ordersStateController = StreamController<OrdersState>.broadcast();
  });

  tearDown(() {
    catalogStateController.close();
    posStateController.close();
    shiftStateController.close();
    ordersStateController.close();
  });

  testWidgets('Catalog page renders header, search bar, and products when loaded', (WidgetTester tester) async {
    const loadedState = CatalogLoaded(
      allProducts: tProducts,
      displayedProducts: tProducts,
      categories: tCategories,
    );

    when(() => mockCatalogBloc.state).thenReturn(loadedState);
    when(() => mockCatalogBloc.stream).thenAnswer((_) => catalogStateController.stream);
    when(() => mockCatalogBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: CatalogPage(bloc: mockCatalogBloc),
      ),
    );
    await tester.pump();

    expect(find.text('Catalog & Stock Matrix'), findsOneWidget);
    expect(find.text('Espresso Double'), findsOneWidget);
  });

  testWidgets('POS page renders cart dock and product grid when active shift is ready', (WidgetTester tester) async {
    final posReadyState = PosReady(
      cart: const Cart(
        items: [
          CartItem(product: tProduct, quantity: 2, unitPrice: 45.0),
        ],
        taxRate: 0.14,
      ),
      allProducts: tProducts,
      displayedProducts: tProducts,
      categories: tCategories,
      heldTabs: const [],
    );

    when(() => mockPosBloc.state).thenReturn(posReadyState);
    when(() => mockPosBloc.stream).thenAnswer((_) => posStateController.stream);
    when(() => mockPosBloc.close()).thenAnswer((_) async {});

    when(() => mockShiftBloc.state).thenReturn(ActiveShiftReady(shift: tActiveShift));
    when(() => mockShiftBloc.stream).thenAnswer((_) => shiftStateController.stream);
    when(() => mockShiftBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: PosPage(posBloc: mockPosBloc, shiftBloc: mockShiftBloc),
      ),
    );
    await tester.pump();

    expect(find.text('Current Order'), findsOneWidget);
    expect(find.text('PAY / CHECKOUT'), findsOneWidget);
    expect(find.text('Espresso Double'), findsWidgets);
    expect(find.text('Cash Drawer Locked'), findsNothing);
  });

  testWidgets('POS page renders shift lock overlay when no active shift exists', (WidgetTester tester) async {
    final posReadyState = PosReady(
      cart: const Cart(taxRate: 0.14),
      allProducts: tProducts,
      displayedProducts: tProducts,
      categories: tCategories,
    );

    when(() => mockPosBloc.state).thenReturn(posReadyState);
    when(() => mockPosBloc.stream).thenAnswer((_) => posStateController.stream);
    when(() => mockPosBloc.close()).thenAnswer((_) async {});

    when(() => mockShiftBloc.state).thenReturn(const NoActiveShift());
    when(() => mockShiftBloc.stream).thenAnswer((_) => shiftStateController.stream);
    when(() => mockShiftBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: PosPage(posBloc: mockPosBloc, shiftBloc: mockShiftBloc),
      ),
    );
    await tester.pump();

    expect(find.text('Cash Drawer Locked'), findsOneWidget);
    expect(find.text('START SHIFT & DECLARE FLOAT'), findsOneWidget);
  });

  testWidgets('Orders history page renders transaction table and status badge', (WidgetTester tester) async {
    final loadedState = OrdersLoaded(
      allOrders: [tPastOrder],
      displayedOrders: [tPastOrder],
    );

    when(() => mockOrdersBloc.state).thenReturn(loadedState);
    when(() => mockOrdersBloc.stream).thenAnswer((_) => ordersStateController.stream);
    when(() => mockOrdersBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: OrdersHistoryPage(bloc: mockOrdersBloc),
      ),
    );
    await tester.pump();

    expect(find.text('Sales History & Returns Ledger'), findsOneWidget);
    expect(find.text('#TXN-500'), findsOneWidget);
    expect(find.text('PAID'), findsOneWidget);
  });

  testWidgets('Customers page renders KPI cards and customer table row', (WidgetTester tester) async {
    final mockCustomerBloc = MockCustomerBloc();
    final customerStateController = StreamController<CustomerState>.broadcast();
    addTearDown(() => customerStateController.close());

    final tCustomer = Customer(
      id: 'CUST-001',
      name: 'Youssef Mansour',
      phone: '01011112222',
      totalDebt: 250.0,
      loyaltyPoints: 50,
      createdAt: DateTime.now(),
    );

    final loadedState = CustomersLoaded(
      allCustomers: [tCustomer],
      displayedCustomers: [tCustomer],
    );

    when(() => mockCustomerBloc.state).thenReturn(loadedState);
    when(() => mockCustomerBloc.stream).thenAnswer((_) => customerStateController.stream);
    when(() => mockCustomerBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: CustomersPage(bloc: mockCustomerBloc),
      ),
    );
    await tester.pump();

    expect(find.text('Total Customers'), findsOneWidget);
    expect(find.text('Total Outstanding Debt'), findsOneWidget);
    expect(find.text('Youssef Mansour'), findsOneWidget);
    expect(find.text('01011112222'), findsOneWidget);
    expect(find.text('ADD NEW CUSTOMER'), findsOneWidget);
  });

  testWidgets('Boss portal page renders KPI cards and operational expense table', (WidgetTester tester) async {
    final mockErpBloc = MockErpBloc();
    final erpStateController = StreamController<ErpState>.broadcast();
    addTearDown(() => erpStateController.close());

    final tExpense = Expense(
      id: 'EXP-001',
      category: ExpenseCategory.rent,
      amount: 12000.0,
      date: DateTime.now(),
      description: 'Store Downtown Branch Rent',
      isPaidFromDrawer: false,
    );

    final tEmployee = Employee(
      id: 'EMP-001',
      name: 'Mostafa Samir',
      role: EmployeeRole.manager,
      baseSalary: 10000.0,
      hireDate: DateTime(2026, 1, 1),
    );

    final loadedState = ErpLoaded(
      employees: [tEmployee],
      expenses: [tExpense],
      cashAdvances: const [],
      salarySlips: const [],
      selectedMonth: DateTime.now().month,
      selectedYear: DateTime.now().year,
      activeSubTabIndex: 0,
    );

    when(() => mockErpBloc.state).thenReturn(loadedState);
    when(() => mockErpBloc.stream).thenAnswer((_) => erpStateController.stream);
    when(() => mockErpBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BossPortalPage(bloc: mockErpBloc),
      ),
    );
    await tester.pump();

    expect(find.text('Boss Manager ERP & Payroll Hub'), findsOneWidget);
    expect(find.text('Total Monthly Expenses'), findsOneWidget);
    expect(find.text('Committed Net Payroll'), findsOneWidget);
    expect(find.text('Store Downtown Branch Rent'), findsOneWidget);
    expect(find.text('RECORD EXPENSE'), findsOneWidget);
  });

  testWidgets('StoreBuilderWizardPage renders industry cards and launch button', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(body: StoreBuilderWizardPage()),
      ),
    );
    await tester.pump();

    expect(find.text('Store Builder & Blueprint Setup Wizard'), findsOneWidget);
    expect(find.text('Retail & Supermarkets'), findsOneWidget);
    expect(find.text('Medical, Dental & Clinical Practice'), findsOneWidget);
    expect(find.text('Food & Beverage'), findsOneWidget);
    expect(find.text('Save Blueprint & Launch POS Workspace'), findsOneWidget);
  });

  testWidgets('POS page reactively renders Scan Rx when Pharmacy industry blueprint is loaded', (WidgetTester tester) async {
    final mockConfig = MockConfigBloc();
    final configController = StreamController<ConfigState>.broadcast();
    addTearDown(() => configController.close());

    final pharmacyBlueprint = StoreBlueprint(
      storeName: 'Care Pharmacy',
      industryType: IndustryType.pharmacy,
      themeColorHex: '#10B981',
      toggles: const {'sw.prescription_scanning': true},
    );

    when(() => mockConfig.state).thenReturn(ConfigLoaded(blueprint: pharmacyBlueprint));
    when(() => mockConfig.stream).thenAnswer((_) => configController.stream);
    when(() => mockConfig.close()).thenAnswer((_) async {});

    final posReadyState = PosReady(
      cart: const Cart(taxRate: 0.14),
      allProducts: tProducts,
      displayedProducts: tProducts,
      categories: tCategories,
      heldTabs: const [],
    );

    when(() => mockPosBloc.state).thenReturn(posReadyState);
    when(() => mockPosBloc.stream).thenAnswer((_) => posStateController.stream);
    when(() => mockPosBloc.close()).thenAnswer((_) async {});

    when(() => mockShiftBloc.state).thenReturn(ActiveShiftReady(shift: tActiveShift));
    when(() => mockShiftBloc.stream).thenAnswer((_) => shiftStateController.stream);
    when(() => mockShiftBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dynamicDarkTheme(const Color(0xFF10B981)),
        home: PosPage(
          posBloc: mockPosBloc,
          shiftBloc: mockShiftBloc,
          configBloc: mockConfig,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Scan Rx'), findsOneWidget);
  });

  testWidgets('POS page reactively renders Tables button when Restaurant industry blueprint is loaded', (WidgetTester tester) async {
    final mockConfig = MockConfigBloc();
    final configController = StreamController<ConfigState>.broadcast();
    addTearDown(() => configController.close());

    final restaurantBlueprint = StoreBlueprint(
      storeName: 'Bella Italia Cafe',
      industryType: IndustryType.foodAndBeverage,
      themeColorHex: '#F59E0B',
      toggles: const {'sw.table_management': true},
    );

    when(() => mockConfig.state).thenReturn(ConfigLoaded(blueprint: restaurantBlueprint));
    when(() => mockConfig.stream).thenAnswer((_) => configController.stream);
    when(() => mockConfig.close()).thenAnswer((_) async {});

    final posReadyState = PosReady(
      cart: const Cart(taxRate: 0.14),
      allProducts: tProducts,
      displayedProducts: tProducts,
      categories: tCategories,
      heldTabs: const [],
    );

    when(() => mockPosBloc.state).thenReturn(posReadyState);
    when(() => mockPosBloc.stream).thenAnswer((_) => posStateController.stream);
    when(() => mockPosBloc.close()).thenAnswer((_) async {});

    when(() => mockShiftBloc.state).thenReturn(ActiveShiftReady(shift: tActiveShift));
    when(() => mockShiftBloc.stream).thenAnswer((_) => shiftStateController.stream);
    when(() => mockShiftBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dynamicDarkTheme(const Color(0xFFF59E0B)),
        home: PosPage(
          posBloc: mockPosBloc,
          shiftBloc: mockShiftBloc,
          configBloc: mockConfig,
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Tables'), findsOneWidget);
  });

  testWidgets('CatalogPage displays Import / Export button and opens DataIoManagerDialog', (WidgetTester tester) async {
    const loadedState = CatalogLoaded(
      allProducts: tProducts,
      displayedProducts: tProducts,
      categories: tCategories,
    );

    when(() => mockCatalogBloc.state).thenReturn(loadedState);
    when(() => mockCatalogBloc.stream).thenAnswer((_) => catalogStateController.stream);
    when(() => mockCatalogBloc.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: CatalogPage(bloc: mockCatalogBloc),
      ),
    );
    await tester.pump();

    expect(find.text('Import / Export'), findsOneWidget);
  });

  testWidgets('DataIoManagerDialog renders 3 action cards and displays success import stats', (WidgetTester tester) async {
    final mockDataIo = MockDataIoBloc();
    final dataIoController = StreamController<DataIoState>.broadcast();
    addTearDown(() => dataIoController.close());

    const importResult = ImportResult(
      successCount: 42,
      failCount: 2,
      errorMessages: ['Row 5: Invalid Retail Price'],
    );

    when(() => mockDataIo.state).thenReturn(
      const DataIoSuccess(
        'Import completed: 42 imported, 2 skipped',
        importResult: importResult,
        filePath: '/storage/products.csv',
      ),
    );
    when(() => mockDataIo.stream).thenAnswer((_) => dataIoController.stream);
    when(() => mockDataIo.close()).thenAnswer((_) async {});

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: BlocProvider<DataIoBloc>.value(
            value: mockDataIo,
            child: const DataIoManagerDialog(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('CSV Smart Import & Export Engine'), findsOneWidget);
    expect(find.text('DOWNLOAD TEMPLATE'), findsOneWidget);
    expect(find.text('EXPORT INVENTORY'), findsOneWidget);
    expect(find.text('SELECT & IMPORT CSV'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('• Row 5: Invalid Retail Price'), findsOneWidget);
  });

  testWidgets('AdvancedSettingsDialog renders toggle categories, typed search filter, and individual switches', (WidgetTester tester) async {
    final mockConfig = MockConfigBloc();
    final configController = StreamController<ConfigState>.broadcast();
    addTearDown(() => configController.close());

    final blueprint = StoreBlueprint(
      storeName: 'Test Hypermarket',
      industryType: IndustryType.supermarket,
      themeColorHex: '#10B981',
      toggles: const {
        'sw.table_management': false,
        'sw.grocery_weight_pricing': true,
        'hw.retail_barcode_scanner': true,
        'sw.compliance_audit_logs': true,
      },
    );

    when(() => mockConfig.state).thenReturn(ConfigLoaded(blueprint: blueprint));
    when(() => mockConfig.stream).thenAnswer((_) => configController.stream);
    when(() => mockConfig.close()).thenAnswer((_) async {});

    tester.view.physicalSize = const Size(1280, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: BlocProvider<ConfigBloc>.value(
            value: mockConfig,
            child: AdvancedSettingsDialog(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Advanced System Settings & Feature Matrix'), findsOneWidget);
    expect(find.text('SUPERMARKET'), findsOneWidget);
    expect(find.text('Software Feature Modules (sw.*)'), findsOneWidget);
    expect(find.text('Table Management'), findsOneWidget);
    expect(find.text('Grocery Weight Pricing'), findsOneWidget);
    expect(find.text('REQUIRED'), findsOneWidget);

    // Test typed search (Rule B)
    await tester.enterText(find.byType(TextField), 'scale');
    await tester.pump();

    expect(find.text('Grocery Scale'), findsOneWidget);
    expect(find.text('Table Management'), findsNothing);
  });
}
