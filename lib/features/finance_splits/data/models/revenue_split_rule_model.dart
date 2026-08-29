import '../../domain/entities/revenue_split_rule.dart';

class RevenueSplitRuleModel extends RevenueSplitRule {
  const RevenueSplitRuleModel({
    required super.id,
    required super.name,
    super.type = SplitRuleType.custom,
    super.percentage = 0.0,
    super.flatFee = 0.0,
    required super.recipientName,
    super.recipientId,
  });

  factory RevenueSplitRuleModel.fromJson(Map<String, dynamic> json) {
    return RevenueSplitRuleModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: SplitRuleType.fromString(json['type']?.toString()),
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      flatFee: (json['flatFee'] as num?)?.toDouble() ?? 0.0,
      recipientName: json['recipientName']?.toString() ?? '',
      recipientId: json['recipientId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'percentage': percentage,
      'flatFee': flatFee,
      'recipientName': recipientName,
      'recipientId': recipientId,
    };
  }

  factory RevenueSplitRuleModel.fromEntity(RevenueSplitRule entity) {
    return RevenueSplitRuleModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      percentage: entity.percentage,
      flatFee: entity.flatFee,
      recipientName: entity.recipientName,
      recipientId: entity.recipientId,
    );
  }
}

class SplitCalculationResultModel extends SplitCalculationResult {
  const SplitCalculationResultModel({
    required super.rule,
    required super.calculatedAmount,
    required super.recipientName,
  });

  factory SplitCalculationResultModel.fromJson(Map<String, dynamic> json) {
    return SplitCalculationResultModel(
      rule: RevenueSplitRuleModel.fromJson(
        Map<String, dynamic>.from(json['rule'] as Map),
      ),
      calculatedAmount: (json['calculatedAmount'] as num?)?.toDouble() ?? 0.0,
      recipientName: json['recipientName']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rule': rule is RevenueSplitRuleModel
          ? (rule as RevenueSplitRuleModel).toJson()
          : RevenueSplitRuleModel.fromEntity(rule).toJson(),
      'calculatedAmount': calculatedAmount,
      'recipientName': recipientName,
    };
  }
}

class FinanceSettlementLogModel extends FinanceSettlementLog {
  const FinanceSettlementLogModel({
    required super.id,
    required super.referenceId,
    required super.totalAmount,
    required super.date,
    required super.splits,
    required super.netOwnerAmount,
    super.notes,
  });

  factory FinanceSettlementLogModel.fromJson(Map<String, dynamic> json) {
    return FinanceSettlementLogModel(
      id: json['id']?.toString() ?? '',
      referenceId: json['referenceId']?.toString() ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      splits: (json['splits'] as List<dynamic>?)
              ?.map((e) => SplitCalculationResultModel.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      netOwnerAmount: (json['netOwnerAmount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referenceId': referenceId,
      'totalAmount': totalAmount,
      'date': date.toIso8601String(),
      'splits': splits
          .map((s) => s is SplitCalculationResultModel
              ? s.toJson()
              : SplitCalculationResultModel(
                  rule: s.rule,
                  calculatedAmount: s.calculatedAmount,
                  recipientName: s.recipientName,
                ).toJson())
          .toList(),
      'netOwnerAmount': netOwnerAmount,
      'notes': notes,
    };
  }

  factory FinanceSettlementLogModel.fromEntity(FinanceSettlementLog entity) {
    return FinanceSettlementLogModel(
      id: entity.id,
      referenceId: entity.referenceId,
      totalAmount: entity.totalAmount,
      date: entity.date,
      splits: entity.splits,
      netOwnerAmount: entity.netOwnerAmount,
      notes: entity.notes,
    );
  }
}
