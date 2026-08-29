import '../../domain/entities/work_order_ticket.dart';

class WorkOrderStageRecordModel extends WorkOrderStageRecord {
  const WorkOrderStageRecordModel({
    required super.stage,
    required super.timestamp,
    super.notes,
    super.updatedBy,
  });

  factory WorkOrderStageRecordModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderStageRecordModel(
      stage: WorkOrderStage.fromString(json['stage']?.toString()),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      notes: json['notes']?.toString(),
      updatedBy: json['updatedBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stage': stage.name,
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'updatedBy': updatedBy,
    };
  }

  factory WorkOrderStageRecordModel.fromEntity(WorkOrderStageRecord entity) {
    return WorkOrderStageRecordModel(
      stage: entity.stage,
      timestamp: entity.timestamp,
      notes: entity.notes,
      updatedBy: entity.updatedBy,
    );
  }
}

class WorkOrderTicketModel extends WorkOrderTicket {
  const WorkOrderTicketModel({
    required super.id,
    required super.title,
    required super.customerId,
    required super.customerName,
    super.customerPhone,
    super.assignedStaffId,
    super.assignedStaffName,
    super.currentStage = WorkOrderStage.intake,
    super.stagesHistory = const [],
    super.customMetadata = const {},
    super.totalEstimate = 0.0,
    super.depositPaid = 0.0,
    required super.createdAt,
    super.targetCompletionDate,
  });

  factory WorkOrderTicketModel.fromJson(Map<String, dynamic> json) {
    return WorkOrderTicketModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      customerName: json['customerName']?.toString() ?? '',
      customerPhone: json['customerPhone']?.toString(),
      assignedStaffId: json['assignedStaffId']?.toString(),
      assignedStaffName: json['assignedStaffName']?.toString(),
      currentStage: WorkOrderStage.fromString(json['currentStage']?.toString()),
      stagesHistory: (json['stagesHistory'] as List<dynamic>?)
              ?.map((e) => WorkOrderStageRecordModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      customMetadata: (json['customMetadata'] is Map)
          ? Map<String, dynamic>.from(json['customMetadata'] as Map)
          : const {},
      totalEstimate: (json['totalEstimate'] as num?)?.toDouble() ?? 0.0,
      depositPaid: (json['depositPaid'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      targetCompletionDate: DateTime.tryParse(json['targetCompletionDate']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'customerId': customerId,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'assignedStaffId': assignedStaffId,
      'assignedStaffName': assignedStaffName,
      'currentStage': currentStage.name,
      'stagesHistory': stagesHistory
          .map((s) => s is WorkOrderStageRecordModel
              ? s.toJson()
              : WorkOrderStageRecordModel.fromEntity(s).toJson())
          .toList(),
      'customMetadata': customMetadata,
      'totalEstimate': totalEstimate,
      'depositPaid': depositPaid,
      'createdAt': createdAt.toIso8601String(),
      'targetCompletionDate': targetCompletionDate?.toIso8601String(),
    };
  }

  factory WorkOrderTicketModel.fromEntity(WorkOrderTicket entity) {
    return WorkOrderTicketModel(
      id: entity.id,
      title: entity.title,
      customerId: entity.customerId,
      customerName: entity.customerName,
      customerPhone: entity.customerPhone,
      assignedStaffId: entity.assignedStaffId,
      assignedStaffName: entity.assignedStaffName,
      currentStage: entity.currentStage,
      stagesHistory: entity.stagesHistory,
      customMetadata: entity.customMetadata,
      totalEstimate: entity.totalEstimate,
      depositPaid: entity.depositPaid,
      createdAt: entity.createdAt,
      targetCompletionDate: entity.targetCompletionDate,
    );
  }
}
