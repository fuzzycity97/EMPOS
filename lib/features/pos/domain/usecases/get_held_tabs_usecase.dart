import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/hold_tab.dart';
import '../repositories/pos_repository.dart';

class GetHeldTabsUseCase {
  final PosRepository repository;

  GetHeldTabsUseCase(this.repository);

  Future<Either<Failure, List<HoldTab>>> call() async {
    return await repository.getHeldTabs();
  }
}
