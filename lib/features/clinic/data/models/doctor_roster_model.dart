import '../../domain/entities/doctor_roster.dart';

class DoctorRosterModel extends DoctorRoster {
  const DoctorRosterModel({
    required super.id,
    required super.doctorId,
    required super.doctorName,
    required super.specialty,
    required super.workingDays,
    super.shiftStartHour = 9,
    super.shiftEndHour = 17,
    super.slotDurationMinutes = 60,
    super.roomName = 'Suite A',
    super.isActive = true,
    super.colorHex = '#3B82F6',
  });

  factory DoctorRosterModel.fromJson(Map<String, dynamic> json) {
    return DoctorRosterModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      specialty: json['specialty'] as String,
      workingDays: (json['workingDays'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ?? [1, 2, 3, 4, 5],
      shiftStartHour: (json['shiftStartHour'] as num?)?.toInt() ?? 9,
      shiftEndHour: (json['shiftEndHour'] as num?)?.toInt() ?? 17,
      slotDurationMinutes: (json['slotDurationMinutes'] as num?)?.toInt() ?? 60,
      roomName: json['roomName'] as String? ?? 'Suite A',
      isActive: json['isActive'] as bool? ?? true,
      colorHex: json['colorHex'] as String? ?? '#3B82F6',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'specialty': specialty,
      'workingDays': workingDays,
      'shiftStartHour': shiftStartHour,
      'shiftEndHour': shiftEndHour,
      'slotDurationMinutes': slotDurationMinutes,
      'roomName': roomName,
      'isActive': isActive,
      'colorHex': colorHex,
    };
  }

  factory DoctorRosterModel.fromEntity(DoctorRoster entity) {
    return DoctorRosterModel(
      id: entity.id,
      doctorId: entity.doctorId,
      doctorName: entity.doctorName,
      specialty: entity.specialty,
      workingDays: entity.workingDays,
      shiftStartHour: entity.shiftStartHour,
      shiftEndHour: entity.shiftEndHour,
      slotDurationMinutes: entity.slotDurationMinutes,
      roomName: entity.roomName,
      isActive: entity.isActive,
      colorHex: entity.colorHex,
    );
  }
}
