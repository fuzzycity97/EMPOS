import 'package:equatable/equatable.dart';

enum SplitRuleType {
  insuranceCopay('Insurance / Third-Party Copay'),
  staffCommission('Staff / Stylist / Mechanic Commission'),
  brokerSplit('Real Estate Broker / Agent Split'),
  partnerEquity('Partner Equity / Dividend Share'),
  custom('Custom Percentage or Flat Split');

  final String label;
  const SplitRuleType(this.label);

  static SplitRuleType fromString(String? val) {
    if (val == null) return SplitRuleType.custom;
    final lower = val.toLowerCase().replaceAll('_', '');
    for (final s in SplitRuleType.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return SplitRuleType.custom;
  }
}

class RevenueSplitRule extends Equatable {
  final String id;
  final String name;
  final SplitRuleType type;
  final double percentage; // e.g. 0.30 for 30%
  final double flatFee;
  final String recipientName;
  final String? recipientId;

  const RevenueSplitRule({
    required this.id,
    required this.name,
    this.type = SplitRuleType.custom,
    this.percentage = 0.0,
    this.flatFee = 0.0,
    required this.recipientName,
    this.recipientId,
  });

  RevenueSplitRule copyWith({
    String? id,
    String? name,
    SplitRuleType? type,
    double? percentage,
    double? flatFee,
    String? recipientName,
    String? recipientId,
  }) {
    return RevenueSplitRule(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      percentage: percentage ?? this.percentage,
      flatFee: flatFee ?? this.flatFee,
      recipientName: recipientName ?? this.recipientName,
      recipientId: recipientId ?? this.recipientId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        percentage,
        flatFee,
        recipientName,
        recipientId,
      ];
}

class SplitCalculationResult extends Equatable {
  final RevenueSplitRule rule;
  final double calculatedAmount;
  final String recipientName;

  const SplitCalculationResult({
    required this.rule,
    required this.calculatedAmount,
    required this.recipientName,
  });

  @override
  List<Object?> get props => [rule, calculatedAmount, recipientName];
}

class FinanceSettlementLog extends Equatable {
  final String id;
  final String referenceId; // Order ID, Visit ID, Work Order ID, or Transaction ID
  final double totalAmount;
  final DateTime date;
  final List<SplitCalculationResult> splits;
  final double netOwnerAmount;
  final String? notes;

  const FinanceSettlementLog({
    required this.id,
    required this.referenceId,
    required this.totalAmount,
    required this.date,
    required this.splits,
    required this.netOwnerAmount,
    this.notes,
  });

  double get totalDistributed =>
      splits.fold<double>(0.0, (sum, s) => sum + s.calculatedAmount);

  @override
  List<Object?> get props => [
        id,
        referenceId,
        totalAmount,
        date,
        splits,
        netOwnerAmount,
        notes,
      ];
}
