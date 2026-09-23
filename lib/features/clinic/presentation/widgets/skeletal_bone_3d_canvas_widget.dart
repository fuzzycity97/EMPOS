import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/localization/app_language.dart';
import '../../domain/entities/clinical_anatomy_status_entry.dart';

/// Skeletal Age Stage for Anatomical Morphing
enum SkeletalAgeStage {
  pediatric(
    'Pediatric',
    'الأطفال (نمو)',
    'Open cranial fontanelles, active epiphyseal growth plates (physis), and unfused pelvic triradiate cartilage.',
  ),
  adult(
    'Adult',
    'البالغ (206)',
    'Fully fused sutures, closed epiphyseal lines, consolidated pelvic girdle, and normal cortical bone mineral density.',
  ),
  geriatric(
    'Geriatric',
    'كبار السن',
    'Cortical thinning, osteoporotic bone loss, thoracic kyphosis curvature, disc narrowing, and marginal osteophytes/spurs.',
  );

  final String labelEn;
  final String labelAr;
  final String description;
  const SkeletalAgeStage(this.labelEn, this.labelAr, this.description);

  String get label => AppLanguage.isArabic ? labelAr : labelEn;
}

/// 3D Skeletal Render Mode
enum SkeletalRenderMode {
  solid('Solid 3D Anatomy', 'تشريح عظمي مصمت', LucideIcons.bone),
  xray('Fluoroscopy X-Ray', 'أشعة راديوغرافية سينية', LucideIcons.scanLine),
  heatmap('Bone Density Heatmap', 'خريطة الكثافة ومناطق الخطر', LucideIcons.flame);

  final String labelEn;
  final String labelAr;
  final IconData icon;
  const SkeletalRenderMode(this.labelEn, this.labelAr, this.icon);

  String get label => AppLanguage.isArabic ? labelAr : labelEn;
}

/// Skeletal Anatomical Focus Region
enum SkeletalRegionFocus {
  full('Full Skeleton', 'كامل الهيكل العظمي'),
  cranial('Cranium & Cervical', 'الجمجمة والفقرات العنقية'),
  thoracic('Thorax & Rib Cage', 'القفص الصدري والأضلاع'),
  spine('Vertebral Column', 'العمود الفقري والفقرات'),
  pelvis('Pelvis & Hips', 'الحوض ومفصل الورك'),
  upperLimbs('Upper Extremities', 'الأطراف العلوية والكتف'),
  lowerLimbs('Lower Extremities', 'الأطراف السفلية والركبة');

  final String labelEn;
  final String labelAr;
  const SkeletalRegionFocus(this.labelEn, this.labelAr);

  String get label => AppLanguage.isArabic ? labelAr : labelEn;
}

/// Surgical Intervention & Fixation Hardware Types
enum SurgicalHardwareType {
  drillHole('Drill Hole / Burrhole', 'ثقب حفر جراحي', LucideIcons.circleDot),
  fixationPlate('Dynamic Compression Plate', 'شريحة تثبيت عظام', LucideIcons.rectangleHorizontal),
  corticalScrew('Cortical Bone Screw', 'مسمار عظمي قشري', LucideIcons.plusCircle),
  intramedullaryNail('Intramedullary Nail', 'مسمار نخاعي تداخلي', LucideIcons.spline),
  kWirePin('Kirschner Wire (K-Wire)', 'سلك كيرشنر تثبيت', LucideIcons.minus);

  final String labelEn;
  final String labelAr;
  final IconData icon;
  const SurgicalHardwareType(this.labelEn, this.labelAr, this.icon);

  String get label => AppLanguage.isArabic ? labelAr : labelEn;
}

/// 3D Vector Point
class BonePoint3D {
  final double x;
  final double y;
  final double z;

  const BonePoint3D(this.x, this.y, this.z);

  BonePoint3D operator +(BonePoint3D other) => BonePoint3D(x + other.x, y + other.y, z + other.z);
  BonePoint3D operator -(BonePoint3D other) => BonePoint3D(x - other.x, y - other.y, z - other.z);
  BonePoint3D operator *(double factor) => BonePoint3D(x * factor, y * factor, z * factor);

  double get length => math.sqrt(x * x + y * y + z * z);

  double dot(BonePoint3D other) => x * other.x + y * other.y + z * other.z;

  BonePoint3D cross(BonePoint3D other) => BonePoint3D(
        y * other.z - z * other.y,
        z * other.x - x * other.z,
        x * other.y - y * other.x,
      );

  BonePoint3D normalized() {
    final len = length;
    if (len == 0) return const BonePoint3D(0, 1, 0);
    return BonePoint3D(x / len, y / len, z / len);
  }

  BonePoint3D rotateY(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return BonePoint3D(
      x * cosA + z * sinA,
      y,
      -x * sinA + z * cosA,
    );
  }

  BonePoint3D rotateX(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return BonePoint3D(
      x,
      y * cosA - z * sinA,
      y * sinA + z * cosA,
    );
  }

  BonePoint3D transform(double yaw, double pitch) {
    return rotateY(yaw).rotateX(pitch);
  }

  BonePoint3D inverseTransform(double yaw, double pitch) {
    return rotateX(-pitch).rotateY(-yaw);
  }
}

/// A placed surgical hardware item attached to a specific bone
class BoneInterventionPoint {
  final String id;
  final String boneId;
  final SurgicalHardwareType type;
  final BonePoint3D localOffset; // relative to bone.center in local 3D space
  final BonePoint3D normal; // 3D surface normal vector on the bone
  final double length;
  final double angle;

  const BoneInterventionPoint({
    required this.id,
    required this.boneId,
    required this.type,
    required this.localOffset,
    this.normal = const BonePoint3D(0, 0, 1),
    this.length = 32.0,
    this.angle = 0.0,
  });

  BoneInterventionPoint copyWith({
    String? id,
    String? boneId,
    SurgicalHardwareType? type,
    BonePoint3D? localOffset,
    BonePoint3D? normal,
    double? length,
    double? angle,
  }) {
    return BoneInterventionPoint(
      id: id ?? this.id,
      boneId: boneId ?? this.boneId,
      type: type ?? this.type,
      localOffset: localOffset ?? this.localOffset,
      normal: normal ?? this.normal,
      length: length ?? this.length,
      angle: angle ?? this.angle,
    );
  }
}

/// 3D Bone Segment Definition
class _BoneSegment3D {
  final String id;
  final String code;
  final String nameEn;
  final String nameAr;
  final SkeletalRegionFocus region;
  final List<BonePoint3D> vertices;
  final List<List<int>> faces;
  final BonePoint3D center;
  final double hitRadius;
  final bool hasPediatricGrowthPlate;
  final bool hasGeriatricSpurRisk;
  final double boneDensityTScore;

  const _BoneSegment3D({
    required this.id,
    required this.code,
    required this.nameEn,
    required this.nameAr,
    required this.region,
    required this.vertices,
    required this.faces,
    required this.center,
    this.hitRadius = 26.0,
    this.hasPediatricGrowthPlate = false,
    this.hasGeriatricSpurRisk = false,
    this.boneDensityTScore = 0.5,
  });

  String get name => AppLanguage.isArabic ? nameAr : nameEn;
}

/// Interactive 3D Skeletal Bone Canvas Widget.
class SkeletalBone3dCanvasWidget extends StatefulWidget {
  final Map<String, ClinicalAnatomyStatusEntry>? activeStatuses;
  final String? selectedBoneId;
  final void Function(String boneCode, String nameEn, String nameAr)? onBoneSelected;
  final void Function(String boneCode, String nameEn, String nameAr)? onBoneSecondaryTap;
  final SkeletalAgeStage initialAgeStage;
  final bool initialSoloMode;
  final List<BoneInterventionPoint>? initialInterventions;
  final void Function(List<BoneInterventionPoint> interventions)? onInterventionsChanged;

  const SkeletalBone3dCanvasWidget({
    super.key,
    this.activeStatuses,
    this.selectedBoneId,
    this.onBoneSelected,
    this.onBoneSecondaryTap,
    this.initialAgeStage = SkeletalAgeStage.adult,
    this.initialSoloMode = false,
    this.initialInterventions,
    this.onInterventionsChanged,
  });

  @override
  State<SkeletalBone3dCanvasWidget> createState() => _SkeletalBone3dCanvasWidgetState();
}

class _SkeletalBone3dCanvasWidgetState extends State<SkeletalBone3dCanvasWidget> {
  late final ValueNotifier<double> _yawNotifier;
  late final ValueNotifier<double> _pitchNotifier;
  late final ValueNotifier<double> _zoomNotifier;
  late final ValueNotifier<Offset> _panNotifier;
  late final ValueNotifier<SkeletalAgeStage> _ageStageNotifier;
  late final ValueNotifier<SkeletalRenderMode> _renderModeNotifier;
  late final ValueNotifier<SkeletalRegionFocus> _focusNotifier;
  late final ValueNotifier<String?> _selectedBoneNotifier;
  late final ValueNotifier<bool> _isSoloModeNotifier;
  late final ValueNotifier<bool> _showCartilageNotifier;
  late final ValueNotifier<SurgicalHardwareType?> _activeToolNotifier;
  late final ValueNotifier<List<BoneInterventionPoint>> _interventionsNotifier;

  Offset _lastFocalPoint = Offset.zero;

  @override
  void initState() {
    super.initState();
    _yawNotifier = ValueNotifier<double>(0.0);
    _pitchNotifier = ValueNotifier<double>(0.08);
    _zoomNotifier = ValueNotifier<double>(1.0);
    _panNotifier = ValueNotifier<Offset>(Offset.zero);
    _ageStageNotifier = ValueNotifier<SkeletalAgeStage>(widget.initialAgeStage);
    _renderModeNotifier = ValueNotifier<SkeletalRenderMode>(SkeletalRenderMode.solid);
    _focusNotifier = ValueNotifier<SkeletalRegionFocus>(SkeletalRegionFocus.full);
    _selectedBoneNotifier = ValueNotifier<String?>(widget.selectedBoneId);
    _isSoloModeNotifier = ValueNotifier<bool>(widget.initialSoloMode);
    _showCartilageNotifier = ValueNotifier<bool>(true);
    _activeToolNotifier = ValueNotifier<SurgicalHardwareType?>(null);
    _interventionsNotifier = ValueNotifier<List<BoneInterventionPoint>>(widget.initialInterventions ?? []);
  }

