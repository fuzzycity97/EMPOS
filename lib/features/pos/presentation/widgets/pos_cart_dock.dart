import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/hold_tab.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import 'checkout_dialog.dart';
import 'discount_dialog.dart';
import 'held_tabs_dialog.dart';

class PosCartDock extends StatelessWidget {
  final Cart cart;
  final List<HoldTab> heldTabs;

  const PosCartDock({
    super.key,
    required this.cart,
    required this.heldTabs,
  });

  void _openDiscountDialog(BuildContext context) {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items to cart before applying discount!')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<PosBloc>(),
        child: DiscountDialog(currentDiscount: cart.discount),
      ),
    );
  }

  void _openHeldTabsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<PosBloc>(),
        child: HeldTabsDialog(heldTabs: heldTabs),
      ),
    );
  }

  void _promptHoldTab(BuildContext context) {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Nothing to park.')),
      );
      return;
    }

    final titleController = TextEditingController(
      text: 'TAB-${DateTime.now().minute}:${DateTime.now().second}',
    );

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        title: Row(
          children: const [
            Icon(LucideIcons.pause, color: AppColors.info, size: 18),
            SizedBox(width: 8),
            Text('Park / Hold Tab'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Tab or Table Name to park this cart:',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'e.g. Table 4, Mr. Kareem'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.info),
            onPressed: () {
              final title = titleController.text.trim();
              context.read<PosBloc>().add(
                    HoldCurrentTabEvent(
                      tabTitle: title.isNotEmpty ? title : 'HOLD-ORDER',
                    ),
                  );
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Park Tab'),
          ),
        ],
      ),
    );
  }

  void _promptClearCart(BuildContext context) {
    if (cart.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          side: const BorderSide(color: AppColors.borderDark),
        ),
        title: Row(
          children: const [
            Icon(LucideIcons.trash2, color: AppColors.danger, size: 18),
            SizedBox(width: 8),
            Text('Void Active Order?'),
          ],
        ),
        content: const Text(
          'Are you sure you want to clear all items from the current active cart?',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              context.read<PosBloc>().add(const ClearCartEvent());
              Navigator.of(dialogCtx).pop();
            },
            child: const Text('Void Order'),
          ),
        ],
      ),
    );
  }

  void _openCheckoutDialog(BuildContext context) {
    if (cart.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart is empty. Add items to checkout.')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogCtx) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<PosBloc>()),
          tryGetCustomerBloc(context),
        ],
        child: CheckoutDialog(cart: cart),
      ),
    );
  }

  BlocProvider<CustomerBloc> tryGetCustomerBloc(BuildContext context) {
    try {
      return BlocProvider.value(value: context.read<CustomerBloc>());
    } catch (_) {
      return BlocProvider(create: (_) => sl<CustomerBloc>()..add(const LoadCustomersEvent()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          // 1. Header: Current Order & Item Count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.space16,
              vertical: AppDimensions.space12,
            ),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.shoppingCart,
                        size: 18,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      Flexible(
                        child: Text(
                          'Current Order',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
                  ),
                  child: Text(
                    '${cart.totalItemCount} items',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Quick Action Toolbar (Disc, Hold, Tabs, Void)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.borderDark)),
              color: AppColors.surfaceElevatedDark,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _CartQuickActionBtn(
                    label: 'Discount',
                    icon: LucideIcons.tag,
                    color: AppColors.warning,
                    badgeText: cart.discountAmount > 0 ? 'Active' : null,
                    onTap: () => _openDiscountDialog(context),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CartQuickActionBtn(
                    label: 'Hold Tab',
                    icon: LucideIcons.pause,
                    color: AppColors.info,
                    onTap: () => _promptHoldTab(context),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CartQuickActionBtn(
                    label: 'Parked',
                    icon: LucideIcons.layers,
                    color: AppColors.accent,
                    badgeText: heldTabs.isNotEmpty ? '${heldTabs.length}' : null,
                    onTap: () => _openHeldTabsDialog(context),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _CartQuickActionBtn(
                    label: 'Void',
                    icon: LucideIcons.trash2,
                    color: AppColors.danger,
                    onTap: () => _promptClearCart(context),
                  ),
                ),
              ],
            ),
          ),

          // 3. Cart Items List
          Expanded(
            child: cart.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          LucideIcons.shoppingBag,
                          size: 38,
                          color: AppColors.textMutedDark,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Active cart is empty',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(AppDimensions.space8),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, index) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevatedDark,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          border: Border(
                            left: BorderSide(color: theme.colorScheme.primary, width: 3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title & Price Calculation
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.nameEn,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${CurrencyFormatter.format(item.unitPrice)} × ${item.quantity} = ${CurrencyFormatter.format(item.lineTotal)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Stepper
                            Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    context.read<PosBloc>().add(
                                          UpdateQuantityEvent(
                                            productId: item.product.id,
                                            quantity: item.quantity - 1,
                                          ),
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.danger.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '−',
                                      style: TextStyle(
                                        color: AppColors.danger,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                  constraints: const BoxConstraints(minWidth: 26),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${item.quantity}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    context.read<PosBloc>().add(
                                          UpdateQuantityEvent(
                                            productId: item.product.id,
                                            quantity: item.quantity + 1,
                                          ),
                                        );
                                  },
                                  borderRadius: BorderRadius.circular(4),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppColors.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      '+',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // 4. Cart Summary & Big Checkout Button
          Container(
            padding: const EdgeInsets.all(AppDimensions.space12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.borderDark)),
              color: AppColors.surfaceElevatedDark,
            ),
            child: Column(
              children: [
                _summaryRow('Subtotal:', CurrencyFormatter.format(cart.subtotal)),
                if (cart.discountAmount > 0)
                  _summaryRow(
                    'Discount:',
                    '- ${CurrencyFormatter.format(cart.discountAmount)}',
                    color: AppColors.warning,
                  ),
                _summaryRow('VAT (14%):', CurrencyFormatter.format(cart.taxAmount)),
                const Divider(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL DUE:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          CurrencyFormatter.format(cart.grandTotal),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.success,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Charge Button
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                    ),
                    onPressed: () => _openCheckoutDialog(context),
                    icon: const Icon(LucideIcons.banknote, size: 18),
                    label: const Text(
                      'PAY / CHECKOUT',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: color ?? AppColors.textSecondaryDark,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: color ?? AppColors.textPrimaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _CartQuickActionBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String? badgeText;
  final VoidCallback onTap;

  const _CartQuickActionBtn({
    required this.label,
    required this.icon,
    required this.color,
    this.badgeText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 13, color: color),
                if (badgeText != null) ...[
                  const SizedBox(width: 3),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText!,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
