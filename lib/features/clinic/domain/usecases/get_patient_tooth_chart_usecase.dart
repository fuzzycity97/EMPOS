import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tooth_chart_entry.dart';
import '../repositories/dental_repository.dart';

class GetPatientToothChartUseCase {
  final DentalRepository repository;

  GetPatientToothChartUseCase(this.repository);

  Future<Either<Failure, List<ToothChartEntry>>> call(
    String patientId, {
    DateTime? dateOfBirth,
  }) {
    return repository.getPatientToothChart(patientId, dateOfBirth: dateOfBirth);
  }
}
