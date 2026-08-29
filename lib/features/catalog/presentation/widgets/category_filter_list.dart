import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';

class CategoryFilterList extends StatelessWidget {
  const CategoryFilterList({super.key});

  IconData _resolveCategoryIcon(String? iconName) {
    switch (iconName?.toLowerCase()) {
      case 'cup-soda':
      case 'beverages':
        return LucideIcons.cupSoda;
      case 'utensils':
      case 'food':
        return LucideIcons.utensils;
      case 'shopping-bag':
      case 'retail':
        return LucideIcons.shoppingBag;
      case 'sparkles':
      case 'services':
        return LucideIcons.sparkles;
      case 'layers':
      default:
        return LucideIcons.layers;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatalogBloc, CatalogState>(
      builder: (context, state) {
        if (state is! CatalogLoaded) return const SizedBox.shrink();

        final isAllSelected = state.selectedCategoryId == null;

        return SizedBox(
          height: 42,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              // 1. "All Categories" Tab
              _CategoryTabChip(
                label: 'All Categories',
                icon: LucideIcons.layoutGrid,
                isSelected: isAllSelected,
                count: state.allProducts.length,
                onTap: () {
                  context.read<CatalogBloc>().add(const SelectCategory(null));
                },
              ),
              const SizedBox(width: AppDimensions.space8),

              // 2. Dynamic Categories
              ...state.categories.map((cat) {
                final isSelected = state.selectedCategoryId == cat.id;
                final catCount = state.allProducts
                    .where((p) => p.categoryId == cat.id)
                    .length;

                return Padding(
                  padding: const EdgeInsets.only(right: AppDimensions.space8),
                  child: _CategoryTabChip(
                    label: cat.name,
                    arabicLabel: cat.nameAr,
                    icon: _resolveCategoryIcon(cat.icon ?? cat.name),
                    isSelected: isSelected,
                    isEnabled: cat.isEnabled,
                    count: catCount,
                    onTap: () {
                      context.read<CatalogBloc>().add(SelectCategory(cat.id));
                    },
                    onToggleStatus: (enabled) {
                      context.read<CatalogBloc>().add(
                            ToggleCategoryStatus(
                              categoryId: cat.id,
                              isEnabled: enabled,
                            ),
                          );
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}

class _CategoryTabChip extends StatelessWidget {
  final String label;
  final String? arabicLabel;
  final IconData icon;
  final bool isSelected;
  final bool isEnabled;
  final int count;
  final VoidCallback onTap;
  final ValueChanged<bool>? onToggleStatus;

  const _CategoryTabChip({
    required this.label,
    this.arabicLabel,
    required this.icon,
    required this.isSelected,
    this.isEnabled = true,
    required this.count,
    required this.onTap,
    this.onToggleStatus,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.space12,
          vertical: AppDimensions.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isEnabled ? AppColors.surfaceElevatedDark : AppColors.surfaceDark.withValues(alpha: 0.5)),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight
                : (isEnabled ? AppColors.borderDark : AppColors.danger.withValues(alpha: 0.3)),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isEnabled ? AppColors.primaryLight : AppColors.textMutedDark),
            ),
            const SizedBox(width: AppDimensions.space8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isEnabled ? AppColors.textPrimaryDark : AppColors.textMutedDark),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                ),
              ),
            ),
            if (onToggleStatus != null) ...[
              const SizedBox(width: AppDimensions.space8),
              GestureDetector(
                onTap: () => onToggleStatus!(!isEnabled),
                child: Tooltip(
                  message: isEnabled ? 'Disable category' : 'Enable category',
                  child: Icon(
                    isEnabled ? LucideIcons.toggleRight : LucideIcons.toggleLeft,
                    size: 16,
                    color: isEnabled ? AppColors.success : AppColors.textMutedDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
