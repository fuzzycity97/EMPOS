import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/booking_repository.dart';

class CheckAvailabilityUseCase {
  final BookingRepository repository;

  CheckAvailabilityUseCase(this.repository);

  Future<Either<Failure, bool>> call(
    String resourceId,
    DateTime startTime,
    DateTime endTime, {
    String? excludeBookingId,
  }) {
    return repository.checkAvailability(
      resourceId,
      startTime,
      endTime,
      excludeBookingId: excludeBookingId,
    );
  }
}
