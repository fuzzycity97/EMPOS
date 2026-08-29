import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/network/lan_sync/data/message_routes.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import 'package:empos/features/clinic/data/models/clinic_visit_model.dart';
import 'package:empos/features/clinic/data/models/patient_profile_model.dart';
import 'package:empos/features/clinic/domain/entities/clinic_visit.dart';
import 'package:empos/features/clinic/domain/entities/patient_profile.dart';
import 'package:empos/features/clinic/domain/entities/procedure_item.dart';
import 'package:empos/features/clinic/domain/repositories/clinic_repository.dart';
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

class MockLanSyncRepository extends Mock implements LanSyncRepository {}
class MockClinicRepository extends Mock implements ClinicRepository {}
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
  late MockClinicRepository mockClinicRepo;
  late MockGetClinicQueueUseCase mockGetQueue;
  late MockCheckInPatientUseCase mockCheckIn;
  late MockUpdateVisitStatusUseCase mockUpdateVisit;
  late MockCompleteVisitUseCase mockCompleteVisit;
  late MockGetPatientToothChartUseCase mockGetToothChart;
  late MockSaveToothChartUseCase mockSaveToothChart;
  late MockGetPatientsUseCase mockGetPatients;
  late MockSearchPatientsUseCase mockSearchPatients;
  late MockGetRollingMeanWaitUseCase mockGetWait;
  late StreamController<SyncEnvelope> incomingEventsController;

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
        doctorName: 'usr_doctor',
        queueNumber: 1,
        status: ClinicVisitStatus.waiting,
        checkInTime: DateTime.now(),
      ),
    );
    registerFallbackValue(
      PatientProfile(
        id: 'pat_test',
        name: 'Test Patient',
        phone: '123456',
        createdAt: DateTime.now(),
      ),
    );
  });

  setUp(() {
    mockLanSyncRepo = MockLanSyncRepository();
    mockClinicRepo = MockClinicRepository();
    mockGetQueue = MockGetClinicQueueUseCase();
    mockCheckIn = MockCheckInPatientUseCase();
    mockUpdateVisit = MockUpdateVisitStatusUseCase();
    mockCompleteVisit = MockCompleteVisitUseCase();
    mockGetToothChart = MockGetPatientToothChartUseCase();
    mockSaveToothChart = MockSaveToothChartUseCase();
    mockGetPatients = MockGetPatientsUseCase();
    mockSearchPatients = MockSearchPatientsUseCase();
    mockGetWait = MockGetRollingMeanWaitUseCase();
    incomingEventsController = StreamController<SyncEnvelope>.broadcast();

    when(() => mockLanSyncRepo.incomingEvents).thenAnswer((_) => incomingEventsController.stream);
    when(() => mockLanSyncRepo.broadcast(any())).thenAnswer((_) async => true);
    when(() => mockLanSyncRepo.isHost).thenReturn(false);
    when(() => mockGetQueue.call(doctorName: any(named: 'doctorName'))).thenAnswer((_) async => const Right([]));
    when(() => mockGetPatients.call()).thenAnswer((_) async => const Right([]));
    when(() => mockGetWait.call(any())).thenAnswer((_) async => const Right(15));
    when(() => mockClinicRepo.savePatient(any())).thenAnswer((inv) async => Right(inv.positionalArguments[0] as PatientProfile));
    when(() => mockClinicRepo.saveVisit(any())).thenAnswer((inv) async => Right(inv.positionalArguments[0] as ClinicVisit));
  });

  tearDown(() {
    incomingEventsController.close();
  });

  group('LAN Sync Full Data Payload Synchronization Tests', () {
    test('1. Broadcaster (Reception): CheckInPatientEvent broadcasts envelope containing FULL JSON for patient and visit', () async {
      final savedVisit = ClinicVisit(
        id: 'vis_sync_1',
        patientId: 'pat_sync_1',
        patientName: 'Sarah Jenkins',
        doctorName: 'usr_doctor',
        queueNumber: 3,
        status: ClinicVisitStatus.waiting,
        checkInTime: DateTime.now(),
        chiefComplaint: 'Toothache and swelling [Age: 29, Tel: 555-0192]',
      );

      when(() => mockCheckIn(any())).thenAnswer((_) async => Right(savedVisit));

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
        clinicRepository: mockClinicRepo,
        lanSyncRepository: mockLanSyncRepo,
      );

      clinicBloc.add(
        const CheckInPatientEvent(
          patientId: 'pat_sync_1',
          patientName: 'Sarah Jenkins',
          doctorName: 'usr_doctor',
          chiefComplaint: 'Toothache and swelling [Age: 29, Tel: 555-0192]',
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Verify envelope broadcasted with full payload
      final captured = verify(() => mockLanSyncRepo.broadcast(captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);

      final envelope = captured.first as SyncEnvelope;
      expect(envelope.type, equals(MessageRoutes.patientCheckedIn));
      expect(envelope.payload, isNotNull);

      // Validate patient JSON payload
      expect(envelope.payload!['patient'], isA<Map<String, dynamic>>());
      final patientJson = envelope.payload!['patient'] as Map<String, dynamic>;
      expect(patientJson['id'], equals('pat_sync_1'));
      expect(patientJson['name'], equals('Sarah Jenkins'));

      // Validate visit JSON payload
      expect(envelope.payload!['visit'], isA<Map<String, dynamic>>());
      final visitJson = envelope.payload!['visit'] as Map<String, dynamic>;
      expect(visitJson['id'], equals('vis_sync_1'));
      expect(visitJson['patientName'], equals('Sarah Jenkins'));
      expect(visitJson['queueNumber'], equals(3));
      expect(visitJson['status'], equals('waiting'));

      await clinicBloc.close();
    });

    test('2 & 3. Listener (Doctor): Receiving patient.checked_in extracts JSON and explicitly inserts into local DB', () async {
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
        clinicRepository: mockClinicRepo,
        lanSyncRepository: mockLanSyncRepo,
      );

      final remotePatient = PatientProfileModel(
        id: 'pat_remote_9',
        name: 'Carlos Santana',
        phone: '555-9988',
        createdAt: DateTime.now(),
      );

      final remoteVisit = ClinicVisitModel(
        id: 'vis_remote_9',
        patientId: 'pat_remote_9',
        patientName: 'Carlos Santana',
        doctorName: 'usr_doctor',
        queueNumber: 5,
        status: ClinicVisitStatus.waiting,
        checkInTime: DateTime.now(),
        chiefComplaint: 'Root canal checkup',
      );

      // Simulate incoming event from Reception
      incomingEventsController.add(
        SyncEnvelope.create(
          type: MessageRoutes.patientCheckedIn,
          senderId: 'reception_desk',
          senderRole: 'receptionist',
          payload: {
            'patient': remotePatient.toJson(),
            'visit': remoteVisit.toJson(),
          },
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Verify listener explicitly inserted patient into local DB
      verify(() => mockClinicRepo.savePatient(any(that: isA<PatientProfile>().having(
            (p) => p.id,
            'id',
            equals('pat_remote_9'),
          ).having(
            (p) => p.name,
            'name',
            equals('Carlos Santana'),
          )))).called(1);

      // Verify listener explicitly inserted visit into local DB
      verify(() => mockClinicRepo.saveVisit(any(that: isA<ClinicVisit>().having(
            (v) => v.id,
            'id',
            equals('vis_remote_9'),
          ).having(
            (v) => v.queueNumber,
            'queueNumber',
            equals(5),
          )))).called(1);

      // Verify queue reload was triggered
      verify(() => mockGetQueue.call(doctorName: any(named: 'doctorName'))).called(greaterThanOrEqualTo(1));

      await clinicBloc.close();
    });

    test('4. CompleteExaminationEvent broadcasts full JSON and peer listener saves completed visit into local DB', () async {
      final completedVisit = ClinicVisit(
        id: 'vis_complete_88',
        patientId: 'pat_88',
        patientName: 'Elena Rostova',
        doctorName: 'usr_doctor',
        queueNumber: 2,
        status: ClinicVisitStatus.completed,
        checkInTime: DateTime.now().subtract(const Duration(minutes: 40)),
        completionTime: DateTime.now(),
        diagnosis: 'Compound cavity on tooth #19',
        appliedProcedures: const [
          ProcedureItem(id: 'pr_1', code: 'D2140', name: 'Amalgam restoration', standardFee: 350.0),
        ],
        totalFee: 350.0,
        patientCopay: 70.0,
        insurancePaid: 280.0,
      );

      when(() => mockCompleteVisit(any())).thenAnswer((_) async => Right(completedVisit));

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
        clinicRepository: mockClinicRepo,
        lanSyncRepository: mockLanSyncRepo,
      );

      // Doctor completes examination
      clinicBloc.add(CompleteExaminationEvent(completedVisit));

      await Future.delayed(const Duration(milliseconds: 100));

      // Verify broadcast contains full visit JSON with procedures and fee
      final captured = verify(() => mockLanSyncRepo.broadcast(captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);

      final envelope = captured.first as SyncEnvelope;
      expect(envelope.type, equals(MessageRoutes.visitCompleted));
      expect(envelope.payload!['visit'], isA<Map<String, dynamic>>());

      final visitPayload = envelope.payload!['visit'] as Map<String, dynamic>;
      expect(visitPayload['id'], equals('vis_complete_88'));
      expect(visitPayload['totalFee'], equals(350.0));
      expect(visitPayload['patientCopay'], equals(70.0));
      expect(visitPayload['diagnosis'], equals('Compound cavity on tooth #19'));

      // Now simulate Reception receiving this visitCompleted envelope
      incomingEventsController.add(envelope);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify Reception saved completed visit into its local DB
      verify(() => mockClinicRepo.saveVisit(any(that: isA<ClinicVisit>().having(
            (v) => v.id,
            'id',
            equals('vis_complete_88'),
          ).having(
            (v) => v.totalFee,
            'totalFee',
            equals(350.0),
          )))).called(1);

      await clinicBloc.close();
    });

    test('5. Host State Dispatcher: Receiving sync.request_active_state bundles active visits and patients into sync.full_state_response', () async {
      when(() => mockLanSyncRepo.isHost).thenReturn(true);

      final waitingVisit = ClinicVisit(
        id: 'vis_active_1',
        patientId: 'pat_active_1',
        patientName: 'Alice Springs',
        doctorName: 'usr_doctor',
        queueNumber: 1,
        status: ClinicVisitStatus.waiting,
        checkInTime: DateTime.now(),
      );

      final inExamVisit = ClinicVisit(
        id: 'vis_active_2',
        patientId: 'pat_active_2',
        patientName: 'Bob Miller',
        doctorName: 'usr_doctor',
        queueNumber: 2,
        status: ClinicVisitStatus.inExamination,
        checkInTime: DateTime.now(),
      );

      final completedVisit = ClinicVisit(
        id: 'vis_past_9',
        patientId: 'pat_past_9',
        patientName: 'Past Patient',
        doctorName: 'usr_doctor',
        queueNumber: 0,
        status: ClinicVisitStatus.completed,
        checkInTime: DateTime.now(),
      );

      final activePatient1 = PatientProfile(
        id: 'pat_active_1',
        name: 'Alice Springs',
        phone: '111-222',
        createdAt: DateTime.now(),
      );

      final activePatient2 = PatientProfile(
        id: 'pat_active_2',
        name: 'Bob Miller',
        phone: '333-444',
        createdAt: DateTime.now(),
      );

      when(() => mockGetQueue.call(doctorName: any(named: 'doctorName')))
          .thenAnswer((_) async => Right([waitingVisit, inExamVisit, completedVisit]));
      when(() => mockGetPatients.call())
          .thenAnswer((_) async => Right([activePatient1, activePatient2]));

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
        clinicRepository: mockClinicRepo,
        lanSyncRepository: mockLanSyncRepo,
      );

      // Client node connects or reconnects after network drop, sending request
      incomingEventsController.add(
        SyncEnvelope.create(
          type: MessageRoutes.syncRequestActiveState,
          senderId: 'client-station-2',
          senderRole: 'station',
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final captured = verify(() => mockLanSyncRepo.broadcast(captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);

      final responseEnv = captured.firstWhere(
        (e) => (e as SyncEnvelope).type == MessageRoutes.syncFullStateResponse,
      ) as SyncEnvelope;

      expect(responseEnv.payload, isNotNull);
      final visitsList = responseEnv.payload!['visits'] as List;
      final patientsList = responseEnv.payload!['patients'] as List;

      // Only waiting and inExamination visits should be in the active state bundle
      expect(visitsList.length, equals(2));
      expect(visitsList.any((v) => v['id'] == 'vis_active_1'), isTrue);
      expect(visitsList.any((v) => v['id'] == 'vis_active_2'), isTrue);
      expect(visitsList.any((v) => v['id'] == 'vis_past_9'), isFalse);

      expect(patientsList.length, equals(2));
      expect(patientsList.any((p) => p['id'] == 'pat_active_1'), isTrue);

      await clinicBloc.close();
    });

    test('6. Client State Ingestion: Receiving sync.full_state_response batch-upserts data and triggers queue reload', () async {
      when(() => mockLanSyncRepo.isHost).thenReturn(false);

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
        clinicRepository: mockClinicRepo,
        lanSyncRepository: mockLanSyncRepo,
      );

      final responseEnvelope = SyncEnvelope.create(
        type: MessageRoutes.syncFullStateResponse,
        senderId: 'hub_host',
        senderRole: 'host',
        payload: {
          'patients': [
            {'id': 'pat_reconciled_1', 'name': 'Patient Alpha', 'phone': '999', 'createdAt': DateTime.now().toIso8601String()},
            {'id': 'pat_reconciled_2', 'name': 'Patient Beta', 'phone': '888', 'createdAt': DateTime.now().toIso8601String()},
          ],
          'visits': [
            {
              'id': 'vis_reconciled_1',
              'patientId': 'pat_reconciled_1',
              'patientName': 'Patient Alpha',
              'doctorName': 'usr_doctor',
              'queueNumber': 1,
              'status': 'waiting',
              'checkInTime': DateTime.now().toIso8601String(),
            },
            {
              'id': 'vis_reconciled_2',
              'patientId': 'pat_reconciled_2',
              'patientName': 'Patient Beta',
              'doctorName': 'usr_doctor',
              'queueNumber': 2,
              'status': 'inExamination',
              'checkInTime': DateTime.now().toIso8601String(),
            },
          ],
        },
      );

      incomingEventsController.add(responseEnvelope);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert both patients were saved into local DB
      verify(() => mockClinicRepo.savePatient(any(that: isA<PatientProfile>().having(
            (p) => p.id,
            'id',
            equals('pat_reconciled_1'),
          )))).called(1);
      verify(() => mockClinicRepo.savePatient(any(that: isA<PatientProfile>().having(
            (p) => p.id,
            'id',
            equals('pat_reconciled_2'),
          )))).called(1);

      // Assert both visits were saved into local DB
      verify(() => mockClinicRepo.saveVisit(any(that: isA<ClinicVisit>().having(
            (v) => v.id,
            'id',
            equals('vis_reconciled_1'),
          )))).called(1);
      verify(() => mockClinicRepo.saveVisit(any(that: isA<ClinicVisit>().having(
            (v) => v.id,
            'id',
            equals('vis_reconciled_2'),
          )))).called(1);

      // Assert queue was reloaded
      verify(() => mockGetQueue.call(doctorName: any(named: 'doctorName'))).called(greaterThanOrEqualTo(1));

      await clinicBloc.close();
    });

    test('7. Torture Test: Client disconnects, host registers new patient "momo", client reconnects and reconciles "momo" into local DB', () async {
      when(() => mockLanSyncRepo.isHost).thenReturn(true);

      final momoPatient = PatientProfile(
        id: 'pat_momo',
        name: 'momo',
        phone: '555-0999',
        createdAt: DateTime.now(),
      );

      final momoVisit = ClinicVisit(
        id: 'vis_momo',
        patientId: 'pat_momo',
        patientName: 'momo',
        doctorName: 'usr_doctor',
        queueNumber: 3,
        status: ClinicVisitStatus.waiting,
        checkInTime: DateTime.now(),
      );

      when(() => mockGetQueue.call(doctorName: any(named: 'doctorName')))
          .thenAnswer((_) async => Right([momoVisit]));
      when(() => mockGetPatients.call())
          .thenAnswer((_) async => Right([momoPatient]));

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
        clinicRepository: mockClinicRepo,
        lanSyncRepository: mockLanSyncRepo,
      );

      // Reconnecting client requests active state
      incomingEventsController.add(
        SyncEnvelope.create(
          type: MessageRoutes.syncRequestActiveState,
          senderId: 'client-station-2',
          senderRole: 'station',
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      final captured = verify(() => mockLanSyncRepo.broadcast(captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);

      final responseEnv = captured.firstWhere(
        (e) => (e as SyncEnvelope).type == MessageRoutes.syncFullStateResponse,
      ) as SyncEnvelope;

      expect(responseEnv.payload, isNotNull);
      final patientsList = responseEnv.payload!['patients'] as List;
      final visitsList = responseEnv.payload!['visits'] as List;

      // Verify 'momo' is present in host broadcast payload
      expect(patientsList.any((p) => p['name'] == 'momo' && p['id'] == 'pat_momo'), isTrue);
      expect(visitsList.any((v) => v['patientName'] == 'momo' && v['id'] == 'vis_momo'), isTrue);

      // Now client receives the response envelope
      when(() => mockLanSyncRepo.isHost).thenReturn(false);
      when(() => mockClinicRepo.savePatient(any())).thenAnswer((inv) async => Right(inv.positionalArguments[0] as PatientProfile));
      when(() => mockClinicRepo.saveVisit(any())).thenAnswer((inv) async => Right(inv.positionalArguments[0] as ClinicVisit));

      incomingEventsController.add(responseEnv);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify 'momo' patient was saved to local client database
      verify(() => mockClinicRepo.savePatient(any(that: isA<PatientProfile>().having(
            (p) => p.name,
            'name',
            equals('momo'),
          )))).called(1);

      // Verify 'momo' visit was saved to local client database
      verify(() => mockClinicRepo.saveVisit(any(that: isA<ClinicVisit>().having(
            (v) => v.patientName,
            'patientName',
            equals('momo'),
          )))).called(1);

      await clinicBloc.close();
    });

    test('8. Broadcaster & Listener: UpdateVisitStatusEvent broadcasts visit.updated with full payload, peer saves it to DB', () async {
      final updatedVisit = ClinicVisit(
        id: 'vis_status_1',
        patientId: 'pat_status_1',
        patientName: 'Jane Doe',
        doctorName: 'usr_doctor',
        queueNumber: 1,
        status: ClinicVisitStatus.inExamination,
        checkInTime: DateTime.now().subtract(const Duration(minutes: 10)),
        consultationStartTime: DateTime.now(),
      );

      final patient = PatientProfile(
        id: 'pat_status_1',
        name: 'Jane Doe',
        phone: '123456',
        createdAt: DateTime.now(),
      );

      when(() => mockUpdateVisit('vis_status_1', ClinicVisitStatus.inExamination))
          .thenAnswer((_) async => Right(updatedVisit));
      when(() => mockGetPatients()).thenAnswer((_) async => Right([patient]));

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
        clinicRepository: mockClinicRepo,
        lanSyncRepository: mockLanSyncRepo,
      );

      // Station calls in the patient (status -> inExamination)
      clinicBloc.add(
        const UpdateVisitStatusEvent(
          visitId: 'vis_status_1',
          status: ClinicVisitStatus.inExamination,
        ),
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Verify broadcast envelope with visit.updated
      final captured = verify(() => mockLanSyncRepo.broadcast(captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);

      final envelope = captured.first as SyncEnvelope;
      expect(envelope.type, equals(MessageRoutes.syncVisitUpdated));
      expect(envelope.payload!['status'], equals('inExamination'));
      expect(envelope.payload!['visit']['id'], equals('vis_status_1'));
      expect(envelope.payload!['patient']['id'], equals('pat_status_1'));

      // Simulate peer node receiving visit.updated
      incomingEventsController.add(envelope);
      await Future.delayed(const Duration(milliseconds: 100));

      // Peer saves updated visit to local DB
      verify(() => mockClinicRepo.saveVisit(any(that: isA<ClinicVisit>().having(
            (v) => v.id,
            'id',
            equals('vis_status_1'),
          ).having(
            (v) => v.status,
            'status',
            equals(ClinicVisitStatus.inExamination),
          )))).called(1);

      await clinicBloc.close();
    });

    test('9. Conflict Resolution: Ingesting stale waiting visit when local is inExamination ignores overwrite and fires counter-sync', () async {
      when(() => mockLanSyncRepo.isHost).thenReturn(false);

      final localVisit = ClinicVisit(
        id: 'vis_conflict_1',
        patientId: 'pat_conflict_1',
        patientName: 'Stale Defense Patient',
        doctorName: 'usr_doctor',
        queueNumber: 1,
        status: ClinicVisitStatus.inExamination, // Newer local state
        checkInTime: DateTime.now().subtract(const Duration(minutes: 15)),
        consultationStartTime: DateTime.now(),
      );

      final localPatient = PatientProfile(
        id: 'pat_conflict_1',
        name: 'Stale Defense Patient',
        phone: '555-1234',
        createdAt: DateTime.now(),
      );

      when(() => mockGetQueue.call(doctorName: any(named: 'doctorName')))
          .thenAnswer((_) async => Right([localVisit]));
      when(() => mockGetPatients()).thenAnswer((_) async => Right([localPatient]));

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
        clinicRepository: mockClinicRepo,
        lanSyncRepository: mockLanSyncRepo,
      );

      // Incoming full state response contains STALE 'waiting' status
      final staleResponseEnv = SyncEnvelope.create(
        type: MessageRoutes.syncFullStateResponse,
        senderId: 'hub_host',
        senderRole: 'host',
        payload: {
          'patients': [
            PatientProfileModel.fromEntity(localPatient).toJson(),
          ],
          'visits': [
            ClinicVisitModel(
              id: 'vis_conflict_1',
              patientId: 'pat_conflict_1',
              patientName: 'Stale Defense Patient',
              doctorName: 'usr_doctor',
              queueNumber: 1,
              status: ClinicVisitStatus.waiting, // STALE STATE from host
              checkInTime: DateTime.now().subtract(const Duration(minutes: 15)),
            ).toJson(),
          ],
        },
      );

      incomingEventsController.add(staleResponseEnv);
      await Future.delayed(const Duration(milliseconds: 100));

      // Verify that saveVisit was NEVER called with the stale waiting status
      verifyNever(() => mockClinicRepo.saveVisit(any(that: isA<ClinicVisit>().having(
            (v) => v.status,
            'status',
            equals(ClinicVisitStatus.waiting),
          ))));

      // Verify counter-sync broadcast was fired to correct the network
      final captured = verify(() => mockLanSyncRepo.broadcast(captureAny())).captured;
      expect(captured.isNotEmpty, isTrue);

      final counterEnv = captured.firstWhere(
        (e) => (e as SyncEnvelope).type == MessageRoutes.syncVisitUpdated,
      ) as SyncEnvelope;

      expect(counterEnv.payload!['visitId'], equals('vis_conflict_1'));
      expect(counterEnv.payload!['status'], equals('inExamination'));

      await clinicBloc.close();
    });
  });
}
