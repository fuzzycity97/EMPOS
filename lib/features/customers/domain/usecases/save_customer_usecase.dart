import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class SaveCustomerUseCase {
  final CustomerRepository repository;

  SaveCustomerUseCase(this.repository);

  Future<Either<Failure, Customer>> call(Customer customer) async {
    return await repository.saveCustomer(customer);
  }
}
