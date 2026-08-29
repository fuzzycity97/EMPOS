import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/refund_transaction.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';

class RefundReceiptWidget extends StatelessWidget {
  final RefundTransaction refund;

  const RefundReceiptWidget({super.key, required this.refund});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space24),
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.rotateCcw,
                  size: 28,
                  color: Color(0xFFDC2626),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'RETURN & REFUND VOUCHER',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: 1.0,
                ),
              ),
              const Text(
                'EMPOS Retail Return Audit Voucher',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFE2E8F0)),

              // Refund Metadata
              _receiptRow('Voucher No.', refund.refundNumber, isBold: true),
              _receiptRow('Original Order', '#${refund.originalOrderNumber}'),
              _receiptRow('Date & Time', DateFormatter.formatDateTime(refund.createdAt)),
              if (refund.cashierId != null)
                _receiptRow('Processed By', refund.cashierId!),
              if (refund.reason.isNotEmpty)
                _receiptRow('Return Reason', refund.reason),
              const Divider(color: Color(0xFFE2E8F0)),

              // Items Refunded List
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'RETURNED ITEMS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF475569),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              ...refund.refundedItems.map((item) {
                final lineSubtotal = item.unitPrice * item.quantity;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${item.product.nameEn} (x${item.quantity})',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      Text(
                        '- ${CurrencyFormatter.format(lineSubtotal)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFDC2626),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(color: Color(0xFFE2E8F0)),

              // Total Refunded
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL REFUNDED:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '- ${CurrencyFormatter.format(refund.refundTotal)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFDC2626),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              _receiptRow(
                'Refund Tender',
                refund.refundTender.name.toUpperCase(),
                isBold: true,
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
                            content: Text('Refund Voucher sent to thermal printer.'),
                          ),
                        );
                      },
                      icon: const Icon(LucideIcons.printer, size: 14),
                      label: const Text('Print Voucher', style: TextStyle(fontSize: 12)),
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
                        context.read<OrdersBloc>().add(const DismissRefundReceiptEvent());
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

  Widget _receiptRow(String label, String value, {bool isBold = false}) {
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
              color: const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 12 : 11,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: const Color(0xFF0F172A),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
