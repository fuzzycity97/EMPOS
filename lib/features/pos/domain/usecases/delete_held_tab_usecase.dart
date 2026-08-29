import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/pos_repository.dart';

class DeleteHeldTabUseCase {
  final PosRepository repository;

  DeleteHeldTabUseCase(this.repository);

  Future<Either<Failure, Unit>> call(String tabId) async {
    return await repository.deleteHeldTab(tabId);
  }
}
