import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_ledger_entry.dart';
import '../repositories/customer_repository.dart';

class ChargeCustomerDebtParams extends Equatable {
  final String customerId;
  final double amount;
  final String? relatedOrderId;
  final String? notes;

  const ChargeCustomerDebtParams({
    required this.customerId,
    required this.amount,
    this.relatedOrderId,
    this.notes,
  });

  @override
  List<Object?> get props => [customerId, amount, relatedOrderId, notes];
}

class ChargeCustomerDebtUseCase {
  final CustomerRepository repository;

  ChargeCustomerDebtUseCase(this.repository);

  Future<Either<Failure, CustomerLedgerEntry>> call(
    ChargeCustomerDebtParams params,
  ) async {
    return await repository.chargeCustomerDebt(
      customerId: params.customerId,
      amount: params.amount,
      relatedOrderId: params.relatedOrderId,
      notes: params.notes,
    );
  }
}
