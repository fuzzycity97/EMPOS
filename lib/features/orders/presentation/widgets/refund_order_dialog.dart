import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../pos/domain/entities/cart_item.dart';
import '../../../pos/domain/entities/order.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';

class RefundOrderDialog extends StatelessWidget {
  final PosOrder order;
  final ValueNotifier<Map<String, int>> quantitiesNotifier;
  final ValueNotifier<TenderType> selectedTenderNotifier;
  final TextEditingController reasonController;

  const RefundOrderDialog._({
    super.key,
    required this.order,
    required this.quantitiesNotifier,
    required this.selectedTenderNotifier,
    required this.reasonController,
  });

  factory RefundOrderDialog({Key? key, required PosOrder order}) {
    // Default: initialize all items with 0 quantities to refund
    final initialMap = <String, int>{};
    for (final item in order.cart.items) {
      initialMap[item.product.id] = 0;
    }

    // Default refund tender: first tender used in original payment
    final defaultTender = order.payments.isNotEmpty
        ? order.payments.first.tenderType
        : TenderType.cash;

    return RefundOrderDialog._(
      key: key,
      order: order,
      quantitiesNotifier: ValueNotifier<Map<String, int>>(initialMap),
      selectedTenderNotifier: ValueNotifier<TenderType>(defaultTender),
      reasonController: TextEditingController(text: 'Customer Return'),
    );
  }

  void _selectAll() {
    final newMap = <String, int>{};
    for (final item in order.cart.items) {
      newMap[item.product.id] = item.quantity;
    }
    quantitiesNotifier.value = newMap;
  }

  void _clearAll() {
    final newMap = <String, int>{};
    for (final item in order.cart.items) {
      newMap[item.product.id] = 0;
    }
    quantitiesNotifier.value = newMap;
  }

  void _updateQuantity(String productId, int delta, int maxQty) {
    final currentMap = Map<String, int>.from(quantitiesNotifier.value);
    final current = currentMap[productId] ?? 0;
    final updated = (current + delta).clamp(0, maxQty);
    currentMap[productId] = updated;
    quantitiesNotifier.value = currentMap;
  }

  double _calculateRefundTotal(Map<String, int> qtyMap) {
    final int totalOriginalCount =
        order.cart.items.fold(0, (sum, i) => sum + i.quantity);
    final int totalRefundCount =
        qtyMap.values.fold(0, (sum, qty) => sum + qty);

    if (totalRefundCount == 0) return 0.0;
    if (totalRefundCount >= totalOriginalCount) {
      return order.cart.grandTotal;
    }

    double subtotal = 0.0;
    for (final item in order.cart.items) {
      final qtyToRefund = qtyMap[item.product.id] ?? 0;
      if (qtyToRefund > 0) {
        final lineRatio = qtyToRefund / item.quantity;
        final itemDiscountPart = item.itemDiscount * lineRatio;
        subtotal += (item.unitPrice * qtyToRefund) - itemDiscountPart;
      }
    }

    return (subtotal * (1.0 + order.cart.taxRate)).clamp(0.0, order.cart.grandTotal);
  }

  void _submitRefund(BuildContext context) {
    final qtyMap = quantitiesNotifier.value;
    final refundedItems = <CartItem>[];

    for (final item in order.cart.items) {
      final qtyToRefund = qtyMap[item.product.id] ?? 0;
      if (qtyToRefund > 0) {
        refundedItems.add(
          CartItem(
            product: item.product,
            quantity: qtyToRefund,
            unitPrice: item.unitPrice,
            itemDiscount: (item.itemDiscount / item.quantity) * qtyToRefund,
          ),
        );
      }
    }

    if (refundedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least 1 item quantity to refund.')),
      );
      return;
    }

    final reason = reasonController.text.trim().isEmpty
        ? 'Customer Return'
        : reasonController.text.trim();

