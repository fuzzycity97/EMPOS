import 'package:equatable/equatable.dart';
import 'shift.dart';

class ConsolidatedZReport extends Equatable {
  final DateTime date;
  final int totalShiftsCount;
  final int totalOrdersCount;
  final double totalGrossSales;
  final double totalNetSales;
  final double totalDiscounts;
  final double totalTax;
  final double totalOpeningCash;
  final double totalExpectedCash;
  final double totalCountedCash;
  final double totalDifference;
  final double totalCashSales;
  final double totalCardSales;
  final double totalInstapaySales;
  final double totalVodafoneSales;
  final double totalRefunds;
  final List<Shift> closedShifts;
  final DateTime generatedAt;

  const ConsolidatedZReport({
    required this.date,
    required this.totalShiftsCount,
    required this.totalOrdersCount,
    required this.totalGrossSales,
    required this.totalNetSales,
    required this.totalDiscounts,
    required this.totalTax,
    required this.totalOpeningCash,
    required this.totalExpectedCash,
    required this.totalCountedCash,
    required this.totalDifference,
    required this.totalCashSales,
    required this.totalCardSales,
    this.totalInstapaySales = 0.0,
    this.totalVodafoneSales = 0.0,
    required this.totalRefunds,
    required this.closedShifts,
    required this.generatedAt,
  });

  bool get isBalanced => totalDifference == 0.0;
  bool get isShortage => totalDifference < 0.0;
  bool get isSurplus => totalDifference > 0.0;

  double get totalDigitalSales =>
      totalCardSales + totalInstapaySales + totalVodafoneSales;

  @override
  List<Object?> get props => [
        date,
        totalShiftsCount,
        totalOrdersCount,
        totalGrossSales,
        totalNetSales,
        totalDiscounts,
        totalTax,
        totalOpeningCash,
        totalExpectedCash,
        totalCountedCash,
        totalDifference,
        totalCashSales,
        totalCardSales,
        totalInstapaySales,
        totalVodafoneSales,
        totalRefunds,
        closedShifts,
        generatedAt,
      ];
}
