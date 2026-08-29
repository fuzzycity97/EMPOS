import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/presentation/bloc/config_bloc.dart';
import '../../../../core/config/presentation/bloc/config_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../shift/domain/entities/cash_transaction.dart';
import '../../../shift/presentation/bloc/shift_bloc.dart';
import '../../../shift/presentation/bloc/shift_state.dart';
import '../../../shift/presentation/widgets/cash_transaction_dialog.dart';
import '../../../shift/presentation/widgets/close_shift_dialog.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import 'industry_pos_actions.dart';

class PosSearchHeader extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCategoryId;
  final TextEditingController searchController;

  const PosSearchHeader._({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.searchController,
  });

  factory PosSearchHeader({
    Key? key,
    required List<Category> categories,
    required String? selectedCategoryId,
  }) {
    return PosSearchHeader._(
      key: key,
      categories: categories,
      selectedCategoryId: selectedCategoryId,
      searchController: TextEditingController(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Search / Barcode row
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Icon(
                        LucideIcons.barcode,
                        size: 20,
                        color: primaryColor,
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: searchController,
                        decoration: const InputDecoration(
                          hintText: 'Scan Barcode (F2) or type to search products...',
                          hintStyle: TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMutedDark,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        style: const TextStyle(fontSize: 13),
                        onChanged: (val) {
                          context
                              .read<PosBloc>()
                              .add(SearchPosProductsEvent(val));
                        },
                        onSubmitted: (val) {
                          if (val.trim().isNotEmpty) {
                            context.read<PosBloc>().add(ScanBarcodeEvent(val.trim()));
                            searchController.clear();
                            context
                                .read<PosBloc>()
                                .add(const SearchPosProductsEvent(''));
                          }
                        },
                      ),
                    ),
                    // Live Scale indicator if Grocery/Scale enabled
                    _ConfigReactiveActionWrapper(
                      builder: (bp) {
                        if (bp.isSupermarket ||
                            bp.isEnabled('sw.grocery_weight_pricing') ||
                            bp.isEnabled('hw.grocery_scale')) {
                          return const ScaleWeightIndicator();
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: AppDimensions.space8),

            // Dynamic Industry Actions (Pharmacy Rx / Restaurant Tables)
            _ConfigReactiveActionWrapper(
              builder: (bp) {
                if (bp.isPharmacy || bp.isEnabled('sw.prescription_scanning')) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: PharmacyPrescriptionButton(),
                  );
                }
                if (bp.isRestaurant || bp.isEnabled('sw.table_management')) {
                  return const Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: RestaurantTablesButton(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Cash Drawer Button & Menu
            BlocBuilder<ShiftBloc, ShiftState>(
              builder: (context, shiftState) {
                if (shiftState is! ActiveShiftReady) {
                  return const SizedBox.shrink();
                }

                return PopupMenuButton<String>(
                  color: AppColors.surfaceElevatedDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    side: const BorderSide(color: AppColors.borderDark),
                  ),
                  onSelected: (val) {
                    if (val == 'payIn') {
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<ShiftBloc>(),
                          child: CashTransactionDialog(
                            shiftId: shiftState.shift.id,
                            initialType: CashTransactionType.payIn,
                          ),
                        ),
                      );
                    } else if (val == 'payOut') {
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<ShiftBloc>(),
                          child: CashTransactionDialog(
                            shiftId: shiftState.shift.id,
                            initialType: CashTransactionType.payOut,
                          ),
                        ),
                      );
                    } else if (val == 'closeShift') {
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocProvider.value(
                          value: context.read<ShiftBloc>(),
                          child: CloseShiftDialog(shift: shiftState.shift),
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(
                      value: 'payIn',
                      child: Row(
                        children: [
                          Icon(LucideIcons.arrowDownLeft, size: 16, color: AppColors.success),
                          SizedBox(width: 8),
                          Text('Add Pay-In (Float In)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'payOut',
                      child: Row(
                        children: [
                          Icon(LucideIcons.arrowUpRight, size: 16, color: AppColors.danger),
                          SizedBox(width: 8),
                          Text('Add Pay-Out (Float Out)', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'closeShift',
                      child: Row(
                        children: [
                          Icon(LucideIcons.lock, size: 16, color: AppColors.warning),
                          SizedBox(width: 8),
                          Text('Z-Report & End Shift', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevatedDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.wallet, size: 15, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Text(
                          CurrencyFormatter.format(shiftState.shift.expectedCash),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(LucideIcons.chevronDown, size: 12, color: AppColors.textMutedDark),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: AppDimensions.space8),

            // Sync status badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(LucideIcons.circleCheck, size: 14, color: AppColors.success),
                  SizedBox(width: 6),
                  Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.space12),

        // Category Filter Chips
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _PosCatChip(
                label: 'All Items',
                isSelected: selectedCategoryId == null,
                onTap: () => context
                    .read<PosBloc>()
                    .add(const SelectPosCategoryEvent(null)),
              ),
              const SizedBox(width: 6),
              ...categories.map((cat) {
                final isSelected = selectedCategoryId == cat.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: _PosCatChip(
                    label: cat.name,
                    isSelected: isSelected,
                    onTap: () => context
                        .read<PosBloc>()
                        .add(SelectPosCategoryEvent(cat.id)),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

class _PosCatChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _PosCatChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isSelected ? primaryColor : AppColors.borderDark,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.textSecondaryDark,
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfigReactiveActionWrapper extends StatelessWidget {
  final Widget Function(dynamic blueprint) builder;

  const _ConfigReactiveActionWrapper({required this.builder});

  @override
  Widget build(BuildContext context) {
    ConfigBloc? bloc;
    try {
      bloc = context.read<ConfigBloc>();
    } catch (_) {}

    if (bloc == null) return const SizedBox.shrink();

    return BlocBuilder<ConfigBloc, ConfigState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is ConfigLoaded) {
          return builder(state.blueprint);
        }
        return const SizedBox.shrink();
      },
    );
  }
}
