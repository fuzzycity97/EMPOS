import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/catalog_repository.dart';

class GetProductsParams {
  final String? categoryId;
  final bool? onlyActive;

  const GetProductsParams({this.categoryId, this.onlyActive});
}

class GetProductsUseCase {
  final CatalogRepository repository;

  GetProductsUseCase(this.repository);

  Future<Either<Failure, List<Product>>> call([GetProductsParams? params]) async {
    return await repository.getProducts(
      categoryId: params?.categoryId,
      onlyActive: params?.onlyActive,
    );
  }
}
