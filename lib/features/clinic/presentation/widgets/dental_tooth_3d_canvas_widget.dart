import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/localization/app_language.dart';
import '../../domain/entities/clinical_anatomy_status_entry.dart';
import '../../domain/entities/tooth_chart_entry.dart';
import 'tooth_glb_mesh.dart';

export '../../domain/entities/anatomical_engine_models.dart';

/// Interactive Polymorphic 3D Anatomical & Odontogram Canvas Widget.
/// Deterministic 3D vector geometry & triangle mesh projection, perspective raycasting,
/// anatomical 3D gingival (gum) arch, dynamic 3D pin projection,
/// and depth-sorted shader pipeline across Clinical, Dental, Physiotherapy,
/// Ophthalmology, and Veterinary anatomical profiles.
class DentalTooth3dCanvasWidget extends StatefulWidget {
  final List<ToothChartEntry> toothChart;
  final bool isPediatric;
  final ToothChartEntry? selectedTooth;
  final void Function(ToothChartEntry entry) onToothSelected;
  final String specialtyKey;
  final Map<String, ClinicalAnatomyStatusEntry>? activeStatuses;
  final bool isPinMode;
  final void Function(
    double normX,
    double normY, {
    String? toothCode,
    String? partName,
    double? x3d,
    double? y3d,
    double? z3d,
  })? onCanvasTapToPin;
  final void Function(ClinicalAnatomyStatusEntry pin)? onPinTap;

  const DentalTooth3dCanvasWidget({
    super.key,
    required this.toothChart,
    this.isPediatric = false,
    this.selectedTooth,
    required this.onToothSelected,
    this.specialtyKey = 'dental_clinic',
    this.activeStatuses,
    this.isPinMode = false,
    this.onCanvasTapToPin,
    this.onPinTap,
  });

  @override
  State<DentalTooth3dCanvasWidget> createState() => _DentalTooth3dCanvasWidgetState();
}

class _DentalTooth3dCanvasWidgetState extends State<DentalTooth3dCanvasWidget> {
  static Future<void> get _meshLoadFuture => ToothGlbMeshLibrary.preloadAll();

  late final ValueNotifier<double> _rotX;
  late final ValueNotifier<double> _rotY;
  late final ValueNotifier<double> _scale;
  late final ValueNotifier<Offset> _panOffset;
  late final ValueNotifier<bool> _showGumsNotifier;
  late final ValueNotifier<String?> _emptySpaceWarningNotifier;
  Timer? _warningTimer;

  @override
  void initState() {
    super.initState();
    _rotX = ValueNotifier<double>(0.35);
    _rotY = ValueNotifier<double>(0.0);
    _scale = ValueNotifier<double>(1.1);
    _panOffset = ValueNotifier<Offset>(Offset.zero);
    _showGumsNotifier = ValueNotifier<bool>(true);
    _emptySpaceWarningNotifier = ValueNotifier<String?>(null);
  }

