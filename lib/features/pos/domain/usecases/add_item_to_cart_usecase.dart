import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/product.dart';
import '../entities/cart.dart';
import '../repositories/pos_repository.dart';

class AddItemToCartParams {
  final Cart currentCart;
  final Product product;
  final int quantity;

  const AddItemToCartParams({
    required this.currentCart,
    required this.product,
    this.quantity = 1,
  });
}

class AddItemToCartUseCase {
  final PosRepository repository;

  AddItemToCartUseCase(this.repository);

  Future<Either<Failure, Cart>> call(AddItemToCartParams params) async {
    return await repository.addItemToCart(
      currentCart: params.currentCart,
      product: params.product,
      quantity: params.quantity,
    );
  }
}
