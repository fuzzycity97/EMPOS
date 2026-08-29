import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/business_partner.dart';
import '../repositories/erp_repository.dart';

class SavePartnerUseCase {
  final ErpRepository repository;

  SavePartnerUseCase(this.repository);

  Future<Either<Failure, BusinessPartner>> call(BusinessPartner partner) async {
    return await repository.savePartner(partner);
  }
}
