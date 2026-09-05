import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/entities/tooth_chart_entry.dart';

class ToothEditorSheet extends StatelessWidget {
  final ToothChartEntry entry;
  final bool isPediatric;
  final String? doctorName;
  final void Function(ToothChartEntry updatedEntry) onSave;
  final VoidCallback onCancel;

  const ToothEditorSheet({
    super.key,
    required this.entry,
    this.isPediatric = false,
    this.doctorName,
    required this.onSave,
    required this.onCancel,
  });

  static Future<void> show(
    BuildContext context, {
    required ToothChartEntry entry,
    bool isPediatric = false,
    String? doctorName,
    required void Function(ToothChartEntry updatedEntry) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ToothEditorSheetModal(
        entry: entry,
        isPediatric: isPediatric,
        doctorName: doctorName,
        onSave: (updated) {
          onSave(updated);
          Navigator.of(ctx).pop();
        },
        onCancel: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ToothEditorSheetModal(
      entry: entry,
      isPediatric: isPediatric,
      doctorName: doctorName,
      onSave: onSave,
      onCancel: onCancel,
    );
  }
}

class _ToothEditorSheetModal extends StatelessWidget {
  final ToothChartEntry entry;
  final bool isPediatric;
  final String? doctorName;
  final void Function(ToothChartEntry updatedEntry) onSave;
  final VoidCallback onCancel;

  const _ToothEditorSheetModal({
    required this.entry,
    required this.isPediatric,
    this.doctorName,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use local ValueNotifiers wrapped in Stateless component to keep 100% StatelessWidget rule
    final selectedState = ValueNotifier<ToothState>(entry.state);
    final selectedSpecialCase = ValueNotifier<SpecialCaseType?>(
      entry.specialCaseType ?? (entry.state == ToothState.specialCase ? SpecialCaseType.customOther : null),
    );
    final pocketDepth = ValueNotifier<int>(entry.pocketDepthMm);
    final surfaceNotation = ValueNotifier<String>(entry.surfaceNotation);
    final notesController = TextEditingController(text: entry.notes ?? '');

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 150),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag Handle & Header
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _getStateColor(entry.state).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStateIcon(entry.state),
                      color: _getStateColor(entry.state),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'FDI ${entry.fdiNumber}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: (isPediatric ? Colors.pink : Colors.blue).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPediatric ? 'Primary #${entry.effectiveToothCode}' : 'Univ #${entry.effectiveToothCode}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isPediatric ? Colors.pink : Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.purple.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                entry.category.displayName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          entry.plainLanguagePosition,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: onCancel,
                    tooltip: 'Close',
                  ),
                ],
              ),
            ),
            const Divider(height: 20),

            // Form Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Clinical Status Grid
                    Text(
                      'CLINICAL STATUS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<ToothState>(
                      valueListenable: selectedState,
                      builder: (context, current, _) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ToothState.values.map((s) {
                            final isSel = current == s;
                            final color = _getStateColor(s);
                            return InkWell(
                              onTap: () => selectedState.value = s,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                decoration: BoxDecoration(
                                  color: isSel ? color : color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: isSel ? color : color.withValues(alpha: 0.3),
                                    width: isSel ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getStateIcon(s),
                                      size: 14,
                                      color: isSel ? Colors.white : color,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      s.displayName,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                        color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. Special Case Sub-Type (Conditional)
                    ValueListenableBuilder<ToothState>(
                      valueListenable: selectedState,
                      builder: (context, current, _) {
                        if (current != ToothState.specialCase) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SPECIAL CASE ANOMALY TYPE',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Colors.indigo.shade300,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ValueListenableBuilder<SpecialCaseType?>(
                              valueListenable: selectedSpecialCase,
                              builder: (context, currentSpecial, _) {
                                return Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: SpecialCaseType.values.map((sc) {
                                    final isSel = currentSpecial == sc;
                                    return ChoiceChip(
                                      label: Text(sc.displayName, style: const TextStyle(fontSize: 11)),
                                      selected: isSel,
                                      selectedColor: Colors.indigo.withValues(alpha: 0.25),
                                      onSelected: (_) => selectedSpecialCase.value = sc,
                                    );
                                  }).toList(),
                                );
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        );
                      },
                    ),

                    // 3. Periodontal Pocket Depth & Surface Notations
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Pocket Depth
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'POCKET DEPTH (MM)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 6),
                              ValueListenableBuilder<int>(
                                valueListenable: pocketDepth,
                                builder: (context, depth, _) {
                                  return Row(
                                    children: [1, 2, 3, 4, 5, 6, 7, 8, 9].map((d) {
                                      final isSel = depth == d;
                                      final dColor = d <= 3
                                          ? Colors.green
                                          : (d <= 5 ? Colors.amber : Colors.red);
                                      return Expanded(
                                        child: InkWell(
                                          onTap: () => pocketDepth.value = d,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(horizontal: 1),
                                            padding: const EdgeInsets.symmetric(vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isSel ? dColor : dColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(
                                                color: isSel ? dColor : dColor.withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                '$d',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color: isSel ? Colors.white : (isDark ? Colors.white : Colors.black87),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // 4. Surface Notations (M, O/I, D, B, L)
                    Text(
                      'AFFECTED SURFACES (MODBL)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ValueListenableBuilder<String>(
                      valueListenable: surfaceNotation,
                      builder: (context, not, _) {
                        final surfaces = [
                          {'code': 'M', 'label': 'Mesial (M)'},
                          {'code': 'O', 'label': entry.category == ToothCategory.incisor ? 'Incisal (I)' : 'Occlusal (O)'},
                          {'code': 'D', 'label': 'Distal (D)'},
                          {'code': 'B', 'label': 'Buccal / Facial (B)'},
                          {'code': 'L', 'label': 'Lingual / Palatal (L)'},
                        ];
                        return Wrap(
                          spacing: 6,
                          children: surfaces.map((s) {
                            final code = s['code']!;
                            final hasCode = not.contains(code);
                            return FilterChip(
                              label: Text(s['label']!, style: const TextStyle(fontSize: 11)),
                              selected: hasCode,
                              onSelected: (selected) {
                                final currentVal = surfaceNotation.value;
                                if (selected) {
                                  if (!currentVal.contains(code)) {
                                    surfaceNotation.value = '$currentVal$code';
                                  }
                                } else {
                                  surfaceNotation.value = currentVal.replaceAll(code, '');
                                }
                              },
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // 5. Free-Text Description / Clinical Notes
                    Text(
                      'CLINICAL DESCRIPTION & DIAGNOSIS NOTES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Enter clinical observations, pathology details, or proposed treatment plan...',
                        hintStyle: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.black38),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 6. Append-Only Tooth History Audit Trail
                    if (entry.history.isNotEmpty) ...[
                      Text(
                        'CLINICAL HISTORY & PREVIOUS DIAGNOSES (${entry.history.length})',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white60 : Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
                        ),
                        child: Column(
                          children: entry.history.reversed.take(4).map((hist) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.only(top: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _getStateColor(hist.state),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              hist.state.displayName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: _getStateColor(hist.state),
                                              ),
                                            ),
                                            Text(
                                              _formatDate(hist.timestamp),
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: isDark ? Colors.white38 : Colors.black38,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (hist.description.isNotEmpty)
                                          Text(
                                            hist.description,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isDark ? Colors.white70 : Colors.black87,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Footer Actions
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onCancel,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton.icon(
                    icon: const Icon(LucideIcons.save, size: 18),
                    label: const Text('Save Tooth Record'),
                    onPressed: () {
                      final newHistory = List<ToothHistoryEntry>.from(entry.history);
                      final notesText = notesController.text.trim();

                      // Record append-only history entry if state or notes changed
                      if (selectedState.value != entry.state || notesText.isNotEmpty) {
                        newHistory.add(
                          ToothHistoryEntry(
                            timestamp: DateTime.now(),
                            state: selectedState.value,
                            description: notesText.isNotEmpty ? notesText : 'Status updated to ${selectedState.value.displayName}',
                            doctorName: doctorName,
                            specialCaseType: selectedSpecialCase.value,
                          ),
                        );
                      }

                      final updated = entry.copyWith(
                        state: selectedState.value,
                        specialCaseType: selectedSpecialCase.value,
                        pocketDepthMm: pocketDepth.value,
                        surfaceNotation: surfaceNotation.value,
                        notes: notesText.isNotEmpty ? notesText : entry.notes,
                        history: newHistory,
                      );

                      onSave(updated);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _getStateColor(ToothState state) {
    switch (state) {
      case ToothState.healthy:
        return const Color(0xFF10B981); // Emerald
      case ToothState.decayed:
        return const Color(0xFFEF4444); // Red
      case ToothState.filled:
        return const Color(0xFF3B82F6); // Blue
      case ToothState.crown:
        return const Color(0xFFF59E0B); // Gold
      case ToothState.rootCanal:
        return const Color(0xFFF97316); // Orange
      case ToothState.missing:
        return const Color(0xFF64748B); // Slate Gray
      case ToothState.extracted:
        return const Color(0xFF3F3F46); // Zinc Dark
      case ToothState.impacted:
        return const Color(0xFFE11D48); // Rose
      case ToothState.bridge:
        return const Color(0xFF06B6D4); // Cyan
      case ToothState.implant:
        return const Color(0xFF8B5CF6); // Purple
      case ToothState.fractured:
        return const Color(0xFFDC2626); // Crimson
      case ToothState.specialCase:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  static IconData _getStateIcon(ToothState state) {
    switch (state) {
      case ToothState.healthy:
        return LucideIcons.circleCheck;
      case ToothState.decayed:
        return LucideIcons.triangleAlert;
      case ToothState.filled:
        return LucideIcons.wrench;
      case ToothState.crown:
        return LucideIcons.crown;
      case ToothState.rootCanal:
        return LucideIcons.zap;
      case ToothState.missing:
        return LucideIcons.circleMinus;
      case ToothState.extracted:
        return LucideIcons.trash2;
      case ToothState.impacted:
        return LucideIcons.anchor;
      case ToothState.bridge:
        return LucideIcons.link;
      case ToothState.implant:
        return LucideIcons.hammer;
      case ToothState.fractured:
        return LucideIcons.activity;
      case ToothState.specialCase:
        return LucideIcons.sparkles;
    }
  }

  static String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
