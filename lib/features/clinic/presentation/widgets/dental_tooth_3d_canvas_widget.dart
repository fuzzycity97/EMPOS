import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/tooth_chart_entry.dart';

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

    // View state notifiers for 100% StatelessWidget gesture responsiveness
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
              right: 120,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _presetButton('Front 3D', () {
                        rotX.value = 0.35;
                        rotY.value = 0.0;
                        scale.value = 1.1;
                        panOffset.value = Offset.zero;
                      }),
                      const SizedBox(width: 4),
                      _presetButton('Upper Arch', () {
                        rotX.value = 1.15;
                        rotY.value = 0.0;
                        scale.value = 1.25;
                        panOffset.value = Offset.zero;
                      }),
                      const SizedBox(width: 4),
                      _presetButton('Lower Arch', () {
                        rotX.value = -1.15;
                        rotY.value = 0.0;
                        scale.value = 1.25;
                        panOffset.value = Offset.zero;
                      }),
                      const SizedBox(width: 4),
                      _presetButton('Right Sagittal', () {
                        rotX.value = 0.15;
                        rotY.value = 1.35;
                        scale.value = 1.2;
                        panOffset.value = Offset.zero;
                      }),
                      const SizedBox(width: 4),
                      _presetButton('Left Sagittal', () {
                        rotX.value = 0.15;
                        rotY.value = -1.35;
                        scale.value = 1.2;
                        panOffset.value = Offset.zero;
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // 3. Zoom Controls (Top Right)
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove, size: 16, color: Colors.white70),
                      onPressed: () {
                        scale.value = (scale.value - 0.2).clamp(0.6, 2.5);
                      },
                      tooltip: 'Zoom Out',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, size: 16, color: Colors.white70),
                      onPressed: () {
                        scale.value = (scale.value + 0.2).clamp(0.6, 2.5);
                      },
                      tooltip: 'Zoom In',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    IconButton(
                      icon: const Icon(Icons.restart_alt, size: 16, color: Colors.white70),
                      onPressed: () {
                        rotX.value = 0.35;
                        rotY.value = 0.0;
                        scale.value = 1.1;
                        panOffset.value = Offset.zero;
                      },
                      tooltip: 'Reset Camera',
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),

            // 4. Instructions & Selected Tooth Floating Badge (Bottom)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white10),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.touch_app_outlined, size: 12, color: Colors.white60),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Drag to rotate 3D • Pinch/Scroll to zoom • Tap tooth to edit',
                              style: TextStyle(fontSize: 10, color: Colors.white70),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (selectedTooth != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blueAccent),
                      ),
                      child: Text(
                        'FDI ${selectedTooth!.fdiNumber}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _presetButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
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
    final teethData = _generate3dTeethPositions(isPediatric);

    ToothChartEntry? closestTooth;
    double minDistance = 26.0 * s; // Hit radius

    for (final t in teethData) {
      final p3d = _rotatePoint(t.x, t.y, t.z, rx, ry);
      // Perspective projection
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
    // Rotate Y (yaw)
    final cosY = math.cos(ry);
    final sinY = math.sin(ry);
    final x1 = x * cosY + z * sinY;
    final z1 = -x * sinY + z * cosY;

    // Rotate X (pitch)
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

    // Draw ambient background grid & orientation guides
    _drawGridBackground(canvas, size, center);

    // Generate tooth coordinates in 3D parabolic arch
    final coords = DentalTooth3dCanvasWidget._generate3dTeethPositions(isPediatric);

    // Transform and project each tooth
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

    // Depth sort (Painters algorithm: back to front)
    renderList.sort((a, b) => a.depthZ.compareTo(b.depthZ));

    // Connect arch wire guides in 3D
    _drawArchBridges(canvas, renderList);

    // Render each tooth mesh with anatomical cusps, roots, and status shading
    for (final item in renderList) {
      _drawToothMesh(canvas, item);
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

    // Occlusal centerline guide
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

  void _drawToothMesh(Canvas canvas, _RenderTooth item) {
    final pos = item.screenPos;
    final sf = item.scaleFactor.clamp(0.5, 2.2);
    final stateColor = _getStateColor(item.entry.state);
    final isMissing = item.entry.state == ToothState.missing ||
        item.entry.state == ToothState.extracted;

    // 1. Highlight Ring for Selected Tooth
    if (item.isSelected) {
      final selGlow = Paint()
        ..color = Colors.blueAccent.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, 22 * sf, selGlow);

      final selRing = Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, 20 * sf, selRing);
    }

    // 2. Anatomical 3D Mesh Geometry
    final cat = item.entry.category;
    final toothRadius = (cat == ToothCategory.molar ? 14.0 : (cat == ToothCategory.premolar ? 11.0 : 9.5)) * sf;

    // Draw Root Silhouette
    final rootHeight = (item.isUpper ? -14.0 : 14.0) * sf;
    final rootPath = Path();
    if (cat == ToothCategory.molar) {
      // Multi-root shape
      rootPath.moveTo(pos.dx - toothRadius * 0.6, pos.dy);
      rootPath.lineTo(pos.dx - toothRadius * 0.8, pos.dy + rootHeight);
      rootPath.lineTo(pos.dx - toothRadius * 0.2, pos.dy);
      rootPath.lineTo(pos.dx + toothRadius * 0.2, pos.dy);
      rootPath.lineTo(pos.dx + toothRadius * 0.8, pos.dy + rootHeight);
      rootPath.lineTo(pos.dx + toothRadius * 0.6, pos.dy);
    } else {
      // Single tapered root
      rootPath.moveTo(pos.dx - toothRadius * 0.5, pos.dy);
      rootPath.lineTo(pos.dx, pos.dy + rootHeight);
      rootPath.lineTo(pos.dx + toothRadius * 0.5, pos.dy);
    }
    rootPath.close();

    final rootPaint = Paint()
      ..color = stateColor.withValues(alpha: isMissing ? 0.2 : 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawPath(rootPath, rootPaint);

    // Draw Crown Base (3D Sphere / Rounded Box)
    final crownRect = Rect.fromCenter(
      center: pos,
      width: toothRadius * 2,
      height: toothRadius * 1.8,
    );

    // Radial lighting gradient for enamel specular realism
    if (!isMissing) {
      final gradient = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 0.85,
        colors: [
          Colors.white,
          stateColor.withValues(alpha: 0.35),
          stateColor.withValues(alpha: 0.85),
        ],
        stops: const [0.0, 0.55, 1.0],
      );
      final crownPaint = Paint()
        ..shader = gradient.createShader(crownRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(crownRect, Radius.circular(toothRadius * 0.5)),
        crownPaint,
      );
    } else {
      final dashPaint = Paint()
        ..color = stateColor
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawRRect(
        RRect.fromRectAndRadius(crownRect, Radius.circular(toothRadius * 0.5)),
        dashPaint,
      );
    }

    // 3. Occlusal / Anatomical Grooves & Status Badges
    _drawOcclusalDetails(canvas, pos, toothRadius, cat, item.entry.state);

    // 4. FDI & Universal Number Label
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

    final labelOffset = Offset(
      pos.dx - textPainter.width / 2,
      pos.dy + (item.isUpper ? -toothRadius * 1.5 - textPainter.height : toothRadius * 1.3),
    );
    textPainter.paint(canvas, labelOffset);

    // 5. Periodontal Pocket Depth Indicator if pathological (> 3mm)
    if (item.entry.pocketDepthMm > 3) {
      final pColor = item.entry.pocketDepthMm >= 6 ? Colors.red : Colors.amber;
      final pocketBadge = Paint()..color = pColor;
      canvas.drawCircle(Offset(pos.dx + toothRadius * 0.7, pos.dy - toothRadius * 0.7), 4 * sf, pocketBadge);
    }
  }

  void _drawOcclusalDetails(Canvas canvas, Offset pos, double r, ToothCategory cat, ToothState state) {
    final detailPaint = Paint()
      ..color = Colors.black38
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    if (cat == ToothCategory.molar) {
      // Cross-grooves for 4 cusps
      canvas.drawLine(Offset(pos.dx - r * 0.5, pos.dy), Offset(pos.dx + r * 0.5, pos.dy), detailPaint);
      canvas.drawLine(Offset(pos.dx, pos.dy - r * 0.5), Offset(pos.dx, pos.dy + r * 0.5), detailPaint);
    } else if (cat == ToothCategory.premolar) {
      // Central developmental groove
      canvas.drawLine(Offset(pos.dx - r * 0.4, pos.dy), Offset(pos.dx + r * 0.4, pos.dy), detailPaint);
    } else if (cat == ToothCategory.incisor) {
      // Incisal edge
      canvas.drawLine(Offset(pos.dx - r * 0.5, pos.dy - r * 0.1), Offset(pos.dx + r * 0.5, pos.dy - r * 0.1), detailPaint);
    }

    // Clinical state decals directly in 3D
    if (state == ToothState.crown) {
      final crownPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(pos, r * 0.7, crownPaint);
    } else if (state == ToothState.rootCanal) {
      final endoPaint = Paint()
        ..color = const Color(0xFFF97316)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pos, r * 0.35, endoPaint);
    } else if (state == ToothState.implant) {
      final impPaint = Paint()
        ..color = const Color(0xFF8B5CF6)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(pos.dx, pos.dy - r * 0.6), Offset(pos.dx, pos.dy + r * 0.6), impPaint);
      canvas.drawLine(Offset(pos.dx - r * 0.4, pos.dy), Offset(pos.dx + r * 0.4, pos.dy), impPaint);
    } else if (state == ToothState.fractured) {
      final crackPaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..strokeWidth = 2.0;
      final path = Path()
        ..moveTo(pos.dx - r * 0.5, pos.dy - r * 0.5)
        ..lineTo(pos.dx, pos.dy)
        ..lineTo(pos.dx + r * 0.5, pos.dy + r * 0.5);
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
