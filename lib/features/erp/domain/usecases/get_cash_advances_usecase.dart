import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cash_advance.dart';
import '../repositories/erp_repository.dart';

class GetCashAdvancesUseCase {
  final ErpRepository repository;

  GetCashAdvancesUseCase(this.repository);

  Future<Either<Failure, List<CashAdvance>>> call({
    String? employeeId,
    int? month,
    int? year,
  }) async {
    return await repository.getCashAdvances(
      employeeId: employeeId,
      month: month,
      year: year,
    );
  }
}
