import 'package:flutter/material.dart';

enum ShiftRecurrence { weekly, biweekly, custom }

enum SlotUnavailabilityReason {
  outsideWorkingHours,
  doctorOnLeave,
  slotAlreadyBooked,
  breakOrPrayerTime,
  maxDailyCapacityReached,
}

/// Simple Time Range representation within a single day.
class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;
  final String? name; // e.g. 'Lunch Break', 'Prayer Time'

  const TimeRange({
    required this.start,
    required this.end,
    this.name,
  });
}

/// Represents a doctor's configurable working shift on a day of the week.
/// Supports configurable slot duration (15/20/30 min) and break periods.
class DoctorWorkingShift {
  final int dayOfWeek; // 1 (Mon) - 7 (Sun)
  final TimeOfDay startTime;
  final TimeOfDay endTime;
  final int slotDurationMinutes; // e.g. 15, 20, 30 min
  final List<TimeRange> breakTimes; // Lunch, clinic handover, prayer
  final ShiftRecurrence recurrence;

  const DoctorWorkingShift({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.slotDurationMinutes = 20,
    this.breakTimes = const [],
    this.recurrence = ShiftRecurrence.weekly,
  });

  /// Factory helper for creating standard shifts with breaks
  factory DoctorWorkingShift.standard({
    required int dayOfWeek,
    int startHour = 9,
    int startMinute = 0,
    int endHour = 17,
    int endMinute = 0,
    int slotDurationMinutes = 20,
    List<TimeRange>? breakTimes,
  }) {
    return DoctorWorkingShift(
      dayOfWeek: dayOfWeek,
      startTime: TimeOfDay(hour: startHour, minute: startMinute),
      endTime: TimeOfDay(hour: endHour, minute: endMinute),
      slotDurationMinutes: slotDurationMinutes,
      breakTimes: breakTimes ?? const [
        TimeRange(
          start: TimeOfDay(hour: 13, minute: 0),
          end: TimeOfDay(hour: 14, minute: 0),
          name: 'Lunch Break',
        ),
      ],
    );
  }
}

/// Represents an emergency or annual leave override date range for a specific doctor.
class DoctorLeaveOverride {
  final DateTime startDateTime;
  final DateTime endDateTime;
  final String reason; // e.g. 'Annual Leave', 'Emergency Surgery', 'Conference'

  const DoctorLeaveOverride({
    required this.startDateTime,
    required this.endDateTime,
    required this.reason,
  });

  /// Real half-open [start, end) intersection with leave window [startDateTime, endDateTime).
  bool intersects(DateTime start, DateTime end) =>
      start.isBefore(endDateTime) && end.isAfter(startDateTime);

  /// Point-in-time check.
  bool covers(DateTime target) =>
      (target.isAfter(startDateTime) || target.isAtSameMomentAs(startDateTime)) &&
      target.isBefore(endDateTime);
}

/// Encapsulates slot validation result with detailed reason and alternatives.
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
