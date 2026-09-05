import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/medical_risk_factor.dart';
import '../bloc/clinic_bloc.dart';
import '../bloc/clinic_event.dart';

class MedicalRiskFactorManagerDialog extends StatelessWidget {
  final List<MedicalRiskFactor> currentFactors;

  const MedicalRiskFactorManagerDialog({
    super.key,
    required this.currentFactors,
  });

  static const List<Map<String, dynamic>> availableColors = [
    {'name': 'Amber', 'value': 0xFFEAB308},
    {'name': 'Orange', 'value': 0xFFF97316},
    {'name': 'Red', 'value': 0xFFEF4444},
    {'name': 'Rose', 'value': 0xFFF43F5E},
    {'name': 'Cyan', 'value': 0xFF06B6D4},
    {'name': 'Teal', 'value': 0xFF14B8A6},
    {'name': 'Indigo', 'value': 0xFF6366F1},
    {'name': 'Purple', 'value': 0xFFA855F7},
    {'name': 'Green', 'value': 0xFF22C55E},
    {'name': 'Blue', 'value': 0xFF3B82F6},
  ];

  static const List<Map<String, dynamic>> availableIcons = [
    {'name': 'activity', 'icon': LucideIcons.activity, 'label': 'Vitals'},
    {'name': 'cigarette', 'icon': LucideIcons.cigarette, 'label': 'Smoking'},
    {'name': 'heartPulse', 'icon': LucideIcons.heartPulse, 'label': 'Hypertension'},
    {'name': 'heart', 'icon': LucideIcons.heart, 'label': 'Heart'},
    {'name': 'droplet', 'icon': LucideIcons.droplet, 'label': 'Blood/Bleeding'},
    {'name': 'wind', 'icon': LucideIcons.wind, 'label': 'Respiratory'},
    {'name': 'baby', 'icon': LucideIcons.baby, 'label': 'Pregnancy'},
    {'name': 'pill', 'icon': LucideIcons.pill, 'label': 'Medication'},
    {'name': 'shieldAlert', 'icon': LucideIcons.shieldAlert, 'label': 'High Risk'},
    {'name': 'alertTriangle', 'icon': LucideIcons.triangleAlert, 'label': 'Warning'},
    {'name': 'dna', 'icon': LucideIcons.dna, 'label': 'Genetics'},
    {'name': 'bone', 'icon': LucideIcons.bone, 'label': 'Bone/Joint'},
    {'name': 'eye', 'icon': LucideIcons.eye, 'label': 'Eye'},
    {'name': 'brain', 'icon': LucideIcons.brain, 'label': 'Brain'},
    {'name': 'apple', 'icon': LucideIcons.apple, 'label': 'Nutrition'},
  ];

