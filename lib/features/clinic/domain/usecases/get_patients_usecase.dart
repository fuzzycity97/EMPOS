import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_profile.dart';
import '../repositories/clinic_repository.dart';

class GetPatientsUseCase {
  final ClinicRepository repository;

  GetPatientsUseCase(this.repository);

  Future<Either<Failure, List<PatientProfile>>> call() {
    return repository.getPatients();
  }
}
