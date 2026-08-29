import '../../domain/entities/clinic_visit.dart';
import 'procedure_item_model.dart';
import 'tooth_chart_entry_model.dart';

class ClinicVisitModel extends ClinicVisit {
  const ClinicVisitModel({
    required super.id,
    required super.patientId,
    required super.patientName,
    required super.doctorName,
    super.roomNumber = 'Room 1',
    required super.queueNumber,
    super.status = ClinicVisitStatus.waiting,
    required super.checkInTime,
    super.consultationStartTime,
    super.completionTime,
    super.chiefComplaint = '',
    super.diagnosis,
    super.prescriptions = const [],
    super.appliedProcedures = const [],
    super.toothChart = const [],
    super.totalFee = 0.0,
    super.patientCopay = 0.0,
    super.insurancePaid = 0.0,
    super.isPaid = false,
    super.recallDate,
    super.bloodPressure = '120/80 mmHg',
    super.heartRate = '76 BPM',
    super.respiratoryRate = '16 bpm',
    super.spo2 = '99%',
    super.temperature = '36.8 °C',
  });

  factory ClinicVisitModel.fromJson(Map<String, dynamic> json) {
    return ClinicVisitModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      patientName: json['patientName']?.toString() ?? '',
      doctorName: json['doctorName']?.toString() ?? '',
      roomNumber: json['roomNumber']?.toString() ?? 'Room 1',
      queueNumber: (json['queueNumber'] as num?)?.toInt() ?? 1,
      status: ClinicVisitStatus.fromString(json['status']?.toString()),
      checkInTime: DateTime.tryParse(json['checkInTime']?.toString() ?? '') ?? DateTime.now(),
      consultationStartTime: DateTime.tryParse(json['consultationStartTime']?.toString() ?? ''),
      completionTime: DateTime.tryParse(json['completionTime']?.toString() ?? ''),
      chiefComplaint: json['chiefComplaint']?.toString() ?? '',
      diagnosis: json['diagnosis']?.toString(),
      prescriptions: (json['prescriptions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      appliedProcedures: (json['appliedProcedures'] as List<dynamic>?)
              ?.map((e) => ProcedureItemModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      toothChart: (json['toothChart'] as List<dynamic>?)
              ?.map((e) => ToothChartEntryModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      totalFee: (json['totalFee'] as num?)?.toDouble() ?? 0.0,
      patientCopay: (json['patientCopay'] as num?)?.toDouble() ?? 0.0,
      insurancePaid: (json['insurancePaid'] as num?)?.toDouble() ?? 0.0,
      isPaid: json['isPaid'] == true,
      recallDate: DateTime.tryParse(json['recallDate']?.toString() ?? ''),
      bloodPressure: json['bloodPressure']?.toString() ?? '120/80 mmHg',
      heartRate: json['heartRate']?.toString() ?? '76 BPM',
      respiratoryRate: json['respiratoryRate']?.toString() ?? '16 bpm',
      spo2: json['spo2']?.toString() ?? '99%',
      temperature: json['temperature']?.toString() ?? '36.8 °C',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorName': doctorName,
      'roomNumber': roomNumber,
      'queueNumber': queueNumber,
      'status': status.name,
      'checkInTime': checkInTime.toIso8601String(),
      'consultationStartTime': consultationStartTime?.toIso8601String(),
      'completionTime': completionTime?.toIso8601String(),
      'chiefComplaint': chiefComplaint,
      'diagnosis': diagnosis,
      'prescriptions': prescriptions,
      'appliedProcedures': appliedProcedures
          .map((p) => p is ProcedureItemModel ? p.toJson() : ProcedureItemModel.fromEntity(p).toJson())
          .toList(),
      'toothChart': toothChart
          .map((t) => t is ToothChartEntryModel ? t.toJson() : ToothChartEntryModel.fromEntity(t).toJson())
          .toList(),
      'totalFee': totalFee,
      'patientCopay': patientCopay,
      'insurancePaid': insurancePaid,
      'isPaid': isPaid,
      'recallDate': recallDate?.toIso8601String(),
      'bloodPressure': bloodPressure,
      'heartRate': heartRate,
      'respiratoryRate': respiratoryRate,
      'spo2': spo2,
      'temperature': temperature,
    };
  }

  factory ClinicVisitModel.fromEntity(ClinicVisit entity) {
    return ClinicVisitModel(
      id: entity.id,
      patientId: entity.patientId,
      patientName: entity.patientName,
      doctorName: entity.doctorName,
      roomNumber: entity.roomNumber,
      queueNumber: entity.queueNumber,
      status: entity.status,
      checkInTime: entity.checkInTime,
      consultationStartTime: entity.consultationStartTime,
      completionTime: entity.completionTime,
      chiefComplaint: entity.chiefComplaint,
      diagnosis: entity.diagnosis,
      prescriptions: entity.prescriptions,
      appliedProcedures: entity.appliedProcedures,
      toothChart: entity.toothChart,
      totalFee: entity.totalFee,
      patientCopay: entity.patientCopay,
      insurancePaid: entity.insurancePaid,
      isPaid: entity.isPaid,
      recallDate: entity.recallDate,
      bloodPressure: entity.bloodPressure,
      heartRate: entity.heartRate,
      respiratoryRate: entity.respiratoryRate,
      spo2: entity.spo2,
      temperature: entity.temperature,
    );
  }
}
