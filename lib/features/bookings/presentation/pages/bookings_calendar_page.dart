import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/industry_components/universal_calendar_grid_widget.dart';
import '../../domain/entities/booking_item.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';

class BookingsCalendarPage extends StatelessWidget {
  final BookingBloc? bloc;

  const BookingsCalendarPage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    final bookingBloc = bloc ?? context.read<BookingBloc>();
    final selectedDateNotifier = ValueNotifier<DateTime>(DateTime.now());

    final resources = const [
      'Resource Bay 1',
      'Resource Bay 2',
      'Specialist Suite A',
      'VIP Lounge 1',
    ];

    return BlocBuilder<BookingBloc, BookingState>(
      bloc: bookingBloc,
      builder: (context, state) {
        if (state is BookingInitial || state is BookingLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is BookingError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => bookingBloc.add(const LoadBookingsEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final loaded = state as BookingLoaded;

        return ValueListenableBuilder<DateTime>(
          valueListenable: selectedDateNotifier,
          builder: (context, selectedDate, _) {
            return Scaffold(
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Action Header & Date Navigator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: Border(
                        bottom: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.calendar_month, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 8),
                            Text(
                              'Universal Bookings & Calendar (${loaded.bookings.length} Scheduled)',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left),
                              onPressed: () {
                                final prev = selectedDate.subtract(const Duration(days: 1));
                                selectedDateNotifier.value = prev;
                                bookingBloc.add(LoadBookingsEvent(date: prev));
                              },
                            ),
                            Text(
                              '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right),
                              onPressed: () {
                                final next = selectedDate.add(const Duration(days: 1));
                                selectedDateNotifier.value = next;
                                bookingBloc.add(LoadBookingsEvent(date: next));
                              },
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              onPressed: () => _showCreateBookingDialog(
                                context,
                                bookingBloc,
                                selectedDate,
                                resources.first,
                              ),
                              icon: const Icon(Icons.add),
                              label: const Text('Book Appointment'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Calendar Grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: UniversalCalendarGridWidget(
                        bookings: loaded.bookings,
                        selectedDate: selectedDate,
                        resources: resources,
                        onSlotSelected: (resourceId, slotTime) {
                          _showCreateBookingDialog(context, bookingBloc, slotTime, resourceId);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showCreateBookingDialog(
    BuildContext context,
    BookingBloc bloc,
    DateTime startTime,
    String initialResource,
  ) {
    final customerController = TextEditingController();
    final serviceController = TextEditingController(text: 'General Service');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Schedule New Booking Slot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: 'Customer / Guest Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: serviceController,
                decoration: const InputDecoration(labelText: 'Service Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              Text(
                'Slot: ${startTime.hour}:00 - ${startTime.hour + 1}:00 on $initialResource',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final cust = customerController.text.trim();
                final srv = serviceController.text.trim();
                if (cust.isEmpty) return;

                bloc.add(
                  CreateBookingEvent(
                    BookingItem(
                      id: 'book_${DateTime.now().millisecondsSinceEpoch}',
                      customerOrPatientId: 'c_${DateTime.now().millisecondsSinceEpoch}',
                      customerName: cust,
                      resourceId: initialResource,
                      resourceName: initialResource,
                      serviceName: srv.isNotEmpty ? srv : 'Standard Appointment',
                      startTime: startTime,
                      endTime: startTime.add(const Duration(hours: 1)),
                      createdAt: DateTime.now(),
                    ),
                  ),
                );

                Navigator.of(ctx).pop();
              },
              child: const Text('Confirm Booking'),
            ),
          ],
        );
      },
    );
  }
}
