import 'dart:convert';
import '../../domain/entities/customer.dart';

class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.name,
    required super.phone,
    super.address,
    super.totalDebt = 0.0,
    super.loyaltyPoints = 0,
    super.notes,
    required super.createdAt,
  });

  factory CustomerModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse CustomerModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return CustomerModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return CustomerModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for CustomerModel: ${raw.runtimeType}');
  }

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString(),
      totalDebt: (json['totalDebt'] as num?)?.toDouble() ?? 0.0,
      loyaltyPoints: (json['loyaltyPoints'] as num?)?.toInt() ?? 0,
      notes: json['notes']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'totalDebt': totalDebt,
      'loyaltyPoints': loyaltyPoints,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CustomerModel.fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      totalDebt: entity.totalDebt,
      loyaltyPoints: entity.loyaltyPoints,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }

  @override
  CustomerModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    double? totalDebt,
    int? loyaltyPoints,
    String? notes,
    DateTime? createdAt,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      totalDebt: totalDebt ?? this.totalDebt,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
