import 'package:flutter/material.dart';
import '../../../features/bookings/domain/entities/booking_item.dart';

class UniversalCalendarGridWidget extends StatelessWidget {
  final List<BookingItem> bookings;
  final DateTime selectedDate;
  final List<String> resources;
  final void Function(String resourceId, DateTime timeSlot)? onSlotSelected;
  final void Function(BookingItem booking)? onBookingTapped;

  const UniversalCalendarGridWidget({
    super.key,
    required this.bookings,
    required this.selectedDate,
    required this.resources,
    this.onSlotSelected,
    this.onBookingTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hours = List.generate(12, (i) => i + 8); // 08:00 to 19:00

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Resource Headers
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    const SizedBox(width: 70), // Time column spacer
                    ...resources.map((res) {
                      return Container(
                        width: 180,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          res,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Time Grid Rows
              ...hours.map((hour) {
                final slotTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  hour,
                  0,
                );

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hour Label
                    SizedBox(
                      width: 70,
                      height: 60,
                      child: Center(
                        child: Text(
                          '${hour.toString().padLeft(2, '0')}:00',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Resource Slots for this hour
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: resources.map((res) {
                            final slotEnd = slotTime.add(const Duration(hours: 1));
                            final activeBooking = bookings.cast<BookingItem?>().firstWhere(
                                  (b) =>
                                      b != null &&
                                      b.resourceId.toLowerCase() == res.toLowerCase() &&
                                      b.isActive &&
                                      b.overlapsWith(slotTime, slotEnd),
                                  orElse: () => null,
                                );

                            return Container(
                              width: 180,
                              height: 56,
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: activeBooking != null
                                    ? _getStatusColor(activeBooking.status).withValues(alpha: 0.15)
                                    : (isDark ? const Color(0xFF0F172A) : Colors.white),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: activeBooking != null
                                      ? _getStatusColor(activeBooking.status)
                                      : (isDark ? Colors.white10 : Colors.black12),
                                ),
                              ),
                              child: InkWell(
                                onTap: () {
                                  if (activeBooking != null) {
                                    onBookingTapped?.call(activeBooking);
                                  } else {
                                    onSlotSelected?.call(res, slotTime);
                                  }
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(6),
                                  child: activeBooking != null
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              activeBooking.customerName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: _getStatusColor(activeBooking.status),
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              activeBooking.serviceName,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDark ? Colors.white70 : Colors.black87,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        )
                                      : Center(
                                          child: Icon(
                                            Icons.add_circle_outline,
                                            size: 16,
                                            color: isDark ? Colors.white24 : Colors.black26,
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        );
      },
    );
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
        return Colors.red;
    }
  }
}
