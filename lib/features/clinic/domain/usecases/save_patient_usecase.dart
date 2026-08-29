import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_profile.dart';
import '../repositories/clinic_repository.dart';

class SavePatientUseCase {
  final ClinicRepository repository;

  SavePatientUseCase(this.repository);

  Future<Either<Failure, PatientProfile>> call(PatientProfile patient) {
    return repository.savePatient(patient);
  }
}
