import 'package:equatable/equatable.dart';
import '../../domain/entities/revenue_split_rule.dart';

abstract class FinanceSplitState extends Equatable {
  const FinanceSplitState();

  @override
  List<Object?> get props => [];
}

class FinanceSplitInitial extends FinanceSplitState {}

class FinanceSplitLoading extends FinanceSplitState {}

class FinanceSplitCalculated extends FinanceSplitState {
  final double totalAmount;
  final List<SplitCalculationResult> results;
  final double netOwnerAmount;

  const FinanceSplitCalculated({
    required this.totalAmount,
    required this.results,
    required this.netOwnerAmount,
  });

  @override
  List<Object?> get props => [totalAmount, results, netOwnerAmount];
}

class FinanceSettlementsLoaded extends FinanceSplitState {
  final List<FinanceSettlementLog> logs;

  const FinanceSettlementsLoaded(this.logs);

  @override
  List<Object?> get props => [logs];
}

class FinanceSplitError extends FinanceSplitState {
  final String message;

  const FinanceSplitError(this.message);

  @override
  List<Object?> get props => [message];
}
