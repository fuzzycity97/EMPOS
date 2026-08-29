import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/work_order_ticket.dart';
import '../../domain/repositories/work_order_repository.dart';
import '../datasources/work_order_local_data_source.dart';
import '../models/work_order_ticket_model.dart';

class WorkOrderRepositoryImpl implements WorkOrderRepository {
  final WorkOrderLocalDataSource localDataSource;

  WorkOrderRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<WorkOrderTicket>>> getWorkOrders({
    WorkOrderStage? stage,
    String? customerId,
    String? assignedStaffId,
  }) async {
    try {
      final all = await localDataSource.getWorkOrders();
      var filtered = all.where((w) {
        if (stage != null && w.currentStage != stage) return false;
        if (customerId != null && customerId.isNotEmpty && w.customerId != customerId) return false;
        if (assignedStaffId != null && assignedStaffId.isNotEmpty && w.assignedStaffId != assignedStaffId) {
          return false;
        }
        return true;
      }).toList();

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(filtered);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error fetching work orders: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkOrderTicket?>> getWorkOrderById(String id) async {
    try {
      final ticket = await localDataSource.getWorkOrderById(id);
      return Right(ticket);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error retrieving work order $id: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkOrderTicket>> saveWorkOrder(WorkOrderTicket ticket) async {
    try {
      final model = WorkOrderTicketModel.fromEntity(ticket);
      await localDataSource.saveWorkOrder(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error saving work order: $e'));
    }
  }

  @override
  Future<Either<Failure, WorkOrderTicket>> transitionStage(
    String id,
    WorkOrderStage newStage, {
    String? notes,
    String? updatedBy,
  }) async {
    try {
      final existing = await localDataSource.getWorkOrderById(id);
      if (existing == null) {
        return Left(CacheFailure(message: 'Work order $id not found'));
      }

      final newRecord = WorkOrderStageRecord(
        stage: newStage,
        timestamp: DateTime.now(),
        notes: notes,
        updatedBy: updatedBy,
      );

      final updatedHistory = List<WorkOrderStageRecord>.from(existing.stagesHistory)..add(newRecord);

      final updatedTicket = existing.copyWith(
        currentStage: newStage,
        stagesHistory: updatedHistory,
      );

      final model = WorkOrderTicketModel.fromEntity(updatedTicket);
      await localDataSource.saveWorkOrder(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error transitioning work order stage: $e'));
    }
  }
}
