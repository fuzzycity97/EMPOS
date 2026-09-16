import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_language.dart';

enum ArchitecturalZoneType {
  residentialApartment('Residential Suite / Apartment', 'شقة / جناح سكني'),
  commercialOffice('Commercial Office / Clinic', 'مكتب تجاري / عيادة'),
  ballroomStage('Grand Ballroom & Stage', 'قاعة كبرى ومنصة'),
  exhibitionBooth('Exhibition & Expo Booth', 'جناح معرض وفعاليات'),
  hotelSuite('Hotel Boutique Suite', 'جناح فندقي فاخر'),
  terraceGarden('Open-Air Terrace & Garden', 'تراس وحديقة مفتوحة');

  final String labelEn;
  final String labelAr;
  const ArchitecturalZoneType(this.labelEn, this.labelAr);

  String get localized => AppLanguage.tr(labelEn, labelAr);
}

enum FlooringTexture {
  hardwoodOak('Hardwood Oak Planks', 'باركيه خشب أرو'),
  italianMarble('Italian Carrara Marble', 'رخام إيطالي كرارا'),
  plushCarpet('Plush Velvet Carpet', 'موكيت مخملي فاخر'),
  polishedConcrete('Polished Architectural Concrete', 'خرسانة مصقولة');

  final String labelEn;
  final String labelAr;
  const FlooringTexture(this.labelEn, this.labelAr);

  String get localized => AppLanguage.tr(labelEn, labelAr);
}

enum ArchitecturalStatus {
  available('Available / For Sale', 'متاح / للبيع أو الإيجار', Color(0xFF10B981)),
  underOffer('Under Negotiation / Offer', 'قيد التفاوض', Color(0xFFF59E0B)),
  reserved('Reserved / Booked', 'محجوز / مؤجر', Color(0xFF3B82F6)),
  maintenance('Maintenance / Fit-out', 'أعمال تشطيب وصيانة', Color(0xFFEF4444));

  final String labelEn;
  final String labelAr;
  final Color color;
  const ArchitecturalStatus(this.labelEn, this.labelAr, this.color);

  String get localized => AppLanguage.tr(labelEn, labelAr);
}

class ArchitecturalUnitRecord {
  final String id;
  final String name;
  final ArchitecturalZoneType zoneType;
  final double areaSqm;
  final int floorLevel;
  final double priceEgp;
  final ArchitecturalStatus status;
  final Offset position; // Normalized 0.0 - 1.0 on 3D floor
  final Size dimensions; // Width and Length in meters
  final FlooringTexture flooring;
  final String notes;

  const ArchitecturalUnitRecord({
    required this.id,
    required this.name,
    this.zoneType = ArchitecturalZoneType.residentialApartment,
    this.areaSqm = 145.0,
    this.floorLevel = 1,
    this.priceEgp = 3500000.0,
    this.status = ArchitecturalStatus.available,
    this.position = const Offset(0.35, 0.45),
    this.dimensions = const Size(12.0, 10.0),
    this.flooring = FlooringTexture.hardwoodOak,
    this.notes = '',
  });

  ArchitecturalUnitRecord copyWith({
    String? id,
    String? name,
    ArchitecturalZoneType? zoneType,
    double? areaSqm,
    int? floorLevel,
    double? priceEgp,
    ArchitecturalStatus? status,
    Offset? position,
    Size? dimensions,
    FlooringTexture? flooring,
    String? notes,
  }) {
    return ArchitecturalUnitRecord(
      id: id ?? this.id,
      name: name ?? this.name,
      zoneType: zoneType ?? this.zoneType,
      areaSqm: areaSqm ?? this.areaSqm,
      floorLevel: floorLevel ?? this.floorLevel,
      priceEgp: priceEgp ?? this.priceEgp,
      status: status ?? this.status,
      position: position ?? this.position,
      dimensions: dimensions ?? this.dimensions,
      flooring: flooring ?? this.flooring,
      notes: notes ?? this.notes,
    );
  }
}

