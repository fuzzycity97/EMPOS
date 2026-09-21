import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/localization/app_language.dart';
import '../../domain/entities/clinical_anatomy_status_entry.dart';
import 'specialty_3d_anatomical_models.dart';

/// Universal Clinical Age Progression Stages for all medical disciplines
enum ClinicalAgeStage {
  infant('Infant / Neonate', 'رضيع / حديث الولادة', '0 - 12 Months', 'خصائص ولادية ونمو أولي'),
  child('Child / Pediatric', 'طفل', '1 - 11 Years', 'مرحلة الطفولة وتطور الأنسجة'),
  adolescent('Adolescent / Youth', 'يافع / مراهق', '12 - 18 Years', 'اكتمال التمايز الهيكلي والهرموني'),
  adult('Mature Adult', 'بالغ مكتمل', '19 - 64 Years', 'الكتلة التشريحية النموذجية'),
  geriatric('Geriatric / Senior', 'مسن / كبير السن', '65+ Years', 'تغيرات الشيخوخة والضمور والصلابة');

  final String titleEn;
  final String titleAr;
  final String ageRange;
  final String descAr;

  const ClinicalAgeStage(this.titleEn, this.titleAr, this.ageRange, this.descAr);

  String get localizedTitle => AppLanguage.isArabic ? titleAr : titleEn;
}

/// Simple 3D point with vector operations and rotation
class Point3D {
  final double x;
  final double y;
  final double z;

  const Point3D(this.x, this.y, this.z);

  Point3D operator +(Point3D other) => Point3D(x + other.x, y + other.y, z + other.z);
  Point3D operator -(Point3D other) => Point3D(x - other.x, y - other.y, z - other.z);
  Point3D operator *(double scalar) => Point3D(x * scalar, y * scalar, z * scalar);

  double dot(Point3D o) => x * o.x + y * o.y + z * o.z;

  Point3D cross(Point3D o) => Point3D(
        y * o.z - z * o.y,
        z * o.x - x * o.z,
        x * o.y - y * o.x,
      );

  double get length => math.sqrt(x * x + y * y + z * z);

  Point3D normalized() {
    final len = length;
    if (len < 0.000001) return const Point3D(0, 1, 0);
    return Point3D(x / len, y / len, z / len);
  }

  Point3D rotateX(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Point3D(x, y * cosA - z * sinA, y * sinA + z * cosA);
  }

  Point3D rotateY(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Point3D(x * cosA + z * sinA, y, -x * sinA + z * cosA);
  }

  Point3D rotateZ(double angle) {
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    return Point3D(x * cosA - y * sinA, x * sinA + y * cosA, z);
  }

  Point3D rotateEuler(double yaw, double pitch) {
    final p = rotateX(pitch);
    return p.rotateY(yaw);
  }

  Offset toScreen(Size size, double scale, {double fov = 400.0}) {
    final cx = size.width * 0.5;
    final cy = size.height * 0.5;
    final dist = fov / (fov + z + 200.0);
    return Offset(cx + x * scale * dist, cy + y * scale * dist);
  }
}

/// 3D Polygonal or Parametric Mesh Face
class MeshFace3D {
  final List<Point3D> vertices;
  final Color baseColor;
  final String? partKey;
  final String? partNameEn;
  final String? partNameAr;
  final bool isWireframe;

  MeshFace3D({
    required this.vertices,
    required this.baseColor,
    this.partKey,
    this.partNameEn,
    this.partNameAr,
    this.isWireframe = false,
  });

  Point3D get centroid {
    double sx = 0, sy = 0, sz = 0;
    for (final v in vertices) {
      sx += v.x;
      sy += v.y;
      sz += v.z;
    }
    final n = vertices.length;
    return Point3D(sx / n, sy / n, sz / n);
  }

  Point3D computeNormal() {
    if (vertices.length < 3) return const Point3D(0, 0, 1);
    final v0 = vertices[0];
    final v1 = vertices[1];
    final v2 = vertices[2];
    return (v1 - v0).cross(v2 - v0).normalized();
  }
}

