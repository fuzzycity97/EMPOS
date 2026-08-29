import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/revenue_split_rule.dart';
import '../repositories/finance_split_repository.dart';

class RecordSettlementUseCase {
  final FinanceSplitRepository repository;

  RecordSettlementUseCase(this.repository);

  Future<Either<Failure, FinanceSettlementLog>> call(FinanceSettlementLog settlement) {
    return repository.recordSettlement(settlement);
  }
}