/// 3D Interactive, Editable Architectural Property & Event Venue Layout Canvas
class RealEstateVenue3DCanvasWidget extends StatelessWidget {
  final ValueNotifier<List<ArchitecturalUnitRecord>> unitsNotifier;
  final ValueNotifier<ArchitecturalUnitRecord?> selectedUnitNotifier;
  final ValueNotifier<double> yawNotifier;
  final ValueNotifier<double> pitchNotifier;
  final Function(ArchitecturalUnitRecord unit)? onListingCommitted;

  RealEstateVenue3DCanvasWidget({
    super.key,
    ValueNotifier<List<ArchitecturalUnitRecord>>? unitsNotifier,
    ValueNotifier<ArchitecturalUnitRecord?>? selectedUnitNotifier,
    ValueNotifier<double>? yawNotifier,
    ValueNotifier<double>? pitchNotifier,
    this.onListingCommitted,
  })  : unitsNotifier = unitsNotifier ??
            ValueNotifier<List<ArchitecturalUnitRecord>>(defaultUnits),
        selectedUnitNotifier =
            selectedUnitNotifier ?? ValueNotifier<ArchitecturalUnitRecord?>(defaultUnits.first),
        yawNotifier = yawNotifier ?? ValueNotifier<double>(0.2),
        pitchNotifier = pitchNotifier ?? ValueNotifier<double>(0.35);

