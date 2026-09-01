import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/tooth_chart_entry.dart';
import 'tooth_glb_mesh.dart';

class DentalTooth3dCanvasWidget extends StatelessWidget {
  final List<ToothChartEntry> toothChart;
  final bool isPediatric;
  final ToothChartEntry? selectedTooth;
  final void Function(ToothChartEntry entry) onToothSelected;

  static Future<void> get _meshLoadFuture => ToothGlbMeshLibrary.preloadAll();

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

    final rotX = ValueNotifier<double>(0.35);
    final rotY = ValueNotifier<double>(0.0);
    final scale = ValueNotifier<double>(1.1);
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
        child: FutureBuilder<void>(
          future: _meshLoadFuture,
          builder: (context, snapshot) {
            final meshesReady = snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError &&
                ToothGlbMeshLibrary.isReady;

            return Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onScaleStart: (_) {},
                    onScaleUpdate: (details) {
                      if (details.pointerCount == 1) {
                        rotY.value += details.focalPointDelta.dx * 0.012;
                        rotX.value = (rotX.value - details.focalPointDelta.dy * 0.012)
                            .clamp(-1.2, 1.2);
                      } else {
                        scale.value = (scale.value * details.scale).clamp(0.6, 2.5);
                        panOffset.value += details.focalPointDelta;
                      }
                    },
                    onTapUp: meshesReady
                        ? (details) {
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
                          }
                        : null,
                    child: AnimatedBuilder(
                      animation: Listenable.merge([rotX, rotY, scale, panOffset]),
                      builder: (context, _) {
                        if (!meshesReady) {
                          return const Center(
                            child: Text(
                              'Loading tooth models…',
                              style: TextStyle(fontSize: 11, color: Colors.white54),
                            ),
                          );
                        }
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
                _cameraPresetsDock(rotX, rotY, scale, panOffset),
                _zoomControls(rotX, rotY, scale, panOffset),
                _bottomBar(selectedTooth),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cameraPresetsDock(
    ValueNotifier<double> rotX,
    ValueNotifier<double> rotY,
    ValueNotifier<double> scale,
    ValueNotifier<Offset> panOffset,
  ) {
    return Positioned(
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
    );
  }

  Widget _zoomControls(
    ValueNotifier<double> rotX,
    ValueNotifier<double> rotY,
    ValueNotifier<double> scale,
    ValueNotifier<Offset> panOffset,
  ) {
    return Positioned(
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
              onPressed: () => scale.value = (scale.value - 0.2).clamp(0.6, 2.5),
              tooltip: 'Zoom Out',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(Icons.add, size: 16, color: Colors.white70),
              onPressed: () => scale.value = (scale.value + 0.2).clamp(0.6, 2.5),
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
    );
  }

  Widget _bottomBar(ToothChartEntry? selectedTooth) {
    return Positioned(
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
                'FDI ${selectedTooth.fdiNumber}',
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
    var minDistance = 30.0 * s;

    for (final t in teethData) {
      final entry = _findEntry(t.code);
      final p3d = _rotatePoint(t.x, t.y, t.z, rx, ry);
      const distance = 400.0;
      final fov = distance / (distance - p3d.z);
      final screenX = center.dx + p3d.x * s * fov;
      final screenY = center.dy + p3d.y * s * fov;

      final hitRadius = _categoryHitRadius(entry.category) * s * fov;
      final dist = (Offset(screenX, screenY) - tapPos).distance;
      if (dist < math.min(minDistance, hitRadius)) {
        minDistance = dist;
        closestTooth = entry;
      }
    }

    return closestTooth;
  }

  static double _categoryHitRadius(ToothCategory category) {
    switch (category) {
      case ToothCategory.molar:
        return 22;
      case ToothCategory.premolar:
        return 18;
      case ToothCategory.canine:
        return 16;
      case ToothCategory.incisor:
        return 14;
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

  static List<_Tooth3dCoord> _generate3dTeethPositions(bool isPediatric) {
    final list = <_Tooth3dCoord>[];

    if (isPediatric) {
      final upperCodes = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J'];
      for (var i = 0; i < upperCodes.length; i++) {
        final angle = -math.pi * 0.75 + (i / (upperCodes.length - 1)) * (math.pi * 1.5);
        const r = 75.0;
        final x = r * math.sin(angle);
        final z = r * (1.0 - math.cos(angle)) * 0.7;
        const y = -36.0;
        list.add(_Tooth3dCoord(code: upperCodes[i], x: x, y: y, z: z, isUpper: true));
      }

      final lowerCodes = ['T', 'S', 'R', 'Q', 'P', 'O', 'N', 'M', 'L', 'K'];
      for (var i = 0; i < lowerCodes.length; i++) {
        final angle = -math.pi * 0.75 + (i / (lowerCodes.length - 1)) * (math.pi * 1.5);
        const r = 70.0;
        final x = r * math.sin(angle);
        final z = r * (1.0 - math.cos(angle)) * 0.7;
        const y = 36.0;
        list.add(_Tooth3dCoord(code: lowerCodes[i], x: x, y: y, z: z, isUpper: false));
      }
    } else {
      final upperCodes = List.generate(16, (i) => (i + 1).toString());
      for (var i = 0; i < upperCodes.length; i++) {
        final angle = -math.pi * 0.82 + (i / (upperCodes.length - 1)) * (math.pi * 1.64);
        const r = 100.0;
        final x = r * math.sin(angle);
        final z = r * (1.0 - math.cos(angle)) * 0.8;
        const y = -40.0;
        list.add(_Tooth3dCoord(code: upperCodes[i], x: x, y: y, z: z, isUpper: true));
      }

      final lowerCodes = List.generate(16, (i) => (32 - i).toString());
      for (var i = 0; i < lowerCodes.length; i++) {
        final angle = -math.pi * 0.82 + (i / (lowerCodes.length - 1)) * (math.pi * 1.64);
        const r = 94.0;
        final x = r * math.sin(angle);
        final z = r * (1.0 - math.cos(angle)) * 0.8;
        const y = 40.0;
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

class _ProjectedTriangle {
  final Offset a;
  final Offset b;
  final Offset c;
  final double depth;
  final Color color;

  const _ProjectedTriangle({
    required this.a,
    required this.b,
    required this.c,
    required this.depth,
    required this.color,
  });
}

class _Tooth3dPainter extends CustomPainter {
  static const _light = _Point3d(-0.35, -0.65, 0.67);

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
    final allTriangles = <_ProjectedTriangle>[];

    for (final coord in coords) {
      final entry = _findEntry(coord.code);
      final isSelected = selectedToothCode != null &&
          selectedToothCode!.toUpperCase() == coord.code.toUpperCase();
      final anchor = DentalTooth3dCanvasWidget._rotatePoint(
        coord.x,
        coord.y,
        coord.z,
        rotX,
        rotY,
      );
      const distance = 450.0;
      final fov = distance / (distance - anchor.z);
      final screenX = center.dx + anchor.x * scale * fov;
      final screenY = center.dy + anchor.y * scale * fov;

      final meshResult = _projectToothMesh(
        entry: entry,
        archX: coord.x,
        archY: coord.y,
        archZ: coord.z,
        isUpper: coord.isUpper,
        fov: fov,
        center: center,
        stateColor: _getStateColor(entry.state),
      );

      allTriangles.addAll(meshResult.triangles);

      renderList.add(
        _RenderTooth(
          entry: entry,
          screenPos: Offset(screenX, screenY),
          crownScreenPos: meshResult.crownCenter,
          depthZ: anchor.z,
          scaleFactor: fov * scale,
          screenRadius: meshResult.screenRadius,
          isUpper: coord.isUpper,
          isSelected: isSelected,
        ),
      );
    }

    renderList.sort((a, b) => a.depthZ.compareTo(b.depthZ));
    _drawArchBridges(canvas, renderList);

    allTriangles.sort((a, b) => a.depth.compareTo(b.depth));
    for (final tri in allTriangles) {
      final path = Path()
        ..moveTo(tri.a.dx, tri.a.dy)
        ..lineTo(tri.b.dx, tri.b.dy)
        ..lineTo(tri.c.dx, tri.c.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = tri.color);
    }

    for (final item in renderList) {
      _drawToothOverlays(canvas, item);
    }
  }

  _MeshProjectionResult _projectToothMesh({
    required ToothChartEntry entry,
    required double archX,
    required double archY,
    required double archZ,
    required bool isUpper,
    required double fov,
    required Offset center,
    required Color stateColor,
  }) {
    final mesh = ToothGlbMeshLibrary.meshForSync(entry.category);
    final meshHeight = (mesh.crownY - mesh.rootY).abs().clamp(0.5, 999.0);
    final categoryScale = _categoryMeshScale(entry.category);
    final vertexScale = (categoryScale / meshHeight) * scale * fov;
    final meshMidY = (mesh.crownY + mesh.rootY) / 2;

    final isMissing = entry.state == ToothState.missing || entry.state == ToothState.extracted;
    final triangles = <_ProjectedTriangle>[];

    var crownSumX = 0.0;
    var crownSumY = 0.0;
    var crownCount = 0;
    var maxScreenRadius = 12.0;

    for (var i = 0; i < mesh.indices.length; i += 3) {
      final projected = <_Point3d>[];
      final screenPts = <Offset>[];

      for (var j = 0; j < 3; j++) {
        final v = mesh.vertices[mesh.indices[i + j]];
        final localY = (v[1] - meshMidY) * (isUpper ? 1.0 : -1.0);
        final wx = archX + v[0] * vertexScale / fov;
        final wy = archY + localY * vertexScale / fov;
        final wz = archZ + v[2] * vertexScale / fov;
        final rotated = DentalTooth3dCanvasWidget._rotatePoint(wx, wy, wz, rotX, rotY);
        projected.add(rotated);
        const distance = 450.0;
        final triFov = distance / (distance - rotated.z);
        final sx = center.dx + rotated.x * scale * triFov;
        final sy = center.dy + rotated.y * scale * triFov;
        screenPts.add(Offset(sx, sy));

        if (v[1] > meshMidY) {
          crownSumX += sx;
          crownSumY += sy;
          crownCount++;
        }
      }

      final normal = _triangleNormal(projected[0], projected[1], projected[2]);
      final shade = (_dot(normal, _light) * 0.5 + 0.5).clamp(0.25, 1.0);
      final base = isMissing ? stateColor.withValues(alpha: 0.18) : stateColor;
      final enamel = Color.lerp(base, Colors.white, shade * 0.55)!;
      final depth = (projected[0].z + projected[1].z + projected[2].z) / 3;

      triangles.add(
        _ProjectedTriangle(
          a: screenPts[0],
          b: screenPts[1],
          c: screenPts[2],
          depth: depth,
          color: enamel,
        ),
      );
    }

    final crownCenter = crownCount > 0
        ? Offset(crownSumX / crownCount, crownSumY / crownCount)
        : Offset(
            center.dx + archX * scale * fov,
            center.dy + archY * scale * fov,
          );

    for (final tri in triangles) {
      for (final pt in [tri.a, tri.b, tri.c]) {
        final d = (pt - crownCenter).distance;
        if (d > maxScreenRadius) maxScreenRadius = d;
      }
    }

    return _MeshProjectionResult(
      triangles: triangles,
      crownCenter: crownCenter,
      screenRadius: maxScreenRadius.clamp(10.0, 36.0),
    );
  }

  static double _categoryMeshScale(ToothCategory category) {
    switch (category) {
      case ToothCategory.molar:
        return 30;
      case ToothCategory.premolar:
        return 24;
      case ToothCategory.canine:
        return 22;
      case ToothCategory.incisor:
        return 20;
    }
  }

  static _Point3d _triangleNormal(_Point3d a, _Point3d b, _Point3d c) {
    final ux = b.x - a.x;
    final uy = b.y - a.y;
    final uz = b.z - a.z;
    final vx = c.x - a.x;
    final vy = c.y - a.y;
    final vz = c.z - a.z;
    final nx = uy * vz - uz * vy;
    final ny = uz * vx - ux * vz;
    final nz = ux * vy - uy * vx;
    final len = math.sqrt(nx * nx + ny * ny + nz * nz);
    if (len == 0) return const _Point3d(0, 1, 0);
    return _Point3d(nx / len, ny / len, nz / len);
  }

  static double _dot(_Point3d a, _Point3d b) => a.x * b.x + a.y * b.y + a.z * b.z;

  void _drawToothOverlays(Canvas canvas, _RenderTooth item) {
    final pos = item.crownScreenPos;
    final r = item.screenRadius;
    final sf = item.scaleFactor.clamp(0.5, 2.2);
    final stateColor = _getStateColor(item.entry.state);
    final isMissing = item.entry.state == ToothState.missing ||
        item.entry.state == ToothState.extracted;

    if (item.isSelected) {
      final selGlow = Paint()
        ..color = Colors.blueAccent.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(pos, r + 6, selGlow);

      final selRing = Paint()
        ..color = Colors.blueAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, r + 3, selRing);
    }

    if (isMissing) {
      final outline = Paint()
        ..color = stateColor.withValues(alpha: 0.7)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(pos, r * 0.85, outline);
    }

    _drawStatusDecals(canvas, pos, r, item.entry.state);

    final labelText = item.entry.fdiNumber;
    final textPainter = TextPainter(
      text: TextSpan(
        text: labelText,
        style: TextStyle(
          fontSize: (10.0 * sf).clamp(8.0, 14.0),
          fontWeight: FontWeight.bold,
          color: item.isSelected ? Colors.blueAccent : Colors.white,
          shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final labelOffset = Offset(
      pos.dx - textPainter.width / 2,
      pos.dy + (item.isUpper ? -r - textPainter.height - 4 : r + 4),
    );
    textPainter.paint(canvas, labelOffset);

    if (item.entry.pocketDepthMm > 3) {
      final pColor = item.entry.pocketDepthMm >= 6 ? Colors.red : Colors.amber;
      canvas.drawCircle(Offset(pos.dx + r * 0.65, pos.dy - r * 0.55), 4 * sf, Paint()..color = pColor);
    }
  }

  void _drawStatusDecals(Canvas canvas, Offset pos, double r, ToothState state) {
    if (state == ToothState.crown) {
      final crownPaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawCircle(pos, r * 0.72, crownPaint);
    } else if (state == ToothState.rootCanal) {
      canvas.drawCircle(
        pos,
        r * 0.38,
        Paint()..color = const Color(0xFFF97316),
      );
    } else if (state == ToothState.implant) {
      final impPaint = Paint()
        ..color = const Color(0xFF8B5CF6)
        ..strokeWidth = 2.0;
      canvas.drawLine(Offset(pos.dx, pos.dy - r * 0.65), Offset(pos.dx, pos.dy + r * 0.65), impPaint);
      canvas.drawLine(Offset(pos.dx - r * 0.45, pos.dy), Offset(pos.dx + r * 0.45, pos.dy), impPaint);
    } else if (state == ToothState.fractured) {
      final crackPaint = Paint()
        ..color = const Color(0xFFDC2626)
        ..strokeWidth = 2.0;
      final path = Path()
        ..moveTo(pos.dx - r * 0.55, pos.dy - r * 0.55)
        ..lineTo(pos.dx, pos.dy)
        ..lineTo(pos.dx + r * 0.55, pos.dy + r * 0.55);
      canvas.drawPath(path, crackPaint);
    } else if (state == ToothState.bridge) {
      final bridgePaint = Paint()
        ..color = const Color(0xFF06B6D4)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(pos.dx - r * 0.8, pos.dy), Offset(pos.dx + r * 0.8, pos.dy), bridgePaint);
    } else if (state == ToothState.impacted) {
      canvas.drawCircle(
        pos,
        r * 0.5,
        Paint()
          ..color = const Color(0xFFE11D48).withValues(alpha: 0.35)
          ..style = PaintingStyle.fill,
      );
    }
  }

  void _drawGridBackground(Canvas canvas, Size size, Offset center) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1;

    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (var y = 0.0; y < size.height; y += 40) {
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
      for (var i = 1; i < uppers.length; i++) {
        path.lineTo(uppers[i].screenPos.dx, uppers[i].screenPos.dy);
      }
      canvas.drawPath(path, archPaint);
    }

    final lowers = teeth.where((t) => !t.isUpper).toList()
      ..sort((a, b) => a.screenPos.dx.compareTo(b.screenPos.dx));
    if (lowers.length > 1) {
      final path = Path()..moveTo(lowers.first.screenPos.dx, lowers.first.screenPos.dy);
      for (var i = 1; i < lowers.length; i++) {
        path.lineTo(lowers[i].screenPos.dx, lowers[i].screenPos.dy);
      }
      canvas.drawPath(path, archPaint);
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

class _MeshProjectionResult {
  final List<_ProjectedTriangle> triangles;
  final Offset crownCenter;
  final double screenRadius;

  const _MeshProjectionResult({
    required this.triangles,
    required this.crownCenter,
    required this.screenRadius,
  });
}

class _RenderTooth {
  final ToothChartEntry entry;
  final Offset screenPos;
  final Offset crownScreenPos;
  final double depthZ;
  final double scaleFactor;
  final double screenRadius;
  final bool isUpper;
  final bool isSelected;

  const _RenderTooth({
    required this.entry,
    required this.screenPos,
    required this.crownScreenPos,
    required this.depthZ,
    required this.scaleFactor,
    required this.screenRadius,
    required this.isUpper,
    required this.isSelected,
  });
}
