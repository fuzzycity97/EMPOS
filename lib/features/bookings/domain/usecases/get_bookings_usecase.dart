import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_item.dart';
import '../repositories/booking_repository.dart';

class GetBookingsUseCase {
  final BookingRepository repository;

  GetBookingsUseCase(this.repository);

  Future<Either<Failure, List<BookingItem>>> call({
    String? resourceId,
    DateTime? date,
    String? customerId,
  }) {
    return repository.getBookings(
      resourceId: resourceId,
      date: date,
      customerId: customerId,
    );
  }
}
