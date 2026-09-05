import 'package:equatable/equatable.dart';
import 'procedure_item.dart';
import 'tooth_chart_entry.dart';

enum ClinicVisitStatus {
  waiting,
  inExamination,
  completed,
  cancelled,
  noShow;

  static ClinicVisitStatus fromString(String? val) {
    if (val == null) return ClinicVisitStatus.waiting;
    final lower = val.toLowerCase().replaceAll('_', '');
    for (final s in ClinicVisitStatus.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return ClinicVisitStatus.waiting;
  }
}

class ClinicVisit extends Equatable {
  final String id;
  final String patientId;
  final String patientName;
  final String doctorName;
  final String roomNumber;
  final int queueNumber;
  final ClinicVisitStatus status;
  final DateTime checkInTime;
  final DateTime? consultationStartTime;
  final DateTime? completionTime;
  final String chiefComplaint;
  final String? diagnosis;
  final List<String> prescriptions;
  final List<ProcedureItem> appliedProcedures;
  final List<ToothChartEntry> toothChart;
  final double totalFee;
  final double patientCopay;
  final double insurancePaid;
  final bool isPaid;
  final DateTime? recallDate;
  final String bloodPressure;
  final String heartRate;
  final String respiratoryRate;
  final String spo2;
  final String temperature;
  final String? labResults;
  final List<String> attachmentPaths;
  final List<String> attachmentTitles;

  const ClinicVisit({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    this.roomNumber = 'Room 1',
    required this.queueNumber,
    this.status = ClinicVisitStatus.waiting,
    required this.checkInTime,
    this.consultationStartTime,
    this.completionTime,
    this.chiefComplaint = '',
    this.diagnosis,
    this.prescriptions = const [],
    this.appliedProcedures = const [],
    this.toothChart = const [],
    this.totalFee = 0.0,
    this.patientCopay = 0.0,
    this.insurancePaid = 0.0,
    this.isPaid = false,
    this.recallDate,
    this.bloodPressure = '120/80 mmHg',
    this.heartRate = '76 BPM',
    this.respiratoryRate = '16 bpm',
    this.spo2 = '99%',
    this.temperature = '36.8 °C',
    this.labResults,
    this.attachmentPaths = const [],
    this.attachmentTitles = const [],
  });

  int get consultationDurationMinutes {
    if (consultationStartTime == null || completionTime == null) return 0;
    return completionTime!.difference(consultationStartTime!).inMinutes;
  }

  ClinicVisit copyWith({
    String? id,
    String? patientId,
    String? patientName,
    String? doctorName,
    String? roomNumber,
    int? queueNumber,
    ClinicVisitStatus? status,
    DateTime? checkInTime,
    DateTime? consultationStartTime,
    DateTime? completionTime,
    String? chiefComplaint,
    String? diagnosis,
    List<String>? prescriptions,
    List<ProcedureItem>? appliedProcedures,
    List<ToothChartEntry>? toothChart,
    double? totalFee,
    double? patientCopay,
    double? insurancePaid,
    bool? isPaid,
    DateTime? recallDate,
    String? bloodPressure,
    String? heartRate,
    String? respiratoryRate,
    String? spo2,
    String? temperature,
    String? labResults,
    List<String>? attachmentPaths,
    List<String>? attachmentTitles,
  }) {
    return ClinicVisit(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      doctorName: doctorName ?? this.doctorName,
      roomNumber: roomNumber ?? this.roomNumber,
      queueNumber: queueNumber ?? this.queueNumber,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      consultationStartTime: consultationStartTime ?? this.consultationStartTime,
      completionTime: completionTime ?? this.completionTime,
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      diagnosis: diagnosis ?? this.diagnosis,
      prescriptions: prescriptions ?? this.prescriptions,
      appliedProcedures: appliedProcedures ?? this.appliedProcedures,
      toothChart: toothChart ?? this.toothChart,
      totalFee: totalFee ?? this.totalFee,
      patientCopay: patientCopay ?? this.patientCopay,
      insurancePaid: insurancePaid ?? this.insurancePaid,
      isPaid: isPaid ?? this.isPaid,
      recallDate: recallDate ?? this.recallDate,
      bloodPressure: bloodPressure ?? this.bloodPressure,
      heartRate: heartRate ?? this.heartRate,
      respiratoryRate: respiratoryRate ?? this.respiratoryRate,
      spo2: spo2 ?? this.spo2,
      temperature: temperature ?? this.temperature,
      labResults: labResults ?? this.labResults,
      attachmentPaths: attachmentPaths ?? this.attachmentPaths,
      attachmentTitles: attachmentTitles ?? this.attachmentTitles,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        patientName,
        doctorName,
        roomNumber,
        queueNumber,
        status,
        checkInTime,
        consultationStartTime,
        completionTime,
        chiefComplaint,
        diagnosis,
        prescriptions,
        appliedProcedures,
        toothChart,
        totalFee,
        patientCopay,
        insurancePaid,
        isPaid,
        recallDate,
        bloodPressure,
        heartRate,
        respiratoryRate,
        spo2,
        temperature,
        labResults,
        attachmentPaths,
        attachmentTitles,
      ];
}
