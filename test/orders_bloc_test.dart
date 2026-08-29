import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/orders/domain/entities/orders_filter.dart';
import 'package:empos/features/orders/domain/entities/refund_transaction.dart';
import 'package:empos/features/orders/domain/usecases/get_order_by_id_usecase.dart';
import 'package:empos/features/orders/domain/usecases/get_orders_history_usecase.dart';
import 'package:empos/features/orders/domain/usecases/get_refund_transactions_usecase.dart';
import 'package:empos/features/orders/domain/usecases/process_refund_usecase.dart';
import 'package:empos/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:empos/features/orders/presentation/bloc/orders_event.dart';
import 'package:empos/features/orders/presentation/bloc/orders_state.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/order.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';

class MockGetOrdersHistoryUseCase extends Mock implements GetOrdersHistoryUseCase {}
class MockGetOrderByIdUseCase extends Mock implements GetOrderByIdUseCase {}
class MockProcessRefundUseCase extends Mock implements ProcessRefundUseCase {}
class MockGetRefundTransactionsUseCase extends Mock implements GetRefundTransactionsUseCase {}

void main() {
  late MockGetOrdersHistoryUseCase mockGetOrdersHistory;
  late MockGetOrderByIdUseCase mockGetOrderById;
  late MockProcessRefundUseCase mockProcessRefund;
  late MockGetRefundTransactionsUseCase mockGetRefundTransactions;
  late OrdersBloc ordersBloc;

  const tProduct = Product(
    id: 'p-1',
    nameEn: 'Espresso',
    categoryId: 'cat-1',
    price: 40.0,
    stock: 50,
    barcode: '622000',
  );

  final tOrder = PosOrder(
    id: 'ORD-1',
    orderNumber: 'TXN-001',
    cart: const Cart(
      items: [
        CartItem(product: tProduct, quantity: 1, unitPrice: 40.0),
      ],
      taxRate: 0.0,
    ),
    payments: const [
      PaymentDetail(tenderType: TenderType.cash, amount: 40.0),
    ],
    status: OrderStatus.paid,
    createdAt: DateTime(2026, 8, 28, 12, 0),
  );

  final tRefundTx = RefundTransaction(
    id: 'REF-1',
    refundNumber: 'RET-001',
    originalOrderId: 'ORD-1',
    originalOrderNumber: 'TXN-001',
    refundedItems: const [
      CartItem(product: tProduct, quantity: 1, unitPrice: 40.0),
    ],
    refundTotal: 40.0,
    refundTender: TenderType.cash,
    reason: 'Customer return',
    createdAt: DateTime(2026, 8, 28, 12, 30),
  );

  setUpAll(() {
    registerFallbackValue(const OrdersFilter());
    registerFallbackValue(const ProcessRefundParams(
      orderId: 'ORD-1',
      refundedItems: [],
      refundTender: TenderType.cash,
      reason: 'test',
    ));
  });

  setUp(() {
    mockGetOrdersHistory = MockGetOrdersHistoryUseCase();
    mockGetOrderById = MockGetOrderByIdUseCase();
    mockProcessRefund = MockProcessRefundUseCase();
    mockGetRefundTransactions = MockGetRefundTransactionsUseCase();

    ordersBloc = OrdersBloc(
      getOrdersHistoryUseCase: mockGetOrdersHistory,
      getOrderByIdUseCase: mockGetOrderById,
      processRefundUseCase: mockProcessRefund,
      getRefundTransactionsUseCase: mockGetRefundTransactions,
    );
  });

  tearDown(() {
    ordersBloc.close();
  });

  group('OrdersBloc Tests', () {
    test('initial state should be OrdersInitial', () {
      expect(ordersBloc.state, equals(const OrdersInitial()));
    });

    blocTest<OrdersBloc, OrdersState>(
      'emits [OrdersLoading, OrdersLoaded] when LoadOrdersEvent succeeds',
      build: () {
        when(() => mockGetOrdersHistory(filter: any(named: 'filter')))
            .thenAnswer((_) async => Right([tOrder]));
        return ordersBloc;
      },
      act: (b) => b.add(const LoadOrdersEvent()),
      expect: () => [
        const OrdersLoading(),
        OrdersLoaded(allOrders: [tOrder], displayedOrders: [tOrder]),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'filters displayed orders when SearchOrdersEvent is triggered',
      build: () {
        when(() => mockGetOrdersHistory(filter: any(named: 'filter')))
            .thenAnswer((_) async => Right([tOrder]));
        return ordersBloc;
      },
      seed: () => OrdersLoaded(allOrders: [tOrder], displayedOrders: [tOrder]),
      act: (b) => b.add(const SearchOrdersEvent('TXN-001')),
      expect: () => [
        OrdersLoaded(
          allOrders: [tOrder],
          displayedOrders: [tOrder],
          searchQuery: 'TXN-001',
        ),
      ],
    );

    blocTest<OrdersBloc, OrdersState>(
      'processes refund and emits updated OrdersLoaded with lastRefundTransaction',
      build: () {
        when(() => mockProcessRefund(any())).thenAnswer((_) async => Right(tRefundTx));
        when(() => mockGetOrdersHistory()).thenAnswer((_) async => Right([
          tOrder.copyWith(status: OrderStatus.refunded),
        ]));
        return ordersBloc;
      },
      seed: () => OrdersLoaded(allOrders: [tOrder], displayedOrders: [tOrder]),
      act: (b) => b.add(SubmitRefundEvent(
        orderId: 'ORD-1',
        refundedItems: const [
          CartItem(product: tProduct, quantity: 1, unitPrice: 40.0),
        ],
        refundTender: TenderType.cash,
        reason: 'Customer return',
      )),
      expect: () => [
        OrdersLoaded(
          allOrders: [tOrder],
          displayedOrders: [tOrder],
          isProcessingRefund: true,
        ),
        OrdersLoaded(
          allOrders: [tOrder.copyWith(status: OrderStatus.refunded)],
          displayedOrders: [tOrder.copyWith(status: OrderStatus.refunded)],
          isProcessingRefund: false,
          lastRefundTransaction: tRefundTx,
          toastMessage: 'Refund #RET-001 processed successfully.',
        ),
      ],
    );
  });
}
