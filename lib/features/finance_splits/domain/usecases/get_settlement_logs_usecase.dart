import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/revenue_split_rule.dart';
import '../repositories/finance_split_repository.dart';

class GetSettlementLogsUseCase {
  final FinanceSplitRepository repository;

  GetSettlementLogsUseCase(this.repository);

  Future<Either<Failure, List<FinanceSettlementLog>>> call({String? referenceId}) {
    return repository.getSettlementLogs(referenceId: referenceId);
  }
}
