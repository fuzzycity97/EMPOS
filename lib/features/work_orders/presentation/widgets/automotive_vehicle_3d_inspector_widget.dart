import 'package:flutter/material.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/localization/app_language.dart';

/// Vehicle Body Type
enum VehicleBodyType {
  sedan('Sedan (صالون)', Icons.directions_car),
  suv('SUV / Crossover (دفع رباعي)', Icons.airport_shuttle),
  truck('Pickup Truck (شاحنة نقل)', Icons.local_shipping),
  coupe('Sport Coupe (كوبيه رياضي)', Icons.sports_motorsports_outlined),
  ev('Electric EV (كهربائي)', Icons.electric_car);

  final String rawLabel;
  final IconData icon;
  const VehicleBodyType(this.rawLabel, this.icon);

  String get label => AppLanguage.isArabic ? rawLabel : (rawLabel.contains('(') ? rawLabel.split('(')[0].trim() : rawLabel);
}

/// Automotive Inspection Layer
enum AutoInspectionLayer {
  all('All Systems (جميع الأنظمة)', 'Complete vehicle composite frame'),
  exterior('1. Exterior Body & Paint (الهيكل والطلاء)', 'Panels, bumpers, windshield & dents'),
  powertrain('2. Powertrain & Engine Bay (المحرك والميكانيكا)', 'Engine block, radiator, battery & fluid levels'),
  wheelsBrakes('3. Wheels & Brakes (الإطارات والمكابح)', 'Tire tread depth, brake pads & wheel bearings'),
  undercarriage('4. Undercarriage & Suspension (أسفل الهيكل والتعليق)', 'Exhaust system, drive shaft, shocks & steering tie rods');

  final String rawLabel;
  final String rawDescription;
  const AutoInspectionLayer(this.rawLabel, this.rawDescription);

  String get label => AppLanguage.isArabic ? rawLabel : (rawLabel.contains('(') ? rawLabel.split('(')[0].trim() : rawLabel);
  String get description => AppLanguage.isArabic ? rawDescription : (rawDescription.contains('(') ? rawDescription.split('(')[0].trim() : rawDescription);
}

/// Inspection Severity Rating
enum InspectionSeverity {
  good('Pass / Good', 'سليم وممتاز', Color(0xFF10B981)),
  attention('Needs Attention / Fair', 'يحتاج متابعة', Color(0xFFF59E0B)),
  critical('Critical / Immediate Repair', 'حرج / يتطلب إصلاح فوري', Color(0xFFEF4444));

  final String labelEn;
  final String labelAr;
  final Color color;
  const InspectionSeverity(this.labelEn, this.labelAr, this.color);

  String get label => AppLanguage.isArabic ? labelAr : labelEn;
}

/// Single Inspection Point Result
class VehicleInspectionPoint {
  final String id;
  final String nameEn;
  final String nameAr;
  final AutoInspectionLayer layer;
  final InspectionSeverity severity;
  final String notes;
  final double estimatedCost;
  final Offset relativePos; // (x, y) 0.0 - 1.0 on canvas

  const VehicleInspectionPoint({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.layer,
    required this.severity,
    required this.notes,
    required this.estimatedCost,
    required this.relativePos,
  });

  String get name => AppLanguage.isArabic ? nameAr : nameEn;
  String get title => name;
  double get estimatedRepairCost => estimatedCost;
  String get systemCategory => layer.label;

  VehicleInspectionPoint copyWith({
    InspectionSeverity? severity,
    String? notes,
    double? estimatedCost,
    Offset? relativePos,
  }) {
    return VehicleInspectionPoint(
      id: id,
      nameEn: nameEn,
      nameAr: nameAr,
      layer: layer,
      severity: severity ?? this.severity,
      notes: notes ?? this.notes,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      relativePos: relativePos ?? this.relativePos,
    );
  }
}

/// Vehicle Dealership / Workshop Record for 3D Showroom & Service Bay
class VehicleDealershipRecord {
  final String id;
  final String make;
  final String model;
  final int year;
  final String vin;
  final VehicleBodyType bodyType;
  final Color paintColor;
  final double priceEgp;
  final String status;
  final Map<String, VehicleInspectionPoint> findings;

  const VehicleDealershipRecord({
    required this.id,
    required this.make,
    required this.model,
    required this.year,
    required this.vin,
    required this.bodyType,
    required this.paintColor,
    required this.priceEgp,
    required this.status,
    required this.findings,
  });

  String get displayName => '$year $make $model';

  VehicleDealershipRecord copyWith({
    String? make,
    String? model,
    int? year,
    String? vin,
    VehicleBodyType? bodyType,
    Color? paintColor,
    double? priceEgp,
    String? status,
    Map<String, VehicleInspectionPoint>? findings,
  }) {
    return VehicleDealershipRecord(
      id: id,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      vin: vin ?? this.vin,
      bodyType: bodyType ?? this.bodyType,
      paintColor: paintColor ?? this.paintColor,
      priceEgp: priceEgp ?? this.priceEgp,
      status: status ?? this.status,
      findings: findings ?? this.findings,
    );
  }
}

/// 3D Interactive Automotive Vehicle Inspection & Dealership 3D Showroom Workspace
class AutomotiveVehicle3DInspectorWidget extends StatefulWidget {
  final StoreBlueprint? blueprint;
  final void Function(VehicleInspectionPoint finding)? onFindingAddedToTicket;

  const AutomotiveVehicle3DInspectorWidget({
    super.key,
    this.blueprint,
    this.onFindingAddedToTicket,
  });

  @override
  State<AutomotiveVehicle3DInspectorWidget> createState() => _AutomotiveVehicle3DInspectorWidgetState();
}

