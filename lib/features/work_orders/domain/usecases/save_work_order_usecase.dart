import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_order_ticket.dart';
import '../repositories/work_order_repository.dart';

class SaveWorkOrderUseCase {
  final WorkOrderRepository repository;

  SaveWorkOrderUseCase(this.repository);

  Future<Either<Failure, WorkOrderTicket>> call(WorkOrderTicket ticket) {
    return repository.saveWorkOrder(ticket);
  }
}
