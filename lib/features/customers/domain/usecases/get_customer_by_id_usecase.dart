import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomerByIdUseCase {
  final CustomerRepository repository;

  GetCustomerByIdUseCase(this.repository);

  Future<Either<Failure, Customer>> call(String customerId) async {
    return await repository.getCustomerById(customerId);
  }
}
