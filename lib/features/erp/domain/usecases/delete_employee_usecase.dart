import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/erp_repository.dart';

class DeleteEmployeeUseCase {
  final ErpRepository repository;

  DeleteEmployeeUseCase(this.repository);

  Future<Either<Failure, void>> call(String employeeId) async {
    return await repository.deleteEmployee(employeeId);
  }
}
