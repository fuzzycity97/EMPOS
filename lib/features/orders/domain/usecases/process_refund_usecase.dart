import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../pos/domain/entities/cart_item.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../entities/refund_transaction.dart';
import '../repositories/orders_repository.dart';

class ProcessRefundParams extends Equatable {
  final String orderId;
  final List<CartItem> refundedItems;
  final TenderType refundTender;
  final String reason;
  final String? cashierId;

  const ProcessRefundParams({
    required this.orderId,
    required this.refundedItems,
    required this.refundTender,
    required this.reason,
    this.cashierId,
  });

  @override
  List<Object?> get props => [
        orderId,
        refundedItems,
        refundTender,
        reason,
        cashierId,
      ];
}

class ProcessRefundUseCase {
  final OrdersRepository repository;

  ProcessRefundUseCase(this.repository);

  Future<Either<Failure, RefundTransaction>> call(
    ProcessRefundParams params,
  ) async {
    return await repository.processRefund(
      orderId: params.orderId,
      refundedItems: params.refundedItems,
      refundTender: params.refundTender,
      reason: params.reason,
      cashierId: params.cashierId,
    );
  }
}
