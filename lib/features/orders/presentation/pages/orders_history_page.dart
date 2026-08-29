import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../pos/domain/entities/order.dart';
import '../../../pos/presentation/widgets/checkout_receipt_dialog.dart';
import '../bloc/orders_bloc.dart';
import '../bloc/orders_event.dart';
import '../bloc/orders_state.dart';
import '../widgets/order_details_dialog.dart';
import '../widgets/refund_order_dialog.dart';
import '../widgets/refund_receipt_widget.dart';

class OrdersHistoryPage extends StatelessWidget {
  final OrdersBloc? bloc;

  const OrdersHistoryPage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<OrdersBloc>.value(
        value: bloc!,
        child: const _OrdersHistoryView(),
      );
    }

    try {
      context.read<OrdersBloc>();
      return const _OrdersHistoryView();
    } catch (_) {
      return BlocProvider(
        create: (_) => sl<OrdersBloc>()..add(const LoadOrdersEvent()),
        child: const _OrdersHistoryView(),
      );
    }
  }
}

class _OrdersHistoryView extends StatelessWidget {
  const _OrdersHistoryView();

  void _showRefundReceipt(BuildContext context, OrdersLoaded state) {
    if (state.lastRefundTransaction == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<OrdersBloc>(),
        child: RefundReceiptWidget(refund: state.lastRefundTransaction!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<OrdersBloc, OrdersState>(
        listener: (context, state) {
          if (state is OrdersLoaded) {
            if (state.toastMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.toastMessage!),
                  backgroundColor: AppColors.surfaceElevatedDark,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                ),
              );
            }

            if (state.lastRefundTransaction != null) {
              _showRefundReceipt(context, state);
            }
          }
        },
        builder: (context, state) {
          if (state is OrdersLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is OrdersError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.circleAlert,
                      color: AppColors.danger, size: 48),
                  const SizedBox(height: 16),
                  Text('Failed to load orders history',
                      style: theme.textTheme.headlineLarge),
                  const SizedBox(height: 8),
                  Text(state.message,
                      style: const TextStyle(color: AppColors.textSecondaryDark)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<OrdersBloc>().add(const LoadOrdersEvent()),
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is OrdersLoaded) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header & Search Bar
                  _buildHeaderAndFilters(context, state),
                  const SizedBox(height: AppDimensions.space16),

                  // Orders Table / List
                  Expanded(
                    child: state.displayedOrders.isEmpty
                        ? _buildEmptyState(state)
                        : _buildOrdersList(context, state),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHeaderAndFilters(BuildContext context, OrdersLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.history,
                  size: 20, color: AppColors.primaryLight),
              const SizedBox(width: 8),
              const Text(
                'Sales History & Returns Ledger',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${state.displayedOrders.length} Transactions',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.space12),
          Row(
            children: [
              // Search Field
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevatedDark,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: TextField(
                    decoration: const InputDecoration(
                      prefixIcon: Icon(LucideIcons.search, size: 16),
                      hintText:
                          'Search Order #, phone number, customer name, or item...',
                      hintStyle: TextStyle(fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (val) {
                      context.read<OrdersBloc>().add(SearchOrdersEvent(val));
                    },
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.space12),

              // Filter Chips
              _filterChip(
                context,
                label: 'All Orders',
                isSelected: state.selectedStatus == null,
                onTap: () => context
                    .read<OrdersBloc>()
                    .add(const FilterOrdersByStatusEvent(null)),
              ),
              const SizedBox(width: 6),
              _filterChip(
                context,
                label: 'Paid',
                isSelected: state.selectedStatus == OrderStatus.paid,
                onTap: () => context
                    .read<OrdersBloc>()
                    .add(const FilterOrdersByStatusEvent(OrderStatus.paid)),
              ),
              const SizedBox(width: 6),
              _filterChip(
                context,
                label: 'Partial Returns',
                isSelected:
                    state.selectedStatus == OrderStatus.partiallyRefunded,
                onTap: () => context.read<OrdersBloc>().add(
                      const FilterOrdersByStatusEvent(
                        OrderStatus.partiallyRefunded,
                      ),
                    ),
              ),
              const SizedBox(width: 6),
              _filterChip(
                context,
                label: 'Refunded',
                isSelected: state.selectedStatus == OrderStatus.refunded,
                onTap: () => context
                    .read<OrdersBloc>()
                    .add(const FilterOrdersByStatusEvent(OrderStatus.refunded)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterChip(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.borderDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textSecondaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(OrdersLoaded state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.receiptText,
              size: 48, color: AppColors.textMutedDark),
          const SizedBox(height: 12),
          Text(
            state.searchQuery.isNotEmpty
                ? 'No transactions match "${state.searchQuery}"'
                : 'No sales recorded yet.',
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(BuildContext context, OrdersLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: ListView.separated(
          itemCount: state.displayedOrders.length,
          separatorBuilder: (ctx, i) => Divider(
            height: 1,
            color: AppColors.borderDark.withValues(alpha: 0.5),
          ),
          itemBuilder: (context, index) {
            final order = state.displayedOrders[index];
            final isRefunded = order.status == OrderStatus.refunded;
            final isPartiallyRefunded =
                order.status == OrderStatus.partiallyRefunded;

            final itemsSummary = order.cart.items
                .map((i) => '${i.product.nameEn} (x${i.quantity})')
                .join(', ');

            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (ctx) => BlocProvider.value(
                    value: context.read<OrdersBloc>(),
                    child: OrderDetailsDialog(order: order),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space12),
                child: Row(
                  children: [
                    // Order Number & Time
                    SizedBox(
                      width: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '#${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primaryLight,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormatter.formatDateTime(order.createdAt),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMutedDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Cashier & Customer Info
                    SizedBox(
                      width: 140,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.customerName ??
                                (order.customerPhone ?? 'Walk-in Guest'),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'By: ${order.cashierId ?? "Active Cashier"}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textMutedDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Items Summary
                    Expanded(
                      child: Text(
                        itemsSummary,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondaryDark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Total Amount
                    SizedBox(
                      width: 110,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          CurrencyFormatter.format(order.cart.grandTotal),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: isRefunded
                                ? AppColors.danger
                                : AppColors.success,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Status Badge
                    SizedBox(
                      width: 110,
                      child: _statusBadge(order.status),
                    ),
                    const SizedBox(width: 12),

                    // Quick Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(LucideIcons.printer, size: 16),
                          tooltip: 'Print Duplicate Receipt',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) =>
                                  CheckoutReceiptDialog(order: order),
                            );
                          },
                        ),
                        if (!isRefunded)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(LucideIcons.rotateCcw,
                                size: 16, color: AppColors.danger),
                            tooltip: isPartiallyRefunded
                                ? 'Return Remaining'
                                : 'Refund Order',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => BlocProvider.value(
                                  value: context.read<OrdersBloc>(),
                                  child: RefundOrderDialog(order: order),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
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
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w900,
          color: fg,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
