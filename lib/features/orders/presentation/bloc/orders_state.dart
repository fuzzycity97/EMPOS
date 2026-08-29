import 'package:equatable/equatable.dart';
import '../../../pos/domain/entities/order.dart';
import '../../domain/entities/refund_transaction.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

class OrdersLoaded extends OrdersState {
  final List<PosOrder> allOrders;
  final List<PosOrder> displayedOrders;
  final String searchQuery;
  final OrderStatus? selectedStatus;
  final PosOrder? selectedOrder;
  final bool isProcessingRefund;
  final RefundTransaction? lastRefundTransaction;
  final String? toastMessage;

  const OrdersLoaded({
    required this.allOrders,
    required this.displayedOrders,
    this.searchQuery = '',
    this.selectedStatus,
    this.selectedOrder,
    this.isProcessingRefund = false,
    this.lastRefundTransaction,
    this.toastMessage,
  });

  OrdersLoaded copyWith({
    List<PosOrder>? allOrders,
    List<PosOrder>? displayedOrders,
    String? searchQuery,
    OrderStatus? selectedStatus,
    bool clearStatus = false,
    PosOrder? selectedOrder,
    bool clearSelectedOrder = false,
    bool? isProcessingRefund,
    RefundTransaction? lastRefundTransaction,
    bool clearLastRefund = false,
    String? toastMessage,
    bool clearToast = false,
  }) {
    return OrdersLoaded(
      allOrders: allOrders ?? this.allOrders,
      displayedOrders: displayedOrders ?? this.displayedOrders,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: clearStatus ? null : (selectedStatus ?? this.selectedStatus),
      selectedOrder: clearSelectedOrder ? null : (selectedOrder ?? this.selectedOrder),
      isProcessingRefund: isProcessingRefund ?? this.isProcessingRefund,
      lastRefundTransaction: clearLastRefund ? null : (lastRefundTransaction ?? this.lastRefundTransaction),
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    );
  }

  @override
  List<Object?> get props => [
        allOrders,
        displayedOrders,
        searchQuery,
        selectedStatus,
        selectedOrder,
        isProcessingRefund,
        lastRefundTransaction,
        toastMessage,
      ];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
