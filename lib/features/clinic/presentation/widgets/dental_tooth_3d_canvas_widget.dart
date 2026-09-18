import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/localization/app_language.dart';
import '../../domain/entities/clinical_anatomy_status_entry.dart';
import '../../domain/entities/tooth_chart_entry.dart';
import 'tooth_glb_mesh.dart';

export '../../domain/entities/anatomical_engine_models.dart';

/// Specialized 3D Dental Surgical Hardware, Implants, and Clinical Instruments
enum DentalSurgicalInstrument {
  none(
    id: 'none',
    titleEn: 'Natural Tooth Anatomy',
    titleAr: 'التشريح الطبيعي للسن',
    icon: LucideIcons.scan,
    color: Color(0xFF38BDF8),
  ),
  implantFixture(
    id: 'implant',
    titleEn: 'Titanium Implant Fixture',
    titleAr: 'غرسة تيتانيوم لولبية',
    icon: LucideIcons.shieldCheck,
    color: Color(0xFF94A3B8),
  ),
  endoRotaryFile(
    id: 'endo_file',
    titleEn: 'NiTi Rotary Canal File',
    titleAr: 'مبرد روتاري لعلاج الجذور',
    icon: LucideIcons.zap,
    color: Color(0xFFF59E0B),
  ),
  cavityPrep(
    id: 'cavity_prep',
    titleEn: 'Cavity Drill Preparation',
    titleAr: 'تحضير تجويف حفر',
    icon: LucideIcons.circleDot,
    color: Color(0xFFEF4444),
  ),
  compositeFilling(
    id: 'composite_filling',
    titleEn: 'Composite Resin Restoration',
    titleAr: 'حشوة كمبوزيت تجميلية',
    icon: LucideIcons.sparkles,
    color: Color(0xFF10B981),
  ),
  prostheticCrown(
    id: 'prosthetic_crown',
    titleEn: 'Zirconia / Ceramic Crown',
    titleAr: 'تاج زيركونيا تعويضي',
    icon: LucideIcons.crown,
    color: Color(0xFF8B5CF6),
  ),
  orthoBracket(
    id: 'ortho_bracket',
    titleEn: 'Orthodontic Slot Bracket',
    titleAr: 'حاصرة وسلك تقويم الأسنان',
    icon: LucideIcons.gitCommit,
    color: Color(0xFF06B6D4),
  );

  final String id;
  final String titleEn;
  final String titleAr;
  final IconData icon;
  final Color color;

  const DentalSurgicalInstrument({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.color,
  });

