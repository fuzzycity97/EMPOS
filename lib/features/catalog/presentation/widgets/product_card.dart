import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<int>? onQuickStockAdjust;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
    this.onQuickStockAdjust,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(
          color: product.isOutOfStock
              ? AppColors.danger.withValues(alpha: 0.4)
              : (product.isLowStock
                  ? AppColors.warning.withValues(alpha: 0.4)
                  : theme.dividerColor),
          width: product.isOutOfStock || product.isLowStock ? 1.5 : 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.space12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Header Row: Category Badge & Stock Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _CategoryBadge(categoryId: product.categoryId),
                _StockStatusBadge(product: product),
              ],
            ),
            const SizedBox(height: AppDimensions.space8),

            // Product Name & Arabic Name
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.nameEn,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: product.isOutOfStock
                        ? AppColors.textMutedDark
                        : AppColors.textPrimaryDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.nameAr != null && product.nameAr!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    product.nameAr!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: AppColors.textSecondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppDimensions.space8),

            // Barcode Chip
            if (product.barcode.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      LucideIcons.barcode,
                      size: 13,
                      color: AppColors.textMutedDark,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.barcode,
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppDimensions.space12),

            // Divider
            const Divider(height: 1),
            const SizedBox(height: AppDimensions.space8),

            // Footer: Price & Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      CurrencyFormatter.format(product.price),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: product.isOutOfStock
                            ? AppColors.textMutedDark
                            : AppColors.primaryLight,
                      ),
                    ),
                    if (product.cost != null && product.cost! > 0)
                      Text(
                        'Cost: ${CurrencyFormatter.format(product.cost!)}',
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(
                        LucideIcons.pencil,
                        size: 15,
                        color: AppColors.primaryLight,
                      ),
                      tooltip: 'Edit Product',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onEdit,
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    IconButton(
                      icon: const Icon(
                        LucideIcons.trash2,
                        size: 15,
                        color: AppColors.danger,
                      ),
                      tooltip: 'Delete Product',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final String categoryId;

  const _CategoryBadge({required this.categoryId});

  String _cleanCat(String id) {
    return id.replaceAll('cat-', '').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        _cleanCat(categoryId),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _StockStatusBadge extends StatelessWidget {
  final Product product;

  const _StockStatusBadge({required this.product});

  @override
  Widget build(BuildContext context) {
    if (!product.trackQty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: const Text(
          'SERVICE',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: AppColors.accent,
          ),
        ),
      );
    }

    if (product.isOutOfStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: const Text(
          'OUT OF STOCK',
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: AppColors.danger,
          ),
        ),
      );
    }

    if (product.isLowStock) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Text(
          'LOW: ${product.stock}',
          style: const TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.bold,
            color: AppColors.warning,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Text(
        'STOCK: ${product.stock}',
        style: const TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: AppColors.success,
        ),
      ),
    );
  }
}
