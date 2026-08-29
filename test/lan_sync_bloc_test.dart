import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/network/lan_sync/data/message_routes.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import 'package:empos/core/network/lan_sync/presentation/bloc/lan_sync_bloc.dart';
import 'package:empos/core/network/lan_sync/presentation/bloc/lan_sync_event.dart';
import 'package:empos/core/network/lan_sync/presentation/bloc/lan_sync_state.dart';
import 'package:empos/features/clinic/domain/entities/clinic_visit.dart';
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
import 'dart:async';

class MockLanSyncRepository extends Mock implements LanSyncRepository {}
class MockGetClinicQueueUseCase extends Mock implements GetClinicQueueUseCase {}
class MockCheckInPatientUseCase extends Mock implements CheckInPatientUseCase {}
class MockUpdateVisitStatusUseCase extends Mock implements UpdateVisitStatusUseCase {}
class MockCompleteVisitUseCase extends Mock implements CompleteVisitUseCase {}
class MockGetPatientToothChartUseCase extends Mock implements GetPatientToothChartUseCase {}
class MockSaveToothChartUseCase extends Mock implements SaveToothChartUseCase {}
class MockGetPatientsUseCase extends Mock implements GetPatientsUseCase {}
class MockSearchPatientsUseCase extends Mock implements SearchPatientsUseCase {}
class MockGetRollingMeanWaitUseCase extends Mock implements GetRollingMeanWaitUseCase {}

