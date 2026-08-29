import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/booking_item_model.dart';

abstract class BookingLocalDataSource {
  Future<List<BookingItemModel>> getBookings();
  Future<BookingItemModel?> getBookingById(String id);
  Future<void> saveBooking(BookingItemModel booking);
  Future<void> deleteBooking(String id);
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  static const String bookingsBoxName = 'empos_bookings_box';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(bookingsBoxName)) {
      return Hive.box<dynamic>(bookingsBoxName);
    }
    return await Hive.openBox<dynamic>(bookingsBoxName);
  }

  @override
  Future<List<BookingItemModel>> getBookings() async {
    try {
      final box = await _openBox();
      final List<BookingItemModel> list = [];
      for (final raw in box.values) {
        if (raw != null) {
          if (raw is String) {
            list.add(BookingItemModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)));
          } else if (raw is Map) {
            list.add(BookingItemModel.fromJson(Map<String, dynamic>.from(raw)));
          }
        }
      }
      list.sort((a, b) => a.startTime.compareTo(b.startTime));
      return list;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve bookings: $e');
    }
  }

  @override
  Future<BookingItemModel?> getBookingById(String id) async {
    try {
      final box = await _openBox();
      final raw = box.get(id);
      if (raw == null) return null;
      if (raw is String) {
        return BookingItemModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
      }
      return BookingItemModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve booking $id: $e');
    }
  }

  @override
  Future<void> saveBooking(BookingItemModel booking) async {
    try {
      final box = await _openBox();
      await box.put(booking.id, jsonEncode(booking.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save booking: $e');
    }
  }

  @override
  Future<void> deleteBooking(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete booking: $e');
    }
  }
}
