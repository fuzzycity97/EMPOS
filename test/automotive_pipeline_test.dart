import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:empos/core/config/data/models/store_blueprint_model.dart';
import 'package:empos/core/localization/app_language.dart';
import 'package:empos/features/work_orders/data/datasources/work_order_local_data_source.dart';
import 'package:empos/features/work_orders/data/repositories/work_order_repository_impl.dart';
import 'package:empos/features/work_orders/domain/usecases/get_work_orders_usecase.dart';
import 'package:empos/features/work_orders/domain/usecases/save_work_order_usecase.dart';
import 'package:empos/features/work_orders/domain/usecases/transition_stage_usecase.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_bloc.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_event.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_state.dart';
import 'package:empos/features/work_orders/presentation/pages/work_orders_pipeline_page.dart';
import 'package:empos/features/work_orders/presentation/widgets/automotive_vehicle_3d_inspector_widget.dart';

void main() {
  late Directory tempDir;
  late WorkOrderLocalDataSource workOrderDataSource;
  late WorkOrderRepositoryImpl workOrderRepository;
  late WorkOrderBloc workOrderBloc;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    tempDir = await Directory.systemTemp.createTemp('empos_auto_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    AppLanguage.currentLocale.value = const Locale('en');
    workOrderDataSource = WorkOrderLocalDataSourceImpl();
    workOrderRepository = WorkOrderRepositoryImpl(localDataSource: workOrderDataSource);
    workOrderBloc = WorkOrderBloc(
      getWorkOrdersUseCase: GetWorkOrdersUseCase(workOrderRepository),
      saveWorkOrderUseCase: SaveWorkOrderUseCase(workOrderRepository),
      transitionStageUseCase: TransitionStageUseCase(workOrderRepository),
    );
  });

  tearDown(() async {
    await workOrderBloc.close();
    if (Hive.isBoxOpen(WorkOrderLocalDataSourceImpl.workOrdersBoxName)) {
      await Hive.box(WorkOrderLocalDataSourceImpl.workOrdersBoxName).clear();
    }
  });

  Widget buildTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  group('AutomotiveVehicle3DInspectorWidget Tests', () {
    testWidgets('Renders 3D inspector with initial dealership fleet, 3D controls, and inspection points', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          const AutomotiveVehicle3DInspectorWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Check header and controls
      expect(find.text('Automotive 3D Vehicle & Bay Inspection Pipeline'), findsOneWidget);
      expect(find.text('+ Add Car to 3D Showroom'), findsOneWidget);
      expect(find.text('2024 BMW M4 Competition'), findsWidgets);
      expect(find.text('2024 Land Rover Defender 110 V8'), findsOneWidget);

      // Check default inspection points exist
      expect(find.text('Front Left Ceramic Brake Pads'), findsOneWidget);
      expect(find.text('Engine Bay & Synthetic Oil'), findsOneWidget);
    });

    testWidgets('Dealer owner can switch between dealership cars and inspect their 3D models', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          const AutomotiveVehicle3DInspectorWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Land Rover Defender chip
      await tester.tap(find.text('2024 Land Rover Defender 110 V8'));
      await tester.pumpAndSettle();

      // Header now displays Defender and its critical brake pad finding
      expect(find.text('2024 Land Rover Defender 110 V8 • VIN: SALWR2V48PA109281'), findsOneWidget);
      expect(find.text('18500 EGP'), findsWidgets);
    });

    testWidgets('Dealer owner can add a brand new car to the 3D showroom with custom body and paint', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          const AutomotiveVehicle3DInspectorWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Click "+ Add Car to 3D Showroom"
      await tester.tap(find.text('+ Add Car to 3D Showroom'));
      await tester.pumpAndSettle();

      // Verify Add Car modal dialog appeared
      expect(find.text('Add New Car to 3D Showroom'), findsOneWidget);

      // Submit dialog (defaults to Porsche 911 Carrera 4S Coupe)
      await tester.tap(find.text('Add Vehicle to Showroom'));
      await tester.pumpAndSettle();

      // Verify new car was added and set as active in 3D showroom
      expect(find.text('2024 Porsche 911 Carrera 4S'), findsWidgets);
      expect(find.text('2024 Porsche 911 Carrera 4S • VIN: WP0AB2A99NS192837'), findsOneWidget);
    });

    testWidgets('Filters inspection points by layer (Powertrain, Wheels/Brakes, Undercarriage)', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          const AutomotiveVehicle3DInspectorWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Filter to Powertrain & Engine
      await tester.tap(find.text('2. Powertrain & Engine Bay'));
      await tester.pumpAndSettle();
      expect(find.text('Engine Bay & Synthetic Oil'), findsOneWidget);

      // Filter to Wheels & Brakes
      await tester.tap(find.text('3. Wheels & Brakes'));
      await tester.pumpAndSettle();
      expect(find.text('Front Left Ceramic Brake Pads'), findsOneWidget);
    });

    testWidgets('Supports 3D rotation gestures and Reset 3D button', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestWidget(
          const AutomotiveVehicle3DInspectorWidget(),
        ),
      );
      await tester.pumpAndSettle();

      // Perform a drag on the 3D viewport
      final viewport = find.byType(CustomPaint).first;
      await tester.drag(viewport, const Offset(60, 30));
      await tester.pumpAndSettle();

      // Tap Reset 3D
      await tester.ensureVisible(find.text('Reset 3D'));
      await tester.tap(find.text('Reset 3D'));
      await tester.pumpAndSettle();
      expect(find.text('Reset 3D'), findsOneWidget);
    });

    testWidgets('Tapping finding card opens diagnostic edit modal and emits onFindingAddedToTicket', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      VehicleInspectionPoint? emittedPoint;

      await tester.pumpWidget(
        buildTestWidget(
          AutomotiveVehicle3DInspectorWidget(
            onFindingAddedToTicket: (point) {
              emittedPoint = point;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Front Left Ceramic Brake Pads finding badge
      await tester.tap(find.text('Front Left Ceramic Brake Pads'));
      await tester.pumpAndSettle();

      // Verify modal dialog appeared
      expect(find.text('Front Left Ceramic Brake Pads'), findsWidgets);
      expect(find.text('Critical / Immediate Repair'), findsOneWidget);

      // Tap Critical severity
      await tester.tap(find.text('Critical / Immediate Repair'));
      await tester.pumpAndSettle();

      // Save & Add to Job Ticket
      await tester.tap(find.text('Save & Add to Job Ticket'));
      await tester.pumpAndSettle();

      expect(emittedPoint, isNotNull);
      expect(emittedPoint!.severity, equals(InspectionSeverity.critical));
      expect(emittedPoint!.title, equals('Front Left Ceramic Brake Pads'));
    });

    testWidgets('Arabic localization displays translated texts without text leakage', (tester) async {
      AppLanguage.currentLocale.value = const Locale('ar');
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() {
        AppLanguage.currentLocale.value = const Locale('en');
        tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        buildTestWidget(
          const AutomotiveVehicle3DInspectorWidget(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('جناح فحص المركبات ثلاثي الأبعاد ورافعات الصيانة'), findsOneWidget);
      expect(find.text('+ إضافة سيارة للمعرض 3D'), findsOneWidget);
      expect(find.text('إعادة ضبط'), findsOneWidget);
    });
  });

  group('WorkOrdersPipelinePage Automotive Integration Tests', () {
    testWidgets('Shows 3D Vehicle Inspector tab when automotive blueprint is active', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final autoBlueprint = StoreBlueprintModel.defaultAutoRepairBlueprint();

      await tester.runAsync(() async {
        workOrderBloc.add(const LoadWorkOrdersEvent());
        await workOrderBloc.stream.firstWhere((s) => s is WorkOrderLoaded);
      });

      await tester.pumpWidget(
        buildTestWidget(
          WorkOrdersPipelinePage(
            bloc: workOrderBloc,
            blueprint: autoBlueprint,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Header shows automotive workshop title and segmented toggle
      expect(find.text('Automotive Workshop & Pipeline (0 Active)'), findsOneWidget);
      expect(find.text('Kanban Pipeline'), findsOneWidget);
      expect(find.text('3D Vehicle Inspector'), findsOneWidget);

      // Switch to 3D Vehicle Inspector
      await tester.tap(find.text('3D Vehicle Inspector'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // 3D Inspector widget is displayed
      expect(find.byType(AutomotiveVehicle3DInspectorWidget), findsOneWidget);
    });

    testWidgets('Adding finding from 3D Vehicle Inspector dispatches work order ticket into pipeline', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final autoBlueprint = StoreBlueprintModel.defaultAutoRepairBlueprint();

      await tester.runAsync(() async {
        workOrderBloc.add(const LoadWorkOrdersEvent());
        await workOrderBloc.stream.firstWhere((s) => s is WorkOrderLoaded);
      });

      await tester.pumpWidget(
        buildTestWidget(
          WorkOrdersPipelinePage(
            bloc: workOrderBloc,
            blueprint: autoBlueprint,
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Switch to 3D Vehicle Inspector
      await tester.tap(find.text('3D Vehicle Inspector'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Tap on Engine Bay finding card
      await tester.tap(find.text('Engine Bay & Synthetic Oil'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Save & Add to Job Ticket
      await tester.runAsync(() async {
        await tester.tap(find.text('Save & Add to Job Ticket'));
        await workOrderBloc.stream.firstWhere((s) => s is WorkOrderLoaded);
      });
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // SnackBar shows success notification
      expect(
        find.text('Defect "Engine Bay & Synthetic Oil" added to Service Intake pipeline!'),
        findsOneWidget,
      );

      // Switch back to Kanban Pipeline
      await tester.tap(find.text('Kanban Pipeline'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Pipeline now shows 1 active ticket in Intake
      expect(workOrderBloc.state, isA<WorkOrderLoaded>());
      final loaded = workOrderBloc.state as WorkOrderLoaded;
      expect(loaded.tickets.length, equals(1));
      expect(loaded.tickets.first.title, contains('Engine Bay & Synthetic Oil'));
    });
  });
}