/// Interactive 3D Anatomical Scene Viewer Widget with Solo Part Inspection & 3D Medical Instruments
class Clinical3dSceneViewer extends StatefulWidget {
  final List<MeshFace3D> Function(
    ClinicalAgeStage ageStage, {
    SpecialtyInstrument? instrument,
    bool isSoloMode,
    String? soloPartKey,
  }) sceneMeshBuilder;
  final void Function(String partKey, String nameEn, String nameAr)? onPartSelected;
  final void Function(String partKey, String nameEn, String nameAr, Offset globalPos)? onPartSecondaryTap;
  final Map<String, ClinicalAnatomyStatusEntry>? activeStatuses;
  final ClinicalAgeStage initialAgeStage;
  final void Function(ClinicalAgeStage stage)? onAgeStageChanged;
  final String specialtyTitle;
  final String specialtyTitleAr;
  final IconData specialtyIcon;
  final Color primaryColor;
  final double initialZoom;
  final double initialPitch;
  final double initialYaw;
  final double height;
  final List<SpecialtyInstrument> availableInstruments;
  final Widget? overlayBottomWidget;

  const Clinical3dSceneViewer({
    super.key,
    required this.sceneMeshBuilder,
    this.onPartSelected,
    this.onPartSecondaryTap,
    this.activeStatuses,
    this.initialAgeStage = ClinicalAgeStage.adult,
    this.onAgeStageChanged,
    required this.specialtyTitle,
    required this.specialtyTitleAr,
    required this.specialtyIcon,
    required this.primaryColor,
    this.initialZoom = 1.0,
    this.initialPitch = 0.2,
    this.initialYaw = 0.3,
    this.height = 370,
    this.availableInstruments = const [],
    this.overlayBottomWidget,
  });

  @override
  State<Clinical3dSceneViewer> createState() => _Clinical3dSceneViewerState();
}

class _Clinical3dSceneViewerState extends State<Clinical3dSceneViewer> with SingleTickerProviderStateMixin {
  late ClinicalAgeStage _currentAgeStage;
  late double _yaw;
  late double _pitch;
  late double _zoom;
  Offset? _lastPanPos;
  String? _hoveredPartKey;
  String? _selectedPartKey;
  String? _selectedPartNameEn;
  String? _selectedPartNameAr;
  bool _isSoloMode = false;
  SpecialtyInstrument _selectedInstrument = SpecialtyInstrument.none;
  bool _autoRotate = false;
  late final AnimationController _autoRotController;
  Timer? _singleTapTimer;
  Offset? _pendingTapPos;

  @override
  void initState() {
    super.initState();
    _currentAgeStage = widget.initialAgeStage;
    _yaw = widget.initialYaw;
    _pitch = widget.initialPitch;
    _zoom = widget.initialZoom;

    _autoRotController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..addListener(() {
        if (_autoRotate) {
          setState(() {
            _yaw += 0.015;
            if (_yaw > math.pi * 2) _yaw -= math.pi * 2;
          });
        }
      });
  }

  @override
  void dispose() {
    _singleTapTimer?.cancel();
    _singleTapTimer = null;
    _autoRotController.dispose();
    super.dispose();
  }

  void _resetCamera() {
    setState(() {
      _yaw = widget.initialYaw;
      _pitch = widget.initialPitch;
      _zoom = widget.initialZoom;
    });
  }

  void _toggleAutoRotate() {
    setState(() {
      _autoRotate = !_autoRotate;
      if (_autoRotate) {
        _autoRotController.repeat();
      } else {
        _autoRotController.stop();
      }
    });
  }

  void _enterSoloMode() {
    if (_selectedPartKey != null) {
      setState(() {
        _isSoloMode = true;
        _zoom = 1.6; // zoom into the solo part
      });
    }
  }

