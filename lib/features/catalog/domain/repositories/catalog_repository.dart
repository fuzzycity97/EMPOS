import 'package:dartz/dartz.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/error/failures.dart';
import '../entities/category.dart';
import '../entities/product.dart';

abstract class CatalogRepository {
  Future<Either<Failure, List<Product>>> getProducts({
    String? categoryId,
    bool? onlyActive,
  });

  Future<Either<Failure, Product>> getProductByBarcode(String barcode);

  Future<Either<Failure, Product>> getProductById(String id);

  Future<Either<Failure, List<Product>>> searchProducts(String query);

  Future<Either<Failure, List<Category>>> getCategories({bool? onlyActive});

  Future<Either<Failure, Unit>> saveProduct(Product product);

  Future<Either<Failure, Unit>> deleteProduct(String id);

  Future<Either<Failure, Unit>> saveCategory(Category category);

  Future<Either<Failure, Unit>> deleteCategory(String id);

  Future<Either<Failure, Unit>> toggleCategoryStatus(String id, bool isEnabled);

  Future<Either<Failure, Unit>> updateStock(String productId, int quantityDelta);

  Future<Either<Failure, Unit>> seedCatalogForBlueprint(StoreBlueprint blueprint, {bool force = false});
}
