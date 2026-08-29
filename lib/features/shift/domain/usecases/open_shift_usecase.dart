import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/shift.dart';
import '../repositories/shift_repository.dart';

class OpenShiftParams extends Equatable {
  final String cashierId;
  final String? cashierName;
  final double startingCash;
  final String? notes;

  const OpenShiftParams({
    required this.cashierId,
    this.cashierName,
    required this.startingCash,
    this.notes,
  });

  @override
  List<Object?> get props => [cashierId, cashierName, startingCash, notes];
}

class OpenShiftUseCase {
  final ShiftRepository repository;

  OpenShiftUseCase(this.repository);

  Future<Either<Failure, Shift>> call(OpenShiftParams params) async {
    return await repository.openShift(
      cashierId: params.cashierId,
      cashierName: params.cashierName,
      startingCash: params.startingCash,
      notes: params.notes,
    );
  }
}
