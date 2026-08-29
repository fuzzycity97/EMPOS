import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/cash_transaction.dart';
import '../repositories/shift_repository.dart';

class AddCashTransactionParams extends Equatable {
  final String shiftId;
  final CashTransactionType type;
  final double amount;
  final String reason;

  const AddCashTransactionParams({
    required this.shiftId,
    required this.type,
    required this.amount,
    required this.reason,
  });

  @override
  List<Object?> get props => [shiftId, type, amount, reason];
}

class AddCashTransactionUseCase {
  final ShiftRepository repository;

  AddCashTransactionUseCase(this.repository);

  Future<Either<Failure, CashTransaction>> call(
    AddCashTransactionParams params,
  ) async {
    return await repository.addCashTransaction(
      shiftId: params.shiftId,
      type: params.type,
      amount: params.amount,
      reason: params.reason,
    );
  }
}
