import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../entities/store_blueprint.dart';
import '../repositories/config_repository.dart';

class LoadStoreBlueprintUseCase {
  final ConfigRepository repository;

  LoadStoreBlueprintUseCase(this.repository);

  Future<Either<Failure, StoreBlueprint>> call() async {
    return await repository.loadStoreBlueprint();
  }
}
