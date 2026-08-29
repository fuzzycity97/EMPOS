import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/employee.dart';
import '../repositories/erp_repository.dart';

class SaveEmployeeUseCase {
  final ErpRepository repository;

  SaveEmployeeUseCase(this.repository);

  Future<Either<Failure, Employee>> call(Employee employee) async {
    return await repository.saveEmployee(employee);
  }
}
