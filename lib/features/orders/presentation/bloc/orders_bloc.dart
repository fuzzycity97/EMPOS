import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../pos/domain/entities/order.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/get_orders_history_usecase.dart';
import '../../domain/usecases/get_refund_transactions_usecase.dart';
import '../../domain/usecases/process_refund_usecase.dart';
import 'orders_event.dart';
import 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final GetOrdersHistoryUseCase getOrdersHistoryUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final ProcessRefundUseCase processRefundUseCase;
  final GetRefundTransactionsUseCase getRefundTransactionsUseCase;

  OrdersBloc({
    required this.getOrdersHistoryUseCase,
    required this.getOrderByIdUseCase,
    required this.processRefundUseCase,
    required this.getRefundTransactionsUseCase,
  }) : super(const OrdersInitial()) {
    on<LoadOrdersEvent>(_onLoadOrders);
    on<SearchOrdersEvent>(_onSearchOrders);
    on<FilterOrdersByStatusEvent>(_onFilterByStatus);
    on<SelectOrderEvent>(_onSelectOrder);
    on<SubmitRefundEvent>(_onSubmitRefund);
    on<DismissRefundReceiptEvent>(_onDismissRefundReceipt);
  }

  Future<void> _onLoadOrders(
    LoadOrdersEvent event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const OrdersLoading());
    final result = await getOrdersHistoryUseCase();

    result.fold(
      (failure) => emit(OrdersError(failure.message)),
      (orders) {
        emit(
          OrdersLoaded(
            allOrders: orders,
            displayedOrders: orders,
          ),
        );
      },
    );
  }

  void _onSearchOrders(
    SearchOrdersEvent event,
    Emitter<OrdersState> emit,
  ) {
    if (state is! OrdersLoaded) return;
    final current = state as OrdersLoaded;

    final filtered = _filterOrders(
      allOrders: current.allOrders,
      query: event.query,
      status: current.selectedStatus,
    );

    emit(current.copyWith(
      searchQuery: event.query,
      displayedOrders: filtered,
    ));
  }

  void _onFilterByStatus(
    FilterOrdersByStatusEvent event,
    Emitter<OrdersState> emit,
  ) {
    if (state is! OrdersLoaded) return;
    final current = state as OrdersLoaded;

    final filtered = _filterOrders(
      allOrders: current.allOrders,
      query: current.searchQuery,
      status: event.status,
    );

    emit(current.copyWith(
      selectedStatus: event.status,
      clearStatus: event.status == null,
      displayedOrders: filtered,
    ));
  }

  Future<void> _onSelectOrder(
    SelectOrderEvent event,
    Emitter<OrdersState> emit,
  ) async {
    if (state is! OrdersLoaded) return;
    final current = state as OrdersLoaded;

    if (event.orderId == null) {
      emit(current.copyWith(clearSelectedOrder: true));
      return;
    }

    final result = await getOrderByIdUseCase(event.orderId!);
    result.fold(
      (failure) => emit(current.copyWith(toastMessage: failure.message)),
      (order) => emit(current.copyWith(selectedOrder: order)),
    );
  }

  Future<void> _onSubmitRefund(
    SubmitRefundEvent event,
    Emitter<OrdersState> emit,
  ) async {
    if (state is! OrdersLoaded) return;
    final current = state as OrdersLoaded;

    emit(current.copyWith(isProcessingRefund: true, clearToast: true));

    final result = await processRefundUseCase(
      ProcessRefundParams(
        orderId: event.orderId,
        refundedItems: event.refundedItems,
        refundTender: event.refundTender,
        reason: event.reason,
        cashierId: event.cashierId,
      ),
    );

    await result.fold(
      (failure) async {
        emit(current.copyWith(
          isProcessingRefund: false,
          toastMessage: failure.message,
        ));
      },
      (refundTx) async {
        // Refresh orders list to reflect restocked & refunded state
        final ordersResult = await getOrdersHistoryUseCase();
        final updatedOrders = ordersResult.getOrElse(() => current.allOrders);

        PosOrder? updatedSelectedOrder;
        if (current.selectedOrder?.id == event.orderId) {
          final selectedResult = await getOrderByIdUseCase(event.orderId);
          updatedSelectedOrder = selectedResult.getOrElse(() => current.selectedOrder!);
        }

        final filtered = _filterOrders(
          allOrders: updatedOrders,
          query: current.searchQuery,
          status: current.selectedStatus,
        );

        emit(current.copyWith(
          allOrders: updatedOrders,
          displayedOrders: filtered,
          selectedOrder: updatedSelectedOrder,
          isProcessingRefund: false,
          lastRefundTransaction: refundTx,
          toastMessage: 'Refund #${refundTx.refundNumber} processed successfully.',
        ));
      },
    );
  }

  void _onDismissRefundReceipt(
    DismissRefundReceiptEvent event,
    Emitter<OrdersState> emit,
  ) {
    if (state is! OrdersLoaded) return;
    final current = state as OrdersLoaded;
    emit(current.copyWith(clearLastRefund: true));
  }

  List<PosOrder> _filterOrders({
    required List<PosOrder> allOrders,
    required String query,
    required OrderStatus? status,
  }) {
    List<PosOrder> result = List.from(allOrders);

    if (status != null) {
      result = result.where((o) => o.status == status).toList();
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isNotEmpty) {
      result = result.where((o) {
        final matchNum = o.orderNumber.toLowerCase().contains(trimmed);
        final matchPhone = o.customerPhone?.toLowerCase().contains(trimmed) ?? false;
        final matchName = o.customerName?.toLowerCase().contains(trimmed) ?? false;
        final matchItem = o.cart.items.any((i) =>
            i.product.nameEn.toLowerCase().contains(trimmed) ||
            (i.product.nameAr?.toLowerCase().contains(trimmed) ?? false));
        return matchNum || matchPhone || matchName || matchItem;
      }).toList();
    }

    return result;
  }
}
