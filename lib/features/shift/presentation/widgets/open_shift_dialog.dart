import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/shift_bloc.dart';
import '../bloc/shift_event.dart';

class OpenShiftDialog extends StatelessWidget {
  final TextEditingController floatController;
  final TextEditingController cashierNameController;
  final TextEditingController notesController;

  const OpenShiftDialog._({
    super.key,
    required this.floatController,
    required this.cashierNameController,
    required this.notesController,
  });

  factory OpenShiftDialog({Key? key, String defaultCashier = 'Active Cashier'}) {
    return OpenShiftDialog._(
      key: key,
      floatController: TextEditingController(text: '500.00'),
      cashierNameController: TextEditingController(text: defaultCashier),
      notesController: TextEditingController(),
    );
  }

  void _setPreset(double amount) {
    floatController.text = amount.toStringAsFixed(2);
  }

  void _submit(BuildContext context) {
    final float = double.tryParse(floatController.text.trim()) ?? 0.0;
    final cashier = cashierNameController.text.trim();
    final notes = notesController.text.trim();

    if (cashier.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a cashier name.')),
      );
      return;
    }

    context.read<ShiftBloc>().add(
          OpenShiftEvent(
            cashierId: 'CASHIER-${DateTime.now().millisecondsSinceEpoch}',
            cashierName: cashier,
            startingCash: float,
            notes: notes.isNotEmpty ? notes : null,
          ),
        );

    Navigator.of(context).pop();
  }

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
        padding: const EdgeInsets.all(AppDimensions.space24),
        constraints: const BoxConstraints(maxWidth: 460),
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: const Icon(
                        LucideIcons.unlock,
                        size: 20,
                        color: AppColors.primaryLight,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Text(
                      'Start Shift & Open Drawer',
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

            // Cashier Name
            const Text(
              'Cashier Name / Operator',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: cashierNameController,
              decoration: const InputDecoration(
                prefixIcon: Icon(LucideIcons.userCheck, size: 16),
                hintText: 'Enter operator name',
              ),
            ),
            const SizedBox(height: AppDimensions.space16),

            // Opening Float
            const Text(
              'Starting Morning Cash Float (EGP)',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: floatController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixIcon: Icon(LucideIcons.banknote, size: 16),
                hintText: '0.00',
              ),
            ),
            const SizedBox(height: AppDimensions.space8),

            // Quick Preset Buttons
            Wrap(
              spacing: 6,
              children: [
                _PresetBtn(label: '200 EGP', onTap: () => _setPreset(200)),
                _PresetBtn(label: '500 EGP', onTap: () => _setPreset(500)),
                _PresetBtn(label: '1000 EGP', onTap: () => _setPreset(1000)),
                _PresetBtn(label: '2000 EGP', onTap: () => _setPreset(2000)),
              ],
            ),
            const SizedBox(height: AppDimensions.space16),

            // Notes
            const Text(
              'Shift Notes (Optional)',
              style: TextStyle(
                fontSize: 11.5,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                hintText: 'e.g. Morning Opening Float',
              ),
            ),
            const SizedBox(height: AppDimensions.space24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  ),
                ),
                onPressed: () => _submit(context),
                icon: const Icon(LucideIcons.playCircle, size: 18),
                label: const Text(
                  'OPEN SHIFT & UNLOCK POS',
                  style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        side: const BorderSide(color: AppColors.borderDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
