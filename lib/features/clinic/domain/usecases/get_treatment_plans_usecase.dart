import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dental_treatment_plan.dart';
import '../repositories/dental_repository.dart';

class GetTreatmentPlansUseCase {
  final DentalRepository repository;

  GetTreatmentPlansUseCase(this.repository);

  Future<Either<Failure, List<DentalTreatmentPlan>>> call(String patientId) {
    return repository.getTreatmentPlans(patientId);
  }
}
