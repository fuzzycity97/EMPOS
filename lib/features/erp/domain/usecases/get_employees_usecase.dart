import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employee.dart';
import '../repositories/erp_repository.dart';

class GetEmployeesUseCase {
  final ErpRepository repository;

  GetEmployeesUseCase(this.repository);

  Future<Either<Failure, List<Employee>>> call({bool? activeOnly}) async {
    return await repository.getEmployees(activeOnly: activeOnly);
  }
}
