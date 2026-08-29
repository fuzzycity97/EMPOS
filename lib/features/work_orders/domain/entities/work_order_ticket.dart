import 'package:equatable/equatable.dart';

enum WorkOrderStage {
  intake('Intake / Checked In'),
  inspection('Diagnosis / Inspection'),
  inProgress('In Progress / Service'),
  qualityCheck('Quality Check & Testing'),
  ready('Ready for Pickup / Closing'),
  delivered('Delivered / Completed'),
  cancelled('Cancelled');

  final String label;
  const WorkOrderStage(this.label);

  static WorkOrderStage fromString(String? val) {
    if (val == null) return WorkOrderStage.intake;
    final lower = val.toLowerCase().replaceAll('_', '').replaceAll(' ', '');
    for (final s in WorkOrderStage.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return WorkOrderStage.intake;
  }
}

class WorkOrderStageRecord extends Equatable {
  final WorkOrderStage stage;
  final DateTime timestamp;
  final String? notes;
  final String? updatedBy;

  const WorkOrderStageRecord({
    required this.stage,
    required this.timestamp,
    this.notes,
    this.updatedBy,
  });

  WorkOrderStageRecord copyWith({
    WorkOrderStage? stage,
    DateTime? timestamp,
    String? notes,
    String? updatedBy,
  }) {
    return WorkOrderStageRecord(
      stage: stage ?? this.stage,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [stage, timestamp, notes, updatedBy];
}

class WorkOrderTicket extends Equatable {
  final String id;
  final String title;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? assignedStaffId;
  final String? assignedStaffName;
  final WorkOrderStage currentStage;
  final List<WorkOrderStageRecord> stagesHistory;
  final Map<String, dynamic> customMetadata; // VIN, Mileage, CaseNumber, PropertyAddress
  final double totalEstimate;
  final double depositPaid;
  final DateTime createdAt;
  final DateTime? targetCompletionDate;

  const WorkOrderTicket({
    required this.id,
    required this.title,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.assignedStaffId,
    this.assignedStaffName,
    this.currentStage = WorkOrderStage.intake,
    this.stagesHistory = const [],
    this.customMetadata = const {},
    this.totalEstimate = 0.0,
    this.depositPaid = 0.0,
    required this.createdAt,
    this.targetCompletionDate,
  });

  double get balanceDue => (totalEstimate - depositPaid).clamp(0.0, double.infinity);
  bool get isClosed =>
      currentStage == WorkOrderStage.delivered || currentStage == WorkOrderStage.cancelled;

  WorkOrderTicket copyWith({
    String? id,
    String? title,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? assignedStaffId,
    String? assignedStaffName,
    WorkOrderStage? currentStage,
    List<WorkOrderStageRecord>? stagesHistory,
    Map<String, dynamic>? customMetadata,
    double? totalEstimate,
    double? depositPaid,
    DateTime? createdAt,
    DateTime? targetCompletionDate,
  }) {
    return WorkOrderTicket(
      id: id ?? this.id,
      title: title ?? this.title,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      currentStage: currentStage ?? this.currentStage,
      stagesHistory: stagesHistory ?? this.stagesHistory,
      customMetadata: customMetadata ?? this.customMetadata,
      totalEstimate: totalEstimate ?? this.totalEstimate,
      depositPaid: depositPaid ?? this.depositPaid,
      createdAt: createdAt ?? this.createdAt,
      targetCompletionDate: targetCompletionDate ?? this.targetCompletionDate,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        customerId,
        customerName,
        customerPhone,
        assignedStaffId,
        assignedStaffName,
        currentStage,
        stagesHistory,
        customMetadata,
        totalEstimate,
        depositPaid,
        createdAt,
        targetCompletionDate,
      ];
}
