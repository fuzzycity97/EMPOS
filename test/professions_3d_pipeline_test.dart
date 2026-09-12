import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/core/config/domain/entities/store_blueprint.dart';
import 'package:empos/core/localization/app_language.dart';
import 'package:empos/core/theme/app_theme.dart';
import 'package:empos/features/work_orders/domain/entities/work_order_ticket.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_bloc.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_event.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_state.dart';
import 'package:empos/features/work_orders/presentation/pages/work_orders_pipeline_page.dart';
import 'package:empos/features/work_orders/presentation/widgets/tattoo_piercing_3d_studio_widget.dart';
import 'package:empos/features/work_orders/presentation/widgets/retail_fashion_3d_showcase_widget.dart';
import 'package:empos/features/work_orders/presentation/widgets/real_estate_venue_3d_canvas_widget.dart';
import 'package:empos/features/work_orders/presentation/widgets/electronics_device_3d_inspector_widget.dart';

class FakeWorkOrderBloc extends Fake implements WorkOrderBloc {
  final List<WorkOrderEvent> dispatchedEvents = [];
  final WorkOrderState _state;

  FakeWorkOrderBloc(this._state);

  @override
  WorkOrderState get state => _state;

  @override
  Stream<WorkOrderState> get stream => Stream.value(_state);

  @override
  void add(WorkOrderEvent event) {
    dispatchedEvents.add(event);
  }
}

