import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../pos/domain/entities/cart_item.dart';
import '../../../pos/domain/entities/order.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../entities/orders_filter.dart';
import '../entities/refund_transaction.dart';

abstract class OrdersRepository {
  Future<Either<Failure, List<PosOrder>>> getOrdersHistory({OrdersFilter? filter});

  Future<Either<Failure, PosOrder>> getOrderById(String orderId);

  Future<Either<Failure, RefundTransaction>> processRefund({
    required String orderId,
    required List<CartItem> refundedItems,
    required TenderType refundTender,
    required String reason,
    String? cashierId,
  });

  Future<Either<Failure, List<RefundTransaction>>> getRefundTransactions({
    String? orderId,
  });
}
