import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/anatomical_annotation_models.dart';

/// Cardiology & Vascular Stenosis Caliper & Stent Spline Tool.
/// 100% [StatelessWidget] architecture.
class CardiologyVascularActionWidget extends StatelessWidget {
  final ValueNotifier<String> vesselNotifier;
  final ValueNotifier<double> stenosisNotifier;
  final ValueNotifier<VascularInterventionType> interventionNotifier;
  final ValueNotifier<List<Offset>> splinePointsNotifier;
  final void Function(CardiologyVascularAnnotation annotation, List<ProcedureItem> billingItems)? onApply;

  CardiologyVascularActionWidget({
    super.key,
    ValueNotifier<String>? vesselNotifier,
    ValueNotifier<double>? stenosisNotifier,
    ValueNotifier<VascularInterventionType>? interventionNotifier,
    ValueNotifier<List<Offset>>? splinePointsNotifier,
    this.onApply,
  })  : vesselNotifier = vesselNotifier ?? ValueNotifier<String>('LAD'),
        stenosisNotifier = stenosisNotifier ?? ValueNotifier<double>(75.0),
        interventionNotifier = interventionNotifier ?? ValueNotifier<VascularInterventionType>(VascularInterventionType.drugElutingStent),
        splinePointsNotifier = splinePointsNotifier ??
            ValueNotifier<List<Offset>>([
              const Offset(0.2, 0.5),
              const Offset(0.5, 0.5),
              const Offset(0.8, 0.5),
            ]);

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
                  const Icon(LucideIcons.activity, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Coronary Caliper & Stent Spline',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              // Vessel Picker
              ValueListenableBuilder<String>(
                valueListenable: vesselNotifier,
                builder: (context, vessel, _) {
                  return Row(
                    children: ['LAD', 'RCA', 'LCx'].map((v) {
                      final active = v == vessel;
                      return Padding(
                        padding: const EdgeInsets.only(left: 4),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(4),
                          onTap: () => vesselNotifier.value = v,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: active ? Colors.redAccent : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              v,
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
          const SizedBox(height: 14),

          // Stenosis Occlusion Caliper Slider (10% to 100%)
          ValueListenableBuilder<double>(
            valueListenable: stenosisNotifier,
            builder: (context, stenosis, _) {
              final isCritical = stenosis >= 70.0;
              final statusColor = stenosis < 50
                  ? const Color(0xFF10B981)
                  : (stenosis < 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Stenosis Caliper: ${stenosis.toStringAsFixed(0)}% Occlusion',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isCritical ? 'CRITICAL ISCHEMIA (â‰¥70%)' : (stenosis >= 50 ? 'SIGNIFICANT LESION' : 'MILD / NON-SIGNIFICANT'),
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10.5, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: stenosis,
                    min: 10,
                    max: 100,
                    divisions: 18,
                    activeColor: statusColor,
                    label: '${stenosis.toStringAsFixed(0)}%',
                    onChanged: (val) => stenosisNotifier.value = val,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),

          // Intervention Selector
          ValueListenableBuilder<VascularInterventionType>(
            valueListenable: interventionNotifier,
            builder: (context, intervention, _) {
              return Row(
                children: [
                  Expanded(
                    child: _buildInterventionChip(
                      label: 'Drug-Eluting Stent',
                      type: VascularInterventionType.drugElutingStent,
                      selected: intervention == VascularInterventionType.drugElutingStent,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInterventionChip(
                      label: 'Bypass Spline (CABG)',
                      type: VascularInterventionType.bypassGraftSpline,
                      selected: intervention == VascularInterventionType.bypassGraftSpline,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInterventionChip(
                      label: 'PTCA Balloon',
                      type: VascularInterventionType.balloonAngioplasty,
                      selected: intervention == VascularInterventionType.balloonAngioplasty,
                      isDark: isDark,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // Interactive Vascular Diagram & Spline Canvas
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 110,
              width: double.infinity,
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              child: ValueListenableBuilder<List<Offset>>(
                valueListenable: splinePointsNotifier,
                builder: (context, points, _) {
                  return GestureDetector(
                    onPanDown: (details) {
                      final box = context.findRenderObject() as RenderBox?;
                      if (box != null) {
                        final local = box.globalToLocal(details.globalPosition);
                        final norm = Offset(
                          (local.dx / box.size.width).clamp(0.05, 0.95),
                          (local.dy / box.size.height).clamp(0.05, 0.95),
                        );
                        splinePointsNotifier.value = [...points, norm];
                      }
                    },
                    child: CustomPaint(
                      painter: _VascularSplinePainter(
                        points: points,
                        stenosisPct: stenosisNotifier.value,
                        intervention: interventionNotifier.value,
                        isDark: isDark,
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 6,
                            left: 8,
                            child: Text(
                              'Vessel Axis: ${vesselNotifier.value} • Spline Nodes: ${points.length}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            bottom: 6,
                            right: 8,
                            child: TextButton.icon(
                              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                              icon: const Icon(LucideIcons.rotateCcw, size: 12),
                              label: const Text('Reset Spline', style: TextStyle(fontSize: 10)),
                              onPressed: () => splinePointsNotifier.value = [
                                const Offset(0.2, 0.5),
                                const Offset(0.5, 0.5),
                                const Offset(0.8, 0.5),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Billing Preview
          ValueListenableBuilder<double>(
            valueListenable: stenosisNotifier,
            builder: (context, stenosis, _) {
              return ValueListenableBuilder<VascularInterventionType>(
                valueListenable: interventionNotifier,
                builder: (context, intervention, _) {
                  final annotation = CardiologyVascularAnnotation(
                    vesselName: vesselNotifier.value,
                    stenosisPercentage: stenosis,
                    interventionType: intervention,
                    splineControlPoints: splinePointsNotifier.value,
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
                                  'Vascular Billing Binding (${items.length} item${items.length == 1 ? "" : "s"})',
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
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(LucideIcons.check, size: 16),
              label: const Text('Apply Vascular Caliper & Stent to Cart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              onPressed: () {
                final annotation = CardiologyVascularAnnotation(
                  vesselName: vesselNotifier.value,
                  stenosisPercentage: stenosisNotifier.value,
                  interventionType: interventionNotifier.value,
                  splineControlPoints: splinePointsNotifier.value,
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

  Widget _buildInterventionChip({
    required String label,
    required VascularInterventionType type,
    required bool selected,
    required bool isDark,
  }) {
    return InkWell(
      onTap: () => interventionNotifier.value = type,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? Colors.redAccent.withValues(alpha: 0.2)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? Colors.redAccent : (isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.redAccent : null,
          ),
        ),
      ),
    );
  }
}

class _VascularSplinePainter extends CustomPainter {
  final List<Offset> points;
  final double stenosisPct;
  final VascularInterventionType intervention;
  final bool isDark;

  _VascularSplinePainter({
    required this.points,
    required this.stenosisPct,
    required this.intervention,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw Vessel Lumen
    final vesselPaint = Paint()
      ..color = Colors.red.withValues(alpha: isDark ? 0.3 : 0.2)
      ..strokeWidth = 24
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(size.width * 0.05, size.height * 0.5);
    path.cubicTo(
      size.width * 0.35,
      size.height * 0.2,
      size.width * 0.65,
      size.height * 0.8,
      size.width * 0.95,
      size.height * 0.5,
    );
    canvas.drawPath(path, vesselPaint);

    // 2. Draw Stenosis Pinch
    final pinchPaint = Paint()
      ..color = Colors.amber
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final midX = size.width * 0.5;
    final midY = size.height * 0.5;
    final pinchRadius = 14.0 * (1.0 - (stenosisPct / 100.0) * 0.7);
    canvas.drawCircle(Offset(midX, midY), pinchRadius, pinchPaint);

    // 3. Draw Stent / Spline Control Nodes
    final nodePaint = Paint()
      ..color = intervention == VascularInterventionType.bypassGraftSpline ? const Color(0xFF3B82F6) : Colors.cyanAccent
      ..style = PaintingStyle.fill;

    for (final p in points) {
      final actual = Offset(p.dx * size.width, p.dy * size.height);
      canvas.drawCircle(actual, 4, nodePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _VascularSplinePainter old) => true;
}
