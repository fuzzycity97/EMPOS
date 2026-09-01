import 'package:flutter/material.dart';

enum ShiftRecurrence { weekly, biweekly, custom }

enum SlotUnavailabilityReason {
  outsideWorkingHours,
  doctorOnLeave,
  slotAlreadyBooked,
  breakOrPrayerTime,
  maxDailyCapacityReached,
}

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  const TimeRange({required this.start, required this.end});
}

class DoctorWorkingShift {
  final int dayOfWeek; // 1 (Mon) - 7 (Sun)
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int slotDurationMinutes; // e.g. 15, 20, 30 min
  final List<TimeRange> breakTimes; // Lunch, clinic handover

  const DoctorWorkingShift({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.slotDurationMinutes = 20,
    this.breakTimes = const [],
  });
}

class DoctorLeaveOverride {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String reason; // "Conference", "Annual Leave", "Emergency Surgery"

  const DoctorLeaveOverride({
    required this.startDateTime,
    required this.endDateTime,
    required this.reason,
  });

  bool covers(DateTime target) =>
      target.isAfter(startDateTime.subtract(const Duration(seconds: 1))) &&
      target.isBefore(endDateTime.add(const Duration(seconds: 1)));
}

class SmartSlotValidationResult {
  final bool isAvailable;
  final SlotUnavailabilityReason? reason;
  final String humanReadableMessage;
  final List<DateTime> nearestAlternativeSlots;

  const SmartSlotValidationResult({
    required this.isAvailable,
    this.reason,
    required this.humanReadableMessage,
    this.nearestAlternativeSlots = const [],
  });
}