  @override
  void didUpdateWidget(covariant SkeletalBone3dCanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedBoneId != oldWidget.selectedBoneId) {
      _selectedBoneNotifier.value = widget.selectedBoneId;
    }
  }

  @override
  void dispose() {
    _yawNotifier.dispose();
    _pitchNotifier.dispose();
    _zoomNotifier.dispose();
    _panNotifier.dispose();
    _ageStageNotifier.dispose();
    _renderModeNotifier.dispose();
    _focusNotifier.dispose();
    _selectedBoneNotifier.dispose();
    _isSoloModeNotifier.dispose();
    _showCartilageNotifier.dispose();
    _activeToolNotifier.dispose();
    _interventionsNotifier.dispose();
    super.dispose();
  }

  void _resetCamera() {
    _yawNotifier.value = 0.0;
    _pitchNotifier.value = 0.08;
    _zoomNotifier.value = 1.0;
    _panNotifier.value = Offset.zero;
  }

  void _setPresetCamera(double yaw, double pitch, double zoom, Offset pan, SkeletalRegionFocus focus) {
    _yawNotifier.value = yaw;
    _pitchNotifier.value = pitch;
    _zoomNotifier.value = zoom;
    _panNotifier.value = pan;
    _focusNotifier.value = focus;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return RepaintBoundary(
      child: Container(
        height: 540,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF090D16) : const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 1. Interactive 3D Gesture Viewport
              Positioned.fill(
                child: RepaintBoundary(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onScaleStart: (details) {
                          _lastFocalPoint = details.focalPoint;
                        },
                        onScaleUpdate: (details) {
                          if (details.pointerCount > 1) {
                            // Pinch to zoom & 2-finger pan
                            _zoomNotifier.value = (_zoomNotifier.value * details.scale).clamp(0.65, 3.8);
                            final delta = details.focalPoint - _lastFocalPoint;
                            _panNotifier.value += delta;
                            _lastFocalPoint = details.focalPoint;
                          } else {
                            // 1-finger Orbit Drag (Yaw & Pitch)
                            final delta = details.focalPoint - _lastFocalPoint;
                            _yawNotifier.value += delta.dx * 0.012;
                            _pitchNotifier.value = (_pitchNotifier.value - delta.dy * 0.012).clamp(-0.85, 0.85);
                            _lastFocalPoint = details.focalPoint;
                          }
                        },
                        onTapUp: (details) => _handleCanvasTap(details.localPosition, canvasSize),
                        onSecondaryTapUp: (details) => _handleCanvasSecondaryTap(details.localPosition, canvasSize),
                        child: AnimatedBuilder(
                          animation: Listenable.merge([
                            _yawNotifier,
                            _pitchNotifier,
                            _zoomNotifier,
                            _panNotifier,
                            _ageStageNotifier,
                            _renderModeNotifier,
                            _focusNotifier,
                            _selectedBoneNotifier,
                            _isSoloModeNotifier,
                            _showCartilageNotifier,
                            _activeToolNotifier,
                            _interventionsNotifier,
                          ]),
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _Skeletal3DPainter(
                                yaw: _yawNotifier.value,
                                pitch: _pitchNotifier.value,
                                zoom: _zoomNotifier.value,
                                pan: _panNotifier.value,
                                ageStage: _ageStageNotifier.value,
                                renderMode: _renderModeNotifier.value,
                                regionFocus: _focusNotifier.value,
                                selectedBoneId: _selectedBoneNotifier.value,
                                activeStatuses: widget.activeStatuses ?? {},
                                isSoloMode: _isSoloModeNotifier.value,
                                showCartilage: _showCartilageNotifier.value,
                                interventions: _interventionsNotifier.value,
                                isDark: isDark,
                              ),
                              size: Size.infinite,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 2. Top Header Bar (Solo Mode Banner OR Whole Skeleton Controls)
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: RepaintBoundary(
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isSoloModeNotifier,
                    builder: (context, isSolo, _) {
                      return ValueListenableBuilder<String?>(
                        valueListenable: _selectedBoneNotifier,
                        builder: (context, selectedId, _) {
                          final soloBone = selectedId != null ? _SkeletalMeshDatabase.getBone(selectedId) : null;
                          if (isSolo && soloBone != null) {
                            return _buildSoloModeHeader(isDark, soloBone);
                          }
                          return SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildAgeStageSelector(isDark),
                                const SizedBox(width: 8),
                                _buildRenderModeAndFocusBar(isDark),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),

              // 3. Floating Surgical CAD & Fixation Toolbar (Drill Holes, Plates, Screws, Nails, Pins)
              Positioned(
                top: 54,
                left: 10,
                right: 10,
                child: RepaintBoundary(
                  child: _buildSurgicalHardwareToolbar(isDark),
                ),
              ),

              // 4. Bottom-Left: Camera Presets & Reset
              Positioned(
                bottom: 10,
                left: 10,
                child: RepaintBoundary(
                  child: _buildCameraPresetsDock(isDark),
                ),
              ),

              // 5. Bottom-Right: Active Bone Inspector Badge
              Positioned(
                bottom: 10,
                right: 10,
                child: RepaintBoundary(
                  child: _buildSelectedBoneBadge(isDark),
                ),
              ),

              // 6. Active Tool Instruction Pill or Age Biomarker Pill
              Positioned(
                bottom: 56,
                left: 10,
                child: RepaintBoundary(
                  child: ValueListenableBuilder<SurgicalHardwareType?>(
                    valueListenable: _activeToolNotifier,
                    builder: (context, tool, _) {
                      if (tool != null) {
                        return _buildActiveToolInstruction(isDark, tool);
                      }
                      return ValueListenableBuilder<bool>(
                        valueListenable: _isSoloModeNotifier,
                        builder: (context, isSolo, _) {
                          if (isSolo) return const SizedBox.shrink();
                          return _buildAgeBiomarkerBanner(isDark);
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSoloModeHeader(bool isDark, _BoneSegment3D soloBone) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0D9488), width: 1.5),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.focus, size: 16, color: Color(0xFF0D9488)),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        AppLanguage.isArabic ? 'عزل 3D منفرد' : 'Solo 3D View',
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      soloBone.name,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${soloBone.code} • ${soloBone.region.label}',
                  style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(width: 14),
            ElevatedButton.icon(
              key: const ValueKey('btn_view_whole_skeleton'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                visualDensity: VisualDensity.compact,
              ),
              icon: const Icon(LucideIcons.maximize2, size: 13),
              label: Text(
                AppLanguage.isArabic ? 'عرض كامل الهيكل' : 'View Whole Skeleton',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
              ),
              onPressed: () {
                _isSoloModeNotifier.value = false;
                _resetCamera();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurgicalHardwareToolbar(bool isDark) {
    return ValueListenableBuilder<SurgicalHardwareType?>(
      valueListenable: _activeToolNotifier,
      builder: (context, activeTool, _) {
        return ValueListenableBuilder<List<BoneInterventionPoint>>(
          valueListenable: _interventionsNotifier,
          builder: (context, interventions, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: activeTool != null ? const Color(0xFFF59E0B) : (isDark ? Colors.white24 : Colors.black12),
                  width: activeTool != null ? 1.5 : 1.0,
                ),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Inspect / Orbit Tool
                    _buildToolButton(
                      key: const ValueKey('btn_tool_orbit'),
                      label: AppLanguage.isArabic ? 'معاينة وفحص' : 'Inspect / Orbit',
                      icon: LucideIcons.mousePointer,
                      isSelected: activeTool == null,
                      color: const Color(0xFF0D9488),
                      isDark: isDark,
                      onTap: () => _activeToolNotifier.value = null,
                    ),
                    const SizedBox(width: 4),
                    // Hardware items:
                    ...SurgicalHardwareType.values.map((tool) {
                      final isSel = activeTool == tool;
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: _buildToolButton(
                          key: ValueKey('btn_tool_${tool.name}'),
                          label: tool.label,
                          icon: tool.icon,
                          isSelected: isSel,
                          color: const Color(0xFFF59E0B),
                          isDark: isDark,
                          onTap: () {
                            if (_activeToolNotifier.value == tool) {
                              _activeToolNotifier.value = null;
                            } else {
                              _activeToolNotifier.value = tool;
                            }
                          },
                        ),
                      );
                    }),
                    if (interventions.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(height: 18, width: 1, color: Colors.grey.withValues(alpha: 0.3)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D9488).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${interventions.length}',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        key: const ValueKey('btn_undo_hardware'),
                        visualDensity: VisualDensity.compact,
                        tooltip: AppLanguage.isArabic ? 'تراجع عن آخر قطعة' : 'Undo Last Hardware',
                        icon: const Icon(LucideIcons.undo2, size: 14, color: Colors.amber),
                        onPressed: () {
                          final list = List<BoneInterventionPoint>.from(_interventionsNotifier.value);
                          list.removeLast();
                          _interventionsNotifier.value = list;
                          widget.onInterventionsChanged?.call(list);
                        },
                      ),
                      IconButton(
                        key: const ValueKey('btn_clear_hardware'),
                        visualDensity: VisualDensity.compact,
                        tooltip: AppLanguage.isArabic ? 'مسح كافة القطع' : 'Clear All Hardware',
                        icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                        onPressed: () {
                          _interventionsNotifier.value = [];
                          widget.onInterventionsChanged?.call([]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildToolButton({
    required Key key,
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : (isDark ? Colors.white24 : Colors.black12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 13,
              color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveToolInstruction(bool isDark, SurgicalHardwareType tool) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF59E0B)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.crosshair, size: 12, color: Color(0xFFF59E0B)),
          const SizedBox(width: 5),
          Text(
            AppLanguage.isArabic
                ? 'انقر على العظمة لوضع: ${tool.labelAr}'
                : 'Tap bone surface to place: ${tool.labelEn}',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFF59E0B)),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeStageSelector(bool isDark) {
    return ValueListenableBuilder<SkeletalAgeStage>(
      valueListenable: _ageStageNotifier,
      builder: (context, currentAge, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.5)),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: SkeletalAgeStage.values.map((stage) {
              final isSelected = stage == currentAge;
              return InkWell(
                key: ValueKey('btn_age_${stage.name}'),
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  _ageStageNotifier.value = stage;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        stage == SkeletalAgeStage.pediatric
                            ? LucideIcons.baby
                            : stage == SkeletalAgeStage.adult
                                ? LucideIcons.user
                                : LucideIcons.activity,
                        size: 13,
                        color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        stage.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRenderModeAndFocusBar(bool isDark) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Render Mode
        ValueListenableBuilder<SkeletalRenderMode>(
          valueListenable: _renderModeNotifier,
          builder: (context, mode, _) {
            return Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: SkeletalRenderMode.values.map((m) {
                  final sel = m == mode;
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: m.label,
                    icon: Icon(m.icon, size: 15, color: sel ? const Color(0xFF0D9488) : Colors.grey),
                    onPressed: () => _renderModeNotifier.value = m,
                  );
                }).toList(),
              ),
            );
          },
        ),
        const SizedBox(width: 8),

        // Focus Region Dropdown
        ValueListenableBuilder<SkeletalRegionFocus>(
          valueListenable: _focusNotifier,
          builder: (context, focus, _) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white24),
              ),
              child: DropdownButton<SkeletalRegionFocus>(
                value: focus,
                underline: const SizedBox(),
                isDense: true,
                dropdownColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                ),
                items: SkeletalRegionFocus.values.map((f) {
                  return DropdownMenuItem(
                    value: f,
                    child: Text(f.label),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _focusNotifier.value = val;
                    _adjustCameraForFocus(val);
                  }
                },
              ),
            );
          },
        ),
        const SizedBox(width: 8),

        // Cartilages & Joint Structures Toggle Button
        ValueListenableBuilder<bool>(
          valueListenable: _showCartilageNotifier,
          builder: (context, showCartilage, _) {
            return InkWell(
              key: const ValueKey('btn_toggle_cartilage'),
              borderRadius: BorderRadius.circular(10),
              onTap: () => _showCartilageNotifier.value = !_showCartilageNotifier.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: showCartilage ? const Color(0xFF0284C7) : (isDark ? const Color(0xFF0F172A) : Colors.white),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: showCartilage ? Colors.transparent : Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.sparkles,
                      size: 13,
                      color: showCartilage ? Colors.white : const Color(0xFF0284C7),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      AppLanguage.isArabic ? 'الغضاريف والمفاصل' : 'Cartilage & Discs',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: showCartilage ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _adjustCameraForFocus(SkeletalRegionFocus focus) {
    switch (focus) {
      case SkeletalRegionFocus.full:
        _resetCamera();
        break;
      case SkeletalRegionFocus.cranial:
        _setPresetCamera(0.0, 0.05, 1.8, const Offset(0, 110), focus);
        break;
      case SkeletalRegionFocus.thoracic:
        _setPresetCamera(0.0, 0.05, 1.6, const Offset(0, 45), focus);
        break;
      case SkeletalRegionFocus.spine:
        _setPresetCamera(math.pi * 0.95, 0.05, 1.4, const Offset(0, 10), focus);
        break;
      case SkeletalRegionFocus.pelvis:
        _setPresetCamera(0.0, 0.1, 1.7, const Offset(0, -50), focus);
        break;
      case SkeletalRegionFocus.upperLimbs:
        _setPresetCamera(0.0, 0.05, 1.3, const Offset(0, 40), focus);
        break;
      case SkeletalRegionFocus.lowerLimbs:
        _setPresetCamera(0.0, 0.05, 1.4, const Offset(0, -120), focus);
        break;
    }
  }

  Widget _buildCameraPresetsDock(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildPresetBtn('Front', 0.0, 0.08, 1.0, Offset.zero),
          _buildPresetBtn('Back', math.pi, 0.08, 1.0, Offset.zero),
          _buildPresetBtn('Side', math.pi / 2, 0.05, 1.0, Offset.zero),
          const SizedBox(width: 4),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Reset View',
            icon: const Icon(LucideIcons.rotateCcw, size: 14, color: Colors.teal),
            onPressed: _resetCamera,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetBtn(String label, double yaw, double pitch, double zoom, Offset pan) {
    return TextButton(
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      ),
      onPressed: () => _setPresetCamera(yaw, pitch, zoom, pan, _focusNotifier.value),
      child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal)),
    );
  }

  Widget _buildSelectedBoneBadge(bool isDark) {
    return ValueListenableBuilder<String?>(
      valueListenable: _selectedBoneNotifier,
      builder: (context, boneId, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isSoloModeNotifier,
          builder: (context, isSolo, _) {
            if (boneId == null) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.mousePointerClick, size: 12, color: Colors.teal),
                    SizedBox(width: 6),
                    Text(
                      'Tap any 3D bone to inspect, isolate & drill/plate',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            final bone = _SkeletalMeshDatabase.getBone(boneId);
            if (bone == null) return const SizedBox.shrink();

            final statusEntry = widget.activeStatuses?['ortho_${bone.code}'];
            final color = statusEntry?.visualColor ?? const Color(0xFF0D9488);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF0F172A) : Colors.white).withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color, width: 1.5),
                boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 8)],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(LucideIcons.bone, size: 16, color: color),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          bone.name,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${bone.code} • ${bone.region.label}',
                          style: const TextStyle(fontSize: 9.5, color: Colors.grey),
                        ),
                        if (statusEntry != null)
                          Text(
                            '${statusEntry.status.icd10Code}: ${AppLanguage.isArabic ? statusEntry.status.titleAr : statusEntry.status.title}',
                            style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: color),
                          ),
                      ],
                    ),
                    if (!isSolo) ...[
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        key: const ValueKey('btn_enter_solo_bone_mode'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D9488),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(LucideIcons.focus, size: 12),
                        label: Text(
                          AppLanguage.isArabic ? 'عزل وعرض منفرد' : 'Solo 3D View',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          _isSoloModeNotifier.value = true;
                          _resetCamera();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildAgeBiomarkerBanner(bool isDark) {
    return ValueListenableBuilder<SkeletalAgeStage>(
      valueListenable: _ageStageNotifier,
      builder: (context, age, _) {
        Color badgeColor;
        String text;
        IconData icon;

        switch (age) {
          case SkeletalAgeStage.pediatric:
            badgeColor = const Color(0xFF06B6D4);
            text = AppLanguage.isArabic
                ? 'صفائح نمو نشطة (Physis) وغضاريف تكلس قيد التطور'
                : 'Active Epiphyseal Growth Plates (Physis) & Open Fontanelles';
            icon = LucideIcons.sparkles;
            break;
          case SkeletalAgeStage.adult:
            badgeColor = const Color(0xFF10B981);
            text = AppLanguage.isArabic
                ? 'الهيكل العظمي البالغ الكامل (206 عظمة مندمجة بالكامل)'
                : 'Mature Adult Skeleton (206 Fully Consolidated Bones)';
            icon = LucideIcons.shieldCheck;
            break;
          case SkeletalAgeStage.geriatric:
            badgeColor = const Color(0xFFF59E0B);
            text = AppLanguage.isArabic
                ? 'تحدب فقري (Kyphosis)، ترقق عظمي وتنكس غضروفي'
                : 'Osteoporotic Cortical Thinning & Degenerative Kyphosis';
            icon = LucideIcons.alertTriangle;
            break;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: badgeColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: badgeColor),
              const SizedBox(width: 5),
              Text(
                text,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColor),
              ),
            ],
          ),
        );
      },
    );
  }

  ({BonePoint3D point, BonePoint3D normal})? _raycastBoneSurface({
    required _BoneSegment3D bone,
    required Offset tapPos,
    required double cx,
    required double cy,
    required double yaw,
    required double pitch,
    required double zoom,
    required Offset pan,
    double scaleMultiplier = 1.0,
    bool isSolo = false,
  }) {
    const fov = 680.0;
    final center = isSolo ? const BonePoint3D(0, 0, 0) : bone.center;

    // Transform vertices to local centered and camera space
    final localVertices = bone.vertices.map((v) {
      if (isSolo) {
        return (v - bone.center) * scaleMultiplier;
      }
      return v;
    }).toList();

    final camVertices = localVertices.map((v) => v.transform(yaw, pitch)).toList();

    final projPoints = camVertices.map((p) {
      final s = (fov / (fov + p.z)) * zoom;
      return Offset(cx + pan.dx + p.x * s, cy + pan.dy - p.y * s);
    }).toList();

    double triArea2D(Offset a, Offset b, Offset c) {
      return (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx);
    }

    BonePoint3D? bestHitLocal;
    BonePoint3D? bestNormalLocal;
    double closestDistance = double.infinity;
    double bestCameraZ = double.infinity;

    for (final face in bone.faces) {
      if (face.length < 3) continue;

      final triIndices = [
        [face[0], face[1], face[2]],
        if (face.length >= 4) [face[0], face[2], face[3]],
      ];

      for (final tri in triIndices) {
        final i0 = tri[0];
        final i1 = tri[1];
        final i2 = tri[2];

        final p0 = projPoints[i0];
        final p1 = projPoints[i1];
        final p2 = projPoints[i2];

        final area = triArea2D(p0, p1, p2);
        if (area.abs() < 1e-4) continue;

        final w0 = triArea2D(p1, p2, tapPos) / area;
        final w1 = triArea2D(p2, p0, tapPos) / area;
        final w2 = 1.0 - w0 - w1;

        final v01 = localVertices[i1] - localVertices[i0];
        final v02 = localVertices[i2] - localVertices[i0];
        var fn = v01.cross(v02).normalized();

        if (w0 >= -0.05 && w1 >= -0.05 && w2 >= -0.05) {
          final c0 = camVertices[i0];
          final c1 = camVertices[i1];
          final c2 = camVertices[i2];
          final camZ = c0.z * w0 + c1.z * w1 + c2.z * w2;

          if (camZ < bestCameraZ) {
            bestCameraZ = camZ;
            final hit = localVertices[i0] * w0.clamp(0.0, 1.0) +
                localVertices[i1] * w1.clamp(0.0, 1.0) +
                localVertices[i2] * w2.clamp(0.0, 1.0);

            if (fn.dot(hit - center) < 0) fn = fn * -1.0;
            bestHitLocal = hit;
            bestNormalLocal = fn;
            closestDistance = 0.0;
          }
        } else if (closestDistance > 0) {
          final triCenterProj = Offset((p0.dx + p1.dx + p2.dx) / 3, (p0.dy + p1.dy + p2.dy) / 3);
          final dist = (tapPos - triCenterProj).distance;
          if (dist < closestDistance) {
            closestDistance = dist;
            final hit = (localVertices[i0] + localVertices[i1] + localVertices[i2]) * (1.0 / 3.0);
            if (fn.dot(hit - center) < 0) fn = fn * -1.0;
            bestHitLocal = hit;
            bestNormalLocal = fn;
          }
        }
      }
    }

    if (bestHitLocal != null && bestNormalLocal != null) {
      if (isSolo) {
        return (
          point: bestHitLocal * (1.0 / scaleMultiplier),
          normal: bestNormalLocal,
        );
      } else {
        return (
          point: bestHitLocal - bone.center,
          normal: bestNormalLocal,
        );
      }
    }
    return null;
  }

  void _handleCanvasTap(Offset tapPos, Size canvasSize) {
    final bones = _SkeletalMeshDatabase.allBones;
    final yaw = _yawNotifier.value;
    final pitch = _pitchNotifier.value;
    final zoom = _zoomNotifier.value;
    final pan = _panNotifier.value;
    final isSolo = _isSoloModeNotifier.value;
    final activeTool = _activeToolNotifier.value;

    const fov = 680.0;
    final cx = canvasSize.width * 0.5;
    final cy = canvasSize.height * 0.52;

    // 1. If in Solo Mode:
    if (isSolo) {
      final soloBone = _selectedBoneNotifier.value != null
          ? _SkeletalMeshDatabase.getBone(_selectedBoneNotifier.value!)
          : bones.first;
      if (soloBone == null) return;

      if (activeTool != null) {
        // True 3D Surface Raycast on the solo bone
        const soloScale = 3.2;
        final hit = _raycastBoneSurface(
          bone: soloBone,
          tapPos: tapPos,
          cx: cx,
          cy: cy,
          yaw: yaw,
          pitch: pitch,
          zoom: zoom,
          pan: pan,
          scaleMultiplier: soloScale,
          isSolo: true,
        );

        final localOffset = hit?.point ??
            BonePoint3D(
              (tapPos.dx - (cx + pan.dx)) / (zoom * soloScale),
              ((cy + pan.dy) - tapPos.dy) / (zoom * soloScale),
              0.0,
            ).inverseTransform(yaw, pitch);

        final normal = hit?.normal ?? const BonePoint3D(0, 0, 1).inverseTransform(yaw, pitch).normalized();

        final intervention = BoneInterventionPoint(
          id: 'hw_${DateTime.now().microsecondsSinceEpoch}',
          boneId: soloBone.id,
          type: activeTool,
          localOffset: localOffset,
          normal: normal,
        );
        final updated = [..._interventionsNotifier.value, intervention];
        _interventionsNotifier.value = updated;
        widget.onInterventionsChanged?.call(updated);
      }
      return;
    }

    // 2. Whole Skeleton Mode:
    _BoneSegment3D? hitBone;
    ({BonePoint3D point, BonePoint3D normal})? hitSurface;

    if (activeTool != null) {
      for (final bone in bones) {
        if (_focusNotifier.value != SkeletalRegionFocus.full && bone.region != _focusNotifier.value) {
          continue;
        }
        final candidate = _raycastBoneSurface(
          bone: bone,
          tapPos: tapPos,
          cx: cx,
          cy: cy,
          yaw: yaw,
          pitch: pitch,
          zoom: zoom,
          pan: pan,
          scaleMultiplier: 1.0,
          isSolo: false,
        );
        if (candidate != null) {
          hitBone = bone;
          hitSurface = candidate;
          break;
        }
      }

      hitBone ??= (_selectedBoneNotifier.value != null ? _SkeletalMeshDatabase.getBone(_selectedBoneNotifier.value!) : bones.first);
      if (hitBone != null) {
        hitSurface ??= _raycastBoneSurface(
          bone: hitBone,
          tapPos: tapPos,
          cx: cx,
          cy: cy,
          yaw: yaw,
          pitch: pitch,
          zoom: zoom,
          pan: pan,
          scaleMultiplier: 1.0,
          isSolo: false,
        );

        final localOffset = hitSurface?.point ??
            BonePoint3D(
              (tapPos.dx - (cx + pan.dx)) / zoom,
              ((cy + pan.dy) - tapPos.dy) / zoom,
              0.0,
            ).inverseTransform(yaw, pitch);

        final normal = hitSurface?.normal ?? const BonePoint3D(0, 0, 1).inverseTransform(yaw, pitch).normalized();

        final intervention = BoneInterventionPoint(
          id: 'hw_${DateTime.now().microsecondsSinceEpoch}',
          boneId: hitBone.id,
          type: activeTool,
          localOffset: localOffset,
          normal: normal,
        );
        final updated = [..._interventionsNotifier.value, intervention];
        _interventionsNotifier.value = updated;
        widget.onInterventionsChanged?.call(updated);
      }
    } else {
      // Normal bone selection
      double minDistance = 85.0;
      for (final bone in bones) {
        if (_focusNotifier.value != SkeletalRegionFocus.full && bone.region != _focusNotifier.value) {
          continue;
        }
        final rotated = bone.center.transform(yaw, pitch);
        final scale = (fov / (fov + rotated.z)) * zoom;
        final projX = cx + pan.dx + rotated.x * scale;
        final projY = cy + pan.dy - rotated.y * scale;
        final dist = (tapPos - Offset(projX, projY)).distance;
        if (dist < minDistance) {
          minDistance = dist;
          hitBone = bone;
        }
      }

      if (hitBone != null) {
        _selectedBoneNotifier.value = hitBone.id;
        widget.onBoneSelected?.call(hitBone.code, hitBone.nameEn, hitBone.nameAr);
      }
    }
  }

  void _handleCanvasSecondaryTap(Offset tapPos, Size canvasSize) {
    final bones = _SkeletalMeshDatabase.allBones;
    final yaw = _yawNotifier.value;
    final pitch = _pitchNotifier.value;
    final zoom = _zoomNotifier.value;
    final pan = _panNotifier.value;
    const fov = 680.0;
    final cx = canvasSize.width * 0.5;
    final cy = canvasSize.height * 0.52;

    _BoneSegment3D? hitBone;
    double minDistance = 110.0;

    for (final bone in bones) {
      if (_focusNotifier.value != SkeletalRegionFocus.full && bone.region != _focusNotifier.value) {
        continue;
      }
      final rotated = bone.center.transform(yaw, pitch);
      final scale = (fov / (fov + rotated.z)) * zoom;
      final projX = cx + pan.dx + rotated.x * scale;
      final projY = cy + pan.dy - rotated.y * scale;
      final dist = (tapPos - Offset(projX, projY)).distance;
      if (dist < minDistance) {
        minDistance = dist;
        hitBone = bone;
      }
    }

    if (hitBone != null) {
      _selectedBoneNotifier.value = hitBone.id;
      widget.onBoneSecondaryTap?.call(hitBone.code, hitBone.nameEn, hitBone.nameAr);
    }
  }
}

/// 3D Skeletal Canvas Custom Painter
class _Skeletal3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final double zoom;
  final Offset pan;
  final SkeletalAgeStage ageStage;
  final SkeletalRenderMode renderMode;
  final SkeletalRegionFocus regionFocus;
  final String? selectedBoneId;
  final Map<String, ClinicalAnatomyStatusEntry> activeStatuses;
  final bool isSoloMode;
  final bool showCartilage;
  final List<BoneInterventionPoint> interventions;
  final bool isDark;

  const _Skeletal3DPainter({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.pan,
    required this.ageStage,
    required this.renderMode,
    required this.regionFocus,
    required this.selectedBoneId,
    required this.activeStatuses,
    required this.isSoloMode,
    this.showCartilage = true,
    required this.interventions,
    required this.isDark,
  });

  Offset _project(BonePoint3D p, double cx, double cy, {double fov = 680.0}) {
    final scale = (fov / (fov + p.z)) * zoom;
    return Offset(cx + pan.dx + p.x * scale, cy + pan.dy - p.y * scale);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.52;

    if (isSoloMode && selectedBoneId != null) {
      _paintSoloBoneMode(canvas, cx, cy);
      return;
    }

    // Whole Skeleton Mode:
    // Draw Subtle Floor Grid
    _draw3DGroundGrid(canvas, cx, cy);

    // Filter bones based on region focus
    final bones = _SkeletalMeshDatabase.allBones.where((b) {
      if (regionFocus == SkeletalRegionFocus.full) return true;
      return b.region == regionFocus;
    }).toList();

    // Depth Sorting: Sort bones from back to front (highest Z to lowest Z)
    bones.sort((a, b) {
      final aZ = a.center.transform(yaw, pitch).z;
      final bZ = b.center.transform(yaw, pitch).z;
      return bZ.compareTo(aZ);
    });

    for (final bone in bones) {
      _paintBone(canvas, cx, cy, bone);
    }

    // Paint Articular Joint Cartilages, Intervertebral Discs & Menisci in TRUE 3D
    if (showCartilage) {
      _paintArticularCartilageAndJoints(canvas, cx, cy);
    }

    // Paint Pediatric Growth Plates or Geriatric Osteophytes Overlay
    if (ageStage == SkeletalAgeStage.pediatric) {
      _paintPediatricPhyses(canvas, cx, cy);
    } else if (ageStage == SkeletalAgeStage.geriatric) {
      _paintGeriatricKyphosisAndSpurs(canvas, cx, cy);
    }

    // Paint All Surgical Interventions across the Whole Skeleton in TRUE 3D
    for (final intervention in interventions) {
      final bone = _SkeletalMeshDatabase.getBone(intervention.boneId);
      if (bone == null) continue;
      if (regionFocus != SkeletalRegionFocus.full && bone.region != regionFocus) continue;

      _paintIntervention3D(
        canvas: canvas,
        cx: cx,
        cy: cy,
        center3D: bone.center + intervention.localOffset,
        normal3D: intervention.normal,
        type: intervention.type,
        scale: zoom * 0.85,
        yaw: yaw,
        pitch: pitch,
      );
    }
  }

  void _paintSoloBoneMode(Canvas canvas, double cx, double cy) {
    final soloBone = _SkeletalMeshDatabase.getBone(selectedBoneId!) ?? _SkeletalMeshDatabase.allBones.first;
    const soloScale = 3.2;

    // Solo Orbital Ground Pedestal Ring
    final pedestalPaint = Paint()
      ..color = const Color(0xFF0D9488).withValues(alpha: isDark ? 0.25 : 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (double r = 40; r <= 140; r += 50) {
      final p1 = _project(BonePoint3D(-r, -90, 0).transform(yaw, pitch), cx, cy);
      final p2 = _project(BonePoint3D(r, -90, 0).transform(yaw, pitch), cx, cy);
      canvas.drawLine(p1, p2, pedestalPaint);
      final p3 = _project(BonePoint3D(0, -90, -r).transform(yaw, pitch), cx, cy);
      final p4 = _project(BonePoint3D(0, -90, r).transform(yaw, pitch), cx, cy);
      canvas.drawLine(p3, p4, pedestalPaint);
    }

    // Paint Solo Bone Centered at (0, 0, 0)
    final statusEntry = activeStatuses['ortho_${soloBone.code}'];
    final boneBaseColor = statusEntry?.visualColor ??
        (renderMode == SkeletalRenderMode.xray
            ? const Color(0xFF67E8F9)
            : renderMode == SkeletalRenderMode.heatmap
                ? _getHeatmapColor(soloBone.boneDensityTScore, ageStage)
                : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9)));

    // Transform vertices centered around (0,0,0) and scaled
    final transformed = soloBone.vertices.map((v) {
      final centered = (v - soloBone.center) * soloScale;
      return centered.transform(yaw, pitch);
    }).toList();

    final lightDir = const BonePoint3D(0.4, 0.7, -0.6);
    final lightLen = math.sqrt(lightDir.x * lightDir.x + lightDir.y * lightDir.y + lightDir.z * lightDir.z);
    final normLight = BonePoint3D(lightDir.x / lightLen, lightDir.y / lightLen, lightDir.z / lightLen);

    for (final face in soloBone.faces) {
      if (face.length < 3) continue;

      final p0 = transformed[face[0]];
      final p1 = transformed[face[1]];
      final p2 = transformed[face[2]];

      final v1 = BonePoint3D(p1.x - p0.x, p1.y - p0.y, p1.z - p0.z);
      final v2 = BonePoint3D(p2.x - p0.x, p2.y - p0.y, p2.z - p0.z);
      final normal = BonePoint3D(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x,
      );
      final nLen = math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
      if (nLen == 0) continue;

      final normN = BonePoint3D(normal.x / nLen, normal.y / nLen, normal.z / nLen);
      final dot = (normN.x * normLight.x + normN.y * normLight.y + normN.z * normLight.z).clamp(-1.0, 1.0);
      final intensity = (0.45 + 0.55 * math.max(0.0, -dot)).clamp(0.2, 1.0);

      final path = Path();
      final proj0 = _project(p0, cx, cy);
      path.moveTo(proj0.dx, proj0.dy);
      for (int i = 1; i < face.length; i++) {
        final proj = _project(transformed[face[i]], cx, cy);
        path.lineTo(proj.dx, proj.dy);
      }
      path.close();

      if (renderMode == SkeletalRenderMode.xray) {
        final xrayFill = Paint()
          ..color = boneBaseColor.withValues(alpha: 0.22)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, xrayFill);

        final xrayStroke = Paint()
          ..color = boneBaseColor.withValues(alpha: 0.85)
          ..strokeWidth = 1.6
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, xrayStroke);
      } else {
        final shadedColor = Color.fromARGB(
          255,
          (boneBaseColor.r * 255 * intensity).toInt().clamp(0, 255),
          (boneBaseColor.g * 255 * intensity).toInt().clamp(0, 255),
          (boneBaseColor.b * 255 * intensity).toInt().clamp(0, 255),
        );
        final fillPaint = Paint()
          ..color = shadedColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);

        final strokePaint = Paint()
          ..color = (isDark ? Colors.cyanAccent.withValues(alpha: 0.35) : Colors.teal.withValues(alpha: 0.3))
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, strokePaint);
      }
    }

    // Paint High-Magnification Articular Cartilage & Fibrocartilage in Solo Bone Mode
    if (showCartilage) {
      _paintSoloBoneCartilages(canvas, cx, cy, soloBone, soloScale);
    }

    // Paint Surgical Interventions for this Solo Bone in TRUE 3D
    final soloInterventions = interventions.where((i) => i.boneId == soloBone.id || i.boneId == soloBone.code);
    for (final intervention in soloInterventions) {
      _paintIntervention3D(
        canvas: canvas,
        cx: cx,
        cy: cy,
        center3D: intervention.localOffset * soloScale,
        normal3D: intervention.normal,
        type: intervention.type,
        scale: zoom * 1.6,
        yaw: yaw,
        pitch: pitch,
      );
    }
  }

  void _paintIntervention3D({
    required Canvas canvas,
    required double cx,
    required double cy,
    required BonePoint3D center3D,
    required BonePoint3D normal3D,
    required SurgicalHardwareType type,
    required double scale,
    required double yaw,
    required double pitch,
  }) {
    // 1. Compute Orthonormal Basis in 3D Space (Normal, Tangent U, Bitangent V)
    final norm = normal3D.normalized();
    BonePoint3D u;
    if (norm.y.abs() < 0.88) {
      u = norm.cross(const BonePoint3D(0, 1, 0)).normalized();
    } else {
      u = norm.cross(const BonePoint3D(1, 0, 0)).normalized();
    }
    final v = norm.cross(u).normalized();

    final lightDir = const BonePoint3D(0.4, 0.7, -0.6).normalized();

    Offset project3D(BonePoint3D pt) {
      final camPt = pt.transform(yaw, pitch);
      return _project(camPt, cx, cy);
    }

    double shadeFace(BonePoint3D faceNorm) {
      final camNorm = faceNorm.transform(yaw, pitch).normalized();
      final dot = (camNorm.x * lightDir.x + camNorm.y * lightDir.y + camNorm.z * lightDir.z).clamp(-1.0, 1.0);
      return (0.42 + 0.58 * math.max(0.0, -dot)).clamp(0.25, 1.0);
    }

    switch (type) {
      case SurgicalHardwareType.drillHole:
        // ---------------------------------------------------------------------
        // 1. TRUE 3D COUNTERSUNK CYLINDRICAL DRILL HOLE (BURRHOLE)
        // ---------------------------------------------------------------------
        final r = (4.8 * scale).clamp(2.5, 20.0);
        final depth = (18.0 * scale).clamp(8.0, 60.0);
        final bevelR = r * 1.35;

        const segments = 8;
        final rimPts = <BonePoint3D>[];
        final bevelPts = <BonePoint3D>[];
        final bottomPts = <BonePoint3D>[];

        for (int i = 0; i < segments; i++) {
          final theta = (i / segments) * 2 * math.pi;
          final cosT = math.cos(theta);
          final sinT = math.sin(theta);
          final radialVec = u * cosT + v * sinT;

          rimPts.add(center3D + radialVec * r);
          bevelPts.add(center3D + radialVec * bevelR);
          bottomPts.add(center3D - norm * depth + radialVec * r);
        }

        // Draw Countersink Bevel Ring on Bone Surface
        for (int i = 0; i < segments; i++) {
          final next = (i + 1) % segments;
          final p0 = project3D(rimPts[i]);
          final p1 = project3D(rimPts[next]);
          final p2 = project3D(bevelPts[next]);
          final p3 = project3D(bevelPts[i]);

          final path = Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
          final bevelPaint = Paint()
            ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.85)
            ..style = PaintingStyle.fill;
          canvas.drawPath(path, bevelPaint);

          final bevelEdge = Paint()
            ..color = const Color(0xFF475569)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.8;
          canvas.drawPath(path, bevelEdge);
        }

        // Draw 3D Borehole Cylinder Wall Faces
        for (int i = 0; i < segments; i++) {
          final next = (i + 1) % segments;
          final pRim0 = project3D(rimPts[i]);
          final pRim1 = project3D(rimPts[next]);
          final pBot1 = project3D(bottomPts[next]);
          final pBot0 = project3D(bottomPts[i]);

          final wallPath = Path()..moveTo(pRim0.dx, pRim0.dy)..lineTo(pRim1.dx, pRim1.dy)..lineTo(pBot1.dx, pBot1.dy)..lineTo(pBot0.dx, pBot0.dy)..close();
          final wallPaint = Paint()
            ..color = Color.fromARGB(255, 12 + (i * 3) % 25, 18 + (i * 4) % 25, 28 + (i * 5) % 25)
            ..style = PaintingStyle.fill;
          canvas.drawPath(wallPath, wallPaint);

          final wallStroke = Paint()
            ..color = Colors.black45
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7;
          canvas.drawPath(wallPath, wallStroke);
        }

        // Draw 3D Bottom Base Cap
        final bottomPath = Path();
        final b0 = project3D(bottomPts[0]);
        bottomPath.moveTo(b0.dx, b0.dy);
        for (int i = 1; i < segments; i++) {
          final bp = project3D(bottomPts[i]);
          bottomPath.lineTo(bp.dx, bp.dy);
        }
        bottomPath.close();
        final bottomPaint = Paint()
          ..color = const Color(0xFF030712)
          ..style = PaintingStyle.fill;
        canvas.drawPath(bottomPath, bottomPaint);
        break;

      case SurgicalHardwareType.corticalScrew:
        // ---------------------------------------------------------------------
        // 2. TRUE 3D CORTICAL BONE SCREW (HEAD + THREADED SHAFT)
        // ---------------------------------------------------------------------
        final headR = (4.6 * scale).clamp(2.5, 18.0);
        final headH = (3.2 * scale).clamp(1.5, 12.0);
        final shaftR = headR * 0.46;
        final shaftL = (20.0 * scale).clamp(10.0, 70.0);

        const segs = 8;
        final shaftTip = center3D - norm * shaftL;

        final shaftBasePts = <BonePoint3D>[];
        final shaftTipPts = <BonePoint3D>[];
        for (int i = 0; i < segs; i++) {
          final theta = (i / segs) * 2 * math.pi;
          final radial = u * math.cos(theta) + v * math.sin(theta);
          shaftBasePts.add(center3D + radial * shaftR);
          shaftTipPts.add(shaftTip + radial * shaftR);
        }

        // Draw 3D Shaft cylinder faces into bone
        for (int i = 0; i < segs; i++) {
          final next = (i + 1) % segs;
          final p0 = project3D(shaftBasePts[i]);
          final p1 = project3D(shaftBasePts[next]);
          final p2 = project3D(shaftTipPts[next]);
          final p3 = project3D(shaftTipPts[i]);

          final path = Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
          final sh = 0.5 + 0.5 * math.cos((i / segs) * 2 * math.pi);
          final col = Color.fromARGB(255, (120 * sh).toInt(), (145 * sh).toInt(), (165 * sh).toInt());
          canvas.drawPath(path, Paint()..color = col..style = PaintingStyle.fill);
        }

        // Draw 3D Screw Threads (Helical Rings)
        for (double d = 3.0; d < shaftL - 2.0; d += 4.0 * scale) {
          final ringCenter = center3D - norm * d;
          final pStart = project3D(ringCenter - u * (shaftR * 1.35));
          final pEnd = project3D(ringCenter + u * (shaftR * 1.35) - norm * (0.8 * scale));
          canvas.drawLine(pStart, pEnd, Paint()..color = const Color(0xFF94A3B8)..strokeWidth = 1.2 * scale);
        }

        // 3D Screw Head (+norm)
        final headBasePts = <BonePoint3D>[];
        final headTopPts = <BonePoint3D>[];
        final headTopCenter = center3D + norm * headH;

        for (int i = 0; i < segs; i++) {
          final theta = (i / segs) * 2 * math.pi;
          final radial = u * math.cos(theta) + v * math.sin(theta);
          headBasePts.add(center3D + radial * headR);
          headTopPts.add(headTopCenter + radial * (headR * 1.15));
        }

        // Head Beveled Cylinder Sides
        for (int i = 0; i < segs; i++) {
          final next = (i + 1) % segs;
          final p0 = project3D(headBasePts[i]);
          final p1 = project3D(headBasePts[next]);
          final p2 = project3D(headTopPts[next]);
          final p3 = project3D(headTopPts[i]);

          final path = Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
          final faceNorm = (headBasePts[next] - headBasePts[i]).cross(norm).normalized();
          final sh = shadeFace(faceNorm);
          final c = Color.fromARGB(255, (210 * sh).toInt(), (225 * sh).toInt(), (235 * sh).toInt());
          canvas.drawPath(path, Paint()..color = c..style = PaintingStyle.fill);
          canvas.drawPath(path, Paint()..color = const Color(0xFF475569)..style = PaintingStyle.stroke..strokeWidth = 0.8);
        }

        // Head Top Crown Polygon
        final crownPath = Path();
        final c0 = project3D(headTopPts[0]);
        crownPath.moveTo(c0.dx, c0.dy);
        for (int i = 1; i < segs; i++) {
          final cp = project3D(headTopPts[i]);
          crownPath.lineTo(cp.dx, cp.dy);
        }
        crownPath.close();
        final crownSh = shadeFace(norm);
        final crownCol = Color.fromARGB(255, (235 * crownSh).toInt(), (245 * crownSh).toInt(), (255 * crownSh).toInt());
        canvas.drawPath(crownPath, Paint()..color = crownCol..style = PaintingStyle.fill);
        canvas.drawPath(crownPath, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 1.0);

        // Phillips Cross Drive Recess in 3D
        final crossA0 = project3D(headTopCenter - u * (headR * 0.55));
        final crossA1 = project3D(headTopCenter + u * (headR * 0.55));
        final crossB0 = project3D(headTopCenter - v * (headR * 0.55));
        final crossB1 = project3D(headTopCenter + v * (headR * 0.55));
        final crossPaint = Paint()..color = const Color(0xFF0F172A)..strokeWidth = 1.6 * scale..strokeCap = StrokeCap.round;
        canvas.drawLine(crossA0, crossA1, crossPaint);
        canvas.drawLine(crossB0, crossB1, crossPaint);
        break;

      case SurgicalHardwareType.fixationPlate:
        // ---------------------------------------------------------------------
        // 3. TRUE 3D TITANIUM DYNAMIC COMPRESSION PLATE (DCP)
        // ---------------------------------------------------------------------
        final len = (38.0 * scale).clamp(20.0, 110.0);
        final wid = (10.0 * scale).clamp(5.0, 30.0);
        final th = (3.4 * scale).clamp(1.8, 12.0);

        final halfL = len * 0.5;
        final halfW = wid * 0.5;

        final b0 = center3D - u * halfL - v * halfW;
        final b1 = center3D + u * halfL - v * halfW;
        final b2 = center3D + u * halfL + v * halfW;
        final b3 = center3D - u * halfL + v * halfW;

        final t0 = b0 + norm * th;
        final t1 = b1 + norm * th;
        final t2 = b2 + norm * th;
        final t3 = b3 + norm * th;

        void drawQuad(BonePoint3D p0, BonePoint3D p1, BonePoint3D p2, BonePoint3D p3, Color baseCol) {
          final s0 = project3D(p0);
          final s1 = project3D(p1);
          final s2 = project3D(p2);
          final s3 = project3D(p3);

          final fn = (p1 - p0).cross(p2 - p0).normalized();
          final sh = shadeFace(fn);
          final fillCol = Color.fromARGB(
            255,
            (baseCol.r * 255 * sh).toInt().clamp(0, 255),
            (baseCol.g * 255 * sh).toInt().clamp(0, 255),
            (baseCol.b * 255 * sh).toInt().clamp(0, 255),
          );

          final path = Path()..moveTo(s0.dx, s0.dy)..lineTo(s1.dx, s1.dy)..lineTo(s2.dx, s2.dy)..lineTo(s3.dx, s3.dy)..close();
          canvas.drawPath(path, Paint()..color = fillCol..style = PaintingStyle.fill);
          canvas.drawPath(path, Paint()..color = const Color(0xFF334155)..style = PaintingStyle.stroke..strokeWidth = 1.0);
        }

        const titaniumCol = Color(0xFFCBD5E1);
        drawQuad(b0, b1, t1, t0, titaniumCol);
        drawQuad(b1, b2, t2, t1, titaniumCol);
        drawQuad(b2, b3, t3, t2, titaniumCol);
        drawQuad(b3, b0, t0, t3, titaniumCol);
        drawQuad(t0, t1, t2, t3, const Color(0xFFE2E8F0));

        final holeOffsets = [-halfL * 0.65, 0.0, halfL * 0.65];
        for (int i = 0; i < holeOffsets.length; i++) {
          final ox = holeOffsets[i];
          final holeCenter = center3D + u * ox + norm * th;
          final holeR = 2.2 * scale;

          final holePts = <Offset>[];
          for (int k = 0; k < 6; k++) {
            final a = (k / 6) * 2 * math.pi;
            final pt = holeCenter + (u * math.cos(a) + v * math.sin(a)) * holeR;
            holePts.add(project3D(pt));
          }
          final hp = Path()..moveTo(holePts[0].dx, holePts[0].dy);
          for (int k = 1; k < 6; k++) {
            hp.lineTo(holePts[k].dx, holePts[k].dy);
          }
          hp.close();
          canvas.drawPath(hp, Paint()..color = const Color(0xFF1E293B)..style = PaintingStyle.fill);

          if (i != 1) {
            final screwCrown = holeCenter + norm * (0.8 * scale);
            final sP = project3D(screwCrown);
            canvas.drawCircle(sP, holeR * 0.88, Paint()..color = const Color(0xFF0D9488)..style = PaintingStyle.fill);
            final c1 = project3D(screwCrown - u * (holeR * 0.5));
            final c2 = project3D(screwCrown + u * (holeR * 0.5));
            canvas.drawLine(c1, c2, Paint()..color = Colors.white..strokeWidth = 0.9 * scale);
          }
        }
        break;

      case SurgicalHardwareType.intramedullaryNail:
        // ---------------------------------------------------------------------
        // 4. TRUE 3D TITANIUM INTRAMEDULLARY NAIL (IM NAIL ROD + LOCKING BOLTS)
        // ---------------------------------------------------------------------
        final rodLen = (48.0 * scale).clamp(24.0, 140.0);
        final rodR = (3.4 * scale).clamp(1.8, 12.0);
        final halfRLen = rodLen * 0.5;

        final axis = v;
        final perp = u;

        const nSegs = 8;
        final topCapPts = <BonePoint3D>[];
        final botCapPts = <BonePoint3D>[];
        final topCenter = center3D + axis * halfRLen;
        final botCenter = center3D - axis * halfRLen;

        for (int i = 0; i < nSegs; i++) {
          final theta = (i / nSegs) * 2 * math.pi;
          final rVec = perp * math.cos(theta) + norm * math.sin(theta);
          topCapPts.add(topCenter + rVec * rodR);
          botCapPts.add(botCenter + rVec * rodR);
        }

        for (int i = 0; i < nSegs; i++) {
          final next = (i + 1) % nSegs;
          final p0 = project3D(topCapPts[i]);
          final p1 = project3D(topCapPts[next]);
          final p2 = project3D(botCapPts[next]);
          final p3 = project3D(botCapPts[i]);

          final path = Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
          final theta = (i / nSegs) * 2 * math.pi;
          final rNorm = (perp * math.cos(theta) + norm * math.sin(theta)).normalized();
          final sh = shadeFace(rNorm);
          final c = Color.fromARGB(255, (40 + 180 * sh).toInt().clamp(0, 255), (140 + 110 * sh).toInt().clamp(0, 255), (210 + 45 * sh).toInt().clamp(0, 255));
          canvas.drawPath(path, Paint()..color = c..style = PaintingStyle.fill);
        }

        final topPath = Path();
        topPath.moveTo(project3D(topCapPts[0]).dx, project3D(topCapPts[0]).dy);
        for (int i = 1; i < nSegs; i++) {
          topPath.lineTo(project3D(topCapPts[i]).dx, project3D(topCapPts[i]).dy);
        }
        topPath.close();
        canvas.drawPath(topPath, Paint()..color = const Color(0xFF38BDF8)..style = PaintingStyle.fill);

        final tipPt = project3D(botCenter - axis * (6.0 * scale));
        for (int i = 0; i < nSegs; i++) {
          final next = (i + 1) % nSegs;
          final p0 = project3D(botCapPts[i]);
          final p1 = project3D(botCapPts[next]);
          final tipTri = Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy)..lineTo(tipPt.dx, tipPt.dy)..close();
          canvas.drawPath(tipTri, Paint()..color = const Color(0xFF0284C7)..style = PaintingStyle.fill);
        }

        final boltOffsets = [halfRLen * 0.65, -halfRLen * 0.65];
        for (final bo in boltOffsets) {
          final boltCenter = center3D + axis * bo;
          final bStart = project3D(boltCenter - perp * (rodR * 2.2));
          final bEnd = project3D(boltCenter + perp * (rodR * 2.2));
          canvas.drawLine(bStart, bEnd, Paint()..color = Colors.white..strokeWidth = 2.4 * scale..strokeCap = StrokeCap.round);
          canvas.drawCircle(bStart, 1.8 * scale, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.fill);
          canvas.drawCircle(bEnd, 1.8 * scale, Paint()..color = const Color(0xFF0F172A)..style = PaintingStyle.fill);
        }
        break;

      case SurgicalHardwareType.kWirePin:
        // ---------------------------------------------------------------------
        // 5. TRUE 3D KIRSCHNER WIRE (K-WIRE PIN)
        // ---------------------------------------------------------------------
        final pinLen = (52.0 * scale).clamp(25.0, 150.0);
        final pinR = (1.5 * scale).clamp(0.8, 4.0);

        final pinDir = (norm * 0.8 + v * 0.6).normalized();
        final pEntry = center3D + pinDir * (pinLen * 0.45);
        final pExit = center3D - pinDir * (pinLen * 0.55);

        const kwSegs = 6;
        final entryPts = <BonePoint3D>[];
        final exitPts = <BonePoint3D>[];
        for (int i = 0; i < kwSegs; i++) {
          final theta = (i / kwSegs) * 2 * math.pi;
          final rVec = u * math.cos(theta) + norm.cross(u) * math.sin(theta);
          entryPts.add(pEntry + rVec * pinR);
          exitPts.add(pExit + rVec * pinR);
        }

        for (int i = 0; i < kwSegs; i++) {
          final next = (i + 1) % kwSegs;
          final p0 = project3D(entryPts[i]);
          final p1 = project3D(entryPts[next]);
          final p2 = project3D(exitPts[next]);
          final p3 = project3D(exitPts[i]);

          final path = Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy)..lineTo(p2.dx, p2.dy)..lineTo(p3.dx, p3.dy)..close();
          final sh = 0.5 + 0.5 * math.cos((i / kwSegs) * 2 * math.pi);
          final c = Color.fromARGB(255, (244 * sh).toInt().clamp(0, 255), (63 * sh).toInt().clamp(0, 255), (94 * sh).toInt().clamp(0, 255));
          canvas.drawPath(path, Paint()..color = c..style = PaintingStyle.fill);
        }

        final trocarTip = project3D(pExit - pinDir * (5.0 * scale));
        for (int i = 0; i < kwSegs; i++) {
          final next = (i + 1) % kwSegs;
          final p0 = project3D(exitPts[i]);
          final p1 = project3D(exitPts[next]);
          final tri = Path()..moveTo(p0.dx, p0.dy)..lineTo(p1.dx, p1.dy)..lineTo(trocarTip.dx, trocarTip.dy)..close();
          canvas.drawPath(tri, Paint()..color = Colors.white..style = PaintingStyle.fill);
        }

        final loopCenter = project3D(pEntry + pinDir * (3.0 * scale));
        canvas.drawCircle(loopCenter, pinR * 2.2, Paint()..color = const Color(0xFFF43F5E)..style = PaintingStyle.stroke..strokeWidth = 1.6 * scale);
        break;
    }
  }

  void _draw3DGroundGrid(Canvas canvas, double cx, double cy) {
    final gridPaint = Paint()
      ..color = (isDark ? Colors.white10 : Colors.black12)
      ..strokeWidth = 1.0;

    const floorY = -180.0;
    for (double x = -150; x <= 150; x += 30) {
      final p1 = _project(BonePoint3D(x, floorY, -150).transform(yaw, pitch), cx, cy);
      final p2 = _project(BonePoint3D(x, floorY, 150).transform(yaw, pitch), cx, cy);
      canvas.drawLine(p1, p2, gridPaint);
    }
    for (double z = -150; z <= 150; z += 30) {
      final p1 = _project(BonePoint3D(-150, floorY, z).transform(yaw, pitch), cx, cy);
      final p2 = _project(BonePoint3D(150, floorY, z).transform(yaw, pitch), cx, cy);
      canvas.drawLine(p1, p2, gridPaint);
    }
  }

  void _paintBone(Canvas canvas, double cx, double cy, _BoneSegment3D bone) {
    final isSelected = bone.id == selectedBoneId;
    final statusEntry = activeStatuses['ortho_${bone.code}'];
    final hasStatus = statusEntry != null;

    // Determine Base Shading Color
    Color boneBaseColor;
    if (hasStatus) {
      boneBaseColor = statusEntry.visualColor;
    } else if (renderMode == SkeletalRenderMode.xray) {
      boneBaseColor = const Color(0xFF67E8F9);
    } else if (renderMode == SkeletalRenderMode.heatmap) {
      boneBaseColor = _getHeatmapColor(bone.boneDensityTScore, ageStage);
    } else {
      boneBaseColor = isDark ? const Color(0xFFE2E8F0) : const Color(0xFFF1F5F9);
    }

    // Transform Vertices
    final transformed = bone.vertices.map((v) {
      var pt = v;
      if (ageStage == SkeletalAgeStage.pediatric && bone.region == SkeletalRegionFocus.cranial) {
        pt = BonePoint3D(pt.x * 1.15, pt.y * 1.12, pt.z * 1.15);
      } else if (ageStage == SkeletalAgeStage.geriatric && bone.region == SkeletalRegionFocus.spine) {
        final kyphosisShift = (bone.center.y > 0 && bone.center.y < 80) ? 14.0 : 0.0;
        pt = BonePoint3D(pt.x, pt.y - 4.0, pt.z + kyphosisShift);
      }
      return pt.transform(yaw, pitch);
    }).toList();

    // Directional Lighting
    final lightDir = const BonePoint3D(0.4, 0.7, -0.6);
    final lightLen = math.sqrt(lightDir.x * lightDir.x + lightDir.y * lightDir.y + lightDir.z * lightDir.z);
    final normLight = BonePoint3D(lightDir.x / lightLen, lightDir.y / lightLen, lightDir.z / lightLen);

    for (final face in bone.faces) {
      if (face.length < 3) continue;

      final p0 = transformed[face[0]];
      final p1 = transformed[face[1]];
      final p2 = transformed[face[2]];

      final v1 = BonePoint3D(p1.x - p0.x, p1.y - p0.y, p1.z - p0.z);
      final v2 = BonePoint3D(p2.x - p0.x, p2.y - p0.y, p2.z - p0.z);
      final normal = BonePoint3D(
        v1.y * v2.z - v1.z * v2.y,
        v1.z * v2.x - v1.x * v2.z,
        v1.x * v2.y - v1.y * v2.x,
      );
      final nLen = math.sqrt(normal.x * normal.x + normal.y * normal.y + normal.z * normal.z);
      if (nLen == 0) continue;

      final normN = BonePoint3D(normal.x / nLen, normal.y / nLen, normal.z / nLen);

      if (renderMode == SkeletalRenderMode.solid && normN.z > 0.45) {
        continue;
      }

      final dot = (normN.x * normLight.x + normN.y * normLight.y + normN.z * normLight.z).clamp(-1.0, 1.0);
      final intensity = (0.45 + 0.55 * math.max(0.0, -dot)).clamp(0.2, 1.0);

      final path = Path();
      final proj0 = _project(p0, cx, cy);
      path.moveTo(proj0.dx, proj0.dy);
      for (int i = 1; i < face.length; i++) {
        final proj = _project(transformed[face[i]], cx, cy);
        path.lineTo(proj.dx, proj.dy);
      }
      path.close();

      if (renderMode == SkeletalRenderMode.xray) {
        final xrayFill = Paint()
          ..color = boneBaseColor.withValues(alpha: 0.16)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, xrayFill);

        final xrayStroke = Paint()
          ..color = boneBaseColor.withValues(alpha: 0.75)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, xrayStroke);
        // Cortical bone specular sheen & rim depth
        final halfDir = const BonePoint3D(0.35, 0.45, 0.82).normalized();
        final specDot = math.max(0.0, normN.x * halfDir.x + normN.y * halfDir.y + normN.z * halfDir.z);
        final specular = math.pow(specDot, 16.0) * 0.32;

        final baseR = boneBaseColor.r * 255;
        final baseG = boneBaseColor.g * 255;
        final baseB = boneBaseColor.b * 255;

        final shadedColor = Color.fromARGB(
          255,
          (baseR * intensity + 255 * specular).toInt().clamp(0, 255),
          (baseG * intensity + 255 * specular).toInt().clamp(0, 255),
          (baseB * intensity + 255 * specular).toInt().clamp(0, 255),
        );

        final fillPaint = Paint()
          ..color = shadedColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }
    }

    if (isSelected) {
      final centerProj = _project(bone.center.transform(yaw, pitch), cx, cy);
      final glowPaint = Paint()
        ..color = const Color(0xFF0D9488).withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(centerProj, bone.hitRadius * zoom, glowPaint);

      final corePaint = Paint()
        ..color = const Color(0xFF0D9488)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(centerProj, 4.0 * zoom, corePaint);
    }
  }

  Color _getHeatmapColor(double tScore, SkeletalAgeStage age) {
    if (age == SkeletalAgeStage.geriatric) {
      if (tScore < -2.5) return const Color(0xFFEF4444);
      if (tScore < -1.0) return const Color(0xFFF59E0B);
      return const Color(0xFF10B981);
    } else if (age == SkeletalAgeStage.pediatric) {
      return const Color(0xFF06B6D4);
    }
    return const Color(0xFF10B981);
  }

  void _paintPediatricPhyses(Canvas canvas, double cx, double cy) {
    final physisPaint = Paint()
      ..color = const Color(0xFF06B6D4).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    final plates = [
      BonePoint3D(24, -30, 0),
      BonePoint3D(-24, -30, 0),
      BonePoint3D(24, -50, 0),
      BonePoint3D(-24, -50, 0),
      BonePoint3D(52, 60, 0),
      BonePoint3D(-52, 60, 0),
      BonePoint3D(65, 0, 0),
      BonePoint3D(-65, 0, 0),
    ];

    for (final pt in plates) {
      final proj = _project(pt.transform(yaw, pitch), cx, cy);
      canvas.drawCircle(proj, 6.0 * zoom, physisPaint);
    }
  }

  void _paintGeriatricKyphosisAndSpurs(Canvas canvas, double cx, double cy) {
    final spurPaint = Paint()
      ..color = const Color(0xFFDC2626).withValues(alpha: 0.9)
      ..style = PaintingStyle.fill;

    final spurs = [
      BonePoint3D(26, -38, 4),
      BonePoint3D(-26, -38, 4),
      BonePoint3D(0, 15, -6),
      BonePoint3D(18, -10, 0),
      BonePoint3D(-18, -10, 0),
    ];

    for (final pt in spurs) {
      final proj = _project(pt.transform(yaw, pitch), cx, cy);
      canvas.drawCircle(proj, 4.0 * zoom, spurPaint);
    }
  }

  void _paintArticularCartilageAndJoints(Canvas canvas, double cx, double cy) {
    if (!showCartilage) return;

    final cartilagePaint = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: renderMode == SkeletalRenderMode.xray ? 0.35 : 0.85)
      ..style = PaintingStyle.fill;
    final cartilageBorder = Paint()
      ..color = const Color(0xFF0284C7).withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final costalPaint = Paint()
      ..color = const Color(0xFF7DD3FC).withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.2 * zoom;

    // 1. Intervertebral Discs (Cervical, Thoracic, Lumbar, Lumbosacral)
    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.spine || regionFocus == SkeletalRegionFocus.cranial) {
      final cervicalDiscYs = [92.0, 95.0, 98.0, 101.0, 104.0];
      for (final dy in cervicalDiscYs) {
        _draw3DDisc(canvas, cx, cy, center: BonePoint3D(0, dy, 2), radius: 6.5, height: 1.6, fill: cartilagePaint, stroke: cartilageBorder);
      }
    }

    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.spine || regionFocus == SkeletalRegionFocus.thoracic) {
      final thoracicDiscYs = [75.0, 68.0, 61.0, 54.0, 47.0, 40.0, 33.0];
      for (final dy in thoracicDiscYs) {
        _draw3DDisc(canvas, cx, cy, center: BonePoint3D(0, dy, 0), radius: 8.5, height: 2.2, fill: cartilagePaint, stroke: cartilageBorder);
      }
    }

    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.spine || regionFocus == SkeletalRegionFocus.pelvis) {
      final lumbarDiscYs = [24.0, 18.0, 12.0, 6.0, 0.0, -6.0];
      final discH = ageStage == SkeletalAgeStage.geriatric ? 1.4 : 3.0; // Narrowed disc space in geriatric
      for (final dy in lumbarDiscYs) {
        _draw3DDisc(canvas, cx, cy, center: BonePoint3D(0, dy, 6), radius: 11.5, height: discH, fill: cartilagePaint, stroke: cartilageBorder);
      }
    }

    // 2. Costal Cartilages (7 bilateral chondral rib arches bridging to sternum)
    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.thoracic) {
      final ribArches = [
        [-14.0, 75.0, -8.0, 14.0, 75.0, -8.0, 75.0],
        [-20.0, 68.0, -9.0, 20.0, 68.0, -9.0, 68.0],
        [-24.0, 60.0, -10.0, 24.0, 60.0, -10.0, 60.0],
        [-28.0, 52.0, -10.0, 28.0, 52.0, -10.0, 52.0],
        [-30.0, 44.0, -10.0, 30.0, 44.0, -10.0, 44.0],
        [-30.0, 36.0, -9.0, 30.0, 36.0, -9.0, 36.0],
        [-26.0, 28.0, -7.0, 26.0, 28.0, -7.0, 30.0],
      ];
      for (final r in ribArches) {
        final pL = _project(BonePoint3D(r[0], r[1], r[2]).transform(yaw, pitch), cx, cy);
        final pSternum = _project(BonePoint3D(0, r[6], -13).transform(yaw, pitch), cx, cy);
        final pR = _project(BonePoint3D(r[3], r[4], r[5]).transform(yaw, pitch), cx, cy);
        canvas.drawLine(pL, pSternum, costalPaint);
        canvas.drawLine(pR, pSternum, costalPaint);
      }
    }

    // 3. Knee Joint Articular Cartilage & Menisci (Medial & Lateral C-shaped pads)
    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.lowerLimbs) {
      for (final side in [-1.0, 1.0]) {
        final kx = 21.0 * side;
        // Femoral Condylar Cartilage Caps
        _draw3DCartilageCap(canvas, cx, cy, center: BonePoint3D(kx, -78, 0), radius: 6.5, fill: cartilagePaint, stroke: cartilageBorder);
        // Tibial Plateau Cartilage
        _draw3DCartilageCap(canvas, cx, cy, center: BonePoint3D(kx, -88, 0), radius: 7.0, fill: cartilagePaint, stroke: cartilageBorder);
        // Medial & Lateral Meniscus Fibrocartilage Rings
        final menP1 = _project(BonePoint3D(kx - 5, -83, 0).transform(yaw, pitch), cx, cy);
        final menP2 = _project(BonePoint3D(kx + 5, -83, 0).transform(yaw, pitch), cx, cy);
        canvas.drawCircle(menP1, 3.8 * zoom, cartilagePaint);
        canvas.drawCircle(menP2, 3.8 * zoom, cartilagePaint);
        canvas.drawCircle(menP1, 3.8 * zoom, cartilageBorder);
        canvas.drawCircle(menP2, 3.8 * zoom, cartilageBorder);
      }
    }

    // 4. Hip Joint Acetabular Labrum & Femoral Head Cartilage
    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.pelvis || regionFocus == SkeletalRegionFocus.lowerLimbs) {
      for (final side in [-1.0, 1.0]) {
        final hx = 24.0 * side;
        _draw3DCartilageCap(canvas, cx, cy, center: BonePoint3D(hx, -24, -3), radius: 8.0, fill: cartilagePaint, stroke: cartilageBorder);
        final labrumPt = _project(BonePoint3D(hx, -24, -3).transform(yaw, pitch), cx, cy);
        canvas.drawCircle(labrumPt, 9.5 * zoom, cartilageBorder..strokeWidth = 2.0);
      }
    }

    // 5. Shoulder Glenoid Labrum & Humeral Head Cartilage
    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.upperLimbs) {
      for (final side in [-1.0, 1.0]) {
        final sx = 48.0 * side;
        _draw3DCartilageCap(canvas, cx, cy, center: BonePoint3D(sx, 74, -3), radius: 7.5, fill: cartilagePaint, stroke: cartilageBorder);
      }
    }

    // 6. Elbow Articular Cartilage
    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.upperLimbs) {
      for (final side in [-1.0, 1.0]) {
        final ex = 56.0 * side;
        _draw3DCartilageCap(canvas, cx, cy, center: BonePoint3D(ex, 19, -1), radius: 5.5, fill: cartilagePaint, stroke: cartilageBorder);
      }
    }

    // 7. Ankle Mortise & Talotibial Articular Cartilage
    if (regionFocus == SkeletalRegionFocus.full || regionFocus == SkeletalRegionFocus.lowerLimbs) {
      for (final side in [-1.0, 1.0]) {
        final ax = 18.0 * side;
        _draw3DCartilageCap(canvas, cx, cy, center: BonePoint3D(ax, -146, -2), radius: 6.0, fill: cartilagePaint, stroke: cartilageBorder);
      }
    }
  }

  void _paintSoloBoneCartilages(Canvas canvas, double cx, double cy, _BoneSegment3D soloBone, double soloScale) {
    final soloCartilageFill = Paint()
      ..color = const Color(0xFF38BDF8).withValues(alpha: 0.88)
      ..style = PaintingStyle.fill;
    final soloCartilageStroke = Paint()
      ..color = const Color(0xFF0284C7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    if (soloBone.region == SkeletalRegionFocus.spine) {
      // High-res Intervertebral Disc with nucleus pulposus & annulus fibrosus
      final discPos = _project(const BonePoint3D(0, 0, 0).transform(yaw, pitch), cx, cy);
      canvas.drawCircle(discPos, 28.0 * zoom, soloCartilageFill);
      canvas.drawCircle(discPos, 28.0 * zoom, soloCartilageStroke);
      canvas.drawCircle(discPos, 12.0 * zoom, Paint()..color = const Color(0xFFBAE6FD)..style = PaintingStyle.fill);
    } else if (soloBone.id == 'bone_femur') {
      // Femoral Head Cartilage Cap & Distal Condylar Gliding Cartilage
      final headPos = _project((const BonePoint3D(-2, 28, 0)).transform(yaw, pitch), cx, cy);
      canvas.drawCircle(headPos, 22.0 * zoom, soloCartilageFill);
      canvas.drawCircle(headPos, 22.0 * zoom, soloCartilageStroke);
      final condylePos = _project((const BonePoint3D(0, -32, 0)).transform(yaw, pitch), cx, cy);
      canvas.drawOval(Rect.fromCenter(center: condylePos, width: 44 * zoom, height: 20 * zoom), soloCartilageFill);
      canvas.drawOval(Rect.fromCenter(center: condylePos, width: 44 * zoom, height: 20 * zoom), soloCartilageStroke);
    } else if (soloBone.id == 'bone_patella_knee') {
      // Patellar posterior cartilage facet & Meniscal Horns
      final patPos = _project(const BonePoint3D(0, 0, 0).transform(yaw, pitch), cx, cy);
      canvas.drawCircle(patPos, 26.0 * zoom, soloCartilageFill);
      canvas.drawCircle(patPos, 26.0 * zoom, soloCartilageStroke);
      final m1 = _project((const BonePoint3D(-24, -10, 0)).transform(yaw, pitch), cx, cy);
      final m2 = _project((const BonePoint3D(24, -10, 0)).transform(yaw, pitch), cx, cy);
      canvas.drawOval(Rect.fromCenter(center: m1, width: 22 * zoom, height: 14 * zoom), soloCartilageFill);
      canvas.drawOval(Rect.fromCenter(center: m2, width: 22 * zoom, height: 14 * zoom), soloCartilageFill);
      canvas.drawOval(Rect.fromCenter(center: m1, width: 22 * zoom, height: 14 * zoom), soloCartilageStroke);
      canvas.drawOval(Rect.fromCenter(center: m2, width: 22 * zoom, height: 14 * zoom), soloCartilageStroke);
    } else if (soloBone.id == 'bone_humerus') {
      // Humeral Head Articular Cartilage
      final headPos = _project((const BonePoint3D(0, 32, 0)).transform(yaw, pitch), cx, cy);
      canvas.drawCircle(headPos, 24.0 * zoom, soloCartilageFill);
      canvas.drawCircle(headPos, 24.0 * zoom, soloCartilageStroke);
    } else if (soloBone.id == 'bone_tibia_fibula') {
      // Tibial Plateau Articular Cartilage & Meniscal Footprints
      final platPos = _project((const BonePoint3D(0, 32, 0)).transform(yaw, pitch), cx, cy);
      canvas.drawOval(Rect.fromCenter(center: platPos, width: 48 * zoom, height: 22 * zoom), soloCartilageFill);
      canvas.drawOval(Rect.fromCenter(center: platPos, width: 48 * zoom, height: 22 * zoom), soloCartilageStroke);
    }
  }

  void _draw3DDisc(
    Canvas canvas,
    double cx,
    double cy, {
    required BonePoint3D center,
    required double radius,
    required double height,
    required Paint fill,
    required Paint stroke,
    int segments = 8,
  }) {
    final topCenter = center + BonePoint3D(0, height * 0.5, 0);
    final botCenter = center - BonePoint3D(0, height * 0.5, 0);
    final topPts = <Offset>[];
    final botPts = <Offset>[];

    for (int i = 0; i < segments; i++) {
      final theta = (i / segments) * 2 * math.pi;
      final rx = math.cos(theta) * radius;
      final rz = math.sin(theta) * radius;
      topPts.add(_project((topCenter + BonePoint3D(rx, 0, rz)).transform(yaw, pitch), cx, cy));
      botPts.add(_project((botCenter + BonePoint3D(rx, 0, rz)).transform(yaw, pitch), cx, cy));
    }

    for (int i = 0; i < segments; i++) {
      final next = (i + 1) % segments;
      final path = Path()
        ..moveTo(topPts[i].dx, topPts[i].dy)
        ..lineTo(topPts[next].dx, topPts[next].dy)
        ..lineTo(botPts[next].dx, botPts[next].dy)
        ..lineTo(botPts[i].dx, botPts[i].dy)
        ..close();
      canvas.drawPath(path, fill);
    }

    final topPath = Path()..moveTo(topPts[0].dx, topPts[0].dy);
    for (int i = 1; i < segments; i++) {
      topPath.lineTo(topPts[i].dx, topPts[i].dy);
    }
    topPath.close();
    canvas.drawPath(topPath, fill);
    canvas.drawPath(topPath, stroke);
  }

  void _draw3DCartilageCap(
    Canvas canvas,
    double cx,
    double cy, {
    required BonePoint3D center,
    required double radius,
    required Paint fill,
    required Paint stroke,
  }) {
    final proj = _project(center.transform(yaw, pitch), cx, cy);
    canvas.drawCircle(proj, radius * zoom, fill);
    canvas.drawCircle(proj, radius * zoom, stroke);
  }

  @override
  bool shouldRepaint(covariant _Skeletal3DPainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.zoom != zoom ||
        oldDelegate.pan != pan ||
        oldDelegate.ageStage != ageStage ||
        oldDelegate.renderMode != renderMode ||
        oldDelegate.regionFocus != regionFocus ||
        oldDelegate.selectedBoneId != selectedBoneId ||
        oldDelegate.activeStatuses != activeStatuses ||
        oldDelegate.isSoloMode != isSoloMode ||
        oldDelegate.showCartilage != showCartilage ||
        oldDelegate.interventions != interventions ||
        oldDelegate.isDark != isDark;
  }
}

