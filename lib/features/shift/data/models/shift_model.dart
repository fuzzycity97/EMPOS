import '../../domain/entities/shift.dart';

class ShiftModel extends Shift {
  const ShiftModel({
    required super.id,
    required super.cashierId,
    super.cashierName,
    required super.startTime,
    super.endTime,
    required super.startingCash,
    super.expectedCash = 0.0,
    super.actualCash,
    super.difference = 0.0,
    super.status = ShiftStatus.open,
    super.notes,
  });

  factory ShiftModel.fromJson(Map<String, dynamic> json) {
    return ShiftModel(
      id: json['id'] as String,
      cashierId: json['cashierId'] as String,
      cashierName: json['cashierName'] as String?,
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'] as String)
          : null,
      startingCash: (json['startingCash'] as num).toDouble(),
      expectedCash: (json['expectedCash'] as num?)?.toDouble() ?? 0.0,
      actualCash: (json['actualCash'] as num?)?.toDouble(),
      difference: (json['difference'] as num?)?.toDouble() ?? 0.0,
      status: ShiftStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ShiftStatus.open,
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cashierId': cashierId,
      'cashierName': cashierName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'startingCash': startingCash,
      'expectedCash': expectedCash,
      'actualCash': actualCash,
      'difference': difference,
      'status': status.name,
      'notes': notes,
    };
  }

  factory ShiftModel.fromEntity(Shift entity) {
    return ShiftModel(
      id: entity.id,
      cashierId: entity.cashierId,
      cashierName: entity.cashierName,
      startTime: entity.startTime,
      endTime: entity.endTime,
      startingCash: entity.startingCash,
      expectedCash: entity.expectedCash,
      actualCash: entity.actualCash,
      difference: entity.difference,
      status: entity.status,
      notes: entity.notes,
    );
  }
}
