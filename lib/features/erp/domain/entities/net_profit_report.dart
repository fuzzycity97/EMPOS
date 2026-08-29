import 'package:equatable/equatable.dart';

class NetProfitReport extends Equatable {
  final int month;
  final int year;
  final double grossSales;
  final double refunds;
  final double netSales;
  final double cogs;
  final double grossProfit;
  final double operatingExpenses;
  final double payrollExpenses;
  final double netOperatingProfit;
  final Map<String, double> partnerShares; // partnerId -> share amount

  const NetProfitReport({
    required this.month,
    required this.year,
    required this.grossSales,
    required this.refunds,
    required this.netSales,
    required this.cogs,
    required this.grossProfit,
    required this.operatingExpenses,
    required this.payrollExpenses,
    required this.netOperatingProfit,
    required this.partnerShares,
  });

  factory NetProfitReport.compute({
    required int month,
    required int year,
    required double grossSales,
    required double refunds,
    required double cogs,
    required double operatingExpenses,
    required double payrollExpenses,
    required Map<String, double> equityPercentages, // partnerId -> equity % (e.g. 50.0)
  }) {
    final netSales = (grossSales - refunds).clamp(0.0, double.infinity);
    final grossProfit = (netSales - cogs).clamp(0.0, double.infinity);
    final netOperatingProfit = (grossProfit - operatingExpenses - payrollExpenses);

    final Map<String, double> partnerShares = {};
    for (final entry in equityPercentages.entries) {
      final shareAmount = netOperatingProfit > 0
          ? (netOperatingProfit * (entry.value / 100.0))
          : 0.0;
      partnerShares[entry.key] = shareAmount;
    }

    return NetProfitReport(
      month: month,
      year: year,
      grossSales: grossSales,
      refunds: refunds,
      netSales: netSales,
      cogs: cogs,
      grossProfit: grossProfit,
      operatingExpenses: operatingExpenses,
      payrollExpenses: payrollExpenses,
      netOperatingProfit: netOperatingProfit,
      partnerShares: partnerShares,
    );
  }

  @override
  List<Object?> get props => [
        month,
        year,
        grossSales,
        refunds,
        netSales,
        cogs,
        grossProfit,
        operatingExpenses,
        payrollExpenses,
        netOperatingProfit,
        partnerShares,
      ];
}
