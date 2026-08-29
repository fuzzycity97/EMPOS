import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_order_ticket.dart';
import '../repositories/work_order_repository.dart';

class TransitionStageUseCase {
  final WorkOrderRepository repository;

  TransitionStageUseCase(this.repository);

  Future<Either<Failure, WorkOrderTicket>> call(
    String id,
    WorkOrderStage newStage, {
    String? notes,
    String? updatedBy,
  }) {
    return repository.transitionStage(
      id,
      newStage,
      notes: notes,
      updatedBy: updatedBy,
    );
  }
}
