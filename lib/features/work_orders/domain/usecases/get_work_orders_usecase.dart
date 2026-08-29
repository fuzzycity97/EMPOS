import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_order_ticket.dart';
import '../repositories/work_order_repository.dart';

class GetWorkOrdersUseCase {
  final WorkOrderRepository repository;

  GetWorkOrdersUseCase(this.repository);

  Future<Either<Failure, List<WorkOrderTicket>>> call({
    WorkOrderStage? stage,
    String? customerId,
    String? assignedStaffId,
  }) {
    return repository.getWorkOrders(
      stage: stage,
      customerId: customerId,
      assignedStaffId: assignedStaffId,
    );
  }
}
