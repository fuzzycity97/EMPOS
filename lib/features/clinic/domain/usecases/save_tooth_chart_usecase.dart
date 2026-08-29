import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/tooth_chart_entry.dart';
import '../repositories/dental_repository.dart';

class SaveToothChartUseCase {
  final DentalRepository repository;

  SaveToothChartUseCase(this.repository);

  Future<Either<Failure, void>> call(String patientId, List<ToothChartEntry> entries) {
    return repository.saveToothChart(patientId, entries);
  }
}
