import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_language.dart';

enum GarmentCategory {
  suitBlazer('Suits & Blazers', 'بدل وبليزر'),
  eveningDress('Evening Dresses & Gowns', 'فساتين سهرة'),
  outerwearCoat('Outerwear & Coats', 'معاطف وجواكت'),
  topsShirts('Shirts & Blouses', 'قمصان وبلوزات'),
  trousers('Trousers & Slacks', 'بناطيل وسراويل'),
  footwear('Luxury Footwear', 'أحذية راقية');

  final String labelEn;
  final String labelAr;
  const GarmentCategory(this.labelEn, this.labelAr);

  String get localized => AppLanguage.tr(labelEn, labelAr);
}

enum FabricType {
  wool('Italian Wool', 'صوف إيطالي'),
  silkSatin('Silk Satin', 'ساتان حريري'),
  velvet('Royal Velvet', 'مخمل ملكي'),
  denim('Raw Selvedge Denim', 'جينز خام فاخر'),
  leather('Genuine Leather', 'جلد طبيعي'),
  linen('Pure Linen', 'كتان نقي');

  final String labelEn;
  final String labelAr;
  const FabricType(this.labelEn, this.labelAr);

  String get localized => AppLanguage.tr(labelEn, labelAr);
}

class GarmentApparelRecord {
  final String id;
  final String name;
  final GarmentCategory category;
  final FabricType fabric;
  final Color primaryColor;
  final List<String> sizes;
  final double priceEgp;
  final double rentalPriceEgp;
  final String description;
  final List<String> alterationTags;

  const GarmentApparelRecord({
    required this.id,
    required this.name,
    this.category = GarmentCategory.suitBlazer,
    this.fabric = FabricType.wool,
    this.primaryColor = const Color(0xFF1E293B),
    this.sizes = const ['48R', '50R', '52R', '54R'],
    this.priceEgp = 6800.0,
    this.rentalPriceEgp = 1200.0,
    this.description = '',
    this.alterationTags = const [],
  });

  GarmentApparelRecord copyWith({
    String? id,
    String? name,
    GarmentCategory? category,
    FabricType? fabric,
    Color? primaryColor,
    List<String>? sizes,
    double? priceEgp,
    double? rentalPriceEgp,
    String? description,
    List<String>? alterationTags,
  }) {
    return GarmentApparelRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      fabric: fabric ?? this.fabric,
      primaryColor: primaryColor ?? this.primaryColor,
      sizes: sizes ?? this.sizes,
      priceEgp: priceEgp ?? this.priceEgp,
      rentalPriceEgp: rentalPriceEgp ?? this.rentalPriceEgp,
      description: description ?? this.description,
      alterationTags: alterationTags ?? this.alterationTags,
    );
  }
}

class AlterationPin {
  final String id;
  final String label;
  final Offset position; // Normalized coordinates 0.0 - 1.0 on mannequin
  final String adjustment; // e.g. "-2.5 cm"
  final String note;

  const AlterationPin({
    required this.id,
    required this.label,
    required this.position,
    this.adjustment = '',
    this.note = '',
  });
}

/// 3D Interactive, Editable Retail Fashion & Apparel Mannequin Showcase Widget
class RetailFashion3DShowcaseWidget extends StatelessWidget {
  final ValueNotifier<List<GarmentApparelRecord>> collectionNotifier;
  final ValueNotifier<GarmentApparelRecord?> selectedGarmentNotifier;
  final ValueNotifier<List<AlterationPin>> pinsNotifier;
  final ValueNotifier<double> yawNotifier;
  final ValueNotifier<double> pitchNotifier;
  final ValueNotifier<bool> isPinningModeNotifier;
  final Function(GarmentApparelRecord garment, List<AlterationPin> pins)? onOrderCommitted;

