import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/net_profit_report.dart';
import '../repositories/erp_repository.dart';

class CalculateNetProfitReportUseCase {
  final ErpRepository repository;

  CalculateNetProfitReportUseCase(this.repository);

  Future<Either<Failure, NetProfitReport>> call({
    required int month,
    required int year,
  }) async {
    return await repository.calculateNetProfitReport(
      month: month,
      year: year,
    );
  }
}
