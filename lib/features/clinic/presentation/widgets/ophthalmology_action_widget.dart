import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/anatomical_annotation_models.dart';

/// Ophthalmology Cup-to-Disc (C:D) Dial & Automated Glaucoma Diagnostic Suggestions.
/// 100% [StatelessWidget] architecture.
class OphthalmologyActionWidget extends StatelessWidget {
  final ValueNotifier<double> cupDiscRatioNotifier;
  final ValueNotifier<bool> rightEyeNotifier;
  final ValueNotifier<bool> visualFieldNotifier;
  final ValueNotifier<bool> octScanNotifier;
  final void Function(OphthalmologyCupDiscAnnotation annotation, List<ProcedureItem> billingItems)? onApply;

  OphthalmologyActionWidget({
    super.key,
    ValueNotifier<double>? cupDiscRatioNotifier,
    ValueNotifier<bool>? rightEyeNotifier,
    ValueNotifier<bool>? visualFieldNotifier,
    ValueNotifier<bool>? octScanNotifier,
    this.onApply,
  })  : cupDiscRatioNotifier = cupDiscRatioNotifier ?? ValueNotifier<double>(0.4),
        rightEyeNotifier = rightEyeNotifier ?? ValueNotifier<bool>(true),
        visualFieldNotifier = visualFieldNotifier ?? ValueNotifier<bool>(false),
        octScanNotifier = octScanNotifier ?? ValueNotifier<bool>(false);

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
              Expanded(
                child: Row(
                  children: [
                    const Icon(LucideIcons.eye, color: Color(0xFF06B6D4), size: 18),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Optic Nerve Cup-to-Disc (C:D) Ratio',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              // Eye Toggle (OD vs OS)
              ValueListenableBuilder<bool>(
                valueListenable: rightEyeNotifier,
                builder: (context, isRightEye, _) {
                  return Row(
                    children: [
                      _buildEyeButton(label: 'OD (Right)', selected: isRightEye, onSelect: () => rightEyeNotifier.value = true, isDark: isDark),
                      const SizedBox(width: 4),
                      _buildEyeButton(label: 'OS (Left)', selected: !isRightEye, onSelect: () => rightEyeNotifier.value = false, isDark: isDark),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Simulation of Optic Disc & Cup
          Center(
            child: ValueListenableBuilder<double>(
              valueListenable: cupDiscRatioNotifier,
              builder: (context, cdRatio, _) {
                final isGlaucoma = cdRatio > 0.5;
                final statusColor = cdRatio <= 0.4
                    ? const Color(0xFF10B981)
                    : (cdRatio <= 0.6 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

                return Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer Optic Disc (Neuroretinal Rim)
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFFEA580C), Color(0xFF9A3412)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.orange.withValues(alpha: 0.25),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        // Inner Physiological Cup
                        Container(
                          width: (120 * cdRatio).clamp(12.0, 115.0),
                          height: (120 * cdRatio).clamp(12.0, 115.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFEF3C7),
                            border: Border.all(color: Colors.amberAccent, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            cdRatio.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isGlaucoma
                            ? 'GLAUCOMA SUSPECT / CUPPING (C:D > 0.50)'
                            : (cdRatio > 0.4 ? 'BORDERLINE PHYSIOLOGICAL CUPPING' : 'NORMAL PHYSIOLOGICAL CUP'),
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: statusColor),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // C:D Slider Dial (0.1 to 1.0)
          ValueListenableBuilder<double>(
            valueListenable: cupDiscRatioNotifier,
            builder: (context, cdRatio, _) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('C:D Ratio Caliper', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      Text(
                        cdRatio.toStringAsFixed(2),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'monospace'),
                      ),
                    ],
                  ),
                  Slider(
                    value: cdRatio,
                    min: 0.1,
                    max: 1.0,
                    divisions: 18,
                    activeColor: const Color(0xFF06B6D4),
                    label: cdRatio.toStringAsFixed(2),
                    onChanged: (val) {
                      cupDiscRatioNotifier.value = val;
                      // Automated suggestion trigger: If cup-to-disc > 0.5, auto-recommend follow-up tests
                      if (val > 0.5) {
                        visualFieldNotifier.value = true;
                        octScanNotifier.value = true;
                      }
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),

          // Automated Diagnostic Suggestions Checkboxes
          const Text('Automated Diagnostic Follow-Up Orders:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 6),
          ValueListenableBuilder<bool>(
            valueListenable: visualFieldNotifier,
            builder: (context, reqVf, _) {
              return Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF06B6D4),
                title: const Text('Humphrey 24-2 Visual Field Perimetry', style: TextStyle(fontSize: 12)),
                subtitle: const Text('Recommended for scotoma & nerve fiber bundle defects', style: TextStyle(fontSize: 10, color: Colors.grey)),
                value: reqVf,
                onChanged: (val) => visualFieldNotifier.value = val ?? false,
              ),
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: octScanNotifier,
            builder: (context, reqOct, _) {
              return Material(
                color: Colors.transparent,
                child: CheckboxListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF06B6D4),
                title: const Text('OCT RNFL & Ganglion Cell Complex Scan', style: TextStyle(fontSize: 12)),
                subtitle: const Text('Recommended for quantitative micron neuroretinal rim thinning', style: TextStyle(fontSize: 10, color: Colors.grey)),
                value: reqOct,
                onChanged: (val) => octScanNotifier.value = val ?? false,
              ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Billing Preview
          ValueListenableBuilder<double>(
            valueListenable: cupDiscRatioNotifier,
            builder: (context, cdRatio, _) {
              return ValueListenableBuilder<bool>(
                valueListenable: visualFieldNotifier,
                builder: (context, reqVf, _) {
                  return ValueListenableBuilder<bool>(
                    valueListenable: octScanNotifier,
                    builder: (context, reqOct, _) {
                      final annotation = OphthalmologyCupDiscAnnotation(
                        cupToDiscRatio: cdRatio,
                        rightEyeOD: rightEyeNotifier.value,
                        requestVisualFieldTest: reqVf,
                        requestOctScan: reqOct,
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
                                      'Ophthalmic Cart Binding (${items.length} item${items.length == 1 ? "" : "s"})',
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
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.check, size: 16),
              label: const Text('Apply C:D Ratio & Orders to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                final annotation = OphthalmologyCupDiscAnnotation(
                  cupToDiscRatio: cupDiscRatioNotifier.value,
                  rightEyeOD: rightEyeNotifier.value,
                  requestVisualFieldTest: visualFieldNotifier.value,
                  requestOctScan: octScanNotifier.value,
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

  Widget _buildEyeButton({required String label, required bool selected, required VoidCallback onSelect, required bool isDark}) {
    return InkWell(
      onTap: onSelect,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF06B6D4) : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : null,
          ),
        ),
      ),
    );
  }
}
