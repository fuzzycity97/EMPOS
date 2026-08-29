import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../entities/customer.dart';
import '../entities/customer_ledger_entry.dart';

abstract class CustomerRepository {
  Future<Either<Failure, List<Customer>>> getCustomers({String? searchQuery});

  Future<Either<Failure, Customer>> getCustomerById(String customerId);

  Future<Either<Failure, Customer>> saveCustomer(Customer customer);

  Future<Either<Failure, void>> deleteCustomer(String customerId);

  Future<Either<Failure, List<CustomerLedgerEntry>>> getCustomerLedger(
    String customerId,
  );

  Future<Either<Failure, CustomerLedgerEntry>> chargeCustomerDebt({
    required String customerId,
    required double amount,
    String? relatedOrderId,
    String? notes,
  });

  Future<Either<Failure, CustomerLedgerEntry>> processDebtPayment({
    required String customerId,
    required double amount,
    required TenderType paymentTender,
    String? notes,
  });
}
