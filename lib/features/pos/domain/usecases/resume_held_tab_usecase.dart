import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../repositories/pos_repository.dart';

class ResumeHeldTabUseCase {
  final PosRepository repository;

  ResumeHeldTabUseCase(this.repository);

  Future<Either<Failure, Cart>> call(String tabId) async {
    return await repository.resumeHeldTab(tabId);
  }
}
