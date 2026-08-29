import 'dart:convert';
import '../../domain/entities/employee.dart';

class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.id,
    required super.name,
    super.phone,
    super.role = EmployeeRole.cashier,
    super.baseSalary = 0.0,
    super.hourlyRate,
    required super.hireDate,
    super.isActive = true,
  });

  factory EmployeeModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse EmployeeModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return EmployeeModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return EmployeeModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for EmployeeModel: ${raw.runtimeType}');
  }

  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    final roleStr = json['role']?.toString().toLowerCase();
    EmployeeRole role = EmployeeRole.cashier;
    if (roleStr == 'supervisor') {
      role = EmployeeRole.supervisor;
    } else if (roleStr == 'manager') {
      role = EmployeeRole.manager;
    } else if (roleStr == 'inventoryclerk' || roleStr == 'inventory') {
      role = EmployeeRole.inventoryClerk;
    } else if (roleStr == 'other') {
      role = EmployeeRole.other;
    }

    return EmployeeModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      role: role,
      baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0.0,
      hourlyRate: (json['hourlyRate'] as num?)?.toDouble(),
      hireDate: DateTime.tryParse(json['hireDate']?.toString() ?? '') ?? DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'role': role.name,
      'baseSalary': baseSalary,
      'hourlyRate': hourlyRate,
      'hireDate': hireDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  factory EmployeeModel.fromEntity(Employee entity) {
    return EmployeeModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      role: entity.role,
      baseSalary: entity.baseSalary,
      hourlyRate: entity.hourlyRate,
      hireDate: entity.hireDate,
      isActive: entity.isActive,
    );
  }

  @override
  EmployeeModel copyWith({
    String? id,
    String? name,
    String? phone,
    EmployeeRole? role,
    double? baseSalary,
    double? hourlyRate,
    DateTime? hireDate,
    bool? isActive,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      baseSalary: baseSalary ?? this.baseSalary,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
