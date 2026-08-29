import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/business_partner.dart';
import '../repositories/erp_repository.dart';

class GetPartnersUseCase {
  final ErpRepository repository;

  GetPartnersUseCase(this.repository);

  Future<Either<Failure, List<BusinessPartner>>> call() async {
    return await repository.getPartners();
  }
}
