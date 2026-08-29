import 'package:equatable/equatable.dart';

class NetSalarySlip extends Equatable {
  final String employeeId;
  final String employeeName;
  final int month;
  final int year;
  final double baseSalary;
  final double totalAdvances;
  final double bonuses;
  final double deductions;
  final double netPayable;

  const NetSalarySlip({
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.year,
    required this.baseSalary,
    required this.totalAdvances,
    this.bonuses = 0.0,
    this.deductions = 0.0,
    required this.netPayable,
  });

  factory NetSalarySlip.compute({
    required String employeeId,
    required String employeeName,
    required int month,
    required int year,
    required double baseSalary,
    required double totalAdvances,
    double bonuses = 0.0,
    double deductions = 0.0,
  }) {
    final net = (baseSalary + bonuses - deductions - totalAdvances)
        .clamp(0.0, double.infinity);
    return NetSalarySlip(
      employeeId: employeeId,
      employeeName: employeeName,
      month: month,
      year: year,
      baseSalary: baseSalary,
      totalAdvances: totalAdvances,
      bonuses: bonuses,
      deductions: deductions,
      netPayable: net,
    );
  }

  @override
  List<Object?> get props => [
        employeeId,
        employeeName,
        month,
        year,
        baseSalary,
        totalAdvances,
        bonuses,
        deductions,
        netPayable,
      ];
}