class _AutomotiveVehicle3DInspectorWidgetState extends State<AutomotiveVehicle3DInspectorWidget> {
  late final ValueNotifier<List<VehicleDealershipRecord>> _vehiclesNotifier;
  late final ValueNotifier<String> _selectedVehicleIdNotifier;
  late final ValueNotifier<AutoInspectionLayer> _layerNotifier;
  late final ValueNotifier<double> _yawNotifier;
  late final ValueNotifier<double> _pitchNotifier;
  late final ValueNotifier<int> _activeLiftBayNotifier;
  late final ValueNotifier<bool> _isDropPinModeNotifier;

  static const List<Color> _availablePaints = [
    Color(0xFF0284C7), // Sapphire Blue
    Color(0xFFE11D48), // Crimson Red
    Color(0xFF10B981), // Emerald Green
    Color(0xFFF59E0B), // Solar Amber
    Color(0xFF64748B), // Slate Grey
    Color(0xFF0F172A), // Midnight Black
    Color(0xFFE2E8F0), // Alpine White
    Color(0xFF8B5CF6), // Royal Purple
  ];

  @override
  void initState() {
    super.initState();

    final defaultFindings = {
      'engine_oil': const VehicleInspectionPoint(
        id: 'engine_oil',
        nameEn: 'Engine Bay & Synthetic Oil',
        nameAr: 'حجرة المحرك والزيت التخليقي',
        layer: AutoInspectionLayer.powertrain,
        severity: InspectionSeverity.good,
        notes: 'Oil level optimal (5W-30), no valve cover gasket leaks detected.',
        estimatedCost: 0.0,
        relativePos: Offset(0.28, 0.45),
      ),
      'front_brake': const VehicleInspectionPoint(
        id: 'front_brake',
        nameEn: 'Front Left Ceramic Brake Pads',
        nameAr: 'تيل الفرامل الأمامي الأيسر',
        layer: AutoInspectionLayer.wheelsBrakes,
        severity: InspectionSeverity.attention,
        notes: 'Brake pad thickness at 3.5mm (Service threshold is 3.0mm).',
        estimatedCost: 650.0,
        relativePos: Offset(0.35, 0.72),
      ),
      'tire_tread': const VehicleInspectionPoint(
        id: 'tire_tread',
        nameEn: 'Rear Right Tire Tread & Camber',
        nameAr: 'عمق مداس الإطار الخلفي والمحاذاة',
        layer: AutoInspectionLayer.wheelsBrakes,
        severity: InspectionSeverity.good,
        notes: 'Tread depth 6.2mm, uniform wear across tread blocks.',
        estimatedCost: 0.0,
        relativePos: Offset(0.68, 0.72),
      ),
      'exhaust_cat': const VehicleInspectionPoint(
        id: 'exhaust_cat',
        nameEn: 'Exhaust Flex Pipe & Catalytic Converter',
        nameAr: 'ماسورة العادم ودبة التلوث',
        layer: AutoInspectionLayer.undercarriage,
        severity: InspectionSeverity.good,
        notes: 'No exhaust soot leakage, hangers and flex joint intact.',
        estimatedCost: 0.0,
        relativePos: Offset(0.50, 0.55),
      ),
    };

    final initialVehicles = [
      VehicleDealershipRecord(
        id: 'car_bmw_m4',
        make: 'BMW',
        model: 'M4 Competition',
        year: 2024,
        vin: 'WBA33AY05PFP12948',
        bodyType: VehicleBodyType.sedan,
        paintColor: const Color(0xFF0284C7),
        priceEgp: 4850000.0,
        status: 'Showroom Floor',
        findings: Map.from(defaultFindings),
      ),
      VehicleDealershipRecord(
        id: 'car_defender_110',
        make: 'Land Rover',
        model: 'Defender 110 V8',
        year: 2024,
        vin: 'SALWR2V48PA109281',
        bodyType: VehicleBodyType.suv,
        paintColor: const Color(0xFF64748B),
        priceEgp: 6200000.0,
        status: 'Bay 1 Service',
        findings: {
          'front_brake': const VehicleInspectionPoint(
            id: 'front_brake',
            nameEn: 'Front Left Ceramic Brake Pads',
            nameAr: 'تيل الفرامل الأمامي الأيسر',
            layer: AutoInspectionLayer.wheelsBrakes,
            severity: InspectionSeverity.critical,
            notes: 'Heavy rotor grooving. Replace rotors and pads.',
            estimatedCost: 18500.0,
            relativePos: Offset(0.35, 0.72),
          ),
        },
      ),
      VehicleDealershipRecord(
        id: 'car_raptor_f150',
        make: 'Ford',
        model: 'F-150 Raptor 4x4',
        year: 2023,
        vin: '1FTFW1RG3PFA98210',
        bodyType: VehicleBodyType.truck,
        paintColor: const Color(0xFFF59E0B),
        priceEgp: 5400000.0,
        status: 'Showroom Ready',
        findings: Map.from(defaultFindings),
      ),
    ];

    _vehiclesNotifier = ValueNotifier<List<VehicleDealershipRecord>>(initialVehicles);
    _selectedVehicleIdNotifier = ValueNotifier<String>('car_bmw_m4');
    _layerNotifier = ValueNotifier<AutoInspectionLayer>(AutoInspectionLayer.all);
    _yawNotifier = ValueNotifier<double>(0.0);
    _pitchNotifier = ValueNotifier<double>(0.0);
    _activeLiftBayNotifier = ValueNotifier<int>(1);
    _isDropPinModeNotifier = ValueNotifier<bool>(false);
  }

