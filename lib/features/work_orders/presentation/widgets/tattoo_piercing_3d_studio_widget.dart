import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_language.dart';

enum BodyRegionView {
  fullBody('Full Body', 'الجسم بالكامل'),
  chestTorso('Chest & Torso', 'الصدر والجذع'),
  backSpine('Back & Spine', 'الظهر والعمود الفقري'),
  leftArm('Left Arm & Shoulder', 'الذراع الأيسر والكتف'),
  rightArm('Right Arm & Shoulder', 'الذراع الأيمن والكتف'),
  legs('Legs & Calves', 'الساقين والربلتين'),
  neckHead('Neck & Head', 'العنق والرأس');

  final String labelEn;
  final String labelAr;
  const BodyRegionView(this.labelEn, this.labelAr);

  String get localized => AppLanguage.tr(labelEn, labelAr);
}

enum TattooArtStyle {
  neoTraditional('Neo-Traditional', 'نيو تراديشنال'),
  blackAndGrey('Black & Grey', 'أسود ورمادي'),
  japaneseIrezumi('Japanese Irezumi', 'ياباني إيريزومي'),
  fineLineMicro('Fine Line Micro', 'خطوط دقيقة'),
  colorRealism('Color Realism', 'واقعي ملون'),
  piercingTitanium('Titanium Piercing', 'بيرسينج تيتانيوم');

  final String labelEn;
  final String labelAr;
  const TattooArtStyle(this.labelEn, this.labelAr);

  String get localized => AppLanguage.tr(labelEn, labelAr);
}

class TattooDesignRecord {
  final String id;
  final String title;
  final bool isPiercing;
  final TattooArtStyle style;
  final BodyRegionView targetRegion;
  final Color inkColor;
  final double priceEgp;
  final double estimatedHours;
  final int sessionsCount;
  final Offset position; // Normalized coordinates 0.0 - 1.0 on body mesh
  final double scale;
  final String notes;

  const TattooDesignRecord({
    required this.id,
    required this.title,
    this.isPiercing = false,
    this.style = TattooArtStyle.blackAndGrey,
    this.targetRegion = BodyRegionView.chestTorso,
    this.inkColor = const Color(0xFF1E293B),
    this.priceEgp = 1200.0,
    this.estimatedHours = 2.5,
    this.sessionsCount = 1,
    this.position = const Offset(0.5, 0.35),
    this.scale = 1.0,
    this.notes = '',
  });

  TattooDesignRecord copyWith({
    String? id,
    String? title,
    bool? isPiercing,
    TattooArtStyle? style,
    BodyRegionView? targetRegion,
    Color? inkColor,
    double? priceEgp,
    double? estimatedHours,
    int? sessionsCount,
    Offset? position,
    double? scale,
    String? notes,
  }) {
    return TattooDesignRecord(
      id: id ?? this.id,
      title: title ?? this.title,
      isPiercing: isPiercing ?? this.isPiercing,
      style: style ?? this.style,
      targetRegion: targetRegion ?? this.targetRegion,
      inkColor: inkColor ?? this.inkColor,
      priceEgp: priceEgp ?? this.priceEgp,
      estimatedHours: estimatedHours ?? this.estimatedHours,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      position: position ?? this.position,
      scale: scale ?? this.scale,
      notes: notes ?? this.notes,
    );
  }
}

/// 3D Interactive, Editable Tattoo & Piercing Body Stencil Studio
class TattooPiercing3DStudioWidget extends StatelessWidget {
  final ValueNotifier<List<TattooDesignRecord>> designsNotifier;
  final ValueNotifier<TattooDesignRecord?> selectedDesignNotifier;
  final ValueNotifier<BodyRegionView> activeRegionNotifier;
  final ValueNotifier<double> yawNotifier;
  final ValueNotifier<double> pitchNotifier;
  final ValueNotifier<bool> isPlacingModeNotifier;
  final Function(TattooDesignRecord design)? onDesignCommitted;

