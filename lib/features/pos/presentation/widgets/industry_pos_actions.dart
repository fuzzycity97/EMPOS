import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/pos_bloc.dart';
import '../bloc/pos_event.dart';
import 'restaurant_table_map_widget.dart';
import '../pages/kitchen_display_system_page.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pharmacy: Scan Rx / Prescription Button & Dialog
// ─────────────────────────────────────────────────────────────────────────────
class PharmacyPrescriptionButton extends StatelessWidget {
  const PharmacyPrescriptionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _openPrescriptionDialog(context),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.pill, size: 15, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'Scan Rx',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openPrescriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => const PrescriptionScanDialog(),
    );
  }
}

class PrescriptionScanDialog extends StatelessWidget {
  const PrescriptionScanDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rxController = TextEditingController(text: 'RX-8849-PARACETAMOL');

    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      title: Row(
        children: [
          Icon(LucideIcons.fileText, color: theme.colorScheme.primary, size: 20),
          const SizedBox(width: 8),
          const Text('Scan Medical Prescription (Rx)'),
        ],
      ),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Optical Prescription / Insurance Barcode Reader:',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: rxController,
              decoration: const InputDecoration(
                hintText: 'Scan Doctor Rx barcode or patient ID...',
                prefixIcon: Icon(LucideIcons.barcode, size: 18),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(AppDimensions.space12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.shieldCheck, size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Duplicate Molecule & Active Ingredient checking active.',
                      style: TextStyle(fontSize: 11.5, color: AppColors.textPrimaryDark),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final val = rxController.text.trim();
            if (val.isNotEmpty) {
              context.read<PosBloc>().add(ScanBarcodeEvent(val));
            }
            Navigator.of(context).pop();
          },
          icon: const Icon(LucideIcons.check, size: 16),
          label: const Text('Add Rx to Cart'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Food & Beverage: Dine-In Tables Selector Button & Dialog
// ─────────────────────────────────────────────────────────────────────────────
class RestaurantTablesButton extends StatelessWidget {
  const RestaurantTablesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _openTablesDialog(context),
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.utensils, size: 15, color: theme.colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              'Tables',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openTablesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogCtx) => BlocProvider.value(
        value: context.read<PosBloc>(),
        child: const RestaurantTablesDialog(),
      ),
    );
  }
}

class RestaurantTablesDialog extends StatelessWidget {
  final ValueNotifier<int>? modeNotifier;

  const RestaurantTablesDialog({super.key, this.modeNotifier});

  @override
  Widget build(BuildContext context) {
    final activeModeNotifier = modeNotifier ?? ValueNotifier<int>(0);
    final tables = [
      {'name': 'T-01 (Window)', 'status': 'Free', 'color': AppColors.success},
      {'name': 'T-02 (Window)', 'status': 'Occupied', 'color': AppColors.danger},
      {'name': 'T-03 (Booth)', 'status': 'Free', 'color': AppColors.success},
      {'name': 'T-04 (Booth)', 'status': 'Free', 'color': AppColors.success},
      {'name': 'T-05 (Center)', 'status': 'Free', 'color': AppColors.success},
      {'name': 'T-06 (Terrace)', 'status': 'Occupied', 'color': AppColors.danger},
      {'name': 'T-07 (Terrace)', 'status': 'Free', 'color': AppColors.success},
      {'name': 'T-08 (VIP Lounge)', 'status': 'Free', 'color': AppColors.success},
    ];

    return AlertDialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      title: Row(
        children: [
          const Icon(LucideIcons.utensils, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('Select Dine-In Table Layout')),
          ValueListenableBuilder<int>(
            valueListenable: activeModeNotifier,
            builder: (context, mode, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ChoiceChip(
                    label: const Text('2D Floor Plan', style: TextStyle(fontSize: 11)),
                    selected: mode == 0,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => activeModeNotifier.value = 0,
                  ),
                  const SizedBox(width: 6),
                  ChoiceChip(
                    label: const Text('Quick Grid', style: TextStyle(fontSize: 11)),
                    selected: mode == 1,
                    selectedColor: AppColors.primary,
                    onSelected: (_) => activeModeNotifier.value = 1,
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    tooltip: 'Kitchen Display System (KDS)',
                    icon: const Icon(LucideIcons.chefHat, color: AppColors.warning, size: 20),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => KitchenDisplaySystemPage()),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
      content: SizedBox(
        width: 820,
        height: 520,
        child: ValueListenableBuilder<int>(
          valueListenable: activeModeNotifier,
          builder: (context, mode, _) {
            if (mode == 0) {
              return RestaurantTableMapWidget(
                onTableSelected: (table) {
                  context.read<PosBloc>().add(
                        HoldCurrentTabEvent(tabTitle: 'DINE-IN ${table.label}'),
                      );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Order linked to table ${table.label}')),
                  );
                },
              );
            }

            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final t = tables[index];
                final isFree = t['status'] == 'Free';

                return InkWell(
                  onTap: () {
                    context.read<PosBloc>().add(
                          HoldCurrentTabEvent(tabTitle: 'DINE-IN ${t['name']}'),
                        );
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Order linked to table ${t['name']}')),
                    );
                  },
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevatedDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(
                        color: isFree ? AppColors.borderDark : AppColors.danger.withValues(alpha: 0.5),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          t['name'] as String,
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (t['color'] as Color).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            t['status'] as String,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: t['color'] as Color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Supermarket: Live Electronic Scale Weight Indicator
// ─────────────────────────────────────────────────────────────────────────────
class ScaleWeightIndicator extends StatelessWidget {
  const ScaleWeightIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(LucideIcons.scale, size: 14, color: AppColors.warning),
          SizedBox(width: 4),
          Text(
            'SCALE: 0.000 KG',
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              color: AppColors.warning,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Food & Beverage: Kitchen Display System (KDS) Entry Button
// ─────────────────────────────────────────────────────────────────────────────
class KitchenKdsButton extends StatelessWidget {
  const KitchenKdsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => KitchenDisplaySystemPage()),
        );
      },
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.chefHat, size: 15, color: AppColors.warning),
            SizedBox(width: 6),
            Text(
              'Kitchen KDS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

