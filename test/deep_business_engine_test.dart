import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/catalog/domain/entities/product_batch.dart';
import 'package:empos/features/catalog/domain/repositories/catalog_repository.dart';
import 'package:empos/features/clinic/domain/entities/clinic_visit.dart';
import 'package:empos/features/clinic/domain/entities/procedure_item.dart';
import 'package:empos/features/clinic/domain/repositories/clinic_repository.dart';
import 'package:empos/features/clinic/domain/usecases/complete_visit_usecase.dart';
import 'package:empos/features/customers/domain/entities/customer.dart';
import 'package:empos/features/customers/domain/repositories/customer_repository.dart';
import 'package:empos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:empos/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/pos/domain/services/fefo_picking_engine.dart';
import 'package:empos/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:empos/features/shift/domain/entities/consolidated_z_report.dart';
import 'package:empos/features/shift/domain/entities/shift.dart';
import 'package:empos/features/shift/domain/entities/z_report.dart';
import 'package:empos/features/shift/domain/repositories/shift_repository.dart';
import 'package:empos/features/shift/domain/usecases/generate_consolidated_z_report_usecase.dart';
import 'package:empos/features/shift/presentation/widgets/consolidated_z_report_dialog.dart';

import 'package:empos/features/pos/data/models/order_model.dart';

class MockClinicRepository extends Mock implements ClinicRepository {}
class MockCatalogRepository extends Mock implements CatalogRepository {}
class MockCustomerRepository extends Mock implements CustomerRepository {}
class MockPosLocalDataSource extends Mock implements PosLocalDataSource {}
class MockCatalogLocalDataSource extends Mock implements CatalogLocalDataSource {}
class MockShiftRepository extends Mock implements ShiftRepository {}
class FakePosOrderModel extends Fake implements PosOrderModel {}

