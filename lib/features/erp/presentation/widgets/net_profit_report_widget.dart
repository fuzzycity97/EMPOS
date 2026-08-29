import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/erp_state.dart';
import 'capital_injection_dialog.dart';
import 'dividend_payout_dialog.dart';
import 'partner_form_dialog.dart';

class NetProfitReportWidget extends StatelessWidget {
  final ErpLoaded state;

  const NetProfitReportWidget({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final report = state.netProfitReport;
    final partners = state.partners;

    if (report == null) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space32),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'Computing Executive Net Profit & Equity Report...',
                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final isProfit = report.netOperatingProfit >= 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------------------------------------------------------------------
          // 1. Top Executive Metric Cards
          // -------------------------------------------------------------------
          Row(
            children: [
              _metricCard(
                title: 'Net Sales Revenue',
                amount: report.netSales,
                subtitle: 'After ${report.refunds.toStringAsFixed(2)} EGP refunds',
                icon: LucideIcons.trendingUp,
                color: AppColors.cyan,
              ),
              const SizedBox(width: AppDimensions.space16),
              _metricCard(
                title: 'Cost of Goods (COGS)',
                amount: report.cogs,
                subtitle: 'Inventory direct cost',
                icon: LucideIcons.boxes,
                color: AppColors.warning,
              ),
              const SizedBox(width: AppDimensions.space16),
              _metricCard(
                title: 'Total OPEX + Payroll',
                amount: report.operatingExpenses + report.payrollExpenses,
                subtitle: '${report.operatingExpenses.toStringAsFixed(0)} exp + ${report.payrollExpenses.toStringAsFixed(0)} pay',
                icon: LucideIcons.receipt,
                color: AppColors.error,
              ),
              const SizedBox(width: AppDimensions.space16),
              _metricCard(
                title: 'Net Operating Profit',
                amount: report.netOperatingProfit,
                subtitle: isProfit ? 'Distributable surplus' : 'Net operating deficit',
                icon: isProfit ? LucideIcons.badgePercent : LucideIcons.triangleAlert,
                color: isProfit ? AppColors.emerald : AppColors.error,
                highlight: true,
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),

          // -------------------------------------------------------------------
          // 2. Financial Waterfall & Equity Pie Chart Row
          // -------------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Financial Waterfall Breakdown Table
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevatedDark,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.fileSpreadsheet, size: 18, color: AppColors.primary),
                              SizedBox(width: 8),
                              Text(
                                'P&L Waterfall Financial Breakdown',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimaryDark,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceDark,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Text(
                              'Period: ${report.month}/${report.year}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      _waterfallRow('Gross Sales Receipts', report.grossSales, isPositive: true),
                      _waterfallRow('(-) Customer Returns & Refunds', -report.refunds, isNegative: true),
                      const Divider(color: AppColors.borderDark, height: 20),
                      _waterfallRow('(=) Net Sales Revenue', report.netSales, isBold: true),
                      _waterfallRow('(-) Cost of Goods Sold (COGS)', -report.cogs, isNegative: true),
                      const Divider(color: AppColors.borderDark, height: 20),
                      _waterfallRow('(=) Gross Operating Margin', report.grossProfit, isBold: true, color: AppColors.cyan),
                      _waterfallRow('(-) Store Operational Overhead', -report.operatingExpenses, isNegative: true),
                      _waterfallRow('(-) Staff Payroll & Net Wages', -report.payrollExpenses, isNegative: true),
                      const Divider(color: AppColors.borderDark, height: 24, thickness: 1.5),
                      _waterfallRow(
                        '(=) Net Operating Distributable Profit',
                        report.netOperatingProfit,
                        isBold: true,
                        color: isProfit ? AppColors.emerald : AppColors.error,
                        isFinal: true,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space16),

              // Equity Share Visualizer Chart
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(AppDimensions.space20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevatedDark,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(LucideIcons.pieChart, size: 18, color: AppColors.emerald),
                          SizedBox(width: 8),
                          Text(
                            'Partner Equity Ownership',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (partners.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Text(
                              'No partners registered yet.',
                              style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                            ),
                          ),
                        )
                      else ...[
                        SizedBox(
                          height: 170,
                          child: PieChart(
                            PieChartData(
                              sectionsSpace: 2,
                              centerSpaceRadius: 36,
                              sections: partners.asMap().entries.map((entry) {
                                final index = entry.key;
                                final p = entry.value;
                                final colors = [
                                  AppColors.primary,
                                  AppColors.emerald,
                                  AppColors.cyan,
                                  AppColors.warning,
                                  Colors.purpleAccent,
                                ];
                                final color = colors[index % colors.length];

                                return PieChartSectionData(
                                  color: color,
                                  value: p.equityPercentage,
                                  title: '${p.equityPercentage.toStringAsFixed(0)}%',
                                  radius: 44,
                                  titleStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Legend List
                        ...partners.asMap().entries.map((entry) {
                          final index = entry.key;
                          final p = entry.value;
                          final colors = [
                            AppColors.primary,
                            AppColors.emerald,
                            AppColors.cyan,
                            AppColors.warning,
                            Colors.purpleAccent,
                          ];
                          final color = colors[index % colors.length];

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(
                              children: [
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    p.name,
                                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimaryDark),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  '${p.equityPercentage.toStringAsFixed(1)}%',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space24),

          // -------------------------------------------------------------------
          // 3. Partner Capital & Profit Shares Roster
          // -------------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevatedDark,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: AppColors.borderDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(LucideIcons.handshake, size: 18, color: AppColors.primary),
                        const SizedBox(width: 8),
                        const Text(
                          'Business Partners & Period Profit Allocation',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                          child: Text(
                            '${partners.length} Partners (${state.totalPartnerEquity.toStringAsFixed(1)}% Allocated)',
                            style: const TextStyle(color: AppColors.primary, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => DividendPayoutDialog.show(context),
                          icon: const Icon(LucideIcons.coins, size: 16, color: AppColors.emerald),
                          label: const Text('Distribute Payout', style: TextStyle(color: AppColors.emerald)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: AppColors.emerald.withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppDimensions.space10),
                        ElevatedButton.icon(
                          onPressed: () => PartnerFormDialog.show(context),
                          icon: const Icon(LucideIcons.userPlus, size: 16),
                          label: const Text('+ Add Partner'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                if (partners.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppDimensions.space32),
                    alignment: Alignment.center,
                    child: const Text(
                      'No business partners found. Click "+ Add Partner" to register equity holders.',
                      style: TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                    ),
                  )
                else
                  Column(
                    children: partners.map((partner) {
                      final shareAmount = report.partnerShares[partner.id] ?? 0.0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: AppDimensions.space10),
                        padding: const EdgeInsets.all(AppDimensions.space14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Left: Partner Info
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(LucideIcons.user, size: 18, color: AppColors.primary),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      partner.name,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimaryDark,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      partner.contactInfo ?? 'No contact info',
                                      style: const TextStyle(fontSize: 11.5, color: AppColors.textMutedDark),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // Middle: Equity, Capital & Withdrawn
                            Row(
                              children: [
                                _partnerStatColumn('Equity', '${partner.equityPercentage.toStringAsFixed(1)}%', AppColors.primary),
                                const SizedBox(width: 24),
                                _partnerStatColumn('Invested Capital', '${partner.totalInvestedCapital.toStringAsFixed(2)} EGP', AppColors.textPrimaryDark),
                                const SizedBox(width: 24),
                                _partnerStatColumn('Withdrawn Dividends', '${partner.withdrawnDividends.toStringAsFixed(2)} EGP', AppColors.warning),
                                const SizedBox(width: 24),
                                _partnerStatColumn(
                                  'Current Period Share',
                                  '${shareAmount.toStringAsFixed(2)} EGP',
                                  shareAmount > 0 ? AppColors.emerald : AppColors.textMutedDark,
                                  isBold: true,
                                ),
                              ],
                            ),

                            // Right: Actions
                            Row(
                              children: [
                                IconButton(
                                  tooltip: 'Inject Capital',
                                  onPressed: () => CapitalInjectionDialog.show(context, partner: partner),
                                  icon: const Icon(LucideIcons.arrowUpRight, color: AppColors.emerald, size: 18),
                                ),
                                IconButton(
                                  tooltip: 'Edit Partner',
                                  onPressed: () => PartnerFormDialog.show(context, partner: partner),
                                  icon: const Icon(LucideIcons.pencil, color: AppColors.cyan, size: 18),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard({
    required String title,
    required double amount,
    required String subtitle,
    required IconData icon,
    required Color color,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: highlight ? color.withValues(alpha: 0.12) : AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(
            color: highlight ? color.withValues(alpha: 0.4) : AppColors.borderDark,
            width: highlight ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 12, color: AppColors.textMutedDark, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${amount.toStringAsFixed(2)} EGP',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: highlight ? color : AppColors.textPrimaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _waterfallRow(
    String label,
    double value, {
    bool isPositive = false,
    bool isNegative = false,
    bool isBold = false,
    bool isFinal = false,
    Color? color,
  }) {
    final displayColor = color ??
        (isNegative
            ? AppColors.error
            : isPositive
                ? AppColors.emerald
                : AppColors.textPrimaryDark);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isFinal ? 14 : 13,
              fontWeight: (isBold || isFinal) ? FontWeight.bold : FontWeight.w500,
              color: isFinal ? displayColor : AppColors.textPrimaryDark,
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} EGP',
            style: TextStyle(
              fontSize: isFinal ? 15 : 13,
              fontWeight: (isBold || isFinal) ? FontWeight.w900 : FontWeight.bold,
              color: displayColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _partnerStatColumn(String label, String value, Color valueColor, {bool isBold = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10.5, color: AppColors.textMutedDark, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}
