import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/business_partner.dart';
import '../bloc/erp_bloc.dart';
import '../bloc/erp_event.dart';

class PartnerFormDialog extends StatelessWidget {
  final BusinessPartner? partnerToEdit;

  const PartnerFormDialog({
    super.key,
    this.partnerToEdit,
  });

  static Future<void> show(BuildContext context, {BusinessPartner? partner}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: context.read<ErpBloc>(),
        child: PartnerFormDialog(partnerToEdit: partner),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nameController = TextEditingController(text: partnerToEdit?.name ?? '');
    final phoneController = TextEditingController(text: partnerToEdit?.contactInfo ?? '');
    final equityController = TextEditingController(
      text: partnerToEdit != null ? partnerToEdit!.equityPercentage.toStringAsFixed(1) : '25.0',
    );
    final capitalController = TextEditingController(
      text: partnerToEdit != null ? partnerToEdit!.totalInvestedCapital.toStringAsFixed(2) : '0.00',
    );

    final isEdit = partnerToEdit != null;

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
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      ),
                      child: const Icon(LucideIcons.handshake, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Text(
                      isEdit ? 'Edit Business Partner' : 'Add Business Partner',
                      style: const TextStyle(
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

            // Partner Full Name
            const Text(
              'Full Legal Name *',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: nameController,
              style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. Mahmoud El-Sayed',
                hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceDark,
                prefixIcon: const Icon(LucideIcons.user, size: 18, color: AppColors.textMutedDark),
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

            // Phone / Contact Info
            const Text(
              'Contact Info (Phone / Email)',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'e.g. 01012345678 or partner@business.com',
                hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                filled: true,
                fillColor: AppColors.surfaceDark,
                prefixIcon: const Icon(LucideIcons.phone, size: 18, color: AppColors.textMutedDark),
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

            // Equity Percentage & Capital Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Equity Share (%) *',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: equityController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '25.0',
                          suffixText: '%',
                          suffixStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: AppColors.surfaceDark,
                          prefixIcon: const Icon(LucideIcons.pieChart, size: 18, color: AppColors.primary),
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
                    ],
                  ),
                ),
                const SizedBox(width: AppDimensions.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invested Capital (EGP)',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: capitalController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: AppColors.emerald, fontSize: 14, fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          hintText: '0.00',
                          suffixText: 'EGP',
                          suffixStyle: const TextStyle(color: AppColors.emerald, fontWeight: FontWeight.bold),
                          filled: true,
                          fillColor: AppColors.surfaceDark,
                          prefixIcon: const Icon(LucideIcons.wallet, size: 18, color: AppColors.emerald),
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
                    ],
                  ),
                ),
              ],
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
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final equity = double.tryParse(equityController.text.trim()) ?? 0.0;
                    final capital = double.tryParse(capitalController.text.trim()) ?? 0.0;

                    final partner = BusinessPartner(
                      id: partnerToEdit?.id ?? 'PTR-${DateTime.now().millisecondsSinceEpoch}',
                      name: name,
                      contactInfo: phoneController.text.trim().isNotEmpty ? phoneController.text.trim() : null,
                      equityPercentage: equity.clamp(0.0, 100.0),
                      totalInvestedCapital: capital,
                      withdrawnDividends: partnerToEdit?.withdrawnDividends ?? 0.0,
                      createdAt: partnerToEdit?.createdAt ?? DateTime.now(),
                    );

                    context.read<ErpBloc>().add(SavePartnerEvent(partner));
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(LucideIcons.check, size: 18),
                  label: Text(isEdit ? 'Save Changes' : 'Create Partner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
