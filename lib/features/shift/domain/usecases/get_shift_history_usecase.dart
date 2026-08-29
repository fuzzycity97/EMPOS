import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/shift.dart';
import '../repositories/shift_repository.dart';

class GetShiftHistoryUseCase {
  final ShiftRepository repository;

  GetShiftHistoryUseCase(this.repository);

  Future<Either<Failure, List<Shift>>> call() async {
    return await repository.getShiftHistory();
  }
}
