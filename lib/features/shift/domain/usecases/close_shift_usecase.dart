import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shift.dart';
import '../repositories/shift_repository.dart';

class CloseShiftParams extends Equatable {
  final String shiftId;
  final double actualCash;
  final String? notes;

  const CloseShiftParams({
    required this.shiftId,
    required this.actualCash,
    this.notes,
  });

  @override
  List<Object?> get props => [shiftId, actualCash, notes];
}

class CloseShiftUseCase {
  final ShiftRepository repository;

  CloseShiftUseCase(this.repository);

  Future<Either<Failure, Shift>> call(CloseShiftParams params) async {
    return await repository.closeShift(
      shiftId: params.shiftId,
      actualCash: params.actualCash,
      notes: params.notes,
    );
  }
}
