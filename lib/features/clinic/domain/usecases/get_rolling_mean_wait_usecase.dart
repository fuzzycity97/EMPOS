import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/clinic_repository.dart';

class GetRollingMeanWaitUseCase {
  final ClinicRepository repository;

  GetRollingMeanWaitUseCase(this.repository);

  Future<Either<Failure, int>> call(String doctorName) {
    return repository.getRollingMeanWaitMinutes(doctorName);
  }
}
