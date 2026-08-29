import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/dividend_payout.dart';
import '../repositories/erp_repository.dart';

class GetDividendPayoutsUseCase {
  final ErpRepository repository;

  GetDividendPayoutsUseCase(this.repository);

  Future<Either<Failure, List<DividendPayout>>> call({
    String? partnerId,
    int? month,
    int? year,
  }) async {
    return await repository.getDividendPayouts(
      partnerId: partnerId,
      month: month,
      year: year,
    );
  }
}
