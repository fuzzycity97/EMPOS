import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/features/appointments/domain/models/doctor_schedule_models.dart';
import 'package:empos/features/appointments/domain/services/smart_scheduling_engine.dart';
import 'package:empos/features/appointments/presentation/reception_quick_booking_modal.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Test setup: Monday shift 09:00 - 17:00, lunch break 13:00 - 14:00, 30-min slots
  final testShift = DoctorWorkingShift(
    dayOfWeek: DateTime.monday,
    startTime: const TimeOfDay(hour: 9, minute: 0),
    endTime: const TimeOfDay(hour: 17, minute: 0),
    slotDurationMinutes: 30,
    breakTimes: const [
      TimeRange(
        start: TimeOfDay(hour: 13, minute: 0),
        end: TimeOfDay(hour: 14, minute: 0),
        name: 'Lunch Break',
      ),
    ],
  );

  // Leave override on 2026-09-14 (Monday): Annual Leave from 00:00 to 23:59
  final leaveOverride = DoctorLeaveOverride(
    startDateTime: DateTime(2026, 9, 14, 0, 0),
    endDateTime: DateTime(2026, 9, 14, 23, 59),
    reason: 'Annual Vacation',
  );

  // A Monday date that is not on leave: 2026-09-07
  final mondayDate = DateTime(2026, 9, 7);

  group('Task 8: Smart Doctor Roster & Conflict Guard Verification', () {
    test('1 & 2. Booking during lunch break is rejected with clear reason and suggests 3 alternatives', () {
      final lunchSlot = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 13, 15);
      final result = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: lunchSlot,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [],
      );

      expect(result.isAvailable, isFalse);
      expect(result.reason, SlotUnavailabilityReason.breakOrPrayerTime);
      expect(result.humanReadableMessage, contains('Lunch Break'));
      expect(result.nearestAlternativeSlots.length, 3);
      // All 3 alternative slots must be valid and available
      for (final alt in result.nearestAlternativeSlots) {
        final altCheck = SmartSchedulingEngine.validateRequestedSlot(
          requestedStart: alt,
          durationMinutes: 30,
          weeklyShifts: [testShift],
          leaves: [],
          existingBookedSlots: [],
        );
        expect(altCheck.isAvailable, isTrue);
      }
    });

    test('3. Leave override rejects booking with specific leave reason', () {
      final leaveDateSlot = DateTime(2026, 9, 14, 10, 0); // Monday during annual leave
      final result = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: leaveDateSlot,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [leaveOverride],
        existingBookedSlots: [],
      );

      expect(result.isAvailable, isFalse);
      expect(result.reason, SlotUnavailabilityReason.doctorOnLeave);
      expect(result.humanReadableMessage, contains('Annual Vacation'));
    });

    test('4. Existing booking conflict: overlapping slot is correctly rejected', () {
      final existingBooking = DateTimeRange(
        start: DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 10, 0),
        end: DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 10, 30),
      );

      // Overlapping slot [10:15 - 10:45)
      final overlappingSlot = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 10, 15);
      final result = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: overlappingSlot,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [existingBooking],
      );

      expect(result.isAvailable, isFalse);
      expect(result.reason, SlotUnavailabilityReason.slotAlreadyBooked);
      expect(result.humanReadableMessage, contains('already booked'));
    });

    test('5. Boundary case: booking exactly adjacent to shift start/end and breaks (half-open interval)', () {
      // 5a. Exactly at shift start: [09:00 - 09:30) -> MUST SUCCEED
      final atShiftStart = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 9, 0);
      final resStart = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: atShiftStart,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [],
      );
      expect(resStart.isAvailable, isTrue);

      // 5b. Exactly finishing at shift end: [16:30 - 17:00) -> MUST SUCCEED
      final finishingAtShiftEnd = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 16, 30);
      final resEnd = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: finishingAtShiftEnd,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [],
      );
      expect(resEnd.isAvailable, isTrue);

      // 5c. Starting at shift end: [17:00 - 17:30) -> MUST BE REJECTED (outside shift)
      final startingAtShiftEnd = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 17, 0);
      final resPastEnd = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: startingAtShiftEnd,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [],
      );
      expect(resPastEnd.isAvailable, isFalse);
      expect(resPastEnd.reason, SlotUnavailabilityReason.outsideWorkingHours);

      // 5d. Finishing right when break begins: [12:30 - 13:00) (Break is 13:00 - 14:00) -> MUST SUCCEED
      final upToBreak = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 12, 30);
      final resUpToBreak = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: upToBreak,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [],
      );
      expect(resUpToBreak.isAvailable, isTrue);

      // 5e. Starting right when break ends: [14:00 - 14:30) -> MUST SUCCEED
      final afterBreak = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 14, 0);
      final resAfterBreak = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: afterBreak,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [],
      );
      expect(resAfterBreak.isAvailable, isTrue);

      // 5f. Finishing right when booking starts: [09:30 - 10:00) (Booking is 10:00 - 10:30) -> MUST SUCCEED
      final existingBooking = DateTimeRange(
        start: DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 10, 0),
        end: DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 10, 30),
      );
      final beforeBooking = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 9, 30);
      final resBeforeBooking = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: beforeBooking,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [existingBooking],
      );
      expect(resBeforeBooking.isAvailable, isTrue);

      // 5g. Starting right when booking ends: [10:30 - 11:00) -> MUST SUCCEED
      final afterBooking = DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 10, 30);
      final resAfterBooking = SmartSchedulingEngine.validateRequestedSlot(
        requestedStart: afterBooking,
        durationMinutes: 30,
        weeklyShifts: [testShift],
        leaves: [],
        existingBookedSlots: [existingBooking],
      );
      expect(resAfterBooking.isAvailable, isTrue);
    });

    testWidgets('ReceptionQuickBookingModal UI displays live conflict status, reason, and alternative chips', (tester) async {
      DateTime? confirmedSlot;
      int? confirmedDuration;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReceptionQuickBookingModal(
              doctorId: 'DOC-101',
              doctorName: 'Dr. Tarek Clinic',
              weeklyShifts: [testShift],
              leaves: [leaveOverride],
              selectedDateTimeNotifier: ValueNotifier(DateTime(mondayDate.year, mondayDate.month, mondayDate.day, 10, 0)),
              existingBookings: [],
              onConfirmBooking: (slot, dur) {
                confirmedSlot = slot;
                confirmedDuration = dur;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Quick Booking'), findsOneWidget);
      expect(find.textContaining('Confirm Booking'), findsOneWidget);

      await tester.tap(find.textContaining('Confirm Booking'));
      await tester.pumpAndSettle();

      expect(confirmedSlot, isNotNull);
      expect(confirmedDuration, 20);
    });
  });
}


