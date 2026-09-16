import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_language.dart';

enum DeviceFormFactor {
  smartphone('Smartphone (هاتف ذكي)', Icons.smartphone),
  tablet('Tablet / iPad (جهاز لوحي)', Icons.tablet_mac),
  laptop('Laptop / Notebook (حاسوب محمول)', Icons.laptop_mac),
  smartwatch('Smartwatch (ساعة ذكية)', Icons.watch);

  final String label;
  final IconData icon;
  const DeviceFormFactor(this.label, this.icon);

  String get localized => AppLanguage.tr(
        label.split(' (').first,
        label.contains('(') ? label.split('(')[1].replaceAll(')', '') : label,
      );
}

enum DiagnosticDamageType {
  screenDamage('Screen / OLED Fracture', 'كسر الشاشة / تلف اللمس', Color(0xFFEF4444)),
  batteryDegradation('Battery Swollen / Degraded', 'انتفاخ / تلف البطارية', Color(0xFFF59E0B)),
  liquidCorrosion('Liquid / Water Contact', 'تلف سوائل / تآكل بوردة', Color(0xFFA855F7)),
  cameraLens('Camera Lens / Sensor Crack', 'كسر عدسة أو مستشعر الكاميرا', Color(0xFF3B82F6)),
  chargingPort('Charging Port / Pin Damage', 'تلف مدخل الشحن / التوصيل', Color(0xFFFB923C)),
  housingFrame('Housing Frame / Back Glass', 'انحناء الشاسيه / كسر الظهر', Color(0xFF06B6D4));

  final String labelEn;
  final String labelAr;
  final Color color;
  const DiagnosticDamageType(this.labelEn, this.labelAr, this.color);

  String get localized => AppLanguage.tr(labelEn, labelAr);
}

class DeviceDiagnosticPin {
  final String id;
  final DiagnosticDamageType type;
  final Offset position; // Normalized 0.0 - 1.0 on 3D device face
  final String note;
  final double repairEstimateEgp;

  const DeviceDiagnosticPin({
    required this.id,
    required this.type,
    required this.position,
    this.note = '',
    this.repairEstimateEgp = 450.0,
  });
}

class ElectronicsDeviceRecord {
  final String id;
  final String brand;
  final String modelName;
  final DeviceFormFactor formFactor;
  final Color chassisColor;
  final String serialOrImei;
  final double diagnosticFeeEgp;
  final String notes;
  final List<DeviceDiagnosticPin> diagnosticPins;

  const ElectronicsDeviceRecord({
    required this.id,
    required this.brand,
    required this.modelName,
    this.formFactor = DeviceFormFactor.smartphone,
    this.chassisColor = const Color(0xFF334155),
    this.serialOrImei = 'IMEI-86392018392104',
    this.diagnosticFeeEgp = 350.0,
    this.notes = '',
    this.diagnosticPins = const [],
  });

  ElectronicsDeviceRecord copyWith({
    String? id,
    String? brand,
    String? modelName,
    DeviceFormFactor? formFactor,
    Color? chassisColor,
    String? serialOrImei,
    double? diagnosticFeeEgp,
    String? notes,
    List<DeviceDiagnosticPin>? diagnosticPins,
  }) {
    return ElectronicsDeviceRecord(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      modelName: modelName ?? this.modelName,
      formFactor: formFactor ?? this.formFactor,
      chassisColor: chassisColor ?? this.chassisColor,
      serialOrImei: serialOrImei ?? this.serialOrImei,
      diagnosticFeeEgp: diagnosticFeeEgp ?? this.diagnosticFeeEgp,
      notes: notes ?? this.notes,
      diagnosticPins: diagnosticPins ?? this.diagnosticPins,
    );
  }
}

/// 3D Interactive, Editable Electronics & Mobile Device Diagnostic Workbench
class ElectronicsDevice3DInspectorWidget extends StatelessWidget {
  final ValueNotifier<List<ElectronicsDeviceRecord>> devicesNotifier;
  final ValueNotifier<ElectronicsDeviceRecord?> selectedDeviceNotifier;
  final ValueNotifier<double> yawNotifier;
  final ValueNotifier<double> pitchNotifier;
  final ValueNotifier<bool> isAddingPinNotifier;
  final Function(ElectronicsDeviceRecord device, List<DeviceDiagnosticPin> pins)? onOrderCommitted;

