import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../repositories/pos_repository.dart';

class UpdateCartQuantityParams {
  final Cart currentCart;
  final String productId;
  final int quantity;

  const UpdateCartQuantityParams({
    required this.currentCart,
    required this.productId,
    required this.quantity,
  });
}

class UpdateCartQuantityUseCase {
  final PosRepository repository;

  UpdateCartQuantityUseCase(this.repository);

  Future<Either<Failure, Cart>> call(UpdateCartQuantityParams params) async {
    return await repository.updateItemQuantity(
      currentCart: params.currentCart,
      productId: params.productId,
      quantity: params.quantity,
    );
  }
}
