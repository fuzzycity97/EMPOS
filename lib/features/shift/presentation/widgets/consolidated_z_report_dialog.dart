import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/consolidated_z_report.dart';
import '../../domain/entities/shift.dart';
import '../../domain/usecases/generate_consolidated_z_report_usecase.dart';

class ConsolidatedZReportDialog extends StatelessWidget {
  final GenerateConsolidatedZReportUseCase? useCase;
  final ValueNotifier<bool> isLoadingNotifier;
  final ValueNotifier<ConsolidatedZReport?> reportNotifier;
  final ValueNotifier<String?> errorNotifier;

  const ConsolidatedZReportDialog._({
    super.key,
    required this.useCase,
    required this.isLoadingNotifier,
    required this.reportNotifier,
    required this.errorNotifier,
  });

  factory ConsolidatedZReportDialog({
    Key? key,
    GenerateConsolidatedZReportUseCase? customUseCase,
  }) {
    final uc = customUseCase ?? sl<GenerateConsolidatedZReportUseCase>();
    final isLoading = ValueNotifier<bool>(true);
    final report = ValueNotifier<ConsolidatedZReport?>(null);
    final error = ValueNotifier<String?>(null);

    // Initial load
    uc().then((result) {
      isLoading.value = false;
      result.fold(
        (failure) => error.value = failure.message,
        (data) => report.value = data,
      );
    });

    return ConsolidatedZReportDialog._(
      key: key,
      useCase: uc,
      isLoadingNotifier: isLoading,
      reportNotifier: report,
      errorNotifier: error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Container(
        width: 860,
        constraints: const BoxConstraints(maxHeight: 740),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.borderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space16,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(LucideIcons.fileSpreadsheet, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consolidated Daily Z-Report',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Multi-register financial reconciliation across all staff shifts for today',
                          style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AppColors.textSecondaryDark, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── BODY ────────────────────────────────────────────────────────
            Expanded(
              child: ValueListenableBuilder<bool>(
                valueListenable: isLoadingNotifier,
                builder: (context, isLoading, _) {
                  if (isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  return ValueListenableBuilder<String?>(
                    valueListenable: errorNotifier,
                    builder: (context, errorMsg, _) {
                      if (errorMsg != null) {
                        return Center(
                          child: Text(
                            'Error: $errorMsg',
                            style: const TextStyle(color: AppColors.danger),
                          ),
                        );
                      }

                      return ValueListenableBuilder<ConsolidatedZReport?>(
                        valueListenable: reportNotifier,
                        builder: (context, report, _) {
                          if (report == null) {
                            return const Center(
                              child: Text(
                                'No report data available.',
                                style: TextStyle(color: AppColors.textSecondaryDark),
                              ),
                            );
                          }

                          return _buildReportContent(context, report);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            // ── FOOTER ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space12,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Generated at ${DateTime.now().toLocal().toString().split(".")[0]}',
                    style: const TextStyle(color: AppColors.textMutedDark, fontSize: 11.5),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(BuildContext context, ConsolidatedZReport report) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppDimensions.space20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KPI SUMMARY TILES ─────────────────────────────────────────────
          Row(
            children: [
              _buildKpiCard(
                title: 'TOTAL NET SALES',
                value: CurrencyFormatter.format(report.totalNetSales),
                subtitle: '${report.totalOrdersCount} Orders (${report.totalShiftsCount} Shifts)',
                color: AppColors.primary,
                icon: LucideIcons.trendingUp,
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                title: 'EXPECTED CASH',
                value: CurrencyFormatter.format(report.totalExpectedCash),
                subtitle: 'Opening: ${CurrencyFormatter.format(report.totalOpeningCash)}',
                color: AppColors.info,
                icon: LucideIcons.wallet,
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                title: 'COUNTED CASH',
                value: CurrencyFormatter.format(report.totalCountedCash),
                subtitle: 'Variance: ${CurrencyFormatter.format(report.totalDifference)}',
                color: report.isShortage
                    ? AppColors.danger
                    : report.isSurplus
                        ? AppColors.warning
                        : AppColors.success,
                icon: LucideIcons.coins,
              ),
              const SizedBox(width: 12),
              _buildKpiCard(
                title: 'DIGITAL / CARD',
                value: CurrencyFormatter.format(report.totalDigitalSales),
                subtitle: 'Card: ${CurrencyFormatter.format(report.totalCardSales)}',
                color: AppColors.accent,
                icon: LucideIcons.creditCard,
              ),
            ],
          ),

          const SizedBox(height: AppDimensions.space24),

          // ── PAYMENT BREAKDOWN SUMMARY ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(AppDimensions.space16),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevatedDark,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSubMetric('Cash Sales', CurrencyFormatter.format(report.totalCashSales)),
                  const SizedBox(width: 24),
                  _buildSubMetric('Card Sales', CurrencyFormatter.format(report.totalCardSales)),
                  const SizedBox(width: 24),
                  _buildSubMetric('InstaPay / Wallet', CurrencyFormatter.format(report.totalInstapaySales + report.totalVodafoneSales)),
                  const SizedBox(width: 24),
                  _buildSubMetric('Discounts', CurrencyFormatter.format(report.totalDiscounts)),
                  const SizedBox(width: 24),
                  _buildSubMetric('Total Tax', CurrencyFormatter.format(report.totalTax)),
                  const SizedBox(width: 24),
                  _buildSubMetric('Total Refunds', CurrencyFormatter.format(report.totalRefunds), isDanger: report.totalRefunds > 0),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppDimensions.space24),

          // ── SHIFTS AUDIT LOG TABLE ────────────────────────────────────────
          const Text(
            'CLOSED REGISTER SHIFTS AUDIT LOG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          if (report.closedShifts.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              alignment: Alignment.center,
              child: const Text(
                'No closed shifts recorded for today yet.',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderDark),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Table(
                border: TableBorder.symmetric(
                  inside: const BorderSide(color: AppColors.borderDark),
                ),
                columnWidths: const {
                  0: FlexColumnWidth(2.5),
                  1: FlexColumnWidth(2),
                  2: FlexColumnWidth(1.8),
                  3: FlexColumnWidth(1.8),
                  4: FlexColumnWidth(1.8),
                  5: FlexColumnWidth(1.8),
                },
                children: [
                  TableRow(
                    decoration: const BoxDecoration(color: AppColors.surfaceElevatedDark),
                    children: [
                      _buildTableHeader('Cashier / Shift'),
                      _buildTableHeader('Duration'),
                      _buildTableHeader('Opening Float'),
                      _buildTableHeader('Expected'),
                      _buildTableHeader('Counted'),
                      _buildTableHeader('Variance'),
                    ],
                  ),
                  for (final shift in report.closedShifts)
                    TableRow(
                      children: [
                        _buildTableCell('${shift.cashierName ?? "Cashier"} (${shift.id.substring(0, 8)})'),
                        _buildTableCell(_formatDuration(shift)),
                        _buildTableCell(CurrencyFormatter.format(shift.startingCash)),
                        _buildTableCell(CurrencyFormatter.format(shift.expectedCash)),
                        _buildTableCell(CurrencyFormatter.format(shift.actualCash ?? 0.0)),
                        _buildVarianceCell(shift),
                      ],
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMetric(String label, String value, {bool isDanger = false}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: isDanger ? AppColors.danger : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTableCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        text,
        style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11.5),
      ),
    );
  }

  Widget _buildVarianceCell(Shift shift) {
    final diff = shift.difference;
    final isShort = diff < -0.01;
    final isSurp = diff > 0.01;

    final color = isShort ? AppColors.danger : isSurp ? AppColors.warning : AppColors.success;
    final label = CurrencyFormatter.format(diff);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDuration(Shift shift) {
    if (shift.endTime == null) return 'Open';
    final duration = shift.endTime!.difference(shift.startTime);
    final hours = duration.inHours;
    final mins = duration.inMinutes % 60;
    return '${hours}h ${mins}m';
  }
}
