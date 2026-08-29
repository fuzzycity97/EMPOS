import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_item.dart';
import '../repositories/booking_repository.dart';

class SaveBookingUseCase {
  final BookingRepository repository;

  SaveBookingUseCase(this.repository);

  Future<Either<Failure, BookingItem>> call(BookingItem booking) {
    return repository.saveBooking(booking);
  }
}