  void _exitSoloMode() {
    setState(() {
      _isSoloMode = false;
      _zoom = widget.initialZoom;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final faces = widget.sceneMeshBuilder(
      _currentAgeStage,
      instrument: SpecialtyInstrument.none,
      isSoloMode: _isSoloMode,
      soloPartKey: _selectedPartKey,
    );

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isSoloMode
              ? Colors.amberAccent
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: _isSoloMode ? 2.0 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withValues(alpha: isDark ? 0.08 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. TOP HEADER WITH SPECIALTY BADGE & CONTROLS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131D34) : Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: widget.primaryColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(widget.specialtyIcon, color: widget.primaryColor, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              _isSoloMode
                                  ? '${AppLanguage.tr('SOLO 3D VIEW: ', 'عرض ثلاثي الأبعاد منفرد: ')}${AppLanguage.isArabic ? (_selectedPartNameAr ?? '') : (_selectedPartNameEn ?? '')}'
                                  : (AppLanguage.isArabic ? widget.specialtyTitleAr : widget.specialtyTitle),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: _isSoloMode ? Colors.amberAccent : (isDark ? Colors.white : const Color(0xFF0F172A)),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (_isSoloMode) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: Colors.amberAccent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SOLO',
                                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.amberAccent),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _isSoloMode
                            ? AppLanguage.tr('Isolated realistic 3D organ view with instruments', 'معاينة العضو منفرداً بدقة عالية مع الأدوات الطبية')
                            : 'Interactive 3D Anatomical Projection (3D مجسم تفاعلي)',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // Solo Mode Toggle button
                if (_isSoloMode)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0284C7),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.arrow_back, size: 14),
                    label: Text(AppLanguage.tr('Full View', 'العرض الكامل')),
                    onPressed: _exitSoloMode,
                  )
                else if (_selectedPartKey != null)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      textStyle: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(LucideIcons.maximize2, size: 13),
                    label: Text(AppLanguage.tr('Solo 3D', 'عرض منفرد 3D')),
                    onPressed: _enterSoloMode,
                  ),

                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    _autoRotate ? Icons.pause_circle_filled : Icons.play_circle_outline,
                    size: 20,
                    color: _autoRotate ? widget.primaryColor : (isDark ? Colors.white70 : Colors.black54),
                  ),
                  tooltip: 'Auto Rotate (دوران تلقائي)',
                  onPressed: _toggleAutoRotate,
                ),
                IconButton(
                  icon: Icon(Icons.refresh, size: 20, color: isDark ? Colors.white70 : Colors.black54),
                  tooltip: 'Reset View (إعادة ضبط)',
                  onPressed: _resetCamera,
                ),
              ],
            ),
          ),

          // 2. UNIVERSAL AGE PROGRESSION SELECTOR BAR
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                ),
              ),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(LucideIcons.clock, size: 14, color: widget.primaryColor),
                      const SizedBox(width: 6),
                      Text(
                        AppLanguage.tr('Age Stage:', 'المرحلة العمرية:'),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  ...ClinicalAgeStage.values.map((stage) {
                    final isSel = stage == _currentAgeStage;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: InkWell(
                        onTap: () {
                          setState(() => _currentAgeStage = stage);
                          widget.onAgeStageChanged?.call(stage);
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isSel
                                ? widget.primaryColor
                                : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? widget.primaryColor
                                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                stage.localizedTitle,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel
                                      ? Colors.white
                                      : (isDark ? Colors.white70 : const Color(0xFF334155)),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(${stage.ageRange})',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: isSel
                                      ? Colors.white.withValues(alpha: 0.8)
                                      : (isDark ? Colors.white38 : Colors.black38),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // 3. MAIN 3D INTERACTIVE CANVAS VIEWPORT
          SizedBox(
            height: widget.height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                    onPanStart: (details) {
                      _singleTapTimer?.cancel();
                      _singleTapTimer = null;
                      _pendingTapPos = null;
                      _lastPanPos = details.localPosition;
                    },
                    onPanUpdate: (details) {
                      if (_lastPanPos != null) {
                        final dx = details.localPosition.dx - _lastPanPos!.dx;
                        final dy = details.localPosition.dy - _lastPanPos!.dy;
                        setState(() {
                          _yaw += dx * 0.012;
                          _pitch = (_pitch + dy * 0.012).clamp(-1.4, 1.4);
                        });
                        _lastPanPos = details.localPosition;
                      }
                    },
                    onPanEnd: (_) => _lastPanPos = null,
                    onTapUp: (details) {
                      if (_singleTapTimer != null && _singleTapTimer!.isActive) {
                        // Second tap within 500ms window: cancel timer and trigger double tap (Solo Mode)!
                        _singleTapTimer!.cancel();
                        _singleTapTimer = null;
                        _pendingTapPos = null;
                        _handleCanvasDoubleTap(details.localPosition, faces);
                      } else {
                        // First tap: buffer location and wait one half second (500ms)
                        _pendingTapPos = details.localPosition;
                        _singleTapTimer = Timer(const Duration(milliseconds: 500), () {
                          if (mounted && _pendingTapPos != null) {
                            final pos = _pendingTapPos!;
                            _pendingTapPos = null;
                            _singleTapTimer = null;
                            _handleCanvasTap(pos, faces);
                          }
                        });
                      }
                    },
                    onSecondaryTapUp: (details) {
                      _singleTapTimer?.cancel();
                      _singleTapTimer = null;
                      _pendingTapPos = null;
                      _handleCanvasSecondaryTap(details.localPosition, details.globalPosition, faces);
                    },
                    onLongPressStart: (details) {
                      _singleTapTimer?.cancel();
                      _singleTapTimer = null;
                      _pendingTapPos = null;
                      _handleCanvasSecondaryTap(details.localPosition, details.globalPosition, faces);
                    },
                    child: CustomPaint(
                      painter: _Generic3DScenePainter(
                        faces: faces,
                        yaw: _yaw,
                        pitch: _pitch,
                        zoom: _zoom,
                        isDark: isDark,
                        primaryColor: widget.primaryColor,
                        activeStatuses: widget.activeStatuses,
                        hoveredPartKey: _hoveredPartKey,
                        selectedPartKey: _selectedPartKey,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                ),

                // Floating zoom buttons
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildFloatingCircleBtn(
                        icon: Icons.add,
                        tooltip: 'Zoom In',
                        onTap: () => setState(() => _zoom = (_zoom * 1.15).clamp(0.4, 4.0)),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 6),
                      _buildFloatingCircleBtn(
                        icon: Icons.remove,
                        tooltip: 'Zoom Out',
                        onTap: () => setState(() => _zoom = (_zoom / 1.15).clamp(0.4, 4.0)),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                // Hint overlay pill
                Positioned(
                  left: 12,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.hand, size: 12, color: widget.primaryColor),
                        const SizedBox(width: 5),
                        Text(
                          _isSoloMode
                              ? AppLanguage.tr('Solo Mode active • Double-click to exit • Drag to rotate', 'الوضع المنفرد نشط • انقر مرتين للخروج • اسحب للتدوير')
                              : AppLanguage.tr('Tap to select • Double-click for Solo 3D • Drag to rotate', 'انقر للتحديد • انقر مرتين للعرض المنفرد 3D • اسحب للتدوير'),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          if (widget.overlayBottomWidget != null) widget.overlayBottomWidget!,
        ],
      ),
    );
  }

  Widget _buildInstrumentPill(SpecialtyInstrument inst, bool isDark) {
    final isSel = inst == _selectedInstrument;
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: InkWell(
        onTap: () => setState(() => _selectedInstrument = inst),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: isSel
                ? const Color(0xFF0284C7)
                : (isDark ? const Color(0xFF1E293B) : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSel
                  ? const Color(0xFF38BDF8)
                  : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isSel) const Icon(Icons.check, size: 11, color: Colors.white),
              if (isSel) const SizedBox(width: 3),
              Text(
                inst.localizedTitle,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                  color: isSel
                      ? Colors.white
                      : (isDark ? Colors.white70 : const Color(0xFF334155)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  MeshFace3D? _findClosestFace(Offset tapPos, List<MeshFace3D> faces, {double maxDist = 58.0}) {
    final size = Size(double.infinity, widget.height);
    final scale = 1.0 * _zoom;

    MeshFace3D? closestFace;
    double minSqDist = maxDist * maxDist;

    for (final face in faces) {
      if (face.partKey == null) continue;
      final rotC = face.centroid.rotateEuler(_yaw, _pitch);
      final screenPos = rotC.toScreen(size, scale);
      final distSq = (screenPos.dx - tapPos.dx) * (screenPos.dx - tapPos.dx) +
          (screenPos.dy - tapPos.dy) * (screenPos.dy - tapPos.dy);
      if (distSq < minSqDist) {
        minSqDist = distSq;
        closestFace = face;
      }
    }
    return closestFace;
  }

  void _handleCanvasTap(Offset tapPos, List<MeshFace3D> faces) {
    final closestFace = _findClosestFace(tapPos, faces, maxDist: 58.0);

    if (closestFace != null) {
      setState(() {
        _hoveredPartKey = closestFace.partKey;
        _selectedPartKey = closestFace.partKey;
        _selectedPartNameEn = closestFace.partNameEn ?? closestFace.partKey!;
        _selectedPartNameAr = closestFace.partNameAr ?? closestFace.partNameEn ?? closestFace.partKey!;
      });
      widget.onPartSelected?.call(
        closestFace.partKey!,
        closestFace.partNameEn ?? closestFace.partKey!,
        closestFace.partNameAr ?? closestFace.partNameEn ?? closestFace.partKey!,
      );
    }
  }

  void _handleCanvasDoubleTap(Offset tapPos, List<MeshFace3D> faces) {
    final closestFace = _findClosestFace(tapPos, faces, maxDist: 75.0);

    if (closestFace != null && closestFace.partKey != null) {
      final key = closestFace.partKey!;
      final en = closestFace.partNameEn ?? key;
      final ar = closestFace.partNameAr ?? en;
      setState(() {
        _hoveredPartKey = key;
        _selectedPartKey = key;
        _selectedPartNameEn = en;
        _selectedPartNameAr = ar;
        // Toggle solo mode
        if (_isSoloMode && _selectedPartKey == key) {
          _isSoloMode = false;
          _zoom = widget.initialZoom;
        } else {
          _isSoloMode = true;
          _zoom = 1.6;
        }
      });
    } else if (_isSoloMode) {
      // Double clicking outside or background exits solo mode
      _exitSoloMode();
    }
  }

  void _handleCanvasSecondaryTap(Offset tapPos, Offset globalPos, List<MeshFace3D> faces) {
    final size = Size(double.infinity, widget.height);
    final scale = 1.0 * _zoom;

    MeshFace3D? closestFace;
    double minSqDist = 110.0 * 110.0;

    for (final face in faces) {
      if (face.partKey == null) continue;
      final rotC = face.centroid.rotateEuler(_yaw, _pitch);
      final screenPos = rotC.toScreen(size, scale);
      final distSq = (screenPos.dx - tapPos.dx) * (screenPos.dx - tapPos.dx) +
          (screenPos.dy - tapPos.dy) * (screenPos.dy - tapPos.dy);
      if (distSq < minSqDist) {
        minSqDist = distSq;
        closestFace = face;
      }
    }

    if (closestFace != null) {
      final key = closestFace.partKey!;
      final en = closestFace.partNameEn ?? key;
      final ar = closestFace.partNameAr ?? en;
      setState(() {
        _hoveredPartKey = key;
        _selectedPartKey = key;
        _selectedPartNameEn = en;
        _selectedPartNameAr = ar;
      });
      widget.onPartSecondaryTap?.call(key, en, ar, globalPos);
    }
  }

  Widget _buildFloatingCircleBtn({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: (isDark ? const Color(0xFF1E293B) : Colors.white).withValues(alpha: 0.9),
            shape: BoxShape.circle,
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, size: 16, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        ),
      ),
    );
  }
}

/// Custom painter that projects 3D faces with realistic multi-light studio shading,
/// Blinn-Phong organic specular highlights, Fresnel curvature depth, and smooth face rendering.
class _Generic3DScenePainter extends CustomPainter {
  final List<MeshFace3D> faces;
  final double yaw;
  final double pitch;
  final double zoom;
  final bool isDark;
  final Color primaryColor;
  final Map<String, ClinicalAnatomyStatusEntry>? activeStatuses;
  final String? hoveredPartKey;
  final String? selectedPartKey;

  _Generic3DScenePainter({
    required this.faces,
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.isDark,
    required this.primaryColor,
    this.activeStatuses,
    this.hoveredPartKey,
    this.selectedPartKey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    // Realistic surgical key light from upper-front-left
    final keyLight = const Point3D(-0.55, -0.65, 0.52).normalized();
    // Soft cool bounce fill light from lower-front-right
    final fillLight = const Point3D(0.45, 0.35, 0.65).normalized();
    // Halfway vector for Blinn-Phong specular sheen (view is along +Z = 0, 0, 1)
    final halfDir = (keyLight * -1.0 + const Point3D(0, 0, 1)).normalized();

    final transformedFaces = <_RenderFace>[];

    for (final face in faces) {
      final rotVertices = face.vertices.map((v) => v.rotateEuler(yaw, pitch)).toList();
      double sumZ = 0;
      for (final v in rotVertices) {
        sumZ += v.z;
      }
      final avgZ = sumZ / rotVertices.length;

      Point3D norm = const Point3D(0, 0, 1);
      if (rotVertices.length >= 3) {
        norm = (rotVertices[1] - rotVertices[0]).cross(rotVertices[2] - rotVertices[0]).normalized();
      }

      transformedFaces.add(_RenderFace(
        original: face,
        rotatedVertices: rotVertices,
        normal: norm,
        avgZ: avgZ,
      ));
    }

    // Depth sorting from back to front
    transformedFaces.sort((a, b) => a.avgZ.compareTo(b.avgZ));
    final scale = 1.0 * zoom;

    for (final rf in transformedFaces) {
      final face = rf.original;
      final rotVerts = rf.rotatedVertices;
      if (rotVerts.isEmpty) continue;

      final screenPts = rotVerts.map((v) => v.toScreen(size, scale)).toList();

      final path = Path()..moveTo(screenPts[0].dx, screenPts[0].dy);
      for (int i = 1; i < screenPts.length; i++) {
        path.lineTo(screenPts[i].dx, screenPts[i].dy);
      }
      path.close();

      Color faceColor = face.baseColor;
      if (face.partKey != null && activeStatuses != null) {
        final status = activeStatuses![face.partKey];
        if (status != null) {
          faceColor = status.visualColor;
        }
      }

      // Multi-light diffuse calculation
      final keyDot = math.max(0.0, -rf.normal.dot(keyLight));
      final fillDot = math.max(0.0, -rf.normal.dot(fillLight));
      const ambient = 0.38;
      final diffuse = (ambient + keyDot * 0.52 + fillDot * 0.20).clamp(0.0, 1.0);

      // Blinn-Phong organic specular highlight for wet/glossy tissues & hardware
      final specDot = math.max(0.0, rf.normal.dot(halfDir));
      final specular = math.pow(specDot, 18.0) * 0.35;

      // Fresnel rim glow highlighting organic 3D curvature
      final rim = math.pow(1.0 - math.max(0.0, rf.normal.z.abs()), 2.6) * 0.22;

      final baseR = faceColor.r * 255;
      final baseG = faceColor.g * 255;
      final baseB = faceColor.b * 255;

      final r = (baseR * diffuse + 255 * specular + baseR * rim).toInt().clamp(0, 255);
      final g = (baseG * diffuse + 255 * specular + baseG * rim).toInt().clamp(0, 255);
      final b = (baseB * diffuse + 255 * specular + baseB * rim).toInt().clamp(0, 255);
      final alpha = faceColor.a > 0.05 ? (faceColor.a * 255).toInt() : 255;
      final shadedColor = Color.fromARGB(alpha, r, g, b);

      if (!face.isWireframe) {
        final fillPaint = Paint()
          ..color = shadedColor
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, fillPaint);
      }

      // Only draw stroke outlines for wireframe meshes or selected/hovered parts.
      // This completely removes the "sketchy wireframe CAD" look while keeping clean selection highlights!
      final isHovered = face.partKey != null && face.partKey == hoveredPartKey;
      final isSelected = face.partKey != null && face.partKey == selectedPartKey;
      if (face.isWireframe || isHovered || isSelected) {
        final borderPaint = Paint()
          ..color = isHovered
              ? const Color(0xFFFBBF24) // Amber accent for hovered
              : (isSelected
                  ? primaryColor.withValues(alpha: 0.95)
                  : shadedColor)
          ..strokeWidth = (isHovered || isSelected) ? 2.2 : 1.2
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _Generic3DScenePainter old) {
    return old.yaw != yaw ||
        old.pitch != pitch ||
        old.zoom != zoom ||
        old.isDark != isDark ||
        old.hoveredPartKey != hoveredPartKey ||
        old.selectedPartKey != selectedPartKey ||
        old.faces != faces ||
        old.activeStatuses != activeStatuses;
  }
}

class _RenderFace {
  final MeshFace3D original;
  final List<Point3D> rotatedVertices;
  final Point3D normal;
  final double avgZ;

  _RenderFace({
    required this.original,
    required this.rotatedVertices,
    required this.normal,
    required this.avgZ,
  });
}
