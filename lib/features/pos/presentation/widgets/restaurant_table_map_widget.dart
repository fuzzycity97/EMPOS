import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_language.dart';

enum TableStatus { available, occupied, billed, reserved }

enum TableShape { round, square, booth, bar }

class RestaurantTable {
  final String id;
  final String label;
  final int capacity;
  final String section;
  final Offset position;
  final TableStatus status;
  final TableShape shape;
  final double currentBill;
  final String? serverName;
  final String? activeTabId;

  const RestaurantTable({
    required this.id,
    required this.label,
    required this.capacity,
    required this.section,
    required this.position,
    this.status = TableStatus.available,
    this.shape = TableShape.square,
    this.currentBill = 0.0,
    this.serverName,
    this.activeTabId,
  });

  RestaurantTable copyWith({
    String? id,
    String? label,
    int? capacity,
    String? section,
    Offset? position,
    TableStatus? status,
    TableShape? shape,
    double? currentBill,
    String? serverName,
    String? activeTabId,
  }) {
    return RestaurantTable(
      id: id ?? this.id,
      label: label ?? this.label,
      capacity: capacity ?? this.capacity,
      section: section ?? this.section,
      position: position ?? this.position,
      status: status ?? this.status,
      shape: shape ?? this.shape,
      currentBill: currentBill ?? this.currentBill,
      serverName: serverName ?? this.serverName,
      activeTabId: activeTabId ?? this.activeTabId,
    );
  }
}

/// 2D & 3D Interactive, Editable Restaurant Floor Plan & Table Management Canvas
class RestaurantTableMapWidget extends StatelessWidget {
  final ValueNotifier<List<RestaurantTable>> tablesNotifier;
  final ValueNotifier<String> activeSectionNotifier;
  final ValueNotifier<RestaurantTable?> selectedTableNotifier;
  final ValueNotifier<int> viewModeNotifier; // 0: 2D Floor Plan, 1: 3D Isometric Dining Hall
  final ValueNotifier<double> yawNotifier;
  final ValueNotifier<double> pitchNotifier;
  final Function(RestaurantTable table)? onTableSelected;
  final Function(RestaurantTable table)? onParkTabToTable;
  final TransformationController transformationController;

  RestaurantTableMapWidget({
    super.key,
    ValueNotifier<List<RestaurantTable>>? tablesNotifier,
    ValueNotifier<String>? activeSectionNotifier,
    ValueNotifier<RestaurantTable?>? selectedTableNotifier,
    ValueNotifier<int>? viewModeNotifier,
    ValueNotifier<double>? yawNotifier,
    ValueNotifier<double>? pitchNotifier,
    TransformationController? transformationController,
    this.onTableSelected,
    this.onParkTabToTable,
  })  : tablesNotifier = tablesNotifier ??
            ValueNotifier<List<RestaurantTable>>(defaultTables),
        activeSectionNotifier =
            activeSectionNotifier ?? ValueNotifier<String>('Main Dining'),
        selectedTableNotifier =
            selectedTableNotifier ?? ValueNotifier<RestaurantTable?>(null),
        viewModeNotifier = viewModeNotifier ?? ValueNotifier<int>(0),
        yawNotifier = yawNotifier ?? ValueNotifier<double>(0.0),
        pitchNotifier = pitchNotifier ?? ValueNotifier<double>(0.0),
        transformationController =
            transformationController ?? TransformationController();