  @override
  void dispose() {
    _warningTimer?.cancel();
    _rotX.dispose();
    _rotY.dispose();
    _scale.dispose();
    _panOffset.dispose();
    _showGumsNotifier.dispose();
    _emptySpaceWarningNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
            return LayoutBuilder(
              builder: (context, constraints) {
                final canvasW = constraints.maxWidth > 0 ? constraints.maxWidth : 400.0;
                final canvasH = constraints.maxHeight > 0 ? constraints.maxHeight : 380.0;

                return Stack(
                  children: [
                    Positioned.fill(
                      child: GestureDetector(
                        onScaleStart: (_) {},
                        onScaleUpdate: (details) {
                          if (details.pointerCount == 1) {
                            _rotY.value += details.focalPointDelta.dx * 0.012;
                            _rotX.value = (_rotX.value - details.focalPointDelta.dy * 0.012)
                                .clamp(-1.2, 1.2);
                          } else {
                            _scale.value = (_scale.value * details.scale).clamp(0.6, 2.5);
                            _panOffset.value += details.focalPointDelta;
                          }
                        },
                        onTapUp: (details) {
                          final size = Size(canvasW, canvasH);
                          if (widget.isPinMode && widget.onCanvasTapToPin != null) {
                            final hit = _hitTestToothOrGingiva(
                              details.localPosition,
                              size,
                              _rotX.value,
                              _rotY.value,
                              _scale.value,
                              _panOffset.value,
                            );

                            if (hit == null || hit.distance > 65.0) {
                              // Reject pinning to empty space!
                              _emptySpaceWarningNotifier.value = AppLanguage.tr(
                                'Tap directly on a tooth or gum arch to attach 3D Pin Note. Pins cannot float in empty space.',
                                'يرجى النقر مباشرة على سن أو على قوس اللثة لتثبيت الدبوس. لا يمكن تثبيت الدبوس في الفراغ.',
                              );
                              _warningTimer?.cancel();
                              _warningTimer = Timer(const Duration(seconds: 3), () {
                                if (mounted && _emptySpaceWarningNotifier.value != null) {
                                  _emptySpaceWarningNotifier.value = null;
                                }
                              });
                              return;
                            }

                            final normX = (hit.screenPos.dx / canvasW).clamp(0.05, 0.95);
                            final normY = (hit.screenPos.dy / canvasH).clamp(0.05, 0.95);
                            final partName = hit.isGingiva
                                ? 'Tooth #${hit.entry.effectiveToothCode} (${AppLanguage.tr('Gingiva / Gum', 'اللثة')})'
                                : 'Tooth #${hit.entry.effectiveToothCode}';

                            widget.onCanvasTapToPin!(
                              normX,
                              normY,
                              toothCode: hit.entry.effectiveToothCode,
                              partName: partName,
                              x3d: hit.coord.x,
                              y3d: hit.coord.y + (hit.isGingiva ? (hit.coord.isUpper ? -14.0 : 14.0) : 0.0),
                              z3d: hit.coord.z,
                            );
                            return;
                          }

                          final toothHit = _hitTestTooth(
                            details.localPosition,
                            size,
                            _rotX.value,
                            _rotY.value,
                            _scale.value,
                            _panOffset.value,
                          );
                          if (toothHit != null) {
                            widget.onToothSelected(toothHit);
                          }
                        },
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _rotX,
                            _rotY,
                            _scale,
                            _panOffset,
                            _showGumsNotifier,
                          ]),
                          builder: (context, _) {
                            final center = Offset(canvasW / 2 + _panOffset.value.dx, canvasH / 2 + _panOffset.value.dy);
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _Tooth3dPainter(
                                      toothChart: widget.toothChart,
                                      isPediatric: widget.isPediatric,
                                      selectedToothCode: widget.selectedTooth?.effectiveToothCode,
                                      rotX: _rotX.value,
                                      rotY: _rotY.value,
                                      scale: _scale.value,
                                      pan: _panOffset.value,
                                      isDark: isDark,
                                      showGums: _showGumsNotifier.value,
                                    ),
                                  ),
                                ),
                                // ── DYNAMIC 3D PROJECTED PIN MARKERS ──────────
                                // Pins rotate, scale, and pan naturally in 3D perspective with the dental model!
                                if (widget.activeStatuses != null)
                                  ..._buildProjected3dPins(
                                    context: context,
                                    pins: widget.activeStatuses!.values.where((e) => e.isCustomPin).toList(),
                                    canvasW: canvasW,
                                    canvasH: canvasH,
                                    center: center,
                                    rx: _rotX.value,
                                    ry: _rotY.value,
                                    s: _scale.value,
                                    isDark: isDark,
                                  ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    _cameraPresetsDock(),
                    _zoomControls(),
                    _bottomBar(widget.selectedTooth),
                    if (widget.isPinMode)
                      Positioned(
                        top: 52,
                        left: 12,
                        right: 12,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.pin, color: Colors.white, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  AppLanguage.tr(
                                    'Tap on any Tooth or Gum area to attach 3D Pin Note',
                                    'انقر على أي سن أو منطقة لثة لتثبيت دبوس الملاحظات ثلاثي الأبعاد',
                                  ),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    // Floating Warning when user taps in empty space
                    Positioned(
                      top: 86,
                      left: 16,
                      right: 16,
                      child: ValueListenableBuilder<String?>(
                        valueListenable: _emptySpaceWarningNotifier,
                        builder: (context, warning, _) {
                          if (warning == null) return const SizedBox.shrink();
                          return Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDC2626),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(LucideIcons.alertTriangle, color: Colors.white, size: 15),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      warning,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// Projects all custom pins into true 3D space, anchored to specific teeth/gums.
  /// Rotates, zooms, and depth-fades in synchronized real-time.
  List<Widget> _buildProjected3dPins({
    required BuildContext context,
    required List<ClinicalAnatomyStatusEntry> pins,
    required double canvasW,
    required double canvasH,
    required Offset center,
    required double rx,
    required double ry,
    required double s,
    required bool isDark,
  }) {
    final teethCoords = generate3dTeethPositions(widget.isPediatric);
    final widgets = <Widget>[];

    for (final pin in pins) {
      double ax, ay, az;
      if (pin.x3d != null && pin.y3d != null && pin.z3d != null) {
        ax = pin.x3d!;
        ay = pin.y3d!;
        az = pin.z3d!;
      } else {
        // Resolve 3D anchor from attachedToothCode or partKey/name
        _Tooth3dCoord? matchedCoord;
        if (pin.attachedToothCode != null) {
          matchedCoord = teethCoords.cast<_Tooth3dCoord?>().firstWhere(
            (c) => c?.code.toUpperCase() == pin.attachedToothCode!.toUpperCase(),
            orElse: () => null,
          );
        }
        matchedCoord ??= teethCoords.cast<_Tooth3dCoord?>().firstWhere(
          (c) =>
              pin.partKey.contains(c!.code) ||
              pin.partName.contains('#${c.code}') ||
              pin.partName.contains(' ${c.code}'),
          orElse: () => null,
        );

        if (matchedCoord != null) {
          ax = matchedCoord.x;
          ay = matchedCoord.y;
          az = matchedCoord.z;
        } else {
          // Approximate anchor on the arch from normalized screen coords
          final nx = pin.normalizedX ?? 0.5;
          final ny = pin.normalizedY ?? 0.5;
          final isUpper = ny < 0.5;
          final angle = (nx - 0.5) * math.pi * 1.5;
          final r = isUpper ? 100.0 : 94.0;
          ax = r * math.sin(angle);
          ay = isUpper ? -40.0 : 40.0;
          az = r * (1.0 - math.cos(angle)) * 0.8;
        }
      }

      // Rotate point in 3D using current camera orientation
      final rotated = rotatePoint(ax, ay, az, rx, ry);
      const distance = 450.0;
      final fov = distance / (distance - rotated.z);
      final screenX = center.dx + rotated.x * s * fov;
      final screenY = center.dy + rotated.y * s * fov;

      // Occlusion & depth culling: fade when facing backwards behind the arch
      final isBackFacing = rotated.z < -80.0;
      final opacity = isBackFacing ? 0.35 : 1.0;

      widgets.add(
        Positioned(
          left: (screenX - 16).clamp(4.0, (canvasW - 120.0).clamp(4.0, double.infinity)),
          top: (screenY - 34).clamp(4.0, (canvasH - 38.0).clamp(4.0, double.infinity)),
          child: Opacity(
            opacity: opacity,
            child: _buildPinMarker(context, pin, isDark, anchorOffset: Offset(screenX, screenY)),
          ),
        ),
      );
    }

    return widgets;
  }

  Widget _cameraPresetsDock() {
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
              // ── 3D GUM (GINGIVAL ARCH) TOGGLE ──
              ValueListenableBuilder<bool>(
                valueListenable: _showGumsNotifier,
                builder: (context, showGums, _) {
                  return GestureDetector(
                    key: const Key('btn_toggle_3d_gums'),
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _showGumsNotifier.value = !showGums,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: showGums
                            ? const Color(0xFFE11D48).withValues(alpha: 0.35)
                            : Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: showGums
                            ? Border.all(color: const Color(0xFFFB7185), width: 1.2)
                            : Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.activity,
                            size: 11,
                            color: showGums ? const Color(0xFFFDA4AF) : Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            showGums ? '3D Gums: ON' : '3D Gums: OFF',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: showGums ? Colors.white : Colors.white70,
                              fontWeight: showGums ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              _presetButton('Front 3D', () {
                _rotX.value = 0.35;
                _rotY.value = 0.0;
                _scale.value = 1.1;
                _panOffset.value = Offset.zero;
              }),
              const SizedBox(width: 4),
              _presetButton('Upper Arch', () {
                _rotX.value = 1.15;
                _rotY.value = 0.0;
                _scale.value = 1.25;
                _panOffset.value = Offset.zero;
              }),
              const SizedBox(width: 4),
              _presetButton('Lower Arch', () {
                _rotX.value = -1.15;
                _rotY.value = 0.0;
                _scale.value = 1.25;
                _panOffset.value = Offset.zero;
              }),
              const SizedBox(width: 4),
              _presetButton('Right Sagittal', () {
                _rotX.value = 0.15;
                _rotY.value = 1.35;
                _scale.value = 1.2;
                _panOffset.value = Offset.zero;
              }),
              const SizedBox(width: 4),
              _presetButton('Left Sagittal', () {
                _rotX.value = 0.15;
                _rotY.value = -1.35;
                _scale.value = 1.2;
                _panOffset.value = Offset.zero;
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _zoomControls() {
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
              icon: const Icon(LucideIcons.minus, size: 16, color: Colors.white70),
              onPressed: () => _scale.value = (_scale.value - 0.2).clamp(0.6, 2.5),
              tooltip: 'Zoom Out',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(LucideIcons.plus, size: 16, color: Colors.white70),
              onPressed: () => _scale.value = (_scale.value + 0.2).clamp(0.6, 2.5),
              tooltip: 'Zoom In',
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(LucideIcons.rotateCcw, size: 16, color: Colors.white70),
              onPressed: () {
                _rotX.value = 0.35;
                _rotY.value = 0.0;
                _scale.value = 1.1;
                _panOffset.value = Offset.zero;
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
              child: Row(
                children: [
                  const Icon(LucideIcons.mousePointer, size: 12, color: Colors.white60),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      AppLanguage.tr(
                        'Drag to rotate 3D • Pinch/Scroll to zoom • Tap tooth/gum to inspect',
                        'اسحب لتدوير النموذج 3D • قرص/تمرير للتكبير • انقر على السن/اللثة للمعاينة',
                      ),
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
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

  Widget _buildPinMarker(
    BuildContext context,
    ClinicalAnatomyStatusEntry pin,
    bool isDark, {
    Offset? anchorOffset,
  }) {
    final color = pin.visualColor;
    final fee = pin.status.suggestedProcedure.standardFee;
    return Tooltip(
      message:
          '${pin.partName}: ${pin.clinicalNote.isNotEmpty ? pin.clinicalNote : pin.status.title}${fee > 0 ? " (${fee.toStringAsFixed(0)} EGP)" : ""}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onPinTap != null ? () => widget.onPinTap!(pin) : null,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color, width: 2.0),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.8),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: const Icon(LucideIcons.pin, size: 9, color: Colors.white),
                ),
                const SizedBox(width: 4),
                Text(
                  pin.partName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (fee > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${fee.toStringAsFixed(0)} EGP',
                      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _presetButton(String label, VoidCallback onTap) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
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

  /// Raycast hit-test for tooth selection
  ToothChartEntry? _hitTestTooth(
    Offset tapPos,
    Size size,
    double rx,
    double ry,
    double s,
    Offset pan,
  ) {
    final center = Offset(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    final teethData = generate3dTeethPositions(widget.isPediatric);

    ToothChartEntry? closestTooth;
    var minDistance = 30.0 * s;

    for (final t in teethData) {
      final entry = _findEntry(t.code);
      final p3d = rotatePoint(t.x, t.y, t.z, rx, ry);
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

  /// Enhanced hit test for tooth or gingiva targeting to guarantee pins never attach to empty space
  _Dental3dHitTarget? _hitTestToothOrGingiva(
    Offset tapPos,
    Size size,
    double rx,
    double ry,
    double s,
    Offset pan,
  ) {
    final center = Offset(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    final teethData = generate3dTeethPositions(widget.isPediatric);

    _Dental3dHitTarget? closestTarget;
    var minDistance = double.infinity;

    for (final t in teethData) {
      final entry = _findEntry(t.code);
      final p3d = rotatePoint(t.x, t.y, t.z, rx, ry);
      const distance = 450.0;
      final fov = distance / (distance - p3d.z);
      final screenX = center.dx + p3d.x * s * fov;
      final screenY = center.dy + p3d.y * s * fov;

      final dist = (Offset(screenX, screenY) - tapPos).distance;
      if (dist < minDistance) {
        minDistance = dist;
        // Check if tap was on the gingival margin (above crown for upper, below for lower)
        final isGingiva = (t.isUpper && tapPos.dy < screenY - 5) || (!t.isUpper && tapPos.dy > screenY + 5);
        closestTarget = _Dental3dHitTarget(
          entry: entry,
          coord: t,
          screenPos: Offset(screenX, screenY),
          distance: dist,
          isGingiva: isGingiva,
        );
      }
    }

    return closestTarget;
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
    for (final t in widget.toothChart) {
      if (t.effectiveToothCode.toUpperCase() == code.toUpperCase()) {
        return t;
      }
    }
    return ToothChartEntry(
      toothNumber: int.tryParse(code) ?? 1,
      toothCode: code,
      isDeciduous: widget.isPediatric,
    );
  }

  static List<_Tooth3dCoord> generate3dTeethPositions(bool isPediatric) {
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

  static _Point3d rotatePoint(double x, double y, double z, double rx, double ry) {
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

/// Generic Polymorphic Alias for multi-specialty clinical view integration
typedef Anatomical3dCanvasWidget = DentalTooth3dCanvasWidget;

class _Dental3dHitTarget {
  final ToothChartEntry entry;
  final _Tooth3dCoord coord;
  final Offset screenPos;
  final double distance;
  final bool isGingiva;

  const _Dental3dHitTarget({
    required this.entry,
    required this.coord,
    required this.screenPos,
    required this.distance,
    required this.isGingiva,
  });
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
  final bool showGums;

  _Tooth3dPainter({
    required this.toothChart,
    required this.isPediatric,
    this.selectedToothCode,
    required this.rotX,
    required this.rotY,
    required this.scale,
    required this.pan,
    required this.isDark,
    this.showGums = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    _drawGridBackground(canvas, size, center);

    final coords = _DentalTooth3dCanvasWidgetState.generate3dTeethPositions(isPediatric);
    final renderList = <_RenderTooth>[];
    final allTriangles = <_ProjectedTriangle>[];

    // ── 1. GENERATE 3D GINGIVAL (GUM) ARCH MESHES ────────────────────────────
    if (showGums) {
      _generateGingivalArchTriangles(
        isUpper: true,
        coords: coords.where((c) => c.isUpper).toList(),
        allTriangles: allTriangles,
        center: center,
      );
      _generateGingivalArchTriangles(
        isUpper: false,
        coords: coords.where((c) => !c.isUpper).toList(),
        allTriangles: allTriangles,
        center: center,
      );
    }

    // ── 2. PROJECT 3D TOOTH MESHES ───────────────────────────────────────────
    for (final coord in coords) {
      final entry = _findEntry(coord.code);
      final isSelected = selectedToothCode != null &&
          selectedToothCode!.toUpperCase() == coord.code.toUpperCase();
      final anchor = _DentalTooth3dCanvasWidgetState.rotatePoint(
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

    // ── 3. DEPTH-SORT ALL TRIANGLES (TEETH + GUM) ────────────────────────────
    allTriangles.sort((a, b) => a.depth.compareTo(b.depth));
    for (final tri in allTriangles) {
      final path = Path()
        ..moveTo(tri.a.dx, tri.a.dy)
        ..lineTo(tri.b.dx, tri.b.dy)
        ..lineTo(tri.c.dx, tri.c.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = tri.color);
    }

    // ── 4. WIRE ARCH BRIDGES (SUBTLE ARCH GUIDES) ────────────────────────────
    if (!showGums) {
      renderList.sort((a, b) => a.depthZ.compareTo(b.depthZ));
      _drawArchBridges(canvas, renderList);
    }

    // ── 5. TOOTH LABELS, PERIODONTAL METRICS & STATUS DECALS ─────────────────
    for (final item in renderList) {
      _drawToothOverlays(canvas, item);
    }
  }

  /// Generates a realistic, anatomically curved 3D gingival (gum) tissue arch.
  /// Features scalloped gingival margins (interdental papillae), smooth alveolar ridge curvature,
  /// 3D lighting, and periodontal disease / pocket depth color indicators.
  void _generateGingivalArchTriangles({
    required bool isUpper,
    required List<_Tooth3dCoord> coords,
    required List<_ProjectedTriangle> allTriangles,
    required Offset center,
  }) {
    if (coords.isEmpty) return;

    final numSegments = isPediatric ? 24 : 36;
    final r = isUpper ? (isPediatric ? 75.0 : 100.0) : (isPediatric ? 70.0 : 94.0);
    final maxAngle = isPediatric ? math.pi * 0.75 : math.pi * 0.82;
    final kScallop = isPediatric ? 10.0 : 16.0;

    final yBase = isUpper ? -56.0 : 56.0;
    final yMarginCenter = isUpper ? -36.0 : 36.0;
    final yPalateBase = isUpper ? -50.0 : 50.0;

    for (var i = 0; i < numSegments; i++) {
      final t0 = i / numSegments;
      final t1 = (i + 1) / numSegments;

      final a0 = -maxAngle + t0 * (2 * maxAngle);
      final a1 = -maxAngle + t1 * (2 * maxAngle);

      // Scalloped interdental papillae dipping around each tooth neck
      final sc0 = math.sin(t0 * math.pi * kScallop) * (isUpper ? 2.4 : -2.4);
      final sc1 = math.sin(t1 * math.pi * kScallop) * (isUpper ? 2.4 : -2.4);

      final ym0 = yMarginCenter + sc0;
      final ym1 = yMarginCenter + sc1;

      // Outer Alveolar Base (Buccal/Labial)
      final rOutBase = r + 11.0;
      final pOutBase0 = _Point3d(rOutBase * math.sin(a0), yBase, rOutBase * (1.0 - math.cos(a0)) * 0.8);
      final pOutBase1 = _Point3d(rOutBase * math.sin(a1), yBase, rOutBase * (1.0 - math.cos(a1)) * 0.8);

      // Outer Gingival Margin (Crest / Free Gingiva)
      final rMargin = r + 3.5;
      final pMargin0 = _Point3d(rMargin * math.sin(a0), ym0, rMargin * (1.0 - math.cos(a0)) * 0.8);
      final pMargin1 = _Point3d(rMargin * math.sin(a1), ym1, rMargin * (1.0 - math.cos(a1)) * 0.8);

      // Inner Gingival Margin (Palatal / Lingual Crest)
      final rInMargin = r - 3.5;
      final pInMargin0 = _Point3d(rInMargin * math.sin(a0), ym0, rInMargin * (1.0 - math.cos(a0)) * 0.8);
      final pInMargin1 = _Point3d(rInMargin * math.sin(a1), ym1, rInMargin * (1.0 - math.cos(a1)) * 0.8);

      // Inner Alveolar Base (Palatal Vault / Floor of Mouth)
      final rInBase = r - 12.0;
      final pInBase0 = _Point3d(rInBase * math.sin(a0), yPalateBase, rInBase * (1.0 - math.cos(a0)) * 0.8);
      final pInBase1 = _Point3d(rInBase * math.sin(a1), yPalateBase, rInBase * (1.0 - math.cos(a1)) * 0.8);

      // Determine Periodontal Status for this sector (Pocket Depth / Gingivitis)
      final toothIndex = (t0 * (coords.length - 1)).round().clamp(0, coords.length - 1);
      final toothEntry = _findEntry(coords[toothIndex].code);

      Color gumColor;
      if (toothEntry.pocketDepthMm >= 6) {
        gumColor = const Color(0xFFDC2626); // Deep Periodontal Pocket / Severe Inflammation
      } else if (toothEntry.pocketDepthMm >= 4) {
        gumColor = const Color(0xFFEA580C); // Moderate Pocket / Marginal Gingivitis
      } else {
        gumColor = const Color(0xFFE28A94); // Healthy Stippled Pink Gingiva
      }

      // 1. Buccal / Labial Outer Wall Quad (2 triangles)
      _addQuadToTriangles(
        p0: pOutBase0,
        p1: pOutBase1,
        p2: pMargin1,
        p3: pMargin0,
        baseColor: gumColor,
        allTriangles: allTriangles,
        center: center,
      );

      // 2. Gingival Collar / Sulcus Quad (2 triangles)
      _addQuadToTriangles(
        p0: pMargin0,
        p1: pMargin1,
        p2: pInMargin1,
        p3: pInMargin0,
        baseColor: Color.lerp(gumColor, const Color(0xFFBE5261), 0.3)!,
        allTriangles: allTriangles,
        center: center,
      );

      // 3. Palatal / Lingual Inner Wall Quad (2 triangles)
      _addQuadToTriangles(
        p0: pInMargin0,
        p1: pInMargin1,
        p2: pInBase1,
        p3: pInBase0,
        baseColor: Color.lerp(gumColor, const Color(0xFFC75D6A), 0.5)!,
        allTriangles: allTriangles,
        center: center,
      );
    }
  }

  void _addQuadToTriangles({
    required _Point3d p0,
    required _Point3d p1,
    required _Point3d p2,
    required _Point3d p3,
    required Color baseColor,
    required List<_ProjectedTriangle> allTriangles,
    required Offset center,
  }) {
    // Project and rotate vertices
    final r0 = _DentalTooth3dCanvasWidgetState.rotatePoint(p0.x, p0.y, p0.z, rotX, rotY);
    final r1 = _DentalTooth3dCanvasWidgetState.rotatePoint(p1.x, p1.y, p1.z, rotX, rotY);
    final r2 = _DentalTooth3dCanvasWidgetState.rotatePoint(p2.x, p2.y, p2.z, rotX, rotY);
    final r3 = _DentalTooth3dCanvasWidgetState.rotatePoint(p3.x, p3.y, p3.z, rotX, rotY);

    const distance = 450.0;
    final f0 = distance / (distance - r0.z);
    final f1 = distance / (distance - r1.z);
    final f2 = distance / (distance - r2.z);
    final f3 = distance / (distance - r3.z);

    final s0 = Offset(center.dx + r0.x * scale * f0, center.dy + r0.y * scale * f0);
    final s1 = Offset(center.dx + r1.x * scale * f1, center.dy + r1.y * scale * f1);
    final s2 = Offset(center.dx + r2.x * scale * f2, center.dy + r2.y * scale * f2);
    final s3 = Offset(center.dx + r3.x * scale * f3, center.dy + r3.y * scale * f3);

    // Tri 1: (p0, p1, p3)
    final norm1 = _triangleNormal(r0, r1, r3);
    final shade1 = (_dot(norm1, _light) * 0.45 + 0.55).clamp(0.25, 1.0);
    final litColor1 = Color.lerp(baseColor, Colors.white, (shade1 - 0.5).clamp(0.0, 1.0) * 0.45)!;
    final depth1 = (r0.z + r1.z + r3.z) / 3;

    allTriangles.add(
      _ProjectedTriangle(a: s0, b: s1, c: s3, depth: depth1, color: litColor1),
    );

    // Tri 2: (p1, p2, p3)
    final norm2 = _triangleNormal(r1, r2, r3);
    final shade2 = (_dot(norm2, _light) * 0.45 + 0.55).clamp(0.25, 1.0);
    final litColor2 = Color.lerp(baseColor, Colors.white, (shade2 - 0.5).clamp(0.0, 1.0) * 0.45)!;
    final depth2 = (r1.z + r2.z + r3.z) / 3;

    allTriangles.add(
      _ProjectedTriangle(a: s1, b: s2, c: s3, depth: depth2, color: litColor2),
    );
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
        final rotated = _DentalTooth3dCanvasWidgetState.rotatePoint(wx, wy, wz, rotX, rotY);
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

    // Periodontal pocket indicator badge
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
        oldDelegate.isDark != isDark ||
        oldDelegate.showGums != showGums;
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
