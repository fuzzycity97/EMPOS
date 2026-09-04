import 'package:flutter/material.dart';
import '../models/doctor_schedule_models.dart';

class SmartSchedulingEngine {
  /// Evaluates requested appointment slot [requestedStart, requestedEnd) in O(1)
  /// against doctor weekly shift, breaks, leave overrides, and existing bookings
  /// using rigorous half-open interval intersection math.
  static SmartSlotValidationResult validateRequestedSlot({
    required DateTime requestedStart,
    required int durationMinutes,
    required List<DoctorWorkingShift> weeklyShifts,
    required List<DoctorLeaveOverride> leaves,
    required List<DateTimeRange> existingBookedSlots,
    bool computeAlternatives = true,
  }) {
    final requestedEnd = requestedStart.add(Duration(minutes: durationMinutes));

    List<DateTime> getAlternatives() {
      if (!computeAlternatives) return const [];
      return findNextAvailableSlots(
        from: requestedStart,
        durationMinutes: durationMinutes,
        weeklyShifts: weeklyShifts,
        leaves: leaves,
        existingBookedSlots: existingBookedSlots,
      );
    }

    // 1. Check Doctor Leaves / Emergency Absences via half-open interval intersection
    for (final leave in leaves) {
      if (leave.intersects(requestedStart, requestedEnd)) {
        return SmartSlotValidationResult(
          isAvailable: false,
          reason: SlotUnavailabilityReason.doctorOnLeave,
          humanReadableMessage: 'Doctor is unavailable due to: ${leave.reason}',
          nearestAlternativeSlots: getAlternatives(),
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
        nearestAlternativeSlots: getAlternatives(),
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

    // Boundary check: [requestedStart, requestedEnd) must be subset of [shiftStart, shiftEnd)
    if (requestedStart.isBefore(shiftStart) || requestedEnd.isAfter(shiftEnd)) {
      final startStr = '${dayShift.startTime.hour.toString().padLeft(2, "0")}:${dayShift.startTime.minute.toString().padLeft(2, "0")}';
      final endStr = '${dayShift.endTime.hour.toString().padLeft(2, "0")}:${dayShift.endTime.minute.toString().padLeft(2, "0")}';
      return SmartSlotValidationResult(
        isAvailable: false,
        reason: SlotUnavailabilityReason.outsideWorkingHours,
        humanReadableMessage: 'Requested time is outside doctor shift hours ($startStr - $endStr).',
        nearestAlternativeSlots: getAlternatives(),
      );
    }

    // 3. Check Scheduled Break Times via half-open interval intersection
    for (final b in dayShift.breakTimes) {
      final breakStart = DateTime(requestedStart.year, requestedStart.month, requestedStart.day, b.start.hour, b.start.minute);
      final breakEnd = DateTime(requestedStart.year, requestedStart.month, requestedStart.day, b.end.hour, b.end.minute);
      if (requestedStart.isBefore(breakEnd) && requestedEnd.isAfter(breakStart)) {
        final breakLabel = b.name ?? 'clinic break / prayer time';
        return SmartSlotValidationResult(
          isAvailable: false,
          reason: SlotUnavailabilityReason.breakOrPrayerTime,
          humanReadableMessage: 'Requested slot intersects with scheduled $breakLabel.',
          nearestAlternativeSlots: getAlternatives(),
        );
      }
    }

    // 4. Check Intersecting Existing Bookings via half-open interval intersection
    for (final booked in existingBookedSlots) {
      if (requestedStart.isBefore(booked.end) && requestedEnd.isAfter(booked.start)) {
        return SmartSlotValidationResult(
          isAvailable: false,
          reason: SlotUnavailabilityReason.slotAlreadyBooked,
          humanReadableMessage: 'Slot is already booked for another patient.',
          nearestAlternativeSlots: getAlternatives(),
        );
      }
    }

    return const SmartSlotValidationResult(
      isAvailable: true,
      humanReadableMessage: 'Slot is available for booking.',
    );
  }

  /// Forward-scanning function that returns the next [count] (default 3) valid available slots
  /// after a requested time, for use when the requested slot conflicts.
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
        computeAlternatives: false,
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
