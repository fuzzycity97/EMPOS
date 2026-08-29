import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/booking_item.dart';

abstract class BookingRepository {
  Future<Either<Failure, List<BookingItem>>> getBookings({
    String? resourceId,
    DateTime? date,
    String? customerId,
  });

  Future<Either<Failure, BookingItem>> saveBooking(BookingItem booking);

  Future<Either<Failure, BookingItem>> cancelBooking(String bookingId);

  /// Checks if resource is free for the given time slot (returns true if available, false if conflict)
  Future<Either<Failure, bool>> checkAvailability(
    String resourceId,
    DateTime startTime,
    DateTime endTime, {
    String? excludeBookingId,
  });
}
