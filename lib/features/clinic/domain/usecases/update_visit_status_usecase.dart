import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/clinic_visit.dart';
import '../repositories/clinic_repository.dart';

class UpdateVisitStatusUseCase {
  final ClinicRepository repository;

  UpdateVisitStatusUseCase(this.repository);

  Future<Either<Failure, ClinicVisit>> call(String visitId, ClinicVisitStatus status) {
    return repository.updateVisitStatus(visitId, status);
  }
}
