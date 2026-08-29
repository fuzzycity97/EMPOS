import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../bloc/config_bloc.dart';
import '../bloc/config_event.dart';
import '../bloc/config_state.dart';
import '../../../hardware/presentation/widgets/hardware_diagnostics_dialog.dart';
import '../../../../features/auth/domain/entities/user_role.dart';
import '../../../../features/auth/presentation/widgets/role_guard_widget.dart';
import '../../../../features/rmm/presentation/pages/developer_console_page.dart';

class AdvancedSettingsDialog extends StatelessWidget {
  final ValueNotifier<String> _searchFilterNotifier = ValueNotifier<String>('');

  AdvancedSettingsDialog({super.key});

  static String formatToggleLabel(String key) {
    final cleanKey = key.replaceFirst(RegExp(r'^(sw\.|hw\.)'), '');
    final words = cleanKey.split('_').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1);
    }).toList();
    return words.join(' ');
  }

  static String getToggleDescription(String key) {
    switch (key) {
      case 'sw.table_management':
        return 'Enables Dine-In / Table layout selection and floor tab binding in POS.';
      case 'sw.prescription_scanning':
        return 'Activates Optical Rx scanning, molecule interaction checks, and patient dosage logs.';
      case 'sw.grocery_weight_pricing':
        return 'Calculates item line totals dynamically from weight scale inputs.';
      case 'sw.box_and_strip_selling':
        return 'Allows breaking whole medicine boxes into sub-unit strips with proportionate pricing.';
      case 'sw.expiry_tracking':
        return 'Enforces FEFO (First-Expired-First-Out) batch control on inventory products.';
      case 'sw.batch_numbers':
        return 'Tracks manufacturer lot/batch numbers for pharmaceutical and food safety.';
      case 'sw.loyalty_points':
        return 'Awards reward points per transaction and enables point-redemption discounts.';
      case 'sw.custom_tax_rates':
        return 'Allows per-product custom VAT override rates instead of global flat rate.';
      case 'sw.multi_shift_management':
        return 'Enables granular multi-cashier shift float declarations and Z-report audits.';
      case 'sw.compliance_audit_logs':
        return 'System compliance logging for tax authorities and audit trails (Required).';
      case 'hw.retail_barcode_scanner':
        return 'Global keyboard hook listener for physical USB and Bluetooth barcode scanners.';
      case 'hw.receipt_printer_80mm':
        return 'Direct thermal printing of formatted 80mm receipts with QR tax signatures.';
      case 'hw.cash_drawer_kick':
        return 'Sends electrical kick pulse to open cash drawer RJ11 port on transaction completion.';
      case 'hw.grocery_scale':
        return 'Integrates digital weighing scales with real-time tare and zero calibration.';
      case 'hw.optical_prescription_scanner':
        return 'High-resolution document camera scanner integration for medical prescriptions.';
      case 'hw.customer_display':
        return 'Secondary dual-screen customer facing price and total due monitor.';
      default:
        return 'Configure this discrete system engine toggle.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820, maxHeight: 780),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: BlocBuilder<ConfigBloc, ConfigState>(
            builder: (context, state) {
              if (state is! ConfigLoaded) {
                return const Center(child: CircularProgressIndicator());
              }

              final blueprint = state.blueprint;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: Icon(LucideIcons.settings, color: primaryColor, size: 24),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Advanced System Settings & Feature Matrix',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                    border: Border.all(color: primaryColor.withValues(alpha: 0.4)),
                                  ),
                                  child: Text(
                                    blueprint.industryType.name.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Active Store: ${blueprint.storeName} | Granular Software & Hardware Toggles (Rule A)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => HardwareDiagnosticsDialog(),
                          );
                        },
                        icon: const Icon(LucideIcons.printer, size: 14),
                        label: const Text('Hardware Diagnostics'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryLight,
                          side: const BorderSide(color: AppColors.primary),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      RoleGuardWidget(
                        allowedRoles: const [UserRole.admin],
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => DeveloperConsolePage(),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.terminal, size: 14),
                          label: const Text('Developer Console'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.accent,
                            side: const BorderSide(color: AppColors.accent),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(LucideIcons.x, size: 20),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  const Divider(color: AppColors.borderDark, height: 1),
                  const SizedBox(height: AppDimensions.space12),

                  // Search Bar for typed search (Rule B)
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceElevatedDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: TextField(
                      onChanged: (val) => _searchFilterNotifier.value = val,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(LucideIcons.search, size: 16),
                        hintText: 'Search toggles (e.g., table, prescription, scale, barcode, tax)...',
                        hintStyle: TextStyle(fontSize: 12.5),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space12),

                  // Scrollable Toggle Sections
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: _searchFilterNotifier,
                      builder: (context, searchQuery, _) {
                        final query = searchQuery.trim().toLowerCase();

                        // Collect and sort toggles
                        final allToggles = Map<String, bool>.from(blueprint.toggles);

                        // Ensure standard core toggles exist in the map
                        _ensureStandardToggles(allToggles);

                        final swToggles = allToggles.entries
                            .where((e) => e.key.startsWith('sw.'))
                            .where((e) => _matchesSearch(e.key, query))
                            .toList();

                        final hwToggles = allToggles.entries
                            .where((e) => e.key.startsWith('hw.'))
                            .where((e) => _matchesSearch(e.key, query))
                            .toList();

                        if (swToggles.isEmpty && hwToggles.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(LucideIcons.searchX, size: 36, color: AppColors.textMutedDark),
                                const SizedBox(height: 8),
                                Text(
                                  'No toggles match "$searchQuery"',
                                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView(
                          children: [
                            if (swToggles.isNotEmpty) ...[
                              _CategoryHeader(
                                title: 'Software Feature Modules (sw.*)',
                                icon: LucideIcons.cpu,
                                count: swToggles.length,
                                color: primaryColor,
                              ),
                              const SizedBox(height: 6),
                              ...swToggles.map((entry) => _ToggleTile(
                                    toggleKey: entry.key,
                                    isEnabled: entry.value,
                                    primaryColor: primaryColor,
                                    isRequired: entry.key == 'sw.compliance_audit_logs',
                                    onChanged: (val) {
                                      context.read<ConfigBloc>().add(
                                            SetToggleEvent(
                                              toggleKey: entry.key,
                                              isEnabled: val,
                                            ),
                                          );
                                    },
                                  )),
                              const SizedBox(height: 16),
                            ],
                            if (hwToggles.isNotEmpty) ...[
                              _CategoryHeader(
                                title: 'Hardware Peripherals & Devices (hw.*)',
                                icon: LucideIcons.hardDrive,
                                count: hwToggles.length,
                                color: AppColors.secondary,
                              ),
                              const SizedBox(height: 6),
                              ...hwToggles.map((entry) => _ToggleTile(
                                    toggleKey: entry.key,
                                    isEnabled: entry.value,
                                    primaryColor: AppColors.secondary,
                                    isRequired: false,
                                    onChanged: (val) {
                                      context.read<ConfigBloc>().add(
                                            SetToggleEvent(
                                              toggleKey: entry.key,
                                              isEnabled: val,
                                            ),
                                          );
                                    },
                                  )),
                            ],
                          ],
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space12),
                  const Divider(color: AppColors.borderDark, height: 1),
                  const SizedBox(height: AppDimensions.space12),

                  // Footer Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Changes are saved instantly to EMPOS_Database',
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                            color: AppColors.textMutedDark,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('APPLY & CLOSE'),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  static bool _matchesSearch(String key, String query) {
    if (query.isEmpty) return true;
    final label = formatToggleLabel(key).toLowerCase();
    final rawKey = key.toLowerCase();
    final description = getToggleDescription(key).toLowerCase();
    return label.contains(query) || rawKey.contains(query) || description.contains(query);
  }

  static void _ensureStandardToggles(Map<String, bool> toggles) {
    final standardKeys = [
      'sw.prescription_scanning',
      'sw.table_management',
      'sw.grocery_weight_pricing',
      'sw.box_and_strip_selling',
      'sw.expiry_tracking',
      'sw.batch_numbers',
      'sw.loyalty_points',
      'sw.custom_tax_rates',
      'sw.multi_shift_management',
      'sw.compliance_audit_logs',
      'hw.retail_barcode_scanner',
      'hw.receipt_printer_80mm',
      'hw.cash_drawer_kick',
      'hw.grocery_scale',
      'hw.optical_prescription_scanner',
      'hw.customer_display',
    ];

    for (final k in standardKeys) {
      toggles.putIfAbsent(k, () => k == 'sw.compliance_audit_logs');
    }
  }
}

class _CategoryHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final int count;
  final Color color;

  const _CategoryHeader({
    required this.title,
    required this.icon,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusRound),
            ),
            child: Text(
              '$count Toggles',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String toggleKey;
  final bool isEnabled;
  final Color primaryColor;
  final bool isRequired;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.toggleKey,
    required this.isEnabled,
    required this.primaryColor,
    required this.isRequired,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final title = AdvancedSettingsDialog.formatToggleLabel(toggleKey);
    final description = AdvancedSettingsDialog.getToggleDescription(toggleKey);

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isEnabled ? AppColors.surfaceElevatedDark : AppColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          side: BorderSide(
            color: isEnabled ? primaryColor.withValues(alpha: 0.35) : AppColors.borderDark,
          ),
        ),
        child: SwitchListTile(
          activeThumbColor: primaryColor,
          activeTrackColor: primaryColor.withValues(alpha: 0.4),
          dense: true,
        title: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: isEnabled ? Colors.white : AppColors.textSecondaryDark,
                ),
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                ),
                child: const Text(
                  'REQUIRED',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 2),
            Text(
              toggleKey,
              style: const TextStyle(
                fontSize: 10,
                fontFamily: 'monospace',
                color: AppColors.textMutedDark,
              ),
            ),
          ],
        ),
        value: isRequired ? true : isEnabled,
        onChanged: isRequired ? null : onChanged,
      ),
    ),
  );
}
}
