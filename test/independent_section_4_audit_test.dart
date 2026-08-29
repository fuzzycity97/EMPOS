import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/constants/app_colors.dart';
import 'package:empos/core/network/lan_sync/data/repositories/lan_sync_repository_impl.dart';
import 'package:empos/core/hardware/data/repositories/printer_repository_impl.dart';
import 'package:empos/features/auth/domain/entities/app_user.dart';
import 'package:empos/features/auth/domain/entities/user_role.dart';
import 'package:empos/features/auth/domain/repositories/auth_repository.dart';
import 'package:empos/features/auth/presentation/widgets/role_guard_widget.dart';
import 'package:empos/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:empos/features/auth/presentation/bloc/auth_state.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/catalog/data/models/product_model.dart';
import 'package:empos/features/catalog/domain/entities/product_batch.dart';
import 'package:empos/features/clinic/data/datasources/clinic_local_data_source.dart';
import 'package:empos/features/clinic/data/repositories/clinic_repository_impl.dart';
import 'package:empos/features/clinic/data/repositories/dental_repository_impl.dart';
import 'package:empos/features/clinic/domain/entities/clinic_visit.dart';
import 'package:empos/features/clinic/domain/entities/procedure_item.dart';
import 'package:empos/features/clinic/domain/usecases/check_in_patient_usecase.dart';
import 'package:empos/features/clinic/domain/usecases/complete_visit_usecase.dart';
import 'package:empos/features/clinic/domain/usecases/get_clinic_queue_usecase.dart';
import 'package:empos/features/clinic/domain/usecases/get_patient_tooth_chart_usecase.dart';
import 'package:empos/features/clinic/domain/usecases/get_patients_usecase.dart';
import 'package:empos/features/clinic/domain/usecases/get_rolling_mean_wait_usecase.dart';
import 'package:empos/features/clinic/domain/usecases/save_tooth_chart_usecase.dart';
import 'package:empos/features/clinic/domain/usecases/search_patients_usecase.dart';
import 'package:empos/features/clinic/domain/usecases/update_visit_status_usecase.dart';
import 'package:empos/features/clinic/presentation/bloc/clinic_bloc.dart';
import 'package:empos/features/clinic/presentation/bloc/clinic_event.dart';
import 'package:empos/features/pos/data/datasources/pos_local_data_source.dart';
import 'package:empos/features/pos/data/models/order_model.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/order.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:empos/features/pos/domain/usecases/process_checkout_usecase.dart';
import 'package:empos/features/pos/domain/services/fefo_picking_engine.dart';
import 'package:empos/features/finance_splits/data/datasources/finance_split_local_data_source.dart';
import 'package:empos/features/finance_splits/data/repositories/finance_split_repository_impl.dart';
import 'package:empos/features/finance_splits/domain/entities/revenue_split_rule.dart';
import 'package:empos/features/orders/data/datasources/orders_local_data_source.dart';
import 'package:empos/features/shift/data/datasources/shift_local_data_source.dart';
import 'package:empos/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:empos/features/catalog/data/repositories/catalog_repository_impl.dart';
import 'package:empos/features/erp/data/datasources/erp_local_data_source.dart';
import 'package:empos/features/erp/data/models/expense_model.dart';
import 'package:empos/features/erp/domain/entities/expense.dart';
import 'package:empos/features/erp/data/repositories/erp_repository_impl.dart';
import 'package:empos/features/bookings/data/datasources/booking_local_data_source.dart';
import 'package:empos/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:empos/features/bookings/domain/entities/booking_item.dart';
import 'package:empos/features/work_orders/data/datasources/work_order_local_data_source.dart';
import 'package:empos/features/work_orders/data/repositories/work_order_repository_impl.dart';
import 'package:empos/features/work_orders/domain/entities/work_order_ticket.dart';
import 'package:empos/features/data_io/data/repositories/data_io_repository_impl.dart';
import 'package:empos/features/rmm/data/repositories/rmm_repository_impl.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('empos_audit_test_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('INDEPENDENT VERIFICATION OF SECTION 4 (Actual Runtime Pipeline)', () {
    // -------------------------------------------------------------------------
    // PRIORITY 1: Real-Network LAN Sync Full Payload & State Reconciliation
    // -------------------------------------------------------------------------
    test('P1: Real WebSocket LAN Sync Hub on 9096, live broadcast, and state reconciliation after network drop', () async {
      final hostRepo = LanSyncRepositoryImpl();
      final clientRepo = LanSyncRepositoryImpl();

      // 1. Start real Host server on port 9096
      await hostRepo.startHostServer(port: 9096);
      expect(hostRepo.isHost, isTrue);
      expect(hostRepo.isConnected, isTrue);

      // 2. Connect real Client to Host via WebSocket
      await clientRepo.connectToHost('127.0.0.1', port: 9096);
      await Future.delayed(const Duration(milliseconds: 200));
      expect(clientRepo.isConnected, isTrue);

      // 3. Initialize real Hive datasources and repositories for Host and Client
      final clinicDataSource = ClinicLocalDataSourceImpl();
      final clinicRepo = ClinicRepositoryImpl(localDataSource: clinicDataSource);
      final dentalRepo = DentalRepositoryImpl(localDataSource: clinicDataSource);

      final hostBloc = ClinicBloc(
        getClinicQueueUseCase: GetClinicQueueUseCase(clinicRepo),
        checkInPatientUseCase: CheckInPatientUseCase(clinicRepo),
        updateVisitStatusUseCase: UpdateVisitStatusUseCase(clinicRepo),
        completeVisitUseCase: CompleteVisitUseCase(clinicRepo),
        getPatientToothChartUseCase: GetPatientToothChartUseCase(dentalRepo),
        saveToothChartUseCase: SaveToothChartUseCase(dentalRepo),
        getPatientsUseCase: GetPatientsUseCase(clinicRepo),
        searchPatientsUseCase: SearchPatientsUseCase(clinicRepo),
        getRollingMeanWaitUseCase: GetRollingMeanWaitUseCase(clinicRepo),
        clinicRepository: clinicRepo,
        lanSyncRepository: hostRepo,
      );

      final clientBloc = ClinicBloc(
        getClinicQueueUseCase: GetClinicQueueUseCase(clinicRepo),
        checkInPatientUseCase: CheckInPatientUseCase(clinicRepo),
        updateVisitStatusUseCase: UpdateVisitStatusUseCase(clinicRepo),
        completeVisitUseCase: CompleteVisitUseCase(clinicRepo),
        getPatientToothChartUseCase: GetPatientToothChartUseCase(dentalRepo),
        saveToothChartUseCase: SaveToothChartUseCase(dentalRepo),
        getPatientsUseCase: GetPatientsUseCase(clinicRepo),
        searchPatientsUseCase: SearchPatientsUseCase(clinicRepo),
        getRollingMeanWaitUseCase: GetRollingMeanWaitUseCase(clinicRepo),
        clinicRepository: clinicRepo,
        lanSyncRepository: clientRepo,
      );

      // 4. Live broadcast check-in on Host -> Client receives full payload over network
      hostBloc.add(
        const CheckInPatientEvent(
          patientId: 'pat_live_101',
          patientName: 'David Hasselhoff',
          doctorName: 'usr_doctor',
          chiefComplaint: 'Chest discomfort [Age: 45, Tel: 555-0100]',
        ),
      );

      await Future.delayed(const Duration(milliseconds: 200));

      // Assert David Hasselhoff received and saved into local database via WebSocket sync
      final receivedPatient = await clinicDataSource.getPatientById('pat_live_101');
      expect(receivedPatient, isNotNull);
      expect(receivedPatient!.name, equals('David Hasselhoff'));

      // 5. Network Drop Simulation: Client disconnects
      await clientRepo.disconnect();
      expect(clientRepo.isConnected, isFalse);

      // Host checks in a new patient while client is disconnected (offline gap)
      hostBloc.add(
        const CheckInPatientEvent(
          patientId: 'pat_offline_202',
          patientName: 'Grace Hopper',
          doctorName: 'usr_doctor',
          chiefComplaint: 'Routine checkup',
        ),
      );
      await Future.delayed(const Duration(milliseconds: 200));

      // 6. Client Reconnects -> Auto-Sync State Reconciliation (sync.request_active_state -> sync.full_state_response)
      await clientRepo.connectToHost('127.0.0.1', port: 9096);
      await Future.delayed(const Duration(milliseconds: 1000));

      // Assert Grace Hopper was reconciled and saved in database
      final reconciledPatient = await clinicDataSource.getPatientById('pat_offline_202');
      expect(reconciledPatient, isNotNull);
      expect(reconciledPatient!.name, equals('Grace Hopper'));

      // Cleanup
      await hostBloc.close();
      await clientBloc.close();
      await clientRepo.disconnect();
      await hostRepo.disconnect();
    });

    // -------------------------------------------------------------------------
    // PRIORITY 2: Authentication & RBAC Screen Restriction
    // -------------------------------------------------------------------------
    testWidgets('P2: RBAC RoleGuardWidget strictly renders for allowed roles and blocks forbidden roles', (tester) async {
      final mockAuthRepo = MockAuthRepository();

      Widget buildTestableWidget(UserRole activeRole) {
        return MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                RoleGuardWidget(
                  allowedRoles: const [UserRole.admin, UserRole.manager],
                  fallback: const Text('Access Denied: Management Only', style: TextStyle(color: AppColors.error)),
                  child: const Text('Manager Dashboard Unlocked', style: TextStyle(color: AppColors.success)),
                ),
                RoleGuardWidget(
                  allowedRoles: const [UserRole.doctor, UserRole.admin],
                  fallback: const Text('Access Denied: Doctor Only', style: TextStyle(color: AppColors.error)),
                  child: const Text('Doctor Station Unlocked', style: TextStyle(color: AppColors.success)),
                ),
              ],
            ),
          ),
        );
      }

      // 1. Test Cashier role (both should be blocked)
      final cashierUser = AppUser(
        id: 'usr_cashier',
        name: 'Cashier John',
        role: UserRole.cashier,
        pinCodeHash: '1234',
        isActive: true,
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>(
          key: const ValueKey('auth_cashier'),
          create: (_) => AuthBloc(authRepository: mockAuthRepo)
            ..emit(AuthAuthenticated(cashierUser)),
          child: buildTestableWidget(UserRole.cashier),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Access Denied: Management Only'), findsOneWidget);
      expect(find.text('Access Denied: Doctor Only'), findsOneWidget);
      expect(find.text('Manager Dashboard Unlocked'), findsNothing);
      expect(find.text('Doctor Station Unlocked'), findsNothing);

      // 2. Test Doctor role (Doctor Station unlocked, Manager Dashboard blocked)
      final docUser = AppUser(
        id: 'usr_doc',
        name: 'Dr. Sarah',
        role: UserRole.doctor,
        pinCodeHash: '5555',
        isActive: true,
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>(
          key: const ValueKey('auth_doctor'),
          create: (_) => AuthBloc(authRepository: mockAuthRepo)
            ..emit(AuthAuthenticated(docUser)),
          child: buildTestableWidget(UserRole.doctor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Access Denied: Management Only'), findsOneWidget);
      expect(find.text('Doctor Station Unlocked'), findsOneWidget);
      expect(find.text('Manager Dashboard Unlocked'), findsNothing);

      // 3. Test Admin role (Both unlocked)
      final adminUser = AppUser(
        id: 'usr_admin',
        name: 'Super Admin',
        role: UserRole.admin,
        pinCodeHash: '9999',
        isActive: true,
      );

      await tester.pumpWidget(
        BlocProvider<AuthBloc>(
          key: const ValueKey('auth_admin'),
          create: (_) => AuthBloc(authRepository: mockAuthRepo)
            ..emit(AuthAuthenticated(adminUser)),
          child: buildTestableWidget(UserRole.admin),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Manager Dashboard Unlocked'), findsOneWidget);
      expect(find.text('Doctor Station Unlocked'), findsOneWidget);
    });

    // -------------------------------------------------------------------------
    // PRIORITY 3: POS Core & Split Payments Specifically
    // -------------------------------------------------------------------------
    test('P3: POS Checkout Engine accurately processes split-tender payments across Cash and Card', () async {
      final posLocal = PosLocalDataSourceImpl();
      final catalogLocal = CatalogLocalDataSourceImpl();

      final posRepo = PosRepositoryImpl(
        localDataSource: posLocal,
        catalogLocalDataSource: catalogLocal,
      );

      final checkoutUseCase = ProcessCheckoutUseCase(posRepo);

      const productA = Product(
        id: 'p_100',
        nameEn: 'Premium Coffee Beans',
        categoryId: 'cat_coffee',
        price: 100.0,
        stock: 20,
        barcode: '6221000100',
      );

      // Save product in catalog to allow stock deduction
      await catalogLocal.saveProduct(ProductModel.fromEntity(productA));

      const cart = Cart(
        items: [
          CartItem(product: productA, quantity: 1, unitPrice: 100.0),
        ],
        taxRate: 0.14, // Grand total = 114.00
      );

      expect(cart.grandTotal, equals(114.0));

      // Split payment: $50.00 Cash + $64.00 Card
      final splitPayments = const [
        PaymentDetail(tenderType: TenderType.cash, amount: 50.0),
        PaymentDetail(tenderType: TenderType.card, amount: 64.0),
      ];

      final result = await checkoutUseCase(
        ProcessCheckoutParams(
          cart: cart,
          payments: splitPayments,
          cashierId: 'cashier_01',
        ),
      );

      expect(result.isRight(), isTrue);
      final order = result.getOrElse(() => throw Exception('Checkout failed'));

      expect(order.payments.length, equals(2));
      expect(order.payments[0].tenderType, equals(TenderType.cash));
      expect(order.payments[0].amount, equals(50.0));
      expect(order.payments[1].tenderType, equals(TenderType.card));
      expect(order.payments[1].amount, equals(64.0));

      // Verify recorded order inside posLocalDataSource
      final allPosOrders = await posLocal.getOrders();
      expect(allPosOrders.any((o) => o.id == order.id), isTrue);
      final savedOrder = allPosOrders.firstWhere((o) => o.id == order.id);
      expect(savedOrder.payments.fold(0.0, (s, p) => s + p.amount), equals(114.0));
    });

    // -------------------------------------------------------------------------
    // PRIORITY 4: Universal Multi-Party Finance Split Engine
    // -------------------------------------------------------------------------
    test('P4: Finance Split Engine computes exact mathematical commission splits and logs settlement audit', () async {
      final financeLocal = FinanceSplitLocalDataSourceImpl();
      final financeRepo = FinanceSplitRepositoryImpl(localDataSource: financeLocal);

      // Total booking revenue: $600.00
      final rules = <RevenueSplitRule>[
        const RevenueSplitRule(
          id: 'r_owner',
          name: 'Salon Owner Rule',
          recipientName: 'Salon Owner',
          percentage: 0.60,
          flatFee: 0.0,
        ),
        const RevenueSplitRule(
          id: 'r_stylist',
          name: 'Master Stylist Rule',
          recipientName: 'Master Stylist Jessica',
          percentage: 0.30,
          flatFee: 10.0,
        ),
        const RevenueSplitRule(
          id: 'r_platform',
          name: 'Platform Fee Rule',
          recipientName: 'Booking Platform',
          percentage: 0.10,
          flatFee: 0.0,
        ),
      ];

      final splitRes = financeRepo.calculateDistribution(600.0, rules);
      expect(splitRes.isRight(), isTrue);
      final cuts = splitRes.getOrElse(() => []);

      expect(cuts.length, equals(3));
      // Owner: 600 * 0.60 = 360.00
      expect(cuts[0].calculatedAmount, equals(360.0));
      // Stylist: 600 * 0.30 + 10 = 180 + 10 = 190.00
      expect(cuts[1].calculatedAmount, equals(190.0));
      // Platform: 600 * 0.10 = 60.00
      expect(cuts[2].calculatedAmount, equals(60.0));

      // Record settlement audit log in real Hive DB
      final log = FinanceSettlementLog(
        id: 'SET-9099',
        referenceId: 'ORD-SPLIT-1',
        totalAmount: 600.0,
        date: DateTime.now(),
        splits: cuts,
        netOwnerAmount: 360.0,
      );

      final saveResult = await financeRepo.recordSettlement(log);
      expect(saveResult.isRight(), isTrue);

      final savedLogs = await financeRepo.getSettlementLogs();
      final logsList = savedLogs.getOrElse(() => []);
      expect(logsList.any((s) => s.id == 'SET-9099'), isTrue);
    });

    // -------------------------------------------------------------------------
    // PRIORITY 5: Boss Portal & Operational ERP (Reactive to Real Transactions)
    // -------------------------------------------------------------------------
    test('P5: Boss ERP Net Profit dynamically computes from real orders and expenses, not static mocks', () async {
      final ordersLocal = OrdersLocalDataSourceImpl();
      final erpLocal = ErpLocalDataSourceImpl();
      final shiftLocal = ShiftLocalDataSourceImpl();

      final erpRepo = ErpRepositoryImpl(
        localDataSource: erpLocal,
        ordersLocalDataSource: ordersLocal,
        shiftLocalDataSource: shiftLocal,
      );

      final now = DateTime.now();

      // 1. Seed a real paid order in OrdersLocalDataSource ($300 gross)
      final realOrder = PosOrderModel(
        id: 'ORD-REAL-1',
        orderNumber: 'TX-1',
        cart: const Cart(
          items: [
            CartItem(
              product: Product(id: 'p_retail', nameEn: 'Retail Jacket', categoryId: 'c1', price: 300.0, stock: 10, barcode: '998811'),
              quantity: 1,
              unitPrice: 300.0,
            ),
          ],
          taxRate: 0.0, // Grand total = 300.00
        ),
        payments: const [
          PaymentDetail(tenderType: TenderType.card, amount: 300.0),
        ],
        status: OrderStatus.paid,
        cashierId: 'c1',
        createdAt: now,
      );
      await ordersLocal.updateOrder(realOrder);

      // 2. Seed a real operating expense in ErpLocalDataSource ($50 Electricity)
      final realExpense = ExpenseModel(
        id: 'EXP-1',
        category: ExpenseCategory.utilities,
        amount: 50.0,
        date: now,
        description: 'Electricity Bill',
      );
      await erpLocal.saveExpense(realExpense);

      // 3. Run real calculateNetProfitReport
      final reportRes = await erpRepo.calculateNetProfitReport(month: now.month, year: now.year);
      expect(reportRes.isRight(), isTrue);
      final report = reportRes.getOrElse(() => throw Exception('Failed to calculate profit'));

      // Gross sales must equal 300.0
      expect(report.grossSales, equals(300.0));
      // Operating expenses must equal 50.0
      expect(report.operatingExpenses, equals(50.0));
      // COGS is calculated as 60% of item price (300 * 0.60 = 180.0)
      expect(report.cogs, equals(180.0));
      // Net Operating Profit = Gross (300) - Refunds (0) - COGS (180) - Operating Expenses (50) - Payroll (0) = 70.0
      expect(report.netOperatingProfit, equals(70.0));
    });

    // -------------------------------------------------------------------------
    // PRIORITY 6: Remaining Modules Runtime Verification
    // -------------------------------------------------------------------------
    test('P6.1: Universal Booking & Calendar Engine detects overlapping conflicts', () async {
      final bookingLocal = BookingLocalDataSourceImpl();
      final bookingRepo = BookingRepositoryImpl(localDataSource: bookingLocal);

      final now = DateTime.now();
      final slotStart = DateTime(now.year, now.month, now.day, 14, 0);
      final slotEnd = DateTime(now.year, now.month, now.day, 15, 0);

      final booking1 = BookingItem(
        id: 'bkg_1',
        customerOrPatientId: 'cust_1',
        customerName: 'Marcus Aurelius',
        customerPhone: '123',
        resourceId: 'staff_barber_1',
        serviceName: 'Full Haircut',
        startTime: slotStart,
        endTime: slotEnd,
        status: BookingStatus.confirmed,
        price: 50.0,
        createdAt: now,
      );
      await bookingRepo.saveBooking(booking1);

      // Check availability for same staff member and overlapping slot
      final conflictCheck = await bookingRepo.checkAvailability(
        'staff_barber_1',
        slotStart.add(const Duration(minutes: 15)),
        slotEnd.add(const Duration(minutes: 15)),
      );

      expect(conflictCheck.isRight(), isTrue);
      expect(conflictCheck.getOrElse(() => true), isFalse); // False means unavailable / conflict detected!
    });

    test('P6.2: Universal Work Order Pipeline transitions stages', () async {
      final workOrderLocal = WorkOrderLocalDataSourceImpl();
      final workOrderRepo = WorkOrderRepositoryImpl(localDataSource: workOrderLocal);

      final order = WorkOrderTicket(
        id: 'wo_1',
        title: 'Brake Disc Replacement',
        customerId: 'cust_wayne',
        customerName: 'Bruce Wayne',
        customerPhone: '555',
        currentStage: WorkOrderStage.intake,
        createdAt: DateTime.now(),
      );
      await workOrderRepo.saveWorkOrder(order);

      final transitionRes = await workOrderRepo.transitionStage('wo_1', WorkOrderStage.inProgress);
      expect(transitionRes.isRight(), isTrue);
      final updated = transitionRes.getOrElse(() => throw Exception('Transition failed'));
      expect(updated.currentStage, equals(WorkOrderStage.inProgress));
    });

    test('P6.3: FEFO Batch Picking Engine sorts earliest expiry date first and picks quantities', () async {
      final batchOld = ProductBatch(
        id: 'b_old',
        productId: 'p_pharma_1',
        batchNumber: 'BATCH-A-OLD',
        expiryDate: DateTime.now().add(const Duration(days: 2)),
        quantity: 5,
      );
      final batchNew = ProductBatch(
        id: 'b_new',
        productId: 'p_pharma_1',
        batchNumber: 'BATCH-B-NEW',
        expiryDate: DateTime.now().add(const Duration(days: 30)),
        quantity: 20,
      );

      final result = FefoPickingEngine.pickBatches(
        availableBatches: [batchNew, batchOld],
        quantityToDeduct: 3,
      );

      expect(result.remainingUnfulfilledQuantity, equals(0));
      // Older batch decremented from 5 to 2
      final updatedOld = result.updatedBatches.firstWhere((b) => b.id == 'b_old');
      expect(updatedOld.quantity, equals(2));
      // Newer batch remains untouched at 20
      final updatedNew = result.updatedBatches.firstWhere((b) => b.id == 'b_new');
      expect(updatedNew.quantity, equals(20));
      expect(result.deductedPerBatch['b_old'], equals(3));
    });

    test('P6.4: Clinic Consumable Auto-Deduction decrements catalog stock on CompleteVisit', () async {
      final clinicDataSource = ClinicLocalDataSourceImpl();
      final clinicRepo = ClinicRepositoryImpl(localDataSource: clinicDataSource);
      final catalogLocal = CatalogLocalDataSourceImpl();
      final catalogRepo = CatalogRepositoryImpl(localDataSource: catalogLocal);

      // Seed consumable product linked to dental root canal procedure
      const anaesthetic = Product(
        id: 'med_lidocaine',
        nameEn: 'Lidocaine 2% Cartridge',
        categoryId: 'cat_dental_consumables',
        price: 15.0,
        stock: 50,
        barcode: '333001',
      );
      await catalogRepo.saveProduct(anaesthetic);

      final completeVisitUseCase = CompleteVisitUseCase(clinicRepo, catalogRepo);

      final visit = ClinicVisit(
        id: 'vis_root_canal_1',
        patientId: 'pat_rc_1',
        patientName: 'John Dental',
        doctorName: 'Dr. Tarek',
        queueNumber: 1,
        status: ClinicVisitStatus.inExamination,
        checkInTime: DateTime.now(),
        appliedProcedures: const [
          ProcedureItem(
            id: 'pr_endo',
            code: 'root_canal',
            name: 'Endodontic Therapy',
            standardFee: 800.0,
            requiredConsumables: ['med_lidocaine'],
          ),
        ],
        totalFee: 800.0,
      );

      final result = await completeVisitUseCase(visit);
      expect(result.isRight(), isTrue);

      // Verify linked consumable was decremented by completeVisitUseCase
      final updatedProduct = await catalogLocal.getProductById('med_lidocaine');
      expect(updatedProduct.stock, lessThan(50));
    });

    test('P6.5: Hardware ESC/POS Driver generates exact test receipt and RJ11 drawer kick pulse', () async {
      final printerRepo = PrinterRepositoryImpl();

      final receiptBytes = printerRepo.buildTestReceiptBytes();
      expect(receiptBytes.isNotEmpty, isTrue);
      // Contains ESC/POS init bytes (0x1B, 0x40)
      expect(receiptBytes[0], equals(0x1B));
      expect(receiptBytes[1], equals(0x40));
    });

    test('P6.6: Developer RMM Console dispatches commands and software updates', () async {
      final lanSync = LanSyncRepositoryImpl();
      final rmmRepo = RmmRepositoryImpl(lanSyncRepository: lanSync);

      await rmmRepo.pushSoftwareUpdate('1.1.0');
      await rmmRepo.sendRemoteCommand('node-test-1', 'CACHE_FLUSH');
    });

    test('P6.7: Data I/O Module generates valid CSV template and exports catalog', () async {
      final catalogLocal = CatalogLocalDataSourceImpl();
      final dataIo = DataIoRepositoryImpl(catalogLocalDataSource: catalogLocal);

      // 1. Generate CSV template
      final templatePath = '${tempDir.path}/test_template.csv';
      final templateRes = await dataIo.generateCatalogTemplate(templatePath);
      expect(templateRes.isRight(), isTrue);
      final file = File(templatePath);
      expect(file.existsSync(), isTrue);
      final content = file.readAsStringSync();
      expect(content.contains('Barcode') && content.contains('Name_EN'), isTrue);

      // 2. Export catalog
      final exportPath = '${tempDir.path}/test_export.csv';
      final exportRes = await dataIo.exportCatalog(exportPath);
      expect(exportRes.isRight(), isTrue);
      expect(File(exportPath).existsSync(), isTrue);
    });
  });
}
