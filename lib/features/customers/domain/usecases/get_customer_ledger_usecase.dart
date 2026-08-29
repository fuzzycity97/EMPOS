import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer_ledger_entry.dart';
import '../repositories/customer_repository.dart';

class GetCustomerLedgerUseCase {
  final CustomerRepository repository;

  GetCustomerLedgerUseCase(this.repository);

  Future<Either<Failure, List<CustomerLedgerEntry>>> call(
    String customerId,
  ) async {
    return await repository.getCustomerLedger(customerId);
  }
}
