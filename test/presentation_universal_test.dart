import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:empos/core/config/data/models/store_blueprint_model.dart';
import 'package:empos/core/widgets/industry_components/universal_calendar_grid_widget.dart';
import 'package:empos/core/widgets/industry_components/universal_pipeline_kanban_widget.dart';
import 'package:empos/features/bookings/data/datasources/booking_local_data_source.dart';
import 'package:empos/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:empos/features/bookings/domain/entities/booking_item.dart';
import 'package:empos/features/bookings/domain/usecases/cancel_booking_usecase.dart';
import 'package:empos/features/bookings/domain/usecases/get_bookings_usecase.dart';
import 'package:empos/features/bookings/domain/usecases/save_booking_usecase.dart';
import 'package:empos/features/bookings/presentation/bloc/booking_bloc.dart';
import 'package:empos/features/bookings/presentation/bloc/booking_event.dart';
import 'package:empos/features/bookings/presentation/bloc/booking_state.dart';
import 'package:empos/features/clinic/data/datasources/clinic_local_data_source.dart';
import 'package:empos/features/clinic/data/repositories/clinic_repository_impl.dart';
import 'package:empos/features/clinic/data/repositories/dental_repository_impl.dart';
import 'package:empos/features/clinic/domain/entities/clinic_visit.dart';
import 'package:empos/features/clinic/domain/entities/patient_profile.dart';
import 'package:empos/features/clinic/domain/entities/tooth_chart_entry.dart';
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
import 'package:empos/features/clinic/presentation/bloc/clinic_state.dart';
import 'package:empos/features/clinic/presentation/pages/clinic_reception_page.dart';
import 'package:empos/features/clinic/presentation/pages/doctor_station_page.dart';
import 'package:empos/features/finance_splits/data/datasources/finance_split_local_data_source.dart';
import 'package:empos/features/finance_splits/data/repositories/finance_split_repository_impl.dart';
import 'package:empos/features/finance_splits/domain/entities/revenue_split_rule.dart';
import 'package:empos/features/finance_splits/domain/usecases/calculate_distribution_usecase.dart';
import 'package:empos/features/finance_splits/domain/usecases/get_settlement_logs_usecase.dart';
import 'package:empos/features/finance_splits/domain/usecases/record_settlement_usecase.dart';
import 'package:empos/features/finance_splits/presentation/bloc/finance_split_bloc.dart';
import 'package:empos/features/finance_splits/presentation/bloc/finance_split_event.dart';
import 'package:empos/features/finance_splits/presentation/bloc/finance_split_state.dart';
import 'package:empos/features/work_orders/data/datasources/work_order_local_data_source.dart';
import 'package:empos/features/work_orders/data/repositories/work_order_repository_impl.dart';
import 'package:empos/features/work_orders/domain/entities/work_order_ticket.dart';
import 'package:empos/features/work_orders/domain/usecases/get_work_orders_usecase.dart';
import 'package:empos/features/work_orders/domain/usecases/save_work_order_usecase.dart';
import 'package:empos/features/work_orders/domain/usecases/transition_stage_usecase.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_bloc.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_event.dart';
import 'package:empos/features/work_orders/presentation/bloc/work_order_state.dart';

