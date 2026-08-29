import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/net_salary_slip.dart';
import '../repositories/erp_repository.dart';

class CalculateSalarySlipParams extends Equatable {
  final String employeeId;
  final int month;
  final int year;
  final double bonuses;
  final double deductions;

  const CalculateSalarySlipParams({
    required this.employeeId,
    required this.month,
    required this.year,
    this.bonuses = 0.0,
    this.deductions = 0.0,
  });

  @override
  List<Object?> get props => [
        employeeId,
        month,
        year,
        bonuses,
        deductions,
      ];
}

class CalculateSalarySlipUseCase {
  final ErpRepository repository;

  CalculateSalarySlipUseCase(this.repository);

  Future<Either<Failure, NetSalarySlip>> call(
    CalculateSalarySlipParams params,
  ) async {
    return await repository.calculateNetSalarySlip(
      employeeId: params.employeeId,
      month: params.month,
      year: params.year,
      bonuses: params.bonuses,
      deductions: params.deductions,
    );
  }

  Future<Either<Failure, List<NetSalarySlip>>> calculateAll({
    required int month,
    required int year,
  }) async {
    return await repository.calculateAllSalarySlips(
      month: month,
      year: year,
    );
  }
}