  String get localizedTitle => AppLanguage.isArabic ? titleAr : titleEn;
}

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
  late final ValueNotifier<bool> _isSoloToothModeNotifier;
  late final ValueNotifier<DentalSurgicalInstrument> _activeInstrumentNotifier;
  late final ValueNotifier<bool> _showPulpNotifier;
  Timer? _warningTimer;
  double _baseScale = 1.1;

  @override
  void initState() {
    super.initState();
    _rotX = ValueNotifier<double>(0.35);
    _rotY = ValueNotifier<double>(0.0);
    _scale = ValueNotifier<double>(1.1);
    _panOffset = ValueNotifier<Offset>(Offset.zero);
    _showGumsNotifier = ValueNotifier<bool>(true);
    _emptySpaceWarningNotifier = ValueNotifier<String?>(null);
    _isSoloToothModeNotifier = ValueNotifier<bool>(false);
    _activeInstrumentNotifier = ValueNotifier<DentalSurgicalInstrument>(DentalSurgicalInstrument.none);
    _showPulpNotifier = ValueNotifier<bool>(false);
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
    _isSoloToothModeNotifier.dispose();
    _activeInstrumentNotifier.dispose();
    _showPulpNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
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
                      child: Listener(
                        onPointerSignal: (pointerSignal) {
                          if (pointerSignal is PointerScrollEvent) {
                            if (pointerSignal.scrollDelta.dy < 0) {
                              _scale.value = (_scale.value + 0.1).clamp(0.6, 2.5);
                            } else if (pointerSignal.scrollDelta.dy > 0) {
                              _scale.value = (_scale.value - 0.1).clamp(0.6, 2.5);
                            }
                          }
                        },
                        child: GestureDetector(
                          onScaleStart: (_) {
                            _baseScale = _scale.value;
                          },
                          onScaleUpdate: (details) {
                            if (details.pointerCount == 1) {
                              _rotY.value += details.focalPointDelta.dx * 0.012;
                              _rotX.value = (_rotX.value - details.focalPointDelta.dy * 0.012)
                                  .clamp(-1.2, 1.2);
                            } else {
                              _scale.value = (_baseScale * details.scale).clamp(0.6, 2.5);
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
                            _isSoloToothModeNotifier,
                            _activeInstrumentNotifier,
                            _showPulpNotifier,
                          ]),
                          builder: (context, _) {
                            final center = Offset(canvasW / 2 + _panOffset.value.dx, canvasH / 2 + _panOffset.value.dy);
                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned.fill(
                                  child: RepaintBoundary(
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
                                        isSoloMode: _isSoloToothModeNotifier.value,
                                        soloTooth: widget.selectedTooth ??
                                            (widget.toothChart.isNotEmpty
                                                ? widget.toothChart.firstWhere(
                                                    (t) => t.effectiveToothCode == '16',
                                                    orElse: () => widget.toothChart.first,
                                                  )
                                                : null),
                                        activeInstrument: _activeInstrumentNotifier.value,
                                        showPulp: _showPulpNotifier.value,
                                      ),
                                    ),
                                  ),
                                ),
                                // ── DYNAMIC 3D PROJECTED PIN MARKERS ──────────
                                // Pins rotate, scale, and pan naturally in 3D perspective with the dental model!
                                if (widget.activeStatuses != null && !_isSoloToothModeNotifier.value)
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
                  ),
                  Positioned.fill(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isSoloToothModeNotifier,
                      builder: (context, isSolo, _) {
                        if (isSolo) {
                          return Stack(
                            children: [
                              _buildSoloHeader(widget.selectedTooth),
                              _buildSoloPresetsDock(),
                              _zoomControls(),
                              _buildSoloInstrumentSelectorBar(),
                            ],
                          );
                        }
                        return Stack(
                          children: [
                            _cameraPresetsDock(),
                            _zoomControls(),
                            _bottomBar(widget.selectedTooth),
                          ],
                        );
                      },
                    ),
                  ),
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
          left: (screenX - 16).clamp(4.0, (canvasW - 32.0).clamp(4.0, double.infinity)),
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
      child: RepaintBoundary(
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
                          color: showGums ? Colors.pinkAccent.withValues(alpha: 0.35) : Colors.white10,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: showGums ? Colors.pinkAccent : Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              showGums ? LucideIcons.smile : LucideIcons.frown,
                              size: 13,
                              color: showGums ? Colors.pinkAccent : Colors.white60,
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
      ),
    );
  }

  Widget _zoomControls() {
    return Positioned(
      top: 12,
      right: 12,
      child: RepaintBoundary(
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
      ),
    );
  }

  Widget _bottomBar(ToothChartEntry? selectedTooth) {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: RepaintBoundary(
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
              const SizedBox(width: 8),
              GestureDetector(
                key: const Key('btn_solo_tooth_3d'),
                onTap: () => _isSoloToothModeNotifier.value = true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.scan, size: 12, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 4),
                      Text(
                        AppLanguage.tr('Solo Tooth 3D', 'عرض السن 3D'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(width: 8),
              GestureDetector(
                key: const Key('btn_solo_tooth_3d'),
                onTap: () => _isSoloToothModeNotifier.value = true,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF38BDF8)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.scan, size: 12, color: Color(0xFF38BDF8)),
                      const SizedBox(width: 4),
                      Text(
                        AppLanguage.tr('Solo Tooth 3D', 'عرض السن 3D'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSoloHeader(ToothChartEntry? selectedTooth) {
    final entry = selectedTooth ??
        (widget.toothChart.isNotEmpty
            ? widget.toothChart.firstWhere((t) => t.effectiveToothCode == '16', orElse: () => widget.toothChart.first)
            : null);
    final fdi = entry?.fdiNumber ?? '16';
    final categoryName = entry != null
        ? AppLanguage.tr(entry.category.name.toUpperCase(), entry.category.name)
        : 'MOLAR';

    return Positioned(
      top: 12,
      left: 12,
      right: 120,
      child: RepaintBoundary(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Back Button to Full Arch
              GestureDetector(
                key: const Key('btn_return_full_arch'),
                onTap: () => _isSoloToothModeNotifier.value = false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0284C7),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(LucideIcons.arrowLeft, size: 14, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        AppLanguage.tr('Full Arch', 'القوس السني الكامل'),
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
              const SizedBox(width: 8),

              // Tooth Info Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.scan, size: 13, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 5),
                    Text(
                      'FDI $fdi • $categoryName (${AppLanguage.tr("Solo 3D", "معاينة ثلاثية الأبعاد")})',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Pulp & Canals Toggle
              ValueListenableBuilder<bool>(
                valueListenable: _showPulpNotifier,
                builder: (context, showPulp, _) {
                  return GestureDetector(
                    key: const Key('btn_toggle_pulp'),
                    onTap: () => _showPulpNotifier.value = !_showPulpNotifier.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: showPulp
                            ? const Color(0xFFE11D48).withValues(alpha: 0.35)
                            : Colors.black.withValues(alpha: 0.65),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: showPulp ? const Color(0xFFE11D48) : Colors.white24,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            LucideIcons.zap,
                            size: 13,
                            color: showPulp ? const Color(0xFFF43F5E) : Colors.white70,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            showPulp
                                ? AppLanguage.tr('Pulp: ON', 'العصب والقنوات: مفعل')
                                : AppLanguage.tr('Pulp: OFF', 'العصب والقنوات: مخفي'),
                            style: TextStyle(
                              color: showPulp ? Colors.white : Colors.white70,
                              fontSize: 11,
                              fontWeight: showPulp ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoloPresetsDock() {
    return Positioned(
      top: 52,
      left: 12,
      right: 120,
      child: RepaintBoundary(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _presetButton('Front 3D', () {
                  _rotX.value = 0.2;
                  _rotY.value = 0.0;
                  _scale.value = 1.1;
                  _panOffset.value = Offset.zero;
                }),
                const SizedBox(width: 4),
                _presetButton('Occlusal (Cusps)', () {
                  _rotX.value = 1.45;
                  _rotY.value = 0.0;
                  _scale.value = 1.1;
                  _panOffset.value = Offset.zero;
                }),
                const SizedBox(width: 4),
                _presetButton('Lingual / Palatal', () {
                  _rotX.value = 0.2;
                  _rotY.value = math.pi;
                  _scale.value = 1.1;
                  _panOffset.value = Offset.zero;
                }),
                const SizedBox(width: 4),
                _presetButton('Mesial Proximal', () {
                  _rotX.value = 0.1;
                  _rotY.value = math.pi / 2;
                  _scale.value = 1.1;
                  _panOffset.value = Offset.zero;
                }),
                const SizedBox(width: 4),
                _presetButton('Root Apical', () {
                  _rotX.value = -1.45;
                  _rotY.value = 0.0;
                  _scale.value = 1.1;
                  _panOffset.value = Offset.zero;
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSoloInstrumentSelectorBar() {
    return Positioned(
      bottom: 12,
      left: 12,
      right: 12,
      child: RepaintBoundary(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Row(
                  children: [
                    const Icon(LucideIcons.wrench, size: 12, color: Color(0xFF38BDF8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppLanguage.tr(
                          '3D Dental Instruments & Surgical Hardware:',
                          'أدوات الجراحة والعتاد الطبي السني 3D:',
                        ),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              ValueListenableBuilder<DentalSurgicalInstrument>(
                valueListenable: _activeInstrumentNotifier,
                builder: (context, activeInst, _) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: DentalSurgicalInstrument.values.map((inst) {
                        final isSelected = activeInst == inst;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: GestureDetector(
                            onTap: () => _activeInstrumentNotifier.value = inst,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? inst.color.withValues(alpha: 0.3)
                                    : Colors.white.withValues(alpha: 0.06),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected ? inst.color : Colors.white12,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    inst.icon,
                                    size: 12,
                                    color: isSelected ? inst.color : Colors.white60,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    inst.localizedTitle,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: isSelected ? Colors.white : Colors.white70,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
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
      const distance = 450.0;
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
  final bool isSoloMode;
  final ToothChartEntry? soloTooth;
  final DentalSurgicalInstrument activeInstrument;
  final bool showPulp;

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
    this.isSoloMode = false,
    this.soloTooth,
    this.activeInstrument = DentalSurgicalInstrument.none,
    this.showPulp = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2 + pan.dx, size.height / 2 + pan.dy);
    _drawGridBackground(canvas, size, center);

    if (isSoloMode) {
      _renderRealisticSoloTooth(
        canvas: canvas,
        size: size,
        center: center,
        tooth: soloTooth ?? (toothChart.isNotEmpty ? toothChart.first : null),
        instrument: activeInstrument,
        showPulp: showPulp,
      );
      return;
    }

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
    final vertexScale = categoryScale / meshHeight;
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
        final wx = archX + v[0] * vertexScale;
        final wy = archY + localY * vertexScale;
        final wz = archZ + v[2] * vertexScale;
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

    final fallbackRotated = _DentalTooth3dCanvasWidgetState.rotatePoint(archX, archY, archZ, rotX, rotY);
    final crownCenter = crownCount > 0
        ? Offset(crownSumX / crownCount, crownSumY / crownCount)
        : Offset(
            center.dx + fallbackRotated.x * scale * fov,
            center.dy + fallbackRotated.y * scale * fov,
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

  void _renderRealisticSoloTooth({
    required Canvas canvas,
    required Size size,
    required Offset center,
    required ToothChartEntry? tooth,
    required DentalSurgicalInstrument instrument,
    required bool showPulp,
  }) {
    final category = tooth?.category ?? ToothCategory.molar;
    final fdi = int.tryParse(tooth?.fdiNumber ?? '16') ?? 16;
    final isUpper = fdi ~/ 10 <= 2;
    const distance = 450.0;
    final effectiveScale = scale * 3.8;

    final allTriangles = <_ProjectedTriangle>[];

    _Point3d rotAndProj(double wx, double wy, double wz) {
      final r = _DentalTooth3dCanvasWidgetState.rotatePoint(wx, wy, wz, rotX, rotY);
      final fov = distance / (distance - r.z);
      final sx = center.dx + r.x * effectiveScale * fov;
      final sy = center.dy + r.y * effectiveScale * fov;
      return _Point3d(sx, sy, r.z);
    }

    void addTri(_Point3d w1, _Point3d w2, _Point3d w3, Color col,
        {double specPower = 20.0, double specVal = 0.55, double alpha = 1.0}) {
      final norm = _triangleNormal(w1, w2, w3);
      final p1 = rotAndProj(w1.x, w1.y, w1.z);
      final p2 = rotAndProj(w2.x, w2.y, w2.z);
      final p3 = rotAndProj(w3.x, w3.y, w3.z);

      final rNorm = _DentalTooth3dCanvasWidgetState.rotatePoint(norm.x, norm.y, norm.z, rotX, rotY);
      final diff = (_dot(rNorm, _light) * 0.5 + 0.5).clamp(0.22, 1.0);
      final nDotL = _dot(rNorm, _light);
      final rz = 2 * nDotL * rNorm.z - _light.z;
      final spec = math.pow(rz.clamp(0.0, 1.0), specPower) * specVal;

      final lit = Color.lerp(col, Colors.white, (diff * 0.45 + spec * 0.55).clamp(0.0, 1.0))!
          .withValues(alpha: alpha);
      final avgZ = (p1.z + p2.z + p3.z) / 3.0;

      allTriangles.add(_ProjectedTriangle(
        a: Offset(p1.x, p1.y),
        b: Offset(p2.x, p2.y),
        c: Offset(p3.x, p3.y),
        depth: avgZ,
        color: lit,
      ));
    }

    void addQuad(_Point3d a, _Point3d b, _Point3d c, _Point3d d, Color col,
        {double specPower = 20.0, double specVal = 0.55, double alpha = 1.0}) {
      addTri(a, b, c, col, specPower: specPower, specVal: specVal, alpha: alpha);
      addTri(a, c, d, col, specPower: specPower, specVal: specVal, alpha: alpha);
    }

    void addCylinder(
      _Point3d bottom,
      _Point3d top,
      double radiusBottom,
      double radiusTop,
      Color col, {
      int segments = 8,
      double specPower = 20.0,
      double specVal = 0.55,
      double alpha = 1.0,
    }) {
      for (var i = 0; i < segments; i++) {
        final a0 = (i / segments) * 2 * math.pi;
        final a1 = ((i + 1) / segments) * 2 * math.pi;
        final c0 = math.cos(a0);
        final s0 = math.sin(a0);
        final c1 = math.cos(a1);
        final s1 = math.sin(a1);

        final b0 = _Point3d(bottom.x + c0 * radiusBottom, bottom.y, bottom.z + s0 * radiusBottom);
        final b1 = _Point3d(bottom.x + c1 * radiusBottom, bottom.y, bottom.z + s1 * radiusBottom);
        final t0 = _Point3d(top.x + c0 * radiusTop, top.y, top.z + s0 * radiusTop);
        final t1 = _Point3d(top.x + c1 * radiusTop, top.y, top.z + s1 * radiusTop);

        addQuad(b0, b1, t1, t0, col, specPower: specPower, specVal: specVal, alpha: alpha);
      }
    }

    final crownSign = isUpper ? 1.0 : -1.0;
    final rootSign = -crownSign;
    final isTranslucent = showPulp || instrument == DentalSurgicalInstrument.endoRotaryFile;
    final enamelAlpha = isTranslucent ? 0.45 : 0.95;
    const baseEnamel = Color(0xFFFBFBF8);
    const cementumColor = Color(0xFFEADBBE);

    // ── 1. REALISTIC 3D ANATOMICAL CROWN MESH ────────────────────────────────
    final isCrownRestoration = instrument == DentalSurgicalInstrument.prostheticCrown;
    final crownColor = isCrownRestoration ? const Color(0xFFEEF2FF) : baseEnamel;
    final crownSpec = isCrownRestoration ? 0.85 : 0.55;
    final crownSpecPower = isCrownRestoration ? 32.0 : 20.0;

    if (category == ToothCategory.molar) {
      // 4 Anatomical cusps
      final mbCusp = _Point3d(-10, crownSign * 22, 9);
      final dbCusp = _Point3d(10, crownSign * 21, 8);
      final mlCusp = _Point3d(-9, crownSign * 21, -9);
      final dlCusp = _Point3d(9, crownSign * 20, -8);

      final centralPit = _Point3d(0, crownSign * 13, 0);
      final mesialPit = _Point3d(-6, crownSign * 14.5, 0);
      final distalPit = _Point3d(6, crownSign * 14.5, 0);

      // Occlusal triangular ridges & fissures
      addTri(mbCusp, mesialPit, centralPit, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(mlCusp, centralPit, mesialPit, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(dbCusp, centralPit, distalPit, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(dlCusp, distalPit, centralPit, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);

      // Marginal ridges
      final mesialRidge = _Point3d(-13, crownSign * 17, 0);
      final distalRidge = _Point3d(13, crownSign * 16.5, 0);
      addTri(mbCusp, mesialRidge, mesialPit, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(mlCusp, mesialPit, mesialRidge, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(dbCusp, distalPit, distalRidge, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(dlCusp, distalRidge, distalPit, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);

      // Mid-coronal axial ring (8 vertices)
      final midAxial = <_Point3d>[
        _Point3d(-14, crownSign * 8, 0),
        _Point3d(-10, crownSign * 8, 12),
        _Point3d(0, crownSign * 8, 14),
        _Point3d(10, crownSign * 8, 12),
        _Point3d(14, crownSign * 8, 0),
        _Point3d(10, crownSign * 8, -12),
        _Point3d(0, crownSign * 8, -14),
        _Point3d(-10, crownSign * 8, -12),
      ];

      // Cervical CEJ ring (8 vertices)
      final cejRing = <_Point3d>[
        _Point3d(-11, 0, 0),
        _Point3d(-8, 0, 9),
        _Point3d(0, 0, 11),
        _Point3d(8, 0, 9),
        _Point3d(11, 0, 0),
        _Point3d(8, 0, -9),
        _Point3d(0, 0, -11),
        _Point3d(-8, 0, -9),
      ];

      // Connect cusps to midAxial ring
      addQuad(mbCusp, dbCusp, midAxial[3], midAxial[1], crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addQuad(mlCusp, midAxial[7], midAxial[5], dlCusp, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addQuad(mbCusp, midAxial[1], midAxial[7], mlCusp, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addQuad(dbCusp, dlCusp, midAxial[5], midAxial[3], crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);

      // Connect midAxial ring to CEJ ring
      for (var i = 0; i < 8; i++) {
        final next = (i + 1) % 8;
        addQuad(midAxial[i], midAxial[next], cejRing[next], cejRing[i], crownColor,
            specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      }
    } else {
      // Premolar / Anterior tooth crown
      final incisalTop = _Point3d(0, crownSign * 22, 1);
      final incisalM = _Point3d(-10, crownSign * 20, 0);
      final incisalD = _Point3d(10, crownSign * 20, 0);
      final cingulum = _Point3d(0, crownSign * 6, -7);

      final cejRing = <_Point3d>[
        _Point3d(-8, 0, 0),
        _Point3d(-6, 0, 7),
        _Point3d(0, 0, 9),
        _Point3d(6, 0, 7),
        _Point3d(8, 0, 0),
        _Point3d(6, 0, -7),
        _Point3d(0, 0, -9),
        _Point3d(-6, 0, -7),
      ];

      addTri(incisalTop, incisalM, cejRing[2], crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(incisalTop, cejRing[2], incisalD, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(incisalTop, cingulum, incisalM, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      addTri(incisalTop, incisalD, cingulum, crownColor, specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);

      for (var i = 0; i < 8; i++) {
        final next = (i + 1) % 8;
        addTri(cejRing[i], cejRing[next], cingulum, crownColor,
            specPower: crownSpecPower, specVal: crownSpec, alpha: enamelAlpha);
      }
    }

    // ── 2. REALISTIC 3D ANATOMICAL ROOTS OR IMPLANT FIXTURE ──────────────────
    if (instrument == DentalSurgicalInstrument.implantFixture) {
      // Titanium Implant Fixture (threaded screw with hex platform & abutment)
      const tiHex = Color(0xFFE2E8F0);
      const tiCollar = Color(0xFFCBD5E1);
      const tiBody = Color(0xFF64748B);
      const tiCrest = Color(0xFF94A3B8);

      // Abutment post on top
      addCylinder(_Point3d(0, 0, 0), _Point3d(0, crownSign * 7, 0), 4.5, 3.2, tiHex,
          specPower: 30.0, specVal: 0.8);

      // Polished Collar
      addCylinder(_Point3d(0, 0, 0), _Point3d(0, rootSign * 5, 0), 6.2, 5.8, tiCollar,
          specPower: 30.0, specVal: 0.8);

      // Threaded Body (10 helical thread rings)
      const numThreads = 10;
      const threadSpan = 32.0;
      for (var i = 0; i < numThreads; i++) {
        final y0 = rootSign * (5.0 + (i / numThreads) * threadSpan);
        final y1 = rootSign * (5.0 + ((i + 0.5) / numThreads) * threadSpan);
        final y2 = rootSign * (5.0 + ((i + 1.0) / numThreads) * threadSpan);

        final taper0 = 1.0 - (i / numThreads) * 0.45;
        final taper1 = 1.0 - ((i + 0.5) / numThreads) * 0.45;
        final taper2 = 1.0 - ((i + 1.0) / numThreads) * 0.45;

        // Trough -> Crest -> Trough
        addCylinder(_Point3d(0, y0, 0), _Point3d(0, y1, 0), 5.2 * taper0, 6.4 * taper1, tiCrest,
            specPower: 26.0, specVal: 0.7);
        addCylinder(_Point3d(0, y1, 0), _Point3d(0, y2, 0), 6.4 * taper1, 4.8 * taper2, tiBody,
            specPower: 26.0, specVal: 0.7);
      }
      // Apical Dome
      addCylinder(_Point3d(0, rootSign * 37, 0), _Point3d(0, rootSign * 40, 0), 2.8, 0.5, tiBody,
          specPower: 20.0, specVal: 0.6);
    } else {
      // Natural Anatomical Roots
      if (category == ToothCategory.molar) {
        if (isUpper) {
          // 3 Roots for Upper Molar: Palatal, Mesiobuccal, Distobuccal
          addCylinder(_Point3d(0, 0, -5), _Point3d(0, rootSign * 36, -12), 4.6, 1.8, cementumColor);
          addCylinder(_Point3d(-6, 0, 4), _Point3d(-10, rootSign * 33, 6), 4.0, 1.6, cementumColor);
          addCylinder(_Point3d(6, 0, 4), _Point3d(9, rootSign * 31, 5), 3.8, 1.5, cementumColor);
        } else {
          // 2 Roots for Lower Molar: Mesial, Distal
          addCylinder(_Point3d(-6, 0, 0), _Point3d(-9, rootSign * 35, 1), 4.8, 2.0, cementumColor);
          addCylinder(_Point3d(6, 0, 0), _Point3d(8, rootSign * 33, 0), 4.5, 1.8, cementumColor);
        }
      } else {
        // Single Tapered Root
        addCylinder(_Point3d(0, 0, 0), _Point3d(2, rootSign * 37, 0), 4.8, 1.6, cementumColor);
      }

      // ── PERIODONTAL APPARATUS: PDL, ALVEOLAR BONE & GINGIVAL COLLAR ──────
      // 1. Periodontal Ligament (PDL) Fibrous Sleeve wrapping root
      const pdlColor = Color(0xFFF472B6);
      if (category == ToothCategory.molar) {
        addCylinder(_Point3d(0, rootSign * 4, 0), _Point3d(0, rootSign * 28, 0), 9.2, 5.5, pdlColor,
            alpha: 0.35);
      } else {
        addCylinder(_Point3d(0, rootSign * 3, 0), _Point3d(2, rootSign * 32, 0), 6.4, 2.8, pdlColor,
            alpha: 0.35);
      }

      // 2. Alveolar Bone Socket (Lamina Dura & Cribriform Plate)
      const boneSocketColor = Color(0xFFE2E8F0);
      addCylinder(_Point3d(0, rootSign * 6, 0), _Point3d(0, rootSign * 38, 0), 12.0, 7.5, boneSocketColor,
          alpha: 0.4);

      // 3. Attached Keratinized Gingiva Collar & Free Gingival Margin
      const gingivaColor = Color(0xFFFDA4AF);
      final gingivaY = rootSign * 3.0;
      addCylinder(_Point3d(0, 0, 0), _Point3d(0, gingivaY, 0), 12.5, 11.5, gingivaColor,
          specPower: 16.0, specVal: 0.5, alpha: 0.85);
    }

    // ── 3. INTERNAL PULP CHAMBER & ROOT CANALS ───────────────────────────────
    if (isTranslucent) {
      const pulpColor = Color(0xFFE11D48);
      // Coronal pulp chamber
      addCylinder(_Point3d(0, 0, 0), _Point3d(0, crownSign * 7, 0), 2.8, 2.2, pulpColor,
          specPower: 12.0, specVal: 0.4);

      // Pulp horns
      if (category == ToothCategory.molar) {
        addCylinder(_Point3d(-6, crownSign * 7, 6), _Point3d(-8, crownSign * 16, 7), 1.4, 0.4, pulpColor);
        addCylinder(_Point3d(6, crownSign * 7, 6), _Point3d(8, crownSign * 15, 6), 1.4, 0.4, pulpColor);
        addCylinder(_Point3d(-6, crownSign * 7, -6), _Point3d(-7, crownSign * 15, -7), 1.4, 0.4, pulpColor);
        addCylinder(_Point3d(6, crownSign * 7, -6), _Point3d(7, crownSign * 14, -6), 1.4, 0.4, pulpColor);

        // Root canals descending to apex
        if (isUpper) {
          addCylinder(_Point3d(0, 0, -5), _Point3d(0, rootSign * 35, -12), 1.6, 0.5, pulpColor);
          addCylinder(_Point3d(-6, 0, 4), _Point3d(-10, rootSign * 32, 6), 1.4, 0.4, pulpColor);
          addCylinder(_Point3d(6, 0, 4), _Point3d(9, rootSign * 30, 5), 1.3, 0.4, pulpColor);
        } else {
          addCylinder(_Point3d(-6, 0, 0), _Point3d(-9, rootSign * 34, 1), 1.8, 0.6, pulpColor);
          addCylinder(_Point3d(6, 0, 0), _Point3d(8, rootSign * 32, 0), 1.6, 0.5, pulpColor);
        }
      } else {
        addCylinder(_Point3d(0, crownSign * 7, 0), _Point3d(0, crownSign * 17, 0), 1.8, 0.5, pulpColor);
        addCylinder(_Point3d(0, 0, 0), _Point3d(2, rootSign * 36, 0), 1.8, 0.5, pulpColor);
      }
    }

    // ── 4. SPECIALIZED 3D SURGICAL INSTRUMENTS ───────────────────────────────
    if (instrument == DentalSurgicalInstrument.endoRotaryFile) {
      // Golden NiTi Rotary File descending into canal
      const nitiGold = Color(0xFFF59E0B);
      const handleBlue = Color(0xFF0284C7);

      // Handpiece contra-angle latch handle at coronal entrance
      addCylinder(_Point3d(0, crownSign * 24, 0), _Point3d(0, crownSign * 34, 0), 3.4, 3.4, handleBlue,
          specPower: 30.0, specVal: 0.8);

      // NiTi Shaft with calibration rings
      addCylinder(_Point3d(0, crownSign * 12, 0), _Point3d(0, crownSign * 24, 0), 1.8, 2.2, nitiGold,
          specPower: 36.0, specVal: 0.9);

      // Spiral fluted blade down root canal
      final canalApex = isUpper ? _Point3d(-10, rootSign * 32, 6) : _Point3d(-9, rootSign * 34, 1);
      addCylinder(_Point3d(0, crownSign * 12, 0), canalApex, 1.8, 0.6, nitiGold,
          specPower: 36.0, specVal: 0.9);
    } else if (instrument == DentalSurgicalInstrument.cavityPrep) {
      // Class I / II Cavity Drill Preparation Box
      const floorDentin = Color(0xFFB45309);
      const wallDentin = Color(0xFFD97706);
      final p0 = _Point3d(-6, crownSign * 11, -5);
      final p1 = _Point3d(6, crownSign * 11, -5);
      final p2 = _Point3d(6, crownSign * 11, 5);
      final p3 = _Point3d(-6, crownSign * 11, 5);

      final w0 = _Point3d(-6, crownSign * 17, -5);
      final w1 = _Point3d(6, crownSign * 17, -5);
      final w2 = _Point3d(6, crownSign * 17, 5);
      final w3 = _Point3d(-6, crownSign * 17, 5);

      // Cavity Floor
      addQuad(p0, p1, p2, p3, floorDentin, specPower: 12.0, specVal: 0.3);
      // Cavity Walls
      addQuad(p0, w0, w1, p1, wallDentin, specPower: 14.0, specVal: 0.4);
      addQuad(p1, w1, w2, p2, wallDentin, specPower: 14.0, specVal: 0.4);
      addQuad(p2, w2, w3, p3, wallDentin, specPower: 14.0, specVal: 0.4);
      addQuad(p3, w3, w0, p0, wallDentin, specPower: 14.0, specVal: 0.4);
    } else if (instrument == DentalSurgicalInstrument.compositeFilling) {
      // Sculpted Composite Resin Restoration
      const resinColor = Color(0xFFF8FAFC);
      const cureGlow = Color(0xFF38BDF8);
      final p0 = _Point3d(-6, crownSign * 14, -5);
      final p1 = _Point3d(6, crownSign * 14, -5);
      final p2 = _Point3d(6, crownSign * 14, 5);
      final p3 = _Point3d(-6, crownSign * 14, 5);
      final centerFossa = _Point3d(0, crownSign * 13, 0);

      addTri(p0, p1, centerFossa, resinColor, specPower: 28.0, specVal: 0.85);
      addTri(p1, p2, centerFossa, resinColor, specPower: 28.0, specVal: 0.85);
      addTri(p2, p3, centerFossa, cureGlow, specPower: 28.0, specVal: 0.85);
      addTri(p3, p0, centerFossa, cureGlow, specPower: 28.0, specVal: 0.85);
    } else if (instrument == DentalSurgicalInstrument.orthoBracket) {
      // Stainless Steel Orthodontic Slot Bracket & Archwire
      const ssChrome = Color(0xFFE2E8F0);
      const ssPad = Color(0xFF64748B);
      const wireColor = Color(0xFF94A3B8);
      const oRingCyan = Color(0xFF06B6D4);

      final by = crownSign * 9.0;
      const bz = 13.5;

      // Base Pad
      addQuad(_Point3d(-7, by - 5, bz), _Point3d(7, by - 5, bz),
          _Point3d(7, by + 5, bz), _Point3d(-7, by + 5, bz), ssPad,
          specPower: 20.0, specVal: 0.5);

      // Bracket Body Wings
      addQuad(_Point3d(-6, by - 4, bz + 2), _Point3d(6, by - 4, bz + 2),
          _Point3d(6, by + 4, bz + 2), _Point3d(-6, by + 4, bz + 2), ssChrome,
          specPower: 32.0, specVal: 0.9);

      // Cyan Elastomeric O-Ring Ligature
      addQuad(_Point3d(-5, by - 3, bz + 3), _Point3d(5, by - 3, bz + 3),
          _Point3d(5, by + 3, bz + 3), _Point3d(-5, by + 3, bz + 3), oRingCyan,
          specPower: 16.0, specVal: 0.6);

      // 0.022" Rectangular NiTi Archwire running horizontally through slot
      addCylinder(_Point3d(-18, by, bz + 3.5), _Point3d(18, by, bz + 3.5), 1.1, 1.1, wireColor,
          specPower: 32.0, specVal: 0.9);
    }

    // ── 5. DEPTH-SORT & RENDER TRIANGLES ─────────────────────────────────────
    allTriangles.sort((a, b) => a.depth.compareTo(b.depth));
    for (final tri in allTriangles) {
      final path = Path()
        ..moveTo(tri.a.dx, tri.a.dy)
        ..lineTo(tri.b.dx, tri.b.dy)
        ..lineTo(tri.c.dx, tri.c.dy)
        ..close();
      canvas.drawPath(path, Paint()..color = tri.color);
    }

    // ── 6. 3D CLINICAL ANNOTATION CALLOUTS ────────────────────────────────────
    final crownLabel = rotAndProj(0, crownSign * 24, 0);
    final cejLabel = rotAndProj(13, 0, 0);
    final apexLabel = rotAndProj(0, rootSign * 38, 0);

    void drawCallout(Offset pt, String text, Color col) {
      final tp = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: col,
            shadows: const [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.drawCircle(pt, 3.5, Paint()..color = col);
      tp.paint(canvas, Offset(pt.dx + 6, pt.dy - tp.height / 2));
    }

    drawCallout(Offset(crownLabel.x, crownLabel.y), AppLanguage.tr('Crown / Enamel', 'التاج والميناء'), const Color(0xFF38BDF8));
    drawCallout(Offset(cejLabel.x, cejLabel.y), AppLanguage.tr('CEJ Cervical Margin', 'عنق السن CEJ'), const Color(0xFF10B981));
    if (instrument == DentalSurgicalInstrument.implantFixture) {
      drawCallout(Offset(apexLabel.x, apexLabel.y), AppLanguage.tr('Titanium Apex', 'ذروة الغرسة'), const Color(0xFF94A3B8));
    } else {
      drawCallout(Offset(apexLabel.x, apexLabel.y), AppLanguage.tr('Root Apex', 'ذروة الجذر'), const Color(0xFFF59E0B));
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
        oldDelegate.showGums != showGums ||
        oldDelegate.isSoloMode != isSoloMode ||
        oldDelegate.soloTooth != soloTooth ||
        oldDelegate.activeInstrument != activeInstrument ||
        oldDelegate.showPulp != showPulp;
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
