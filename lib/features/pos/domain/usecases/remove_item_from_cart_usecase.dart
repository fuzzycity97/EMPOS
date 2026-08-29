import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../repositories/pos_repository.dart';

class RemoveItemFromCartParams {
  final Cart currentCart;
  final String productId;

  const RemoveItemFromCartParams({
    required this.currentCart,
    required this.productId,
  });
}

class RemoveItemFromCartUseCase {
  final PosRepository repository;

  RemoveItemFromCartUseCase(this.repository);

  Future<Either<Failure, Cart>> call(RemoveItemFromCartParams params) async {
    return await repository.removeItemFromCart(
      currentCart: params.currentCart,
      productId: params.productId,
    );
  }
}
