import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';

class CatalogStatsHeader extends StatelessWidget {
  final VoidCallback onAddProduct;
  final VoidCallback onImportExport;

  const CatalogStatsHeader({
    super.key,
    required this.onAddProduct,
    required this.onImportExport,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state is! CatalogLoaded) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.all(AppDimensions.space16),
          decoration: BoxDecoration(
            color: theme.cardTheme.color,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Title & Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              LucideIcons.boxes,
                              size: 22,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: AppDimensions.space8),
                            Flexible(
                              child: Text(
                                'Catalog & Stock Matrix',
                                style: theme.textTheme.headlineLarge,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppDimensions.space4),
                        Text(
                          'Real-time inventory levels, prices, barcode mappings, and category controls.',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                        ),
                        onPressed: onImportExport,
                        icon: const Icon(LucideIcons.fileSpreadsheet, size: 16),
                        label: const Text('Import / Export'),
                      ),
                      ElevatedButton.icon(
                        onPressed: onAddProduct,
                        icon: const Icon(LucideIcons.plus, size: 16),
                        label: const Text('Add Product'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Filter Chips / Quick Counters
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatFilterChip(
                      label: 'All Items',
                      count: state.totalCount,
                      isSelected: state.stockFilter == StockFilter.all,
                      activeColor: AppColors.primary,
                      onTap: () => context
                          .read<CatalogBloc>()
                          .add(const FilterByStockStatus(StockFilter.all)),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    _StatFilterChip(
                      label: 'In Stock',
                      count: state.inStockCount,
                      isSelected: state.stockFilter == StockFilter.inStock,
                      activeColor: AppColors.success,
                      onTap: () => context
                          .read<CatalogBloc>()
                          .add(const FilterByStockStatus(StockFilter.inStock)),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    _StatFilterChip(
                      label: 'Low Stock (<5)',
                      count: state.lowStockCount,
                      isSelected: state.stockFilter == StockFilter.lowStock,
                      activeColor: AppColors.warning,
                      onTap: () => context
                          .read<CatalogBloc>()
                          .add(const FilterByStockStatus(StockFilter.lowStock)),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    _StatFilterChip(
                      label: 'Out of Stock',
                      count: state.outOfStockCount,
                      isSelected: state.stockFilter == StockFilter.outOfStock,
                      activeColor: AppColors.danger,
                      onTap: () => context
                          .read<CatalogBloc>()
                          .add(const FilterByStockStatus(StockFilter.outOfStock)),
                    ),
                    const SizedBox(width: AppDimensions.space8),
                    _StatFilterChip(
                      label: 'Services',
                      count: state.servicesCount,
                      isSelected: state.stockFilter == StockFilter.services,
                      activeColor: AppColors.accent,
                      onTap: () => context
                          .read<CatalogBloc>()
                          .add(const FilterByStockStatus(StockFilter.services)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onTap;

  const _StatFilterChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.borderDark,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? activeColor : AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
