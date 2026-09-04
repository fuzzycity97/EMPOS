import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/anatomical_annotation_models.dart';

/// Dermatology Rule-of-Nines Burn Surface Calculator & Linear Suture Marker.
/// 100% [StatelessWidget] architecture.
class DermatologyActionWidget extends StatelessWidget {
  final ValueNotifier<Set<BodyBurnRegion>> selectedRegionsNotifier;
  final ValueNotifier<double> incisionLengthNotifier;
  final ValueNotifier<int> sutureCountNotifier;
  final void Function(DermatologyBurnAreaSutureAnnotation annotation, List<ProcedureItem> billingItems)? onApply;

  DermatologyActionWidget({
    super.key,
    ValueNotifier<Set<BodyBurnRegion>>? selectedRegionsNotifier,
    ValueNotifier<double>? incisionLengthNotifier,
    ValueNotifier<int>? sutureCountNotifier,
    this.onApply,
  })  : selectedRegionsNotifier = selectedRegionsNotifier ?? ValueNotifier<Set<BodyBurnRegion>>({BodyBurnRegion.chest, BodyBurnRegion.abdomen}),
        incisionLengthNotifier = incisionLengthNotifier ?? ValueNotifier<double>(5.0),
        sutureCountNotifier = sutureCountNotifier ?? ValueNotifier<int>(4);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.flame, color: Color(0xFFF97316), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Rule-of-Nines & Suture Marker',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              // Live TBSA Badge
              ValueListenableBuilder<Set<BodyBurnRegion>>(
                valueListenable: selectedRegionsNotifier,
                builder: (context, regions, _) {
                  final tbsa = regions.fold(0.0, (acc, r) => acc + r.percentage);
                  final isCritical = tbsa >= 20.0;
                  final badgeColor = tbsa == 0
                      ? Colors.grey
                      : (isCritical ? const Color(0xFFEF4444) : const Color(0xFFF97316));

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: badgeColor, width: 1),
                    ),
                    child: Text(
                      'TBSA: ${tbsa.toStringAsFixed(0)}%',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: badgeColor),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rule of Nines Interactive Sector Chips
          const Text('Select Burn Anatomical Regions (Rule of Nines):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          ValueListenableBuilder<Set<BodyBurnRegion>>(
            valueListenable: selectedRegionsNotifier,
            builder: (context, regions, _) {
              return Wrap(
                spacing: 6,
                runSpacing: 6,
                children: BodyBurnRegion.values.map((reg) {
                  final isSelected = regions.contains(reg);
                  return FilterChip(
                                        label: Text('${reg.label} (${reg.percentage.toStringAsFixed(0)}%)', style: const TextStyle(fontSize: 11)),
                    selected: isSelected,
                    selectedColor: const Color(0xFFF97316).withValues(alpha: 0.2),
                    checkmarkColor: const Color(0xFFF97316),
                    onSelected: (val) {
                      final updated = Set<BodyBurnRegion>.from(regions);
                      if (val) {
                        updated.add(reg);
                      } else {
                        updated.remove(reg);
                      }
                      selectedRegionsNotifier.value = updated;
                    },
                  );
                }).toList(),
              );
            },
          ),
          const SizedBox(height: 14),

          // Linear Suture & Incision Caliper Section
          Row(
            children: [
              const Icon(LucideIcons.bandage, size: 16, color: Color(0xFF0D9488)),
              const SizedBox(width: 6),
              const Text('Linear Suture & Incision Caliper:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),

          // Incision Length Slider
          ValueListenableBuilder<double>(
            valueListenable: incisionLengthNotifier,
            builder: (context, len, _) {
              return Row(
                children: [
                  const Text('Wound Length:', style: TextStyle(fontSize: 11)),
                  Expanded(
                    child: Slider(
                      value: len,
                      min: 0,
                      max: 25,
                      divisions: 50,
                      activeColor: const Color(0xFF0D9488),
                      label: '${len.toStringAsFixed(1)} cm',
                      onChanged: (val) => incisionLengthNotifier.value = val,
                    ),
                  ),
                  Text('${len.toStringAsFixed(1)} cm', style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.bold)),
                ],
              );
            },
          ),

          // Suture Stitch Count Stepper
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Stitches Placed:', style: TextStyle(fontSize: 11)),
              ValueListenableBuilder<int>(
                valueListenable: sutureCountNotifier,
                builder: (context, count, _) {
                  return Row(
                    children: [
                      IconButton(
                        icon: const Icon(LucideIcons.minusCircle, size: 18),
                        onPressed: count > 0 ? () => sutureCountNotifier.value = count - 1 : null,
                      ),
                      Text('$count stitches', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      IconButton(
                        icon: const Icon(LucideIcons.plusCircle, size: 18),
                        onPressed: () => sutureCountNotifier.value = count + 1,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Billing Preview
          ValueListenableBuilder<Set<BodyBurnRegion>>(
            valueListenable: selectedRegionsNotifier,
            builder: (context, regions, _) {
              return ValueListenableBuilder<double>(
                valueListenable: incisionLengthNotifier,
                builder: (context, len, _) {
                  return ValueListenableBuilder<int>(
                    valueListenable: sutureCountNotifier,
                    builder: (context, stitches, _) {
                      final annotation = DermatologyBurnAreaSutureAnnotation(
                        affectedBurnRegions: regions,
                        incisionLengthCm: len,
                        sutureCount: stitches,
                      );
                      final items = annotation.getGeneratedBillingItems();
                      final totalFee = items.fold(0.0, (acc, item) => acc + item.standardFee);

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.receipt, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Dermatology Cart Binding (${items.length} item${items.length == 1 ? "" : "s"})',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                                Text(
                                  '\$${totalFee.toStringAsFixed(2)}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF10B981)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            if (items.isEmpty)
                              const Text(
                                'Select burn regions or set incision length to attach procedure items.',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              )
                            else
                              ...items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          '[${item.code}] ${item.name}',
                                          style: const TextStyle(fontSize: 11),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '\$${item.standardFee.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF97316),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.check, size: 16),
              label: const Text('Apply Burn & Suture Procedure to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                final annotation = DermatologyBurnAreaSutureAnnotation(
                  affectedBurnRegions: selectedRegionsNotifier.value,
                  incisionLengthCm: incisionLengthNotifier.value,
                  sutureCount: sutureCountNotifier.value,
                );
                final billingItems = annotation.getGeneratedBillingItems();
                onApply?.call(annotation, billingItems);
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}
