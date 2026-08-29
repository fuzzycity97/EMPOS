import 'package:equatable/equatable.dart';

class BusinessPartner extends Equatable {
  final String id;
  final String name;
  final String? contactInfo;
  final double equityPercentage; // 0.0 to 100.0
  final double totalInvestedCapital;
  final double withdrawnDividends;
  final DateTime createdAt;

  const BusinessPartner({
    required this.id,
    required this.name,
    this.contactInfo,
    required this.equityPercentage,
    this.totalInvestedCapital = 0.0,
    this.withdrawnDividends = 0.0,
    required this.createdAt,
  });

  BusinessPartner copyWith({
    String? id,
    String? name,
    String? contactInfo,
    double? equityPercentage,
    double? totalInvestedCapital,
    double? withdrawnDividends,
    DateTime? createdAt,
  }) {
    return BusinessPartner(
      id: id ?? this.id,
      name: name ?? this.name,
      contactInfo: contactInfo ?? this.contactInfo,
      equityPercentage: equityPercentage ?? this.equityPercentage,
      totalInvestedCapital: totalInvestedCapital ?? this.totalInvestedCapital,
      withdrawnDividends: withdrawnDividends ?? this.withdrawnDividends,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        contactInfo,
        equityPercentage,
        totalInvestedCapital,
        withdrawnDividends,
        createdAt,
      ];
}
