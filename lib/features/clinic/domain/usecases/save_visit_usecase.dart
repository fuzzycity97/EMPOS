import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/clinic_visit.dart';
import '../repositories/clinic_repository.dart';

class SaveVisitUseCase {
  final ClinicRepository repository;

  SaveVisitUseCase(this.repository);

  Future<Either<Failure, ClinicVisit>> call(ClinicVisit visit) {
    return repository.saveVisit(visit);
  }
}