  static const List<RestaurantTable> defaultTables = [
    RestaurantTable(
      id: 'T1',
      label: 'Table 1',
      capacity: 4,
      section: 'Main Dining',
      position: Offset(100, 100),
      status: TableStatus.available,
      shape: TableShape.round,
    ),
    RestaurantTable(
      id: 'T2',
      label: 'Table 2',
      capacity: 2,
      section: 'Main Dining',
      position: Offset(260, 100),
      status: TableStatus.occupied,
      shape: TableShape.square,
      currentBill: 345.50,
      serverName: 'Ahmed K.',
      activeTabId: 'TAB-104',
    ),
    RestaurantTable(
      id: 'T3',
      label: 'Table 3',
      capacity: 6,
      section: 'Main Dining',
      position: Offset(420, 100),
      status: TableStatus.billed,
      shape: TableShape.square,
      currentBill: 720.00,
      serverName: 'Sara M.',
      activeTabId: 'TAB-108',
    ),
    RestaurantTable(
      id: 'T4',
      label: 'Table 4',
      capacity: 4,
      section: 'Main Dining',
      position: Offset(100, 260),
      status: TableStatus.reserved,
      shape: TableShape.round,
      serverName: 'VIP Party (8:00 PM)',
    ),
    RestaurantTable(
      id: 'T5',
      label: 'Booth 5',
      capacity: 6,
      section: 'Main Dining',
      position: Offset(260, 260),
      status: TableStatus.available,
      shape: TableShape.booth,
    ),
    RestaurantTable(
      id: 'T6',
      label: 'Booth 6',
      capacity: 6,
      section: 'Main Dining',
      position: Offset(420, 260),
      status: TableStatus.occupied,
      shape: TableShape.booth,
      currentBill: 512.00,
      serverName: 'Ahmed K.',
      activeTabId: 'TAB-115',
    ),
    RestaurantTable(
      id: 'P1',
      label: 'Patio 1',
      capacity: 4,
      section: 'Patio & Terrace',
      position: Offset(120, 120),
      status: TableStatus.available,
      shape: TableShape.round,
    ),
    RestaurantTable(
      id: 'P2',
      label: 'Patio 2',
      capacity: 4,
      section: 'Patio & Terrace',
      position: Offset(300, 120),
      status: TableStatus.occupied,
      shape: TableShape.square,
      currentBill: 190.00,
      serverName: 'Tarek E.',
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
        children: [
          // ── HEADER & TOOLBAR ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(AppDimensions.space12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(LucideIcons.layoutGrid, color: AppColors.primary, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Restaurant Visual Floor Plan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // 2D vs 3D Floor Switcher
                  ValueListenableBuilder<int>(
                    valueListenable: viewModeNotifier,
                    builder: (context, viewMode, _) {
                      return SegmentedButton<int>(
                        segments: [
                          ButtonSegment<int>(
                            value: 0,
                            icon: const Icon(Icons.grid_view, size: 14),
                            label: Text(AppLanguage.tr('2D Layout', 'مخطط 2D')),
                          ),
                          ButtonSegment<int>(
                            value: 1,
                            icon: const Icon(Icons.view_in_ar, size: 14),
                            label: Text(AppLanguage.tr('3D Dining Hall', 'صالة الطعام 3D')),
                          ),
                        ],
                        selected: {viewMode},
                        onSelectionChanged: (selected) {
                          viewModeNotifier.value = selected.first;
                        },
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // "+ Add Table" Button for Restaurant Manager
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    icon: const Icon(Icons.add_circle, size: 14),
                    label: Text(
                      AppLanguage.tr('+ Add Table', '+ إضافة طاولة'),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => _showAddTableDialog(context),
                  ),
                  const SizedBox(width: 12),

                  // Section Tabs
                  ValueListenableBuilder<String>(
                    valueListenable: activeSectionNotifier,
                    builder: (context, activeSection, _) {
                      return Row(
                        children: ['Main Dining', 'Patio & Terrace', 'Bar Lounge'].map((sec) {
                          final isActive = sec == activeSection;
                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: ChoiceChip(
                              label: Text(sec, style: TextStyle(fontSize: 11, color: isActive ? Colors.white : AppColors.textSecondaryDark)),
                              selected: isActive,
                              selectedColor: AppColors.primary,
                              backgroundColor: AppColors.surfaceElevatedDark,
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              onSelected: (_) => activeSectionNotifier.value = sec,
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Reset Zoom & Angle
                  IconButton(
                    tooltip: 'Reset Zoom & Center',
                    icon: const Icon(LucideIcons.maximize2, size: 16, color: AppColors.textSecondaryDark),
                    onPressed: () {
                      transformationController.value = Matrix4.identity();
                      yawNotifier.value = 0.0;
                      pitchNotifier.value = 0.0;
                    },
                  ),
                  const SizedBox(width: 8),

                  // Legend
                  _buildLegendItem('Available', AppColors.success),
                  const SizedBox(width: 8),
                  _buildLegendItem('Occupied', AppColors.primary),
                  const SizedBox(width: 8),
                  _buildLegendItem('Billed', AppColors.warning),
                  const SizedBox(width: 8),
                  _buildLegendItem('Reserved', AppColors.error),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          // ── INTERACTIVE CANVAS: 2D OR 3D ──────────────────────────────────
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: viewModeNotifier,
              builder: (context, viewMode, _) {
                if (viewMode == 1) {
                  return _build3DIsometricDiningHall(context);
                }
                return _build2DFloorPlan(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 2D Interactive Floor Plan
  Widget _build2DFloorPlan(BuildContext context) {
    return ClipRect(
      child: InteractiveViewer(
        transformationController: transformationController,
        boundaryMargin: const EdgeInsets.all(500),
        minScale: 0.5,
        maxScale: 2.5,
        child: Container(
          width: 1200,
          height: 900,
          decoration: const BoxDecoration(
            color: Color(0xFF0F172A),
          ),
          child: ValueListenableBuilder<String>(
            valueListenable: activeSectionNotifier,
            builder: (context, activeSection, _) {
              return ValueListenableBuilder<List<RestaurantTable>>(
                valueListenable: tablesNotifier,
                builder: (context, tables, _) {
                  final filteredTables = tables.where((t) => t.section == activeSection).toList();

                  return Stack(
                    children: filteredTables.map((table) {
                      return Positioned(
                        left: table.position.dx,
                        top: table.position.dy,
                        child: GestureDetector(
                          onPanUpdate: (details) {
                            final currentList = List<RestaurantTable>.from(tablesNotifier.value);
                            final idx = currentList.indexWhere((t) => t.id == table.id);
                            if (idx != -1) {
                              currentList[idx] = table.copyWith(
                                position: Offset(
                                  (table.position.dx + details.delta.dx).clamp(20, 1100),
                                  (table.position.dy + details.delta.dy).clamp(20, 800),
                                ),
                              );
                              tablesNotifier.value = currentList;
                            }
                          },
                          onTap: () {
                            selectedTableNotifier.value = table;
                            onTableSelected?.call(table);
                          },
                          child: _buildTableCard(context, table),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // 3D Isometric Dining Hall
  Widget _build3DIsometricDiningHall(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: activeSectionNotifier,
      builder: (context, activeSection, _) {
        return ValueListenableBuilder<List<RestaurantTable>>(
          valueListenable: tablesNotifier,
          builder: (context, tables, _) {
            final sectionTables = tables.where((t) => t.section == activeSection).toList();

            return ValueListenableBuilder<double>(
              valueListenable: yawNotifier,
              builder: (context, yaw, _) {
                return ValueListenableBuilder<double>(
                  valueListenable: pitchNotifier,
                  builder: (context, pitch, _) {
                    return Container(
                      color: const Color(0xFF090D16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return GestureDetector(
                            onPanUpdate: (details) {
                              yawNotifier.value = (yawNotifier.value + details.delta.dx * 0.005).clamp(-0.8, 0.8);
                              pitchNotifier.value = (pitchNotifier.value - details.delta.dy * 0.005).clamp(-0.4, 0.4);
                            },
                            child: Stack(
                              children: [
                                // 3D Isometric Floor Grid Painter
                                Positioned.fill(
                                  child: RepaintBoundary(
                                    child: CustomPaint(
                                      painter: _RestaurantFloor3DPainter(
                                        tables: sectionTables,
                                        yaw: yaw,
                                        pitch: pitch,
                                        activeSection: activeSection,
                                      ),
                                    ),
                                  ),
                                ),

                                // Interactive 3D Table Cards / Hotspots
                                ...sectionTables.map((table) {
                                  final normX = (table.position.dx / 1200.0).clamp(0.1, 0.9);
                                  final normY = (table.position.dy / 900.0).clamp(0.1, 0.9);

                                  final isoX = constraints.maxWidth * normX + yaw * 60;
                                  final isoY = constraints.maxHeight * normY + pitch * 40;

                                  return Positioned(
                                    left: (isoX - 65).clamp(10, constraints.maxWidth - 140),
                                    top: (isoY - 45).clamp(10, constraints.maxHeight - 100),
                                    child: GestureDetector(
                                      onPanUpdate: (details) {
                                        final currentList = List<RestaurantTable>.from(tablesNotifier.value);
                                        final idx = currentList.indexWhere((t) => t.id == table.id);
                                        if (idx != -1) {
                                          currentList[idx] = table.copyWith(
                                            position: Offset(
                                              (table.position.dx + details.delta.dx * 2).clamp(50, 1100),
                                              (table.position.dy + details.delta.dy * 2).clamp(50, 800),
                                            ),
                                          );
                                          tablesNotifier.value = currentList;
                                        }
                                      },
                                      onTap: () {
                                        selectedTableNotifier.value = table;
                                        onTableSelected?.call(table);
                                      },
                                      child: _buildTableCard(context, table),
                                    ),
                                  );
                                }),

                                // 3D Navigation Guide
                                Positioned(
                                  bottom: 10,
                                  left: 14,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.rotate_90_degrees_ccw, size: 12, color: Color(0xFFF59E0B)),
                                        const SizedBox(width: 6),
                                        Text(
                                          AppLanguage.tr(
                                            'Drag to rotate 3D Isometric View • Drag tables to rearrange layout',
                                            'اسحب لتدوير المنظور ثلاثي الأبعاد • اسحب الطاولات لإعادة الترتيب',
                                          ),
                                          style: const TextStyle(fontSize: 10, color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  void _showAddTableDialog(BuildContext context) {
    final labelController = TextEditingController(text: 'Table ${tablesNotifier.value.length + 1}');
    final capacityController = TextEditingController(text: '4');
    var selectedShape = TableShape.round;
    var selectedSection = activeSectionNotifier.value;
    var selectedStatus = TableStatus.available;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevatedDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.table_restaurant, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Add New Table to 3D Floor', 'إضافة طاولة جديدة لصالة الطعام 3D'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: labelController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Table Label / Number', 'اسم أو رقم الطاولة'),
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Guest Seating Capacity', 'عدد المقاعد'),
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSection,
                      dropdownColor: AppColors.surfaceElevatedDark,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Dining Section', 'قسم الصالة'),
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                      ),
                      items: ['Main Dining', 'Patio & Terrace', 'Bar Lounge'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedSection = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLanguage.tr('Table Shape:', 'شكل الطاولة:'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: TableShape.values.map((shape) {
                        final isSelected = selectedShape == shape;
                        return ChoiceChip(
                          label: Text(shape.name.toUpperCase(), style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF59E0B),
                          onSelected: (sel) {
                            if (sel) setDialogState(() => selectedShape = shape);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLanguage.tr('Initial Status:', 'الحالة المبدئية:'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: TableStatus.values.map((status) {
                        final isSelected = selectedStatus == status;
                        return ChoiceChip(
                          label: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          onSelected: (sel) {
                            if (sel) setDialogState(() => selectedStatus = status);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                  onPressed: () {
                    final label = labelController.text.trim();
                    final capacity = int.tryParse(capacityController.text.trim()) ?? 4;
                    if (label.isEmpty) return;

                    final newTable = RestaurantTable(
                      id: 'tbl_${DateTime.now().millisecondsSinceEpoch}',
                      label: label,
                      capacity: capacity,
                      section: selectedSection,
                      position: const Offset(200, 200),
                      status: selectedStatus,
                      shape: selectedShape,
                    );

                    final currentList = List<RestaurantTable>.from(tablesNotifier.value)..add(newTable);
                    tablesNotifier.value = currentList;
                    activeSectionNotifier.value = selectedSection;

                    Navigator.of(ctx).pop();
                  },
                  child: Text(
                    AppLanguage.tr('Add Table', 'إضافة الطاولة'),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditTableDialog(BuildContext context, RestaurantTable table) {
    final labelController = TextEditingController(text: table.label);
    final capacityController = TextEditingController(text: table.capacity.toString());
    var selectedShape = table.shape;
    var selectedSection = table.section;
    var selectedStatus = table.status;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.surfaceElevatedDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text(
                    AppLanguage.tr('Edit Table & Status', 'تعديل بيانات وحالة الطاولة'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: labelController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Table Label / Number', 'اسم أو رقم الطاولة'),
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: capacityController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Guest Seating Capacity', 'عدد المقاعد'),
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedSection,
                      dropdownColor: AppColors.surfaceElevatedDark,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: AppLanguage.tr('Dining Section', 'قسم الصالة'),
                        labelStyle: const TextStyle(color: Colors.white70),
                        border: const OutlineInputBorder(),
                      ),
                      items: ['Main Dining', 'Patio & Terrace', 'Bar Lounge'].map((s) {
                        return DropdownMenuItem(value: s, child: Text(s));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setDialogState(() => selectedSection = val);
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLanguage.tr('Table Shape:', 'شكل الطاولة:'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: TableShape.values.map((shape) {
                        final isSelected = selectedShape == shape;
                        return ChoiceChip(
                          label: Text(shape.name.toUpperCase(), style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: const Color(0xFFF59E0B),
                          onSelected: (sel) {
                            if (sel) setDialogState(() => selectedShape = shape);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLanguage.tr('Status:', 'الحالة:'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: TableStatus.values.map((status) {
                        final isSelected = selectedStatus == status;
                        return ChoiceChip(
                          label: Text(status.name.toUpperCase(), style: const TextStyle(fontSize: 11)),
                          selected: isSelected,
                          selectedColor: AppColors.primary,
                          onSelected: (sel) {
                            if (sel) setDialogState(() => selectedStatus = status);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444)),
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: Text(AppLanguage.tr('Delete Table', 'حذف الطاولة')),
                  onPressed: () {
                    final current = List<RestaurantTable>.from(tablesNotifier.value);
                    current.removeWhere((t) => t.id == table.id);
                    tablesNotifier.value = current;
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Table removed from dining floor!',
                          'تم حذف الطاولة من صالة الطعام!',
                        )),
                        backgroundColor: const Color(0xFFEF4444),
                      ),
                    );
                  },
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: Text(AppLanguage.tr('Cancel', 'إلغاء'), style: const TextStyle(color: Colors.white70)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF59E0B)),
                  onPressed: () {
                    final label = labelController.text.trim();
                    final capacity = int.tryParse(capacityController.text.trim()) ?? table.capacity;
                    if (label.isEmpty) return;

                    final updated = table.copyWith(
                      label: label,
                      capacity: capacity,
                      section: selectedSection,
                      shape: selectedShape,
                      status: selectedStatus,
                    );

                    final current = List<RestaurantTable>.from(tablesNotifier.value);
                    final idx = current.indexWhere((t) => t.id == table.id);
                    if (idx != -1) {
                      current[idx] = updated;
                      tablesNotifier.value = current;
                    }

                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(AppLanguage.tr(
                          'Table updated successfully!',
                          'تم تحديث بيانات الطاولة بنجاح!',
                        )),
                        backgroundColor: const Color(0xFF10B981),
                      ),
                    );
                  },
                  child: Text(
                    AppLanguage.tr('Save Changes', 'حفظ التعديلات'),
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTableCard(BuildContext context, RestaurantTable table) {
    Color statusColor;
    String statusText;

    switch (table.status) {
      case TableStatus.available:
        statusColor = AppColors.success;
        statusText = 'FREE';
        break;
      case TableStatus.occupied:
        statusColor = AppColors.primary;
        statusText = 'BUSY';
        break;
      case TableStatus.billed:
        statusColor = AppColors.warning;
        statusText = 'BILLED';
        break;
      case TableStatus.reserved:
        statusColor = AppColors.error;
        statusText = 'RESERVED';
        break;
    }

    return Container(
      width: 130,
      height: 105,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: statusColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: statusColor.withValues(alpha: 0.25),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  table.label,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(LucideIcons.users, size: 12, color: AppColors.textSecondaryDark),
              const SizedBox(width: 4),
              Text('${table.capacity} seats', style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark)),
              const Spacer(),
              InkWell(
                onTap: () => _showEditTableDialog(context, table),
                child: const Icon(Icons.edit, size: 12, color: Colors.white54),
              ),
            ],
          ),
          if (table.currentBill > 0)
            Text(
              'E£ ${table.currentBill.toStringAsFixed(2)}',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: Colors.white,
              ),
            )
          else if (table.serverName != null)
            Text(
              table.serverName!,
              style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
              overflow: TextOverflow.ellipsis,
            )
          else
            const Text(
              'Click to Park Tab',
              style: TextStyle(fontSize: 9, color: AppColors.textSecondaryDark, fontStyle: FontStyle.italic),
            ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
      ],
    );
  }
}

/// Custom 3D Isometric Dining Hall Floor Painter
class _RestaurantFloor3DPainter extends CustomPainter {
  final List<RestaurantTable> tables;
  final double yaw;
  final double pitch;
  final String activeSection;

  _RestaurantFloor3DPainter({
    required this.tables,
    required this.yaw,
    required this.pitch,
    required this.activeSection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // 1. Draw 3D Isometric Tile Grid
    final gridPaint = Paint()
      ..color = const Color(0xFF334155).withValues(alpha: 0.35)
      ..strokeWidth = 1.0;

    final floorFill = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF1E293B).withValues(alpha: 0.6),
          const Color(0xFF0F172A).withValues(alpha: 0.9),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), floorFill);

    // Floor isometric perspective lines
    for (double x = -400; x <= 400; x += 60) {
      canvas.drawLine(
        Offset(cx + x + yaw * 80, cy - 200 + pitch * 60),
        Offset(cx + x * 1.8 + yaw * 120, size.height),
        gridPaint,
      );
    }
    for (double y = -150; y <= 350; y += 50) {
      canvas.drawLine(
        Offset(cx - 500, cy + y + pitch * 30),
        Offset(cx + 500, cy + y + pitch * 30),
        gridPaint,
      );
    }

    // 2. Draw 3D Wooden Table Bases & Chairs under each table
    for (final table in tables) {
      final normX = (table.position.dx / 1200.0).clamp(0.1, 0.9);
      final normY = (table.position.dy / 900.0).clamp(0.1, 0.9);

      final tx = size.width * normX + yaw * 60;
      final ty = size.height * normY + pitch * 40;

      // Table shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawOval(Rect.fromCenter(center: Offset(tx, ty + 20), width: 90, height: 40), shadowPaint);

      // 3D Table Legs & Pedestal
      final legPaint = Paint()
        ..color = const Color(0xFF78350F)
        ..strokeWidth = 4.0;
      canvas.drawLine(Offset(tx - 30, ty), Offset(tx - 30, ty + 18), legPaint);
      canvas.drawLine(Offset(tx + 30, ty), Offset(tx + 30, ty + 18), legPaint);
      canvas.drawLine(Offset(tx, ty), Offset(tx, ty + 18), legPaint);

      // 3D Chairs surrounding the table
      final chairPaint = Paint()..color = const Color(0xFF9A3412);
      final chairRadius = table.shape == TableShape.round ? 45.0 : 40.0;
      final chairCount = table.capacity.clamp(2, 8);
      for (int i = 0; i < chairCount; i++) {
        final angle = (i * 2 * math.pi / chairCount);
        final chX = tx + math.cos(angle) * chairRadius;
        final chY = ty + math.sin(angle) * (chairRadius * 0.6);
        canvas.drawCircle(Offset(chX, chY), 6, chairPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RestaurantFloor3DPainter oldDelegate) {
    return oldDelegate.tables != tables ||
        oldDelegate.yaw != yaw ||
        oldDelegate.pitch != pitch ||
        oldDelegate.activeSection != activeSection;
  }
}
