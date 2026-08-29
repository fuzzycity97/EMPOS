import 'package:equatable/equatable.dart';

class ProcedureItem extends Equatable {
  final String id;
  final String code;
  final String name;
  final double standardFee;
  final double insuranceCoveragePercentage;
  final List<String> requiredConsumables;

  const ProcedureItem({
    required this.id,
    required this.code,
    required this.name,
    required this.standardFee,
    this.insuranceCoveragePercentage = 0.0,
    this.requiredConsumables = const [],
  });

  double get insuranceShare =>
      double.parse((standardFee * insuranceCoveragePercentage).toStringAsFixed(2));
  double get patientCopay =>
      double.parse((standardFee - insuranceShare).toStringAsFixed(2));

  ProcedureItem copyWith({
    String? id,
    String? code,
    String? name,
    double? standardFee,
    double? insuranceCoveragePercentage,
    List<String>? requiredConsumables,
  }) {
    return ProcedureItem(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      standardFee: standardFee ?? this.standardFee,
      insuranceCoveragePercentage: insuranceCoveragePercentage ?? this.insuranceCoveragePercentage,
      requiredConsumables: requiredConsumables ?? this.requiredConsumables,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        standardFee,
        insuranceCoveragePercentage,
        requiredConsumables,
      ];
}
