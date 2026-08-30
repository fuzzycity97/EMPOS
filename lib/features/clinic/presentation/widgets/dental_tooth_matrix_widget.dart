import 'package:flutter/material.dart';
import '../../domain/entities/tooth_chart_entry.dart';
import 'dental_tooth_3d_canvas_widget.dart';
import 'tooth_editor_sheet.dart';

class DentalToothMatrixWidget extends StatelessWidget {
  final List<ToothChartEntry> toothChart;
  final bool isPediatric;
  final String? doctorName;
  final void Function(ToothChartEntry updatedEntry)? onToothUpdated;

  const DentalToothMatrixWidget({
    super.key,
    required this.toothChart,
    this.isPediatric = false,
    this.doctorName,
    this.onToothUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Local ValueNotifiers for 100% StatelessWidget state management
    final is3dMode = ValueNotifier<bool>(true);
    final selectedTooth = ValueNotifier<ToothChartEntry?>(null);

    // FDI Codes: Upper Arch and Lower Arch
    final upperCodes = isPediatric
        ? ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J']
        : List.generate(16, (i) => (i + 1).toString());

    final lowerCodes = isPediatric
        ? ['T', 'S', 'R', 'Q', 'P', 'O', 'N', 'M', 'L', 'K']
        : List.generate(16, (i) => (32 - i).toString());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Header Bar with Dentition Badge & 3D / 2D Mode Switcher
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 460;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.medical_services_outlined, size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isPediatric
                                  ? 'Deciduous Odontogram (Primary 20 Teeth)'
                                  : 'Adult Odontogram (Permanent 32 Teeth)',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'FDI / ISO 3950 Two-Digit System',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isNarrow) ...[
                        const SizedBox(width: 8),
                        _buildHeaderControls(theme, isDark, is3dMode),
                      ],
                    ],
                  ),
                  if (isNarrow) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildHeaderControls(theme, isDark, is3dMode),
                    ),
                  ],
                ],
              );
            },
          ),
          const SizedBox(height: 16),

          // 2. Main Odontogram Presentation (3D Canvas vs 2D Grid)
          ValueListenableBuilder<bool>(
            valueListenable: is3dMode,
            builder: (context, in3d, _) {
              if (in3d) {
                return ValueListenableBuilder<ToothChartEntry?>(
                  valueListenable: selectedTooth,
                  builder: (context, sel, _) {
                    return SizedBox(
                      height: 380,
                      child: DentalTooth3dCanvasWidget(
                        toothChart: toothChart,
                        isPediatric: isPediatric,
                        selectedTooth: sel,
                        onToothSelected: (entry) {
                          selectedTooth.value = entry;
                          _openToothEditor(context, entry);
                        },
                      ),
                    );
                  },
                );
              }

              // 2D Matrix Mode
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upper Arch (Maxillary)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upper Maxillary Arch (FDI 18-11, 21-28 | Univ 1-16)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      Text(
                        'Right -> Left',
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: upperCodes.map((code) {
                        final entry = _findEntry(code);
                        return _ToothItem(
                          entry: entry,
                          isDark: isDark,
                          onTap: () {
                            selectedTooth.value = entry;
                            _openToothEditor(context, entry);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const Divider(height: 24),

                  // Lower Arch (Mandibular)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Lower Mandibular Arch (FDI 48-41, 31-38 | Univ 32-17)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      Text(
                        'Right -> Left',
                        style: TextStyle(fontSize: 10, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: lowerCodes.map((code) {
                        final entry = _findEntry(code);
                        return _ToothItem(
                          entry: entry,
                          isDark: isDark,
                          onTap: () {
                            selectedTooth.value = entry;
                            _openToothEditor(context, entry);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),

          // 3. Clinical Status Legend Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ToothState.values.map((state) {
                final count = toothChart.where((t) => t.state == state).length;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStateColor(state).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _getStateColor(state).withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getStateColor(state),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.displayName} ($count)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderControls(
    ThemeData theme,
    bool isDark,
    ValueNotifier<bool> is3dMode,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pediatric / Adult Chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: (isPediatric ? Colors.pink : Colors.blue).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isPediatric ? 'Pediatric (<12y)' : 'Adult (12y+)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isPediatric ? Colors.pink : Colors.blue,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // 3D vs 2D View Mode Toggle
        ValueListenableBuilder<bool>(
          valueListenable: is3dMode,
          builder: (context, in3d, _) {
            return Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => is3dMode.value = true,
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: in3d ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(left: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.view_in_ar_outlined,
                            size: 13,
                            color: in3d ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '3D View',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: in3d ? FontWeight.bold : FontWeight.normal,
                              color: in3d ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => is3dMode.value = false,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                      decoration: BoxDecoration(
                        color: !in3d ? theme.colorScheme.primary : Colors.transparent,
                        borderRadius: const BorderRadius.horizontal(right: Radius.circular(8)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.grid_view_outlined,
                            size: 13,
                            color: !in3d ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '2D Grid',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: !in3d ? FontWeight.bold : FontWeight.normal,
                              color: !in3d ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                            ),
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
      ],
    );
  }

  void _openToothEditor(BuildContext context, ToothChartEntry entry) {
    ToothEditorSheet.show(
      context,
      entry: entry,
      isPediatric: isPediatric,
      doctorName: doctorName,
      onSave: (updated) {
        onToothUpdated?.call(updated);
      },
    );
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
}

class _ToothItem extends StatelessWidget {
  final ToothChartEntry entry;
  final bool isDark;
  final VoidCallback onTap;

  const _ToothItem({
    required this.entry,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stateColor = DentalToothMatrixWidget._getStateColor(entry.state);

    return Tooltip(
      message: '${entry.plainLanguagePosition}\nStatus: ${entry.state.displayName}${entry.notes != null ? "\nNotes: ${entry.notes}" : ""}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 52,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
          decoration: BoxDecoration(
            color: stateColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: stateColor,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // FDI Number
              Text(
                'FDI ${entry.fdiNumber}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              // Univ Code
              Text(
                '#${entry.effectiveToothCode}',
                style: TextStyle(
                  fontSize: 9,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(height: 3),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: stateColor,
                ),
              ),
              if (entry.pocketDepthMm > 3)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    '${entry.pocketDepthMm}mm',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: entry.pocketDepthMm >= 6 ? Colors.red : Colors.amber,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
