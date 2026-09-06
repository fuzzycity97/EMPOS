import 'package:equatable/equatable.dart';

/// Doctor working shift and roster schedule for clinic appointments.
class DoctorRoster extends Equatable {
  final String id;
  final String doctorId;
  final String doctorName;
  final String specialty;
  final List<int> workingDays; // 1 = Mon, 2 = Tue, 3 = Wed, 4 = Thu, 5 = Fri, 6 = Sat, 7 = Sun
  final int shiftStartHour; // e.g. 9 for 09:00
  final int shiftEndHour; // e.g. 17 for 17:00
  final int slotDurationMinutes; // 30 or 60
  final String roomName;
  final bool isActive;
  final String colorHex;

  const DoctorRoster({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.workingDays,
    this.shiftStartHour = 9,
    this.shiftEndHour = 17,
    this.slotDurationMinutes = 60,
    this.roomName = 'Suite A',
    this.isActive = true,
    this.colorHex = '#3B82F6',
  });

  static const List<DoctorRoster> defaultRosters = [
    DoctorRoster(
      id: 'roster_sarah',
      doctorId: 'usr_doctor',
      doctorName: 'Dr. Sarah Connor',
      specialty: 'Orthodontics & Dental Lead',
      workingDays: [6, 1, 3], // Sat, Mon, Wed
      shiftStartHour: 9,
      shiftEndHour: 17,
      slotDurationMinutes: 60,
      roomName: 'Dental Suite 1',
      isActive: true,
      colorHex: '#10B981', // Emerald
    ),
    DoctorRoster(
      id: 'roster_tarek',
      doctorId: 'usr_doctor_tarek',
      doctorName: 'Dr. Tarek Dental Specialist',
      specialty: 'Maxillofacial Surgery & Implants',
      workingDays: [7, 2, 4], // Sun, Tue, Thu
      shiftStartHour: 12,
      shiftEndHour: 20,
      slotDurationMinutes: 60,
      roomName: 'Surgical Suite 2',
      isActive: true,
      colorHex: '#3B82F6', // Blue
    ),
    DoctorRoster(
      id: 'roster_oncall',
      doctorId: 'usr_doctor_oncall',
      doctorName: 'Dr. On-Call Physician',
      specialty: 'General Triage & Emergencies',
      workingDays: [1, 2, 3, 4, 5, 6, 7], // Daily
      shiftStartHour: 8,
      shiftEndHour: 16,
      slotDurationMinutes: 30,
      roomName: 'Consultation Bay A',
      isActive: true,
      colorHex: '#F59E0B', // Amber
    ),
  ];

  bool isWorkingOn(DateTime date) {
    if (!isActive) return false;
    return workingDays.contains(date.weekday);
  }

  List<DateTime> getSlotsForDate(DateTime date) {
    if (!isWorkingOn(date)) return [];
    final slots = <DateTime>[];
    DateTime current = DateTime(date.year, date.month, date.day, shiftStartHour, 0);
    final end = DateTime(date.year, date.month, date.day, shiftEndHour, 0);

    while (current.isBefore(end)) {
      slots.add(current);
      current = current.add(Duration(minutes: slotDurationMinutes));
    }
    return slots;
  }

  String formatShiftHours() {
    final startPeriod = shiftStartHour >= 12 ? 'PM' : 'AM';
    final start12 = shiftStartHour > 12 ? shiftStartHour - 12 : (shiftStartHour == 0 ? 12 : shiftStartHour);
    final endPeriod = shiftEndHour >= 12 ? 'PM' : 'AM';
    final end12 = shiftEndHour > 12 ? shiftEndHour - 12 : (shiftEndHour == 0 ? 12 : shiftEndHour);
    return '${start12.toString().padLeft(2, '0')}:00 $startPeriod - ${end12.toString().padLeft(2, '0')}:00 $endPeriod';
  }

  DoctorRoster copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? specialty,
    List<int>? workingDays,
    int? shiftStartHour,
    int? shiftEndHour,
    int? slotDurationMinutes,
    String? roomName,
    bool? isActive,
    String? colorHex,
  }) {
    return DoctorRoster(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      specialty: specialty ?? this.specialty,
      workingDays: workingDays ?? this.workingDays,
      shiftStartHour: shiftStartHour ?? this.shiftStartHour,
      shiftEndHour: shiftEndHour ?? this.shiftEndHour,
      slotDurationMinutes: slotDurationMinutes ?? this.slotDurationMinutes,
      roomName: roomName ?? this.roomName,
      isActive: isActive ?? this.isActive,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  @override
  List<Object?> get props => [
        id,
        doctorId,
        doctorName,
        specialty,
        workingDays,
        shiftStartHour,
        shiftEndHour,
        slotDurationMinutes,
        roomName,
        isActive,
        colorHex,
      ];
}
