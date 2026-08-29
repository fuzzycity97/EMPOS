import 'package:equatable/equatable.dart';
import '../../../pos/domain/entities/cart_item.dart';
import '../../../pos/domain/entities/order.dart';
import '../../../pos/domain/entities/payment_detail.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrdersEvent extends OrdersEvent {
  const LoadOrdersEvent();
}

class SearchOrdersEvent extends OrdersEvent {
  final String query;

  const SearchOrdersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterOrdersByStatusEvent extends OrdersEvent {
  final OrderStatus? status;

  const FilterOrdersByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

class SelectOrderEvent extends OrdersEvent {
  final String? orderId;

  const SelectOrderEvent(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class SubmitRefundEvent extends OrdersEvent {
  final String orderId;
  final List<CartItem> refundedItems;
  final TenderType refundTender;
  final String reason;
  final String? cashierId;

  const SubmitRefundEvent({
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

class DismissRefundReceiptEvent extends OrdersEvent {
  const DismissRefundReceiptEvent();
}
