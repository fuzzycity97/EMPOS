import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

enum TableStatus { available, occupied, billed, reserved }

class RestaurantTable {
  final String id;
  final String label;
  final int capacity;
  final String section;
  final Offset position;
  final TableStatus status;
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
      currentBill: currentBill ?? this.currentBill,
      serverName: serverName ?? this.serverName,
      activeTabId: activeTabId ?? this.activeTabId,
    );
  }
}

/// 2D interactive, zoomable, draggable restaurant floor plan layout.
/// 100% [StatelessWidget] following pure Clean Architecture.
class RestaurantTableMapWidget extends StatelessWidget {
  final ValueNotifier<List<RestaurantTable>> tablesNotifier;
  final ValueNotifier<String> activeSectionNotifier;
  final ValueNotifier<RestaurantTable?> selectedTableNotifier;
  final Function(RestaurantTable table)? onTableSelected;
  final Function(RestaurantTable table)? onParkTabToTable;
  final TransformationController transformationController;

  RestaurantTableMapWidget({
    super.key,
    ValueNotifier<List<RestaurantTable>>? tablesNotifier,
    ValueNotifier<String>? activeSectionNotifier,
    ValueNotifier<RestaurantTable?>? selectedTableNotifier,
    TransformationController? transformationController,
    this.onTableSelected,
    this.onParkTabToTable,
  })  : tablesNotifier = tablesNotifier ??
            ValueNotifier<List<RestaurantTable>>(_defaultTables),
        activeSectionNotifier =
            activeSectionNotifier ?? ValueNotifier<String>('Main Dining'),
        selectedTableNotifier =
            selectedTableNotifier ?? ValueNotifier<RestaurantTable?>(null),
        transformationController =
            transformationController ?? TransformationController();

  static const List<RestaurantTable> _defaultTables = [
    RestaurantTable(
      id: 'T1',
      label: 'Table 1',
      capacity: 4,
      section: 'Main Dining',
      position: Offset(100, 100),
      status: TableStatus.available,
    ),
    RestaurantTable(
      id: 'T2',
      label: 'Table 2',
      capacity: 2,
      section: 'Main Dining',
      position: Offset(260, 100),
      status: TableStatus.occupied,
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
      serverName: 'VIP Party (8:00 PM)',
    ),
    RestaurantTable(
      id: 'T5',
      label: 'Booth 5',
      capacity: 6,
      section: 'Main Dining',
      position: Offset(260, 260),
      status: TableStatus.available,
    ),
    RestaurantTable(
      id: 'T6',
      label: 'Booth 6',
      capacity: 6,
      section: 'Main Dining',
      position: Offset(420, 260),
      status: TableStatus.occupied,
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
    ),
    RestaurantTable(
      id: 'P2',
      label: 'Patio 2',
      capacity: 4,
      section: 'Patio & Terrace',
      position: Offset(300, 120),
      status: TableStatus.occupied,
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
                  const SizedBox(width: 16),

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
                  const SizedBox(width: 16),

                  // Reset Zoom
                  IconButton(
                    tooltip: 'Reset Zoom & Center',
                    icon: const Icon(LucideIcons.maximize2, size: 16, color: AppColors.textSecondaryDark),
                    onPressed: () {
                      transformationController.value = Matrix4.identity();
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

          // ── 2D INTERACTIVE FLOOR PLAN CANVAS ──────────────────────────────
          Expanded(
            child: ClipRect(
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
                                    // Live table dragging across canvas
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
            ),
          ),
        ],
      ),
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
            color: statusColor.withValues(alpha: 0.15),
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
