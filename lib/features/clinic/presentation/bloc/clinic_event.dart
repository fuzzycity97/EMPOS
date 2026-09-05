import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/medical_risk_factor.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/entities/tooth_chart_entry.dart';

abstract class ClinicEvent extends Equatable {
  const ClinicEvent();

  @override
  List<Object?> get props => [];
}

class LoadClinicQueueEvent extends ClinicEvent {
  final String? doctorName;

  const LoadClinicQueueEvent({this.doctorName});

  @override
  List<Object?> get props => [doctorName];
}

class CheckInPatientEvent extends ClinicEvent {
  final String patientId;
  final String patientName;
  final String phone;
  final String? age;
  final List<String> chronicConditions;
  final List<String> allergies;
  final String doctorName;
  final String chiefComplaint;
  final String roomNumber;

  const CheckInPatientEvent({
    required this.patientId,
    required this.patientName,
    this.phone = '',
    this.age,
    this.chronicConditions = const [],
    this.allergies = const [],
    required this.doctorName,
    required this.chiefComplaint,
    this.roomNumber = 'Room 1',
  });

  @override
  List<Object?> get props => [
        patientId,
        patientName,
        phone,
        age,
        chronicConditions,
        allergies,
        doctorName,
        chiefComplaint,
        roomNumber,
      ];
}

class UpdatePatientProfileEvent extends ClinicEvent {
  final PatientProfile patient;

  const UpdatePatientProfileEvent(this.patient);

  @override
  List<Object?> get props => [patient];
}

class UpdateVisitStatusEvent extends ClinicEvent {
  final String visitId;
  final ClinicVisitStatus status;

  const UpdateVisitStatusEvent({
    required this.visitId,
    required this.status,
  });

  @override
  List<Object?> get props => [visitId, status];
}

class CompleteVisitEvent extends ClinicEvent {
  final ClinicVisit visit;

  const CompleteVisitEvent(this.visit);

  @override
  List<Object?> get props => [visit];
}

class LoadPatientToothChartEvent extends ClinicEvent {
  final String patientId;

  const LoadPatientToothChartEvent(this.patientId);

  @override
  List<Object?> get props => [patientId];
}

class ResetToothChartEvent extends ClinicEvent {
  final bool isPediatric;
  final List<ToothChartEntry>? initialEntries;

  const ResetToothChartEvent({
    this.isPediatric = false,
    this.initialEntries,
  });

  @override
  List<Object?> get props => [isPediatric, initialEntries];
}


class UpdateToothChartEntryEvent extends ClinicEvent {
  final String patientId;
  final ToothChartEntry entry;

  const UpdateToothChartEntryEvent({
    required this.patientId,
    required this.entry,
  });

  @override
  List<Object?> get props => [patientId, entry];
}

class SaveToothChartEvent extends ClinicEvent {
  final String patientId;
  final List<ToothChartEntry> entries;

  const SaveToothChartEvent({
    required this.patientId,
    required this.entries,
  });

  @override
  List<Object?> get props => [patientId, entries];
}

class SearchClinicPatientsEvent extends ClinicEvent {
  final String query;

  const SearchClinicPatientsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class ProcessVisitPaymentEvent extends ClinicEvent {
  final String visitId;
  final double? amountPaid;

  const ProcessVisitPaymentEvent(this.visitId, {this.amountPaid});

  @override
  List<Object?> get props => [visitId, amountPaid];
}

class UpdateVisitVitalsEvent extends ClinicEvent {
  final String visitId;
  final String bloodPressure;
  final String heartRate;
  final String spo2;
  final String temperature;
  final String respiratoryRate;

  const UpdateVisitVitalsEvent({
    required this.visitId,
    required this.bloodPressure,
    required this.heartRate,
    required this.spo2,
    required this.temperature,
    required this.respiratoryRate,
  });

  @override
  List<Object?> get props => [
        visitId,
        bloodPressure,
        heartRate,
        spo2,
        temperature,
        respiratoryRate,
      ];
}

class LoadMedicalRiskFactorsEvent extends ClinicEvent {
  const LoadMedicalRiskFactorsEvent();
}

class UpdateMedicalRiskFactorsEvent extends ClinicEvent {
  final List<MedicalRiskFactor> factors;

  const UpdateMedicalRiskFactorsEvent(this.factors);

  @override
  List<Object?> get props => [factors];
}

/// Alias for CompleteVisitEvent in examination workflows
typedef CompleteExaminationEvent = CompleteVisitEvent;
