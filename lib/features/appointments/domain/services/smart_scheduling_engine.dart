import 'package:flutter/material.dart';
import '../entities/doctor_schedule_models.dart';

class SmartSchedulingEngine {
  /// Evaluates requested appointment slot in O(1) against roster & active bookings
  static SmartSlotValidationResult validateRequestedSlot({
    required DateTime requestedStart,
    required int durationMinutes,
    required List<DoctorWorkingShift> weeklyShifts,
    required List<DoctorLeaveOverride> leaves,
    required List<DateTimeRange> existingBookedSlots,
  }) {
    final requestedEnd = requestedStart.add(Duration(minutes: durationMinutes));

    // 1. Check Doctor Leaves / Emergency Absences
    for (final leave in leaves) {
      if (leave.covers(requestedStart) || leave.covers(requestedEnd)) {
        return SmartSlotValidationResult(
          isAvailable: false,
          reason: SlotUnavailabilityReason.doctorOnLeave,
          humanReadableMessage: 'Doctor is unavailable: ${leave.reason}',
          nearestAlternativeSlots: findNextAvailableSlots(
            from: requestedStart,
            durationMinutes: durationMinutes,
            weeklyShifts: weeklyShifts,
            leaves: leaves,
            existingBookedSlots: existingBookedSlots,
          ),
        );
      }
    }

    // 2. Check Doctor Weekly Working Shifts
    DoctorWorkingShift? dayShift;
    try {
      dayShift = weeklyShifts.firstWhere((s) => s.dayOfWeek == requestedStart.weekday);
    } catch (_) {
      dayShift = null;
    }

    if (dayShift == null) {
      return SmartSlotValidationResult(
        isAvailable: false,
        reason: SlotUnavailabilityReason.outsideWorkingHours,
        humanReadableMessage: 'Doctor does not work on this day of the week.',
        nearestAlternativeSlots: findNextAvailableSlots(
          from: requestedStart,
          durationMinutes: durationMinutes,
          weeklyShifts: weeklyShifts,
          leaves: leaves,
          existingBookedSlots: existingBookedSlots,
        ),
      );
    }

    final shiftStart = DateTime(
      requestedStart.year,
      requestedStart.month,
      requestedStart.day,
      dayShift.startTime.hour,
      dayShift.startTime.minute,
    );
    final shiftEnd = DateTime(
      requestedStart.year,
      requestedStart.month,
      requestedStart.day,
      dayShift.endTime.hour,
      dayShift.endTime.minute,
    );

    if (requestedStart.isBefore(shiftStart) || requestedEnd.isAfter(shiftEnd)) {
      final startStr = '${dayShift.startTime.hour.toString().padLeft(2, '0')}:${dayShift.startTime.minute.toString().padLeft(2, '0')}';
      final endStr = '${dayShift.endTime.hour.toString().padLeft(2, '0')}:${dayShift.endTime.minute.toString().padLeft(2, '0')}';
      return SmartSlotValidationResult(
        isAvailable: false,
        reason: SlotUnavailabilityReason.outsideWorkingHours,
        humanReadableMessage: 'Requested time is outside working shift ($startStr - $endStr).',
        nearestAlternativeSlots: findNextAvailableSlots(
          from: requestedStart,
          durationMinutes: durationMinutes,
          weeklyShifts: weeklyShifts,
          leaves: leaves,
          existingBookedSlots: existingBookedSlots,
        ),
      );
    }

    // 3. Check Breaks
    for (final b in dayShift.breakTimes) {
      final breakStart = DateTime(requestedStart.year, requestedStart.month, requestedStart.day, b.start.hour, b.start.minute);
      final breakEnd = DateTime(requestedStart.year, requestedStart.month, requestedStart.day, b.end.hour, b.end.minute);
      if (requestedStart.isBefore(breakEnd) && requestedEnd.isAfter(breakStart)) {
        return SmartSlotValidationResult(
          isAvailable: false,
          reason: SlotUnavailabilityReason.breakOrPrayerTime,
          humanReadableMessage: 'Time intersects with scheduled clinic break / prayer time.',
          nearestAlternativeSlots: findNextAvailableSlots(
            from: requestedStart,
            durationMinutes: durationMinutes,
            weeklyShifts: weeklyShifts,
            leaves: leaves,
            existingBookedSlots: existingBookedSlots,
          ),
        );
      }
    }

    // 4. Check Intersecting Appointments
    for (final booked in existingBookedSlots) {
      if (requestedStart.isBefore(booked.end) && requestedEnd.isAfter(booked.start)) {
        return SmartSlotValidationResult(
          isAvailable: false,
          reason: SlotUnavailabilityReason.slotAlreadyBooked,
          humanReadableMessage: 'Slot is already booked for another patient.',
          nearestAlternativeSlots: findNextAvailableSlots(
            from: requestedStart,
            durationMinutes: durationMinutes,
            weeklyShifts: weeklyShifts,
            leaves: leaves,
            existingBookedSlots: existingBookedSlots,
          ),
        );
      }
    }

    return const SmartSlotValidationResult(
      isAvailable: true,
      humanReadableMessage: 'Slot is available for booking.',
    );
  }

  /// Iterates forward to provide 3 closest alternative available slots
  static List<DateTime> findNextAvailableSlots({
    required DateTime from,
    required int durationMinutes,
    required List<DoctorWorkingShift> weeklyShifts,
    required List<DoctorLeaveOverride> leaves,
    required List<DateTimeRange> existingBookedSlots,
    int count = 3,
  }) {
    final List<DateTime> alternatives = [];
    var testTime = from.add(Duration(minutes: durationMinutes));

    for (int i = 0; i < 7 * 24 * 4 && alternatives.length < count; i++) {
      final res = validateRequestedSlot(
        requestedStart: testTime,
        durationMinutes: durationMinutes,
        weeklyShifts: weeklyShifts,
        leaves: leaves,
        existingBookedSlots: existingBookedSlots,
      );
      if (res.isAvailable) {
        alternatives.add(testTime);
        testTime = testTime.add(Duration(minutes: durationMinutes));
      } else {
        testTime = testTime.add(const Duration(minutes: 15));
      }
    }
    return alternatives;
  }
}
