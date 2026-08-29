import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../catalog/domain/entities/product.dart';

class PosProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const PosProductTile({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isOutOfStock = product.isOutOfStock;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isOutOfStock ? null : onAddToCart,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: isOutOfStock
                ? AppColors.surfaceDark.withValues(alpha: 0.4)
                : AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: isOutOfStock
                  ? AppColors.danger.withValues(alpha: 0.3)
                  : (product.isLowStock
                      ? AppColors.warning.withValues(alpha: 0.5)
                      : AppColors.borderDark),
              width: 1.2,
            ),
            boxShadow: isOutOfStock
                ? []
                : const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
          ),
          padding: const EdgeInsets.all(AppDimensions.space12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Category / Service tag & Stock indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Text(
                      product.categoryId.replaceAll('cat-', '').toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  _buildStockBadge(product),
                ],
              ),
              const SizedBox(height: AppDimensions.space8),

              // Middle: Title EN & Arabic
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.nameEn,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock
                          ? AppColors.textMutedDark
                          : AppColors.textPrimaryDark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.nameAr != null && product.nameAr!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      product.nameAr!,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: isOutOfStock
                            ? AppColors.textMutedDark
                            : AppColors.textSecondaryDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppDimensions.space8),

              // Bottom: Price & Quick Add Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        CurrencyFormatter.format(product.price),
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: isOutOfStock
                              ? AppColors.textMutedDark
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isOutOfStock
                          ? AppColors.surfaceElevatedDark
                          : theme.colorScheme.primary,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: Icon(
                      isOutOfStock ? LucideIcons.ban : LucideIcons.plus,
                      size: 14,
                      color: Colors.white,
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

  Widget _buildStockBadge(Product product) {
    if (!product.trackQty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: const Text(
          'SERVICE',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      );
    }

    if (product.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: const Text(
          'OUT',
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.danger,
          ),
        ),
      );
    }

    if (product.isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Text(
          '${product.stock} left',
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        '${product.stock}',
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
        ),
      ),
    );
  }
}
