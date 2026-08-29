import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_item.dart';
import '../repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<Either<Failure, BookingItem>> call(String bookingId) {
    return repository.cancelBooking(bookingId);
  }
}
