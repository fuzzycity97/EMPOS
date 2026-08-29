import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/revenue_split_rule.dart';
import '../repositories/finance_split_repository.dart';

class CalculateDistributionUseCase {
  final FinanceSplitRepository repository;

  CalculateDistributionUseCase(this.repository);

  Either<Failure, List<SplitCalculationResult>> call(
    double totalAmount,
    List<RevenueSplitRule> rules,
  ) {
    return repository.calculateDistribution(totalAmount, rules);
  }
}