    context.read<OrdersBloc>().add(
          SubmitRefundEvent(
            orderId: order.id,
            refundedItems: refundedItems,
            refundTender: selectedTenderNotifier.value,
            reason: reason,
          ),
        );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                          color: AppColors.danger.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: const Icon(
                          LucideIcons.rotateCcw,
                          size: 20,
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Process Return & Refund',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Order #${order.orderNumber} • ${CurrencyFormatter.format(order.cart.grandTotal)}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 8),

              // Full Refund / Clear Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'SELECT ITEMS TO RETURN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textMutedDark,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: _selectAll,
                        icon: const Icon(LucideIcons.checkCheck, size: 14),
                        label: const Text('Refund All Items', style: TextStyle(fontSize: 11)),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          visualDensity: VisualDensity.compact,
                          foregroundColor: AppColors.textMutedDark,
                        ),
                        onPressed: _clearAll,
                        child: const Text('Clear', style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Item List with Steppers
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: ValueListenableBuilder<Map<String, int>>(
                  valueListenable: quantitiesNotifier,
                  builder: (context, qtyMap, _) {
                    return Column(
                      children: order.cart.items.map((item) {
                        final currentRefundQty = qtyMap[item.product.id] ?? 0;
                        final isReturning = currentRefundQty > 0;

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
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isReturning
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textSecondaryDark,
                                      ),
                                    ),
                                    Text(
                                      '${CurrencyFormatter.format(item.unitPrice)} each • Original Qty: ${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textMutedDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Quantity Stepper
                              Row(
                                children: [
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(LucideIcons.minusCircle, size: 18),
                                    onPressed: currentRefundQty > 0
                                        ? () => _updateQuantity(
                                              item.product.id,
                                              -1,
                                              item.quantity,
                                            )
                                        : null,
                                  ),
                                  Container(
                                    width: 32,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$currentRefundQty',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w900,
                                        color: isReturning
                                            ? AppColors.danger
                                            : AppColors.textMutedDark,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    icon: const Icon(LucideIcons.plusCircle, size: 18),
                                    onPressed: currentRefundQty < item.quantity
                                        ? () => _updateQuantity(
                                              item.product.id,
                                              1,
                                              item.quantity,
                                            )
                                        : null,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Tender Selection
              const Text(
                'REFUND METHOD / TENDER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMutedDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              ValueListenableBuilder<TenderType>(
                valueListenable: selectedTenderNotifier,
                builder: (context, currentTender, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: TenderType.values.map((tender) {
                      final isSelected = tender == currentTender;
                      return ChoiceChip(
                        label: Text(
                          tender.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        onSelected: (val) {
                          if (val) selectedTenderNotifier.value = tender;
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space16),

              // Reason
              const Text(
                'RETURN REASON',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textMutedDark,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  'Customer Return',
                  'Defective Product',
                  'Wrong Item Ordered',
                  'Duplicate Charge',
                ].map((preset) {
                  return ActionChip(
                    label: Text(preset, style: const TextStyle(fontSize: 11)),
                    onPressed: () => reasonController.text = preset,
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  hintText: 'Enter return reason or audit notes...',
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Total Calculation Badge & Submit Action
              ValueListenableBuilder<Map<String, int>>(
                valueListenable: quantitiesNotifier,
                builder: (context, qtyMap, _) {
                  final totalRefund = _calculateRefundTotal(qtyMap);
                  final hasItemsToRefund = totalRefund > 0;

                  return Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.space16,
                          vertical: AppDimensions.space12,
                        ),
                        decoration: BoxDecoration(
                          color: hasItemsToRefund
                              ? AppColors.danger.withValues(alpha: 0.12)
                              : AppColors.surfaceElevatedDark,
                          borderRadius:
                              BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(
                            color: hasItemsToRefund
                                ? AppColors.danger.withValues(alpha: 0.3)
                                : AppColors.borderDark,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'TOTAL REFUND PAYOUT:',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryDark,
                              ),
                            ),
                            Text(
                              '- ${CurrencyFormatter.format(totalRefund)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: hasItemsToRefund
                                    ? AppColors.danger
                                    : AppColors.textMutedDark,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.danger,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMedium,
                              ),
                            ),
                          ),
                          onPressed: hasItemsToRefund
                              ? () => _submitRefund(context)
                              : null,
                          icon: const Icon(LucideIcons.rotateCcw, size: 18),
                          label: const Text(
                            'CONFIRM & PROCESS REFUND',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