  RetailFashion3DShowcaseWidget({
    super.key,
    ValueNotifier<List<GarmentApparelRecord>>? collectionNotifier,
    ValueNotifier<GarmentApparelRecord?>? selectedGarmentNotifier,
    ValueNotifier<List<AlterationPin>>? pinsNotifier,
    ValueNotifier<double>? yawNotifier,
    ValueNotifier<double>? pitchNotifier,
    ValueNotifier<bool>? isPinningModeNotifier,
    this.onOrderCommitted,
  })  : collectionNotifier = collectionNotifier ??
            ValueNotifier<List<GarmentApparelRecord>>(defaultCollection),
        selectedGarmentNotifier =
            selectedGarmentNotifier ?? ValueNotifier<GarmentApparelRecord?>(defaultCollection.first),
        pinsNotifier = pinsNotifier ??
            ValueNotifier<List<AlterationPin>>([
              const AlterationPin(
                id: 'ALT-1',
                label: 'Waist Taper',
                position: Offset(0.50, 0.44),
                adjustment: '-3.0 cm',
                note: 'Taper sides for slim fit taper silhouette.',
              ),
              const AlterationPin(
                id: 'ALT-2',
                label: 'Sleeve Length',
                position: Offset(0.28, 0.48),
                adjustment: '-1.5 cm',
                note: 'Show 1/2 inch shirt cuff.',
              ),
            ]),
        yawNotifier = yawNotifier ?? ValueNotifier<double>(0.0),
        pitchNotifier = pitchNotifier ?? ValueNotifier<double>(0.0),
        isPinningModeNotifier = isPinningModeNotifier ?? ValueNotifier<bool>(false);

