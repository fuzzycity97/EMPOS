import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/tooth_chart_entry.dart';

/// Interactive 3D Realistic Odontogram Canvas Widget.
/// Uses pure Flutter 3D vector geometry & multi-faceted anatomical polygons
/// (Incisor blade, Canine cusp & cingulum, Premolar bicuspid, Molar quad-cusp + bifurcated roots)
/// with dynamic orbit, zoom/pan, camera presets, selection highlights, and clinical status shading.
/// 100% [StatelessWidget] following Clean Architecture.
class DentalTooth3dCanvasWidget extends StatelessWidget {
  final List<ToothChartEntry> toothChart;
  final bool isPediatric;
  final ToothChartEntry? selectedTooth;
  final void Function(ToothChartEntry entry) onToothSelected;

  const DentalTooth3dCanvasWidget({
    super.key,
    required this.toothChart,
    this.isPediatric = false,
    this.selectedTooth,
    required this.onToothSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // ValueNotifiers for 100% StatelessWidget gesture responsiveness
    final rotX = ValueNotifier<double>(0.35); // Pitch
    final rotY = ValueNotifier<double>(0.0); // Yaw
    final scale = ValueNotifier<double>(1.1); // Zoom
    final panOffset = ValueNotifier<Offset>(Offset.zero);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090D16) : const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 1. Interactive 3D Canvas
            Positioned.fill(
              child: GestureDetector(
                onScaleStart: (_) {},
                onScaleUpdate: (details) {
                  if (details.pointerCount == 1) {
                    // 1-finger drag: 3D orbital rotation
                    rotY.value += details.focalPointDelta.dx * 0.012;
                    rotX.value = (rotX.value - details.focalPointDelta.dy * 0.012)
                        .clamp(-1.2, 1.2);
                  } else {
                    // 2-finger pinch/drag: zoom and pan
                    scale.value = (scale.value * details.scale).clamp(0.6, 2.5);
                    panOffset.value += details.focalPointDelta;
                  }
                },
                onTapUp: (details) {
                  // Hit-test click in 3D space
                  final size = context.size ?? const Size(400, 350);
                  final hit = _hitTestTooth(
                    details.localPosition,
                    size,
                    rotX.value,
                    rotY.value,
                    scale.value,
                    panOffset.value,
                  );
                  if (hit != null) {
                    onToothSelected(hit);
                  }
                },
                child: AnimatedBuilder(
                  animation: Listenable.merge([rotX, rotY, scale, panOffset]),
                  builder: (context, _) {
                    return CustomPaint(
                      painter: _Tooth3dPainter(
                        toothChart: toothChart,
                        isPediatric: isPediatric,
                        selectedToothCode: selectedTooth?.effectiveToothCode,
                        rotX: rotX.value,
                        rotY: rotY.value,
                        scale: scale.value,
                        pan: panOffset.value,
                        isDark: isDark,
                      ),
                    );
                  },
                ),
              ),
            ),

            // 2. Camera Controls & View Presets (Top Left Dock)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _PresetButton(
                      label: 'Front 3D',
                      icon: Icons.view_in_ar,
                      onTap: () {
                        rotX.value = 0.35;
                        rotY.value = 0.0;
                        scale.value = 1.1;
                        panOffset.value = Offset.zero;
                      },
                    ),
                    const SizedBox(width: 4),
                    _PresetButton(
                      label: 'Upper Arch',
                      icon: Icons.arrow_upward,
                      onTap: () {
                        rotX.value = 1.15;
                        rotY.value = 0.0;
                        scale.value = 1.15;
                        panOffset.value = const Offset(0, 30);
                      },
                    ),
                    const SizedBox(width: 4),
                    _PresetButton(
                      label: 'Lower Arch',
                      icon: Icons.arrow_downward,
                      onTap: () {
                        rotX.value = -1.15;
                        rotY.value = 0.0;
                        scale.value = 1.15;
                        panOffset.value = const Offset(0, -30);
                      },
                    ),
                    const SizedBox(width: 4),
                    _PresetButton(
                      label: 'Right Sagittal',
                      icon: Icons.rotate_right,
                      onTap: () {
                        rotX.value = 0.15;
                        rotY.value = math.pi / 2;
                        scale.value = 1.05;
                        panOffset.value = Offset.zero;
                      },
                    ),
                    const SizedBox(width: 4),
                    _PresetButton(
                      label: 'Left Sagittal',
                      icon: Icons.rotate_left,
                      onTap: () {
                        rotX.value = 0.15;
                        rotY.value = -math.pi / 2;
                        scale.value = 1.05;
                        panOffset.value = Offset.zero;
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 3. Status Legend / Shading Key (Bottom Left)
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _LegendItem(color: Color(0xFF10B981), label: 'Healthy'),
                    _LegendItem(color: Color(0xFFEF4444), label: 'Caries'),
                    _LegendItem(color: Color(0xFF3B82F6), label: 'Filled'),
                    _LegendItem(color: Color(0xFFF59E0B), label: 'Crown'),
                    _LegendItem(color: Color(0xFFF97316), label: 'RCT'),
                    _LegendItem(color: Color(0xFF64748B), label: 'Missing'),
                    _LegendItem(color: Color(0xFF8B5CF6), label: 'Implant'),
                  ],
                ),
              ),
            ),

            // 4. Instructions & Selected Tooth Hint (Top Right)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: selectedTooth != null
                      ? Colors.blueAccent.withValues(alpha: 0.25)
                      : Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: selectedTooth != null
                        ? Colors.blueAccent
                        : Colors.white10,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selectedTooth != null ? Icons.check_circle : Icons.touch_app,
                      size: 14,
                      color: selectedTooth != null ? Colors.blueAccent : Colors.white70,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      selectedTooth != null
                          ? 'Tooth FDI ${selectedTooth!.fdiNumber} (Univ #${selectedTooth!.effectiveToothCode})'
                          : 'Tap tooth to inspect / Drag to rotate 3D',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: selectedTooth != null ? FontWeight.bold : FontWeight.normal,
                        color: selectedTooth != null ? Colors.white : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  ToothChartEntry? _hitTestTooth(
    Offset tapPos,
    Size size,
    double rx,
    double ry,
    double s,
    Offset pan,
  ) {
    final center = Offset(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    final coords = _generate3dTeethPositions(isPediatric);

    ToothChartEntry? closestTooth;
    double minDistance = 28.0 * s;

    for (final t in coords) {
      final p3d = _rotatePoint(t.x, t.y, t.z, rx, ry);
      final distance = 400.0;
      final fov = distance / (distance - p3d.z);
      final screenX = center.dx + p3d.x * s * fov;
      final screenY = center.dy + p3d.y * s * fov;

      final dist = (Offset(screenX, screenY) - tapPos).distance;
      if (dist < minDistance) {
        minDistance = dist;
        closestTooth = _findEntry(t.code);
      }
    }

    return closestTooth;
  }

  ToothChartEntry _findEntry(String code) {
    for (final t in toothChart) {
      if (t.effectiveToothCode.toUpperCase() == code.toUpperCase()) {
        return t;
      }
    }
    return ToothChartEntry(
      toothNumber: int.tryParse(code) ?? 1,
      toothCode: code,
      isDeciduous: isPediatric,
    );
  }

  static List<_Tooth3dCoord> _generate3dTeethPositions(bool isPediatric) {
    final list = <_Tooth3dCoord>[];

    if (isPediatric) {
      // 10 Upper Primary Teeth (A-J): FDI 55..51, 61..65
      final upperCodes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
      for (int i = 0; i < upperCodes.length; i++) {
        final angle = -math.pi * 0.75 + (i / (upperCodes.length - 1)) * (math.pi * 1.5);
        final r = 75.0;
        final x = r * math.sin(angle);
        final z = r * (1.0 - math.cos(angle)) * 0.7;
        final y = -36.0;
        list.add(_Tooth3dCoord(code: upperCodes[i], x: x, y: y, z: z, isUpper: true));
      }

      // 10 Lower Primary Teeth (T-K): FDI 85..81, 71..75
      final lowerCodes = ['T', 'S', 'R', 'Q', 'P', 'O', 'N', 'M', 'L', 'K'];
      for (int i = 0; i < lowerCodes.length; i++) {
        final angle = -math.pi * 0.75 + (i / (lowerCodes.length - 1)) * (math.pi * 1.5);
        final r = 70.0;
        final x = r * math.sin(angle);
        final z = r * (1.0 - math.cos(angle)) * 0.7;
        final y = 36.0;
        list.add(_Tooth3dCoord(code: lowerCodes[i], x: x, y: y, z: z, isUpper: false));
      }
    } else {
      // 16 Upper Adult Teeth (1-16): FDI 18..11, 21..28
      final upperCodes = List.generate(16, (i) => (i + 1).toString());
      for (int i = 0; i < upperCodes.length; i++) {
        final angle = -math.pi * 0.82 + (i / (upperCodes.length - 1)) * (math.pi * 1.64);
        final r = 100.0;
        final x = r * math.sin(angle);
        final z = r * (1.0 - math.cos(angle)) * 0.8;
        final y = -40.0;
        list.add(_Tooth3dCoord(code: upperCodes[i], x: x, y: y, z: z, isUpper: true));
      }

      // 16 Lower Adult Teeth (32-17): FDI 48..41, 31..38
      final lowerCodes = List.generate(16, (i) => (32 - i).toString());
      for (int i = 0; i < lowerCodes.length; i++) {
        final angle = -math.pi * 0.82 + (i / (lowerCodes.length - 1)) * (math.pi * 1.64);
        final r = 94.0;
        final x = r * math.sin(angle);
        final z = r * (1.0 - math.cos(angle)) * 0.8;
        final y = 40.0;
        list.add(_Tooth3dCoord(code: lowerCodes[i], x: x, y: y, z: z, isUpper: false));
      }
    }

    return list;
  }

  static _Point3d _rotatePoint(double x, double y, double z, double rx, double ry) {
    final cosY = math.cos(ry);
    final sinY = math.sin(ry);
    final x1 = x * cosY + z * sinY;
    final z1 = -x * sinY + z * cosY;

    final cosX = math.cos(rx);
    final sinX = math.sin(rx);
    final y2 = y * cosX - z1 * sinX;
    final z2 = y * sinX + z1 * cosX;

    return _Point3d(x1, y2, z2);
  }
}

