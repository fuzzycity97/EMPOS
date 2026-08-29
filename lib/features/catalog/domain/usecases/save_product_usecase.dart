import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/catalog_repository.dart';

class SaveProductUseCase {
  final CatalogRepository repository;

  SaveProductUseCase(this.repository);

  Future<Either<Failure, Unit>> call(Product product) async {
    return await repository.saveProduct(product);
  }
}
