import 'package:flutter/material.dart';
import '../../domain/entities/tooth_chart_entry.dart';

class DentalToothMatrixWidget extends StatelessWidget {
  final List<ToothChartEntry> toothChart;
  final bool isPediatric;
  final void Function(ToothChartEntry updatedEntry)? onToothUpdated;

  const DentalToothMatrixWidget({
    super.key,
    required this.toothChart,
    this.isPediatric = false,
    this.onToothUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Separate into Upper Arch and Lower Arch
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header / Dentition Type Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  children: [
                    Icon(Icons.medical_services_outlined, size: 18, color: theme.colorScheme.primary),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isPediatric ? 'Deciduous Odontogram (Primary 20 Teeth)' : 'Adult Odontogram (Permanent 32 Teeth)',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
            ],
          ),
          const SizedBox(height: 16),

          // Upper Arch (Maxillary)
          Text(
            'Upper Maxillary Arch (1-16 or A-J)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: upperCodes.map((code) {
                final entry = _findEntry(code);
                return _ToothItem(
                  entry: entry,
                  isDark: isDark,
                  onTap: () => _showToothStateDialog(context, entry),
                );
              }).toList(),
            ),
          ),
          const Divider(height: 24),

          // Lower Arch (Mandibular)
          Text(
            'Lower Mandibular Arch (32-17 or T-K)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: lowerCodes.map((code) {
                final entry = _findEntry(code);
                return _ToothItem(
                  entry: entry,
                  isDark: isDark,
                  onTap: () => _showToothStateDialog(context, entry),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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

  void _showToothStateDialog(BuildContext context, ToothChartEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Tooth #${entry.effectiveToothCode} Clinical Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: ToothState.values.map((state) {
              final isSelected = entry.state == state;
              return ListTile(
                leading: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStateColor(state),
                  ),
                ),
                title: Text(state.name.toUpperCase()),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.green) : null,
                onTap: () {
                  final updated = entry.copyWith(state: state);
                  onToothUpdated?.call(updated);
                  Navigator.of(ctx).pop();
                },
              );
            }).toList(),
          ),
        );
      },
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
      case ToothState.missing:
        return const Color(0xFF94A3B8); // Grey
      case ToothState.crown:
        return const Color(0xFFF59E0B); // Gold
      case ToothState.implant:
        return const Color(0xFF8B5CF6); // Purple
      case ToothState.rootCanal:
        return const Color(0xFFF97316); // Orange
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

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        padding: const EdgeInsets.symmetric(vertical: 8),
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
            Text(
              entry.effectiveToothCode,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stateColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
