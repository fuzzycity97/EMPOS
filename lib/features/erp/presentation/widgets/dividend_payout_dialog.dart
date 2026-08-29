import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/erp_bloc.dart';
import '../bloc/erp_event.dart';
import '../bloc/erp_state.dart';

class DividendPayoutDialog extends StatelessWidget {
  final String? initialPartnerId;

  const DividendPayoutDialog({
    super.key,
    this.initialPartnerId,
  });

  static Future<void> show(BuildContext context, {String? partnerId}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<ErpBloc>(),
        child: DividendPayoutDialog(initialPartnerId: partnerId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ErpBloc, ErpState>(
      builder: (context, state) {
        if (state is! ErpLoaded) {
          return const SizedBox.shrink();
        }

        final partners = state.partners;
        if (partners.isEmpty) {
          return Dialog(
            backgroundColor: AppColors.surfaceElevatedDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.circleAlert, color: AppColors.warning, size: 36),
                  const SizedBox(height: 12),
                  const Text(
                    'No Business Partners Found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please add business partners first before distributing dividend payouts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    child: const Text('OK', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          );
        }

        final selectedPartnerIdNotifier = ValueNotifier<String>(
          initialPartnerId ?? partners.first.id,
        );
        final amountController = TextEditingController();
        final notesController = TextEditingController();
        final isPaidFromDrawerNotifier = ValueNotifier<bool>(true);

        return Dialog(
          backgroundColor: AppColors.surfaceElevatedDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            side: const BorderSide(color: AppColors.borderDark),
          ),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(AppDimensions.space24),
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
                          padding: const EdgeInsets.all(AppDimensions.space10),
                          decoration: BoxDecoration(
                            color: AppColors.emerald.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          child: const Icon(LucideIcons.coins, color: AppColors.emerald, size: 20),
                        ),
                        const SizedBox(width: AppDimensions.space12),
                        const Text(
                          'Distribute Dividend Payout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.x, color: AppColors.textMutedDark, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space20),

                // Partner Selector
                const Text(
                  'Select Business Partner *',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 6),
                ValueListenableBuilder<String>(
                  valueListenable: selectedPartnerIdNotifier,
                  builder: (context, selectedId, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedId,
                          isExpanded: true,
                          dropdownColor: AppColors.surfaceElevatedDark,
                          items: partners.map((partner) {
                            return DropdownMenuItem<String>(
                              value: partner.id,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    partner.name,
                                    style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13.5, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    '${partner.equityPercentage.toStringAsFixed(1)}% Equity',
                                    style: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              selectedPartnerIdNotifier.value = val;
                            }
                          },
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.space16),

                // Amount
                const Text(
                  'Dividend Amount (EGP) *',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppColors.emerald, fontSize: 16, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    suffixText: 'EGP',
                    suffixStyle: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.bold),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    prefixIcon: const Icon(LucideIcons.banknote, size: 18, color: AppColors.emerald),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // Notes / Description
                const Text(
                  'Distribution Notes / Period Description',
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: notesController,
                  style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'e.g. Q3 2026 Profit Drawdown',
                    hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    prefixIcon: const Icon(LucideIcons.notebookText, size: 18, color: AppColors.textMutedDark),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // Cash Register Till Pay-Out Toggle
                ValueListenableBuilder<bool>(
                  valueListenable: isPaidFromDrawerNotifier,
                  builder: (context, isDeduct, _) {
                    return Container(
                      padding: const EdgeInsets.all(AppDimensions.space12),
                      decoration: BoxDecoration(
                        color: isDeduct ? AppColors.emerald.withValues(alpha: 0.1) : AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        border: Border.all(
                          color: isDeduct ? AppColors.emerald.withValues(alpha: 0.4) : AppColors.borderDark,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => isPaidFromDrawerNotifier.value = !isDeduct,
                        child: Row(
                          children: [
                            Checkbox(
                              value: isDeduct,
                              activeColor: AppColors.emerald,
                              checkColor: Colors.black,
                              onChanged: (val) => isPaidFromDrawerNotifier.value = val ?? false,
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hand Cash from Shift Till (Shift Pay-Out)',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.textPrimaryDark,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Deducts cash directly from the cashier drawer balance for immediate reconciliation.',
                                    style: TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.space24),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondaryDark,
                        side: const BorderSide(color: AppColors.borderDark),
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    ElevatedButton.icon(
                      onPressed: () {
                        final amount = double.tryParse(amountController.text.trim()) ?? 0.0;
                        if (amount <= 0) return;

                        context.read<ErpBloc>().add(
                              RecordDividendPayoutEvent(
                                partnerId: selectedPartnerIdNotifier.value,
                                amount: amount,
                                payoutDate: DateTime.now(),
                                isPaidFromDrawer: isPaidFromDrawerNotifier.value,
                                notes: notesController.text.trim().isNotEmpty
                                    ? notesController.text.trim()
                                    : null,
                              ),
                            );
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(LucideIcons.check, size: 18),
                      label: const Text('Confirm Distribution'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.emerald,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
