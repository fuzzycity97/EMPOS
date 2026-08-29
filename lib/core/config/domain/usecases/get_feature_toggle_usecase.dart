import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../repositories/config_repository.dart';

class GetFeatureToggleUseCase {
  final ConfigRepository repository;

  GetFeatureToggleUseCase(this.repository);

  Future<Either<Failure, bool>> call(String toggleKey) async {
    return await repository.getFeatureToggle(toggleKey);
  }
}
