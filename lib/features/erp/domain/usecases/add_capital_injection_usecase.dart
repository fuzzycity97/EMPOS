import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/business_partner.dart';
import '../repositories/erp_repository.dart';

class AddCapitalInjectionUseCase {
  final ErpRepository repository;

  AddCapitalInjectionUseCase(this.repository);

  Future<Either<Failure, BusinessPartner>> call({
    required String partnerId,
    required double amount,
  }) async {
    return await repository.addCapitalInjection(
      partnerId: partnerId,
      amount: amount,
    );
  }
}
