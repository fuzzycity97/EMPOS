import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/business_partner.dart';
import '../bloc/erp_bloc.dart';
import '../bloc/erp_event.dart';

class CapitalInjectionDialog extends StatelessWidget {
  final BusinessPartner partner;

  const CapitalInjectionDialog({
    super.key,
    required this.partner,
  });

  static Future<void> show(BuildContext context, {required BusinessPartner partner}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<ErpBloc>(),
        child: CapitalInjectionDialog(partner: partner),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountController = TextEditingController();

    return Dialog(
      backgroundColor: AppColors.surfaceElevatedDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        width: 440,
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
                      child: const Icon(LucideIcons.arrowUpRight, color: AppColors.emerald, size: 20),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    const Text(
                      'Inject Invested Capital',
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
            const SizedBox(height: AppDimensions.space16),

            // Partner Summary Card
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        partner.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Equity Share: ${partner.equityPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 12, color: AppColors.primary),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'Current Capital',
                        style: TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                      ),
                      Text(
                        '${partner.totalInvestedCapital.toStringAsFixed(2)} EGP',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emerald,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Amount Input
            const Text(
              'Additional Capital Amount (EGP) *',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: amountController,
              autofocus: true,
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
                          AddCapitalInjectionEvent(
                            partnerId: partner.id,
                            amount: amount,
                          ),
                        );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: const Text('Inject Capital'),
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
  }
}
