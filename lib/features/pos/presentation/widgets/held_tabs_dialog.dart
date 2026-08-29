import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/hold_tab.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';

class HeldTabsDialog extends StatelessWidget {
  final List<HoldTab> heldTabs;

  const HeldTabsDialog({super.key, required this.heldTabs});

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
        constraints: const BoxConstraints(maxWidth: 560),
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
                    const Icon(LucideIcons.pause, color: AppColors.info, size: 20),
                    const SizedBox(width: AppDimensions.space8),
                    Text(
                      'Suspended / Parked Tabs (${heldTabs.length})',
                      style: theme.textTheme.titleLarge?.copyWith(
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

            // Tab list
            if (heldTabs.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Column(
                    children: const [
                      Icon(LucideIcons.clock, size: 36, color: AppColors.textMutedDark),
                      SizedBox(height: 8),
                      Text(
                        'No orders currently on hold.',
                        style: TextStyle(color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: heldTabs.length,
                  separatorBuilder: (_, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final tab = heldTabs[index];
                    return Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevatedDark,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.info.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusSmall,
                                        ),
                                      ),
                                      child: Text(
                                        tab.title,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.info,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${tab.cart.totalItemCount} items',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondaryDark,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Parked at: ${DateFormatter.formatDateTime(tab.createdAt)}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMutedDark,
                                  ),
                                ),
                                if (tab.customerPhone != null &&
                                    tab.customerPhone!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Customer: ${tab.customerPhone}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.primaryLight,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                CurrencyFormatter.format(tab.cart.grandTotal),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              const SizedBox(width: AppDimensions.space12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.info,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                ),
                                onPressed: () {
                                  context.read<PosBloc>().add(ResumeTabEvent(tab.id));
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(LucideIcons.play, size: 13),
                                label: const Text('Resume', style: TextStyle(fontSize: 12)),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                icon: const Icon(
                                  LucideIcons.trash2,
                                  size: 16,
                                  color: AppColors.danger,
                                ),
                                tooltip: 'Discard Tab',
                                onPressed: () {
                                  context
                                      .read<PosBloc>()
                                      .add(DeleteHeldTabEvent(tab.id));
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