  TattooPiercing3DStudioWidget({
    super.key,
    ValueNotifier<List<TattooDesignRecord>>? designsNotifier,
    ValueNotifier<TattooDesignRecord?>? selectedDesignNotifier,
    ValueNotifier<BodyRegionView>? activeRegionNotifier,
    ValueNotifier<double>? yawNotifier,
    ValueNotifier<double>? pitchNotifier,
    ValueNotifier<bool>? isPlacingModeNotifier,
    this.onDesignCommitted,
  })  : designsNotifier = designsNotifier ??
            ValueNotifier<List<TattooDesignRecord>>(defaultDesigns),
        selectedDesignNotifier =
            selectedDesignNotifier ?? ValueNotifier<TattooDesignRecord?>(defaultDesigns.first),
        activeRegionNotifier =
            activeRegionNotifier ?? ValueNotifier<BodyRegionView>(BodyRegionView.fullBody),
        yawNotifier = yawNotifier ?? ValueNotifier<double>(0.0),
        pitchNotifier = pitchNotifier ?? ValueNotifier<double>(0.0),
        isPlacingModeNotifier = isPlacingModeNotifier ?? ValueNotifier<bool>(false);

  static const List<TattooDesignRecord> defaultDesigns = [
    TattooDesignRecord(
      id: 'TAT-001',
      title: 'Japanese Koi & Peony Half-Sleeve',
      isPiercing: false,
      style: TattooArtStyle.japaneseIrezumi,
      targetRegion: BodyRegionView.rightArm,
      inkColor: Color(0xFF1E3A8A),
      priceEgp: 3500.0,
      estimatedHours: 4.5,
      sessionsCount: 2,
      position: Offset(0.32, 0.38),
      scale: 1.2,
      notes: 'Flowing water background, deep cobalt shading with crimson petals.',
    ),
    TattooDesignRecord(
      id: 'TAT-002',
      title: 'Sacred Geometry Sternum Mandala',
      isPiercing: false,
      style: TattooArtStyle.fineLineMicro,
      targetRegion: BodyRegionView.chestTorso,
      inkColor: Color(0xFF0F172A),
      priceEgp: 2200.0,
      estimatedHours: 3.0,
      sessionsCount: 1,
      position: Offset(0.50, 0.32),
      scale: 1.0,
      notes: '0.25mm 3RL single needle micro linework.',
    ),
    TattooDesignRecord(
      id: 'PRC-003',
      title: 'Titanium Anodized Helix Piercing',
      isPiercing: true,
      style: TattooArtStyle.piercingTitanium,
      targetRegion: BodyRegionView.neckHead,
      inkColor: Color(0xFFEAB308),
      priceEgp: 650.0,
      estimatedHours: 0.5,
      sessionsCount: 1,
      position: Offset(0.56, 0.14),
      scale: 0.8,
      notes: 'Implant-grade ASTM F-136 titanium bar with opal cluster.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER & TOOLBAR ───────────────────────────────────────────────
          _buildToolbar(context),
          const Divider(height: 1, color: AppColors.borderDark),

          // ── 3D INTERACTIVE WORKSPACE ───────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                // Left 3D Body Canvas
                Expanded(
                  flex: 3,
                  child: _build3DBodyViewport(context),
                ),
                const VerticalDivider(width: 1, color: AppColors.borderDark),

                // Right Stencil & Design Inspector Panel
                SizedBox(
                  width: 330,
                  child: _buildInspectorPanel(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.brush, color: Color(0xFFA855F7), size: 20),
            const SizedBox(width: 8),
            Text(
              AppLanguage.tr('3D Tattoo & Body Canvas Studio', 'استوديو وشم وبيرسينج ثلاثي الأبعاد'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 14),

            // "+ Add New Stencil / Tattoo" Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.add_circle, size: 14),
              label: Text(
                AppLanguage.tr('+ Add Stencil to 3D', '+ إضافة رسم 3D'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showAddDesignDialog(context),
            ),
            const SizedBox(width: 12),

            // Placing Mode Toggle
            ValueListenableBuilder<bool>(
              valueListenable: isPlacingModeNotifier,
              builder: (context, isPlacing, _) {
                return FilterChip(
                  avatar: Icon(
                    isPlacing ? Icons.location_on : Icons.touch_app,
                    size: 14,
                    color: isPlacing ? Colors.black : Colors.white70,
                  ),
                  label: Text(
                    isPlacing
                        ? AppLanguage.tr('Click Body to Place Stencil', 'انقر على الجسم لتثبيت الرسم')
                        : AppLanguage.tr('Place on Body', 'تثبيت على الجسم'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPlacing ? Colors.black : Colors.white70,
                    ),
                  ),
                  selected: isPlacing,
                  selectedColor: const Color(0xFFEAB308),
                  backgroundColor: AppColors.surfaceElevatedDark,
                  onSelected: (val) => isPlacingModeNotifier.value = val,
                );
              },
            ),
            const SizedBox(width: 12),

            // Region Focus Filter Chips
            ValueListenableBuilder<BodyRegionView>(
              valueListenable: activeRegionNotifier,
              builder: (context, activeRegion, _) {
                return Row(
                  children: BodyRegionView.values.take(4).map((region) {
                    final isSel = region == activeRegion;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(region.localized, style: const TextStyle(fontSize: 10.5)),
                        selected: isSel,
                        selectedColor: const Color(0xFFA855F7),
                        backgroundColor: AppColors.surfaceElevatedDark,
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                        onSelected: (_) {
                          activeRegionNotifier.value = region;
                          if (region == BodyRegionView.backSpine) {
                            yawNotifier.value = 180.0;
                          } else if (region == BodyRegionView.leftArm) {
                            yawNotifier.value = 90.0;
                          } else if (region == BodyRegionView.rightArm) {
                            yawNotifier.value = -90.0;
                          } else {
                            yawNotifier.value = 0.0;
                          }
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(width: 8),

            // Reset Rotation
            IconButton(
              tooltip: AppLanguage.tr('Reset 3D View', 'إعادة ضبط العرض 3D'),
              icon: const Icon(Icons.restart_alt, size: 18, color: AppColors.textSecondaryDark),
              onPressed: () {
                yawNotifier.value = 0.0;
                pitchNotifier.value = 0.0;
                activeRegionNotifier.value = BodyRegionView.fullBody;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _build3DBodyViewport(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        yawNotifier,
        pitchNotifier,
        designsNotifier,
        selectedDesignNotifier,
        isPlacingModeNotifier,
        activeRegionNotifier,
      ]),
      builder: (context, _) {
        final yaw = yawNotifier.value;
        final pitch = pitchNotifier.value;
        final designs = designsNotifier.value;
        final selectedDesign = selectedDesignNotifier.value;
        final isPlacing = isPlacingModeNotifier.value;
        final activeRegion = activeRegionNotifier.value;

        return Stack(
          children: [
            // Gesture Area for 3D Orbit & Placement
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  yawNotifier.value = (yawNotifier.value + details.delta.dx * 0.8) % 360;
                  pitchNotifier.value = (pitchNotifier.value - details.delta.dy * 0.5).clamp(-30.0, 30.0);
                },
                onTapUp: (details) {
                  if (isPlacing && selectedDesign != null) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box != null) {
                      final localPos = details.localPosition;
                      final normX = (localPos.dx / box.size.width).clamp(0.1, 0.9);
                      final normY = (localPos.dy / box.size.height).clamp(0.1, 0.9);

                      final updated = selectedDesign.copyWith(position: Offset(normX, normY));
                      final list = List<TattooDesignRecord>.from(designsNotifier.value);
                      final idx = list.indexWhere((d) => d.id == selectedDesign.id);
                      if (idx != -1) {
                        list[idx] = updated;
                        designsNotifier.value = list;
                        selectedDesignNotifier.value = updated;
                      }
                      isPlacingModeNotifier.value = false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr(
                            'Stencil anchored onto 3D body position!',
                            'تم تثبيت الرسم على الجسم ثلاثي الأبعاد!',
                          )),
                          backgroundColor: const Color(0xFFA855F7),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  }
                },
                child: CustomPaint(
                  painter: _TattooBody3DPainter(
                    yaw: yaw,
                    pitch: pitch,
                    region: activeRegion,
                    designs: designs,
                    selectedDesign: selectedDesign,
                  ),
                ),
              ),
            ),

            // Top Left HUD Overlay
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.view_in_ar, size: 14, color: Color(0xFFA855F7)),
                    const SizedBox(width: 6),
                    Text(
                      'Yaw: ${yaw.toStringAsFixed(0)}°  Pitch: ${pitch.toStringAsFixed(0)}°  •  ${activeRegion.localized}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Placement Guide Prompt
            if (isPlacing)
              Positioned(
                bottom: 16,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAB308).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.black, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLanguage.tr(
                            'Click anywhere on the 3D body surface to anchor the stencil.',
                            'انقر في أي مكان على سطح الجسم ثلاثي الأبعاد لتثبيت الرسم.',
                          ),
                          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ),
                      TextButton(
                        onPressed: () => isPlacingModeNotifier.value = false,
                        child: Text(AppLanguage.tr('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.black)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildInspectorPanel(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([designsNotifier, selectedDesignNotifier]),
      builder: (context, _) {
        final designs = designsNotifier.value;
        final selected = selectedDesignNotifier.value ?? (designs.isNotEmpty ? designs.first : null);

        return Container(
          color: AppColors.surfaceDark,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLanguage.tr('Studio Stencil Catalog', 'كتالوج رسومات الاستوديو'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),

              // Design List Selector
              SizedBox(
                height: 120,
                child: ListView.separated(
                  itemCount: designs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = designs[index];
                    final isSel = item.id == selected?.id;

                    return InkWell(
                      onTap: () => selectedDesignNotifier.value = item,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFA855F7).withValues(alpha: 0.15) : AppColors.surfaceElevatedDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? const Color(0xFFA855F7) : AppColors.borderDark,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item.inkColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white38),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      color: isSel ? Colors.white : AppColors.textPrimaryDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.style.localized} • ${item.priceEgp.toStringAsFixed(0)} EGP',
                                    style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ),
                            if (item.isPiercing)
                              const Icon(Icons.ring_volume, size: 14, color: Color(0xFFEAB308))
                            else
                              const Icon(Icons.brush, size: 14, color: Color(0xFFA855F7)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 16, color: AppColors.borderDark),

              // Selected Stencil Inspector Details
              if (selected != null) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFA855F7).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                selected.id,
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFA855F7)),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                selected.title,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFA855F7)),
                              tooltip: AppLanguage.tr('Edit Design', 'تعديل بيانات الرسم'),
                              onPressed: () => _showEditDesignDialog(context, selected),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Metric Badges
                        Row(
                          children: [
                            _buildInfoBadge(
                              label: AppLanguage.tr('Price', 'السعر'),
                              val: '${selected.priceEgp.toStringAsFixed(0)} EGP',
                              color: Colors.greenAccent,
                            ),
                            const SizedBox(width: 6),
                            _buildInfoBadge(
                              label: AppLanguage.tr('Sessions', 'الجلسات'),
                              val: '${selected.sessionsCount} (${selected.estimatedHours}h)',
                              color: Colors.cyanAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Text(
                          '${AppLanguage.tr("Target Region", "المنطقة المستهدفة")}: ${selected.targetRegion.localized}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLanguage.tr("Art Style", "نمط الرسم")}: ${selected.style.localized}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        ),
                        if (selected.notes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevatedDark,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              selected.notes,
                              style: const TextStyle(fontSize: 10.5, color: Colors.white70),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Actions: Print Thermal Stencil & Commit
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.print, size: 14),
                  label: Text(
                    AppLanguage.tr('Print Thermal Stencil Blueprint', 'طباعة باترون الوشم الحراري'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Thermal stencil sent to Bluetooth printer!',
                          'تم إرسال باترون الوشم لطابعة الاستنسل الحرارية!',
                        )),
                        backgroundColor: const Color(0xFF3B82F6),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA855F7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.check_circle_outline, size: 14),
                  label: Text(
                    AppLanguage.tr('Book Session with 3D Stencil', 'حجز جلسة بالرسم المختار'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    onDesignCommitted?.call(selected);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Tattoo project linked to order queue!',
                          'تم ربط مشروع الوشم بطلب العميل!',
                        )),
                        backgroundColor: const Color(0xFFA855F7),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoBadge({required String label, required String val, required Color color}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 9, color: color)),
            Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _showAddDesignDialog(BuildContext context) {
    final titleCtrl = TextEditingController(text: 'Custom Tattoo Stencil');
    final priceCtrl = TextEditingController(text: '1800');
    final hoursCtrl = TextEditingController(text: '3.0');
    final notesCtrl = TextEditingController();

    bool isPiercing = false;
    TattooArtStyle selectedStyle = TattooArtStyle.neoTraditional;
    BodyRegionView selectedRegion = BodyRegionView.chestTorso;
    Color selectedColor = const Color(0xFF0F172A);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                side: const BorderSide(color: AppColors.borderDark),
              ),
              title: Row(
                children: [
                  const Icon(Icons.palette, color: Color(0xFFA855F7), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Add New Tattoo / Piercing to 3D Canvas', 'إضافة وشم / بيرسينج جديد للنموذج 3D'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('Design Title / Name', 'اسم / عنوان الرسم'),
                          prefixIcon: const Icon(Icons.title, size: 16),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Category: Tattoo vs Piercing
                      Row(
                        children: [
                          ChoiceChip(
                            label: Text(AppLanguage.tr('Tattoo Stencil', 'باترون وشم')),
                            selected: !isPiercing,
                            selectedColor: const Color(0xFFA855F7),
                            onSelected: (val) {
                              setDialogState(() {
                                isPiercing = false;
                                selectedStyle = TattooArtStyle.neoTraditional;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text(AppLanguage.tr('Body Piercing', 'بيرسينج الجسم')),
                            selected: isPiercing,
                            selectedColor: const Color(0xFFEAB308),
                            onSelected: (val) {
                              setDialogState(() {
                                isPiercing = true;
                                selectedStyle = TattooArtStyle.piercingTitanium;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Style selection
                      Text(
                        AppLanguage.tr('Art Style', 'النمط الفني'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: TattooArtStyle.values.map((st) {
                          final isSel = st == selectedStyle;
                          return ChoiceChip(
                            label: Text(st.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFFA855F7),
                            onSelected: (_) => setDialogState(() => selectedStyle = st),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Target Region
                      Text(
                        AppLanguage.tr('Target Body Region', 'منطقة الجسم المستهدفة'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: BodyRegionView.values.map((reg) {
                          final isSel = reg == selectedRegion;
                          return ChoiceChip(
                            label: Text(reg.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFFA855F7),
                            onSelected: (_) => setDialogState(() => selectedRegion = reg),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Price & Hours
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Price (EGP)', 'السعر (ج.م)'),
                                prefixIcon: const Icon(Icons.attach_money, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: hoursCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Hours (Est)', 'المدة المقدرة (ساعة)'),
                                prefixIcon: const Icon(Icons.access_time, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Ink / Metal Color
                      Text(
                        AppLanguage.tr('Ink / Jewelry Color', 'لون الحبر / المعدن'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Color(0xFF0F172A),
                          const Color(0xFF991B1B),
                          const Color(0xFF1E3A8A),
                          const Color(0xFF065F46),
                          const Color(0xFFEAB308),
                        ].map((c) {
                          final isSel = c.value == selectedColor.value;
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = c),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? Colors.white : Colors.white24,
                                  width: isSel ? 2.5 : 1,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Notes
                      TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('Technique & Stencil Notes', 'ملاحظات التقنية والاستنسل'),
                          hintText: AppLanguage.tr('Needle size, skin tone prep, aftercare instructions...', 'حجم الإبر، تحضير البشرة...'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7)),
                  onPressed: () {
                    final newTitle = titleCtrl.text.trim().isEmpty ? 'Custom Stencil' : titleCtrl.text.trim();
                    final p = double.tryParse(priceCtrl.text) ?? 1200.0;
                    final h = double.tryParse(hoursCtrl.text) ?? 2.0;

                    final newRecord = TattooDesignRecord(
                      id: 'TAT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      title: newTitle,
                      isPiercing: isPiercing,
                      style: selectedStyle,
                      targetRegion: selectedRegion,
                      inkColor: selectedColor,
                      priceEgp: p,
                      estimatedHours: h,
                      notes: notesCtrl.text.trim(),
                      position: const Offset(0.5, 0.4),
                    );

                    final updatedList = List<TattooDesignRecord>.from(designsNotifier.value)..add(newRecord);
                    designsNotifier.value = updatedList;
                    selectedDesignNotifier.value = newRecord;

                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'New 3D design added to showroom!',
                          'تمت إضافة الرسم ثلاثي الأبعاد إلى المعرض!',
                        )),
                        backgroundColor: const Color(0xFFA855F7),
                      ),
                    );
                  },
                  child: Text(AppLanguage.tr('Add Design', 'إضافة الرسم')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDesignDialog(BuildContext context, TattooDesignRecord design) {
    final titleCtrl = TextEditingController(text: design.title);
    final priceCtrl = TextEditingController(text: design.priceEgp.toStringAsFixed(0));
    final hoursCtrl = TextEditingController(text: design.estimatedHours.toStringAsFixed(1));
    final notesCtrl = TextEditingController(text: design.notes);

    bool isPiercing = design.isPiercing;
    TattooArtStyle selectedStyle = design.style;
    BodyRegionView selectedRegion = design.targetRegion;
    Color selectedColor = design.inkColor;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              actionsAlignment: MainAxisAlignment.spaceBetween,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                side: const BorderSide(color: AppColors.borderDark),
              ),
              title: Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFFA855F7), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Edit 3D Design Specs', 'تعديل بيانات الرسم 3D'),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              content: SizedBox(
                width: 460,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: titleCtrl,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('Design Title', 'عنوان الرسم'),
                          prefixIcon: const Icon(Icons.title, size: 16),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Art Style selection
                      Text(
                        AppLanguage.tr('Art Style', 'النمط الفني'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: TattooArtStyle.values.map((st) {
                          final isSel = st == selectedStyle;
                          return ChoiceChip(
                            label: Text(st.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFFA855F7),
                            onSelected: (_) => setDialogState(() => selectedStyle = st),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Target Region
                      Text(
                        AppLanguage.tr('Target Body Region', 'منطقة الجسم المستهدفة'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: BodyRegionView.values.map((reg) {
                          final isSel = reg == selectedRegion;
                          return ChoiceChip(
                            label: Text(reg.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFFA855F7),
                            onSelected: (_) => setDialogState(() => selectedRegion = reg),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Price & Hours
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Price (EGP)', 'السعر (ج.م)'),
                                prefixIcon: const Icon(Icons.attach_money, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: hoursCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Hours (Est)', 'المدة المقدرة (ساعة)'),
                                prefixIcon: const Icon(Icons.access_time, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Color selection
                      Text(
                        AppLanguage.tr('Ink / Jewelry Color', 'لون الحبر / المعدن'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Color(0xFF0F172A),
                          const Color(0xFF991B1B),
                          const Color(0xFF1E3A8A),
                          const Color(0xFF065F46),
                          const Color(0xFFEAB308),
                        ].map((c) {
                          final isSel = c.toARGB32() == selectedColor.toARGB32();
                          return GestureDetector(
                            onTap: () => setDialogState(() => selectedColor = c),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              width: 26,
                              height: 26,
                              decoration: BoxDecoration(
                                color: c,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSel ? Colors.white : Colors.white24,
                                  width: isSel ? 2.5 : 1,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: notesCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('Notes', 'الملاحظات'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(AppLanguage.tr('Delete Design', 'حذف الرسم')),
                  onPressed: () {
                    final current = List<TattooDesignRecord>.from(designsNotifier.value);
                    if (current.length > 1) {
                      current.removeWhere((d) => d.id == design.id);
                      designsNotifier.value = current;
                      selectedDesignNotifier.value = current.first;
                      Navigator.of(dialogCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr('Design deleted from catalog!', 'تم حذف الرسم من الكتالوج!')),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                    }
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFA855F7)),
                  onPressed: () {
                    final updatedRecord = design.copyWith(
                      title: titleCtrl.text.trim().isEmpty ? design.title : titleCtrl.text.trim(),
                      style: selectedStyle,
                      targetRegion: selectedRegion,
                      inkColor: selectedColor,
                      priceEgp: double.tryParse(priceCtrl.text) ?? design.priceEgp,
                      estimatedHours: double.tryParse(hoursCtrl.text) ?? design.estimatedHours,
                      notes: notesCtrl.text.trim(),
                    );

                    final current = List<TattooDesignRecord>.from(designsNotifier.value);
                    final idx = current.indexWhere((d) => d.id == design.id);
                    if (idx != -1) {
                      current[idx] = updatedRecord;
                      designsNotifier.value = current;
                      selectedDesignNotifier.value = updatedRecord;
                    }

                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr('3D design updated!', 'تم تحديث بيانات الرسم 3D!')),
                          backgroundColor: const Color(0xFFA855F7),
                        ),
                      );
                  },
                  child: Text(AppLanguage.tr('Save', 'حفظ')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Custom 3D Anatomical Human Body & Stencil Painter
class _TattooBody3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final BodyRegionView region;
  final List<TattooDesignRecord> designs;
  final TattooDesignRecord? selectedDesign;

  _TattooBody3DPainter({
    required this.yaw,
    required this.pitch,
    required this.region,
    required this.designs,
    required this.selectedDesign,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background Isometric Ambient Grid
    _draw3DGrid(canvas, size, cx, cy);

    // 3D Perspective Rotation Calculations
    final radYaw = yaw * (math.pi / 180.0);
    final radPitch = pitch * (math.pi / 180.0);
    final cosYaw = math.cos(radYaw);
    final sinYaw = math.sin(radYaw);

    // Draw 3D Human Figure Body Silhouette
    _draw3DHumanBody(canvas, size, cx, cy, cosYaw, sinYaw, radPitch);

    // Render 3D Tattoo & Piercing Anchors / Stencils
    for (final design in designs) {
      _drawStencilOnBody(canvas, size, cx, cy, cosYaw, sinYaw, design, design.id == selectedDesign?.id);
    }
  }

  void _draw3DGrid(Canvas canvas, Size size, double cx, double cy) {
    final gridPaint = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    const spacing = 35.0;
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
  }

  void _draw3DHumanBody(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double cosYaw,
    double sinYaw,
    double radPitch,
  ) {
    // Body scale relative to canvas
    final bodyHeight = size.height * 0.75;
    final bodyWidth = bodyHeight * 0.38;

    final baseTop = cy - bodyHeight / 2 + radPitch * 50;

    // Lighting gradient based on yaw
    final lightShift = sinYaw * 0.4;
    final bodyPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(lightShift, -0.2),
        radius: 0.9,
        colors: [
          const Color(0xFF334155),
          const Color(0xFF1E293B),
          const Color(0xFF0F172A),
        ],
      ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: bodyWidth * 1.5, height: bodyHeight));

    final outlinePaint = Paint()
      ..color = const Color(0xFFA855F7).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    // Head
    final headCenter = Offset(cx + sinYaw * 10, baseTop + bodyHeight * 0.08);
    final headRadius = bodyHeight * 0.055;
    canvas.drawCircle(headCenter, headRadius, bodyPaint);
    canvas.drawCircle(headCenter, headRadius, outlinePaint);

    // Neck
    final neckRect = Rect.fromCenter(
      center: Offset(cx + sinYaw * 8, baseTop + bodyHeight * 0.15),
      width: headRadius * 0.9,
      height: bodyHeight * 0.05,
    );
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, const Radius.circular(6)), bodyPaint);
    canvas.drawRRect(RRect.fromRectAndRadius(neckRect, const Radius.circular(6)), outlinePaint);

    // Torso / Chest & Abdomen (Perspective deformation)
    final torsoPath = Path();
    final shoulderY = baseTop + bodyHeight * 0.18;
    final chestY = baseTop + bodyHeight * 0.32;
    final waistY = baseTop + bodyHeight * 0.45;
    final hipY = baseTop + bodyHeight * 0.55;

    final leftShoulder = Offset(cx - (bodyWidth * 0.5) * cosYaw, shoulderY);
    final rightShoulder = Offset(cx + (bodyWidth * 0.5) * cosYaw, shoulderY);
    final leftWaist = Offset(cx - (bodyWidth * 0.32) * cosYaw, waistY);
    final rightWaist = Offset(cx + (bodyWidth * 0.32) * cosYaw, waistY);
    final leftHip = Offset(cx - (bodyWidth * 0.40) * cosYaw, hipY);
    final rightHip = Offset(cx + (bodyWidth * 0.40) * cosYaw, hipY);

    torsoPath.moveTo(leftShoulder.dx, leftShoulder.dy);
    torsoPath.lineTo(rightShoulder.dx, rightShoulder.dy);
    torsoPath.quadraticBezierTo(cx + (bodyWidth * 0.45) * cosYaw, chestY, rightWaist.dx, rightWaist.dy);
    torsoPath.lineTo(rightHip.dx, rightHip.dy);
    torsoPath.lineTo(leftHip.dx, leftHip.dy);
    torsoPath.lineTo(leftWaist.dx, leftWaist.dy);
    torsoPath.quadraticBezierTo(cx - (bodyWidth * 0.45) * cosYaw, chestY, leftShoulder.dx, leftShoulder.dy);
    torsoPath.close();

    canvas.drawPath(torsoPath, bodyPaint);
    canvas.drawPath(torsoPath, outlinePaint);

    // Arms
    _drawLimb(canvas, leftShoulder, Offset(leftShoulder.dx - 20 * cosYaw, hipY), bodyWidth * 0.14, bodyPaint, outlinePaint);
    _drawLimb(canvas, rightShoulder, Offset(rightShoulder.dx + 20 * cosYaw, hipY), bodyWidth * 0.14, bodyPaint, outlinePaint);

    // Legs
    _drawLimb(canvas, leftHip, Offset(cx - (bodyWidth * 0.22) * cosYaw, baseTop + bodyHeight * 0.95), bodyWidth * 0.18, bodyPaint, outlinePaint);
    _drawLimb(canvas, rightHip, Offset(cx + (bodyWidth * 0.22) * cosYaw, baseTop + bodyHeight * 0.95), bodyWidth * 0.18, bodyPaint, outlinePaint);
  }

  void _drawLimb(Canvas canvas, Offset start, Offset end, double thickness, Paint fill, Paint stroke) {
    final rect = Rect.fromPoints(start, end).inflate(thickness / 2);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(thickness / 2));
    canvas.drawRRect(rrect, fill);
    canvas.drawRRect(rrect, stroke);
  }

  void _drawStencilOnBody(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double cosYaw,
    double sinYaw,
    TattooDesignRecord design,
    bool isSelected,
  ) {
    // Project normalized offset (0.0 - 1.0) into canvas coordinates
    final px = cx + (design.position.dx - 0.5) * (size.width * 0.55) * cosYaw;
    final py = size.height * 0.12 + design.position.dy * (size.height * 0.75);

    final anchor = Offset(px, py);

    // Draw Stencil Anchor Halo
    final haloPaint = Paint()
      ..color = (isSelected ? const Color(0xFFA855F7) : design.inkColor).withValues(alpha: isSelected ? 0.4 : 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(anchor, 18 * design.scale, haloPaint);

    // Core Anchor Pin
    final pinPaint = Paint()
      ..color = isSelected ? const Color(0xFFEAB308) : design.inkColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(anchor, 7 * design.scale, pinPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(anchor, 7 * design.scale, borderPaint);

    // Floating Stencil Label Tag
    final textPainter = TextPainter(
      text: TextSpan(
        text: design.title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 9.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          backgroundColor: Colors.black54,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(anchor.dx - textPainter.width / 2, anchor.dy - 22));
  }

  @override
  bool shouldRepaint(covariant _TattooBody3DPainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.region != region ||
        oldDelegate.designs != designs ||
        oldDelegate.selectedDesign != selectedDesign;
  }
}
