import 'package:equatable/equatable.dart';
import '../../domain/entities/revenue_split_rule.dart';

abstract class FinanceSplitEvent extends Equatable {
  const FinanceSplitEvent();

  @override
  List<Object?> get props => [];
}

class CalculateSplitsEvent extends FinanceSplitEvent {
  final double totalAmount;
  final List<RevenueSplitRule> rules;

  const CalculateSplitsEvent({
    required this.totalAmount,
    required this.rules,
  });

  @override
  List<Object?> get props => [totalAmount, rules];
}

class RecordSettlementEvent extends FinanceSplitEvent {
  final FinanceSettlementLog settlement;

  const RecordSettlementEvent(this.settlement);

  @override
  List<Object?> get props => [settlement];
}

class LoadSettlementLogsEvent extends FinanceSplitEvent {
  final String? referenceId;

  const LoadSettlementLogsEvent({this.referenceId});

  @override
  List<Object?> get props => [referenceId];
}
