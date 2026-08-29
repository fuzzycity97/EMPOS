import 'package:equatable/equatable.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/entities/tooth_chart_entry.dart';

abstract class ClinicState extends Equatable {
  const ClinicState();

  @override
  List<Object?> get props => [];
}

class ClinicInitial extends ClinicState {}

class ClinicLoading extends ClinicState {}

class ClinicLoaded extends ClinicState {
  final List<ClinicVisit> queue;
  final List<PatientProfile> patients;
  final List<ToothChartEntry>? activeToothChart;
  final int? rollingMeanWaitMinutes;
  final String? activePatientId;
  final String? activeVisitId;

  const ClinicLoaded({
    required this.queue,
    required this.patients,
    this.activeToothChart,
    this.rollingMeanWaitMinutes,
    this.activePatientId,
    this.activeVisitId,
  });

  List<ClinicVisit> get waitingQueue =>
      queue.where((v) => v.status == ClinicVisitStatus.waiting).toList();

  List<ClinicVisit> get inExaminationQueue =>
      queue.where((v) => v.status == ClinicVisitStatus.inExamination).toList();

  List<ClinicVisit> get completedQueue =>
      queue.where((v) => v.status == ClinicVisitStatus.completed).toList();

  ClinicVisit? get activeVisit {
    if (activeVisitId == null) {
      if (inExaminationQueue.isNotEmpty) return inExaminationQueue.first;
      if (waitingQueue.isNotEmpty) return waitingQueue.first;
      return null;
    }
    return queue.cast<ClinicVisit?>().firstWhere(
          (v) => v?.id == activeVisitId,
          orElse: () => inExaminationQueue.isNotEmpty
              ? inExaminationQueue.first
              : (waitingQueue.isNotEmpty ? waitingQueue.first : null),
        );
  }

  PatientProfile? get activePatient {
    final actVisit = activeVisit;
    final patId = activePatientId ?? actVisit?.patientId;
    if (patId == null) return null;
    return patients.cast<PatientProfile?>().firstWhere(
          (p) => p?.id == patId,
          orElse: () => null,
        );
  }

  ClinicLoaded copyWith({
    List<ClinicVisit>? queue,
    List<PatientProfile>? patients,
    List<ToothChartEntry>? activeToothChart,
    int? rollingMeanWaitMinutes,
    String? activePatientId,
    String? activeVisitId,
  }) {
    return ClinicLoaded(
      queue: queue ?? this.queue,
      patients: patients ?? this.patients,
      activeToothChart: activeToothChart ?? this.activeToothChart,
      rollingMeanWaitMinutes: rollingMeanWaitMinutes ?? this.rollingMeanWaitMinutes,
      activePatientId: activePatientId ?? this.activePatientId,
      activeVisitId: activeVisitId ?? this.activeVisitId,
    );
  }

  @override
  List<Object?> get props => [
        queue,
        patients,
        activeToothChart,
        rollingMeanWaitMinutes,
        activePatientId,
        activeVisitId,
      ];
}

class ClinicError extends ClinicState {
  final String message;

  const ClinicError(this.message);

  @override
  List<Object?> get props => [message];
}
