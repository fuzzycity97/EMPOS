import '../../domain/entities/medical_risk_factor.dart';

class MedicalRiskFactorModel extends MedicalRiskFactor {
  const MedicalRiskFactorModel({
    required super.id,
    required super.label,
    required super.colorValue,
    required super.iconName,
    super.isEnabled,
  });

  factory MedicalRiskFactorModel.fromEntity(MedicalRiskFactor entity) {
    return MedicalRiskFactorModel(
      id: entity.id,
      label: entity.label,
      colorValue: entity.colorValue,
      iconName: entity.iconName,
      isEnabled: entity.isEnabled,
    );
  }

  factory MedicalRiskFactorModel.fromJson(Map<String, dynamic> json) {
    return MedicalRiskFactorModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      colorValue: json['colorValue'] as int? ?? 0xFFEAB308,
      iconName: json['iconName'] as String? ?? 'activity',
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'colorValue': colorValue,
      'iconName': iconName,
      'isEnabled': isEnabled,
    };
  }
}
