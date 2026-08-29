import 'package:equatable/equatable.dart';
import 'shift.dart';

class ZReport extends Equatable {
  final Shift shift;
  final int totalOrdersCount;
  final double grossSales;
  final double netSales;
  final double totalDiscounts;
  final double totalTax;
  final double totalCashSales;
  final double totalCardSales;
  final double totalInstapaySales;
  final double totalVodafoneSales;
  final double totalCustomerAccountSales;
  final double totalPayIns;
  final double totalPayOuts;
  final double totalRefunds;
  final double openingCash;
  final double expectedCash;
  final double? actualCash;
  final double difference;
  final DateTime generatedAt;

  const ZReport({
    required this.shift,
    required this.totalOrdersCount,
    required this.grossSales,
    required this.netSales,
    required this.totalDiscounts,
    required this.totalTax,
    required this.totalCashSales,
    required this.totalCardSales,
    this.totalInstapaySales = 0.0,
    this.totalVodafoneSales = 0.0,
    this.totalCustomerAccountSales = 0.0,
    required this.totalPayIns,
    required this.totalPayOuts,
    required this.totalRefunds,
    required this.openingCash,
    required this.expectedCash,
    this.actualCash,
    required this.difference,
    required this.generatedAt,
  });

  double get totalDigitalSales =>
      totalCardSales + totalInstapaySales + totalVodafoneSales;

  @override
  List<Object?> get props => [
        shift,
        totalOrdersCount,
        grossSales,
        netSales,
        totalDiscounts,
        totalTax,
        totalCashSales,
        totalCardSales,
        totalInstapaySales,
        totalVodafoneSales,
        totalCustomerAccountSales,
        totalPayIns,
        totalPayOuts,
        totalRefunds,
        openingCash,
        expectedCash,
        actualCash,
        difference,
        generatedAt,
      ];
}
