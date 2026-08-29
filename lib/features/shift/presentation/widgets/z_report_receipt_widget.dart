import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/z_report.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';

class ZReportReceiptWidget extends StatelessWidget {
  final ZReport zReport;

  const ZReportReceiptWidget({super.key, required this.zReport});

  @override
  Widget build(BuildContext context) {
    final shift = zReport.shift;

    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space24),
        constraints: const BoxConstraints(maxWidth: 440),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              const Icon(
                LucideIcons.fileSpreadsheet,
                size: 36,
                color: Color(0xFF0F172A),
              ),
              const SizedBox(height: 8),
              const Text(
                'END-OF-DAY Z-REPORT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 1.0,
                ),
              ),
              const Text(
                'EMPOS Commercial Retail Audit Record',
                style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE2E8F0)),

              // Shift Metadata
              _receiptRow('Shift ID', shift.id),
              _receiptRow('Cashier', shift.cashierName ?? shift.cashierId),
              _receiptRow('Start Time', DateFormatter.formatDateTime(shift.startTime)),
              if (shift.endTime != null)
                _receiptRow('End Time', DateFormatter.formatDateTime(shift.endTime!)),
              _receiptRow('Total Orders', '${zReport.totalOrdersCount} Completed'),
              const Divider(color: Color(0xFFE2E8F0)),

              // Sales Summary
              _sectionHeader('SALES PERFORMANCE'),
              _receiptRow('Gross Sales', CurrencyFormatter.format(zReport.grossSales)),
              if (zReport.totalDiscounts > 0)
                _receiptRow(
                  'Total Discounts',
                  '- ${CurrencyFormatter.format(zReport.totalDiscounts)}',
                  color: const Color(0xFFD97706),
                ),
              _receiptRow('Total VAT (14%)', CurrencyFormatter.format(zReport.totalTax)),
              _receiptRow(
                'NET SALES REVENUE',
                CurrencyFormatter.format(zReport.netSales),
                isBold: true,
              ),
              const Divider(color: Color(0xFFE2E8F0)),

              // Tenders Breakdown
              _sectionHeader('TENDER COLLECTIONS'),
              _receiptRow('Cash Sales', CurrencyFormatter.format(zReport.totalCashSales)),
              _receiptRow('Card Sales', CurrencyFormatter.format(zReport.totalCardSales)),
              if (zReport.totalInstapaySales > 0)
                _receiptRow('Instapay Sales', CurrencyFormatter.format(zReport.totalInstapaySales)),
              if (zReport.totalVodafoneSales > 0)
                _receiptRow('Vodafone Cash Sales', CurrencyFormatter.format(zReport.totalVodafoneSales)),
              if (zReport.totalCustomerAccountSales > 0)
                _receiptRow('Customer Credit', CurrencyFormatter.format(zReport.totalCustomerAccountSales)),
              const Divider(color: Color(0xFFE2E8F0)),

              // Cash Drawer Audit & Reconciliation
              _sectionHeader('CASH DRAWER RECONCILIATION'),
              _receiptRow('Opening Cash Float', CurrencyFormatter.format(zReport.openingCash)),
              _receiptRow('Gross Cash Inflow', '+ ${CurrencyFormatter.format(zReport.totalCashSales)}'),
              if (zReport.totalPayIns > 0)
                _receiptRow('Pay-Ins (Float Add)', '+ ${CurrencyFormatter.format(zReport.totalPayIns)}'),
              if (zReport.totalPayOuts > 0)
                _receiptRow('Pay-Outs (Expenses)', '- ${CurrencyFormatter.format(zReport.totalPayOuts)}'),
              if (zReport.totalRefunds > 0)
                _receiptRow('Cash Refunds', '- ${CurrencyFormatter.format(zReport.totalRefunds)}'),
              const Divider(color: Color(0xFFE2E8F0)),
              _receiptRow(
                'EXPECTED CASH',
                CurrencyFormatter.format(zReport.expectedCash),
                isBold: true,
              ),
              if (zReport.actualCash != null)
                _receiptRow(
                  'ACTUAL COUNTED CASH',
                  CurrencyFormatter.format(zReport.actualCash!),
                  isBold: true,
                ),
              _receiptRow(
                'RECONCILIATION DIFFERENCE',
                zReport.difference == 0
                    ? 'BALANCED (0.00)'
                    : (zReport.difference < 0
                        ? 'SHORTAGE (${CurrencyFormatter.format(zReport.difference)})'
                        : 'SURPLUS (+${CurrencyFormatter.format(zReport.difference)})'),
                isBold: true,
                color: zReport.difference == 0
                    ? const Color(0xFF059669)
                    : (zReport.difference < 0
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFD97706)),
              ),
              const SizedBox(height: 20),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Z-Report dispatched to thermal printer.'),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.printer, size: 14),
                      label: const Text('Print Audit', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        context.read<ShiftBloc>().add(const DismissZReportEvent());
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(LucideIcons.check, size: 14),
                      label: const Text('Done', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(
    String label,
    String value, {
    bool isBold = false,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 12 : 11,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
              color: color ?? const Color(0xFF334155),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 13 : 11,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: color ?? const Color(0xFF0F172A),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
