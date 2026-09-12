import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/config/domain/entities/store_blueprint.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/core/config/presentation/bloc/config_bloc.dart';
import 'package:empos/core/config/presentation/bloc/config_state.dart';
import 'package:empos/features/pos/presentation/widgets/pos_search_header.dart';
import 'package:empos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:empos/features/pos/presentation/bloc/pos_state.dart';
import 'package:empos/features/pos/presentation/widgets/checkout_dialog.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/customers/presentation/pages/customers_page.dart';
import 'package:empos/features/customers/presentation/bloc/customer_bloc.dart';
import 'package:empos/features/customers/presentation/bloc/customer_state.dart';
import 'package:empos/features/customers/domain/entities/customer.dart';
import 'package:empos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:empos/features/shift/presentation/bloc/shift_state.dart';
import 'package:empos/features/pos/presentation/widgets/industry_pos_actions.dart';

class MockConfigBloc extends Mock implements ConfigBloc {}
class MockPosBloc extends Mock implements PosBloc {}
class MockCustomerBloc extends Mock implements CustomerBloc {}
class MockShiftBloc extends Mock implements ShiftBloc {}

void main() {
  group('StoreBlueprint isEnabled & MainShell _isTabEnabled Authority Tests', () {
    test('StoreBlueprint isEnabled respects explicit false over industry vertical default', () {
      final pharmacyBp = const StoreBlueprint(
        storeName: 'Test Pharmacy',
        industryType: IndustryType.pharmacy,
        specificIndustry: SpecificIndustry.pharmacy,
        toggles: {
          'sw.prescription_scanning': false,
          'sw.box_and_strip_selling': true,
        },
      );

      expect(pharmacyBp.isPharmacy, isTrue);
      expect(pharmacyBp.isEnabled('sw.prescription_scanning', defaultValue: pharmacyBp.isPharmacy), isFalse);
      expect(pharmacyBp.isEnabled('sw.box_and_strip_selling', defaultValue: pharmacyBp.isPharmacy), isTrue);
      expect(pharmacyBp.isEnabled('sw.unconfigured_key', defaultValue: pharmacyBp.isPharmacy), isTrue);
    });

    test('StoreBlueprint isEnabled respects explicit true when vertical default is false', () {
      final retailBp = const StoreBlueprint(
        storeName: 'Test Retail',
        industryType: IndustryType.retail,
        specificIndustry: SpecificIndustry.cashierPos,
        toggles: {
          'sw.table_management': true,
          'sw.dental_tooth_chart_editor': true,
        },
      );

      expect(retailBp.isRestaurant, isFalse);
      expect(retailBp.isDental, isFalse);
      expect(retailBp.isEnabled('sw.table_management', defaultValue: retailBp.isRestaurant), isTrue);
      expect(retailBp.isEnabled('sw.dental_tooth_chart_editor', defaultValue: retailBp.isDental), isTrue);
    });
  });

  group('POS Search Header Toggle Application Tests', () {
    late MockConfigBloc mockConfigBloc;
    late MockPosBloc mockPosBloc;
    late MockShiftBloc mockShiftBloc;

    setUp(() {
      mockConfigBloc = MockConfigBloc();
      mockPosBloc = MockPosBloc();
      mockShiftBloc = MockShiftBloc();
      when(() => mockPosBloc.state).thenReturn(const PosReady(cart: Cart()));
      when(() => mockPosBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockShiftBloc.state).thenReturn(const ShiftInitial());
      when(() => mockShiftBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('Hides prescription button when sw.prescription_scanning is explicitly false on pharmacy store', (tester) async {
      const blueprint = StoreBlueprint(
        storeName: 'Rx Pharmacy',
        industryType: IndustryType.pharmacy,
        specificIndustry: SpecificIndustry.pharmacy,
        toggles: {
          'sw.prescription_scanning': false,
        },
      );
      when(() => mockConfigBloc.state).thenReturn(const ConfigLoaded(blueprint: blueprint));
      when(() => mockConfigBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<PosBloc>.value(value: mockPosBloc),
                BlocProvider<ShiftBloc>.value(value: mockShiftBloc),
                BlocProvider<ConfigBloc>.value(value: mockConfigBloc),
              ],
              child: PosSearchHeader(
                categories: const [],
                selectedCategoryId: null,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PharmacyPrescriptionButton), findsNothing);
      expect(find.byType(ScaleWeightIndicator), findsNothing);
    });

    testWidgets('Shows prescription button when sw.prescription_scanning is explicitly true', (tester) async {
      const blueprint = StoreBlueprint(
        storeName: 'Rx Pharmacy',
        industryType: IndustryType.pharmacy,
        specificIndustry: SpecificIndustry.pharmacy,
        toggles: {
          'sw.prescription_scanning': true,
        },
      );
      when(() => mockConfigBloc.state).thenReturn(const ConfigLoaded(blueprint: blueprint));
      when(() => mockConfigBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<PosBloc>.value(value: mockPosBloc),
                BlocProvider<ShiftBloc>.value(value: mockShiftBloc),
                BlocProvider<ConfigBloc>.value(value: mockConfigBloc),
              ],
              child: PosSearchHeader(
                categories: const [],
                selectedCategoryId: null,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(PharmacyPrescriptionButton), findsOneWidget);
    });

    testWidgets('Shows live scale indicator when sw.grocery_weight_pricing is true', (tester) async {
      const blueprint = StoreBlueprint(
        storeName: 'Gourmet Market',
        industryType: IndustryType.retail,
        toggles: {
          'sw.grocery_weight_pricing': true,
        },
      );
      when(() => mockConfigBloc.state).thenReturn(const ConfigLoaded(blueprint: blueprint));
      when(() => mockConfigBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<PosBloc>.value(value: mockPosBloc),
                BlocProvider<ShiftBloc>.value(value: mockShiftBloc),
                BlocProvider<ConfigBloc>.value(value: mockConfigBloc),
              ],
              child: PosSearchHeader(
                categories: const [],
                selectedCategoryId: null,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(ScaleWeightIndicator), findsOneWidget);
    });
  });

  group('CheckoutDialog Debt Toggle Application Tests', () {
    late MockConfigBloc mockConfigBloc;
    late MockPosBloc mockPosBloc;
    late MockCustomerBloc mockCustomerBloc;

    setUp(() {
      mockConfigBloc = MockConfigBloc();
      mockPosBloc = MockPosBloc();
      mockCustomerBloc = MockCustomerBloc();
      when(() => mockPosBloc.state).thenReturn(const PosReady(cart: Cart()));
      when(() => mockPosBloc.stream).thenAnswer((_) => const Stream.empty());
      when(() => mockCustomerBloc.state).thenReturn(const CustomerInitial());
      when(() => mockCustomerBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('Hides Customer Account / Tab tender chip when sw.customer_debt_tracking is false', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const bp = StoreBlueprint(
        storeName: 'Cash Only Store',
        toggles: {
          'sw.customer_debt_tracking': false,
        },
      );
      when(() => mockConfigBloc.state).thenReturn(const ConfigLoaded(blueprint: bp));
      when(() => mockConfigBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<PosBloc>.value(value: mockPosBloc),
                BlocProvider<CustomerBloc>.value(value: mockCustomerBloc),
                BlocProvider<ConfigBloc>.value(value: mockConfigBloc),
              ],
              child: CheckoutDialog(cart: Cart()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Customer Account / Tab'), findsNothing);
      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Card'), findsOneWidget);
    });

    testWidgets('Shows Customer Account / Tab tender chip when sw.customer_debt_tracking is true', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      const bp = StoreBlueprint(
        storeName: 'Credit Store',
        toggles: {
          'sw.customer_debt_tracking': true,
        },
      );
      when(() => mockConfigBloc.state).thenReturn(const ConfigLoaded(blueprint: bp));
      when(() => mockConfigBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiBlocProvider(
              providers: [
                BlocProvider<PosBloc>.value(value: mockPosBloc),
                BlocProvider<CustomerBloc>.value(value: mockCustomerBloc),
                BlocProvider<ConfigBloc>.value(value: mockConfigBloc),
              ],
              child: CheckoutDialog(cart: Cart()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Customer Account / Tab'), findsOneWidget);
    });
  });

  group('CustomersPage Debt and Loyalty Toggle Application Tests', () {
    late MockConfigBloc mockConfigBloc;
    late MockCustomerBloc mockCustomerBloc;

    setUp(() {
      mockConfigBloc = MockConfigBloc();
      mockCustomerBloc = MockCustomerBloc();
      final testCustomer = Customer(
        id: 'cust-1',
        name: 'Ahmed Hassan',
        phone: '01012345678',
        totalDebt: 150.0,
        loyaltyPoints: 420,
        createdAt: DateTime.now(),
      );
      final loadedState = CustomersLoaded(
        allCustomers: [testCustomer],
        displayedCustomers: [testCustomer],
        searchQuery: '',
      );
      when(() => mockCustomerBloc.state).thenReturn(loadedState);
      when(() => mockCustomerBloc.stream).thenAnswer((_) => const Stream.empty());
    });

    testWidgets('Hides debt metrics & badges when sw.customer_debt_tracking is false', (tester) async {
      const bp = StoreBlueprint(
        storeName: 'No Debt Store',
        toggles: {
          'sw.customer_debt_tracking': false,
          'sw.loyalty_points': true,
        },
      );
      when(() => mockConfigBloc.state).thenReturn(const ConfigLoaded(blueprint: bp));
      when(() => mockConfigBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CustomerBloc>.value(value: mockCustomerBloc),
              BlocProvider<ConfigBloc>.value(value: mockConfigBloc),
            ],
            child: const CustomersPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Total Customers'), findsOneWidget);
      expect(find.text('Active Debtors'), findsNothing);
      expect(find.text('Total Outstanding Debt'), findsNothing);
      expect(find.textContaining('DEBT ('), findsNothing);
      expect(find.textContaining('420 Pts'), findsOneWidget);
    });

    testWidgets('Hides loyalty points when sw.loyalty_points is false', (tester) async {
      const bp = StoreBlueprint(
        storeName: 'No Loyalty Store',
        toggles: {
          'sw.customer_debt_tracking': true,
          'sw.loyalty_points': false,
        },
      );
      when(() => mockConfigBloc.state).thenReturn(const ConfigLoaded(blueprint: bp));
      when(() => mockConfigBloc.stream).thenAnswer((_) => const Stream.empty());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<CustomerBloc>.value(value: mockCustomerBloc),
              BlocProvider<ConfigBloc>.value(value: mockConfigBloc),
            ],
            child: const CustomersPage(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Total Customers'), findsOneWidget);
      expect(find.text('Active Debtors'), findsOneWidget);
      expect(find.textContaining('DEBT ('), findsOneWidget);
      expect(find.textContaining('420 Pts'), findsNothing);
    });
  });
}
