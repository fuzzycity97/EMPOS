import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../domain/models/doctor_schedule_models.dart';
import '../domain/services/smart_scheduling_engine.dart';

/// Interactive Reception Quick Call & Booking Assistant Modal.
/// 100% [StatelessWidget] architecture.
class ReceptionQuickBookingModal extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  final List<DoctorWorkingShift> weeklyShifts;
  final List<DoctorLeaveOverride> leaves;
  final List<DateTimeRange> existingBookings;
  final ValueNotifier<DateTime> selectedDateTimeNotifier;
  final ValueNotifier<int> durationMinutesNotifier;
  final ValueNotifier<SmartSlotValidationResult> validationNotifier;
  final void Function(DateTime slot, int duration)? onConfirmBooking;

  ReceptionQuickBookingModal({
    super.key,
    required this.doctorId,
    required this.doctorName,
    List<DoctorWorkingShift>? weeklyShifts,
    List<DoctorLeaveOverride>? leaves,
    List<DateTimeRange>? existingBookings,
    ValueNotifier<DateTime>? selectedDateTimeNotifier,
    ValueNotifier<int>? durationMinutesNotifier,
    ValueNotifier<SmartSlotValidationResult>? validationNotifier,
    this.onConfirmBooking,
  })  : weeklyShifts = weeklyShifts ?? _defaultShifts,
        leaves = leaves ?? [],
        existingBookings = existingBookings ?? _defaultBookings,
        selectedDateTimeNotifier = selectedDateTimeNotifier ?? ValueNotifier<DateTime>(_initialSlot()),
        durationMinutesNotifier = durationMinutesNotifier ?? ValueNotifier<int>(20),
        validationNotifier = validationNotifier ?? ValueNotifier<SmartSlotValidationResult>(_initialValidation(selectedDateTimeNotifier?.value ?? _initialSlot(), durationMinutesNotifier?.value ?? 20, weeklyShifts ?? _defaultShifts, leaves ?? [], existingBookings ?? _defaultBookings));

  static DateTime _initialSlot() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 10, 0);
  }

  static SmartSlotValidationResult _initialValidation(
    DateTime slot,
    int duration,
    List<DoctorWorkingShift> shifts,
    List<DoctorLeaveOverride> leaves,
    List<DateTimeRange> bookings,
  ) {
    return SmartSchedulingEngine.validateRequestedSlot(
      requestedStart: slot,
      durationMinutes: duration,
      weeklyShifts: shifts,
      leaves: leaves,
      existingBookedSlots: bookings,
    );
  }

  static final List<DoctorWorkingShift> _defaultShifts = [
    const DoctorWorkingShift(
      dayOfWeek: DateTime.monday,
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 17, minute: 0),
      breakTimes: [TimeRange(start: TimeOfDay(hour: 13, minute: 0), end: TimeOfDay(hour: 14, minute: 0))],
    ),
    const DoctorWorkingShift(
      dayOfWeek: DateTime.tuesday,
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 17, minute: 0),
    ),
    const DoctorWorkingShift(
      dayOfWeek: DateTime.wednesday,
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 17, minute: 0),
    ),
    const DoctorWorkingShift(
      dayOfWeek: DateTime.thursday,
      startTime: TimeOfDay(hour: 9, minute: 0),
      endTime: TimeOfDay(hour: 17, minute: 0),
    ),
    const DoctorWorkingShift(
      dayOfWeek: DateTime.saturday,
      startTime: TimeOfDay(hour: 10, minute: 0),
      endTime: TimeOfDay(hour: 15, minute: 0),
    ),
    const DoctorWorkingShift(
      dayOfWeek: DateTime.sunday,
      startTime: TimeOfDay(hour: 10, minute: 0),
      endTime: TimeOfDay(hour: 15, minute: 0),
    ),
  ];

  static final List<DateTimeRange> _defaultBookings = [
    DateTimeRange(
      start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 10, 30),
      end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 0),
    ),
    DateTimeRange(
      start: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 11, 30),
      end: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 12, 0),
    ),
  ];

  void _revalidate(DateTime newSlot, int duration) {
    selectedDateTimeNotifier.value = newSlot;
    durationMinutesNotifier.value = duration;
    validationNotifier.value = SmartSchedulingEngine.validateRequestedSlot(
      requestedStart: newSlot,
      durationMinutes: duration,
      weeklyShifts: weeklyShifts,
      leaves: leaves,
      existingBookedSlots: existingBookings,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090D16) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(LucideIcons.calendarCheck, size: 20, color: AppColors.primaryLight),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quick Booking â€¢ $doctorName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text('Phone Reception Fast-Booking & Conflict Guard', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark)),
                    ],
                  ),
                ],
              ),
              IconButton(icon: const Icon(LucideIcons.x, size: 18), onPressed: () => Navigator.of(context).pop()),
            ],
          ),
          const Divider(height: 20),

          // â”€â”€ Slot Status Pill (Green / Red) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          ValueListenableBuilder<SmartSlotValidationResult>(
            valueListenable: validationNotifier,
            builder: (context, val, _) {
              final isAvail = val.isAvailable;
              final color = isAvail ? AppColors.success : AppColors.danger;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(color: color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(isAvail ? LucideIcons.checkCircle : LucideIcons.alertTriangle, size: 18, color: color),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAvail ? 'Slot Confirmed Available' : 'Slot Unavailable',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: color),
                          ),
                          Text(val.humanReadableMessage, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // â”€â”€ Alternative Slot Quick-Chips â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          ValueListenableBuilder<SmartSlotValidationResult>(
            valueListenable: validationNotifier,
            builder: (context, val, _) {
              if (val.isAvailable || val.nearestAlternativeSlots.isEmpty) {
                return const SizedBox.shrink();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nearest Available Alternatives (1-Tap):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: val.nearestAlternativeSlots.map((alt) {
                      final str = DateFormat('E, MMM d â€¢ HH:mm').format(alt);
                      return ActionChip(
                        avatar: const Icon(LucideIcons.clock, size: 14, color: AppColors.primaryLight),
                        label: Text(str, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        onPressed: () => _revalidate(alt, durationMinutesNotifier.value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                ],
              );
            },
          ),

          // â”€â”€ Booking Confirmation Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          ValueListenableBuilder<SmartSlotValidationResult>(
            valueListenable: validationNotifier,
            builder: (context, val, _) {
              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: val.isAvailable ? AppColors.success : Colors.grey,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('Confirm Booking & Send WhatsApp Notification', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: val.isAvailable
                          ? () {
                              onConfirmBooking?.call(selectedDateTimeNotifier.value, durationMinutesNotifier.value);
                              Navigator.of(context).pop();
                            }
                          : null,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

