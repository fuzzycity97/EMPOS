import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../repositories/pos_repository.dart';

class GetActiveCartUseCase {
  final PosRepository repository;

  GetActiveCartUseCase(this.repository);

  Future<Either<Failure, Cart>> call() async {
    return await repository.getActiveCart();
  }
}