void main() {
  late MockLanSyncRepository mockLanSyncRepo;
  late StreamController<SyncEnvelope> incomingEventsController;
  late StreamController<List<dynamic>> nodesController;

  setUpAll(() {
    registerFallbackValue(
      SyncEnvelope.create(
        type: 'test',
        senderId: 'test',
        senderRole: 'test',
      ),
    );
    registerFallbackValue(
      ClinicVisit(
        id: 'vis_test',
        patientId: 'pat_test',
        patientName: 'Test Patient',
        doctorName: 'Dr. Test',
        queueNumber: 1,
        status: ClinicVisitStatus.waiting,
        checkInTime: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockLanSyncRepo = MockLanSyncRepository();
    incomingEventsController = StreamController<SyncEnvelope>.broadcast();
    nodesController = StreamController<List<dynamic>>.broadcast();

    when(() => mockLanSyncRepo.incomingEvents).thenAnswer((_) => incomingEventsController.stream);
    when(() => mockLanSyncRepo.connectedNodesStream).thenAnswer((_) => Stream.value([]));
    when(() => mockLanSyncRepo.connectedNodes).thenReturn([]);
    when(() => mockLanSyncRepo.isConnected).thenReturn(false);
    when(() => mockLanSyncRepo.isHost).thenReturn(false);
  });

  tearDown(() {
    incomingEventsController.close();
    nodesController.close();
  });

  group('LanSyncBloc State Management Tests', () {
    test('Initial state is LanSyncInitial', () {
      final bloc = LanSyncBloc(lanSyncRepository: mockLanSyncRepo);
      expect(bloc.state, isA<LanSyncInitial>());
      bloc.close();
    });

    test('StartHostServerEvent starts host server and emits LanSyncConnected', () async {
      when(() => mockLanSyncRepo.startHostServer(port: any(named: 'port'))).thenAnswer((_) async {});
      when(() => mockLanSyncRepo.connectedNodes).thenReturn([]);

      final bloc = LanSyncBloc(lanSyncRepository: mockLanSyncRepo);
      final states = <LanSyncState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const StartHostServerEvent(port: 9090));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.any((s) => s is LanSyncConnected && s.isHost == true), isTrue);

      await sub.cancel();
      await bloc.close();
    });

    test('ConnectToHostEvent connects to host and emits LanSyncConnected as client', () async {
      when(() => mockLanSyncRepo.connectToHost(any(), port: any(named: 'port'))).thenAnswer((_) async {});
      when(() => mockLanSyncRepo.connectedNodes).thenReturn([]);

      final bloc = LanSyncBloc(lanSyncRepository: mockLanSyncRepo);
      final states = <LanSyncState>[];
      final sub = bloc.stream.listen(states.add);

      bloc.add(const ConnectToHostEvent(hostIp: '192.168.1.50', port: 9090));
      await Future.delayed(const Duration(milliseconds: 50));

      expect(states.any((s) => s is LanSyncConnected && s.isHost == false && s.address == '192.168.1.50'), isTrue);

      await sub.cancel();
      await bloc.close();
    });
  });

  group('ClinicBloc Real-Time LAN Sync Integration Tests', () {
    late MockGetClinicQueueUseCase mockGetQueue;
    late MockCheckInPatientUseCase mockCheckIn;
    late MockUpdateVisitStatusUseCase mockUpdateVisit;
    late MockCompleteVisitUseCase mockCompleteVisit;
    late MockGetPatientToothChartUseCase mockGetToothChart;
    late MockSaveToothChartUseCase mockSaveToothChart;
    late MockGetPatientsUseCase mockGetPatients;
    late MockSearchPatientsUseCase mockSearchPatients;
    late MockGetRollingMeanWaitUseCase mockGetWait;

    setUp(() {
      mockGetQueue = MockGetClinicQueueUseCase();
      mockCheckIn = MockCheckInPatientUseCase();
      mockUpdateVisit = MockUpdateVisitStatusUseCase();
      mockCompleteVisit = MockCompleteVisitUseCase();
      mockGetToothChart = MockGetPatientToothChartUseCase();
      mockSaveToothChart = MockSaveToothChartUseCase();
      mockGetPatients = MockGetPatientsUseCase();
      mockSearchPatients = MockSearchPatientsUseCase();
      mockGetWait = MockGetRollingMeanWaitUseCase();

      when(() => mockGetQueue()).thenAnswer((_) async => const Right([]));
      when(() => mockGetPatients()).thenAnswer((_) async => const Right([]));
      when(() => mockGetWait(any())).thenAnswer((_) async => const Right(15));
      when(() => mockLanSyncRepo.broadcast(any())).thenAnswer((_) async {});
    });

    test('CompleteVisitEvent broadcasts visit.completed via LAN Sync', () async {
      final sampleVisit = ClinicVisit(
        id: 'vis_100',
        patientId: 'pat_1',
        patientName: 'John Doe',
        doctorName: 'Dr. House',
        queueNumber: 1,
        status: ClinicVisitStatus.completed,
        checkInTime: DateTime.now(),
        totalFee: 650.0,
      );

      when(() => mockCompleteVisit(any())).thenAnswer((_) async => Right(sampleVisit));

      final clinicBloc = ClinicBloc(
        getClinicQueueUseCase: mockGetQueue,
        checkInPatientUseCase: mockCheckIn,
        updateVisitStatusUseCase: mockUpdateVisit,
        completeVisitUseCase: mockCompleteVisit,
        getPatientToothChartUseCase: mockGetToothChart,
        saveToothChartUseCase: mockSaveToothChart,
        getPatientsUseCase: mockGetPatients,
        searchPatientsUseCase: mockSearchPatients,
        getRollingMeanWaitUseCase: mockGetWait,
        lanSyncRepository: mockLanSyncRepo,
      );

      clinicBloc.add(CompleteVisitEvent(sampleVisit));
      await Future.delayed(const Duration(milliseconds: 100));

      verify(() => mockLanSyncRepo.broadcast(any(
        that: isA<SyncEnvelope>().having((e) => e.type, 'type', MessageRoutes.visitCompleted),
      ))).called(1);

      await clinicBloc.close();
    });

    test('Incoming visit.completed envelope triggers automatic queue reload in ClinicBloc', () async {
      final clinicBloc = ClinicBloc(
        getClinicQueueUseCase: mockGetQueue,
        checkInPatientUseCase: mockCheckIn,
        updateVisitStatusUseCase: mockUpdateVisit,
        completeVisitUseCase: mockCompleteVisit,
        getPatientToothChartUseCase: mockGetToothChart,
        saveToothChartUseCase: mockSaveToothChart,
        getPatientsUseCase: mockGetPatients,
        searchPatientsUseCase: mockSearchPatients,
        getRollingMeanWaitUseCase: mockGetWait,
        lanSyncRepository: mockLanSyncRepo,
      );

      // Emit incoming LAN Sync event from doctor station
      incomingEventsController.add(
        SyncEnvelope.create(
          type: MessageRoutes.visitCompleted,
          senderId: 'doctor_station_1',
          senderRole: 'doctor',
          payload: {'visitId': 'vis_100'},
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert queue was fetched
      verify(() => mockGetQueue()).called(greaterThanOrEqualTo(1));

      await clinicBloc.close();
    });
  });
}
