import 'package:equatable/equatable.dart';
import '../../../pos/domain/entities/cart_item.dart';
import '../../../pos/domain/entities/payment_detail.dart';

class RefundTransaction extends Equatable {
  final String id;
  final String refundNumber;
  final String originalOrderId;
  final String originalOrderNumber;
  final List<CartItem> refundedItems;
  final double refundTotal;
  final TenderType refundTender;
  final String reason;
  final String? cashierId;
  final DateTime createdAt;

  const RefundTransaction({
    required this.id,
    required this.refundNumber,
    required this.originalOrderId,
    required this.originalOrderNumber,
    required this.refundedItems,
    required this.refundTotal,
    required this.refundTender,
    required this.reason,
    this.cashierId,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        refundNumber,
        originalOrderId,
        originalOrderNumber,
        refundedItems,
        refundTotal,
        refundTender,
        reason,
        cashierId,
        createdAt,
      ];
}
