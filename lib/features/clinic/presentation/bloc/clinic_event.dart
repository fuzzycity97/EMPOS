import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_visit.dart';
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
  final String doctorName;
  final String chiefComplaint;
  final String roomNumber;

  const CheckInPatientEvent({
    required this.patientId,
    required this.patientName,
    required this.doctorName,
    required this.chiefComplaint,
    this.roomNumber = 'Room 1',
  });

  @override
  List<Object?> get props => [patientId, patientName, doctorName, chiefComplaint, roomNumber];
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

  const ProcessVisitPaymentEvent(this.visitId);

  @override
  List<Object?> get props => [visitId];
}

/// Alias for CompleteVisitEvent in examination workflows
typedef CompleteExaminationEvent = CompleteVisitEvent;

