import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/z_report.dart';
import '../repositories/shift_repository.dart';

class GenerateZReportUseCase {
  final ShiftRepository repository;

  GenerateZReportUseCase(this.repository);

  Future<Either<Failure, ZReport>> call(String shiftId) async {
    return await repository.generateZReport(shiftId);
  }
}
