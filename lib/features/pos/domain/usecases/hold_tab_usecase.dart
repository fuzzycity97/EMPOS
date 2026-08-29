import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../repositories/pos_repository.dart';

class HoldTabParams {
  final Cart cart;
  final String tabTitle;
  final String? customerPhone;
  final String? customerName;

  const HoldTabParams({
    required this.cart,
    required this.tabTitle,
    this.customerPhone,
    this.customerName,
  });
}

class HoldTabUseCase {
  final PosRepository repository;

  HoldTabUseCase(this.repository);

  Future<Either<Failure, Unit>> call(HoldTabParams params) async {
    return await repository.holdTab(
      cart: params.cart,
      tabTitle: params.tabTitle,
      customerPhone: params.customerPhone,
      customerName: params.customerName,
    );
  }
}
