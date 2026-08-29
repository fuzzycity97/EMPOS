import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/clinic_visit.dart';
import '../repositories/clinic_repository.dart';

class GetClinicQueueUseCase {
  final ClinicRepository repository;

  GetClinicQueueUseCase(this.repository);

  Future<Either<Failure, List<ClinicVisit>>> call({String? doctorName}) {
    return repository.getQueue(doctorName: doctorName);
  }
}
