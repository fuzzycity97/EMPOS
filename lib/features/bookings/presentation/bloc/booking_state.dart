import 'package:equatable/equatable.dart';
import '../../domain/entities/booking_item.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingLoaded extends BookingState {
  final List<BookingItem> bookings;
  final String? activeResourceId;
  final DateTime? selectedDate;

  const BookingLoaded({
    required this.bookings,
    this.activeResourceId,
    this.selectedDate,
  });

  @override
  List<Object?> get props => [bookings, activeResourceId, selectedDate];
}

class BookingError extends BookingState {
  final String message;

  const BookingError(this.message);

  @override
  List<Object?> get props => [message];
}
