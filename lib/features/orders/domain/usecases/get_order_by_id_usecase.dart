import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../pos/domain/entities/order.dart';
import '../repositories/orders_repository.dart';

class GetOrderByIdUseCase {
  final OrdersRepository repository;

  GetOrderByIdUseCase(this.repository);

  Future<Either<Failure, PosOrder>> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}
