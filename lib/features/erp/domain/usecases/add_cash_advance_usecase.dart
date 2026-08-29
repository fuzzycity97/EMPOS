import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/cash_advance.dart';
import '../repositories/erp_repository.dart';

class AddCashAdvanceParams extends Equatable {
  final String employeeId;
  final double amount;
  final String reason;
  final bool deductFromShiftDrawer;

  const AddCashAdvanceParams({
    required this.employeeId,
    required this.amount,
    required this.reason,
    this.deductFromShiftDrawer = true,
  });

  @override
  List<Object?> get props => [
        employeeId,
        amount,
        reason,
        deductFromShiftDrawer,
      ];
}

class AddCashAdvanceUseCase {
  final ErpRepository repository;

  AddCashAdvanceUseCase(this.repository);

  Future<Either<Failure, CashAdvance>> call(
    AddCashAdvanceParams params,
  ) async {
    return await repository.addCashAdvance(
      employeeId: params.employeeId,
      amount: params.amount,
      reason: params.reason,
      deductFromShiftDrawer: params.deductFromShiftDrawer,
    );
  }
}