  @override
  void dispose() {
    _vehiclesNotifier.dispose();
    _selectedVehicleIdNotifier.dispose();
    _layerNotifier.dispose();
    _yawNotifier.dispose();
    _pitchNotifier.dispose();
    _activeLiftBayNotifier.dispose();
    _isDropPinModeNotifier.dispose();
    super.dispose();
  }

  VehicleDealershipRecord get _currentVehicle {
    final list = _vehiclesNotifier.value;
    final selectedId = _selectedVehicleIdNotifier.value;
    return list.firstWhere(
      (v) => v.id == selectedId,
      orElse: () => list.isNotEmpty ? list.first : throw StateError('No vehicles in dealership'),
    );
  }

  void _updateCurrentVehicle(VehicleDealershipRecord updated) {
    final list = List<VehicleDealershipRecord>.from(_vehiclesNotifier.value);
    final idx = list.indexWhere((v) => v.id == updated.id);
    if (idx != -1) {
      list[idx] = updated;
      _vehiclesNotifier.value = list;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder<List<VehicleDealershipRecord>>(
      valueListenable: _vehiclesNotifier,
      builder: (context, vehicles, _) {
        return ValueListenableBuilder<String>(
          valueListenable: _selectedVehicleIdNotifier,
          builder: (context, selectedId, _) {
            final activeVehicle = _currentVehicle;

            return Container(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Header & Dealership Showroom Action Bar
                  _buildDealershipTopBar(activeVehicle, vehicles, isDark),
                  const SizedBox(height: 12),

                  // 2. Control Strip: Body Type, 3D Paint Finish, Service Bay & Pin Mode
                  _buildControlStrip(activeVehicle, isDark),
                  const SizedBox(height: 12),

                  // 3. Inspection Layer Chips
                  _buildLayerFilterChips(isDark),
                  const SizedBox(height: 12),

                  // 4. Interactive 3D Viewport
                  Expanded(
                    child: ValueListenableBuilder<AutoInspectionLayer>(
                      valueListenable: _layerNotifier,
                      builder: (context, activeLayer, _) {
                        return ValueListenableBuilder<double>(
                          valueListenable: _yawNotifier,
                          builder: (context, yaw, _) {
                            return ValueListenableBuilder<double>(
                              valueListenable: _pitchNotifier,
                              builder: (context, pitch, _) {
                                return ValueListenableBuilder<bool>(
                                  valueListenable: _isDropPinModeNotifier,
                                  builder: (context, isDropPin, _) {
                                    return _build3DViewport(
                                      activeVehicle: activeVehicle,
                                      activeLayer: activeLayer,
                                      yaw: yaw,
                                      pitch: pitch,
                                      isDark: isDark,
                                      isDropPin: isDropPin,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 5. Findings & Billable Items Bottom Tray
                  _buildDiagnosticFindingsTray(activeVehicle, isDark),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDealershipTopBar(VehicleDealershipRecord activeVehicle, List<VehicleDealershipRecord> vehicles, bool isDark) {
    final totalCost = activeVehicle.findings.values.fold<double>(0.0, (sum, p) => sum + p.estimatedCost);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activeVehicle.paintColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(activeVehicle.bodyType.icon, color: activeVehicle.paintColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    Text(
                      AppLanguage.tr(
                        'Automotive 3D Vehicle & Bay Inspection Pipeline',
                        'جناح فحص المركبات ثلاثي الأبعاد ورافعات الصيانة',
                      ),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        activeVehicle.status,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${activeVehicle.displayName} • VIN: ${activeVehicle.vin}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),

          // Total Repair / Valuation Metrics
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppLanguage.tr('Repair Estimate', 'تقدير الإصلاح'),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF10B981)),
                ),
                Text(
                  '${totalCost.toStringAsFixed(0)} EGP',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // "+ Add New Car" Button for Dealership Owner
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF3B82F6),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add_circle_outline, size: 16),
            label: Text(
              AppLanguage.tr('+ Add Car to 3D Showroom', '+ إضافة سيارة للمعرض 3D'),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            onPressed: () => _showAddNewVehicleDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildControlStrip(VehicleDealershipRecord activeVehicle, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vehicle Switcher Chips
            Text(
              AppLanguage.tr('Active Car:', 'السيارة الحالية:'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: _vehiclesNotifier.value.map((veh) {
                final isSelected = veh.id == activeVehicle.id;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: veh.paintColor, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 5),
                        Text(veh.displayName, style: const TextStyle(fontSize: 11)),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: veh.paintColor.withValues(alpha: 0.25),
                    onSelected: (sel) {
                      if (sel) {
                        _selectedVehicleIdNotifier.value = veh.id;
                      }
                    },
                  ),
                );
              }).toList(),
            ),
            IconButton(
              tooltip: AppLanguage.tr('Edit / Manage Car', 'تعديل بيانات السيارة'),
              icon: const Icon(Icons.edit_note, size: 20, color: Color(0xFF3B82F6)),
              onPressed: () => _showEditVehicleDialog(context, activeVehicle),
            ),
            const SizedBox(width: 8),

          // Paint Finish Color Picker
          Text(
            AppLanguage.tr('3D Paint:', 'طلاء 3D:'),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: _availablePaints.map((color) {
              final isPicked = activeVehicle.paintColor.toARGB32() == color.toARGB32();
              return InkWell(
                onTap: () {
                  _updateCurrentVehicle(activeVehicle.copyWith(paintColor: color));
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isPicked ? Colors.white : Colors.transparent,
                      width: 2,
                    ),
                    boxShadow: isPicked
                        ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4, spreadRadius: 1)]
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(width: 14),

          // Drop 3D Pin Button
          ValueListenableBuilder<bool>(
            valueListenable: _isDropPinModeNotifier,
            builder: (context, isDropPin, _) {
              return TextButton.icon(
                style: TextButton.styleFrom(
                  backgroundColor: isDropPin ? const Color(0xFFEF4444).withValues(alpha: 0.2) : Colors.transparent,
                  foregroundColor: isDropPin ? const Color(0xFFEF4444) : const Color(0xFF3B82F6),
                  visualDensity: VisualDensity.compact,
                ),
                icon: Icon(isDropPin ? Icons.location_on : Icons.add_location_alt_outlined, size: 14),
                label: Text(
                  isDropPin
                      ? AppLanguage.tr('Drop Mode Active', 'وضع الدبوس نشط')
                      : AppLanguage.tr('+ Add 3D Pin', '+ إضافة دبوس 3D'),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  _isDropPinModeNotifier.value = !_isDropPinModeNotifier.value;
                },
              );
            },
          ),
          const SizedBox(width: 4),

          // Reset 3D View
          TextButton.icon(
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              foregroundColor: const Color(0xFF3B82F6),
            ),
            icon: const Icon(Icons.rotate_left, size: 14),
            label: Text(
              AppLanguage.tr('Reset 3D', 'إعادة ضبط'),
              style: const TextStyle(fontSize: 11),
            ),
            onPressed: () {
              _yawNotifier.value = 0.0;
              _pitchNotifier.value = 0.0;
            },
          ),
        ],
      ),
    ),
  );
}

  Widget _buildLayerFilterChips(bool isDark) {
    return ValueListenableBuilder<AutoInspectionLayer>(
      valueListenable: _layerNotifier,
      builder: (context, activeLayer, _) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Text(
                AppLanguage.tr('Inspection Layers:', 'طبقات الفحص:'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              ...AutoInspectionLayer.values.map(
                (layer) {
                  final isSelected = activeLayer == layer;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        layer.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: const Color(0xFF3B82F6),
                      onSelected: (selected) {
                        if (selected) _layerNotifier.value = layer;
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _build3DViewport({
    required VehicleDealershipRecord activeVehicle,
    required AutoInspectionLayer activeLayer,
    required double yaw,
    required double pitch,
    required bool isDark,
    required bool isDropPin,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDropPin ? const Color(0xFFEF4444) : const Color(0xFF3B82F6).withValues(alpha: 0.3),
          width: isDropPin ? 2 : 1,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          final h = constraints.maxHeight;

          return GestureDetector(
            onPanUpdate: (details) {
              _yawNotifier.value = (_yawNotifier.value + details.delta.dx * 0.01).clamp(-1.0, 1.0);
              _pitchNotifier.value = (_pitchNotifier.value - details.delta.dy * 0.01).clamp(-0.5, 0.5);
            },
            onTapDown: (details) {
              if (isDropPin) {
                final relX = (details.localPosition.dx / w).clamp(0.05, 0.95);
                final relY = (details.localPosition.dy / h).clamp(0.05, 0.95);
                _promptAddNewFindingPin(Offset(relX, relY), activeVehicle);
                _isDropPinModeNotifier.value = false;
              }
            },
            child: Stack(
              children: [
                // 3D Chassis Painter
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _Vehicle3DChassisPainter(
                        bodyType: activeVehicle.bodyType,
                        paintColor: activeVehicle.paintColor,
                        activeLayer: activeLayer,
                        yaw: yaw,
                        pitch: pitch,
                        isDark: isDark,
                      ),
                    ),
                  ),
                ),

                // Interactive Inspection Hotspots
                ...activeVehicle.findings.values
                    .where((p) => activeLayer == AutoInspectionLayer.all || p.layer == activeLayer)
                    .map(
                      (point) => _buildHotspotMarker(point, w, h, activeVehicle),
                    ),

                // Guide overlay text
                Positioned(
                  bottom: 8,
                  left: 12,
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app_outlined, size: 12, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        isDropPin
                            ? AppLanguage.tr(
                                'Tap anywhere on the 3D car to place inspection pin',
                                'انقر في أي موضع على السيارة لتثبيت دبوس الفحص',
                              )
                            : AppLanguage.tr(
                                'Drag to rotate 3D • Tap pins to inspect & edit',
                                'اسحب للتدوير ثلاثي الأبعاد • انقر فوق الدبابيس للفحص والتعديل',
                              ),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isDropPin ? FontWeight.bold : FontWeight.normal,
                          color: isDropPin ? const Color(0xFFEF4444) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHotspotMarker(VehicleInspectionPoint point, double w, double h, VehicleDealershipRecord activeVehicle) {
    final x = w * point.relativePos.dx;
    final y = h * point.relativePos.dy;

    return Positioned(
      left: x - 16,
      top: y - 16,
      child: Tooltip(
        message: '${point.name}\n${point.notes}\n${point.estimatedCost.toStringAsFixed(0)} EGP',
        child: InkWell(
          onTap: () => _showInspectionDialog(point, activeVehicle),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: point.severity.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: point.severity.color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Icon(
                point.severity == InspectionSeverity.good
                    ? Icons.check
                    : (point.severity == InspectionSeverity.attention ? Icons.warning_amber_rounded : Icons.error_outline),
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showInspectionDialog(VehicleInspectionPoint point, VehicleDealershipRecord activeVehicle) {
    final noteController = TextEditingController(text: point.notes);
    final costController = TextEditingController(text: point.estimatedCost.toStringAsFixed(0));
    var selectedSeverity = point.severity;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: selectedSeverity.color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.assignment_turned_in_outlined, color: selectedSeverity.color, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      point.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      AppLanguage.tr('Condition Severity:', 'درجة الحالة:'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: InspectionSeverity.values.map(
                        (sev) => ChoiceChip(
                          label: Text(sev.label, style: const TextStyle(fontSize: 11)),
                          selected: selectedSeverity == sev,
                          selectedColor: sev.color.withValues(alpha: 0.25),
                          checkmarkColor: sev.color,
                          onSelected: (sel) {
                            if (sel) setDialogState(() => selectedSeverity = sev);
                          },
                        ),
                      ).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: noteController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Technician Diagnostic Note', 'ملاحظة الفني التشخيصية'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Estimated Part & Labor Fee (EGP)', 'التكلفة التقديرية للقطعة والمصنعية'),
                        border: const OutlineInputBorder(),
                        suffixText: 'EGP',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء')),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
                  icon: const Icon(Icons.note_add_outlined, size: 16),
                  label: Text(AppLanguage.tr('Save & Add to Job Ticket', 'حفظ وإضافة لأمر الشغل')),
                  onPressed: () {
                    final updated = point.copyWith(
                      severity: selectedSeverity,
                      notes: noteController.text.trim(),
                      estimatedCost: double.tryParse(costController.text.trim()) ?? 0.0,
                    );

                    final map = Map<String, VehicleInspectionPoint>.from(activeVehicle.findings);
                    map[updated.id] = updated;
                    _updateCurrentVehicle(activeVehicle.copyWith(findings: map));

                    widget.onFindingAddedToTicket?.call(updated);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _promptAddNewFindingPin(Offset pos, VehicleDealershipRecord activeVehicle) {
    final titleController = TextEditingController();
    final noteController = TextEditingController();
    final costController = TextEditingController(text: '0');
    var selectedLayer = AutoInspectionLayer.exterior;
    var selectedSeverity = InspectionSeverity.attention;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(AppLanguage.tr('Place 3D Diagnostic Pin', 'تثبيت دبوس فحص 3D')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Component / Finding Name', 'اسم القطعة أو العطل المكتشف'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<AutoInspectionLayer>(
                      initialValue: selectedLayer,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('System Layer', 'نظام الفحص'),
                        border: const OutlineInputBorder(),
                      ),
                      items: AutoInspectionLayer.values.where((l) => l != AutoInspectionLayer.all).map((l) {
                        return DropdownMenuItem(value: l, child: Text(l.label, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedLayer = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<InspectionSeverity>(
                      initialValue: selectedSeverity,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Severity Level', 'درجة الخطورة'),
                        border: const OutlineInputBorder(),
                      ),
                      items: InspectionSeverity.values.map((s) {
                        return DropdownMenuItem(value: s, child: Text(s.label, style: const TextStyle(fontSize: 12)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedSeverity = val);
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteController,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Diagnostic Note', 'الملاحظة الفنية'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: costController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Estimated Cost (EGP)', 'التكلفة التقديرية (ج.م)'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;
                    final cost = double.tryParse(costController.text.trim()) ?? 0.0;
                    final newPin = VehicleInspectionPoint(
                      id: 'pin_${DateTime.now().millisecondsSinceEpoch}',
                      nameEn: title,
                      nameAr: title,
                      layer: selectedLayer,
                      severity: selectedSeverity,
                      notes: noteController.text.trim(),
                      estimatedCost: cost,
                      relativePos: pos,
                    );

                    final map = Map<String, VehicleInspectionPoint>.from(activeVehicle.findings);
                    map[newPin.id] = newPin;
                    _updateCurrentVehicle(activeVehicle.copyWith(findings: map));
                    Navigator.of(ctx).pop();
                  },
                  child: Text(AppLanguage.tr('Add Pin', 'إضافة الدبوس')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddNewVehicleDialog(BuildContext context) {
    final makeController = TextEditingController(text: 'Porsche');
    final modelController = TextEditingController(text: '911 Carrera 4S');
    final yearController = TextEditingController(text: '2024');
    final vinController = TextEditingController(text: 'WP0AB2A99NS192837');
    final priceController = TextEditingController(text: '7500000');
    var selectedBody = VehicleBodyType.coupe;
    var selectedPaint = const Color(0xFFE11D48);

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.directions_car, color: Color(0xFF3B82F6)),
                  const SizedBox(width: 8),
                  Text(AppLanguage.tr('Add New Car to 3D Showroom', 'إضافة سيارة جديدة لمعرض 3D')),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: makeController,
                            decoration: InputDecoration(
                              labelText: AppLanguage.tr('Make (e.g. BMW)', 'الماركة'),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: modelController,
                            decoration: InputDecoration(
                              labelText: AppLanguage.tr('Model (e.g. M4)', 'الموديل'),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: yearController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: AppLanguage.tr('Year', 'سنة الصنع'),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: priceController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            decoration: InputDecoration(
                              labelText: AppLanguage.tr('Price (EGP)', 'السعر (ج.م)'),
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: vinController,
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('VIN Number (17 Chars)', 'رقم الشاسيه VIN'),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLanguage.tr('3D Body Type:', 'طراز الهيكل ثلاثي الأبعاد:'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: VehicleBodyType.values.map((bt) {
                        return ChoiceChip(
                          avatar: Icon(bt.icon, size: 14),
                          label: Text(bt.label, style: const TextStyle(fontSize: 11)),
                          selected: selectedBody == bt,
                          onSelected: (sel) {
                            if (sel) setDialogState(() => selectedBody = bt);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLanguage.tr('3D Exterior Paint Finish:', 'لون الطلاء ثلاثي الأبعاد:'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: _availablePaints.map((color) {
                        final isPicked = selectedPaint.toARGB32() == color.toARGB32();
                        return InkWell(
                          onTap: () => setDialogState(() => selectedPaint = color),
                          child: Container(
                            margin: const EdgeInsets.only(right: 6),
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isPicked ? Colors.white : Colors.transparent,
                                width: 2,
                              ),
                              boxShadow: isPicked
                                  ? [BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4, spreadRadius: 1)]
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                  onPressed: () {
                    final make = makeController.text.trim();
                    final model = modelController.text.trim();
                    final year = int.tryParse(yearController.text.trim()) ?? 2024;
                    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
                    final vin = vinController.text.trim();
                    if (make.isEmpty || model.isEmpty) return;

                    final newVehicle = VehicleDealershipRecord(
                      id: 'car_${DateTime.now().millisecondsSinceEpoch}',
                      make: make,
                      model: model,
                      year: year,
                      vin: vin.isNotEmpty ? vin : 'VIN${DateTime.now().millisecondsSinceEpoch}',
                      bodyType: selectedBody,
                      paintColor: selectedPaint,
                      priceEgp: price,
                      status: 'Showroom Floor',
                      findings: {},
                    );

                    final updatedList = List<VehicleDealershipRecord>.from(_vehiclesNotifier.value)..add(newVehicle);
                    _vehiclesNotifier.value = updatedList;
                    _selectedVehicleIdNotifier.value = newVehicle.id;

                    Navigator.of(ctx).pop();
                  },
                  child: Text(AppLanguage.tr('Add Vehicle to Showroom', 'إضافة السيارة للمعرض')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditVehicleDialog(BuildContext context, VehicleDealershipRecord vehicle) {
    final makeController = TextEditingController(text: vehicle.make);
    final modelController = TextEditingController(text: vehicle.model);
    final yearController = TextEditingController(text: vehicle.year.toString());
    final priceController = TextEditingController(text: vehicle.priceEgp.toStringAsFixed(0));
    final vinController = TextEditingController(text: vehicle.vin);

    VehicleBodyType selectedBody = vehicle.bodyType;
    Color selectedPaint = vehicle.paintColor;
    String selectedStatus = vehicle.status;

    final statuses = [
      'Showroom Floor',
      'In Service Bay',
      'Reserved',
      'Sold',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              actionsAlignment: MainAxisAlignment.spaceBetween,
              title: Row(
                children: [
                  const Icon(Icons.edit_note, color: Color(0xFF3B82F6), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Edit Car Specs & Showroom Status', 'تعديل بيانات وحالة السيارة'),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              content: SizedBox(
                width: 480,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: makeController,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Make / Brand', 'الشركة المصنعة'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: modelController,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Model', 'الموديل'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: yearController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Year', 'سنة الصنع'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: priceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppLanguage.tr('Price (EGP)', 'السعر (ج.م)'),
                                border: const OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: vinController,
                        decoration: InputDecoration(
                          labelText: AppLanguage.tr('VIN Number', 'رقم الشاسيه VIN'),
                          border: const OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLanguage.tr('Showroom Status:', 'حالة السيارة:'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: statuses.map((st) {
                          final isSel = selectedStatus == st;
                          return ChoiceChip(
                            label: Text(st, style: const TextStyle(fontSize: 11)),
                            selected: isSel,
                            selectedColor: const Color(0xFF3B82F6),
                            onSelected: (sel) {
                              if (sel) setDialogState(() => selectedStatus = st);
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLanguage.tr('3D Body Type:', 'طراز الهيكل ثلاثي الأبعاد:'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        children: VehicleBodyType.values.map((bt) {
                          return ChoiceChip(
                            avatar: Icon(bt.icon, size: 14),
                            label: Text(bt.label, style: const TextStyle(fontSize: 11)),
                            selected: selectedBody == bt,
                            selectedColor: const Color(0xFF3B82F6),
                            onSelected: (sel) {
                              if (sel) setDialogState(() => selectedBody = bt);
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                // Delete Car Button
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(AppLanguage.tr('Delete Car', 'حذف السيارة')),
                  onPressed: () {
                    final currentVehicles = List<VehicleDealershipRecord>.from(_vehiclesNotifier.value);
                    if (currentVehicles.length <= 1) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(AppLanguage.tr(
                            'Cannot delete the only car in showroom!',
                            'لا يمكن حذف السيارة الوحيدة في المعرض!',
                          )),
                          backgroundColor: const Color(0xFFEF4444),
                        ),
                      );
                      return;
                    }

                    currentVehicles.removeWhere((v) => v.id == vehicle.id);
                    _vehiclesNotifier.value = currentVehicles;
                    _selectedVehicleIdNotifier.value = currentVehicles.first.id;

                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Car removed from 3D showroom!',
                          'تم حذف السيارة من المعرض 3D!',
                        )),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  },
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء')),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
                  onPressed: () {
                    final make = makeController.text.trim();
                    final model = modelController.text.trim();
                    final year = int.tryParse(yearController.text.trim()) ?? vehicle.year;
                    final price = double.tryParse(priceController.text.trim()) ?? vehicle.priceEgp;
                    final vin = vinController.text.trim();
                    if (make.isEmpty || model.isEmpty) return;

                    final updated = vehicle.copyWith(
                      make: make,
                      model: model,
                      year: year,
                      priceEgp: price,
                      vin: vin.isNotEmpty ? vin : vehicle.vin,
                      bodyType: selectedBody,
                      paintColor: selectedPaint,
                      status: selectedStatus,
                    );

                    final currentVehicles = List<VehicleDealershipRecord>.from(_vehiclesNotifier.value);
                    final idx = currentVehicles.indexWhere((v) => v.id == vehicle.id);
                    if (idx != -1) {
                      currentVehicles[idx] = updated;
                      _vehiclesNotifier.value = currentVehicles;
                    }

                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Car specs updated in 3D showroom!',
                          'تم تحديث مواصفات السيارة في المعرض 3D!',
                        )),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  child: Text(AppLanguage.tr('Save Changes', 'حفظ التعديلات')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDiagnosticFindingsTray(VehicleDealershipRecord activeVehicle, bool isDark) {
    final findings = activeVehicle.findings;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLanguage.tr('Active Inspection Findings & Billable Items:', 'الملاحظات التشخيصية النشطة والبنود القابلة للفوترة:'),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Text(
                '${findings.length} ${AppLanguage.tr('Points Evaluated', 'نقاط تم فحصها')}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (findings.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                AppLanguage.tr(
                  'No defects detected. Click "+ Add 3D Pin" or tap model to log inspection item.',
                  'لا توجد عيوب مسجلة. انقر فوق "+ إضافة دبوس 3D" أو انقر على المجسم لإضافة بند فحص.',
                ),
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: findings.values.map(
                (p) => InkWell(
                  onTap: () => _showInspectionDialog(p, activeVehicle),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: p.severity.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: p.severity.color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: p.severity.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          p.name,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                        if (p.estimatedCost > 0) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(${p.estimatedCost.toStringAsFixed(0)} EGP)',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: p.severity.color),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ).toList(),
            ),
        ],
      ),
    );
  }
}

/// Custom 3D Vehicle Chassis & Lift Bay Painter with Dynamic Custom Paint Finish
class _Vehicle3DChassisPainter extends CustomPainter {
  final VehicleBodyType bodyType;
  final Color paintColor;
  final AutoInspectionLayer activeLayer;
  final double yaw;
  final double pitch;
  final bool isDark;

  _Vehicle3DChassisPainter({
    required this.bodyType,
    required this.paintColor,
    required this.activeLayer,
    required this.yaw,
    required this.pitch,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Draw Lift Bay Workshop Ground Floor Grid
    final gridPaint = Paint()
      ..color = (isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1)).withValues(alpha: 0.4)
      ..strokeWidth = 1.0;

    for (double i = -120; i <= 120; i += 30) {
      canvas.drawLine(
        Offset(cx + i * 1.5, cy + 90 + pitch * 20),
        Offset(cx + i * 2.5, size.height - 15),
        gridPaint,
      );
    }

    // Draw Two-Post Hydraulic Lift Arms
    final liftPaint = Paint()
      ..color = const Color(0xFFEF4444).withValues(alpha: 0.75)
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // Left Lift Column
    canvas.drawLine(
      Offset(cx - 180 + yaw * 10, cy - 80),
      Offset(cx - 180 + yaw * 10, cy + 90),
      liftPaint,
    );
    // Right Lift Column
    canvas.drawLine(
      Offset(cx + 180 + yaw * 10, cy - 80),
      Offset(cx + 180 + yaw * 10, cy + 90),
      liftPaint,
    );

    // Lift Cradle Pads under vehicle
    final padPaint = Paint()
      ..color = const Color(0xFFF59E0B)
      ..strokeWidth = 4.0;
    canvas.drawLine(Offset(cx - 140, cy + 50 + pitch * 15), Offset(cx - 90, cy + 50 + pitch * 15), padPaint);
    canvas.drawLine(Offset(cx + 90, cy + 50 + pitch * 15), Offset(cx + 140, cy + 50 + pitch * 15), padPaint);

    // 3D Vehicle Silhouette with Dynamic Paint Color
    final carPaint = Paint()
      ..color = paintColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final carFillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          paintColor.withValues(alpha: 0.45),
          paintColor.withValues(alpha: 0.20),
          paintColor.withValues(alpha: 0.05),
        ],
      ).createShader(Rect.fromLTWH(cx - 200, cy - 80, 400, 160))
      ..style = PaintingStyle.fill;

    final path = Path();
    final offsetX = yaw * 50;
    final offsetY = pitch * 30;

    if (bodyType == VehicleBodyType.suv) {
      // SUV Silhouette
      path.moveTo(cx - 170 + offsetX, cy + 40 + offsetY); // Front bumper
      path.lineTo(cx - 160 + offsetX, cy + 10 + offsetY); // Grille
      path.lineTo(cx - 100 + offsetX, cy - 10 + offsetY); // Hood
      path.lineTo(cx - 40 + offsetX, cy - 65 + offsetY);  // Windshield
      path.lineTo(cx + 100 + offsetX, cy - 65 + offsetY); // Roof
      path.lineTo(cx + 150 + offsetX, cy - 20 + offsetY); // Rear tailgate
      path.lineTo(cx + 160 + offsetX, cy + 40 + offsetY); // Rear bumper
      path.close();
    } else if (bodyType == VehicleBodyType.truck) {
      // Pickup Truck Silhouette
      path.moveTo(cx - 180 + offsetX, cy + 40 + offsetY);
      path.lineTo(cx - 170 + offsetX, cy + 10 + offsetY);
      path.lineTo(cx - 90 + offsetX, cy - 15 + offsetY);
      path.lineTo(cx - 40 + offsetX, cy - 70 + offsetY);
      path.lineTo(cx + 40 + offsetX, cy - 70 + offsetY);
      path.lineTo(cx + 45 + offsetX, cy - 10 + offsetY); // Cab back window
      path.lineTo(cx + 170 + offsetX, cy - 10 + offsetY); // Truck bed
      path.lineTo(cx + 175 + offsetX, cy + 40 + offsetY);
      path.close();
    } else if (bodyType == VehicleBodyType.coupe) {
      // Fastback Coupe
      path.moveTo(cx - 180 + offsetX, cy + 40 + offsetY);
      path.lineTo(cx - 170 + offsetX, cy + 15 + offsetY);
      path.lineTo(cx - 90 + offsetX, cy + 8 + offsetY);   // Long low hood
      path.lineTo(cx - 30 + offsetX, cy - 40 + offsetY);  // Raked windshield
      path.lineTo(cx + 30 + offsetX, cy - 40 + offsetY);  // Short roof
      path.lineTo(cx + 140 + offsetX, cy + 10 + offsetY); // Swept fastback
      path.lineTo(cx + 170 + offsetX, cy + 15 + offsetY); // Spoiler deck
      path.lineTo(cx + 175 + offsetX, cy + 40 + offsetY);
      path.close();
    } else if (bodyType == VehicleBodyType.ev) {
      // Electric Vehicle (Aerodynamic Teardrop Canopy & Skateboard Battery)
      path.moveTo(cx - 180 + offsetX, cy + 40 + offsetY);
      path.quadraticBezierTo(cx - 175 + offsetX, cy + 10 + offsetY, cx - 120 + offsetX, cy - 8 + offsetY); // Seamless aero nose
      path.lineTo(cx - 40 + offsetX, cy - 58 + offsetY); // Sleek glass canopy
      path.lineTo(cx + 60 + offsetX, cy - 58 + offsetY);
      path.quadraticBezierTo(cx + 140 + offsetX, cy - 20 + offsetY, cx + 175 + offsetX, cy + 25 + offsetY); // Kammback aero tail
      path.lineTo(cx + 175 + offsetX, cy + 40 + offsetY);
      path.close();

      // Battery Skateboard Pack underneath floor
      final batteryPaint = Paint()
        ..color = const Color(0xFF06B6D4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawRect(
        Rect.fromLTWH(cx - 100 + offsetX, cy + 36 + offsetY, 200, 7),
        batteryPaint,
      );
    } else {
      // Sedan Silhouette
      path.moveTo(cx - 180 + offsetX, cy + 40 + offsetY); // Front Bumper
      path.lineTo(cx - 170 + offsetX, cy + 15 + offsetY);
      path.lineTo(cx - 100 + offsetX, cy + 5 + offsetY);  // Front Hood
      path.lineTo(cx - 40 + offsetX, cy - 50 + offsetY);  // Windshield
      path.lineTo(cx + 50 + offsetX, cy - 50 + offsetY);  // Roof
      path.lineTo(cx + 110 + offsetX, cy + 5 + offsetY);  // Rear Glass
      path.lineTo(cx + 170 + offsetX, cy + 15 + offsetY); // Trunk
      path.lineTo(cx + 175 + offsetX, cy + 40 + offsetY); // Rear Bumper
      path.close();
    }

    canvas.drawPath(path, carFillPaint);
    canvas.drawPath(path, carPaint);

    // Front and Rear Wheels & Alloy Rims
    final wheelPaint = Paint()
      ..color = isDark ? const Color(0xFF475569) : const Color(0xFF334155)
      ..style = PaintingStyle.fill;

    final rimPaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final caliperPaint = Paint()
      ..color = const Color(0xFFEF4444)
      ..style = PaintingStyle.fill;

    final frontWheelCenter = Offset(cx - 110 + offsetX * 0.8, cy + 40 + offsetY * 0.8);
    final rearWheelCenter = Offset(cx + 110 + offsetX * 0.8, cy + 40 + offsetY * 0.8);

    // Front Wheel
    canvas.drawCircle(frontWheelCenter, 22, wheelPaint);
    canvas.drawCircle(frontWheelCenter, 14, rimPaint);
    canvas.drawRect(Rect.fromLTWH(frontWheelCenter.dx - 12, frontWheelCenter.dy - 10, 8, 12), caliperPaint);

    // Rear Wheel
    canvas.drawCircle(rearWheelCenter, 22, wheelPaint);
    canvas.drawCircle(rearWheelCenter, 14, rimPaint);
    canvas.drawRect(Rect.fromLTWH(rearWheelCenter.dx - 12, rearWheelCenter.dy - 10, 8, 12), caliperPaint);

    // Powertrain & Engine Block Outline (when active or all)
    if (activeLayer == AutoInspectionLayer.all || activeLayer == AutoInspectionLayer.powertrain) {
      final enginePaint = Paint()
        ..color = const Color(0xFFF59E0B)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      final engineRect = Rect.fromCenter(
        center: Offset(cx - 100 + offsetX, cy + 15 + offsetY),
        width: 48,
        height: 32,
      );
      canvas.drawRRect(RRect.fromRectAndRadius(engineRect, const Radius.circular(4)), enginePaint);
      // Engine cross-hatch intake manifold
      canvas.drawLine(engineRect.topLeft, engineRect.bottomRight, enginePaint..strokeWidth = 1.0);
      canvas.drawLine(engineRect.topRight, engineRect.bottomLeft, enginePaint);
    }

    // Exhaust & Undercarriage System (when active or all)
    if (activeLayer == AutoInspectionLayer.all || activeLayer == AutoInspectionLayer.undercarriage) {
      final exhaustPaint = Paint()
        ..color = const Color(0xFF10B981)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      final exhaustPath = Path()
        ..moveTo(cx - 80 + offsetX, cy + 30 + offsetY)
        ..lineTo(cx + 30 + offsetX, cy + 32 + offsetY) // Catalytic converter
        ..lineTo(cx + 140 + offsetX, cy + 35 + offsetY) // Muffler
        ..lineTo(cx + 175 + offsetX, cy + 35 + offsetY); // Tailpipe tip
      canvas.drawPath(exhaustPath, exhaustPaint);
      // Muffler can
      canvas.drawRect(Rect.fromCenter(center: Offset(cx + 120 + offsetX, cy + 35 + offsetY), width: 24, height: 10), exhaustPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _Vehicle3DChassisPainter oldDelegate) {
    return oldDelegate.bodyType != bodyType ||
        oldDelegate.paintColor != paintColor ||
        oldDelegate.activeLayer != activeLayer ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.isDark != isDark;
  }
}