class _Point3d {
  final double x;
  final double y;
  final double z;
  const _Point3d(this.x, this.y, this.z);
}

class _Tooth3dCoord {
  final String code;
  final double x;
  final double y;
  final double z;
  final bool isUpper;

  const _Tooth3dCoord({
    required this.code,
    required this.x,
    required this.y,
    required this.z,
    required this.isUpper,
  });
}

class _PresetButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _PresetButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: Colors.blueAccent),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 9.5, color: Colors.white70),
        ),
      ],
    );
  }
}

class _Tooth3dPainter extends CustomPainter {
  final List<ToothChartEntry> toothChart;
  final bool isPediatric;
  final String? selectedToothCode;
  final double rotX;
  final double rotY;
  final double scale;
  final Offset pan;
  final bool isDark;

  _Tooth3dPainter({
    required this.toothChart,
    required this.isPediatric,
    this.selectedToothCode,
    required this.rotX,
    required this.rotY,
    required this.scale,
    required this.pan,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + pan.dx, size.height / 2 + pan.dy);

    _drawGridBackground(canvas, size, center);

    final coords = DentalTooth3dCanvasWidget._generate3dTeethPositions(isPediatric);
    final renderList = <_RenderTooth>[];

    for (final coord in coords) {
      final p3d = DentalTooth3dCanvasWidget._rotatePoint(
        coord.x,
        coord.y,
        coord.z,
        rotX,
        rotY,
      );

      final distance = 450.0;
      final fov = distance / (distance - p3d.z);
      final screenX = center.dx + p3d.x * scale * fov;
      final screenY = center.dy + p3d.y * scale * fov;

      final entry = _findEntry(coord.code);
      final isSelected = selectedToothCode != null &&
          selectedToothCode!.toUpperCase() == coord.code.toUpperCase();

      renderList.add(
        _RenderTooth(
          entry: entry,
          screenPos: Offset(screenX, screenY),
          depthZ: p3d.z,
          scaleFactor: fov * scale,
          isUpper: coord.isUpper,
          isSelected: isSelected,
        ),
      );
    }

    // Depth sort (Painter's algorithm: back to front)
    renderList.sort((a, b) => a.depthZ.compareTo(b.depthZ));

    _drawArchBridges(canvas, renderList);

    for (final item in renderList) {
      _drawRealisticAnatomicalTooth(canvas, item);
    }
  }

