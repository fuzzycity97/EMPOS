import 'dart:math';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/anatomical_annotation_models.dart';

/// Orthopedics & Trauma Cut-Plane Tool with Distal Wireframe Fade & Joint Goniometer.
/// 100% [StatelessWidget] architecture.
class OrthopedicsTraumaActionWidget extends StatelessWidget {
  final ValueNotifier<String> limbNotifier;
  final ValueNotifier<bool> enableCutPlaneNotifier;
  final ValueNotifier<double> cutPlaneYNotifier;
  final ValueNotifier<bool> wireframeFadeNotifier;
  final ValueNotifier<double> goniometerAngleNotifier;
  final ValueNotifier<String> motionTypeNotifier;
  final void Function(OrthopedicsCutPlaneGoniometerAnnotation annotation, List<ProcedureItem> billingItems)? onApply;

  OrthopedicsTraumaActionWidget({
    super.key,
    ValueNotifier<String>? limbNotifier,
    ValueNotifier<bool>? enableCutPlaneNotifier,
    ValueNotifier<double>? cutPlaneYNotifier,
    ValueNotifier<bool>? wireframeFadeNotifier,
    ValueNotifier<double>? goniometerAngleNotifier,
    ValueNotifier<String>? motionTypeNotifier,
    this.onApply,
  })  : limbNotifier = limbNotifier ?? ValueNotifier<String>('Right Femur'),
        enableCutPlaneNotifier = enableCutPlaneNotifier ?? ValueNotifier<bool>(true),
        cutPlaneYNotifier = cutPlaneYNotifier ?? ValueNotifier<double>(0.6),
        wireframeFadeNotifier = wireframeFadeNotifier ?? ValueNotifier<bool>(true),
        goniometerAngleNotifier = goniometerAngleNotifier ?? ValueNotifier<double>(115.0),
        motionTypeNotifier = motionTypeNotifier ?? ValueNotifier<String>('Flexion');

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
                  const Icon(LucideIcons.scissors, color: Color(0xFF8B5CF6), size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Osteotomy Cut-Plane & Goniometer',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              // Limb Selector
              ValueListenableBuilder<String>(
                valueListenable: limbNotifier,
                builder: (context, limb, _) {
                  return DropdownButton<String>(
                    value: limb,
                    isDense: true,
                    underline: const SizedBox(),
                    items: ['Right Femur', 'Knee Joint', 'Left Tibia', 'Right Humerus'].map((l) {
                      return DropdownMenuItem(value: l, child: Text(l, style: const TextStyle(fontSize: 12)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) limbNotifier.value = val;
                    },
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Visual Simulation of Bone Truncation / Distal Wireframe Fade & Stump Contour
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 130,
              width: double.infinity,
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              child: ValueListenableBuilder<bool>(
                valueListenable: enableCutPlaneNotifier,
                builder: (context, hasCut, _) {
                  return ValueListenableBuilder<double>(
                    valueListenable: cutPlaneYNotifier,
                    builder: (context, cutY, _) {
                      return ValueListenableBuilder<bool>(
                        valueListenable: wireframeFadeNotifier,
                        builder: (context, fadeDistal, _) {
                          return ValueListenableBuilder<double>(
                            valueListenable: goniometerAngleNotifier,
                            builder: (context, angle, _) {
                              return CustomPaint(
                                painter: _SkeletalCutPlanePainter(
                                  hasCut: hasCut,
                                  cutYRatio: cutY,
                                  fadeDistal: fadeDistal,
                                  angleDegrees: angle,
                                  isDark: isDark,
                                ),
                                child: Stack(
                                  children: [
                                    if (hasCut)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Cut-Plane Level: ${(cutY * 100).toStringAsFixed(0)}% Diaphysis',
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
                                          ),
                                        ),
                                      ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          'Goniometer: ${angle.toStringAsFixed(0)}Â°',
                                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber),
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
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Cut-Plane Controls
          Row(
            children: [
              ValueListenableBuilder<bool>(
                valueListenable: enableCutPlaneNotifier,
                builder: (context, hasCut, _) {
                  return FilterChip(
                    label: const Text('Enable Cut-Plane'),
                    selected: hasCut,
                    selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    onSelected: (val) => enableCutPlaneNotifier.value = val,
                  );
                },
              ),
              const SizedBox(width: 8),
              ValueListenableBuilder<bool>(
                valueListenable: wireframeFadeNotifier,
                builder: (context, fade, _) {
                  return FilterChip(
                    label: const Text('Fade Distal Wireframe'),
                    selected: fade,
                    selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                    onSelected: (val) => wireframeFadeNotifier.value = val,
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Cut-Plane Level Slider
          ValueListenableBuilder<double>(
            valueListenable: cutPlaneYNotifier,
            builder: (context, cutY, _) {
              return Row(
                children: [
                  const Text('Cut Level:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: cutY,
                      min: 0.2,
                      max: 0.85,
                      divisions: 13,
                      activeColor: const Color(0xFF8B5CF6),
                      label: '${(cutY * 100).toStringAsFixed(0)}%',
                      onChanged: (val) => cutPlaneYNotifier.value = val,
                    ),
                  ),
                  Text('${(cutY * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                ],
              );
            },
          ),

          // Goniometer Joint Angle Slider (0° to 180°)
          ValueListenableBuilder<double>(
            valueListenable: goniometerAngleNotifier,
            builder: (context, angle, _) {
              return Row(
                children: [
                  const Text('ROM Angle:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Slider(
                      value: angle,
                      min: 0,
                      max: 180,
                      divisions: 36,
                      activeColor: Colors.amber,
                      label: '${angle.toStringAsFixed(0)}Â°',
                      onChanged: (val) => goniometerAngleNotifier.value = val,
                    ),
                  ),
                  Text('${angle.toStringAsFixed(0)}Â°', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Billing Preview
          ValueListenableBuilder<bool>(
            valueListenable: enableCutPlaneNotifier,
            builder: (context, hasCut, _) {
              return ValueListenableBuilder<double>(
                valueListenable: goniometerAngleNotifier,
                builder: (context, angle, _) {
                  final annotation = OrthopedicsCutPlaneGoniometerAnnotation(
                    targetLimbOrJoint: limbNotifier.value,
                    cutPlane: hasCut
                        ? CutPlaneAnnotation(
                            startNormalized: Offset(0.2, cutPlaneYNotifier.value),
                            endNormalized: Offset(0.8, cutPlaneYNotifier.value),
                            angleRadians: 0,
                            label: 'Osteotomy / Amputation Line',
                          )
                        : null,
                    fadeDistalToWireframe: wireframeFadeNotifier.value,
                    goniometerAngleDegrees: angle,
                    jointMotionType: motionTypeNotifier.value,
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
                                  'Orthopedic Cart Binding (${items.length} item${items.length == 1 ? "" : "s"})',
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
          ),
          const SizedBox(height: 12),

          // Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.check, size: 16),
              label: const Text('Apply Osteotomy & Goniometry to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                final annotation = OrthopedicsCutPlaneGoniometerAnnotation(
                  targetLimbOrJoint: limbNotifier.value,
                  cutPlane: enableCutPlaneNotifier.value
                      ? CutPlaneAnnotation(
                          startNormalized: Offset(0.2, cutPlaneYNotifier.value),
                          endNormalized: Offset(0.8, cutPlaneYNotifier.value),
                          angleRadians: 0,
                          label: 'Osteotomy / Amputation Line',
                        )
                      : null,
                  fadeDistalToWireframe: wireframeFadeNotifier.value,
                  goniometerAngleDegrees: goniometerAngleNotifier.value,
                  jointMotionType: motionTypeNotifier.value,
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
}

class _SkeletalCutPlanePainter extends CustomPainter {
  final bool hasCut;
  final double cutYRatio;
  final bool fadeDistal;
  final double angleDegrees;
  final bool isDark;

  _SkeletalCutPlanePainter({
    required this.hasCut,
    required this.cutYRatio,
    required this.fadeDistal,
    required this.angleDegrees,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boneX = size.width * 0.35;
    final boneW = size.width * 0.15;
    final cutY = size.height * cutYRatio;

    // 1. Proximal Bone Segment (Solid)
    final proximalPaint = Paint()
      ..color = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF64748B)
      ..style = PaintingStyle.fill;

    final proximalRect = Rect.fromLTWH(boneX, 10, boneW, hasCut ? (cutY - 10) : (size.height - 20));
    canvas.drawRRect(RRect.fromRectAndRadius(proximalRect, const Radius.circular(6)), proximalPaint);

    if (hasCut) {
      // 2. Stump Contour Highlight (Warning glow on the preserved margin)
      final stumpPaint = Paint()
        ..color = const Color(0xFF8B5CF6)
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(boneX - 4, cutY), Offset(boneX + boneW + 4, cutY), stumpPaint);

      // 3. Distal Bone Segment (Wireframe / Translucent Fade)
      final distalPaint = Paint()
        ..color = fadeDistal ? const Color(0xFF8B5CF6).withValues(alpha: 0.3) : const Color(0xFF94A3B8)
        ..strokeWidth = 1.5
        ..style = fadeDistal ? PaintingStyle.stroke : PaintingStyle.fill;

      final distalRect = Rect.fromLTWH(boneX, cutY + 4, boneW, (size.height - cutY - 14));
      canvas.drawRRect(RRect.fromRectAndRadius(distalRect, const Radius.circular(6)), distalPaint);

      // Cross-hatch wireframe grid on distal portion
      if (fadeDistal) {
        for (double y = cutY + 12; y < size.height - 14; y += 10) {
          canvas.drawLine(Offset(boneX, y), Offset(boneX + boneW, y), distalPaint);
        }
      }
    }

    // 4. Goniometer Dual-Arm Angle Visualizer on the right side
    final gonioCenter = Offset(size.width * 0.75, size.height * 0.55);
    final armLen = 40.0;
    final gonioPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Stationary Arm (Horizontal)
    canvas.drawLine(gonioCenter, Offset(gonioCenter.dx + armLen, gonioCenter.dy), gonioPaint);

    // Dynamic Rotating Arm based on angleDegrees
    final rad = -angleDegrees * pi / 180.0;
    final endX = gonioCenter.dx + armLen * cos(rad);
    final endY = gonioCenter.dy + armLen * sin(rad);
    canvas.drawLine(gonioCenter, Offset(endX, endY), gonioPaint);

    // Goniometer Hub Pivot
    final hubPaint = Paint()..color = Colors.orangeAccent;
    canvas.drawCircle(gonioCenter, 4.5, hubPaint);
  }

  @override
  bool shouldRepaint(covariant _SkeletalCutPlanePainter old) => true;
}
