import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/usecases/get_bookings_usecase.dart';
import '../../domain/usecases/save_booking_usecase.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final GetBookingsUseCase getBookingsUseCase;
  final SaveBookingUseCase saveBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;

  BookingBloc({
    required this.getBookingsUseCase,
    required this.saveBookingUseCase,
    required this.cancelBookingUseCase,
  }) : super(BookingInitial()) {
    on<LoadBookingsEvent>(_onLoadBookings);
    on<CreateBookingEvent>(_onCreateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
  }

  Future<void> _onLoadBookings(
    LoadBookingsEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final result = await getBookingsUseCase(
      resourceId: event.resourceId,
      date: event.date,
      customerId: event.customerId,
    );

    result.fold(
      (failure) => emit(BookingError(failure.message)),
      (bookings) => emit(
        BookingLoaded(
          bookings: bookings,
          activeResourceId: event.resourceId,
          selectedDate: event.date,
        ),
      ),
    );
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    final result = await saveBookingUseCase(event.booking);

    await result.fold(
      (failure) async => emit(BookingError(failure.message)),
      (_) async {
        // Refresh bookings for the same resource and day
        final refresh = await getBookingsUseCase(
          resourceId: event.booking.resourceId,
          date: event.booking.startTime,
        );
        refresh.fold(
          (failure) => emit(BookingError(failure.message)),
          (bookings) => emit(
            BookingLoaded(
              bookings: bookings,
              activeResourceId: event.booking.resourceId,
              selectedDate: event.booking.startTime,
            ),
          ),
        );
      },
    );
  }

  Future<void> _onCancelBooking(
    CancelBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    final currentState = state;
    emit(BookingLoading());
    final result = await cancelBookingUseCase(event.bookingId);

    await result.fold(
      (failure) async => emit(BookingError(failure.message)),
      (cancelled) async {
        final resId = currentState is BookingLoaded ? currentState.activeResourceId : null;
        final date = currentState is BookingLoaded ? currentState.selectedDate : null;

        final refresh = await getBookingsUseCase(resourceId: resId, date: date);
        refresh.fold(
          (failure) => emit(BookingError(failure.message)),
          (bookings) => emit(
            BookingLoaded(
              bookings: bookings,
              activeResourceId: resId,
              selectedDate: date,
            ),
          ),
        );
      },
    );
  }
}
