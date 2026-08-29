import '../../domain/entities/dental_treatment_plan.dart';

class DentalTreatmentStageModel extends DentalTreatmentStage {
  const DentalTreatmentStageModel({
    required super.stageNumber,
    required super.title,
    required super.procedureCode,
    required super.fee,
    super.isCompleted = false,
    super.completionDate,
  });

  factory DentalTreatmentStageModel.fromJson(Map<String, dynamic> json) {
    return DentalTreatmentStageModel(
      stageNumber: (json['stageNumber'] as num?)?.toInt() ?? 1,
      title: json['title']?.toString() ?? '',
      procedureCode: json['procedureCode']?.toString() ?? '',
      fee: (json['fee'] as num?)?.toDouble() ?? 0.0,
      isCompleted: json['isCompleted'] == true,
      completionDate: DateTime.tryParse(json['completionDate']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stageNumber': stageNumber,
      'title': title,
      'procedureCode': procedureCode,
      'fee': fee,
      'isCompleted': isCompleted,
      'completionDate': completionDate?.toIso8601String(),
    };
  }

  factory DentalTreatmentStageModel.fromEntity(DentalTreatmentStage entity) {
    return DentalTreatmentStageModel(
      stageNumber: entity.stageNumber,
      title: entity.title,
      procedureCode: entity.procedureCode,
      fee: entity.fee,
      isCompleted: entity.isCompleted,
      completionDate: entity.completionDate,
    );
  }
}

class DentalTreatmentPlanModel extends DentalTreatmentPlan {
  const DentalTreatmentPlanModel({
    required super.id,
    required super.patientId,
    required super.title,
    required super.stages,
    required super.totalFee,
    super.status = TreatmentPlanStatus.active,
    required super.createdAt,
  });

  factory DentalTreatmentPlanModel.fromJson(Map<String, dynamic> json) {
    return DentalTreatmentPlanModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patientId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      stages: (json['stages'] as List<dynamic>?)
              ?.map((e) => DentalTreatmentStageModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      totalFee: (json['totalFee'] as num?)?.toDouble() ?? 0.0,
      status: TreatmentPlanStatus.fromString(json['status']?.toString()),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'title': title,
      'stages': stages
          .map((s) => s is DentalTreatmentStageModel
              ? s.toJson()
              : DentalTreatmentStageModel.fromEntity(s).toJson())
          .toList(),
      'totalFee': totalFee,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DentalTreatmentPlanModel.fromEntity(DentalTreatmentPlan entity) {
    return DentalTreatmentPlanModel(
      id: entity.id,
      patientId: entity.patientId,
      title: entity.title,
      stages: entity.stages,
      totalFee: entity.totalFee,
      status: entity.status,
      createdAt: entity.createdAt,
    );
  }
}
