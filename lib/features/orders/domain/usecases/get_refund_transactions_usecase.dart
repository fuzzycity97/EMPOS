import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/refund_transaction.dart';
import '../repositories/orders_repository.dart';

class GetRefundTransactionsUseCase {
  final OrdersRepository repository;

  GetRefundTransactionsUseCase(this.repository);

  Future<Either<Failure, List<RefundTransaction>>> call({String? orderId}) async {
    return await repository.getRefundTransactions(orderId: orderId);
  }
}
