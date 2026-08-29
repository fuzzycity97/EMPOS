import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../entities/store_blueprint.dart';
import '../repositories/config_repository.dart';

class SaveStoreBlueprintUseCase {
  final ConfigRepository repository;

  SaveStoreBlueprintUseCase(this.repository);

  Future<Either<Failure, void>> call(StoreBlueprint blueprint) async {
    return await repository.saveStoreBlueprint(blueprint);
  }
}
