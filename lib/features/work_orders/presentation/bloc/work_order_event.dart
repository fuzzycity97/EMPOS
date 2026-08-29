import 'package:equatable/equatable.dart';
import '../../domain/entities/work_order_ticket.dart';

abstract class WorkOrderEvent extends Equatable {
  const WorkOrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadWorkOrdersEvent extends WorkOrderEvent {
  final WorkOrderStage? stage;
  final String? customerId;
  final String? assignedStaffId;

  const LoadWorkOrdersEvent({this.stage, this.customerId, this.assignedStaffId});

  @override
  List<Object?> get props => [stage, customerId, assignedStaffId];
}

class CreateWorkOrderEvent extends WorkOrderEvent {
  final WorkOrderTicket ticket;

  const CreateWorkOrderEvent(this.ticket);

  @override
  List<Object?> get props => [ticket];
}

class AdvanceStageEvent extends WorkOrderEvent {
  final String ticketId;
  final WorkOrderStage newStage;
  final String? note;
  final String? updatedBy;

  const AdvanceStageEvent({
    required this.ticketId,
    required this.newStage,
    this.note,
    this.updatedBy,
  });

  @override
  List<Object?> get props => [ticketId, newStage, note, updatedBy];
}
