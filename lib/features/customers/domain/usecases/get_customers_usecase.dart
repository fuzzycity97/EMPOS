import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomersUseCase {
  final CustomerRepository repository;

  GetCustomersUseCase(this.repository);

  Future<Either<Failure, List<Customer>>> call({String? searchQuery}) async {
    return await repository.getCustomers(searchQuery: searchQuery);
  }
}
