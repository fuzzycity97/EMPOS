import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../entities/customer_ledger_entry.dart';
import '../repositories/customer_repository.dart';

class ProcessDebtPaymentParams extends Equatable {
  final String customerId;
  final double amount;
  final TenderType paymentTender;
  final String? notes;

  const ProcessDebtPaymentParams({
    required this.customerId,
    required this.amount,
    required this.paymentTender,
    this.notes,
  });

  @override
  List<Object?> get props => [customerId, amount, paymentTender, notes];
}

class ProcessDebtPaymentUseCase {
  final CustomerRepository repository;

  ProcessDebtPaymentUseCase(this.repository);

  Future<Either<Failure, CustomerLedgerEntry>> call(
    ProcessDebtPaymentParams params,
  ) async {
    return await repository.processDebtPayment(
      customerId: params.customerId,
      amount: params.amount,
      paymentTender: params.paymentTender,
      notes: params.notes,
    );
  }
}
