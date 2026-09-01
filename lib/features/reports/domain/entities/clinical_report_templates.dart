import 'package:equatable/equatable.dart';

enum ReportDataType {
  opticalPrescription, // Sphere, Cylinder, Axis, Add, PD, Visual Acuity OD/OS
  dentalOdontogramSummary, // Missing, Decayed, Crowned, Perio depth metrics
  orthopedicRomGoniometry, // Joint ROM flexion/extension degrees & pain scale
  pediatricGrowthSummary, // Weight/Height percentiles & milestone flags
  audiogramThresholds, // Frequency dB hearing thresholds
  cardiacSummary, // Ejection fraction, rhythm annotations, vitals trend
  generalClinicalSummary, // Chief complaint, diagnosis, procedures, lab summary
  fefoDispensingAudit, // Drug batch, expiry, patient recipient, dispensing tech
}

class ClinicalReportEntry extends Equatable {
  final String patientId;
  final String patientName;
  final String doctorId;
  final String doctorName;
  final DateTime encounterDate;
  final ReportDataType reportType;
  final Map<String, dynamic> structuredData;
  final List<String> attachmentUrls;

  const ClinicalReportEntry({
    required this.patientId,
    required this.patientName,
    required this.doctorId,
    required this.doctorName,
    required this.encounterDate,
    required this.reportType,
    required this.structuredData,
    this.attachmentUrls = const [],
  });

  @override
  List<Object?> get props => [
        patientId,
        patientName,
        doctorId,
        doctorName,
        encounterDate,
        reportType,
        structuredData,
        attachmentUrls,
      ];
}
