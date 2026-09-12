import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/entities/clinical_anatomy_status_entry.dart';
import '../../domain/entities/clinical_status_catalog.dart';
import '../../../../core/localization/app_language.dart';
import 'multi_specialty_anatomy_canvas_widget.dart' show ClinicalSpecialtyDiscipline;

/// Interactive 4D/3D Clinical Status & Action Inspector Modal.
/// 100% [StatelessWidget] architecture with reactive [ValueNotifier] state.
/// Provides exhaustive statuses per discipline, live search bar, category chips,
/// and instant procedure/billing linkage.
class ClinicalStatusInspectorModal extends StatelessWidget {
  final String partKey;
  final String partName;
  final String partNameAr;
  final ClinicalSpecialtyDiscipline discipline;
  final ClinicalAnatomyStatusEntry? currentStatus;
  final void Function(ClinicalStatusDefinition status) onStatusSelected;
  final VoidCallback? onClearStatus;

  final ValueNotifier<String> _searchQueryNotifier;
  final ValueNotifier<ClinicalStatusCategory> _activeCategoryNotifier;

  ClinicalStatusInspectorModal({
    super.key,
    required this.partKey,
    required this.partName,
    required this.partNameAr,
    required this.discipline,
    this.currentStatus,
    required this.onStatusSelected,
    this.onClearStatus,
  })  : _searchQueryNotifier = ValueNotifier<String>(''),
        _activeCategoryNotifier = ValueNotifier<ClinicalStatusCategory>(ClinicalStatusCategory.all);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allStatuses = ClinicalStatusCatalog.getStatusesForDiscipline(
      discipline: discipline,
      partKey: partKey,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0A0F1D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── MODAL DRAG HANDLE & HEADER ─────────────────────────────────────
          _buildHeader(context, isDark),

          // ── LIVE SEARCH BAR ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSearchBar(context, isDark),
          ),

          // ── CATEGORY FILTER CHIPS ─────────────────────────────────────────
          _buildCategoryFilterRow(isDark),

          const SizedBox(height: 8),

          // ── STATUS CARDS LIST (FILTERED REACTIVELY) ────────────────────────
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _searchQueryNotifier,
              builder: (context, query, _) {
                return ValueListenableBuilder<ClinicalStatusCategory>(
                  valueListenable: _activeCategoryNotifier,
                  builder: (context, activeCat, _) {
                    final filtered = allStatuses.where((def) {
                      final matchesCat = activeCat == ClinicalStatusCategory.all || def.category == activeCat;
                      final matchesSearch = def.matchesQuery(query);
                      return matchesCat && matchesSearch;
                    }).toList();

                    if (filtered.isEmpty) {
                      return _buildEmptyState(query, isDark);
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final statusDef = filtered[index];
                        final isSelected = currentStatus?.status.id == statusDef.id;
                        return _buildStatusCard(context, statusDef, isSelected, isDark);
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D38) : const Color(0xFFF8FAFC),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.activity, color: Color(0xFF0284C7), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            AppLanguage.isArabic
                                ? (partNameAr.isNotEmpty ? partNameAr : partName)
                                : partName,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0284C7).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            discipline.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0284C7),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Select anatomical status, clinical pathology, and linked procedure',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              if (currentStatus != null && onClearStatus != null)
                TextButton.icon(
                  onPressed: () {
                    onClearStatus?.call();
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(LucideIcons.trash2, size: 14, color: Colors.redAccent),
                  label: const Text(
                    'Clear',
                    style: TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF131D38) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
        ),
      ),
      child: TextField(
        onChanged: (val) => _searchQueryNotifier.value = val,
        decoration: InputDecoration(
          hintText: 'Search status, pathology name, ICD-10 code (e.g. H16, fracture, ulcer)...',
          hintStyle: TextStyle(
            fontSize: 12,
            color: isDark ? Colors.white38 : Colors.black38,
          ),
          prefixIcon: const Icon(LucideIcons.search, size: 16, color: Color(0xFF0284C7)),
          suffixIcon: ValueListenableBuilder<String>(
            valueListenable: _searchQueryNotifier,
            builder: (context, q, _) {
              if (q.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(LucideIcons.xCircle, size: 16),
                onPressed: () => _searchQueryNotifier.value = '',
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        ),
        style: const TextStyle(fontSize: 13),
      ),
    );
  }

  Widget _buildCategoryFilterRow(bool isDark) {
    return SizedBox(
      height: 36,
      child: ValueListenableBuilder<ClinicalStatusCategory>(
        valueListenable: _activeCategoryNotifier,
        builder: (context, activeCat, _) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: ClinicalStatusCategory.values.length,
            separatorBuilder: (_, _) => const SizedBox(width: 6),
            itemBuilder: (context, index) {
              final cat = ClinicalStatusCategory.values[index];
              final isSelected = cat == activeCat;
              return ChoiceChip(
                label: Text(
                  cat.label,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
                selected: isSelected,
                selectedColor: const Color(0xFF0284C7),
                backgroundColor: isDark ? const Color(0xFF131D38) : const Color(0xFFF1F5F9),
                onSelected: (selected) {
                  if (selected) _activeCategoryNotifier.value = cat;
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusCard(
    BuildContext context,
    ClinicalStatusDefinition def,
    bool isSelected,
    bool isDark,
  ) {
    final severityColor = def.severity.color;

    return InkWell(
      onTap: () {
        onStatusSelected(def);
        Navigator.of(context).pop();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? severityColor.withValues(alpha: 0.15)
              : (isDark ? const Color(0xFF131D38) : Colors.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? severityColor
                : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: severityColor.withValues(alpha: 0.2),
                blurRadius: 8,
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: severityColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLanguage.isArabic ? def.titleAr : def.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                // ICD-10 Code Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ICD-10: ${def.icd10Code}',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Severity Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: severityColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    def.severity.label,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
            if (AppLanguage.isArabic && def.title.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                def.title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              def.description,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
            const SizedBox(height: 8),
            // Suggested procedure banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isDark ? Colors.white10 : Colors.black12,
                ),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.stethoscope, size: 13, color: Color(0xFF0284C7)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Procedure: ${def.suggestedProcedure.name} (${def.suggestedProcedure.code})',
                      style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '${def.suggestedProcedure.standardFee.toStringAsFixed(0)} EGP',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String query, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.searchX, size: 36, color: isDark ? Colors.white24 : Colors.black26),
            const SizedBox(height: 12),
            Text(
              'No statuses found matching "$query"',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Try searching with ICD-10 code, Arabic or English clinical keywords',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
