import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/work_order_ticket.dart';

abstract class WorkOrderRepository {
  Future<Either<Failure, List<WorkOrderTicket>>> getWorkOrders({
    WorkOrderStage? stage,
    String? customerId,
    String? assignedStaffId,
  });

  Future<Either<Failure, WorkOrderTicket?>> getWorkOrderById(String id);

  Future<Either<Failure, WorkOrderTicket>> saveWorkOrder(WorkOrderTicket ticket);

  Future<Either<Failure, WorkOrderTicket>> transitionStage(
    String id,
    WorkOrderStage newStage, {
    String? notes,
    String? updatedBy,
  });
}