  void _drawGridBackground(Canvas canvas, Size size, Offset center) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final axisPaint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, 90 * scale, axisPaint);
  }

  void _drawArchBridges(Canvas canvas, List<_RenderTooth> teeth) {
    final archPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final uppers = teeth.where((t) => t.isUpper).toList()
      ..sort((a, b) => a.screenPos.dx.compareTo(b.screenPos.dx));
    if (uppers.length > 1) {
      final path = Path()..moveTo(uppers.first.screenPos.dx, uppers.first.screenPos.dy);
      for (int i = 1; i < uppers.length; i++) {
        path.lineTo(uppers[i].screenPos.dx, uppers[i].screenPos.dy);
      }
      canvas.drawPath(path, archPaint);
    }

    final lowers = teeth.where((t) => !t.isUpper).toList()
      ..sort((a, b) => a.screenPos.dx.compareTo(b.screenPos.dx));
    if (lowers.length > 1) {
      final path = Path()..moveTo(lowers.first.screenPos.dx, lowers.first.screenPos.dy);
      for (int i = 1; i < lowers.length; i++) {
        path.lineTo(lowers[i].screenPos.dx, lowers[i].screenPos.dy);
      }
      canvas.drawPath(path, archPaint);
    }
  }

  void _drawRealisticAnatomicalTooth(Canvas canvas, _RenderTooth item) {
    final pos = item.screenPos;
    final sf = item.scaleFactor.clamp(0.5, 2.2);
    final stateColor = _getStateColor(item.entry.state);
    final isMissing = item.entry.state == ToothState.missing ||
        item.entry.state == ToothState.extracted;
    final cat = item.entry.category;

    // 1. Selection Glow & Ring
    if (item.isSelected) {
      final selGlow = Paint()
        ..color = Colors.blueAccent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(pos, 24 * sf, selGlow);

      final selRing = Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, 22 * sf, selRing);
    }

    // 2. Anatomical Dimensions according to Tooth Morphology
    double crownW;
    double crownH;
    double rootLen;
    switch (cat) {
      case ToothCategory.molar:
        crownW = 28.0 * sf;
        crownH = 22.0 * sf;
        rootLen = 22.0 * sf;
        break;
      case ToothCategory.premolar:
        crownW = 22.0 * sf;
        crownH = 20.0 * sf;
        rootLen = 20.0 * sf;
        break;
      case ToothCategory.canine:
        crownW = 18.0 * sf;
        crownH = 24.0 * sf;
        rootLen = 26.0 * sf;
        break;
      case ToothCategory.incisor:
        crownW = 19.0 * sf;
        crownH = 22.0 * sf;
        rootLen = 22.0 * sf;
        break;
    }

    final rootDir = item.isUpper ? -1.0 : 1.0;

    // 3. Draw Anatomically Accurate Roots
    if (!isMissing) {
      _drawAnatomicalRoots(canvas, pos, crownW, rootLen, rootDir, cat, stateColor);
    }

    // 4. Draw Anatomically Formed Crown (Enamel + Morphological Facets)
    _drawAnatomicalCrown(canvas, pos, crownW, crownH, rootDir, cat, stateColor, isMissing);

    // 5. Draw Occlusal Morphological Grooves, Pit, & Clinical Decals
    if (!isMissing) {
      _drawMorphologyDetails(canvas, pos, crownW, crownH, cat, item.entry.state, sf);
    }

    // 6. FDI & Universal Number Label
    final labelText = item.entry.fdiNumber;
    final textPainter = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          fontSize: (10.0 * sf).clamp(8.0, 14.0),
          fontWeight: FontWeight.bold,
          color: item.isSelected ? Colors.blueAccent : Colors.white,
          shadows: const [
            Shadow(color: Colors.black, blurRadius: 4),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelY = item.isUpper
        ? pos.dy - (crownH / 2) - (rootLen * 0.8) - textPainter.height - 2
        : pos.dy + (crownH / 2) + (rootLen * 0.8) + 2;

    textPainter.paint(canvas, Offset(pos.dx - textPainter.width / 2, labelY));

    // 7. Periodontal Pocket Depth Indicator if pathological (> 3mm)
    if (item.entry.pocketDepthMm > 3) {
      final pColor = item.entry.pocketDepthMm >= 6 ? Colors.red : Colors.amber;
      final pocketBadge = Paint()..color = pColor;
      canvas.drawCircle(Offset(pos.dx + crownW * 0.55, pos.dy - crownH * 0.4), 4.5 * sf, pocketBadge);
    }
  }

  void _drawAnatomicalRoots(
    Canvas canvas,
    Offset pos,
    double crownW,
    double rootLen,
    double dir,
    ToothCategory cat,
    Color stateColor,
  ) {
    final rootPaint = Paint()
      ..color = const Color(0xFFD6C7A1).withValues(alpha: 0.85) // Natural dentin/cementum tone
      ..style = PaintingStyle.fill;

    final rootShade = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final rootPath = Path();

    if (cat == ToothCategory.molar) {
      // Multi-rooted anatomy: Mesial and Distal bifurcated curved roots
      final rY = pos.dy + (rootLen * dir);
      final baseY = pos.dy;

      // Root 1 (Mesial)
      rootPath.moveTo(pos.dx - crownW * 0.4, baseY);
      rootPath.quadraticBezierTo(pos.dx - crownW * 0.6, baseY + (rootLen * 0.6 * dir), pos.dx - crownW * 0.35, rY);
      rootPath.quadraticBezierTo(pos.dx - crownW * 0.25, baseY + (rootLen * 0.5 * dir), pos.dx - crownW * 0.1, baseY);

      // Root 2 (Distal)
      rootPath.moveTo(pos.dx + crownW * 0.1, baseY);
      rootPath.quadraticBezierTo(pos.dx + crownW * 0.25, baseY + (rootLen * 0.5 * dir), pos.dx + crownW * 0.35, rY);
      rootPath.quadraticBezierTo(pos.dx + crownW * 0.6, baseY + (rootLen * 0.6 * dir), pos.dx + crownW * 0.4, baseY);
    } else if (cat == ToothCategory.premolar) {
      // Tapered single root with bifurcated apex hint
      final rY = pos.dy + (rootLen * dir);
      final baseY = pos.dy;
      rootPath.moveTo(pos.dx - crownW * 0.35, baseY);
      rootPath.quadraticBezierTo(pos.dx - crownW * 0.2, baseY + (rootLen * 0.6 * dir), pos.dx, rY);
      rootPath.quadraticBezierTo(pos.dx + crownW * 0.2, baseY + (rootLen * 0.6 * dir), pos.dx + crownW * 0.35, baseY);
    } else {
      // Long robust single root (Incisor / Canine)
      final rY = pos.dy + (rootLen * dir);
      final baseY = pos.dy;
      rootPath.moveTo(pos.dx - crownW * 0.3, baseY);
      rootPath.quadraticBezierTo(pos.dx - crownW * 0.15, baseY + (rootLen * 0.5 * dir), pos.dx, rY);
      rootPath.quadraticBezierTo(pos.dx + crownW * 0.15, baseY + (rootLen * 0.5 * dir), pos.dx + crownW * 0.3, baseY);
    }
    rootPath.close();

    canvas.drawPath(rootPath, rootPaint);
    canvas.drawPath(rootPath, rootShade);
  }

  void _drawAnatomicalCrown(
    Canvas canvas,
    Offset pos,
    double w,
    double h,
    double dir,
    ToothCategory cat,
    Color stateColor,
    bool isMissing,
  ) {
    final crownPath = Path();
    final halfW = w / 2;
    final halfH = h / 2;

    if (cat == ToothCategory.molar) {
      // Quad-cuspal rectangular / rhomboid rounded morphology with defined line angles
      crownPath.moveTo(pos.dx - halfW * 0.9, pos.dy - halfH * 0.7);
      // Buccal cusps
      crownPath.quadraticBezierTo(pos.dx - halfW * 0.5, pos.dy - halfH, pos.dx, pos.dy - halfH * 0.85);
      crownPath.quadraticBezierTo(pos.dx + halfW * 0.5, pos.dy - halfH, pos.dx + halfW * 0.9, pos.dy - halfH * 0.7);
      // Distal curve
      crownPath.quadraticBezierTo(pos.dx + halfW * 1.05, pos.dy, pos.dx + halfW * 0.9, pos.dy + halfH * 0.7);
      // Lingual cusps
      crownPath.quadraticBezierTo(pos.dx + halfW * 0.5, pos.dy + halfH, pos.dx, pos.dy + halfH * 0.85);
      crownPath.quadraticBezierTo(pos.dx - halfW * 0.5, pos.dy + halfH, pos.dx - halfW * 0.9, pos.dy + halfH * 0.7);
      // Mesial curve
      crownPath.quadraticBezierTo(pos.dx - halfW * 1.05, pos.dy, pos.dx - halfW * 0.9, pos.dy - halfH * 0.7);
    } else if (cat == ToothCategory.premolar) {
      // Oval bicuspid crown with buccal and lingual rounded lobes
      crownPath.moveTo(pos.dx - halfW * 0.85, pos.dy - halfH * 0.6);
      crownPath.quadraticBezierTo(pos.dx, pos.dy - halfH, pos.dx + halfW * 0.85, pos.dy - halfH * 0.6);
      crownPath.quadraticBezierTo(pos.dx + halfW, pos.dy, pos.dx + halfW * 0.85, pos.dy + halfH * 0.6);
      crownPath.quadraticBezierTo(pos.dx, pos.dy + halfH, pos.dx - halfW * 0.85, pos.dy + halfH * 0.6);
      crownPath.quadraticBezierTo(pos.dx - halfW, pos.dy, pos.dx - halfW * 0.85, pos.dy - halfH * 0.6);
    } else if (cat == ToothCategory.canine) {
      // Pointed diamond-shaped cusp with prominent labial ridge
      crownPath.moveTo(pos.dx, pos.dy - halfH * 1.05); // Sharp incisal cusp tip
      crownPath.lineTo(pos.dx + halfW * 0.9, pos.dy - halfH * 0.2);
      crownPath.quadraticBezierTo(pos.dx + halfW * 0.8, pos.dy + halfH * 0.8, pos.dx, pos.dy + halfH);
      crownPath.quadraticBezierTo(pos.dx - halfW * 0.8, pos.dy + halfH * 0.8, pos.dx - halfW * 0.9, pos.dy - halfH * 0.2);
    } else {
      // Incisor chisel-shaped crown with straight incisal edge & rounded cervical margin
      crownPath.moveTo(pos.dx - halfW * 0.95, pos.dy - halfH * 0.85);
      crownPath.lineTo(pos.dx + halfW * 0.95, pos.dy - halfH * 0.85); // Straight incisal edge
      crownPath.quadraticBezierTo(pos.dx + halfW * 0.9, pos.dy, pos.dx + halfW * 0.7, pos.dy + halfH * 0.9);
      crownPath.quadraticBezierTo(pos.dx, pos.dy + halfH, pos.dx - halfW * 0.7, pos.dy + halfH * 0.9);
      crownPath.quadraticBezierTo(pos.dx - halfW * 0.9, pos.dy, pos.dx - halfW * 0.95, pos.dy - halfH * 0.85);
    }
    crownPath.close();

    if (!isMissing) {
      // Enamel Specular 3D Gradient Shading
      final bounds = crownPath.getBounds();
      final gradient = RadialGradient(
        center: const Alignment(-0.35, -0.45),
        radius: 0.9,
        colors: [
          const Color(0xFFFFFFFF), // Specular light highlight
          const Color(0xFFF1EFE7), // Natural translucent enamel
          stateColor.withValues(alpha: 0.45), // Diagnostic status tint overlay
          stateColor.withValues(alpha: 0.9), // Deep shadow edge
        ],
        stops: const [0.0, 0.45, 0.8, 1.0],
      );

      final paint = Paint()
        ..shader = gradient.createShader(bounds)
        ..style = PaintingStyle.fill;
      canvas.drawPath(crownPath, paint);

      // Outer anatomical rim line
      final rimPaint = Paint()
        ..color = stateColor.withValues(alpha: 0.8)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(crownPath, rimPaint);
    } else {
      // Dashed contour for missing / extracted tooth
      final dashPaint = Paint()
        ..color = stateColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawPath(crownPath, dashPaint);
    }
  }

  void _drawMorphologyDetails(
    Canvas canvas,
    Offset pos,
    double w,
    double h,
    ToothCategory cat,
    ToothState state,
    double sf,
  ) {
    final groovePaint = Paint()
      ..color = const Color(0xFF5C5543).withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    final halfW = w / 2;
    final halfH = h / 2;

    if (cat == ToothCategory.molar) {
      // Central fossa with cruciate fissure pattern (4 cusps: MB, ML, DB, DL)
      final p = Path();
      p.moveTo(pos.dx - halfW * 0.5, pos.dy);
      p.lineTo(pos.dx + halfW * 0.5, pos.dy);
      p.moveTo(pos.dx, pos.dy - halfH * 0.5);
      p.lineTo(pos.dx, pos.dy + halfH * 0.5);
      canvas.drawPath(p, groovePaint);
      // Central pit
      canvas.drawCircle(pos, 1.8 * sf, Paint()..color = const Color(0xFF5C5543));
    } else if (cat == ToothCategory.premolar) {
      // Central developmental groove separating buccal and lingual triangular ridges
      final p = Path();
      p.moveTo(pos.dx - halfW * 0.4, pos.dy);
      p.lineTo(pos.dx + halfW * 0.4, pos.dy);
      canvas.drawPath(p, groovePaint);
    } else if (cat == ToothCategory.canine) {
      // Prominent longitudinal labial ridge
      final p = Path();
      p.moveTo(pos.dx, pos.dy - halfH * 0.8);
      p.lineTo(pos.dx, pos.dy + halfH * 0.6);
      canvas.drawPath(p, groovePaint);
    } else if (cat == ToothCategory.incisor) {
      // Incisal developmental mamelon grooves
      canvas.drawLine(Offset(pos.dx - halfW * 0.3, pos.dy - halfH * 0.7), Offset(pos.dx - halfW * 0.3, pos.dy - halfH * 0.3), groovePaint);
      canvas.drawLine(Offset(pos.dx + halfW * 0.3, pos.dy - halfH * 0.7), Offset(pos.dx + halfW * 0.3, pos.dy - halfH * 0.3), groovePaint);
    }

    // Specific clinical procedure decals
    if (state == ToothState.crown) {
      final crownPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2;
      canvas.drawCircle(pos, halfW * 0.65, crownPaint);
    } else if (state == ToothState.rootCanal) {
      final endoPaint = Paint()
        ..color = const Color(0xFFF97316)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, 4.0 * sf, endoPaint);
    } else if (state == ToothState.implant) {
      final impPaint = Paint()
        ..color = const Color(0xFF8B5CF6)
        ..strokeWidth = 2.2;
      canvas.drawLine(Offset(pos.dx, pos.dy - halfH * 0.6), Offset(pos.dx, pos.dy + halfH * 0.6), impPaint);
      canvas.drawLine(Offset(pos.dx - halfW * 0.4, pos.dy), Offset(pos.dx + halfW * 0.4, pos.dy), impPaint);
    } else if (state == ToothState.fractured) {
      final crackPaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..strokeWidth = 2.0;
      final path = Path()
        ..moveTo(pos.dx - halfW * 0.5, pos.dy - halfH * 0.5)
        ..lineTo(pos.dx, pos.dy)
        ..lineTo(pos.dx + halfW * 0.5, pos.dy + halfH * 0.5);
      canvas.drawPath(path, crackPaint);
    }
  }

  ToothChartEntry _findEntry(String code) {
    for (final t in toothChart) {
      if (t.effectiveToothCode.toUpperCase() == code.toUpperCase()) {
        return t;
      }
    }
    return ToothChartEntry(
      toothNumber: int.tryParse(code) ?? 1,
      toothCode: code,
      isDeciduous: isPediatric,
    );
  }

  static Color _getStateColor(ToothState state) {
    switch (state) {
      case ToothState.healthy:
        return const Color(0xFF10B981);
      case ToothState.decayed:
        return const Color(0xFFEF4444);
      case ToothState.filled:
        return const Color(0xFF3B82F6);
      case ToothState.crown:
        return const Color(0xFFF59E0B);
      case ToothState.rootCanal:
        return const Color(0xFFF97316);
      case ToothState.missing:
        return const Color(0xFF64748B);
      case ToothState.extracted:
        return const Color(0xFF3F3F46);
      case ToothState.impacted:
        return const Color(0xFFE11D48);
      case ToothState.bridge:
        return const Color(0xFF06B6D4);
      case ToothState.implant:
        return const Color(0xFF8B5CF6);
      case ToothState.fractured:
        return const Color(0xFFDC2626);
      case ToothState.specialCase:
        return const Color(0xFF6366F1);
    }
  }

  @override
  bool shouldRepaint(covariant _Tooth3dPainter oldDelegate) {
    return oldDelegate.rotX != rotX ||
        oldDelegate.rotY != rotY ||
        oldDelegate.scale != scale ||
        oldDelegate.pan != pan ||
        oldDelegate.selectedToothCode != selectedToothCode ||
        oldDelegate.toothChart != toothChart ||
        oldDelegate.isDark != isDark;
  }
}

class _RenderTooth {
  final ToothChartEntry entry;
  final Offset screenPos;
  final double depthZ;
  final double scaleFactor;
  final bool isUpper;
  final bool isSelected;

  const _RenderTooth({
    required this.entry,
    required this.screenPos,
    required this.depthZ,
    required this.scaleFactor,
    required this.isUpper,
    required this.isSelected,
  });
}
