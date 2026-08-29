import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:empos/features/clinic/data/datasources/clinic_local_data_source.dart';
import 'package:empos/features/clinic/data/models/clinic_visit_model.dart';
import 'package:empos/features/clinic/data/models/dental_treatment_plan_model.dart';
import 'package:empos/features/clinic/data/models/patient_profile_model.dart';
import 'package:empos/features/clinic/data/models/tooth_chart_entry_model.dart';
import 'package:empos/features/clinic/data/repositories/clinic_repository_impl.dart';
import 'package:empos/features/clinic/data/repositories/dental_repository_impl.dart';
import 'package:empos/features/clinic/domain/entities/clinic_visit.dart';
import 'package:empos/features/clinic/domain/entities/dental_treatment_plan.dart';
import 'package:empos/features/clinic/domain/entities/patient_profile.dart';
import 'package:empos/features/clinic/domain/entities/procedure_item.dart';
import 'package:empos/features/clinic/domain/entities/tooth_chart_entry.dart';
import 'package:empos/features/clinic/presentation/pages/clinic_reception_page.dart';

void main() {
  late Directory tempDir;
  late ClinicLocalDataSource localDataSource;
  late ClinicRepositoryImpl clinicRepository;
  late DentalRepositoryImpl dentalRepository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('empos_clinic_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    localDataSource = ClinicLocalDataSourceImpl();
    clinicRepository = ClinicRepositoryImpl(localDataSource: localDataSource);
    dentalRepository = DentalRepositoryImpl(localDataSource: localDataSource);
  });

  tearDown(() async {
    final boxNames = [
      ClinicLocalDataSourceImpl.patientsBoxName,
      ClinicLocalDataSourceImpl.visitsBoxName,
      ClinicLocalDataSourceImpl.toothChartsBoxName,
      ClinicLocalDataSourceImpl.dentalPlansBoxName,
    ];
    for (final name in boxNames) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<dynamic>(name).clear();
      }
    }
  });

  group('Clinic Models & JSON Serialization Tests', () {
    test('PatientProfileModel correctly serializes and deserializes', () {
      final patient = PatientProfileModel(
        id: 'pat_001',
        name: 'Dr. Sarah Ahmed',
        phone: '01012345678',
        dateOfBirth: '1992-05-14',
        gender: 'Female',
        bloodType: 'O+',
        allergies: const ['Penicillin', 'Sulfa'],
        chronicConditions: const ['Asthma'],
        currentMedications: const ['Ventolin Inhaler'],
        insuranceProvider: 'Bupa Global',
        policyNumber: 'BUP-998822',
        defaultCopayPercentage: 0.20,
        createdAt: DateTime(2026, 1, 1),
      );

      final json = patient.toJson();
      final reconstructed = PatientProfileModel.fromJson(json);

      expect(reconstructed.id, 'pat_001');
      expect(reconstructed.name, 'Dr. Sarah Ahmed');
      expect(reconstructed.allergies, ['Penicillin', 'Sulfa']);
      expect(reconstructed.insuranceProvider, 'Bupa Global');
      expect(reconstructed.defaultCopayPercentage, 0.20);
    });

    test('ProcedureItemModel computes copay and insurance share accurately', () {
      const procedure = ProcedureItem(
        id: 'proc_01',
        code: 'D2740',
        name: 'Porcelain/Ceramic Dental Crown',
        standardFee: 2000.0,
        insuranceCoveragePercentage: 0.80, // 80% coverage
        requiredConsumables: ['Impression Material', 'Temporary Cement'],
      );

      expect(procedure.insuranceShare, 1600.0);
      expect(procedure.patientCopay, 400.0);
    });

    test('ToothChartEntryModel serializes tooth states and pocket probing depths', () {
      const tooth = ToothChartEntryModel(
        toothNumber: 14, // Maxillary First Molar
        state: ToothState.decayed,
        pocketDepthMm: 4,
        surfaceNotation: 'MOD',
        notes: 'Deep occlusal caries requiring composite restoration',
      );

      final json = tooth.toJson();
      final reconstructed = ToothChartEntryModel.fromJson(json);

      expect(reconstructed.toothNumber, 14);
      expect(reconstructed.state, ToothState.decayed);
      expect(reconstructed.pocketDepthMm, 4);
      expect(reconstructed.surfaceNotation, 'MOD');
      expect(reconstructed.notes, contains('Deep occlusal'));
    });

    test('DentalTreatmentPlanModel handles staged multi-visit plans and completion status', () {
      final plan = DentalTreatmentPlanModel(
        id: 'plan_01',
        patientId: 'pat_001',
        title: 'Full Root Canal & Crown Rehabilitation',
        stages: [
          DentalTreatmentStageModel(
            stageNumber: 1,
            title: 'Root Canal Biomechanical Preparation',
            procedureCode: 'D3330',
            fee: 800.0,
            isCompleted: true,
            completionDate: DateTime(2026, 1, 10),
          ),
          const DentalTreatmentStageModel(
            stageNumber: 2,
            title: 'Canal Obturation & Core Buildup',
            procedureCode: 'D2950',
            fee: 600.0,
            isCompleted: false,
          ),
          const DentalTreatmentStageModel(
            stageNumber: 3,
            title: 'Final Zirconia Crown Placement',
            procedureCode: 'D2740',
            fee: 1800.0,
            isCompleted: false,
          ),
        ],
        totalFee: 3200.0,
        status: TreatmentPlanStatus.active,
        createdAt: DateTime(2026, 1, 10),
      );

      expect(plan.completedStagesCount, 1);
      expect(plan.isFullyCompleted, false);

      final json = plan.toJson();
      final reconstructed = DentalTreatmentPlanModel.fromJson(json);

      expect(reconstructed.stages.length, 3);
      expect(reconstructed.totalFee, 3200.0);
      expect(reconstructed.stages.first.isCompleted, true);
    });
  });

  group('ClinicRepository Queue & Visit Business Logic Tests', () {
    test('Patient registration, search, and queue check-in sequence', () async {
      final patient = PatientProfile(
        id: 'pat_100',
        name: 'Omar Sherif',
        phone: '01122334455',
        insuranceProvider: 'AXA Egypt',
        policyNumber: 'AXA-1100',
        createdAt: DateTime.now(),
      );

      // 1. Save patient
      final saveResult = await clinicRepository.savePatient(patient);
      expect(saveResult.isRight(), true);

      // 2. Search patient
      final searchResult = await clinicRepository.searchPatients('Omar');
      expect(searchResult.isRight(), true);
      searchResult.fold((l) => fail(l.message), (list) {
        expect(list.length, 1);
        expect(list.first.phone, '01122334455');
      });

      // 3. Check-in patient into doctor queue
      final visit = ClinicVisit(
        id: 'vis_01',
        patientId: 'pat_100',
        patientName: 'Omar Sherif',
        doctorName: 'Dr. Tarek Dental',
        queueNumber: 0,
        checkInTime: DateTime.now(),
      );

      final checkInResult = await clinicRepository.checkInPatient(visit);
      expect(checkInResult.isRight(), true);
      checkInResult.fold((l) => fail(l.message), (checkedIn) {
        expect(checkedIn.queueNumber, 1);
        expect(checkedIn.status, ClinicVisitStatus.waiting);
      });

      // 4. Retrieve queue
      final queueResult = await clinicRepository.getQueue(doctorName: 'Dr. Tarek Dental');
      expect(queueResult.isRight(), true);
      queueResult.fold((l) => fail(l.message), (q) {
        expect(q.length, 1);
        expect(q.first.patientName, 'Omar Sherif');
      });
    });

    test('Completing a visit calculates total fee, insurance share, and patient copay', () async {
      const proc1 = ProcedureItem(
        id: 'p1',
        code: 'D0120',
        name: 'Periodic Oral Evaluation',
        standardFee: 300.0,
        insuranceCoveragePercentage: 1.0, // 100% insurance covered
      );
      const proc2 = ProcedureItem(
        id: 'p2',
        code: 'D1110',
        name: 'Prophylaxis Dental Cleaning',
        standardFee: 500.0,
        insuranceCoveragePercentage: 0.50, // 50% insurance covered ($250 copay)
      );

      final visit = ClinicVisit(
        id: 'vis_billing_01',
        patientId: 'pat_100',
        patientName: 'Omar Sherif',
        doctorName: 'Dr. Tarek Dental',
        queueNumber: 1,
        status: ClinicVisitStatus.inExamination,
        checkInTime: DateTime.now().subtract(const Duration(minutes: 25)),
        consultationStartTime: DateTime.now().subtract(const Duration(minutes: 20)),
        appliedProcedures: const [proc1, proc2],
      );

      await clinicRepository.checkInPatient(visit);

      final completeResult = await clinicRepository.completeVisit(visit);
      expect(completeResult.isRight(), true);
      completeResult.fold((l) => fail(l.message), (completed) {
        expect(completed.status, ClinicVisitStatus.completed);
        expect(completed.totalFee, 800.0);
        expect(completed.insurancePaid, 550.0); // $300 + $250
        expect(completed.patientCopay, 250.0); // $0 + $250
      });
    });

    test('Rolling Mean Wait Time calculates queue wait from last 5 completed consultations', () async {
      const doctor = 'Dr. Hesham Medical';

      // 1. Add 5 historical completed visits with specific durations: 10, 20, 15, 25, 30 min (Mean = 20 min)
      final durations = [10, 20, 15, 25, 30];
      for (int i = 0; i < durations.length; i++) {
        final start = DateTime(2026, 1, 1, 10, 0);
        final end = start.add(Duration(minutes: durations[i]));
        final historicalVisit = ClinicVisitModel(
          id: 'hist_$i',
          patientId: 'pat_$i',
          patientName: 'Patient $i',
          doctorName: doctor,
          queueNumber: i + 1,
          status: ClinicVisitStatus.completed,
          checkInTime: start.subtract(const Duration(minutes: 5)),
          consultationStartTime: start,
          completionTime: end,
        );
        await localDataSource.saveVisit(historicalVisit);
      }

      // 2. Add 3 patients currently waiting in queue
      for (int i = 1; i <= 3; i++) {
        final waitingVisit = ClinicVisitModel(
          id: 'waiting_$i',
          patientId: 'wait_pat_$i',
          patientName: 'Waiting Patient $i',
          doctorName: doctor,
          queueNumber: i,
          status: ClinicVisitStatus.waiting,
          checkInTime: DateTime.now(),
        );
        await localDataSource.saveVisit(waitingVisit);
      }

      // 3. Rolling Mean Wait Time = 3 queue patients * (100 min total / 5 visits = 20 min avg) = 60 minutes
      final waitResult = await clinicRepository.getRollingMeanWaitMinutes(doctor);
      expect(waitResult.isRight(), true);
      waitResult.fold((l) => fail(l.message), (waitMinutes) {
        expect(waitMinutes, 60);
      });
    });
  });

  group('DentalRepository Tooth Chart & Plan Persistence Tests', () {
    test('Default tooth chart initializes 32 healthy teeth for new patients', () async {
      final result = await dentalRepository.getPatientToothChart('new_patient_99');
      expect(result.isRight(), true);
      result.fold((l) => fail(l.message), (teeth) {
        expect(teeth.length, 32);
        expect(teeth.first.toothNumber, 1);
        expect(teeth.last.toothNumber, 32);
        expect(teeth.every((t) => t.state == ToothState.healthy), true);
      });
    });

    test('Saving and retrieving modified tooth chart entries', () async {
      final entries = [
        const ToothChartEntry(toothNumber: 3, state: ToothState.decayed, surfaceNotation: 'DO'),
        const ToothChartEntry(toothNumber: 19, state: ToothState.rootCanal, pocketDepthMm: 3),
        const ToothChartEntry(toothNumber: 30, state: ToothState.implant),
      ];

      final saveResult = await dentalRepository.saveToothChart('pat_teeth_01', entries);
      expect(saveResult.isRight(), true);

      final getResult = await dentalRepository.getPatientToothChart('pat_teeth_01');
      expect(getResult.isRight(), true);
      getResult.fold((l) => fail(l.message), (teeth) {
        expect(teeth.length, 3);
        expect(teeth[0].state, ToothState.decayed);
        expect(teeth[1].state, ToothState.rootCanal);
        expect(teeth[2].state, ToothState.implant);
      });
    });
  });

  group('ClinicReceptionPage Doctor Translation Tests', () {
    test('formatDoctorName maps seeded doctor IDs to human-readable names and formats fallback IDs', () {
      expect(ClinicReceptionPage.formatDoctorName('usr_doctor'), equals('Dr. Sarah Connor'));
      expect(ClinicReceptionPage.formatDoctorName('usr_doctor_2'), equals('Dr. Tarek Dental Lead'));
      expect(ClinicReceptionPage.formatDoctorName('usr_doctor_tarek'), equals('Dr. Tarek Dental Lead'));
      expect(ClinicReceptionPage.formatDoctorName('usr_doctor_oncall'), equals('Dr. On-Call Physician'));
      expect(ClinicReceptionPage.formatDoctorName('usr_dentist_specialist'), equals('Dr. Dentist Specialist'));
      expect(ClinicReceptionPage.formatDoctorName('Dr. John Smith'), equals('Dr. John Smith'));
    });
  });

  group('Clinical Vitals & Age-Based Odontogram Logic Tests', () {
    test('ClinicVisitModel serializes and deserializes vitals accurately', () {
      final visit = ClinicVisitModel(
        id: 'vis_vitals_1',
        patientId: 'pat_01',
        patientName: 'Test Vitals',
        doctorName: 'usr_doctor',
        queueNumber: 1,
        checkInTime: DateTime(2026, 1, 1),
        bloodPressure: '135/85 mmHg',
        heartRate: '82 BPM',
        spo2: '98%',
        temperature: '37.2 °C',
        respiratoryRate: '18 bpm',
      );

      final json = visit.toJson();
      final restored = ClinicVisitModel.fromJson(json);

      expect(restored.bloodPressure, '135/85 mmHg');
      expect(restored.heartRate, '82 BPM');
      expect(restored.spo2, '98%');
      expect(restored.temperature, '37.2 °C');
      expect(restored.respiratoryRate, '18 bpm');
    });

    test('PatientProfile calculatedAge parses ISO date of birth and integer strings', () {
      final pediatric = PatientProfile(
        id: 'pat_ped_1',
        name: 'Little Timmy',
        phone: '123',
        dateOfBirth: DateTime(DateTime.now().year - 8, DateTime.now().month, DateTime.now().day).toIso8601String(),
        createdAt: DateTime.now(),
      );
      expect(pediatric.calculatedAge, equals(8));

      final adult = PatientProfile(
        id: 'pat_ad_1',
        name: 'Adult Timmy',
        phone: '123',
        dateOfBirth: '25',
        createdAt: DateTime.now(),
      );
      expect(adult.calculatedAge, equals(25));
    });
  });
}
