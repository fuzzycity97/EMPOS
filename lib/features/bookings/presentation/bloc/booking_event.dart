import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_item.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadBookingsEvent extends BookingEvent {
  final String? resourceId;
  final DateTime? date;
  final String? customerId;

  const LoadBookingsEvent({this.resourceId, this.date, this.customerId});

  @override
  List<Object?> get props => [resourceId, date, customerId];
}

class CreateBookingEvent extends BookingEvent {
  final BookingItem booking;

  const CreateBookingEvent(this.booking);

  @override
  List<Object?> get props => [booking];
}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;

  const CancelBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
