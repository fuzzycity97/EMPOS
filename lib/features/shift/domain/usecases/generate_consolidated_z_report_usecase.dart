import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/consolidated_z_report.dart';
import '../entities/shift.dart';
import '../repositories/shift_repository.dart';

class GenerateConsolidatedZReportUseCase {
  final ShiftRepository repository;

  GenerateConsolidatedZReportUseCase(this.repository);

  Future<Either<Failure, ConsolidatedZReport>> call({DateTime? targetDate}) async {
    try {
      final date = targetDate ?? DateTime.now();
      final historyResult = await repository.getShiftHistory();

      return await historyResult.fold(
        (failure) => Left(failure),
        (shifts) async {
          // Filter closed shifts from the target calendar day
          final closedShiftsToday = shifts.where((s) {
            if (s.status != ShiftStatus.closed) return false;
            final shiftDay = s.endTime ?? s.startTime;
            return shiftDay.year == date.year &&
                shiftDay.month == date.month &&
                shiftDay.day == date.day;
          }).toList();

          int totalOrdersCount = 0;
          double totalGrossSales = 0.0;
          double totalNetSales = 0.0;
          double totalDiscounts = 0.0;
          double totalTax = 0.0;
          double totalOpeningCash = 0.0;
          double totalExpectedCash = 0.0;
          double totalCountedCash = 0.0;
          double totalDifference = 0.0;
          double totalCashSales = 0.0;
          double totalCardSales = 0.0;
          double totalInstapaySales = 0.0;
          double totalVodafoneSales = 0.0;
          double totalRefunds = 0.0;

          for (final shift in closedShiftsToday) {
            totalOpeningCash += shift.startingCash;
            totalExpectedCash += shift.expectedCash;
            totalCountedCash += (shift.actualCash ?? shift.expectedCash);
            totalDifference += shift.difference;

            final zReportResult = await repository.generateZReport(shift.id);
            zReportResult.fold(
              (_) {},
              (zReport) {
                totalOrdersCount += zReport.totalOrdersCount;
                totalGrossSales += zReport.grossSales;
                totalNetSales += zReport.netSales;
                totalDiscounts += zReport.totalDiscounts;
                totalTax += zReport.totalTax;
                totalCashSales += zReport.totalCashSales;
                totalCardSales += zReport.totalCardSales;
                totalInstapaySales += zReport.totalInstapaySales;
                totalVodafoneSales += zReport.totalVodafoneSales;
                totalRefunds += zReport.totalRefunds;
              },
            );
          }

          final report = ConsolidatedZReport(
            date: date,
            totalShiftsCount: closedShiftsToday.length,
            totalOrdersCount: totalOrdersCount,
            totalGrossSales: double.parse(totalGrossSales.toStringAsFixed(2)),
            totalNetSales: double.parse(totalNetSales.toStringAsFixed(2)),
            totalDiscounts: double.parse(totalDiscounts.toStringAsFixed(2)),
            totalTax: double.parse(totalTax.toStringAsFixed(2)),
            totalOpeningCash: double.parse(totalOpeningCash.toStringAsFixed(2)),
            totalExpectedCash: double.parse(totalExpectedCash.toStringAsFixed(2)),
            totalCountedCash: double.parse(totalCountedCash.toStringAsFixed(2)),
            totalDifference: double.parse(totalDifference.toStringAsFixed(2)),
            totalCashSales: double.parse(totalCashSales.toStringAsFixed(2)),
            totalCardSales: double.parse(totalCardSales.toStringAsFixed(2)),
            totalInstapaySales: double.parse(totalInstapaySales.toStringAsFixed(2)),
            totalVodafoneSales: double.parse(totalVodafoneSales.toStringAsFixed(2)),
            totalRefunds: double.parse(totalRefunds.toStringAsFixed(2)),
            closedShifts: closedShiftsToday,
            generatedAt: DateTime.now(),
          );

          return Right(report);
        },
      );
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to generate consolidated Z-Report: $e'));
    }
  }
}
