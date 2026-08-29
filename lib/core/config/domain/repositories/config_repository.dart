import 'package:dartz/dartz.dart';
import '../../../error/failures.dart';
import '../entities/store_blueprint.dart';

abstract class ConfigRepository {
  Future<Either<Failure, StoreBlueprint>> loadStoreBlueprint();
  Future<Either<Failure, void>> saveStoreBlueprint(StoreBlueprint blueprint);
  Future<Either<Failure, bool>> getFeatureToggle(String toggleKey);
  Future<Either<Failure, void>> setFeatureToggle(String toggleKey, bool isEnabled);
}