void main() {
  late Directory tempDir;
  late BookingLocalDataSource bookingDataSource;
  late BookingRepositoryImpl bookingRepository;
  late BookingBloc bookingBloc;

  late WorkOrderLocalDataSource workOrderDataSource;
  late WorkOrderRepositoryImpl workOrderRepository;
  late WorkOrderBloc workOrderBloc;

  late FinanceSplitLocalDataSource financeSplitDataSource;
  late FinanceSplitRepositoryImpl financeSplitRepository;
  late FinanceSplitBloc financeSplitBloc;

  late ClinicLocalDataSource clinicDataSource;
  late ClinicRepositoryImpl clinicRepository;
  late DentalRepositoryImpl dentalRepository;
  late ClinicBloc clinicBloc;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('empos_presentation_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    bookingDataSource = BookingLocalDataSourceImpl();
    bookingRepository = BookingRepositoryImpl(localDataSource: bookingDataSource);
    bookingBloc = BookingBloc(
      getBookingsUseCase: GetBookingsUseCase(bookingRepository),
      saveBookingUseCase: SaveBookingUseCase(bookingRepository),
      cancelBookingUseCase: CancelBookingUseCase(bookingRepository),
    );

    workOrderDataSource = WorkOrderLocalDataSourceImpl();
    workOrderRepository = WorkOrderRepositoryImpl(localDataSource: workOrderDataSource);
    workOrderBloc = WorkOrderBloc(
      getWorkOrdersUseCase: GetWorkOrdersUseCase(workOrderRepository),
      saveWorkOrderUseCase: SaveWorkOrderUseCase(workOrderRepository),
      transitionStageUseCase: TransitionStageUseCase(workOrderRepository),
    );

    financeSplitDataSource = FinanceSplitLocalDataSourceImpl();
    financeSplitRepository = FinanceSplitRepositoryImpl(localDataSource: financeSplitDataSource);
    financeSplitBloc = FinanceSplitBloc(
      calculateDistributionUseCase: CalculateDistributionUseCase(financeSplitRepository),
      recordSettlementUseCase: RecordSettlementUseCase(financeSplitRepository),
      getSettlementLogsUseCase: GetSettlementLogsUseCase(financeSplitRepository),
    );

    clinicDataSource = ClinicLocalDataSourceImpl();
    clinicRepository = ClinicRepositoryImpl(localDataSource: clinicDataSource);
    dentalRepository = DentalRepositoryImpl(localDataSource: clinicDataSource);

    clinicBloc = ClinicBloc(
      getClinicQueueUseCase: GetClinicQueueUseCase(clinicRepository),
      checkInPatientUseCase: CheckInPatientUseCase(clinicRepository),
      updateVisitStatusUseCase: UpdateVisitStatusUseCase(clinicRepository),
      completeVisitUseCase: CompleteVisitUseCase(clinicRepository),
      getPatientToothChartUseCase: GetPatientToothChartUseCase(dentalRepository),
      saveToothChartUseCase: SaveToothChartUseCase(dentalRepository),
      getPatientsUseCase: GetPatientsUseCase(clinicRepository),
      searchPatientsUseCase: SearchPatientsUseCase(clinicRepository),
      getRollingMeanWaitUseCase: GetRollingMeanWaitUseCase(clinicRepository),
    );
  });

  tearDown(() async {
    final boxes = [
      BookingLocalDataSourceImpl.bookingsBoxName,
      WorkOrderLocalDataSourceImpl.workOrdersBoxName,
      FinanceSplitLocalDataSourceImpl.financeSplitsBoxName,
      ClinicLocalDataSourceImpl.patientsBoxName,
      ClinicLocalDataSourceImpl.visitsBoxName,
      ClinicLocalDataSourceImpl.toothChartsBoxName,
    ];
    for (final name in boxes) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<dynamic>(name).clear();
      }
    }
  });

  group('Presentation BLoC State Management Tests', () {
    test('BookingBloc creates booking and emits BookingLoaded', () async {
      final booking = BookingItem(
        id: 'b_100',
        customerOrPatientId: 'c_1',
        customerName: 'Hassan',
        resourceId: 'Bay 1',
        startTime: DateTime(2026, 7, 1, 10, 0),
        endTime: DateTime(2026, 7, 1, 11, 0),
        createdAt: DateTime.now(),
      );

      final expectedStates = [
        isA<BookingLoading>(),
        isA<BookingLoaded>().having((s) => s.bookings.length, 'bookings length', 1),
      ];

      expectLater(bookingBloc.stream, emitsInOrder(expectedStates));
      bookingBloc.add(CreateBookingEvent(booking));
    });

    test('WorkOrderBloc advances stage and emits updated WorkOrderLoaded pipeline', () async {
      final ticket = WorkOrderTicket(
        id: 'wo_99',
        title: 'Engine Diagnostic',
        customerId: 'c_9',
        customerName: 'Samir',
        currentStage: WorkOrderStage.intake,
        createdAt: DateTime.now(),
      );

      await workOrderRepository.saveWorkOrder(ticket);

      final expectedStates = [
        isA<WorkOrderLoading>(),
        isA<WorkOrderLoaded>().having(
          (s) => s.pipeline[WorkOrderStage.inspection]?.length,
          'inspection count',
          1,
        ),
      ];

      expectLater(workOrderBloc.stream, emitsInOrder(expectedStates));
      workOrderBloc.add(const AdvanceStageEvent(
        ticketId: 'wo_99',
        newStage: WorkOrderStage.inspection,
        note: 'Completed preliminary intake scan',
      ));
    });

    test('FinanceSplitBloc calculates distribution and derives net owner amount', () async {
      final rules = [
        const RevenueSplitRule(
          id: 'r_comm',
          name: 'Doctor Commission',
          type: SplitRuleType.staffCommission,
          percentage: 0.35, // 35% of 1000 = 350
          recipientName: 'Dr. Mahmoud',
        ),
      ];

      final expectedStates = [
        isA<FinanceSplitLoading>(),
        isA<FinanceSplitCalculated>()
            .having((s) => s.results.first.calculatedAmount, 'calc amount', 350.0)
            .having((s) => s.netOwnerAmount, 'net owner', 650.0),
      ];

      expectLater(financeSplitBloc.stream, emitsInOrder(expectedStates));
      financeSplitBloc.add(CalculateSplitsEvent(totalAmount: 1000.0, rules: rules));
    });

    test('ClinicBloc checks in patient and emits ClinicLoaded queue', () async {
      final expectedStates = [
        isA<ClinicLoading>(),
        isA<ClinicLoaded>().having((s) => s.queue.length, 'queue length', 1),
      ];

      expectLater(clinicBloc.stream, emitsInOrder(expectedStates));
      clinicBloc.add(const CheckInPatientEvent(
        patientId: 'pat_001',
        patientName: 'Kareem Taha',
        doctorName: 'Dr. Tarek Dental Lead',
        chiefComplaint: 'Severe toothache lower molar',
      ));
    });
  });

  group('Universal Interactive UI Widgets Tests', () {
    testWidgets('UniversalPipelineKanbanWidget renders columns and card metadata', (tester) async {
      final ticket = WorkOrderTicket(
        id: 'wo_k1',
        title: 'Transmission Repair',
        customerId: 'cust_1',
        customerName: 'Captain Tarek',
        currentStage: WorkOrderStage.intake,
        customMetadata: const {'VIN': 'ABC123456', 'Odometer': 85000},
        totalEstimate: 3500.0,
        createdAt: DateTime.now(),
      );

      final Map<WorkOrderStage, List<WorkOrderTicket>> pipeline = {
        WorkOrderStage.intake: [ticket],
        WorkOrderStage.inspection: [],
        WorkOrderStage.inProgress: [],
        WorkOrderStage.qualityCheck: [],
        WorkOrderStage.ready: [],
        WorkOrderStage.delivered: [],
        WorkOrderStage.cancelled: [],
      };

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalPipelineKanbanWidget(
              pipeline: pipeline,
              onAdvanceStage: (t, next) {},
            ),
          ),
        ),
      );

      expect(find.text('Intake / Checked In'), findsOneWidget);
      expect(find.text('Transmission Repair'), findsOneWidget);
      expect(find.text('Captain Tarek'), findsOneWidget);
      expect(find.text('VIN: ABC123456'), findsOneWidget);
      expect(find.text('3500 EGP'), findsOneWidget);
      expect(find.text('Advance'), findsOneWidget);
    });

    testWidgets('UniversalCalendarGridWidget renders time slots and booked item tag', (tester) async {
      final booking = BookingItem(
        id: 'b_grid_1',
        customerOrPatientId: 'p_1',
        customerName: 'Nadia Soliman',
        resourceId: 'Stylist Dina',
        serviceName: 'Hair Keratin Treatment',
        startTime: DateTime(2026, 7, 1, 10, 0),
        endTime: DateTime(2026, 7, 1, 11, 0),
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UniversalCalendarGridWidget(
              bookings: [booking],
              selectedDate: DateTime(2026, 7, 1),
              resources: const ['Stylist Dina', 'Stylist Sarah'],
            ),
          ),
        ),
      );

      expect(find.text('Stylist Dina'), findsOneWidget);
      expect(find.text('Stylist Sarah'), findsOneWidget);
      expect(find.text('10:00'), findsOneWidget);
      expect(find.text('Nadia Soliman'), findsOneWidget);
      expect(find.text('Hair Keratin Treatment'), findsOneWidget);
    });

    testWidgets('DoctorStationPage renders patient vitals, dental matrix, and completion button', (tester) async {
      final visit = ClinicVisit(
        id: 'v_doc_01',
        patientId: 'pat_doc_01',
        patientName: 'Mustafa Kamel',
        doctorName: 'Dr. Tarek',
        queueNumber: 1,
        chiefComplaint: 'Tooth extraction consultation',
        status: ClinicVisitStatus.waiting,
        checkInTime: DateTime.now(),
      );

      final patient = PatientProfile(
        id: 'pat_doc_01',
        name: 'Mustafa Kamel',
        phone: '01011223344',
        allergies: const ['Penicillin'],
        createdAt: DateTime.now(),
      );

      final toothChart = ToothChartEntry.permanentToothCodes
          .map((c) => ToothChartEntry(toothNumber: int.parse(c), toothCode: c))
          .toList();

      final loadedState = ClinicLoaded(
        queue: [visit],
        patients: [patient],
        activeToothChart: toothChart,
        activeVisitId: 'v_doc_01',
      );

      final dentalBlueprint = StoreBlueprintModel.defaultDentalBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoctorStationPage(
              bloc: clinicBloc,
              blueprint: dentalBlueprint,
            ),
          ),
        ),
      );

      // Seed state into bloc
      clinicBloc.emit(loadedState);
      await tester.pump();

      expect(find.text('Patient Queue (1)'), findsOneWidget);
      expect(find.text('Mustafa Kamel'), findsAtLeastNWidgets(1));
      expect(find.text('Allergy: Penicillin'), findsOneWidget);
      expect(find.text('Heart Rate'), findsOneWidget);
      expect(find.text('76 BPM'), findsOneWidget);
      expect(find.text('Adult Odontogram (Permanent 32 Teeth)'), findsOneWidget);
      expect(find.text('Complete & Send to Reception'), findsOneWidget);
    });

    testWidgets('ClinicReceptionPage renders KPI banner and check-in action', (tester) async {
      final visit = ClinicVisit(
        id: 'v_rec_01',
        patientId: 'pat_rec_01',
        patientName: 'Rania Youssef',
        doctorName: 'Dr. Tarek',
        queueNumber: 1,
        chiefComplaint: 'Annual dental cleaning',
        status: ClinicVisitStatus.waiting,
        checkInTime: DateTime.now(),
      );

      final loadedState = ClinicLoaded(
        queue: [visit],
        patients: const [],
        rollingMeanWaitMinutes: 12,
      );

      final dentalBlueprint = StoreBlueprintModel.defaultDentalBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClinicReceptionPage(
              bloc: clinicBloc,
              blueprint: dentalBlueprint,
            ),
          ),
        ),
      );

      clinicBloc.emit(loadedState);
      await tester.pump();

      expect(find.text('Estimated Patient Wait'), findsOneWidget);
      expect(find.text('12 mins'), findsOneWidget);
      expect(find.text('Waiting in Lobby'), findsOneWidget);
      expect(find.text('Patient Intake & Check-In'), findsOneWidget);
      expect(find.text('Rania Youssef'), findsOneWidget);
      expect(find.text('Call In'), findsOneWidget);
    });
  });
}
