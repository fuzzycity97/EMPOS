import 'package:equatable/equatable.dart';

enum EmployeeRole { cashier, supervisor, manager, inventoryClerk, other }

class Employee extends Equatable {
  final String id;
  final String name;
  final String? phone;
  final EmployeeRole role;
  final double baseSalary;
  final double? hourlyRate;
  final DateTime hireDate;
  final bool isActive;

  const Employee({
    required this.id,
    required this.name,
    this.phone,
    this.role = EmployeeRole.cashier,
    this.baseSalary = 0.0,
    this.hourlyRate,
    required this.hireDate,
    this.isActive = true,
  });

  Employee copyWith({
    String? id,
    String? name,
    String? phone,
    EmployeeRole? role,
    double? baseSalary,
    double? hourlyRate,
    DateTime? hireDate,
    bool? isActive,
  }) {
    return Employee(
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

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        role,
        baseSalary,
        hourlyRate,
        hireDate,
        isActive,
      ];
}
