import 'package:equatable/equatable.dart';
import '../../domain/entities/work_order_ticket.dart';

abstract class WorkOrderState extends Equatable {
  const WorkOrderState();

  @override
  List<Object?> get props => [];
}

class WorkOrderInitial extends WorkOrderState {}

class WorkOrderLoading extends WorkOrderState {}

class WorkOrderLoaded extends WorkOrderState {
  final List<WorkOrderTicket> tickets;
  final Map<WorkOrderStage, List<WorkOrderTicket>> pipeline;

  const WorkOrderLoaded({
    required this.tickets,
    required this.pipeline,
  });

  @override
  List<Object?> get props => [tickets, pipeline];
}

class WorkOrderError extends WorkOrderState {
  final String message;

  const WorkOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
