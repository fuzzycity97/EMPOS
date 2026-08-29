import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cash_transaction.dart';
import '../repositories/shift_repository.dart';

class GetCashTransactionsUseCase {
  final ShiftRepository repository;

  GetCashTransactionsUseCase(this.repository);

  Future<Either<Failure, List<CashTransaction>>> call(String shiftId) async {
    return await repository.getCashTransactions(shiftId);
  }
}