/// Comprehensive 3D Anatomical Bone Geometry Database
class _SkeletalMeshDatabase {
  static final List<_BoneSegment3D> allBones = [
    // 1. CRANIAL & FACIAL
    _BoneSegment3D(
      id: 'bone_cranium',
      code: '21310',
      nameEn: 'Cranium & Facial Bones',
      nameAr: 'الجمجمة وعظام الوجه',
      region: SkeletalRegionFocus.cranial,
      center: const BonePoint3D(0, 130, 0),
      hitRadius: 28,
      vertices: const [
        BonePoint3D(-22, 115, -15),
        BonePoint3D(22, 115, -15),
        BonePoint3D(25, 135, -10),
        BonePoint3D(-25, 135, -10),
        BonePoint3D(-20, 150, 8),
        BonePoint3D(20, 150, 8),
        BonePoint3D(0, 158, 5),
        BonePoint3D(0, 105, -18),
      ],
      faces: const [
        [0, 1, 2, 3],
        [3, 2, 5, 4],
        [4, 5, 6],
        [0, 1, 7],
      ],
      boneDensityTScore: 0.8,
    ),

    // 2. CERVICAL SPINE (C1-C7)
    _BoneSegment3D(
      id: 'bone_cervical',
      code: '22551',
      nameEn: 'Cervical Spine (C1-C7)',
      nameAr: 'الفقرات العنقية',
      region: SkeletalRegionFocus.spine,
      center: const BonePoint3D(0, 95, 2),
      hitRadius: 18,
      vertices: const [
        BonePoint3D(-8, 90, 0),
        BonePoint3D(8, 90, 0),
        BonePoint3D(8, 105, 4),
        BonePoint3D(-8, 105, 4),
      ],
      faces: const [
        [0, 1, 2, 3],
      ],
      boneDensityTScore: 0.4,
    ),

    // 3. THORACIC SPINE & RIBS
    _BoneSegment3D(
      id: 'bone_thoracic_ribs',
      code: '21820',
      nameEn: 'Thoracic Spine & Ribs',
      nameAr: 'الفقرات الصدرية والأضلاع',
      region: SkeletalRegionFocus.thoracic,
      center: const BonePoint3D(0, 55, 0),
      hitRadius: 36,
      vertices: const [
        BonePoint3D(-34, 75, -8),
        BonePoint3D(34, 75, -8),
        BonePoint3D(38, 40, -10),
        BonePoint3D(-38, 40, -10),
        BonePoint3D(-28, 25, -6),
        BonePoint3D(28, 25, -6),
        BonePoint3D(0, 80, -14),
        BonePoint3D(0, 30, -14),
      ],
      faces: const [
        [0, 1, 2, 3],
        [3, 2, 5, 4],
        [6, 7, 5, 4],
      ],
      boneDensityTScore: 0.2,
    ),

    // 4. CLAVICLE & SCAPULA
    _BoneSegment3D(
      id: 'bone_clavicle_scapula',
      code: '23515',
      nameEn: 'Clavicle & Scapula',
      nameAr: 'الترقوة ولوح الكتف',
      region: SkeletalRegionFocus.upperLimbs,
      center: const BonePoint3D(0, 78, -2),
      hitRadius: 32,
      vertices: const [
        BonePoint3D(-46, 78, -6),
        BonePoint3D(-14, 82, -12),
        BonePoint3D(14, 82, -12),
        BonePoint3D(46, 78, -6),
        BonePoint3D(-42, 60, 12),
        BonePoint3D(42, 60, 12),
      ],
      faces: const [
        [0, 1, 2, 3],
        [0, 4, 1],
        [3, 5, 2],
      ],
      boneDensityTScore: 0.3,
    ),

    // 5. LUMBAR SPINE (L1-L5)
    _BoneSegment3D(
      id: 'bone_lumbar',
      code: '63030',
      nameEn: 'Lumbar Spine (L1-L5)',
      nameAr: 'الفقرات القطنية وعرق النسا',
      region: SkeletalRegionFocus.spine,
      center: const BonePoint3D(0, 15, 6),
      hitRadius: 22,
      vertices: const [
        BonePoint3D(-12, 5, 5),
        BonePoint3D(12, 5, 5),
        BonePoint3D(12, 28, 7),
        BonePoint3D(-12, 28, 7),
      ],
      faces: const [
        [0, 1, 2, 3],
      ],
      hasGeriatricSpurRisk: true,
      boneDensityTScore: -1.2,
    ),

    // 6. HUMERUS (ARM - BILATERAL)
    _BoneSegment3D(
      id: 'bone_humerus',
      code: '24515',
      nameEn: 'Humerus (Arm)',
      nameAr: 'عظم العضد',
      region: SkeletalRegionFocus.upperLimbs,
      center: const BonePoint3D(52, 45, 0),
      hitRadius: 28,
      vertices: const [
        BonePoint3D(46, 75, -2),
        BonePoint3D(56, 72, -4),
        BonePoint3D(60, 20, -2),
        BonePoint3D(50, 22, 0),
        BonePoint3D(-46, 75, -2),
        BonePoint3D(-56, 72, -4),
        BonePoint3D(-60, 20, -2),
        BonePoint3D(-50, 22, 0),
      ],
      faces: const [
        [0, 1, 2, 3],
        [4, 5, 6, 7],
      ],
      hasPediatricGrowthPlate: true,
      boneDensityTScore: 0.6,
    ),

    // 7. RADIUS & ULNA (FOREARM - BILATERAL)
    _BoneSegment3D(
      id: 'bone_radius_ulna',
      code: '25607',
      nameEn: 'Radius & Ulna (Forearm)',
      nameAr: 'عظمتي الكعبرة والزند',
      region: SkeletalRegionFocus.upperLimbs,
      center: const BonePoint3D(64, -5, 0),
      hitRadius: 26,
      vertices: const [
        BonePoint3D(52, 18, 0),
        BonePoint3D(62, 18, -2),
        BonePoint3D(70, -32, -4),
        BonePoint3D(60, -32, -2),
        BonePoint3D(-52, 18, 0),
        BonePoint3D(-62, 18, -2),
        BonePoint3D(-70, -32, -4),
        BonePoint3D(-60, -32, -2),
      ],
      faces: const [
        [0, 1, 2, 3],
        [4, 5, 6, 7],
      ],
      hasPediatricGrowthPlate: true,
      hasGeriatricSpurRisk: true,
      boneDensityTScore: -0.9,
    ),

    // 8. PELVIS & HIP JOINT
    _BoneSegment3D(
      id: 'bone_pelvis',
      code: '27130',
      nameEn: 'Pelvis & Hip Joint',
      nameAr: 'الحوض ومفصل الورك',
      region: SkeletalRegionFocus.pelvis,
      center: const BonePoint3D(0, -10, 0),
      hitRadius: 36,
      vertices: const [
        BonePoint3D(-36, 10, -4),
        BonePoint3D(36, 10, -4),
        BonePoint3D(28, -24, -10),
        BonePoint3D(-28, -24, -10),
        BonePoint3D(0, -28, -12),
        BonePoint3D(0, 8, 8),
      ],
      faces: const [
        [0, 1, 2, 3],
        [3, 2, 4],
        [0, 1, 5],
      ],
      hasGeriatricSpurRisk: true,
      boneDensityTScore: -1.6,
    ),

    // 9. FEMUR (THIGH BONE - BILATERAL)
    _BoneSegment3D(
      id: 'bone_femur',
      code: '27506',
      nameEn: 'Femur (Thigh Bone)',
      nameAr: 'عظم الفخذ',
      region: SkeletalRegionFocus.lowerLimbs,
      center: const BonePoint3D(24, -55, 0),
      hitRadius: 34,
      vertices: const [
        BonePoint3D(22, -22, -4),
        BonePoint3D(34, -26, -2),
        BonePoint3D(26, -78, 0),
        BonePoint3D(16, -78, 0),
        BonePoint3D(-22, -22, -4),
        BonePoint3D(-34, -26, -2),
        BonePoint3D(-26, -78, 0),
        BonePoint3D(-16, -78, 0),
      ],
      faces: const [
        [0, 1, 2, 3],
        [4, 5, 6, 7],
      ],
      hasPediatricGrowthPlate: true,
      hasGeriatricSpurRisk: true,
      boneDensityTScore: -2.1,
    ),

    // 10. PATELLA & KNEE JOINT
    _BoneSegment3D(
      id: 'bone_patella_knee',
      code: '29881',
      nameEn: 'Patella & Knee Joint',
      nameAr: 'الرضفة ومفصل الركبة',
      region: SkeletalRegionFocus.lowerLimbs,
      center: const BonePoint3D(22, -82, -4),
      hitRadius: 20,
      vertices: const [
        BonePoint3D(17, -80, -6),
        BonePoint3D(25, -80, -6),
        BonePoint3D(25, -88, -6),
        BonePoint3D(17, -88, -6),
        BonePoint3D(-17, -80, -6),
        BonePoint3D(-25, -80, -6),
        BonePoint3D(-25, -88, -6),
        BonePoint3D(-17, -88, -6),
      ],
      faces: const [
        [0, 1, 2, 3],
        [4, 5, 6, 7],
      ],
      hasGeriatricSpurRisk: true,
      boneDensityTScore: 0.1,
    ),

    // 11. TIBIA & FIBULA (LEG - BILATERAL)
    _BoneSegment3D(
      id: 'bone_tibia_fibula',
      code: '27758',
      nameEn: 'Tibia & Fibula (Leg)',
      nameAr: 'عظمتي القصبة والشظية',
      region: SkeletalRegionFocus.lowerLimbs,
      center: const BonePoint3D(20, -118, 0),
      hitRadius: 30,
      vertices: const [
        BonePoint3D(16, -88, 0),
        BonePoint3D(26, -88, 0),
        BonePoint3D(22, -145, -2),
        BonePoint3D(14, -145, -2),
        BonePoint3D(-16, -88, 0),
        BonePoint3D(-26, -88, 0),
        BonePoint3D(-22, -145, -2),
        BonePoint3D(-14, -145, -2),
      ],
      faces: const [
        [0, 1, 2, 3],
        [4, 5, 6, 7],
      ],
      hasPediatricGrowthPlate: true,
      boneDensityTScore: 0.3,
    ),

    // 12. ANKLE & FOOT METATARSALS
    _BoneSegment3D(
      id: 'bone_ankle_foot',
      code: '27814',
      nameEn: 'Ankle & Foot Metatarsals',
      nameAr: 'الكاحل ومشط القدم',
      region: SkeletalRegionFocus.lowerLimbs,
      center: const BonePoint3D(18, -155, -8),
      hitRadius: 24,
      vertices: const [
        BonePoint3D(12, -145, -2),
        BonePoint3D(24, -145, -2),
        BonePoint3D(26, -165, -16),
        BonePoint3D(10, -165, -16),
        BonePoint3D(-12, -145, -2),
        BonePoint3D(-24, -145, -2),
        BonePoint3D(-26, -165, -16),
        BonePoint3D(-10, -165, -16),
      ],
      faces: const [
        [0, 1, 2, 3],
        [4, 5, 6, 7],
      ],
      boneDensityTScore: 0.2,
    ),
  ];

  static _BoneSegment3D? getBone(String id) {
    try {
      return allBones.firstWhere((b) => b.id == id || b.code == id || 'ortho_${b.code}' == id);
    } catch (_) {
      return null;
    }
  }
}
