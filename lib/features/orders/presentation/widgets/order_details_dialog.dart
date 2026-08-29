import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../pos/domain/entities/order.dart';
import '../../../pos/presentation/widgets/checkout_receipt_dialog.dart';
import '../bloc/orders_bloc.dart';
import 'refund_order_dialog.dart';

class OrderDetailsDialog extends StatelessWidget {
  final PosOrder order;

  const OrderDetailsDialog({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRefunded = order.status == OrderStatus.refunded;
    final isPartiallyRefunded = order.status == OrderStatus.partiallyRefunded;

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space24),
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: const Icon(
                          LucideIcons.receipt,
                          size: 20,
                          color: AppColors.primaryLight,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order.orderNumber}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            DateFormatter.formatDateTime(order.createdAt),
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _statusBadge(order.status),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Metadata Row (Cashier, Customer)
              Container(
                padding: const EdgeInsets.all(AppDimensions.space12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OPERATOR / CASHIER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMutedDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.cashierId ?? 'Active Cashier',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CUSTOMER',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMutedDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            order.customerName ??
                                (order.customerPhone != null
                                    ? order.customerPhone!
                                    : 'Walk-in Guest'),
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Items Table
              const Text(
                'ORDER ITEMS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMutedDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  children: order.cart.items.map((item) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.space12,
                        vertical: AppDimensions.space8,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.borderDark.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.nameEn,
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${item.quantity} x ${CurrencyFormatter.format(item.unitPrice)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMutedDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (item.itemDiscount > 0)
                            Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                '-${CurrencyFormatter.format(item.itemDiscount)}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          Text(
                            CurrencyFormatter.format(item.lineTotal),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Math Breakdown
              _mathRow('Subtotal', CurrencyFormatter.format(order.cart.subtotal)),
              if (order.cart.discountAmount > 0)
                _mathRow(
                  'Discounts Applied',
                  '- ${CurrencyFormatter.format(order.cart.discountAmount)}',
                  color: AppColors.warning,
                ),
              _mathRow('VAT (${(order.cart.taxRate * 100).toInt()}%)',
                  CurrencyFormatter.format(order.cart.taxAmount)),
              const Divider(),
              _mathRow(
                'GRAND TOTAL',
                CurrencyFormatter.format(order.cart.grandTotal),
                isBold: true,
              ),
              const SizedBox(height: 8),

              // Payment Tenders List
              Wrap(
                spacing: 8,
                children: order.payments.map((p) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevatedDark,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Text(
                      '${p.tenderType.name.toUpperCase()}: ${CurrencyFormatter.format(p.amount)}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppDimensions.space24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => CheckoutReceiptDialog(order: order),
                        );
                      },
                      icon: const Icon(LucideIcons.printer, size: 16),
                      label: const Text('Reprint Receipt', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  if (!isRefunded) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (ctx) => BlocProvider.value(
                              value: context.read<OrdersBloc>(),
                              child: RefundOrderDialog(order: order),
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.rotateCcw, size: 16),
                        label: Text(
                          isPartiallyRefunded ? 'Return More Items' : 'Process Refund',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(OrderStatus status) {
    Color bg = AppColors.success.withValues(alpha: 0.15);
    Color fg = AppColors.success;
    String label = 'PAID';

    if (status == OrderStatus.refunded) {
      bg = AppColors.danger.withValues(alpha: 0.15);
      fg = AppColors.danger;
      label = 'REFUNDED';
    } else if (status == OrderStatus.partiallyRefunded) {
      bg = AppColors.warning.withValues(alpha: 0.15);
      fg = AppColors.warning;
      label = 'PARTIAL RETURN';
    } else if (status == OrderStatus.pending) {
      bg = Colors.grey.withValues(alpha: 0.15);
      fg = Colors.grey;
      label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _mathRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 13 : 11.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 12,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w600,
              color: color ?? (isBold ? AppColors.success : AppColors.textPrimaryDark),
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
