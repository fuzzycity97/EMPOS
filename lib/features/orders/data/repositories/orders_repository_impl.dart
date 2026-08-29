import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../catalog/data/datasources/catalog_local_data_source.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../../pos/data/models/order_model.dart';
import '../../../pos/domain/entities/cart_item.dart';
import '../../../pos/domain/entities/order.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../../../shift/data/datasources/shift_local_data_source.dart';
import '../../../shift/data/models/cash_transaction_model.dart';
import '../../../shift/domain/entities/cash_transaction.dart';
import '../../domain/entities/orders_filter.dart';
import '../../domain/entities/refund_transaction.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_local_data_source.dart';
import '../models/refund_transaction_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersLocalDataSource localDataSource;
  final CatalogLocalDataSource catalogLocalDataSource;
  final ShiftLocalDataSource shiftLocalDataSource;

  OrdersRepositoryImpl({
    required this.localDataSource,
    required this.catalogLocalDataSource,
    required this.shiftLocalDataSource,
  });

  @override
  Future<Either<Failure, List<PosOrder>>> getOrdersHistory({
    OrdersFilter? filter,
  }) async {
    try {
      final allOrders = await localDataSource.getAllOrders();
      List<PosOrder> filtered = List.from(allOrders);

      if (filter != null) {
        if (filter.status != null) {
          filtered = filtered.where((o) => o.status == filter.status).toList();
        }

        if (filter.dateFrom != null) {
          filtered = filtered.where((o) => o.createdAt.isAfter(filter.dateFrom!)).toList();
        }

        if (filter.dateTo != null) {
          filtered = filtered.where((o) => o.createdAt.isBefore(filter.dateTo!)).toList();
        }

        if (filter.searchQuery != null && filter.searchQuery!.trim().isNotEmpty) {
          final query = filter.searchQuery!.trim().toLowerCase();
          filtered = filtered.where((o) {
            final matchOrderNum = o.orderNumber.toLowerCase().contains(query);
            final matchPhone = o.customerPhone?.toLowerCase().contains(query) ?? false;
            final matchName = o.customerName?.toLowerCase().contains(query) ?? false;
            return matchOrderNum || matchPhone || matchName;
          }).toList();
        }

        if (filter.offset != null && filter.offset! > 0) {
          filtered = filtered.skip(filter.offset!).toList();
        }

        if (filter.limit != null && filter.limit! > 0) {
          filtered = filtered.take(filter.limit!).toList();
        }
      }

      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(filtered);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to fetch order history: $e'));
    }
  }

  @override
  Future<Either<Failure, PosOrder>> getOrderById(String orderId) async {
    try {
      final order = await localDataSource.getOrderById(orderId);
      if (order == null) {
        return const Left(CacheFailure(message: 'Order not found.'));
      }
      return Right(order);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve order: $e'));
    }
  }

  @override
  Future<Either<Failure, RefundTransaction>> processRefund({
    required String orderId,
    required List<CartItem> refundedItems,
    required TenderType refundTender,
    required String reason,
    String? cashierId,
  }) async {
    try {
      final order = await localDataSource.getOrderById(orderId);
      if (order == null) {
        return const Left(CacheFailure(message: 'Order not found.'));
      }

      if (order.status == OrderStatus.refunded) {
        return const Left(CacheFailure(message: 'Order has already been fully refunded.'));
      }

      if (refundedItems.isEmpty) {
        return const Left(CacheFailure(message: 'Please specify items to refund.'));
      }

      // 1. Calculate Refund Total
      double refundTotal = 0.0;
      final int totalOriginalCount = order.cart.items.fold(0, (sum, i) => sum + i.quantity);
      final int totalRefundCount = refundedItems.fold(0, (sum, i) => sum + i.quantity);

      if (totalRefundCount >= totalOriginalCount) {
        // Full Refund matches order's grand total
        refundTotal = order.cart.grandTotal;
      } else {
        // Partial Refund with proportionate tax calculation
        final double rawRefundSubtotal = refundedItems.fold(
          0.0,
          (sum, i) => sum + (i.unitPrice * i.quantity - i.itemDiscount),
        );
        final double taxMultiplier = 1.0 + order.cart.taxRate;
        refundTotal = (rawRefundSubtotal * taxMultiplier).clamp(0.0, order.cart.grandTotal);
      }

      // 2. Update Original Order Status
      final newStatus = totalRefundCount >= totalOriginalCount
          ? OrderStatus.refunded
          : OrderStatus.partiallyRefunded;

      final updatedOrder = PosOrderModel(
        id: order.id,
        orderNumber: order.orderNumber,
        cart: order.cart,
        payments: order.payments,
        status: newStatus,
        cashierId: order.cashierId,
        customerPhone: order.customerPhone,
        customerName: order.customerName,
        changeGiven: order.changeGiven,
        createdAt: order.createdAt,
      );

      await localDataSource.updateOrder(updatedOrder);

      // 3. Return Refunded Quantities Back to Catalog Inventory
      for (final item in refundedItems) {
        final product = await catalogLocalDataSource.getProductById(item.product.id);
        if (product.trackQty) {
          final updatedProduct = product.copyWith(
            stock: product.stock + item.quantity,
          );
          await catalogLocalDataSource.saveProduct(
            ProductModel.fromEntity(updatedProduct),
          );
        }
      }

      // 4. Record Cash Drawer Payout if Refunded in Cash
      if (refundTender == TenderType.cash) {
        final activeShift = await shiftLocalDataSource.getActiveShift();
        if (activeShift != null && activeShift.isOpen) {
          final cashTx = CashTransactionModel(
            id: 'CTX-REF-${DateTime.now().millisecondsSinceEpoch}',
            shiftId: activeShift.id,
            type: CashTransactionType.payOut,
            amount: refundTotal,
            reason: 'Refund for Order #${order.orderNumber}: $reason',
            timestamp: DateTime.now(),
          );
          await shiftLocalDataSource.saveCashTransaction(cashTx);
        }
      }

      // 5. Create & Save RefundTransaction
      final refundTx = RefundTransactionModel(
        id: 'REF-${DateTime.now().millisecondsSinceEpoch}',
        refundNumber: 'RET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        originalOrderId: order.id,
        originalOrderNumber: order.orderNumber,
        refundedItems: refundedItems,
        refundTotal: refundTotal,
        refundTender: refundTender,
        reason: reason,
        cashierId: cashierId ?? order.cashierId,
        createdAt: DateTime.now(),
      );

      await localDataSource.saveRefund(refundTx);

      return Right(refundTx);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to process refund: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RefundTransaction>>> getRefundTransactions({
    String? orderId,
  }) async {
    try {
      final all = await localDataSource.getAllRefunds();
      if (orderId != null && orderId.isNotEmpty) {
        return Right(all.where((r) => r.originalOrderId == orderId).toList());
      }
      return Right(all);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to fetch refund transactions: $e'));
    }
  }
}