void main() {
  setUpAll(() {
    registerFallbackValue(const Product(
      id: 'dummy',
      nameEn: 'dummy',
      categoryId: 'cat',
      price: 10,
      stock: 10,
      barcode: '123',
    ));
    registerFallbackValue(Customer(
      id: 'cust_1',
      name: 'Test',
      phone: '0100000000',
      createdAt: DateTime.now(),
    ));
    registerFallbackValue(FakePosOrderModel());
  });

  group('Task 1: Clinic Consumables Auto-Deduction Tests', () {
    late MockClinicRepository mockClinicRepo;
    late MockCatalogRepository mockCatalogRepo;
    late CompleteVisitUseCase useCase;

    setUp(() {
      mockClinicRepo = MockClinicRepository();
      mockCatalogRepo = MockCatalogRepository();
      useCase = CompleteVisitUseCase(mockClinicRepo, mockCatalogRepo);
    });

    test('Completing visit with root canal automatically decrements consumable inventory', () async {
      final sampleVisit = ClinicVisit(
        id: 'vis_101',
        patientId: 'pat_1',
        patientName: 'John Doe',
        doctorName: 'Dr. Sarah',
        queueNumber: 1,
        status: ClinicVisitStatus.inExamination,
        checkInTime: DateTime.now().subtract(const Duration(minutes: 30)),
        appliedProcedures: const [
          ProcedureItem(
            id: 'proc_root_canal',
            code: 'root_canal',
            name: 'Root Canal Therapy',
            standardFee: 350.0,
            requiredConsumables: ['prod_dental_anesthetic', 'prod_gutta_percha'],
          ),
        ],
      );

      final completedVisit = sampleVisit.copyWith(
        status: ClinicVisitStatus.completed,
        completionTime: DateTime.now(),
      );

      when(() => mockClinicRepo.completeVisit(sampleVisit))
          .thenAnswer((_) async => Right(completedVisit));
      when(() => mockCatalogRepo.getProducts())
          .thenAnswer((_) async => const Right([]));
      when(() => mockCatalogRepo.updateStock(any(), any()))
          .thenAnswer((_) async => const Right(unit));

      final result = await useCase(sampleVisit);

      expect(result.isRight(), isTrue);
      verify(() => mockClinicRepo.completeVisit(sampleVisit)).called(1);
      // Both required consumables must be decremented (-1 each)
      verify(() => mockCatalogRepo.updateStock('prod_dental_anesthetic', -1)).called(1);
      verify(() => mockCatalogRepo.updateStock('prod_gutta_percha', -1)).called(1);
    });

    test('Procedure with no explicit consumables falls back to default procedure mapping', () async {
      final sampleVisit = ClinicVisit(
        id: 'vis_102',
        patientId: 'pat_2',
        patientName: 'Jane Smith',
        doctorName: 'Dr. Sarah',
        queueNumber: 2,
        status: ClinicVisitStatus.inExamination,
        checkInTime: DateTime.now().subtract(const Duration(minutes: 20)),
        appliedProcedures: const [
          ProcedureItem(
            id: 'proc_comp_fill',
            code: 'composite_filling',
            name: 'Composite Resin Filling',
            standardFee: 120.0,
            requiredConsumables: [], // Empty, triggers default mapping
          ),
        ],
      );

      final completedVisit = sampleVisit.copyWith(
        status: ClinicVisitStatus.completed,
        completionTime: DateTime.now(),
      );

      when(() => mockClinicRepo.completeVisit(sampleVisit))
          .thenAnswer((_) async => Right(completedVisit));
      when(() => mockCatalogRepo.getProducts())
          .thenAnswer((_) async => const Right([]));
      when(() => mockCatalogRepo.updateStock(any(), any()))
          .thenAnswer((_) async => const Right(unit));

      final result = await useCase(sampleVisit);

      expect(result.isRight(), isTrue);
      // Verify composite filling consumables deducted: composite, bonding, articulating paper
      verify(() => mockCatalogRepo.updateStock('prod_dental_composite', -1)).called(1);
      verify(() => mockCatalogRepo.updateStock('prod_bonding_agent', -1)).called(1);
      verify(() => mockCatalogRepo.updateStock('prod_articulating_paper', -1)).called(1);
    });
  });

  group('Task 2: FEFO Engine & Customer Loyalty Tests', () {
    test('FEFO engine allocates stock from earliest expiring batches first', () {
      final now = DateTime.now();
      final batch1 = ProductBatch(
        id: 'b1',
        productId: 'prod_amox',
        batchNumber: 'LOT-2026-A',
        expiryDate: now.add(const Duration(days: 30)), // Expiring earliest
        quantity: 5,
      );
      final batch2 = ProductBatch(
        id: 'b2',
        productId: 'prod_amox',
        batchNumber: 'LOT-2026-B',
        expiryDate: now.add(const Duration(days: 90)), // Expiring later
        quantity: 10,
      );
      final batch3 = ProductBatch(
        id: 'b3',
        productId: 'prod_amox',
        batchNumber: 'LOT-2027-C',
        expiryDate: now.add(const Duration(days: 365)), // Expiring latest
        quantity: 20,
      );

      // Deduct 8 units: should deplete all 5 of batch1 and 3 from batch2
      final result = FefoPickingEngine.pickBatches(
        availableBatches: [batch3, batch1, batch2], // Passed unsorted
        quantityToDeduct: 8,
      );

      expect(result.remainingUnfulfilledQuantity, 0);
      expect(result.deductedPerBatch['b1'], 5);
      expect(result.deductedPerBatch['b2'], 3);
      expect(result.deductedPerBatch.containsKey('b3'), isFalse);

      final updatedB1 = result.updatedBatches.firstWhere((b) => b.id == 'b1');
      final updatedB2 = result.updatedBatches.firstWhere((b) => b.id == 'b2');
      final updatedB3 = result.updatedBatches.firstWhere((b) => b.id == 'b3');

      expect(updatedB1.quantity, 0);
      expect(updatedB2.quantity, 7); // 10 - 3
      expect(updatedB3.quantity, 20); // untouched
    });

    test('POS checkout accrues customer loyalty points (1 point per 10 currency units)', () async {
      final mockPosDs = MockPosLocalDataSource();
      final mockCatDs = MockCatalogLocalDataSource();
      final mockCustRepo = MockCustomerRepository();

      final posRepo = PosRepositoryImpl(
        localDataSource: mockPosDs,
        catalogLocalDataSource: mockCatDs,
        customerRepository: mockCustRepo,
      );

      const testProduct = Product(
        id: 'p1',
        nameEn: 'Espresso Blend',
        categoryId: 'c1',
        price: 50.0,
        stock: 100,
        barcode: '111',
      );

      final cart = Cart(items: [CartItem(product: testProduct, quantity: 2, unitPrice: 50.0)]);
      expect(cart.grandTotal, 100.0);

      final customer = Customer(
        id: 'cust_ahmed',
        name: 'Ahmed POS',
        phone: '01012345678',
        loyaltyPoints: 25,
        createdAt: DateTime.now(),
      );

      when(() => mockCatDs.updateStock(any(), any())).thenAnswer((_) async {});
      when(() => mockPosDs.saveOrder(any())).thenAnswer((_) async {});
      when(() => mockPosDs.clearActiveCart()).thenAnswer((_) async {});
      when(() => mockCustRepo.getCustomers(searchQuery: '01012345678'))
          .thenAnswer((_) async => Right([customer]));
      when(() => mockCustRepo.saveCustomer(any()))
          .thenAnswer((invocation) async => Right(invocation.positionalArguments[0] as Customer));

      final checkoutResult = await posRepo.processCheckout(
        cart: cart,
        payments: const [PaymentDetail(tenderType: TenderType.cash, amount: 100.0)],
        customerPhone: '01012345678',
      );

      expect(checkoutResult.isRight(), isTrue);
      // Verify customer was saved with 25 + 10 = 35 loyalty points
      verify(() => mockCustRepo.saveCustomer(any(that: predicate<Customer>((c) => c.loyaltyPoints == 35)))).called(1);
    });
  });

  group('Task 3: Consolidated Daily Z-Report Tests', () {
    late MockShiftRepository mockShiftRepo;
    late GenerateConsolidatedZReportUseCase useCase;

    setUp(() {
      mockShiftRepo = MockShiftRepository();
      useCase = GenerateConsolidatedZReportUseCase(mockShiftRepo);
    });

    test('Aggregates multiple closed shifts into a single consolidated daily report', () async {
      final today = DateTime.now();

      final shift1 = Shift(
        id: 'shift_morning',
        cashierId: 'usr_cashier1',
        cashierName: 'Morning Cashier',
        startTime: today.subtract(const Duration(hours: 8)),
        endTime: today.subtract(const Duration(hours: 4)),
        startingCash: 200.0,
        expectedCash: 700.0,
        actualCash: 700.0,
        difference: 0.0,
        status: ShiftStatus.closed,
      );

      final shift2 = Shift(
        id: 'shift_evening',
        cashierId: 'usr_cashier2',
        cashierName: 'Evening Cashier',
        startTime: today.subtract(const Duration(hours: 4)),
        endTime: today.subtract(const Duration(minutes: 10)),
        startingCash: 200.0,
        expectedCash: 950.0,
        actualCash: 930.0, // $20 shortage
        difference: -20.0,
        status: ShiftStatus.closed,
      );

      when(() => mockShiftRepo.getShiftHistory())
          .thenAnswer((_) async => Right([shift1, shift2]));

      final zReport1 = ZReport(
        shift: shift1,
        totalOrdersCount: 20,
        grossSales: 600.0,
        netSales: 500.0,
        totalDiscounts: 100.0,
        totalTax: 50.0,
        totalCashSales: 500.0,
        totalCardSales: 0.0,
        totalPayIns: 0.0,
        totalPayOuts: 0.0,
        totalRefunds: 0.0,
        openingCash: 200.0,
        expectedCash: 700.0,
        actualCash: 700.0,
        difference: 0.0,
        generatedAt: today,
      );

      final zReport2 = ZReport(
        shift: shift2,
        totalOrdersCount: 30,
        grossSales: 900.0,
        netSales: 750.0,
        totalDiscounts: 150.0,
        totalTax: 75.0,
        totalCashSales: 750.0,
        totalCardSales: 100.0,
        totalPayIns: 0.0,
        totalPayOuts: 0.0,
        totalRefunds: 20.0,
        openingCash: 200.0,
        expectedCash: 950.0,
        actualCash: 930.0,
        difference: -20.0,
        generatedAt: today,
      );

      when(() => mockShiftRepo.generateZReport('shift_morning'))
          .thenAnswer((_) async => Right(zReport1));
      when(() => mockShiftRepo.generateZReport('shift_evening'))
          .thenAnswer((_) async => Right(zReport2));

      final result = await useCase();

      expect(result.isRight(), isTrue);
      final report = result.getOrElse(() => throw Exception());

      expect(report.totalShiftsCount, 2);
      expect(report.totalOrdersCount, 50);
      expect(report.totalNetSales, 1250.0);
      expect(report.totalOpeningCash, 400.0);
      expect(report.totalExpectedCash, 1650.0);
      expect(report.totalCountedCash, 1630.0);
      expect(report.totalDifference, -20.0);
      expect(report.isShortage, isTrue);
      expect(report.totalCardSales, 100.0);
      expect(report.totalRefunds, 20.0);
    });

    testWidgets('ConsolidatedZReportDialog renders KPI tiles and audit table', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockUc = MockGenerateConsolidatedZReportUseCase();
      final report = ConsolidatedZReport(
        date: DateTime.now(),
        totalShiftsCount: 2,
        totalOrdersCount: 45,
        totalGrossSales: 2500.0,
        totalNetSales: 2300.0,
        totalDiscounts: 200.0,
        totalTax: 150.0,
        totalOpeningCash: 500.0,
        totalExpectedCash: 2000.0,
        totalCountedCash: 2000.0,
        totalDifference: 0.0,
        totalCashSales: 1500.0,
        totalCardSales: 800.0,
        totalRefunds: 0.0,
        closedShifts: const [],
        generatedAt: DateTime.now(),
      );

      when(() => mockUc.call(targetDate: any(named: 'targetDate')))
          .thenAnswer((_) async => Right(report));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConsolidatedZReportDialog(customUseCase: mockUc),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Consolidated Daily Z-Report'), findsOneWidget);
      expect(find.text('TOTAL NET SALES'), findsOneWidget);
      expect(find.text('EXPECTED CASH'), findsOneWidget);
      expect(find.text('COUNTED CASH'), findsOneWidget);
      expect(find.text('DIGITAL / CARD'), findsOneWidget);
      expect(find.text('CLOSED REGISTER SHIFTS AUDIT LOG'), findsOneWidget);
    });
  });
}

class MockGenerateConsolidatedZReportUseCase extends Mock implements GenerateConsolidatedZReportUseCase {}
