import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/anatomical_annotation_models.dart';

/// 5-Surface MODBL (Mesial, Occlusal, Distal, Buccal, Lingual)
/// Polygon Selection & Auto-Billing Widget for Dental Clinic.
/// 100% [StatelessWidget] architecture.
class DentalModblActionWidget extends StatelessWidget {
  final int toothNumberFdi;
  final ValueNotifier<Set<DentalModblSurface>> selectedSurfacesNotifier;
  final ValueNotifier<String> shadeNotifier;
  final void Function(DentalModblAnnotation annotation, List<ProcedureItem> billingItems)? onApply;

  DentalModblActionWidget({
    super.key,
    this.toothNumberFdi = 16,
    ValueNotifier<Set<DentalModblSurface>>? selectedSurfacesNotifier,
    ValueNotifier<String>? shadeNotifier,
    this.onApply,
  })  : selectedSurfacesNotifier = selectedSurfacesNotifier ?? ValueNotifier<Set<DentalModblSurface>>({DentalModblSurface.occlusal}),
        shadeNotifier = shadeNotifier ?? ValueNotifier<String>('A2');

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Tooth #$toothNumberFdi',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '5-Surface MODBL Restoration',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              // Composite Shade Selector
              ValueListenableBuilder<String>(
                valueListenable: shadeNotifier,
                builder: (context, shade, _) {
                  return Row(
                    children: ['A1', 'A2', 'A3', 'B1'].map((s) {
                      final active = s == shade;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () => shadeNotifier.value = s,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: active ? AppColors.primary : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              s,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: active ? FontWeight.bold : FontWeight.normal,
                                color: active ? Colors.white : null,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Visual 5-Surface Diamond Selector
          Center(
            child: SizedBox(
              width: 170,
              height: 170,
              child: ValueListenableBuilder<Set<DentalModblSurface>>(
                valueListenable: selectedSurfacesNotifier,
                builder: (context, surfaces, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      // Buccal (Top)
                      Positioned(
                        top: 4,
                        child: _buildSurfaceButton(
                          surface: DentalModblSurface.buccal,
                          label: 'B (Buccal)',
                          isSelected: surfaces.contains(DentalModblSurface.buccal),
                          width: 110,
                          height: 36,
                          isDark: isDark,
                        ),
                      ),
                      // Lingual (Bottom)
                      Positioned(
                        bottom: 4,
                        child: _buildSurfaceButton(
                          surface: DentalModblSurface.lingual,
                          label: 'L (Lingual)',
                          isSelected: surfaces.contains(DentalModblSurface.lingual),
                          width: 110,
                          height: 36,
                          isDark: isDark,
                        ),
                      ),
                      // Mesial (Left)
                      Positioned(
                        left: 4,
                        child: _buildSurfaceButton(
                          surface: DentalModblSurface.mesial,
                          label: 'M',
                          isSelected: surfaces.contains(DentalModblSurface.mesial),
                          width: 38,
                          height: 70,
                          isDark: isDark,
                        ),
                      ),
                      // Distal (Right)
                      Positioned(
                        right: 4,
                        child: _buildSurfaceButton(
                          surface: DentalModblSurface.distal,
                          label: 'D',
                          isSelected: surfaces.contains(DentalModblSurface.distal),
                          width: 38,
                          height: 70,
                          isDark: isDark,
                        ),
                      ),
                      // Occlusal (Center)
                      Center(
                        child: _buildSurfaceButton(
                          surface: DentalModblSurface.occlusal,
                          label: 'O',
                          isSelected: surfaces.contains(DentalModblSurface.occlusal),
                          width: 65,
                          height: 65,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Automated Billing Preview
          ValueListenableBuilder<Set<DentalModblSurface>>(
            valueListenable: selectedSurfacesNotifier,
            builder: (context, surfaces, _) {
              final annotation = DentalModblAnnotation(
                toothNumberFdi: toothNumberFdi,
                selectedSurfaces: surfaces,
                compositeResinShade: shadeNotifier.value,
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
                              'Auto-Attached Billing (${items.length} item${items.length == 1 ? "" : "s"})',
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
                        'Select at least 1 tooth surface to generate composite billing.',
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
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.check, size: 16),
              label: const Text('Apply MODBL Restoration to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                final annotation = DentalModblAnnotation(
                  toothNumberFdi: toothNumberFdi,
                  selectedSurfaces: selectedSurfacesNotifier.value,
                  compositeResinShade: shadeNotifier.value,
                );
                final billingItems = annotation.getGeneratedBillingItems();
                onApply?.call(annotation, billingItems);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurfaceButton({
    required DentalModblSurface surface,
    required String label,
    required bool isSelected,
    required double width,
    required double height,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () {
        final current = Set<DentalModblSurface>.from(selectedSurfacesNotifier.value);
        if (isSelected) {
          current.remove(surface);
        } else {
          current.add(surface);
        }
        selectedSurfacesNotifier.value = current;
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF59E0B).withValues(alpha: 0.25)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? const Color(0xFFF59E0B) : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? const Color(0xFFF59E0B) : null,
          ),
        ),
      ),
    );
  }
}
