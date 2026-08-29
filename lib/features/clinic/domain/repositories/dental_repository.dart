import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dental_treatment_plan.dart';
import '../entities/tooth_chart_entry.dart';

abstract class DentalRepository {
  Future<Either<Failure, List<ToothChartEntry>>> getPatientToothChart(
    String patientId, {
    DateTime? dateOfBirth,
  });
  Future<Either<Failure, void>> saveToothChart(
    String patientId,
    List<ToothChartEntry> entries,
  );
  Future<Either<Failure, List<DentalTreatmentPlan>>> getTreatmentPlans(String patientId);
  Future<Either<Failure, DentalTreatmentPlan>> saveTreatmentPlan(DentalTreatmentPlan plan);
}
