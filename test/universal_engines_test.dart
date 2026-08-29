import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:empos/features/bookings/data/datasources/booking_local_data_source.dart';
import 'package:empos/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:empos/features/bookings/domain/entities/booking_item.dart';
import 'package:empos/features/clinic/data/datasources/clinic_local_data_source.dart';
import 'package:empos/features/clinic/data/models/patient_profile_model.dart';
import 'package:empos/features/clinic/data/repositories/dental_repository_impl.dart';
import 'package:empos/features/finance_splits/data/datasources/finance_split_local_data_source.dart';
import 'package:empos/features/finance_splits/data/repositories/finance_split_repository_impl.dart';
import 'package:empos/features/finance_splits/domain/entities/revenue_split_rule.dart';
import 'package:empos/features/work_orders/data/datasources/work_order_local_data_source.dart';
import 'package:empos/features/work_orders/data/repositories/work_order_repository_impl.dart';
import 'package:empos/features/work_orders/domain/entities/work_order_ticket.dart';

void main() {
  late Directory tempDir;
  late ClinicLocalDataSource clinicDataSource;
  late DentalRepositoryImpl dentalRepository;
  late BookingLocalDataSource bookingDataSource;
  late BookingRepositoryImpl bookingRepository;
  late WorkOrderLocalDataSource workOrderDataSource;
  late WorkOrderRepositoryImpl workOrderRepository;
  late FinanceSplitLocalDataSource financeSplitDataSource;
  late FinanceSplitRepositoryImpl financeSplitRepository;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('empos_universal_engines_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  setUp(() async {
    clinicDataSource = ClinicLocalDataSourceImpl();
    dentalRepository = DentalRepositoryImpl(localDataSource: clinicDataSource);

    bookingDataSource = BookingLocalDataSourceImpl();
    bookingRepository = BookingRepositoryImpl(localDataSource: bookingDataSource);

    workOrderDataSource = WorkOrderLocalDataSourceImpl();
    workOrderRepository = WorkOrderRepositoryImpl(localDataSource: workOrderDataSource);

    financeSplitDataSource = FinanceSplitLocalDataSourceImpl();
    financeSplitRepository = FinanceSplitRepositoryImpl(localDataSource: financeSplitDataSource);
  });

  tearDown(() async {
    final boxes = [
      ClinicLocalDataSourceImpl.patientsBoxName,
      ClinicLocalDataSourceImpl.toothChartsBoxName,
      BookingLocalDataSourceImpl.bookingsBoxName,
      WorkOrderLocalDataSourceImpl.workOrdersBoxName,
      FinanceSplitLocalDataSourceImpl.financeSplitsBoxName,
    ];
    for (final name in boxes) {
      if (Hive.isBoxOpen(name)) {
        await Hive.box<dynamic>(name).clear();
      }
    }
  });

  group('Pediatric vs Adult Dental Tooth Chart Logic', () {
    test('Patient under 12 years old receives 20 Primary/Deciduous teeth (A-T)', () async {
      // 7-year old pediatric patient
      final childPatient = PatientProfileModel(
        id: 'pat_child_01',
        name: 'Adam Youssef',
        phone: '01099887766',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 7 * 365)).toIso8601String(),
        createdAt: DateTime.now(),
      );
      await clinicDataSource.savePatient(childPatient);

      final result = await dentalRepository.getPatientToothChart('pat_child_01');
      expect(result.isRight(), true);
      result.fold((l) => fail(l.message), (teeth) {
        expect(teeth.length, 20);
        expect(teeth.first.effectiveToothCode, 'A');
        expect(teeth.last.effectiveToothCode, 'T');
        expect(teeth.every((t) => t.isDeciduous), true);
      });
    });

    test('Patient 12 years or older receives 32 Permanent teeth (1-32)', () async {
      // 25-year old adult patient
      final adultPatient = PatientProfileModel(
        id: 'pat_adult_01',
        name: 'Mona Zaki',
        phone: '01011223344',
        dateOfBirth: DateTime.now().subtract(const Duration(days: 25 * 365)).toIso8601String(),
        createdAt: DateTime.now(),
      );
      await clinicDataSource.savePatient(adultPatient);

      final result = await dentalRepository.getPatientToothChart('pat_adult_01');
      expect(result.isRight(), true);
      result.fold((l) => fail(l.message), (teeth) {
        expect(teeth.length, 32);
        expect(teeth.first.effectiveToothCode, '1');
        expect(teeth.last.effectiveToothCode, '32');
        expect(teeth.every((t) => !t.isDeciduous), true);
      });
    });
  });

  group('Universal Booking & Calendar Engine Tests', () {
    test('Saves booking and detects scheduling conflict for same resource slot', () async {
      final now = DateTime(2026, 6, 1, 14, 0); // 2:00 PM
      final end = now.add(const Duration(minutes: 60)); // 3:00 PM

      final booking1 = BookingItem(
        id: 'book_01',
        customerOrPatientId: 'cust_01',
        customerName: 'Karim Hassan',
        resourceId: 'doctor_room_3',
        resourceName: 'Examination Room 3',
        serviceName: 'Cardiology Consultation',
        startTime: now,
        endTime: end,
        createdAt: DateTime.now(),
      );

      final save1Result = await bookingRepository.saveBooking(booking1);
      expect(save1Result.isRight(), true);

      // Attempt conflicting booking (2:30 PM to 3:30 PM for same room)
      final conflictingBooking = BookingItem(
        id: 'book_02',
        customerOrPatientId: 'cust_02',
        customerName: 'Samir Ali',
        resourceId: 'doctor_room_3',
        resourceName: 'Examination Room 3',
        serviceName: 'Follow-up Consultation',
        startTime: now.add(const Duration(minutes: 30)),
        endTime: end.add(const Duration(minutes: 30)),
        createdAt: DateTime.now(),
      );

      final save2Result = await bookingRepository.saveBooking(conflictingBooking);
      expect(save2Result.isLeft(), true);
      save2Result.fold((failure) {
        expect(failure.message, contains('already booked'));
      }, (r) => fail('Should have failed with conflict'));
    });

    test('Cancels booking and frees up time-slot availability', () async {
      final now = DateTime(2026, 6, 1, 10, 0);
      final end = now.add(const Duration(minutes: 45));

      final booking = BookingItem(
        id: 'book_salon_01',
        customerOrPatientId: 'cust_03',
        customerName: 'Layla Nour',
        resourceId: 'stylist_chair_1',
        serviceName: 'Hair Styling & Keratin',
        startTime: now,
        endTime: end,
        createdAt: DateTime.now(),
      );

      await bookingRepository.saveBooking(booking);

      // Verify slot is booked
      final check1 = await bookingRepository.checkAvailability('stylist_chair_1', now, end);
      expect(check1.getOrElse(() => true), false);

      // Cancel booking
      final cancelResult = await bookingRepository.cancelBooking('book_salon_01');
      expect(cancelResult.isRight(), true);
      expect(cancelResult.getOrElse(() => booking).status, BookingStatus.cancelled);

      // Verify slot is now available
      final check2 = await bookingRepository.checkAvailability('stylist_chair_1', now, end);
      expect(check2.getOrElse(() => false), true);
    });
  });

  group('Universal Work Order & Service Pipeline Engine Tests', () {
    test('Creates work order with custom industry metadata and tracks stage transitions', () async {
      final ticket = WorkOrderTicket(
        id: 'wo_auto_01',
        title: 'Brake Pad Replacement & Rotor Resurfacing',
        customerId: 'cust_auto_01',
        customerName: 'Tariq Nabil',
        customerPhone: '01234567890',
        assignedStaffName: 'Master Mechanic Mahmoud',
        currentStage: WorkOrderStage.intake,
        customMetadata: const {
          'vehicleVIN': '1HGCR2F83HA123456',
          'odometer': 142500,
          'vehicleModel': 'Honda Accord 2017',
        },
        totalEstimate: 1850.0,
        depositPaid: 500.0,
        createdAt: DateTime(2026, 6, 1, 9, 0),
      );

      expect(ticket.balanceDue, 1350.0);
      await workOrderRepository.saveWorkOrder(ticket);

      // Transition to InProgress
      final transition1 = await workOrderRepository.transitionStage(
        'wo_auto_01',
        WorkOrderStage.inProgress,
        notes: 'Front ceramic pads installed; resurfacing front rotors.',
        updatedBy: 'Mahmoud',
      );
      expect(transition1.isRight(), true);
      transition1.fold((l) => fail(l.message), (t) {
        expect(t.currentStage, WorkOrderStage.inProgress);
        expect(t.stagesHistory.length, 1);
        expect(t.stagesHistory.first.notes, contains('ceramic pads'));
      });

      // Transition to Ready
      final transition2 = await workOrderRepository.transitionStage(
        'wo_auto_01',
        WorkOrderStage.ready,
        notes: 'Road test passed. Vehicle ready for pickup.',
        updatedBy: 'QA Lead Hesham',
      );
      expect(transition2.isRight(), true);
      transition2.fold((l) => fail(l.message), (t) {
        expect(t.currentStage, WorkOrderStage.ready);
        expect(t.stagesHistory.length, 2);
      });
    });
  });

  group('Universal Multi-Party Split & Commission Engine Tests', () {
    test('Calculates multi-rule distribution combining percentage cuts and flat fees', () {
      final rules = [
        const RevenueSplitRule(
          id: 'rule_stylist_comm',
          name: 'Lead Stylist Commission',
          type: SplitRuleType.staffCommission,
          percentage: 0.40, // 40%
          flatFee: 0.0,
          recipientName: 'Stylist Dina',
        ),
        const RevenueSplitRule(
          id: 'rule_assistant_tip',
          name: 'Shampoo Assistant Tip',
          type: SplitRuleType.staffCommission,
          percentage: 0.05, // 5%
          flatFee: 50.0, // + 50 EGP Flat Tip
          recipientName: 'Assistant Aya',
        ),
      ];

      const totalServiceFee = 1000.0;
      final distResult = financeSplitRepository.calculateDistribution(totalServiceFee, rules);
      expect(distResult.isRight(), true);

      distResult.fold((l) => fail(l.message), (splits) {
        expect(splits.length, 2);
        // Stylist: 1000 * 0.40 = 400.0
        expect(splits[0].calculatedAmount, 400.0);
        expect(splits[0].recipientName, 'Stylist Dina');
        // Assistant: (1000 * 0.05) + 50 = 100.0
        expect(splits[1].calculatedAmount, 100.0);
        expect(splits[1].recipientName, 'Assistant Aya');
      });
    });

    test('Records settlement log and retrieves by reference ID', () async {
      final settlement = FinanceSettlementLog(
        id: 'settle_01',
        referenceId: 'order_tx_9988',
        totalAmount: 2000.0,
        date: DateTime.now(),
        splits: const [
          SplitCalculationResult(
            rule: RevenueSplitRule(
              id: 'r1',
              name: 'Broker Split',
              type: SplitRuleType.brokerSplit,
              percentage: 0.20,
              recipientName: 'Brokerage Firm',
            ),
            calculatedAmount: 400.0,
            recipientName: 'Brokerage Firm',
          ),
        ],
        netOwnerAmount: 1600.0,
        notes: 'Real estate transaction closing commission split',
      );

      final saveResult = await financeSplitRepository.recordSettlement(settlement);
      expect(saveResult.isRight(), true);

      final fetchResult = await financeSplitRepository.getSettlementLogs(referenceId: 'order_tx_9988');
      expect(fetchResult.isRight(), true);
      fetchResult.fold((l) => fail(l.message), (logs) {
        expect(logs.length, 1);
        expect(logs.first.netOwnerAmount, 1600.0);
        expect(logs.first.totalDistributed, 400.0);
      });
    });
  });
}
