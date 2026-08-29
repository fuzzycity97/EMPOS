import 'package:equatable/equatable.dart';

enum TreatmentPlanStatus {
  active,
  completed,
  cancelled;

  static TreatmentPlanStatus fromString(String? val) {
    if (val == null) return TreatmentPlanStatus.active;
    final lower = val.toLowerCase();
    for (final s in TreatmentPlanStatus.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return TreatmentPlanStatus.active;
  }
}

class DentalTreatmentStage extends Equatable {
  final int stageNumber;
  final String title;
  final String procedureCode;
  final double fee;
  final bool isCompleted;
  final DateTime? completionDate;

  const DentalTreatmentStage({
    required this.stageNumber,
    required this.title,
    required this.procedureCode,
    required this.fee,
    this.isCompleted = false,
    this.completionDate,
  });

  DentalTreatmentStage copyWith({
    int? stageNumber,
    String? title,
    String? procedureCode,
    double? fee,
    bool? isCompleted,
    DateTime? completionDate,
  }) {
    return DentalTreatmentStage(
      stageNumber: stageNumber ?? this.stageNumber,
      title: title ?? this.title,
      procedureCode: procedureCode ?? this.procedureCode,
      fee: fee ?? this.fee,
      isCompleted: isCompleted ?? this.isCompleted,
      completionDate: completionDate ?? this.completionDate,
    );
  }

  @override
  List<Object?> get props => [
        stageNumber,
        title,
        procedureCode,
        fee,
        isCompleted,
        completionDate,
      ];
}

class DentalTreatmentPlan extends Equatable {
  final String id;
  final String patientId;
  final String title;
  final List<DentalTreatmentStage> stages;
  final double totalFee;
  final TreatmentPlanStatus status;
  final DateTime createdAt;

  const DentalTreatmentPlan({
    required this.id,
    required this.patientId,
    required this.title,
    required this.stages,
    required this.totalFee,
    this.status = TreatmentPlanStatus.active,
    required this.createdAt,
  });

  int get completedStagesCount => stages.where((s) => s.isCompleted).length;
  bool get isFullyCompleted => stages.isNotEmpty && stages.every((s) => s.isCompleted);

  DentalTreatmentPlan copyWith({
    String? id,
    String? patientId,
    String? title,
    List<DentalTreatmentStage>? stages,
    double? totalFee,
    TreatmentPlanStatus? status,
    DateTime? createdAt,
  }) {
    return DentalTreatmentPlan(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      title: title ?? this.title,
      stages: stages ?? this.stages,
      totalFee: totalFee ?? this.totalFee,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        patientId,
        title,
        stages,
        totalFee,
        status,
        createdAt,
      ];
}