  static const List<ArchitecturalUnitRecord> defaultUnits = [
    ArchitecturalUnitRecord(
      id: 'UNIT-101',
      name: 'Penthouse Duplex Panoramic Suite',
      zoneType: ArchitecturalZoneType.residentialApartment,
      areaSqm: 285.0,
      floorLevel: 14,
      priceEgp: 7800000.0,
      status: ArchitecturalStatus.available,
      position: Offset(0.30, 0.35),
      dimensions: Size(16.0, 14.0),
      flooring: FlooringTexture.italianMarble,
      notes: 'Double height ceiling, private wrap-around terrace with sea horizon.',
    ),
    ArchitecturalUnitRecord(
      id: 'HALL-B2',
      name: 'Grand Royal Banquet Stage & VIP Lounge',
      zoneType: ArchitecturalZoneType.ballroomStage,
      areaSqm: 420.0,
      floorLevel: 1,
      priceEgp: 45000.0,
      status: ArchitecturalStatus.reserved,
      position: Offset(0.65, 0.40),
      dimensions: Size(22.0, 18.0),
      flooring: FlooringTexture.plushCarpet,
      notes: 'Integrated acoustic baffling, catwalk truss, and crystal chandeliers.',
    ),
    ArchitecturalUnitRecord(
      id: 'OFF-304',
      name: 'Executive Medical & Tech Office Suite',
      zoneType: ArchitecturalZoneType.commercialOffice,
      areaSqm: 115.0,
      floorLevel: 3,
      priceEgp: 2900000.0,
      status: ArchitecturalStatus.underOffer,
      position: Offset(0.45, 0.65),
      dimensions: Size(11.0, 9.0),
      flooring: FlooringTexture.hardwoodOak,
      notes: 'Fibre optic ready, separate reception zone and glass conference bay.',
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
          // ── TOP TOOLBAR ────────────────────────────────────────────────────
          _buildToolbar(context),
          const Divider(height: 1, color: AppColors.borderDark),

          // ── MAIN 3D ARCHITECTURAL WORKSPACE ────────────────────────────────
          Expanded(
            child: Row(
              children: [
                // Left 3D Isometric Viewport
                Expanded(
                  flex: 3,
                  child: _build3DArchitecturalViewport(context),
                ),
                const VerticalDivider(width: 1, color: AppColors.borderDark),

                // Right Architectural Unit Inspector Panel
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
            const Icon(Icons.apartment, color: Color(0xFF10B981), size: 20),
            const SizedBox(width: 8),
            Text(
              AppLanguage.tr('3D Architectural & Venue Floor Showcase', 'استوديو العقارات والمخططات المعمارية 3D'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 14),

            // "+ Add Unit / Zone" Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.add_home_work, size: 14),
              label: Text(
                AppLanguage.tr('+ Add 3D Unit / Zone', '+ إضافة وحدة / قاعة 3D'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showAddUnitDialog(context),
            ),
            const SizedBox(width: 12),

            // Preset Camera Angles
            _buildPresetChip('Isometric', 'آيزومتريك', 0.25, 0.35),
            _buildPresetChip('Top-Down Plan', 'مخطط رأسي', 0.0, 0.0),
            _buildPresetChip('Side Elevation', 'واجهة جانبية', 0.8, 0.1),

            const SizedBox(width: 8),
            IconButton(
              tooltip: AppLanguage.tr('Reset 3D View', 'إعادة ضبط 3D'),
              icon: const Icon(Icons.restart_alt, size: 18, color: AppColors.textSecondaryDark),
              onPressed: () {
                yawNotifier.value = 0.2;
                pitchNotifier.value = 0.35;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPresetChip(String labelEn, String labelAr, double y, double p) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ActionChip(
        label: Text(AppLanguage.tr(labelEn, labelAr), style: const TextStyle(fontSize: 10.5)),
        backgroundColor: AppColors.surfaceElevatedDark,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        onPressed: () {
          yawNotifier.value = y;
          pitchNotifier.value = p;
        },
      ),
    );
  }

  Widget _build3DArchitecturalViewport(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([yawNotifier, pitchNotifier, unitsNotifier, selectedUnitNotifier]),
      builder: (context, _) {
        final yaw = yawNotifier.value;
        final pitch = pitchNotifier.value;
        final units = unitsNotifier.value;
        final selected = selectedUnitNotifier.value;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  yawNotifier.value = (yawNotifier.value + details.delta.dx * 0.004).clamp(-1.0, 1.0);
                  pitchNotifier.value = (pitchNotifier.value - details.delta.dy * 0.004).clamp(-0.2, 0.8);
                },
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: _ArchitecturalFloor3DPainter(
                      yaw: yaw,
                      pitch: pitch,
                      units: units,
                      selectedUnit: selected,
                    ),
                  ),
                ),
              ),
            ),

            // Top Left HUD
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
                    const Icon(Icons.layers, size: 14, color: Color(0xFF10B981)),
                    const SizedBox(width: 6),
                    Text(
                      '3D Floor Plate  •  ${units.length} Units  •  Drag to Orbit',
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
      animation: Listenable.merge([unitsNotifier, selectedUnitNotifier]),
      builder: (context, _) {
        final units = unitsNotifier.value;
        final selected = selectedUnitNotifier.value ?? (units.isNotEmpty ? units.first : null);

        return Container(
          color: AppColors.surfaceDark,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLanguage.tr('Architectural Units Directory', 'سجل الوحدات والقاعات المعمارية'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),

              // Unit List Selector
              SizedBox(
                height: 120,
                child: ListView.separated(
                  itemCount: units.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = units[index];
                    final isSel = item.id == selected?.id;

                    return InkWell(
                      onTap: () => selectedUnitNotifier.value = item,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF10B981).withValues(alpha: 0.15) : AppColors.surfaceElevatedDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? const Color(0xFF10B981) : AppColors.borderDark,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item.status.color,
                                shape: BoxShape.circle,
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
                                    '${item.areaSqm.toStringAsFixed(0)} m² • ${item.zoneType.localized}',
                                    style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit, size: 14, color: Colors.white54),
                              onPressed: () => _showEditUnitDialog(context, item),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 16, color: AppColors.borderDark),

              // Selected Unit Inspector Details
              if (selected != null) ...[
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          selected.name,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        const SizedBox(height: 6),

                        // Metrics
                        Row(
                          children: [
                            _buildInfoBadge(AppLanguage.tr('Valuation / Price', 'القيمة / السعر'), '${selected.priceEgp.toStringAsFixed(0)} EGP', Colors.greenAccent),
                            const SizedBox(width: 6),
                            _buildInfoBadge(AppLanguage.tr('Surface Area', 'المساحة الإجمالية'), '${selected.areaSqm.toStringAsFixed(0)} m²', Colors.cyanAccent),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Text(
                          '${AppLanguage.tr("Space Zoning", "نوع المساحة")}: ${selected.zoneType.localized}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLanguage.tr("Flooring Finish", "نوع الأرضية")}: ${selected.flooring.localized}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLanguage.tr("Level / Floor", "الدور / المستوى")}: ${selected.floorLevel}',
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

                // Actions
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.assignment_turned_in, size: 14),
                  label: Text(
                    AppLanguage.tr('Create Listing / Booking Order', 'إنشاء عرض عقاري / تذكرة حجز'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    onListingCommitted?.call(selected);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Architectural listing linked to work order pipeline!',
                          'تم ربط الوحدة المعمارية بمسار العمليات والطلبات!',
                        )),
                        backgroundColor: const Color(0xFF10B981),
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

  Widget _buildInfoBadge(String label, String val, Color color) {
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

  void _showAddUnitDialog(BuildContext context) {
    final nameCtrl = TextEditingController(text: 'Deluxe Suite');
    final areaCtrl = TextEditingController(text: '160');
    final priceCtrl = TextEditingController(text: '4200000');
    final floorCtrl = TextEditingController(text: '2');
    final notesCtrl = TextEditingController();

    ArchitecturalZoneType selectedZone = ArchitecturalZoneType.residentialApartment;
    FlooringTexture selectedFlooring = FlooringTexture.hardwoodOak;
    ArchitecturalStatus selectedStatus = ArchitecturalStatus.available;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: Text(AppLanguage.tr('Add New 3D Unit to Floor', 'إضافة وحدة معمارية جديدة 3D')),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppLanguage.tr('Unit / Venue Name', 'اسم الوحدة / القاعة'))),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppLanguage.tr('Area (m²)', 'المساحة م²')))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: floorCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppLanguage.tr('Floor Level', 'الدور / الطابق')))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppLanguage.tr('Price / Valuation (EGP)', 'السعر / التقييم (ج.م)'))),
                    const SizedBox(height: 10),

                    Text(AppLanguage.tr('Zoning Type:', 'نوع النشاط المعماري:'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: ArchitecturalZoneType.values.map((z) {
                        final isSel = z == selectedZone;
                        return ChoiceChip(
                          label: Text(z.localized, style: const TextStyle(fontSize: 10)),
                          selected: isSel,
                          selectedColor: const Color(0xFF10B981),
                          onSelected: (_) => setDialogState(() => selectedZone = z),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    Text(AppLanguage.tr('Flooring Texture:', 'نوع الأرضية:'), style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: FlooringTexture.values.map((f) {
                        final isSel = f == selectedFlooring;
                        return ChoiceChip(
                          label: Text(f.localized, style: const TextStyle(fontSize: 10)),
                          selected: isSel,
                          selectedColor: const Color(0xFF10B981),
                          onSelected: (_) => setDialogState(() => selectedFlooring = f),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    TextField(controller: notesCtrl, decoration: InputDecoration(labelText: AppLanguage.tr('Architectural Notes', 'ملاحظات معمارية ومميزات'))),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: Text(AppLanguage.tr('Cancel', 'إلغاء'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                onPressed: () {
                  final newRecord = ArchitecturalUnitRecord(
                    id: 'UNIT-${DateTime.now().millisecondsSinceEpoch % 10000}',
                    name: nameCtrl.text.trim().isEmpty ? 'Architectural Unit' : nameCtrl.text.trim(),
                    zoneType: selectedZone,
                    areaSqm: double.tryParse(areaCtrl.text) ?? 150.0,
                    floorLevel: int.tryParse(floorCtrl.text) ?? 1,
                    priceEgp: double.tryParse(priceCtrl.text) ?? 3000000.0,
                    status: selectedStatus,
                    flooring: selectedFlooring,
                    notes: notesCtrl.text.trim(),
                    position: const Offset(0.5, 0.5),
                  );

                  final updated = List<ArchitecturalUnitRecord>.from(unitsNotifier.value)..add(newRecord);
                  unitsNotifier.value = updated;
                  selectedUnitNotifier.value = newRecord;

                  Navigator.of(dialogCtx).pop();
                },
                child: Text(AppLanguage.tr('Add Unit', 'إضافة الوحدة')),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditUnitDialog(BuildContext context, ArchitecturalUnitRecord unit) {
    final nameCtrl = TextEditingController(text: unit.name);
    final areaCtrl = TextEditingController(text: unit.areaSqm.toStringAsFixed(0));
    final priceCtrl = TextEditingController(text: unit.priceEgp.toStringAsFixed(0));
    final notesCtrl = TextEditingController(text: unit.notes);

    ArchitecturalZoneType selectedZone = unit.zoneType;
    FlooringTexture selectedFlooring = unit.flooring;
    ArchitecturalStatus selectedStatus = unit.status;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            actionsAlignment: MainAxisAlignment.spaceBetween,
            title: Text(AppLanguage.tr('Edit Unit / Venue Specs', 'تعديل بيانات الوحدة / القاعة')),
            content: SizedBox(
              width: 460,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameCtrl, decoration: InputDecoration(labelText: AppLanguage.tr('Unit Name', 'اسم الوحدة'))),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppLanguage.tr('Area (m²)', 'المساحة')))),
                        const SizedBox(width: 8),
                        Expanded(child: TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: AppLanguage.tr('Price (EGP)', 'السعر')))),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(AppLanguage.tr('Zoning Type:', 'نوع النشاط المعماري:'), style: const TextStyle(fontSize: 11)),
                    Wrap(
                      spacing: 6,
                      children: ArchitecturalZoneType.values.map((z) {
                        final isSel = z == selectedZone;
                        return ChoiceChip(
                          label: Text(z.localized, style: const TextStyle(fontSize: 10)),
                          selected: isSel,
                          selectedColor: const Color(0xFF10B981),
                          onSelected: (_) => setDialogState(() => selectedZone = z),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    Text(AppLanguage.tr('Flooring Texture:', 'نوع الأرضية:'), style: const TextStyle(fontSize: 11)),
                    Wrap(
                      spacing: 6,
                      children: FlooringTexture.values.map((f) {
                        final isSel = f == selectedFlooring;
                        return ChoiceChip(
                          label: Text(f.localized, style: const TextStyle(fontSize: 10)),
                          selected: isSel,
                          selectedColor: const Color(0xFF10B981),
                          onSelected: (_) => setDialogState(() => selectedFlooring = f),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    TextField(controller: notesCtrl, decoration: InputDecoration(labelText: AppLanguage.tr('Notes', 'الملاحظات'))),
                    const SizedBox(height: 10),
                    Text(AppLanguage.tr('Status:', 'الحالة:'), style: const TextStyle(fontSize: 11)),
                    Wrap(
                      spacing: 6,
                      children: ArchitecturalStatus.values.map((st) {
                        final isSel = st == selectedStatus;
                        return ChoiceChip(
                          label: Text(st.localized, style: const TextStyle(fontSize: 10)),
                          selected: isSel,
                          selectedColor: const Color(0xFF10B981),
                          onSelected: (_) => setDialogState(() => selectedStatus = st),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                icon: const Icon(Icons.delete_outline, size: 16),
                label: Text(AppLanguage.tr('Delete Unit', 'حذف الوحدة')),
                onPressed: () {
                  final list = List<ArchitecturalUnitRecord>.from(unitsNotifier.value);
                  if (list.length > 1) {
                    list.removeWhere((u) => u.id == unit.id);
                    unitsNotifier.value = list;
                    selectedUnitNotifier.value = list.first;
                    Navigator.of(dialogCtx).pop();
                  }
                },
              ),
              TextButton(onPressed: () => Navigator.of(dialogCtx).pop(), child: Text(AppLanguage.tr('Cancel', 'إلغاء'))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                onPressed: () {
                  final updated = unit.copyWith(
                    name: nameCtrl.text.trim(),
                    zoneType: selectedZone,
                    areaSqm: double.tryParse(areaCtrl.text) ?? unit.areaSqm,
                    priceEgp: double.tryParse(priceCtrl.text) ?? unit.priceEgp,
                    status: selectedStatus,
                    flooring: selectedFlooring,
                    notes: notesCtrl.text.trim(),
                  );

                  final list = List<ArchitecturalUnitRecord>.from(unitsNotifier.value);
                  final idx = list.indexWhere((u) => u.id == unit.id);
                  if (idx != -1) {
                    list[idx] = updated;
                    unitsNotifier.value = list;
                  }
                  Navigator.of(dialogCtx).pop();
                },
                child: Text(AppLanguage.tr('Save', 'حفظ')),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Custom 3D Isometric Architectural Floor Plate & Zones Painter
class _ArchitecturalFloor3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final List<ArchitecturalUnitRecord> units;
  final ArchitecturalUnitRecord? selectedUnit;

  _ArchitecturalFloor3DPainter({
    required this.yaw,
    required this.pitch,
    required this.units,
    required this.selectedUnit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);

    // 3D Isometric Floor Slab
    _drawStructuralSlab(canvas, size, cx, cy, cosYaw, sinYaw);

    // 3D Architectural Zone Volumes & Partitions
    for (final unit in units) {
      _drawZoneVolume(canvas, size, cx, cy, cosYaw, sinYaw, unit, unit.id == selectedUnit?.id);
    }
  }

  void _drawStructuralSlab(Canvas canvas, Size size, double cx, double cy, double cosYaw, double sinYaw) {
    final slabPaint = Paint()
      ..color = const Color(0xFF1E293B)
      ..style = PaintingStyle.fill;

    final edgePaint = Paint()
      ..color = const Color(0xFF334155)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final w = size.width * 0.70;
    final h = size.height * 0.55;
    final slabTop = cy - h * 0.4 + pitch * 50;

    final slabPath = Path();
    slabPath.moveTo(cx - (w / 2) * cosYaw, slabTop + (h / 2) * 0.4);
    slabPath.lineTo(cx, slabTop);
    slabPath.lineTo(cx + (w / 2) * cosYaw, slabTop + (h / 2) * 0.4);
    slabPath.lineTo(cx, slabTop + h * 0.8);
    slabPath.close();

    canvas.drawPath(slabPath, slabPaint);
    canvas.drawPath(slabPath, edgePaint);
  }

  void _drawZoneVolume(
    Canvas canvas,
    Size size,
    double cx,
    double cy,
    double cosYaw,
    double sinYaw,
    ArchitecturalUnitRecord unit,
    bool isSelected,
  ) {
    final px = cx + (unit.position.dx - 0.5) * (size.width * 0.5) * cosYaw;
    final py = cy + (unit.position.dy - 0.5) * (size.height * 0.4) + pitch * 40;

    final zoneRect = Rect.fromCenter(center: Offset(px, py), width: 80, height: 50);

    // Zone Floor Plate Fill
    final floorPaint = Paint()
      ..color = (isSelected ? const Color(0xFF10B981) : const Color(0xFF475569)).withValues(alpha: isSelected ? 0.35 : 0.20)
      ..style = PaintingStyle.fill;
    canvas.drawRect(zoneRect, floorPaint);

    // Zone 3D Extruded Wall Partitions
    final wallPaint = Paint()
      ..color = isSelected ? const Color(0xFF10B981) : Colors.white30
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.0 : 1.2;
    canvas.drawRect(zoneRect, wallPaint);

    // 3D Floating Status Beacon
    final beaconCenter = Offset(px, py - 20);
    final beaconPaint = Paint()
      ..color = unit.status.color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(beaconCenter, 5, beaconPaint);
    canvas.drawCircle(beaconCenter, 5, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Floating Unit Name Tag
    final textPainter = TextPainter(
      text: TextSpan(
        text: unit.name,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontSize: 9.5,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          backgroundColor: Colors.black87,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(px - textPainter.width / 2, py - 38));
  }

  @override
  bool shouldRepaint(covariant _ArchitecturalFloor3DPainter oldDelegate) {
    return oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.units != units ||
        oldDelegate.selectedUnit != selectedUnit;
  }
}