  static const List<GarmentApparelRecord> defaultCollection = [
    GarmentApparelRecord(
      id: 'GAR-001',
      name: 'Midnight Tuxedo with Satin Shawl Lapel',
      category: GarmentCategory.suitBlazer,
      fabric: FabricType.wool,
      primaryColor: Color(0xFF0F172A), // Midnight Obsidian
      sizes: ['48R', '50R', '52R', '54R', '56R'],
      priceEgp: 9500.0,
      rentalPriceEgp: 1800.0,
      description: 'Super 160s merino wool with 100% mulberry silk satin peak lapels.',
    ),
    GarmentApparelRecord(
      id: 'GAR-002',
      name: 'Emerald Velvet Gala Evening Gown',
      category: GarmentCategory.eveningDress,
      fabric: FabricType.velvet,
      primaryColor: Color(0xFF064E3B), // Royal Emerald
      sizes: ['36', '38', '40', '42'],
      priceEgp: 12400.0,
      rentalPriceEgp: 2400.0,
      description: 'Plush silk velvet column silhouette with pleated back train.',
    ),
    GarmentApparelRecord(
      id: 'GAR-003',
      name: 'Handcrafted Indigo Selvedge Trucker',
      category: GarmentCategory.outerwearCoat,
      fabric: FabricType.denim,
      primaryColor: Color(0xFF1E3A8A), // Indigo
      sizes: ['S', 'M', 'L', 'XL'],
      priceEgp: 4200.0,
      rentalPriceEgp: 850.0,
      description: '14oz Kurabo Japanese selvedge denim with antique brass hardware.',
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

          // ── MAIN 3D WORKSPACE ──────────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                // 3D Mannequin Viewport
                Expanded(
                  flex: 3,
                  child: _build3DMannequinViewport(context),
                ),
                const VerticalDivider(width: 1, color: AppColors.borderDark),

                // Right Garment & Alterations Inspector Panel
                SizedBox(
                  width: 340,
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
            const Icon(Icons.checkroom, color: Color(0xFFEC4899), size: 20),
            const SizedBox(width: 8),
            Text(
              AppLanguage.tr('3D Apparel & Mannequin Fitting Studio', 'استوديو عرض الأزياء والقياس 3D'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 14),

            // "+ Add New Garment" Button for Boutique Owner
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.add_circle, size: 14),
              label: Text(
                AppLanguage.tr('+ Add Garment to 3D', '+ إضافة قطعة أزياء 3D'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showAddGarmentDialog(context),
            ),
            const SizedBox(width: 12),

            // Alteration Pinning Toggle
            ValueListenableBuilder<bool>(
              valueListenable: isPinningModeNotifier,
              builder: (context, isPinning, _) {
                return FilterChip(
                  avatar: Icon(
                    isPinning ? Icons.pin_drop : Icons.straighten,
                    size: 14,
                    color: isPinning ? Colors.black : Colors.white70,
                  ),
                  label: Text(
                    isPinning
                        ? AppLanguage.tr('Click Mannequin to Add Pin', 'انقر على المانيكان لإضافة قياس')
                        : AppLanguage.tr('+ Alteration Pin', '+ قياس/تعديل'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isPinning ? Colors.black : Colors.white70,
                    ),
                  ),
                  selected: isPinning,
                  selectedColor: const Color(0xFFF59E0B),
                  backgroundColor: AppColors.surfaceElevatedDark,
                  onSelected: (val) => isPinningModeNotifier.value = val,
                );
              },
            ),
            const SizedBox(width: 12),

            // Quick Angles
            _buildAngleChip('Front View', 'الأمام', 0.0),
            _buildAngleChip('Back View', 'الخلف', 180.0),
            _buildAngleChip('Profile 90°', 'الجانب', 90.0),

            const SizedBox(width: 8),
            IconButton(
              tooltip: AppLanguage.tr('Reset View', 'إعادة ضبط العرض'),
              icon: const Icon(Icons.restart_alt, size: 18, color: AppColors.textSecondaryDark),
              onPressed: () {
                yawNotifier.value = 0.0;
                pitchNotifier.value = 0.0;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAngleChip(String labelEn, String labelAr, double targetYaw) {
    return ValueListenableBuilder<double>(
      valueListenable: yawNotifier,
      builder: (context, yaw, _) {
        final isSel = (yaw - targetYaw).abs() < 5.0;
        return Padding(
          padding: const EdgeInsets.only(right: 6),
          child: ChoiceChip(
            label: Text(AppLanguage.tr(labelEn, labelAr), style: const TextStyle(fontSize: 10.5)),
            selected: isSel,
            selectedColor: const Color(0xFFEC4899),
            backgroundColor: AppColors.surfaceElevatedDark,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
            onSelected: (_) => yawNotifier.value = targetYaw,
          ),
        );
      },
    );
  }

  Widget _build3DMannequinViewport(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        yawNotifier,
        pitchNotifier,
        selectedGarmentNotifier,
        pinsNotifier,
        isPinningModeNotifier,
      ]),
      builder: (context, _) {
        final yaw = yawNotifier.value;
        final pitch = pitchNotifier.value;
        final garment = selectedGarmentNotifier.value;
        final pins = pinsNotifier.value;
        final isPinning = isPinningModeNotifier.value;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  yawNotifier.value = (yawNotifier.value + details.delta.dx * 0.8) % 360;
                  pitchNotifier.value = (pitchNotifier.value - details.delta.dy * 0.5).clamp(-25.0, 25.0);
                },
                onTapUp: (details) {
                  if (isPinning) {
                    final box = context.findRenderObject() as RenderBox?;
                    if (box != null) {
                      final localPos = details.localPosition;
                      final normX = (localPos.dx / box.size.width).clamp(0.1, 0.9);
                      final normY = (localPos.dy / box.size.height).clamp(0.1, 0.9);

                      _promptNewPinDialog(context, Offset(normX, normY));
                      isPinningModeNotifier.value = false;
                    }
                  }
                },
                child: CustomPaint(
                  painter: _MannequinFashion3DPainter(
                    yaw: yaw,
                    pitch: pitch,
                    garment: garment,
                    pins: pins,
                  ),
                ),
              ),
            ),

            // Top HUD
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
                    const Icon(Icons.view_in_ar, size: 14, color: Color(0xFFEC4899)),
                    const SizedBox(width: 6),
                    Text(
                      '3D Mannequin  •  Yaw: ${yaw.toStringAsFixed(0)}°  •  ${garment?.fabric.localized ?? ""}',
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
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
      animation: Listenable.merge([collectionNotifier, selectedGarmentNotifier, pinsNotifier]),
      builder: (context, _) {
        final collection = collectionNotifier.value;
        final selected = selectedGarmentNotifier.value ?? (collection.isNotEmpty ? collection.first : null);
        final pins = pinsNotifier.value;

        return Container(
          color: AppColors.surfaceDark,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLanguage.tr('Boutique Garments Collection', 'تشكيلة أزياء المتجر'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),

              // Garment Selector
              SizedBox(
                height: 110,
                child: ListView.separated(
                  itemCount: collection.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = collection[index];
                    final isSel = item.id == selected?.id;

                    return InkWell(
                      onTap: () => selectedGarmentNotifier.value = item,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFFEC4899).withValues(alpha: 0.15) : AppColors.surfaceElevatedDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? const Color(0xFFEC4899) : AppColors.borderDark,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: item.primaryColor,
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
                                    item.name,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      color: isSel ? Colors.white : AppColors.textPrimaryDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.category.localized} • ${item.priceEgp.toStringAsFixed(0)} EGP',
                                    style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 14, color: AppColors.textSecondaryDark),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 16, color: AppColors.borderDark),

              // Selected Garment & Alterations
              if (selected != null) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                selected.name,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFFEC4899)),
                              tooltip: AppLanguage.tr('Edit Garment', 'تعديل بيانات القطعة'),
                              onPressed: () => _showEditGarmentDialog(context, selected),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Price & Rental Metrics
                        Row(
                          children: [
                            _buildBadge(AppLanguage.tr('Purchase Price', 'سعر البيع'), '${selected.priceEgp.toStringAsFixed(0)} EGP', Colors.greenAccent),
                            const SizedBox(width: 6),
                            _buildBadge(AppLanguage.tr('Rental / Event', 'سعر الإيجار'), '${selected.rentalPriceEgp.toStringAsFixed(0)} EGP', Colors.amberAccent),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Text(
                          '${AppLanguage.tr("Fabric", "نوع القماش")}: ${selected.fabric.localized}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLanguage.tr("Sizes in Stock", "المقاسات المتوفرة")}: ${selected.sizes.join(", ")}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 10),

                        // Alterations Pins List
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${AppLanguage.tr("Tailoring Alterations", "تعديلات الخياطة والتفصيل")} (${pins.length})',
                              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        ...pins.map((pin) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevatedDark,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.straighten, size: 14, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${pin.label} (${pin.adjustment})',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      if (pin.note.isNotEmpty)
                                        Text(pin.note, style: const TextStyle(fontSize: 9.5, color: Colors.white60)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Commit Tailoring Order Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.assignment_turned_in, size: 14),
                  label: Text(
                    AppLanguage.tr('Commit Tailoring Order with 3D Fitting', 'اعتماد أمر التفصيل بالقياس 3D'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    onOrderCommitted?.call(selected, pins);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Tailoring work order dispatched with 3D measurements!',
                          'تم إنشاء تذكرة التفصيل والتعديلات بالقياسات ثلاثية الأبعاد!',
                        )),
                        backgroundColor: const Color(0xFFEC4899),
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

  Widget _buildBadge(String label, String val, Color color) {
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

  void _promptNewPinDialog(BuildContext context, Offset pos) {
    final labelCtrl = TextEditingController(text: 'Hem Adjustment');
    final adjCtrl = TextEditingController(text: '-2.0 cm');
    final noteCtrl = TextEditingController(text: 'Customer requested bespoke taper.');

    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        title: Text(AppLanguage.tr('Add Alteration Measurement Pin', 'إضافة نقطة تعديل قياس')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelCtrl, decoration: InputDecoration(labelText: AppLanguage.tr('Alteration Area', 'منطقة التعديل'))),
            TextField(controller: adjCtrl, decoration: InputDecoration(labelText: AppLanguage.tr('Adjustment (e.g. -2cm)', 'مقدار التعديل (مثل -2 سم)'))),
            TextField(controller: noteCtrl, decoration: InputDecoration(labelText: AppLanguage.tr('Tailor Instructions', 'تعليمات الخياط'))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: Text(AppLanguage.tr('Cancel', 'إلغاء'))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
            onPressed: () {
              final newPin = AlterationPin(
                id: 'ALT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                label: labelCtrl.text.trim().isEmpty ? 'Alteration' : labelCtrl.text.trim(),
                position: pos,
                adjustment: adjCtrl.text.trim(),
                note: noteCtrl.text.trim(),
              );
              pinsNotifier.value = List<AlterationPin>.from(pinsNotifier.value)..add(newPin);
              Navigator.of(dialogCtx).pop();
            },
            child: Text(AppLanguage.tr('Save Pin', 'حفظ النقطة')),
          ),
        ],
      ),
    );
  }

  void _showAddGarmentDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'Bespoke Cashmere Blazer');
    final priceCtrl = TextEditingController(text: '5500');
    final rentCtrl = TextEditingController(text: '1100');
    final descCtrl = TextEditingController();

    GarmentCategory selectedCat = GarmentCategory.suitBlazer;
    FabricType selectedFabric = FabricType.wool;
    Color selectedColor = const Color(0xFF1E293B);

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
                  const Icon(Icons.checkroom, color: Color(0xFFEC4899), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Add New Garment to 3D Showroom', 'إضافة قطعة ملابس جديدة للمعرض 3D'),
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
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('Garment Name / Model', 'اسم القطعة / الموديل'),
                          prefixIcon: const Icon(Icons.label, size: 16),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Category
                      Text(AppLanguage.tr('Category', 'التصنيف'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: GarmentCategory.values.map((cat) {
                          final isSel = cat == selectedCat;
                          return ChoiceChip(
                            label: Text(cat.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFFEC4899),
                            onSelected: (_) => setDialogState(() => selectedCat = cat),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Fabric
                      Text(AppLanguage.tr('Fabric / Material', 'الخامة / القماش'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: FabricType.values.map((fab) {
                          final isSel = fab == selectedFabric;
                          return ChoiceChip(
                            label: Text(fab.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFFEC4899),
                            onSelected: (_) => setDialogState(() => selectedFabric = fab),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Price & Rental
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Price (EGP)', 'سعر البيع (ج.م)'),
                                prefixIcon: const Icon(Icons.attach_money, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: rentCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Rental (EGP)', 'سعر الإيجار (ج.م)'),
                                prefixIcon: const Icon(Icons.calendar_today, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Colorway Palette
                      Text(AppLanguage.tr('Colorway', 'اللون'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Color(0xFF0F172A), // Midnight
                          const Color(0xFF064E3B), // Emerald
                          const Color(0xFF881337), // Crimson Burgundy
                          const Color(0xFF1E3A8A), // Royal Navy
                          const Color(0xFFD97706), // Camel Wool
                          const Color(0xFFF8FAFC), // Ivory
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
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('Description & Fit Details', 'الوصف وتفاصيل القياس'),
                          hintText: AppLanguage.tr('Drop 7 slim fit, horn buttons, full canvas...', 'قصة مخصصة، أزرار طبيعية...'),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
                  onPressed: () {
                    final newName = nameCtrl.text.trim().isEmpty ? 'Bespoke Garment' : nameCtrl.text.trim();
                    final p = double.tryParse(priceCtrl.text) ?? 5000.0;
                    final r = double.tryParse(rentCtrl.text) ?? 1000.0;

                    final newRecord = GarmentApparelRecord(
                      id: 'GAR-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      name: newName,
                      category: selectedCat,
                      fabric: selectedFabric,
                      primaryColor: selectedColor,
                      priceEgp: p,
                      rentalPriceEgp: r,
                      description: descCtrl.text.trim(),
                    );

                    final updatedList = List<GarmentApparelRecord>.from(collectionNotifier.value)..add(newRecord);
                    collectionNotifier.value = updatedList;
                    selectedGarmentNotifier.value = newRecord;

                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'New garment added to 3D showroom!',
                          'تمت إضافة قطعة الملابس إلى المعرض ثلاثي الأبعاد!',
                        )),
                        backgroundColor: const Color(0xFFEC4899),
                      ),
                    );
                  },
                  child: Text(AppLanguage.tr('Add Garment', 'إضافة القطعة')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditGarmentDialog(BuildContext context, GarmentApparelRecord garment) {
    final nameCtrl = TextEditingController(text: garment.name);
    final priceCtrl = TextEditingController(text: garment.priceEgp.toStringAsFixed(0));
    final rentalPriceCtrl = TextEditingController(text: garment.rentalPriceEgp.toStringAsFixed(0));
    final descCtrl = TextEditingController(text: garment.description);

    GarmentCategory selectedCategory = garment.category;
    FabricType selectedFabric = garment.fabric;
    Color selectedColor = garment.primaryColor;

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
                  const Icon(Icons.edit, color: Color(0xFFEC4899), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Edit 3D Garment Specs', 'تعديل بيانات قطعة الأزياء 3D'),
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
                        controller: nameCtrl,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('Garment Name / Title', 'اسم / عنوان القطعة'),
                          prefixIcon: const Icon(Icons.checkroom, size: 16),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Category
                      Text(
                        AppLanguage.tr('Category / Silhouette', 'التصنيف والشكل 3D'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: GarmentCategory.values.map((cat) {
                          final isSel = cat == selectedCategory;
                          return ChoiceChip(
                            label: Text(cat.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFFEC4899),
                            onSelected: (_) => setDialogState(() => selectedCategory = cat),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Fabric
                      Text(
                        AppLanguage.tr('Fabric Material Shader', 'نوع خامة القماش'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: FabricType.values.map((fab) {
                          final isSel = fab == selectedFabric;
                          return ChoiceChip(
                            label: Text(fab.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFFEC4899),
                            onSelected: (_) => setDialogState(() => selectedFabric = fab),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      // Price & Rental
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Sale Price (EGP)', 'سعر البيع (ج.م)'),
                                prefixIcon: const Icon(Icons.attach_money, size: 16),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: rentalPriceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Rental (EGP)', 'سعر الإيجار (ج.م)'),
                                prefixIcon: const Icon(Icons.event, size: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Color selection
                      Text(
                        AppLanguage.tr('Fabric Colorway', 'لون القماش والتصميم'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Color(0xFF0F172A),
                          const Color(0xFF831843),
                          const Color(0xFF1E3A8A),
                          const Color(0xFF14532D),
                          const Color(0xFFD97706),
                          const Color(0xFFE2E8F0),
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
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('Description & Notes', 'الوصف والملاحظات'),
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
                  label: Text(AppLanguage.tr('Delete Garment', 'حذف القطعة')),
                  onPressed: () {
                    final current = List<GarmentApparelRecord>.from(collectionNotifier.value);
                    if (current.length > 1) {
                      current.removeWhere((g) => g.id == garment.id);
                      collectionNotifier.value = current;
                      selectedGarmentNotifier.value = current.first;
                      Navigator.of(dialogCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr('Garment removed from 3D showroom!', 'تم حذف القطعة من المعرض!')),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEC4899)),
                  onPressed: () {
                    final updatedRecord = garment.copyWith(
                      name: nameCtrl.text.trim().isEmpty ? garment.name : nameCtrl.text.trim(),
                      category: selectedCategory,
                      fabric: selectedFabric,
                      primaryColor: selectedColor,
                      priceEgp: double.tryParse(priceCtrl.text) ?? garment.priceEgp,
                      rentalPriceEgp: double.tryParse(rentalPriceCtrl.text) ?? garment.rentalPriceEgp,
                      description: descCtrl.text.trim(),
                    );

                    final current = List<GarmentApparelRecord>.from(collectionNotifier.value);
                    final idx = current.indexWhere((g) => g.id == garment.id);
                    if (idx != -1) {
                      current[idx] = updatedRecord;
                      collectionNotifier.value = current;
                      selectedGarmentNotifier.value = updatedRecord;
                    }

                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr('3D garment updated!', 'تم تحديث بيانات قطعة الأزياء 3D!')),
                          backgroundColor: const Color(0xFFEC4899),
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

/// Custom 3D Mannequin & Fabric Silhouette Painter
class _MannequinFashion3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final GarmentApparelRecord? garment;
  final List<AlterationPin> pins;

  _MannequinFashion3DPainter({
    required this.yaw,
    required this.pitch,
    required this.garment,
    required this.pins,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    _drawIsometricGrid(canvas, size, cx, cy);

    final radYaw = yaw * (math.pi / 180.0);
    final radPitch = pitch * (math.pi / 180.0);
    final cosYaw = math.cos(radYaw);
    final sinYaw = math.sin(radYaw);

    // Mannequin Base & Stand
    _drawMannequinStand(canvas, size, cx, cy, radPitch);

    // Mannequin Form & Garment Draped in 3D
    _drawDrapedGarment(canvas, size, cx, cy, cosYaw, sinYaw, radPitch);

    // Alteration Callout Pins
    for (final pin in pins) {
      _drawPin(canvas, size, cx, cy, cosYaw, pin);
    }
  }

  void _drawIsometricGrid(Canvas canvas, Size size, double cx, double cy) {
    final paint = Paint()
      ..color = const Color(0xFFEC4899).withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    const spacing = 40.0;
    for (double y = 0; y <= size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    for (double x = 0; x <= size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  void _drawMannequinStand(Canvas canvas, Size size, double cx, double cy, double radPitch) {
    final standPaint = Paint()
      ..color = const Color(0xFF64748B)
      ..strokeWidth = 4.0;

    final baseY = size.height * 0.88 + radPitch * 40;

    // Metal pole
    canvas.drawLine(Offset(cx, cy + size.height * 0.2), Offset(cx, baseY), standPaint);

    // Heavy round metallic pedestal base
    final basePaint = Paint()
      ..color = const Color(0xFF475569)
      ..style = PaintingStyle.fill;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, baseY), width: 140, height: 35), basePaint);

    final borderPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, baseY), width: 140, height: 35), borderPaint);
  }

  void _drawDrapedGarment(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double cosYaw,
    double sinYaw,
    double radPitch,
  ) {
    final torsoHeight = size.height * 0.55;
    final torsoWidth = torsoHeight * 0.44;
    final topY = cy - torsoHeight / 2 + radPitch * 40;

    final garmentColor = garment?.primaryColor ?? const Color(0xFF1E293B);

    // Dynamic 3D lighting shader
    final lightOffset = sinYaw * 0.35;
    final garmentShader = RadialGradient(
      center: Alignment(lightOffset, -0.3),
      radius: 0.85,
      colors: [
        garmentColor.withValues(alpha: 0.95),
        garmentColor,
        Colors.black87,
      ],
    ).createShader(Rect.fromCenter(center: Offset(cx, cy), width: torsoWidth * 1.5, height: torsoHeight));

    final fillPaint = Paint()..shader = garmentShader;

    final strokePaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Neck Form (Mannequin neck cap)
    final neckRect = Rect.fromCenter(
      center: Offset(cx + sinYaw * 6, topY + torsoHeight * 0.05),
      width: torsoWidth * 0.28,
      height: torsoHeight * 0.08,
    );
    canvas.drawOval(neckRect, Paint()..color = const Color(0xFF94A3B8));

    // Tailored Silhouette (Jacket / Gown)
    final path = Path();
    final leftShoulder = Offset(cx - (torsoWidth * 0.55) * cosYaw, topY + torsoHeight * 0.12);
    final rightShoulder = Offset(cx + (torsoWidth * 0.55) * cosYaw, topY + torsoHeight * 0.12);
    final leftWaist = Offset(cx - (torsoWidth * 0.36) * cosYaw, topY + torsoHeight * 0.52);
    final rightWaist = Offset(cx + (torsoWidth * 0.36) * cosYaw, topY + torsoHeight * 0.52);
    final leftHem = Offset(cx - (torsoWidth * 0.50) * cosYaw, topY + torsoHeight * 0.92);
    final rightHem = Offset(cx + (torsoWidth * 0.50) * cosYaw, topY + torsoHeight * 0.92);

    path.moveTo(leftShoulder.dx, leftShoulder.dy);
    path.lineTo(rightShoulder.dx, rightShoulder.dy);
    path.quadraticBezierTo(cx + (torsoWidth * 0.48) * cosYaw, topY + torsoHeight * 0.32, rightWaist.dx, rightWaist.dy);
    path.lineTo(rightHem.dx, rightHem.dy);
    path.lineTo(leftHem.dx, leftHem.dy);
    path.lineTo(leftWaist.dx, leftWaist.dy);
    path.quadraticBezierTo(cx - (torsoWidth * 0.48) * cosYaw, topY + torsoHeight * 0.32, leftShoulder.dx, leftShoulder.dy);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);

    // Lapel / Collar Accent Line
    final lapelPath = Path();
    lapelPath.moveTo(cx - (torsoWidth * 0.15) * cosYaw, topY + torsoHeight * 0.12);
    lapelPath.lineTo(cx, topY + torsoHeight * 0.45);
    lapelPath.lineTo(cx + (torsoWidth * 0.15) * cosYaw, topY + torsoHeight * 0.12);
    canvas.drawPath(
      lapelPath,
      Paint()
        ..color = const Color(0xFFEC4899).withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  void _drawPin(Canvas canvas, Size size, double cx, double cy, double cosYaw, AlterationPin pin) {
    final px = cx + (pin.position.dx - 0.5) * (size.width * 0.5) * cosYaw;
    final py = size.height * 0.15 + pin.position.dy * (size.height * 0.65);

    final center = Offset(px, py);

    // Pin Halo
    final haloPaint = Paint()
      ..color = const Color(0xFFF59E0B).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 14, haloPaint);

    // Pin Core
    final pinPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 6, pinPaint);

    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, 6, borderPaint);

    // Tag
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${pin.label} ${pin.adjustment}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          backgroundColor: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - 20));
  }

  @override
  bool shouldRepaint(covariant _MannequinFashion3DPainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.garment != garment ||
        oldDelegate.pins != pins;
  }
}
