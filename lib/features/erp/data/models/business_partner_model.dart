import 'dart:convert';
import '../../domain/entities/business_partner.dart';

class BusinessPartnerModel extends BusinessPartner {
  const BusinessPartnerModel({
    required super.id,
    required super.name,
    super.contactInfo,
    required super.equityPercentage,
    super.totalInvestedCapital = 0.0,
    super.withdrawnDividends = 0.0,
    required super.createdAt,
  });

  factory BusinessPartnerModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse BusinessPartnerModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return BusinessPartnerModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return BusinessPartnerModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for BusinessPartnerModel: ${raw.runtimeType}');
  }

  factory BusinessPartnerModel.fromJson(Map<String, dynamic> json) {
    return BusinessPartnerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      contactInfo: json['contactInfo']?.toString(),
      equityPercentage: (json['equityPercentage'] as num?)?.toDouble() ?? 0.0,
      totalInvestedCapital: (json['totalInvestedCapital'] as num?)?.toDouble() ?? 0.0,
      withdrawnDividends: (json['withdrawnDividends'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'contactInfo': contactInfo,
      'equityPercentage': equityPercentage,
      'totalInvestedCapital': totalInvestedCapital,
      'withdrawnDividends': withdrawnDividends,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BusinessPartnerModel.fromEntity(BusinessPartner entity) {
    return BusinessPartnerModel(
      id: entity.id,
      name: entity.name,
      contactInfo: entity.contactInfo,
      equityPercentage: entity.equityPercentage,
      totalInvestedCapital: entity.totalInvestedCapital,
      withdrawnDividends: entity.withdrawnDividends,
      createdAt: entity.createdAt,
    );
  }

  @override
  BusinessPartnerModel copyWith({
    String? id,
    String? name,
    String? contactInfo,
    double? equityPercentage,
    double? totalInvestedCapital,
    double? withdrawnDividends,
    DateTime? createdAt,
  }) {
    return BusinessPartnerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      contactInfo: contactInfo ?? this.contactInfo,
      equityPercentage: equityPercentage ?? this.equityPercentage,
      totalInvestedCapital: totalInvestedCapital ?? this.totalInvestedCapital,
      withdrawnDividends: withdrawnDividends ?? this.withdrawnDividends,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
