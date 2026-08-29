import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/order.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';

class CheckoutReceiptDialog extends StatelessWidget {
  final PosOrder order;

  const CheckoutReceiptDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space20),
        constraints: const BoxConstraints(maxWidth: 380),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thermal Receipt Header
            const Icon(LucideIcons.checkCircle2, color: AppColors.success, size: 36),
            const SizedBox(height: 8),
            const Text(
              'PAYMENT SUCCESSFUL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
                letterSpacing: 0.5,
              ),
            ),
            const Text(
              'EMPOS Commercial Retail Flagship',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 12),
            const Divider(color: Color(0xFFE2E8F0)),

            // Metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.orderNumber}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  DateFormatter.formatDateTime(order.createdAt),
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            if (order.customerPhone != null) ...[
              const SizedBox(height: 2),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Customer: ${order.customerPhone}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ),
            ],
            const SizedBox(height: 8),
            const Divider(color: Color(0xFFE2E8F0)),

            // Cart Items Table
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 180),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: order.cart.items.length,
                itemBuilder: (context, index) {
                  final item = order.cart.items[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${item.quantity}x ${item.product.nameEn}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E293B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          CurrencyFormatter.format(item.lineTotal),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const Divider(color: Color(0xFFE2E8F0)),

            // Summary
            _receiptRow('Subtotal', CurrencyFormatter.format(order.cart.subtotal)),
            if (order.cart.discountAmount > 0)
              _receiptRow(
                'Discount',
                '- ${CurrencyFormatter.format(order.cart.discountAmount)}',
                isDiscount: true,
              ),
            _receiptRow('VAT (14%)', CurrencyFormatter.format(order.cart.taxAmount)),
            const Divider(color: Color(0xFFE2E8F0)),
            _receiptRow(
              'GRAND TOTAL',
              CurrencyFormatter.format(order.cart.grandTotal),
              isGrandTotal: true,
            ),
            _receiptRow('Total Paid', CurrencyFormatter.format(order.totalPaid)),
            if (order.changeGiven > 0)
              _receiptRow('Change Returned', CurrencyFormatter.format(order.changeGiven)),
            const SizedBox(height: 16),

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
                        const SnackBar(content: Text('Dispatched to thermal printer.')),
                      );
                    },
                    icon: const Icon(LucideIcons.printer, size: 14),
                    label: const Text('Print', style: TextStyle(fontSize: 12)),
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
                      context.read<PosBloc>().add(const DismissReceiptEvent());
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(LucideIcons.plus, size: 14),
                    label: const Text('New Sale', style: TextStyle(fontSize: 12)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _receiptRow(String label, String value, {bool isDiscount = false, bool isGrandTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isGrandTotal ? 13 : 11.5,
              fontWeight: isGrandTotal ? FontWeight.w900 : FontWeight.w500,
              color: isDiscount ? AppColors.warning : const Color(0xFF475569),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isGrandTotal ? 14 : 11.5,
              fontWeight: isGrandTotal ? FontWeight.w900 : FontWeight.w600,
              color: isDiscount ? AppColors.warning : const Color(0xFF0F172A),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
