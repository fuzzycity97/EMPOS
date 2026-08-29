import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../repositories/catalog_repository.dart';

class SaveCategoryUseCase {
  final CatalogRepository repository;

  SaveCategoryUseCase(this.repository);

  Future<Either<Failure, Unit>> call(Category category) async {
    return await repository.saveCategory(category);
  }
}
