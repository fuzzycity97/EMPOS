import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../pos/data/datasources/pos_local_data_source.dart';
import '../../../pos/domain/entities/order.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../../domain/entities/cash_transaction.dart';
import '../../domain/entities/shift.dart';
import '../../domain/entities/z_report.dart';
import '../../domain/repositories/shift_repository.dart';
import '../datasources/shift_local_data_source.dart';
import '../models/cash_transaction_model.dart';
import '../models/shift_model.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final ShiftLocalDataSource localDataSource;
  final PosLocalDataSource posLocalDataSource;

  ShiftRepositoryImpl({
    required this.localDataSource,
    required this.posLocalDataSource,
  });

  @override
  Future<Either<Failure, Shift?>> getCurrentShift() async {
    try {
      final shift = await localDataSource.getActiveShift();
      if (shift == null) return const Right(null);

      // Dynamically compute expected cash up to current moment
      final zReport = await _buildZReportForShift(shift);
      final updated = shift.copyWith(expectedCash: zReport.expectedCash);
      return Right(updated);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get active shift: $e'));
    }
  }

  @override
  Future<Either<Failure, Shift>> openShift({
    required String cashierId,
    String? cashierName,
    required double startingCash,
    String? notes,
  }) async {
    try {
      final active = await localDataSource.getActiveShift();
      if (active != null) {
        return const Left(
          CacheFailure(message: 'A shift is already open. Please close it first.'),
        );
      }

      final newShift = ShiftModel(
        id: 'SHIFT-${DateTime.now().millisecondsSinceEpoch}',
        cashierId: cashierId,
        cashierName: cashierName,
        startTime: DateTime.now(),
        startingCash: startingCash,
        expectedCash: startingCash,
        status: ShiftStatus.open,
        notes: notes,
      );

      await localDataSource.saveShift(newShift);
      await localDataSource.setActiveShiftId(newShift.id);

      return Right(newShift);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to open shift: $e'));
    }
  }

  @override
  Future<Either<Failure, Shift>> closeShift({
    required String shiftId,
    required double actualCash,
    String? notes,
  }) async {
    try {
      final shift = await localDataSource.getShiftById(shiftId);
      if (shift == null) {
        return const Left(CacheFailure(message: 'Shift not found.'));
      }

      final zReport = await _buildZReportForShift(shift);
      final difference = actualCash - zReport.expectedCash;

      final closedShift = shift.copyWith(
        endTime: DateTime.now(),
        status: ShiftStatus.closed,
        expectedCash: zReport.expectedCash,
        actualCash: actualCash,
        difference: difference,
        notes: notes ?? shift.notes,
      );

      final model = ShiftModel.fromEntity(closedShift);
      await localDataSource.saveShift(model);
      await localDataSource.setActiveShiftId(null);

      return Right(closedShift);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to close shift: $e'));
    }
  }

  @override
  Future<Either<Failure, CashTransaction>> addCashTransaction({
    required String shiftId,
    required CashTransactionType type,
    required double amount,
    required String reason,
  }) async {
    try {
      final tx = CashTransactionModel(
        id: 'CTX-${DateTime.now().millisecondsSinceEpoch}',
        shiftId: shiftId,
        type: type,
        amount: amount,
        reason: reason,
        timestamp: DateTime.now(),
      );

      await localDataSource.saveCashTransaction(tx);
      return Right(tx);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to record cash transaction: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CashTransaction>>> getCashTransactions(
    String shiftId,
  ) async {
    try {
      final list = await localDataSource.getCashTransactionsForShift(shiftId);
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get cash transactions: $e'));
    }
  }

  @override
  Future<Either<Failure, ZReport>> generateZReport(String shiftId) async {
    try {
      final shift = await localDataSource.getShiftById(shiftId);
      if (shift == null) {
        return const Left(CacheFailure(message: 'Shift not found.'));
      }

      final zReport = await _buildZReportForShift(shift);
      return Right(zReport);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to generate Z-Report: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Shift>>> getShiftHistory() async {
    try {
      final list = await localDataSource.getAllShifts();
      return Right(list);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to get shift history: $e'));
    }
  }

  Future<ZReport> _buildZReportForShift(Shift shift) async {
    final endTime = shift.endTime ?? DateTime.now();
    final orders = await posLocalDataSource.getOrders();
    final cashTransactions =
        await localDataSource.getCashTransactionsForShift(shift.id);

    // Filter orders belonging to this shift window
    final shiftOrders = orders.where((o) {
      final created = o.createdAt;
      return created.isAfter(shift.startTime.subtract(const Duration(seconds: 1))) &&
          created.isBefore(endTime.add(const Duration(seconds: 1)));
    }).toList();

    int totalOrdersCount = 0;
    double grossSales = 0.0;
    double netSales = 0.0;
    double totalDiscounts = 0.0;
    double totalTax = 0.0;
    double totalCashSales = 0.0;
    double totalCardSales = 0.0;
    double totalInstapaySales = 0.0;
    double totalVodafoneSales = 0.0;
    double totalCustomerAccountSales = 0.0;
    double totalRefunds = 0.0;

    for (final order in shiftOrders) {
      if (order.status == OrderStatus.refunded) {
        totalRefunds += order.totalPaid;
        continue;
      }

      if (order.status == OrderStatus.paid) {
        totalOrdersCount++;
        grossSales += order.cart.subtotal;
        totalDiscounts += order.cart.discountAmount;
        totalTax += order.cart.taxAmount;
        netSales += order.cart.grandTotal;

        for (final payment in order.payments) {
          switch (payment.tenderType) {
            case TenderType.cash:
              // Net cash added to drawer = cash received - change given
              final netCash = payment.amount - order.changeGiven;
              totalCashSales += netCash;
              break;
            case TenderType.card:
              totalCardSales += payment.amount;
              break;
            case TenderType.instapay:
              totalInstapaySales += payment.amount;
              break;
            case TenderType.vodafoneCash:
              totalVodafoneSales += payment.amount;
              break;
            case TenderType.customerAccount:
              totalCustomerAccountSales += payment.amount;
              break;
          }
        }
      }
    }

    double totalPayIns = 0.0;
    double totalPayOuts = 0.0;

    for (final tx in cashTransactions) {
      if (tx.isPayIn) {
        totalPayIns += tx.amount;
      } else if (tx.isPayOut) {
        totalPayOuts += tx.amount;
      }
    }

    // Expected Drawer Cash Math: Starting Cash + Cash Sales + Pay-Ins - Pay-Outs - Refunds
    final expectedCash = (shift.startingCash +
            totalCashSales +
            totalPayIns -
            totalPayOuts -
            totalRefunds)
        .clamp(0.0, 99999999.0);

    final difference = shift.actualCash != null
        ? (shift.actualCash! - expectedCash)
        : 0.0;

    return ZReport(
      shift: shift,
      totalOrdersCount: totalOrdersCount,
      grossSales: grossSales,
      netSales: netSales,
      totalDiscounts: totalDiscounts,
      totalTax: totalTax,
      totalCashSales: totalCashSales,
      totalCardSales: totalCardSales,
      totalInstapaySales: totalInstapaySales,
      totalVodafoneSales: totalVodafoneSales,
      totalCustomerAccountSales: totalCustomerAccountSales,
      totalPayIns: totalPayIns,
      totalPayOuts: totalPayOuts,
      totalRefunds: totalRefunds,
      openingCash: shift.startingCash,
      expectedCash: expectedCash,
      actualCash: shift.actualCash,
      difference: difference,
      generatedAt: DateTime.now(),
    );
  }
}
