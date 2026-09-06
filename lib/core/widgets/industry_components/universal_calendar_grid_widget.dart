import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../features/bookings/domain/entities/booking_item.dart';
import '../../../features/clinic/domain/entities/doctor_roster.dart';

/// Professional, cross-platform timetable grid for clinic rosters and appointments.
/// Synchronizes horizontal and vertical scrolling flawlessly without misalignment.
/// 100% [StatelessWidget].
class UniversalCalendarGridWidget extends StatelessWidget {
  final List<BookingItem> bookings;
  final DateTime selectedDate;
  final List<DoctorRoster>? doctors;
  final List<String>? resources;
  final void Function(DoctorRoster doctor, DateTime timeSlot)? onDoctorSlotSelected;
  final void Function(String resourceId, DateTime timeSlot)? onSlotSelected;
  final void Function(BookingItem booking)? onBookingTapped;

  const UniversalCalendarGridWidget({
    super.key,
    required this.bookings,
    required this.selectedDate,
    this.doctors,
    this.resources,
    this.onDoctorSlotSelected,
    this.onSlotSelected,
    this.onBookingTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Resolve list of doctors or convert resources to DoctorRoster
    final List<DoctorRoster> resolvedDoctors;
    if (doctors != null && doctors!.isNotEmpty) {
      resolvedDoctors = doctors!;
    } else if (resources != null && resources!.isNotEmpty) {
      resolvedDoctors = resources!.map((r) => DoctorRoster(
        id: r,
        doctorId: r,
        doctorName: r,
        specialty: 'Specialist / Provider',
        roomName: 'Suite',
        workingDays: const [1, 2, 3, 4, 5, 6, 7],
        shiftStartHour: 8,
        shiftEndHour: 20,
      )).toList();
    } else {
      resolvedDoctors = DoctorRoster.defaultRosters;
    }

    final activeDoctors = resolvedDoctors.where((d) => d.isActive).toList();
    final List<DoctorRoster> displayDoctors = activeDoctors.isNotEmpty ? activeDoctors : resolvedDoctors;

    // Calculate earliest start and latest end hour across scheduled doctors
    int minHour = 8;
    int maxHour = 20;
    if (displayDoctors.isNotEmpty) {
      final starts = displayDoctors.map((d) => d.shiftStartHour).toList();
      final ends = displayDoctors.map((d) => d.shiftEndHour).toList();
      minHour = starts.reduce((a, b) => a < b ? a : b);
      maxHour = ends.reduce((a, b) => a > b ? a : b);
    }
    if (maxHour <= minHour) maxHour = minHour + 8;
    final totalHours = (maxHour - minHour).clamp(6, 16);
    final hours = List.generate(totalHours, (i) => i + minHour);

    const double timeColWidth = 70.0;
    const double doctorColWidth = 220.0;
    const double rowHeight = 64.0;
    const double headerHeight = 76.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final totalTableWidth = timeColWidth + (displayDoctors.length * doctorColWidth);

        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE2E8F0)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: SizedBox(
                  width: totalTableWidth < constraints.maxWidth ? constraints.maxWidth : totalTableWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row: Time spacer + Doctor Cards
                      Container(
                        height: headerHeight,
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                          border: Border(
                            bottom: BorderSide(
                              color: isDark ? Colors.white12 : const Color(0xFFE2E8F0),
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Top-Left Corner (Time header)
                            SizedBox(
                              width: timeColWidth,
                              child: Center(
                                child: Icon(
                                  LucideIcons.clock,
                                  size: 18,
                                  color: isDark ? Colors.white54 : Colors.black45,
                                ),
                              ),
                            ),
                            // Doctor columns
                            ...displayDoctors.map((doc) {
                              final isWorkingToday = doc.isWorkingOn(selectedDate);
                              final docColor = _parseColor(doc.colorHex);

                              return Container(
                                width: doctorColWidth,
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    left: BorderSide(
                                      color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: docColor.withValues(alpha: 0.2),
                                      child: Text(
                                        doc.doctorName.isNotEmpty
                                            ? doc.doctorName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join()
                                            : 'DR',
                                        style: TextStyle(
                                          color: docColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            doc.doctorName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Row(
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  doc.specialty,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark ? Colors.white60 : Colors.black54,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: (isWorkingToday ? Colors.teal : Colors.grey).withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  isWorkingToday ? doc.roomName : 'Off-day',
                                                  style: TextStyle(
                                                    fontSize: 9,
                                                    fontWeight: FontWeight.bold,
                                                    color: isWorkingToday ? Colors.teal : Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      // Time Slot Rows
                      ...hours.map((hour) {
                        final slotTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          hour,
                          0,
                        );

                        return Container(
                          height: rowHeight,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFFF1F5F9),
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              // Hour Label
                              SizedBox(
                                width: timeColWidth,
                                child: Center(
                                  child: Text(
                                    '${hour.toString().padLeft(2, '0')}:00',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.white54 : Colors.black54,
                                    ),
                                  ),
                                ),
                              ),

                              // Doctor Cells for this hour
                              ...displayDoctors.map((doc) {
                                final isWithinShift = hour >= doc.shiftStartHour && hour < doc.shiftEndHour;
                                final isWorkingToday = doc.isWorkingOn(selectedDate);
                                final isShiftActive = isWithinShift && isWorkingToday;

                                final slotEnd = slotTime.add(const Duration(hours: 1));

                                // Find matching active booking for this doctor & slot
                                BookingItem? activeBooking;
                                for (final b in bookings) {
                                  if ((b.resourceId.toLowerCase() == doc.id.toLowerCase() ||
                                          b.resourceName.toLowerCase() == doc.doctorName.toLowerCase()) &&
                                      b.isActive &&
                                      b.overlapsWith(slotTime, slotEnd)) {
                                    activeBooking = b;
                                    break;
                                  }
                                }

                                return Container(
                                  width: doctorColWidth,
                                  height: rowHeight,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: !isShiftActive
                                        ? (isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0xFFF8FAFC))
                                        : Colors.transparent,
                                    border: Border(
                                      left: BorderSide(
                                        color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF1F5F9),
                                      ),
                                    ),
                                  ),
                                  child: _buildSlotCell(
                                    context: context,
                                    isDark: isDark,
                                    isShiftActive: isShiftActive,
                                    doctor: doc,
                                    slotTime: slotTime,
                                    booking: activeBooking,
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlotCell({
    required BuildContext context,
    required bool isDark,
    required bool isShiftActive,
    required DoctorRoster doctor,
    required DateTime slotTime,
    required BookingItem? booking,
  }) {
    if (booking != null) {
      final statusColor = _getStatusColor(booking.status);

      return Material(
        color: statusColor.withValues(alpha: isDark ? 0.2 : 0.12),
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () => onBookingTapped?.call(booking),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: statusColor.withValues(alpha: 0.6), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        booking.customerName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  booking.serviceName,
                  style: TextStyle(
                    fontSize: 10,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!isShiftActive) {
      return Center(
        child: Text(
          '-',
          style: TextStyle(
            color: isDark ? Colors.white12 : Colors.black12,
            fontSize: 14,
          ),
        ),
      );
    }

    // Available slot to book
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (onDoctorSlotSelected != null) {
            onDoctorSlotSelected!.call(doctor, slotTime);
          } else {
            onSlotSelected?.call(doctor.id, slotTime);
          }
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: _parseColor(doctor.colorHex).withValues(alpha: 0.1),
        child: Center(
          child: Icon(
            LucideIcons.plusCircle,
            size: 16,
            color: isDark ? Colors.white24 : Colors.black26,
          ),
        ),
      ),
    );
  }

  static Color _parseColor(String hex) {
    try {
      final clean = hex.replaceAll('#', '');
      return Color(int.parse('FF$clean', radix: 16));
    } catch (_) {
      return const Color(0xFF3B82F6);
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.amber;
      case BookingStatus.confirmed:
        return Colors.blue;
      case BookingStatus.checkedIn:
        return Colors.teal;
      case BookingStatus.completed:
        return Colors.green;
      case BookingStatus.cancelled:
        return Colors.redAccent;
    }
  }
}
