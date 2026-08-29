import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/catalog_repository.dart';

class DeleteProductUseCase {
  final CatalogRepository repository;

  DeleteProductUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String id) async {
    return await repository.deleteProduct(id);
  }
}
