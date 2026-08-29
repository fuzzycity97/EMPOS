import 'package:equatable/equatable.dart';

enum BookingStatus {
  pending,
  confirmed,
  checkedIn,
  completed,
  cancelled;

  static BookingStatus fromString(String? val) {
    if (val == null) return BookingStatus.confirmed;
    final lower = val.toLowerCase().replaceAll('_', '');
    for (final s in BookingStatus.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return BookingStatus.confirmed;
  }
}

class BookingItem extends Equatable {
  final String id;
  final String customerOrPatientId;
  final String customerName;
  final String? customerPhone;
  final String resourceId; // Room / Doctor / Stylist / Table / Vehicle Bay
  final String resourceName;
  final String serviceName;
  final DateTime startTime;
  final DateTime endTime;
  final BookingStatus status;
  final double price;
  final double depositPaid;
  final String? notes;
  final DateTime createdAt;

  const BookingItem({
    required this.id,
    required this.customerOrPatientId,
    required this.customerName,
    this.customerPhone,
    required this.resourceId,
    this.resourceName = 'Primary Resource',
    this.serviceName = 'Standard Service',
    required this.startTime,
    required this.endTime,
    this.status = BookingStatus.confirmed,
    this.price = 0.0,
    this.depositPaid = 0.0,
    this.notes,
    required this.createdAt,
  });

  int get durationMinutes => endTime.difference(startTime).inMinutes;
  bool get isActive =>
      status == BookingStatus.pending ||
      status == BookingStatus.confirmed ||
      status == BookingStatus.checkedIn;

  bool overlapsWith(DateTime otherStart, DateTime otherEnd) {
    return startTime.isBefore(otherEnd) && endTime.isAfter(otherStart);
  }

  BookingItem copyWith({
    String? id,
    String? customerOrPatientId,
    String? customerName,
    String? customerPhone,
    String? resourceId,
    String? resourceName,
    String? serviceName,
    DateTime? startTime,
    DateTime? endTime,
    BookingStatus? status,
    double? price,
    double? depositPaid,
    String? notes,
    DateTime? createdAt,
  }) {
    return BookingItem(
      id: id ?? this.id,
      customerOrPatientId: customerOrPatientId ?? this.customerOrPatientId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      resourceId: resourceId ?? this.resourceId,
      resourceName: resourceName ?? this.resourceName,
      serviceName: serviceName ?? this.serviceName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      price: price ?? this.price,
      depositPaid: depositPaid ?? this.depositPaid,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerOrPatientId,
        customerName,
        customerPhone,
        resourceId,
        resourceName,
        serviceName,
        startTime,
        endTime,
        status,
        price,
        depositPaid,
        notes,
        createdAt,
      ];
}
