// test/booking_scheduling_gaps_test.dart
//
// Covers the 2 confirmed scheduling rules found in
// BookingRepositoryImpl.saveBooking():
//   1. Time-slot overlap / resource conflict rejection
//   2. Cancellation frees the slot without hard-deleting history
//
// Also fuzzes the overlap boundary conditions, which is exactly the kind
// of off-by-one bug that "overlapsWith" style logic tends to hide
// (touching-but-not-overlapping slots, zero-duration bookings, etc).

import 'package:flutter_test/flutter_test.dart';
import 'package:empos/features/bookings/data/datasources/booking_local_data_source.dart';
import 'package:empos/features/bookings/data/models/booking_item_model.dart';
import 'package:empos/features/bookings/data/repositories/booking_repository_impl.dart';
import 'package:empos/features/bookings/domain/entities/booking_item.dart';

class FakeBookingLocalDataSource implements BookingLocalDataSource {
  final Map<String, BookingItemModel> _storage = {};

  @override
  Future<List<BookingItemModel>> getBookings() async => _storage.values.toList();

  @override
  Future<BookingItemModel?> getBookingById(String id) async => _storage[id];

  @override
  Future<void> saveBooking(BookingItemModel booking) async {
    _storage[booking.id] = booking;
  }

  @override
  Future<void> deleteBooking(String id) async {
    _storage.remove(id);
  }
}

BookingItem _createBooking({
  required String id,
  required String resourceId,
  required DateTime startTime,
  required DateTime endTime,
  BookingStatus status = BookingStatus.confirmed,
}) {
  return BookingItem(
    id: id,
    customerOrPatientId: 'patient-test-01',
    customerName: 'Test Patient',
    resourceId: resourceId,
    startTime: startTime,
    endTime: endTime,
    status: status,
    createdAt: DateTime(2026, 9, 1),
  );
}

void main() {
  group('Booking scheduling — resource conflict & lifecycle', () {
    late FakeBookingLocalDataSource fakeDataSource;
    late BookingRepositoryImpl repository;

    setUp(() {
      fakeDataSource = FakeBookingLocalDataSource();
      repository = BookingRepositoryImpl(localDataSource: fakeDataSource);
    });

    test('booking that fully overlaps an existing confirmed booking on the '
        'same resource is rejected', () async {
      final existing = _createBooking(
        id: 'b1',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 11, 0),
        status: BookingStatus.confirmed,
      );
      await repository.saveBooking(existing);

      final conflicting = _createBooking(
        id: 'b2',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 10, 30),
        endTime: DateTime(2026, 10, 1, 11, 30),
        status: BookingStatus.pending,
      );

      final result = await repository.saveBooking(conflicting);
      expect(result.isLeft(), isTrue,
          reason: 'Overlapping booking on the same resource must be '
              'rejected with a ValidationFailure');
    });

    test('booking that starts exactly when another ends on the same '
        'resource is NOT a conflict (touching, not overlapping)', () async {
      final existing = _createBooking(
        id: 'b1',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 11, 0),
        status: BookingStatus.confirmed,
      );
      await repository.saveBooking(existing);

      final backToBack = _createBooking(
        id: 'b2',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 11, 0), // starts exactly at b1's end
        endTime: DateTime(2026, 10, 1, 12, 0),
        status: BookingStatus.pending,
      );

      final result = await repository.saveBooking(backToBack);
      expect(result.isRight(), isTrue,
          reason: 'startTime < otherEnd && endTime > otherStart means a '
              'booking starting exactly at another\'s end time should be '
              'allowed — verify this matches intended business behavior '
              '(back-to-back appointments with zero buffer)');
    });

    test('cancelled bookings do not block new bookings on the same '
        'resource/time slot', () async {
      final cancelled = _createBooking(
        id: 'b1',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 11, 0),
        status: BookingStatus.cancelled,
      );
      await repository.saveBooking(cancelled);

      final newBooking = _createBooking(
        id: 'b2',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 11, 0),
        status: BookingStatus.pending,
      );

      final result = await repository.saveBooking(newBooking);
      expect(result.isRight(), isTrue,
          reason: 'A cancelled booking must not count toward conflict '
              'checks — only pending/confirmed/checkedIn should block');
    });

    test('cancelling a booking preserves the original record (soft cancel) '
        'rather than deleting appointment history', () async {
      final booking = _createBooking(
        id: 'b1',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 11, 0),
        status: BookingStatus.confirmed,
      );
      await repository.saveBooking(booking);
      await repository.cancelBooking(booking.id);

      final listResult = await repository.getBookings();
      expect(listResult.isRight(), isTrue);
      final all = listResult.getOrElse(() => []);
      final fetched = all.firstWhere((b) => b.id == booking.id);
      expect(fetched, isNotNull,
          reason: 'Cancellation must not hard-delete the record');
      expect(fetched.status, BookingStatus.cancelled);
    });

    test('zero-duration booking (startTime == endTime) is rejected outright '
        'rather than silently accepted as a non-conflicting slot', () async {
      final degenerate = _createBooking(
        id: 'b1',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 10, 0),
        endTime: DateTime(2026, 10, 1, 10, 0), // zero duration
        status: BookingStatus.pending,
      );

      final result = await repository.saveBooking(degenerate);
      expect(result.isLeft(), isTrue);
    }, skip: 'Confirm intended behavior for zero-duration bookings before '
        'asserting pass/fail — currently undefined in BookingRepositoryImpl.');

    test('midnight-crossing booking (e.g. 23:30–00:30) is evaluated with '
        'correct date-aware overlap logic, not just time-of-day', () async {
      final lateNight = _createBooking(
        id: 'b1',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 1, 23, 30),
        endTime: DateTime(2026, 10, 2, 0, 30),
        status: BookingStatus.confirmed,
      );
      await repository.saveBooking(lateNight);

      final earlyNextDay = _createBooking(
        id: 'b2',
        resourceId: 'chair-1',
        startTime: DateTime(2026, 10, 2, 0, 15), // overlaps into next day
        endTime: DateTime(2026, 10, 2, 1, 0),
        status: BookingStatus.pending,
      );

      final result = await repository.saveBooking(earlyNextDay);
      expect(result.isLeft(), isTrue,
          reason: 'Overlap logic must compare full DateTime, not just '
              'time-of-day, or midnight-crossing bookings will falsely '
              'appear non-conflicting');
    });
  });
}