  @override
  Widget build(BuildContext context) {
    final factorsNotifier = ValueNotifier<List<MedicalRiskFactor>>(List.from(currentFactors));
    final newLabelController = TextEditingController();
    final selectedColorNotifier = ValueNotifier<int>(0xFFEAB308);
    final selectedIconNotifier = ValueNotifier<String>('activity');
    final isAddingNotifier = ValueNotifier<bool>(false);

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: SizedBox(
        width: 580,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(LucideIcons.slidersHorizontal, size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Medical Risk Factors Manager',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                          Text(
                            'Customize clinical indicators, colors & icons across all stations',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textMutedDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Existing factors list
              const Text(
                'Active Clinical Indicators',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondaryDark),
              ),
              const SizedBox(height: 8),

              SizedBox(
                height: 220,
                child: ValueListenableBuilder<List<MedicalRiskFactor>>(
                  valueListenable: factorsNotifier,
                  builder: (context, factors, _) {
                    if (factors.isEmpty) {
                      return const Center(
                        child: Text('No risk factors configured.', style: TextStyle(color: Colors.grey)),
                      );
                    }
                    return ListView.separated(
                      itemCount: factors.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 6),
                      itemBuilder: (ctx, index) {
                        final factor = factors[index];
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.03),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: factor.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(factor.iconData, size: 16, color: factor.color),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  factor.label,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: factor.isEnabled ? Colors.white : Colors.grey,
                                    decoration: factor.isEnabled ? null : TextDecoration.lineThrough,
                                  ),
                                ),
                              ),
                              // Enable/Disable toggle
                              Switch(
                                value: factor.isEnabled,
                                activeThumbColor: factor.color,
                                onChanged: (val) {
                                  final updated = List<MedicalRiskFactor>.from(factors);
                                  updated[index] = factor.copyWith(isEnabled: val);
                                  factorsNotifier.value = updated;
                                },
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
                                onPressed: () {
                                  final updated = List<MedicalRiskFactor>.from(factors)..removeAt(index);
                                  factorsNotifier.value = updated;
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Add New Indicator Section
              ValueListenableBuilder<bool>(
                valueListenable: isAddingNotifier,
                builder: (context, isAdding, _) {
                  if (!isAdding) {
                    return OutlinedButton.icon(
                      onPressed: () => isAddingNotifier.value = true,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(LucideIcons.plus, size: 16, color: AppColors.primary),
                      label: const Text('Add New Risk Factor', style: TextStyle(color: AppColors.primary)),
                    );
                  }

                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: newLabelController,
                                autofocus: true,
                                style: const TextStyle(fontSize: 13, color: Colors.white),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  hintText: 'Condition Name (e.g. Hepatitis, Latex Allergy)',
                                  hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(LucideIcons.x, size: 18, color: Colors.grey),
                              onPressed: () => isAddingNotifier.value = false,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Pick Color
                        const Text('Color Palette:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<int>(
                          valueListenable: selectedColorNotifier,
                          builder: (ctx, selColor, _) {
                            return Wrap(
                              spacing: 8,
                              children: availableColors.map((c) {
                                final colorVal = c['value'] as int;
                                final isSelected = colorVal == selColor;
                                return InkWell(
                                  onTap: () => selectedColorNotifier.value = colorVal,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Color(colorVal),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? Colors.white : Colors.transparent,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(LucideIcons.check, size: 14, color: Colors.black)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 10),

                        // Pick Icon
                        const Text('Icon:', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        const SizedBox(height: 6),
                        ValueListenableBuilder<String>(
                          valueListenable: selectedIconNotifier,
                          builder: (ctx, selIcon, _) {
                            return Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: availableIcons.map((i) {
                                final iconName = i['name'] as String;
                                final iconData = i['icon'] as IconData;
                                final isSelected = iconName == selIcon;
                                return InkWell(
                                  onTap: () => selectedIconNotifier.value = iconName,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : Colors.white10,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                                    ),
                                    child: Icon(iconData, size: 16, color: isSelected ? Colors.white : Colors.grey),
                                  ),
                                );
                              }).toList(),
                            );
                          },
                        ),
                        const SizedBox(height: 10),

                        // Add Button
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            onPressed: () {
                              final text = newLabelController.text.trim();
                              if (text.isEmpty) return;
                              final newFactor = MedicalRiskFactor(
                                id: 'rf_${DateTime.now().millisecondsSinceEpoch}',
                                label: text,
                                colorValue: selectedColorNotifier.value,
                                iconName: selectedIconNotifier.value,
                                isEnabled: true,
                              );
                              factorsNotifier.value = [...factorsNotifier.value, newFactor];
                              newLabelController.clear();
                              isAddingNotifier.value = false;
                            },
                            icon: const Icon(LucideIcons.plus, size: 14, color: Colors.white),
                            label: const Text('Add Indicator', style: TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onPressed: () {
                      context.read<ClinicBloc>().add(UpdateMedicalRiskFactorsEvent(factorsNotifier.value));
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(LucideIcons.save, size: 16, color: Colors.white),
                    label: const Text('Save & Sync to Stations', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
