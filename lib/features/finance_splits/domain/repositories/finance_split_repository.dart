import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/revenue_split_rule.dart';

abstract class FinanceSplitRepository {
  /// Computes the exact distribution for given total amount across a set of split rules
  Either<Failure, List<SplitCalculationResult>> calculateDistribution(
    double totalAmount,
    List<RevenueSplitRule> rules,
  );

  Future<Either<Failure, FinanceSettlementLog>> recordSettlement(
    FinanceSettlementLog settlement,
  );

  Future<Either<Failure, List<FinanceSettlementLog>>> getSettlementLogs({
    String? referenceId,
  });
}
