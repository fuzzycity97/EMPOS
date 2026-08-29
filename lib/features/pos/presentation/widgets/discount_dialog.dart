import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/cart_discount.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';

class DiscountDialog extends StatelessWidget {
  final CartDiscount currentDiscount;
  final TextEditingController pctController;
  final TextEditingController fixedController;

  const DiscountDialog._({
    super.key,
    required this.currentDiscount,
    required this.pctController,
    required this.fixedController,
  });

  factory DiscountDialog({
    Key? key,
    required CartDiscount currentDiscount,
  }) {
    return DiscountDialog._(
      key: key,
      currentDiscount: currentDiscount,
      pctController: TextEditingController(
        text: currentDiscount.type == DiscountType.percentage
            ? currentDiscount.value.toStringAsFixed(0)
            : '',
      ),
      fixedController: TextEditingController(
        text: currentDiscount.type == DiscountType.fixedAmount
            ? currentDiscount.value.toStringAsFixed(2)
            : '',
      ),
    );
  }

  void _applyPresetPct(BuildContext context, double pct) {
    context.read<PosBloc>().add(ApplyDiscountEvent(CartDiscount.percentage(pct)));
    Navigator.of(context).pop();
  }

  void _applyCustom(BuildContext context) {
    final pct = double.tryParse(pctController.text.trim());
    final fixed = double.tryParse(fixedController.text.trim());

    if (pct != null && pct > 0) {
      context.read<PosBloc>().add(ApplyDiscountEvent(CartDiscount.percentage(pct)));
    } else if (fixed != null && fixed > 0) {
      context.read<PosBloc>().add(ApplyDiscountEvent(CartDiscount.fixed(fixed)));
    } else {
      context.read<PosBloc>().add(const ApplyDiscountEvent(CartDiscount.none()));
    }
    Navigator.of(context).pop();
  }

  void _removeDiscount(BuildContext context) {
    context.read<PosBloc>().add(const ApplyDiscountEvent(CartDiscount.none()));
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
        padding: const EdgeInsets.all(AppDimensions.space20),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.tag, color: AppColors.warning, size: 18),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      'Apply Order Discount',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
            const SizedBox(height: AppDimensions.space12),

            // Quick Percentage Presets
            const Text(
              'Quick Percentage Presets',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: AppDimensions.space8),
            Row(
              children: [5.0, 10.0, 15.0, 20.0].map((pct) {
                final isSelected = currentDiscount.type == DiscountType.percentage &&
                    currentDiscount.value == pct;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? AppColors.warning
                            : AppColors.surfaceElevatedDark,
                        foregroundColor:
                            isSelected ? Colors.black : AppColors.textPrimaryDark,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      onPressed: () => _applyPresetPct(context, pct),
                      child: Text(
                        '${pct.toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Custom Percentage or Fixed Amount
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Custom %',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: pctController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 25'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Fixed Amount (EGP)',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: fixedController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(hintText: 'e.g. 50.00'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.space20),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _removeDiscount(context),
                  icon: const Icon(LucideIcons.trash2, size: 14, color: AppColors.danger),
                  label: const Text(
                    'Remove Discount',
                    style: TextStyle(color: AppColors.danger, fontSize: 12),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _applyCustom(context),
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
