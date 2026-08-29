import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../pos/domain/entities/order.dart';
import '../entities/orders_filter.dart';
import '../repositories/orders_repository.dart';

class GetOrdersHistoryUseCase {
  final OrdersRepository repository;

  GetOrdersHistoryUseCase(this.repository);

  Future<Either<Failure, List<PosOrder>>> call({OrdersFilter? filter}) async {
    return await repository.getOrdersHistory(filter: filter);
  }
}
