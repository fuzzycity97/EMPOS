import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/revenue_split_rule.dart';
import '../../domain/repositories/finance_split_repository.dart';
import '../datasources/finance_split_local_data_source.dart';
import '../models/revenue_split_rule_model.dart';

class FinanceSplitRepositoryImpl implements FinanceSplitRepository {
  final FinanceSplitLocalDataSource localDataSource;

  FinanceSplitRepositoryImpl({required this.localDataSource});

  @override
  Either<Failure, List<SplitCalculationResult>> calculateDistribution(
    double totalAmount,
    List<RevenueSplitRule> rules,
  ) {
    try {
      final List<SplitCalculationResult> results = [];
      for (final rule in rules) {
        final pctCut = totalAmount * rule.percentage;
        final totalCut = double.parse((pctCut + rule.flatFee).toStringAsFixed(2));
        results.add(
          SplitCalculationResult(
            rule: rule,
            calculatedAmount: totalCut,
            recipientName: rule.recipientName,
          ),
        );
      }
      return Right(results);
    } catch (e) {
      return Left(ValidationFailure(message: 'Failed to calculate split distribution: $e'));
    }
  }

  @override
  Future<Either<Failure, FinanceSettlementLog>> recordSettlement(
    FinanceSettlementLog settlement,
  ) async {
    try {
      final model = FinanceSettlementLogModel.fromEntity(settlement);
      await localDataSource.saveSettlement(model);
      return Right(model);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error recording settlement: $e'));
    }
  }

  @override
  Future<Either<Failure, List<FinanceSettlementLog>>> getSettlementLogs({
    String? referenceId,
  }) async {
    try {
      final all = await localDataSource.getSettlements();
      var filtered = all;
      if (referenceId != null && referenceId.isNotEmpty) {
        filtered = all.where((s) => s.referenceId == referenceId).toList();
      }
      filtered.sort((a, b) => b.date.compareTo(a.date));
      return Right(filtered);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error fetching settlement logs: $e'));
    }
  }
}
