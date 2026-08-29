import '../../domain/entities/booking_item.dart';

class BookingItemModel extends BookingItem {
  const BookingItemModel({
    required super.id,
    required super.customerOrPatientId,
    required super.customerName,
    super.customerPhone,
    required super.resourceId,
    super.resourceName = 'Primary Resource',
    super.serviceName = 'Standard Service',
    required super.startTime,
    required super.endTime,
    super.status = BookingStatus.confirmed,
    super.price = 0.0,
    super.depositPaid = 0.0,
    super.notes,
    required super.createdAt,
  });

  factory BookingItemModel.fromJson(Map<String, dynamic> json) {
    return BookingItemModel(
      id: json['id']?.toString() ?? '',
      customerOrPatientId: json['customerOrPatientId']?.toString() ?? json['patientId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? json['patientName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString() ?? json['phone']?.toString(),
      resourceId: json['resourceId']?.toString() ?? json['doctorOrRoom']?.toString() ?? '',
      resourceName: json['resourceName']?.toString() ?? 'Primary Resource',
      serviceName: json['serviceName']?.toString() ?? 'Standard Service',
      startTime: DateTime.tryParse(json['startTime']?.toString() ?? json['datetime']?.toString() ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime']?.toString() ?? '') ?? DateTime.now().add(const Duration(minutes: 30)),
      status: BookingStatus.fromString(json['status']?.toString()),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      depositPaid: (json['depositPaid'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerOrPatientId': customerOrPatientId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'resourceId': resourceId,
      'resourceName': resourceName,
      'serviceName': serviceName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status.name,
      'price': price,
      'depositPaid': depositPaid,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BookingItemModel.fromEntity(BookingItem entity) {
    return BookingItemModel(
      id: entity.id,
      customerOrPatientId: entity.customerOrPatientId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      resourceId: entity.resourceId,
      resourceName: entity.resourceName,
      serviceName: entity.serviceName,
      startTime: entity.startTime,
      endTime: entity.endTime,
      status: entity.status,
      price: entity.price,
      depositPaid: entity.depositPaid,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}