void main() {
  setUp(() {
    AppLanguage.currentLocale.value = const Locale('en');
  });

  final testTicket = WorkOrderTicket(
    id: 'wo-1',
    title: 'Initial Diagnostic',
    customerId: 'cust-1',
    customerName: 'Samir',
    customerPhone: '01000000000',
    currentStage: WorkOrderStage.intake,
    totalEstimate: 500,
    createdAt: DateTime(2026, 9, 10),
  );

  final Map<WorkOrderStage, List<WorkOrderTicket>> testPipeline = {
    WorkOrderStage.intake: [testTicket],
    WorkOrderStage.inspection: [],
    WorkOrderStage.inProgress: [],
    WorkOrderStage.qualityCheck: [],
    WorkOrderStage.ready: [],
    WorkOrderStage.delivered: [],
    WorkOrderStage.cancelled: [],
  };

  final List<WorkOrderTicket> testTickets = [testTicket];

  Widget buildApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SizedBox(
          width: 1280,
          height: 900,
          child: child,
        ),
      ),
    );
  }

  group('Turnkey 3D Workspaces for Non-Clinic Professions Tests', () {
    testWidgets('Tattoo & Piercing Studio renders 3D Body Canvas and artist can add new 3D stencil', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final tattooBlueprint = StoreBlueprint(
        storeName: 'Ink & Needle Art Studio',
        specificIndustry: SpecificIndustry.tattooPiercingStudio,
        vertical: IndustryVertical.beautyPersonalCare,
        toggles: const {'sw.tattoo_3d_body_canvas': true},
      );

      final fakeBloc = FakeWorkOrderBloc(
        WorkOrderLoaded(
          pipeline: testPipeline,
          tickets: testTickets,
        ),
      );

      await tester.pumpWidget(
        buildApp(
          WorkOrdersPipelinePage(
            bloc: fakeBloc,
            blueprint: tattooBlueprint,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify header reflects Tattoo & Piercing
      expect(find.text('Tattoo & Piercing Studio Pipeline (1 Active)'), findsOneWidget);
      expect(find.text('3D Body Canvas'), findsOneWidget);

      // Switch to 3D Body Canvas Tab
      await tester.tap(find.text('3D Body Canvas'));
      await tester.pumpAndSettle();

      // 3D Tattoo Studio widget is mounted
      expect(find.byType(TattooPiercing3DStudioWidget), findsOneWidget);
      expect(find.text('3D Tattoo & Body Canvas Studio'), findsOneWidget);
      expect(find.text('+ Add Stencil to 3D'), findsOneWidget);
      expect(find.text('Japanese Koi & Peony Half-Sleeve'), findsWidgets);

      // Tap "+ Add Stencil to 3D"
      await tester.tap(find.text('+ Add Stencil to 3D'));
      await tester.pumpAndSettle();

      // Verify Modal Dialog
      expect(find.text('Add New Tattoo / Piercing to 3D Canvas'), findsOneWidget);
      expect(find.text('Tattoo Stencil'), findsOneWidget);
      expect(find.text('Body Piercing'), findsOneWidget);
      expect(find.text('Neo-Traditional'), findsWidgets);

      // Add design
      await tester.tap(find.text('Add Design'));
      await tester.pumpAndSettle();

      // Verify toast confirmation
      expect(find.text('New 3D design added to showroom!'), findsOneWidget);

      // Verify edit capability
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();
      expect(find.text('Edit 3D Design Specs'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('3D design updated!'), findsOneWidget);
    });

    testWidgets('Fashion Boutique renders 3D Mannequin and merchant can add new 3D garment', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final fashionBlueprint = StoreBlueprint(
        storeName: 'Milano Bespoke Tailors',
        specificIndustry: SpecificIndustry.clothingBoutique,
        vertical: IndustryVertical.retail,
        toggles: const {'sw.fashion_3d_fitting_showcase': true},
      );

      final fakeBloc = FakeWorkOrderBloc(
        WorkOrderLoaded(
          pipeline: testPipeline,
          tickets: testTickets,
        ),
      );

      await tester.pumpWidget(
        buildApp(
          WorkOrdersPipelinePage(
            bloc: fakeBloc,
            blueprint: fashionBlueprint,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header reflects Fashion Boutique
      expect(find.text('Fashion Boutique & Tailoring Pipeline (1 Active)'), findsOneWidget);
      expect(find.text('3D Mannequin & Fit'), findsOneWidget);

      // Switch to 3D Mannequin Tab
      await tester.tap(find.text('3D Mannequin & Fit'));
      await tester.pumpAndSettle();

      // 3D Fashion Showcase is mounted
      expect(find.byType(RetailFashion3DShowcaseWidget), findsOneWidget);
      expect(find.text('3D Apparel & Mannequin Fitting Studio'), findsOneWidget);
      expect(find.text('+ Add Garment to 3D'), findsOneWidget);
      expect(find.text('+ Alteration Pin'), findsOneWidget);

      // Tap "+ Add Garment to 3D"
      await tester.tap(find.text('+ Add Garment to 3D'));
      await tester.pumpAndSettle();

      // Verify Modal Dialog
      expect(find.text('Add New Garment to 3D Showroom'), findsOneWidget);
      expect(find.text('Suits & Blazers'), findsWidgets);

      // Add garment
      await tester.tap(find.text('Add Garment'));
      await tester.pumpAndSettle();

      // Verify confirmation
      expect(find.text('New garment added to 3D showroom!'), findsOneWidget);

      // Verify edit capability
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();
      expect(find.text('Edit 3D Garment Specs'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('3D garment updated!'), findsOneWidget);
    });

    testWidgets('Real Estate & Event Venue renders 3D Architectural Floor and broker can add new 3D unit', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final realEstateBlueprint = StoreBlueprint(
        storeName: 'Al-Safwa Real Estate Development',
        specificIndustry: SpecificIndustry.realEstateAgency,
        vertical: IndustryVertical.professionalServices,
        toggles: const {'sw.realty_3d_architectural_canvas': true},
      );

      final fakeBloc = FakeWorkOrderBloc(
        WorkOrderLoaded(
          pipeline: testPipeline,
          tickets: testTickets,
        ),
      );

      await tester.pumpWidget(
        buildApp(
          WorkOrdersPipelinePage(
            bloc: fakeBloc,
            blueprint: realEstateBlueprint,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header reflects Real Estate
      expect(find.text('Real Estate & Venue Pipeline (1 Active)'), findsOneWidget);
      expect(find.text('3D Architectural Floor'), findsOneWidget);

      // Switch to 3D Architectural Floor Tab
      await tester.tap(find.text('3D Architectural Floor'));
      await tester.pumpAndSettle();

      // 3D Real Estate Canvas is mounted
      expect(find.byType(RealEstateVenue3DCanvasWidget), findsOneWidget);
      expect(find.text('3D Architectural & Venue Floor Showcase'), findsOneWidget);
      expect(find.text('+ Add 3D Unit / Zone'), findsOneWidget);

      // Tap "+ Add 3D Unit / Zone"
      await tester.tap(find.text('+ Add 3D Unit / Zone'));
      await tester.pumpAndSettle();

      // Verify Modal Dialog
      expect(find.text('Add New 3D Unit to Floor'), findsOneWidget);
      expect(find.text('Residential Suite / Apartment'), findsWidgets);

      // Add unit
      await tester.tap(find.text('Add Unit'));
      await tester.pumpAndSettle();

      // Verify unit was added
      expect(find.text('Deluxe Suite'), findsWidgets);
    });

    testWidgets('Electronics & Phone Repair Shop renders 3D Device Bench and owner can add new 3D device and edit specs', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final electronicsBlueprint = StoreBlueprint(
        storeName: 'TechFix Micro-Soldering & Device Lab',
        specificIndustry: SpecificIndustry.electronicsPhoneShop,
        vertical: IndustryVertical.retail,
        toggles: const {'sw.device_3d_diagnostic_inspector': true},
      );

      final fakeBloc = FakeWorkOrderBloc(
        WorkOrderLoaded(
          pipeline: testPipeline,
          tickets: testTickets,
        ),
      );

      await tester.pumpWidget(
        buildApp(
          WorkOrdersPipelinePage(
            bloc: fakeBloc,
            blueprint: electronicsBlueprint,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header reflects Electronics & Device Repair
      expect(find.text('Electronics & Device Repair Pipeline (1 Active)'), findsOneWidget);
      expect(find.text('3D Device Diagnostic'), findsOneWidget);

      // Switch to 3D Device Diagnostic Tab
      await tester.tap(find.text('3D Device Diagnostic'));
      await tester.pumpAndSettle();

      // 3D Device Bench mounted
      expect(find.byType(ElectronicsDevice3DInspectorWidget), findsOneWidget);
      expect(find.text('3D Device Diagnostic & Repair Bench'), findsOneWidget);
      expect(find.text('+ Add Device to 3D Bench'), findsOneWidget);
      expect(find.text('+ 3D Diagnostic Pin'), findsOneWidget);

      // Tap "+ Add Device to 3D Bench"
      await tester.tap(find.text('+ Add Device to 3D Bench'));
      await tester.pumpAndSettle();

      // Verify Modal Dialog
      expect(find.text('Add Device to 3D Bench'), findsOneWidget);
      expect(find.text('Samsung'), findsWidgets);
      expect(find.text('Galaxy S24 Ultra'), findsWidgets);

      // Add device
      await tester.tap(find.text('Add Device'));
      await tester.pumpAndSettle();

      // Verify device was added to the bench list
      expect(find.text('New device added to 3D workbench!'), findsOneWidget);
      expect(find.text('Samsung Galaxy S24 Ultra'), findsWidgets);

      // Tap Edit button on device details
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Device Specs'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('3D device updated!'), findsOneWidget);
    });

    testWidgets('Tattoo & Fashion 3D studios support full Arabic localization without leakage', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      AppLanguage.currentLocale.value = const Locale('ar');

      final tattooBlueprint = StoreBlueprint(
        storeName: 'استوديو فنون الوشم',
        specificIndustry: SpecificIndustry.tattooPiercingStudio,
        vertical: IndustryVertical.beautyPersonalCare,
      );

      final fakeBloc = FakeWorkOrderBloc(
        WorkOrderLoaded(
          pipeline: testPipeline,
          tickets: testTickets,
        ),
      );

      await tester.pumpWidget(
        buildApp(
          WorkOrdersPipelinePage(
            bloc: fakeBloc,
            blueprint: tattooBlueprint,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Arabic header and tabs
      expect(find.text('استوديو الوشم والبيرسينج وخط العمليات (1 نشط)'), findsOneWidget);
      expect(find.text('رسم الجسم 3D'), findsOneWidget);
      expect(find.text('لوحة العمليات'), findsOneWidget);

      // Switch to 3D Tab
      await tester.tap(find.text('رسم الجسم 3D'));
      await tester.pumpAndSettle();

      expect(find.text('استوديو وشم وبيرسينج ثلاثي الأبعاد'), findsOneWidget);
      expect(find.text('+ إضافة رسم 3D'), findsOneWidget);
      expect(find.text('تثبيت على الجسم'), findsOneWidget);
    });
  });
}
