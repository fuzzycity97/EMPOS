import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/product.dart';
import '../repositories/catalog_repository.dart';

class GetProductByBarcodeUseCase {
  final CatalogRepository repository;

  GetProductByBarcodeUseCase(this.repository);

  Future<Either<Failure, Product>> call(String barcode) async {
    return await repository.getProductByBarcode(barcode);
  }
}