  ElectronicsDevice3DInspectorWidget({
    super.key,
    ValueNotifier<List<ElectronicsDeviceRecord>>? devicesNotifier,
    ValueNotifier<ElectronicsDeviceRecord?>? selectedDeviceNotifier,
    ValueNotifier<double>? yawNotifier,
    ValueNotifier<double>? pitchNotifier,
    ValueNotifier<bool>? isAddingPinNotifier,
    this.onOrderCommitted,
  })  : devicesNotifier = devicesNotifier ?? ValueNotifier<List<ElectronicsDeviceRecord>>(defaultDevices),
        selectedDeviceNotifier = selectedDeviceNotifier ?? ValueNotifier<ElectronicsDeviceRecord?>(defaultDevices.first),
        yawNotifier = yawNotifier ?? ValueNotifier<double>(0.0),
        pitchNotifier = pitchNotifier ?? ValueNotifier<double>(0.0),
        isAddingPinNotifier = isAddingPinNotifier ?? ValueNotifier<bool>(false);

  static const List<ElectronicsDeviceRecord> defaultDevices = [
    ElectronicsDeviceRecord(
      id: 'DEV-101',
      brand: 'Apple',
      modelName: 'iPhone 15 Pro Max',
      formFactor: DeviceFormFactor.smartphone,
      chassisColor: Color(0xFF475569), // Natural Titanium
      serialOrImei: 'IMEI-35892109283719',
      diagnosticFeeEgp: 650.0,
      notes: 'Customer reports touch ghost clicks after 1-meter drop on concrete.',
      diagnosticPins: [
        DeviceDiagnosticPin(
          id: 'PIN-1',
          type: DiagnosticDamageType.screenDamage,
          position: Offset(0.48, 0.28),
          note: 'OLED micro-fracture spiderweb along upper left quadrant.',
          repairEstimateEgp: 3200.0,
        ),
      ],
    ),
    ElectronicsDeviceRecord(
      id: 'DEV-102',
      brand: 'Apple',
      modelName: 'iPad Pro 12.9" M2',
      formFactor: DeviceFormFactor.tablet,
      chassisColor: Color(0xFF1E293B), // Space Gray
      serialOrImei: 'SER-DMPV9281H2',
      diagnosticFeeEgp: 500.0,
      notes: 'Fast battery drain, throttling under heavy drawing load in Procreate.',
      diagnosticPins: [
        DeviceDiagnosticPin(
          id: 'PIN-2',
          type: DiagnosticDamageType.batteryDegradation,
          position: Offset(0.50, 0.52),
          note: 'Battery cycle count 890, capacity degraded to 71%.',
          repairEstimateEgp: 1850.0,
        ),
      ],
    ),
    ElectronicsDeviceRecord(
      id: 'DEV-103',
      brand: 'Apple',
      modelName: 'MacBook Pro 16" M3 Max',
      formFactor: DeviceFormFactor.laptop,
      chassisColor: Color(0xFF94A3B8), // Silver
      serialOrImei: 'SER-C02X8392MD6',
      diagnosticFeeEgp: 950.0,
      notes: 'Liquid spill on keyboard deck; intermittent trackpad click response.',
      diagnosticPins: [
        DeviceDiagnosticPin(
          id: 'PIN-3',
          type: DiagnosticDamageType.liquidCorrosion,
          position: Offset(0.50, 0.65),
          note: 'Red LCI indicator triggered under spacebar keycaps.',
          repairEstimateEgp: 4500.0,
        ),
      ],
    ),
    ElectronicsDeviceRecord(
      id: 'DEV-104',
      brand: 'Apple',
      modelName: 'Apple Watch Ultra 2',
      formFactor: DeviceFormFactor.smartwatch,
      chassisColor: Color(0xFFE2E8F0), // Titanium
      serialOrImei: 'SER-FH281902K',
      diagnosticFeeEgp: 400.0,
      notes: 'Digital crown rotational stiffness and sapphire front micro-scratch.',
      diagnosticPins: [
        DeviceDiagnosticPin(
          id: 'PIN-4',
          type: DiagnosticDamageType.chargingPort,
          position: Offset(0.68, 0.45),
          note: 'Debris lodged in digital crown optical encoder cavity.',
          repairEstimateEgp: 650.0,
        ),
      ],
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

          // ── MAIN 3D WORKSPACE ──────────────────────────────────────────────
          Expanded(
            child: Row(
              children: [
                // 3D Device Viewport
                Expanded(
                  flex: 3,
                  child: _build3DDeviceViewport(context),
                ),
                const VerticalDivider(width: 1, color: AppColors.borderDark),

                // Device & Diagnostic Pin Inspector Panel
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
            const Icon(Icons.devices, color: Color(0xFF06B6D4), size: 20),
            const SizedBox(width: 8),
            Text(
              AppLanguage.tr('3D Device Diagnostic & Repair Bench', 'منصة الفحص الفني ثلاثية الأبعاد للأجهزة'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 14),

            // "+ Add Device to 3D Bench"
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF06B6D4),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              icon: const Icon(Icons.add_to_photos, size: 14),
              label: Text(
                AppLanguage.tr('+ Add Device to 3D Bench', '+ إضافة جهاز للمنصة 3D'),
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              onPressed: () => _showAddDeviceDialog(context),
            ),
            const SizedBox(width: 8),

            // "+ Diagnostic Pin" Mode Toggle
            ValueListenableBuilder<bool>(
              valueListenable: isAddingPinNotifier,
              builder: (context, isAdding, _) {
                return FilterChip(
                  avatar: Icon(
                    isAdding ? Icons.check_circle : Icons.add_location_alt,
                    size: 14,
                    color: isAdding ? Colors.white : const Color(0xFFF59E0B),
                  ),
                  label: Text(
                    AppLanguage.tr('+ 3D Diagnostic Pin', '+ تثبيت نقطة عطل 3D'),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isAdding ? Colors.white : AppColors.textPrimaryDark,
                    ),
                  ),
                  selected: isAdding,
                  selectedColor: const Color(0xFFF59E0B),
                  backgroundColor: AppColors.surfaceElevatedDark,
                  onSelected: (val) {
                    isAddingPinNotifier.value = val;
                  },
                );
              },
            ),
            const SizedBox(width: 12),

            // Camera Presets
            _buildPresetChip('Front Display', 'الواجهة الأمامية', 0.0, 0.0),
            _buildPresetChip('Rear Housing', 'الظهر والكاميرا', math.pi, 0.0),
            _buildPresetChip('Isometric 3D', 'رؤية مجسمة 3D', 0.45, 0.35),
            _buildPresetChip('Side Port', 'المنافذ الجانبية', math.pi / 2, 0.1),

            const SizedBox(width: 8),
            IconButton(
              tooltip: AppLanguage.tr('Reset 3D View', 'إعادة ضبط 3D'),
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

  Widget _build3DDeviceViewport(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([selectedDeviceNotifier, yawNotifier, pitchNotifier, isAddingPinNotifier]),
      builder: (context, _) {
        final device = selectedDeviceNotifier.value;
        final yaw = yawNotifier.value;
        final pitch = pitchNotifier.value;
        final isAdding = isAddingPinNotifier.value;

        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onPanUpdate: (details) {
                yawNotifier.value += details.delta.dx * 0.01;
                pitchNotifier.value = (pitchNotifier.value - details.delta.dy * 0.01).clamp(-1.2, 1.2);
              },
              onTapUp: (details) {
                if (isAdding && device != null) {
                  _showAddPinDialog(context, details.localPosition, device);
                }
              },
              child: CustomPaint(
                painter: _Device3DPainter(
                  yaw: yaw,
                  pitch: pitch,
                  device: device,
                ),
                child: const SizedBox.expand(),
              ),
            ),

            // Top HUD
            Positioned(
              top: 12,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(device?.formFactor.icon ?? Icons.devices, size: 14, color: const Color(0xFF06B6D4)),
                    const SizedBox(width: 6),
                    Text(
                      '${device?.brand ?? ""} ${device?.modelName ?? ""}  •  Yaw: ${(yaw * 180 / math.pi).toStringAsFixed(0)}°  Pitch: ${(pitch * 180 / math.pi).toStringAsFixed(0)}°',
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),

            // Placement Banner
            if (isAdding)
              Positioned(
                bottom: 16,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 8)],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.touch_app, size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        AppLanguage.tr(
                          'Tap anywhere on the 3D device to anchor a diagnostic fault pin.',
                          'اضغط في أي مكان على سطح الجهاز 3D لتثبيت علامة العطل الفني.',
                        ),
                        style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
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
      animation: Listenable.merge([devicesNotifier, selectedDeviceNotifier]),
      builder: (context, _) {
        final devices = devicesNotifier.value;
        final selected = selectedDeviceNotifier.value ?? (devices.isNotEmpty ? devices.first : null);
        final pins = selected?.diagnosticPins ?? [];

        return Container(
          color: AppColors.surfaceDark,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppLanguage.tr('Device Bench Catalog', 'الأجهزة المسجلة على المنصة'),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 8),

              // Device Selector List
              SizedBox(
                height: 110,
                child: ListView.separated(
                  itemCount: devices.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = devices[index];
                    final isSel = item.id == selected?.id;

                    return InkWell(
                      onTap: () => selectedDeviceNotifier.value = item,
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF06B6D4).withValues(alpha: 0.15) : AppColors.surfaceElevatedDark,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isSel ? const Color(0xFF06B6D4) : AppColors.borderDark,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(item.formFactor.icon, size: 16, color: const Color(0xFF06B6D4)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${item.brand} ${item.modelName}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                      color: isSel ? Colors.white : AppColors.textPrimaryDark,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${item.diagnosticPins.length} ${AppLanguage.tr("Faults", "أعطال")} • ${item.diagnosticFeeEgp.toStringAsFixed(0)} EGP',
                                    style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(height: 16, color: AppColors.borderDark),

              // Selected Device Details
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
                                '${selected.brand} ${selected.modelName}',
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF06B6D4)),
                              tooltip: AppLanguage.tr('Edit Device Specs', 'تعديل بيانات الجهاز'),
                              onPressed: () => _showEditDeviceDialog(context, selected),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            _buildBadge(AppLanguage.tr('Diagnostic Fee', 'رسوم الفحص'), '${selected.diagnosticFeeEgp.toStringAsFixed(0)} EGP', Colors.cyanAccent),
                            const SizedBox(width: 6),
                            _buildBadge(AppLanguage.tr('Pins / Faults', 'النقاط المسجلة'), '${pins.length}', Colors.amberAccent),
                          ],
                        ),
                        const SizedBox(height: 8),

                        Text(
                          '${AppLanguage.tr("Serial / IMEI", "الرقم التسلسلي / IMEI")}: ${selected.serialOrImei}',
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${AppLanguage.tr("Form Factor", "نوع الجهاز")}: ${selected.formFactor.localized}',
                          style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark),
                        ),
                        const SizedBox(height: 10),

                        Text(
                          '${AppLanguage.tr("Diagnostic Faults Detected", "أعطال الفحص المكتشفة")} (${pins.length})',
                          style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                        const SizedBox(height: 6),

                        ...pins.map((p) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevatedDark,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: p.type.color.withValues(alpha: 0.35)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.warning_amber_rounded, size: 14, color: p.type.color),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.type.localized,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                      if (p.note.isNotEmpty)
                                        Text(p.note, style: const TextStyle(fontSize: 9.5, color: Colors.white60)),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${p.repairEstimateEgp.toStringAsFixed(0)} EGP',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: p.type.color),
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

                // Commit Button
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF06B6D4),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  icon: const Icon(Icons.build_circle, size: 14),
                  label: Text(
                    AppLanguage.tr('Create Repair Work Order with 3D Diagnostics', 'فتح أمر إصلاح بتقرير الفحص 3D'),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  onPressed: () {
                    onOrderCommitted?.call(selected, pins);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Device repair work order dispatched with 3D diagnostic map!',
                          'تم إنشاء أمر إصلاح الجهاز مع خريطة الفحص ثلاثية الأبعاد!',
                        )),
                        backgroundColor: const Color(0xFF06B6D4),
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

  void _showAddDeviceDialog(BuildContext context) {
    final brandCtrl = TextEditingController(text: 'Samsung');
    final modelCtrl = TextEditingController(text: 'Galaxy S24 Ultra');
    final imeiCtrl = TextEditingController(text: 'IMEI-86392019482710');
    final priceCtrl = TextEditingController(text: '450');
    final notesCtrl = TextEditingController();

    DeviceFormFactor selectedFactor = DeviceFormFactor.smartphone;
    Color selectedColor = const Color(0xFF334155);

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                side: const BorderSide(color: AppColors.borderDark),
              ),
              title: Row(
                children: [
                  const Icon(Icons.devices, color: Color(0xFF06B6D4), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Add Device to 3D Bench', 'إضافة جهاز جديد للمنصة 3D'),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: brandCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Brand (Apple, Samsung...)', 'الماركة'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: modelCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Model Name', 'اسم الموديل'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Text(
                        AppLanguage.tr('Device Form Factor', 'نوع وتصميم الجهاز 3D'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: DeviceFormFactor.values.map((f) {
                          final isSel = f == selectedFactor;
                          return ChoiceChip(
                            label: Text(f.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFF06B6D4),
                            onSelected: (_) => setDialogState(() => selectedFactor = f),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: imeiCtrl,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Serial / IMEI', 'الرقم التسلسلي / IMEI'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Diagnostic Fee (EGP)', 'رسوم الفحص (ج.م)'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Color Palette
                      Text(
                        AppLanguage.tr('Chassis Colorway', 'لون الهيكل الخارجي'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Color(0xFF0F172A),
                          const Color(0xFF334155),
                          const Color(0xFF475569),
                          const Color(0xFF94A3B8),
                          const Color(0xFF1E3A8A),
                          const Color(0xFF047857),
                          const Color(0xFFB45309),
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
                          labelText: AppLanguage.tr('Customer Complaint & Symptoms', 'شكوى العميل والأعراض'),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06B6D4)),
                  onPressed: () {
                    final newRecord = ElectronicsDeviceRecord(
                      id: 'DEV-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      brand: brandCtrl.text.trim().isEmpty ? 'Tech' : brandCtrl.text.trim(),
                      modelName: modelCtrl.text.trim().isEmpty ? 'Device' : modelCtrl.text.trim(),
                      formFactor: selectedFactor,
                      chassisColor: selectedColor,
                      serialOrImei: imeiCtrl.text.trim(),
                      diagnosticFeeEgp: double.tryParse(priceCtrl.text) ?? 400.0,
                      notes: notesCtrl.text.trim(),
                    );

                    final updated = List<ElectronicsDeviceRecord>.from(devicesNotifier.value)..add(newRecord);
                    devicesNotifier.value = updated;
                    selectedDeviceNotifier.value = newRecord;

                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'New device added to 3D workbench!',
                          'تمت إضافة الجهاز للمنصة ثلاثية الأبعاد!',
                        )),
                        backgroundColor: const Color(0xFF06B6D4),
                      ),
                    );
                  },
                  child: Text(AppLanguage.tr('Add Device', 'إضافة الجهاز')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditDeviceDialog(BuildContext context, ElectronicsDeviceRecord device) {
    final brandCtrl = TextEditingController(text: device.brand);
    final modelCtrl = TextEditingController(text: device.modelName);
    final imeiCtrl = TextEditingController(text: device.serialOrImei);
    final priceCtrl = TextEditingController(text: device.diagnosticFeeEgp.toStringAsFixed(0));
    final notesCtrl = TextEditingController(text: device.notes);

    DeviceFormFactor selectedFactor = device.formFactor;
    Color selectedColor = device.chassisColor;

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
                  const Icon(Icons.edit, color: Color(0xFF06B6D4), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Edit Device Specs', 'تعديل بيانات ومواصفات الجهاز 3D'),
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
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: brandCtrl,
                              decoration: InputDecoration(labelText: AppLanguage.tr('Brand', 'الماركة')),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: modelCtrl,
                              decoration: InputDecoration(labelText: AppLanguage.tr('Model', 'الموديل')),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Text(
                        AppLanguage.tr('Device Form Factor', 'نوع وتصميم الجهاز 3D'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        children: DeviceFormFactor.values.map((f) {
                          final isSel = f == selectedFactor;
                          return ChoiceChip(
                            label: Text(f.localized, style: const TextStyle(fontSize: 10)),
                            selected: isSel,
                            selectedColor: const Color(0xFF06B6D4),
                            onSelected: (_) => setDialogState(() => selectedFactor = f),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: imeiCtrl,
                              decoration: InputDecoration(labelText: AppLanguage.tr('Serial / IMEI', 'الرقم التسلسلي')),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: priceCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: AppLanguage.tr('Diagnostic Fee (EGP)', 'رسوم الفحص')),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      Text(
                        AppLanguage.tr('Chassis Colorway', 'لون الهيكل الخارجي'),
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Color(0xFF0F172A),
                          const Color(0xFF334155),
                          const Color(0xFF475569),
                          const Color(0xFF94A3B8),
                          const Color(0xFF1E3A8A),
                          const Color(0xFF047857),
                          const Color(0xFFB45309),
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
                  label: Text(AppLanguage.tr('Delete Device', 'حذف الجهاز')),
                  onPressed: () {
                    final current = List<ElectronicsDeviceRecord>.from(devicesNotifier.value);
                    if (current.length > 1) {
                      current.removeWhere((d) => d.id == device.id);
                      devicesNotifier.value = current;
                      selectedDeviceNotifier.value = current.first;
                      Navigator.of(dialogCtx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr('Device removed from workbench!', 'تم حذف الجهاز من المنصة!')),
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
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF06B6D4)),
                  onPressed: () {
                    final updatedRecord = device.copyWith(
                      brand: brandCtrl.text.trim().isEmpty ? device.brand : brandCtrl.text.trim(),
                      modelName: modelCtrl.text.trim().isEmpty ? device.modelName : modelCtrl.text.trim(),
                      formFactor: selectedFactor,
                      chassisColor: selectedColor,
                      serialOrImei: imeiCtrl.text.trim(),
                      diagnosticFeeEgp: double.tryParse(priceCtrl.text) ?? device.diagnosticFeeEgp,
                      notes: notesCtrl.text.trim(),
                    );

                    final current = List<ElectronicsDeviceRecord>.from(devicesNotifier.value);
                    final idx = current.indexWhere((d) => d.id == device.id);
                    if (idx != -1) {
                      current[idx] = updatedRecord;
                      devicesNotifier.value = current;
                      selectedDeviceNotifier.value = updatedRecord;
                    }

                    Navigator.of(dialogCtx).pop();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr('3D device updated!', 'تم تحديث بيانات ومواصفات الجهاز 3D!')),
                          backgroundColor: const Color(0xFF06B6D4),
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

  void _showAddPinDialog(BuildContext context, Offset localPos, ElectronicsDeviceRecord device) {
    final noteCtrl = TextEditingController();
    final estimateCtrl = TextEditingController(text: '650');
    DiagnosticDamageType selectedType = DiagnosticDamageType.screenDamage;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              title: Text(AppLanguage.tr('Anchor Diagnostic Fault Pin', 'تثبيت نقطة عطل فني 3D')),
              content: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLanguage.tr('Fault Category:', 'نوع العطل الفني:'),
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: DiagnosticDamageType.values.map((t) {
                        final isSel = t == selectedType;
                        return ChoiceChip(
                          avatar: Icon(Icons.circle, size: 10, color: t.color),
                          label: Text(t.localized, style: const TextStyle(fontSize: 10)),
                          selected: isSel,
                          selectedColor: t.color.withValues(alpha: 0.3),
                          onSelected: (_) => setDialogState(() => selectedType = t),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: estimateCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Repair Cost Estimate (EGP)', 'تكلفة الإصلاح التقديرية (ج.م)'),
                      ),
                    ),
                    const SizedBox(height: 8),

                    TextField(
                      controller: noteCtrl,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Diagnostic Notes', 'ملاحظات الفحص والعيوب'),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                  onPressed: () {
                    final newPin = DeviceDiagnosticPin(
                      id: 'PIN-${DateTime.now().millisecondsSinceEpoch % 10000}',
                      type: selectedType,
                      position: Offset(localPos.dx / 400.0, localPos.dy / 500.0),
                      note: noteCtrl.text.trim(),
                      repairEstimateEgp: double.tryParse(estimateCtrl.text) ?? 650.0,
                    );

                    final updatedPins = List<DeviceDiagnosticPin>.from(device.diagnosticPins)..add(newPin);
                    final updatedDev = device.copyWith(diagnosticPins: updatedPins);

                    final currentList = List<ElectronicsDeviceRecord>.from(devicesNotifier.value);
                    final idx = currentList.indexWhere((d) => d.id == device.id);
                    if (idx != -1) {
                      currentList[idx] = updatedDev;
                      devicesNotifier.value = currentList;
                      selectedDeviceNotifier.value = updatedDev;
                    }

                    isAddingPinNotifier.value = false;
                    Navigator.of(dialogCtx).pop();
                  },
                  child: Text(AppLanguage.tr('Add Pin', 'تثبيت النقطة')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Custom 3D Device Geometry & Diagnostics Painter
class _Device3DPainter extends CustomPainter {
  final double yaw;
  final double pitch;
  final ElectronicsDeviceRecord? device;

  _Device3DPainter({
    required this.yaw,
    required this.pitch,
    required this.device,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final cx = size.width / 2;
    final cy = size.height / 2;

    _drawWorkbenchGrid(canvas, size, cx, cy);

    final cosYaw = math.cos(yaw);
    final sinYaw = math.sin(yaw);
    final factor = device?.formFactor ?? DeviceFormFactor.smartphone;

    canvas.save();
    canvas.translate(cx, cy);

    // Apply Pitch Matrix
    final matrix = Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective
      ..rotateX(pitch)
      ..rotateY(yaw);
    canvas.transform(matrix.storage);

    _drawDeviceChassis(canvas, factor, device?.chassisColor ?? const Color(0xFF334155), cosYaw, sinYaw);
    _drawDiagnosticPins(canvas, factor, device?.diagnosticPins ?? []);

    canvas.restore();
  }

  void _drawWorkbenchGrid(Canvas canvas, Size size, double cx, double cy) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..strokeWidth = 1.0;

    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _drawDeviceChassis(Canvas canvas, DeviceFormFactor factor, Color chassisColor, double cosYaw, double sinYaw) {
    final isFacingFront = cosYaw >= 0;

    double devW = 160.0;
    double devH = 320.0;
    double cornerR = 24.0;
    double depth = 14.0;

    switch (factor) {
      case DeviceFormFactor.smartphone:
        devW = 150.0;
        devH = 310.0;
        cornerR = 26.0;
        depth = 12.0;
        break;
      case DeviceFormFactor.tablet:
        devW = 280.0;
        devH = 380.0;
        cornerR = 20.0;
        depth = 10.0;
        break;
      case DeviceFormFactor.laptop:
        devW = 340.0;
        devH = 240.0;
        cornerR = 14.0;
        depth = 16.0;
        break;
      case DeviceFormFactor.smartwatch:
        devW = 130.0;
        devH = 160.0;
        cornerR = 36.0;
        depth = 22.0;
        break;
    }

    final rect = Rect.fromCenter(center: Offset.zero, width: devW, height: devH);

    // 1. Chassis 3D Extruded Depth Bevel (perspective side rim when rotated)
    if (sinYaw.abs() > 0.02) {
      final sideWidth = depth * sinYaw;
      final sideRect = Rect.fromLTWH(
        sideWidth > 0 ? rect.right - 2 : rect.left - sideWidth.abs() + 2,
        rect.top + 4,
        sideWidth.abs(),
        rect.height - 8,
      );
      final sidePaint = Paint()
        ..color = Color.lerp(chassisColor, Colors.black, 0.45)!
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(sideRect, Radius.circular(cornerR * 0.4)), sidePaint);
    }

    // 2. Chassis Outer Edge (Extruded bevel)
    final framePaint = Paint()
      ..color = chassisColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerR)), framePaint);

    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(RRect.fromRectAndRadius(rect, Radius.circular(cornerR)), borderPaint);

    if (isFacingFront) {
      // FRONT DISPLAY VIEW
      final screenInset = factor == DeviceFormFactor.laptop ? 14.0 : 8.0;
      final screenRect = rect.deflate(screenInset);
      final screenPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF090D16), Color(0xFF1E293B), Color(0xFF0F172A)],
        ).createShader(screenRect);

      canvas.drawRRect(RRect.fromRectAndRadius(screenRect, Radius.circular(cornerR - 4)), screenPaint);

      // Dynamic Island / Camera Notch on Smartphone / Tablet
      if (factor == DeviceFormFactor.smartphone) {
        final islandRect = Rect.fromCenter(center: Offset(0, -devH / 2 + 22), width: 44, height: 14);
        canvas.drawRRect(RRect.fromRectAndRadius(islandRect, const Radius.circular(7)), Paint()..color = Colors.black);
      } else if (factor == DeviceFormFactor.laptop) {
        // Keyboard Base preview in 3D
        final keyboardRect = Rect.fromCenter(center: Offset(0, devH / 4), width: devW - 40, height: devH / 3);
        canvas.drawRRect(RRect.fromRectAndRadius(keyboardRect, const Radius.circular(6)), Paint()..color = Colors.black38);
      }

      // Specular Glass Sheen
      final sheenPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white.withValues(alpha: 0.15), Colors.transparent],
        ).createShader(screenRect);
      canvas.drawRRect(RRect.fromRectAndRadius(screenRect, Radius.circular(cornerR - 4)), sheenPaint);
    } else {
      // REAR HOUSING VIEW
      final backPaint = Paint()
        ..color = chassisColor.withValues(alpha: 0.95)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(RRect.fromRectAndRadius(rect.deflate(4), Radius.circular(cornerR - 2)), backPaint);

      // Camera Island
      final islandW = devW * 0.42;
      final islandH = devH * 0.28;
      final islandRect = Rect.fromLTWH(-devW / 2 + 14, -devH / 2 + 14, islandW, islandH);
      final islandPaint = Paint()..color = Colors.black.withValues(alpha: 0.35);
      canvas.drawRRect(RRect.fromRectAndRadius(islandRect, const Radius.circular(16)), islandPaint);

      // Camera Lenses
      final lensPaint = Paint()..color = const Color(0xFF0284C7);
      canvas.drawCircle(islandRect.topLeft + const Offset(18, 20), 12, lensPaint);
      canvas.drawCircle(islandRect.topLeft + const Offset(18, 52), 12, lensPaint);
      canvas.drawCircle(islandRect.topLeft + const Offset(46, 36), 12, lensPaint);
    }
  }

  void _drawDiagnosticPins(Canvas canvas, DeviceFormFactor factor, List<DeviceDiagnosticPin> pins) {
    for (final pin in pins) {
      final pinOffset = Offset((pin.position.dx - 0.5) * 160.0, (pin.position.dy - 0.5) * 280.0);

      // Pulsing Outer Beacon
      final haloPaint = Paint()
        ..color = pin.type.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(pinOffset, 14, haloPaint);

      // Pin Core
      final corePaint = Paint()..color = pin.type.color;
      canvas.drawCircle(pinOffset, 7, corePaint);

      final whiteBorder = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(pinOffset, 7, whiteBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _Device3DPainter oldDelegate) {
    return oldDelegate.yaw != yaw || oldDelegate.pitch != pitch || oldDelegate.device != device;
  }
}
