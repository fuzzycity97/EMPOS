import '../../domain/entities/z_report.dart';
import 'shift_model.dart';

class ZReportModel extends ZReport {
  const ZReportModel({
    required super.shift,
    required super.totalOrdersCount,
    required super.grossSales,
    required super.netSales,
    required super.totalDiscounts,
    required super.totalTax,
    required super.totalCashSales,
    required super.totalCardSales,
    super.totalInstapaySales = 0.0,
    super.totalVodafoneSales = 0.0,
    super.totalCustomerAccountSales = 0.0,
    required super.totalPayIns,
    required super.totalPayOuts,
    required super.totalRefunds,
    required super.openingCash,
    required super.expectedCash,
    super.actualCash,
    required super.difference,
    required super.generatedAt,
  });

  factory ZReportModel.fromJson(Map<String, dynamic> json) {
    return ZReportModel(
      shift: ShiftModel.fromJson(Map<String, dynamic>.from(json['shift'] as Map)),
      totalOrdersCount: json['totalOrdersCount'] as int,
      grossSales: (json['grossSales'] as num).toDouble(),
      netSales: (json['netSales'] as num).toDouble(),
      totalDiscounts: (json['totalDiscounts'] as num).toDouble(),
      totalTax: (json['totalTax'] as num).toDouble(),
      totalCashSales: (json['totalCashSales'] as num).toDouble(),
      totalCardSales: (json['totalCardSales'] as num).toDouble(),
      totalInstapaySales: (json['totalInstapaySales'] as num?)?.toDouble() ?? 0.0,
      totalVodafoneSales: (json['totalVodafoneSales'] as num?)?.toDouble() ?? 0.0,
      totalCustomerAccountSales: (json['totalCustomerAccountSales'] as num?)?.toDouble() ?? 0.0,
      totalPayIns: (json['totalPayIns'] as num).toDouble(),
      totalPayOuts: (json['totalPayOuts'] as num).toDouble(),
      totalRefunds: (json['totalRefunds'] as num).toDouble(),
      openingCash: (json['openingCash'] as num).toDouble(),
      expectedCash: (json['expectedCash'] as num).toDouble(),
      actualCash: (json['actualCash'] as num?)?.toDouble(),
      difference: (json['difference'] as num).toDouble(),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shift': ShiftModel.fromEntity(shift).toJson(),
      'totalOrdersCount': totalOrdersCount,
      'grossSales': grossSales,
      'netSales': netSales,
      'totalDiscounts': totalDiscounts,
      'totalTax': totalTax,
      'totalCashSales': totalCashSales,
      'totalCardSales': totalCardSales,
      'totalInstapaySales': totalInstapaySales,
      'totalVodafoneSales': totalVodafoneSales,
      'totalCustomerAccountSales': totalCustomerAccountSales,
      'totalPayIns': totalPayIns,
      'totalPayOuts': totalPayOuts,
      'totalRefunds': totalRefunds,
      'openingCash': openingCash,
      'expectedCash': expectedCash,
      'actualCash': actualCash,
      'difference': difference,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
