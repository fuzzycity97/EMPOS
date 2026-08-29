import 'package:dartz/dartz.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/catalog_repository.dart';
import '../datasources/catalog_local_data_source.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final CatalogLocalDataSource localDataSource;

  CatalogRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<Product>>> getProducts({
    String? categoryId,
    bool? onlyActive,
  }) async {
    try {
      final products = await localDataSource.getProducts(
        categoryId: categoryId,
        onlyActive: onlyActive,
      );
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected catalog error: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    try {
      final product = await localDataSource.getProductById(id);
      return Right(product);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected error fetching product: $e'));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    try {
      final product = await localDataSource.getProductByBarcode(barcode);
      return Right(product);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected barcode error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = await localDataSource.searchProducts(query);
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected search error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories({bool? onlyActive}) async {
    try {
      final categories = await localDataSource.getCategories(onlyActive: onlyActive);
      return Right(categories);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Unexpected categories error: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveProduct(Product product) async {
    try {
      await localDataSource.saveProduct(ProductModel.fromEntity(product));
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to persist product: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteProduct(String id) async {
    try {
      await localDataSource.deleteProduct(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete product: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> saveCategory(Category category) async {
    try {
      await localDataSource.saveCategory(CategoryModel.fromEntity(category));
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to persist category: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(String id) async {
    try {
      await localDataSource.deleteCategory(id);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete category: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> toggleCategoryStatus(String id, bool isEnabled) async {
    try {
      await localDataSource.toggleCategoryStatus(id, isEnabled);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to toggle category: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateStock(String productId, int quantityDelta) async {
    try {
      await localDataSource.updateStock(productId, quantityDelta);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update stock: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> seedCatalogForBlueprint(StoreBlueprint blueprint, {bool force = false}) async {
    try {
      await localDataSource.seedCatalogForBlueprint(blueprint, force: force);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to seed catalog for blueprint: $e'));
    }
  }
}
