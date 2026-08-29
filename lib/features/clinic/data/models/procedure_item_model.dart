import '../../domain/entities/procedure_item.dart';

class ProcedureItemModel extends ProcedureItem {
  const ProcedureItemModel({
    required super.id,
    required super.code,
    required super.name,
    required super.standardFee,
    super.insuranceCoveragePercentage = 0.0,
    super.requiredConsumables = const [],
  });

  factory ProcedureItemModel.fromJson(Map<String, dynamic> json) {
    return ProcedureItemModel(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      standardFee: (json['standardFee'] as num?)?.toDouble() ?? (json['price'] as num?)?.toDouble() ?? 0.0,
      insuranceCoveragePercentage: (json['insuranceCoveragePercentage'] as num?)?.toDouble() ?? 0.0,
      requiredConsumables: (json['requiredConsumables'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'standardFee': standardFee,
      'insuranceCoveragePercentage': insuranceCoveragePercentage,
      'requiredConsumables': requiredConsumables,
    };
  }

  factory ProcedureItemModel.fromEntity(ProcedureItem entity) {
    return ProcedureItemModel(
      id: entity.id,
      code: entity.code,
      name: entity.name,
      standardFee: entity.standardFee,
      insuranceCoveragePercentage: entity.insuranceCoveragePercentage,
      requiredConsumables: entity.requiredConsumables,
    );
  }
}
