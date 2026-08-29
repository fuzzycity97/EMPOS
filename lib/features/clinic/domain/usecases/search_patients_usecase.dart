import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/patient_profile.dart';
import '../repositories/clinic_repository.dart';

class SearchPatientsUseCase {
  final ClinicRepository repository;

  SearchPatientsUseCase(this.repository);

  Future<Either<Failure, List<PatientProfile>>> call(String query) {
    return repository.searchPatients(query);
  }
}
