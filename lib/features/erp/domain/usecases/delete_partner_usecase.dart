import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/erp_repository.dart';

class DeletePartnerUseCase {
  final ErpRepository repository;

  DeletePartnerUseCase(this.repository);

  Future<Either<Failure, void>> call(String partnerId) async {
    return await repository.deletePartner(partnerId);
  }
}
