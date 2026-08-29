import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../entities/cart_discount.dart';
import '../repositories/pos_repository.dart';

class ApplyCartDiscountParams {
  final Cart currentCart;
  final CartDiscount discount;

  const ApplyCartDiscountParams({
    required this.currentCart,
    required this.discount,
  });
}

class ApplyCartDiscountUseCase {
  final PosRepository repository;

  ApplyCartDiscountUseCase(this.repository);

  Future<Either<Failure, Cart>> call(ApplyCartDiscountParams params) async {
    return await repository.applyCartDiscount(
      currentCart: params.currentCart,
      discount: params.discount,
    );
  }
}
