import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dental_treatment_plan.dart';
import '../repositories/dental_repository.dart';

class SaveTreatmentPlanUseCase {
  final DentalRepository repository;

  SaveTreatmentPlanUseCase(this.repository);

  Future<Either<Failure, DentalTreatmentPlan>> call(DentalTreatmentPlan plan) {
    return repository.saveTreatmentPlan(plan);
  }
}
