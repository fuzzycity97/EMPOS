import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/catalog_repository.dart';

class ToggleCategoryStatusUseCase {
  final CatalogRepository repository;

  ToggleCategoryStatusUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String categoryId, bool isEnabled) async {
    return await repository.toggleCategoryStatus(categoryId, isEnabled);
  }
}
