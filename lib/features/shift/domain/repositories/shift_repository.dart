import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cash_transaction.dart';
import '../entities/shift.dart';
import '../entities/z_report.dart';

abstract class ShiftRepository {
  Future<Either<Failure, Shift?>> getCurrentShift();

  Future<Either<Failure, Shift>> openShift({
    required String cashierId,
    String? cashierName,
    required double startingCash,
    String? notes,
  });

  Future<Either<Failure, Shift>> closeShift({
    required String shiftId,
    required double actualCash,
    String? notes,
  });

  Future<Either<Failure, CashTransaction>> addCashTransaction({
    required String shiftId,
    required CashTransactionType type,
    required double amount,
    required String reason,
  });

  Future<Either<Failure, List<CashTransaction>>> getCashTransactions(String shiftId);

  Future<Either<Failure, ZReport>> generateZReport(String shiftId);

  Future<Either<Failure, List<Shift>>> getShiftHistory();
}
