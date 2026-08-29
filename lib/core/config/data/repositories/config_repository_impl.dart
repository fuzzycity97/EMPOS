import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/store_blueprint.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/config_local_data_source.dart';
import '../models/store_blueprint_model.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigLocalDataSource localDataSource;

  ConfigRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, StoreBlueprint>> loadStoreBlueprint() async {
    try {
      final blueprint = await localDataSource.getStoreBlueprint();
      return Right(blueprint);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to load store blueprint: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveStoreBlueprint(StoreBlueprint blueprint) async {
    try {
      final model = StoreBlueprintModel.fromEntity(blueprint);
      await localDataSource.saveStoreBlueprint(model);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save store blueprint: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> getFeatureToggle(String toggleKey) async {
    try {
      final blueprint = await localDataSource.getStoreBlueprint();
      final isEnabled = blueprint.isEnabled(toggleKey, defaultValue: false);
      return Right(isEnabled);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve feature toggle $toggleKey: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> setFeatureToggle(String toggleKey, bool isEnabled) async {
    try {
      final blueprint = await localDataSource.getStoreBlueprint();
      final updatedToggles = Map<String, bool>.from(blueprint.toggles);
      updatedToggles[toggleKey] = isEnabled;
      final updated = blueprint.copyWith(toggles: updatedToggles);
      await localDataSource.saveStoreBlueprint(StoreBlueprintModel.fromEntity(updated));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update feature toggle $toggleKey: $e'));
    }
  }
}
