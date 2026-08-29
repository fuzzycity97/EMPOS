import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/booking_item.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_data_source.dart';
import '../models/booking_item_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDataSource localDataSource;

  BookingRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<BookingItem>>> getBookings({
    String? resourceId,
    DateTime? date,
    String? customerId,
  }) async {
    try {
      final all = await localDataSource.getBookings();
      var filtered = all.where((b) {
        if (resourceId != null && resourceId.isNotEmpty && b.resourceId != resourceId) {
          return false;
        }
        if (customerId != null && customerId.isNotEmpty && b.customerOrPatientId != customerId) {
          return false;
        }
        if (date != null) {
          final isSameDay = b.startTime.year == date.year &&
              b.startTime.month == date.month &&
              b.startTime.day == date.day;
          if (!isSameDay) return false;
        }
        return true;
      }).toList();

      filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
      return Right(filtered);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error fetching bookings: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingItem>> saveBooking(BookingItem booking) async {
    try {
      // Check availability for new/active bookings
      if (booking.isActive) {
        final availResult = await checkAvailability(
          booking.resourceId,
          booking.startTime,
          booking.endTime,
          excludeBookingId: booking.id,
        );

        final isAvailable = availResult.getOrElse(() => false);
        if (!isAvailable) {
          return const Left(
            ValidationFailure(message: 'Selected resource is already booked for this time slot.'),
          );
        }
      }

      final model = BookingItemModel.fromEntity(booking);
      await localDataSource.saveBooking(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error saving booking: $e'));
    }
  }

  @override
  Future<Either<Failure, BookingItem>> cancelBooking(String bookingId) async {
    try {
      final existing = await localDataSource.getBookingById(bookingId);
      if (existing == null) {
        return Left(CacheFailure(message: 'Booking $bookingId not found'));
      }

      final cancelled = existing.copyWith(status: BookingStatus.cancelled);
      final model = BookingItemModel.fromEntity(cancelled);
      await localDataSource.saveBooking(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error cancelling booking: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAvailability(
    String resourceId,
    DateTime startTime,
    DateTime endTime, {
    String? excludeBookingId,
  }) async {
    try {
      final all = await localDataSource.getBookings();
      final hasConflict = all.any((b) {
        if (b.id == excludeBookingId) return false;
        if (b.resourceId != resourceId) return false;
        if (!b.isActive) return false;
        return b.overlapsWith(startTime, endTime);
      });

      return Right(!hasConflict);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error checking booking availability: $e'));
    }
  }
}
