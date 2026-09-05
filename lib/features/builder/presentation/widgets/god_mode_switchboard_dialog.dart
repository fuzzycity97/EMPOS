import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/atomic_business_components.dart';
import '../../../../core/config/facility_blueprint.dart';
import '../../../../core/config/god_mode_capability_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Floating / Master God-Mode Dynamic Capability Switchboard Dialog.
/// 100% [StatelessWidget] architecture with hot-reactive capabilities.
class GodModeSwitchboardDialog extends StatelessWidget {
  final GodModeCapabilityController controller;
  final ValueNotifier<String?> selectedDepartmentIdNotifier;

  GodModeSwitchboardDialog({
    super.key,
    required this.controller,
    ValueNotifier<String?>? selectedDepartmentIdNotifier,
  }) : selectedDepartmentIdNotifier = selectedDepartmentIdNotifier ??
            ValueNotifier<String?>(
              controller.activeBlueprint.departments.isNotEmpty
                  ? controller.activeBlueprint.departments.first.departmentId
                  : null,
            );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final blueprint = controller.activeBlueprint;

        return Dialog(
          backgroundColor: isDark ? const Color(0xFF090D16) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
            side: const BorderSide(color: AppColors.warning, width: 1.5),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 860, maxHeight: 760),
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.space20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                            child: const Icon(LucideIcons.shieldAlert, color: AppColors.warning, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Text(
                                    'MASTER GOD-MODE SWITCHBOARD',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.1,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'LIVE RUNTIME OVERRIDE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${blueprint.facilityName} (${blueprint.departments.length} Depts)',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondaryDark),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // ── Department Selector Tabs ────────────────────────
                  ValueListenableBuilder<String?>(
                    valueListenable: selectedDepartmentIdNotifier,
                    builder: (context, selectedDeptId, _) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            ...blueprint.departments.map((dept) {
                              final isSelected = dept.departmentId == selectedDeptId;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(dept.nameEn),
                                  selected: isSelected,
                                  selectedColor: AppColors.warning.withValues(alpha: 0.2),
                                  labelStyle: TextStyle(
                                    color: isSelected ? AppColors.warning : AppColors.textSecondaryDark,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                  onSelected: (_) => selectedDepartmentIdNotifier.value = dept.departmentId,
                                ),
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Switchboard Grid ────────────────────────────────
                  Expanded(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: selectedDepartmentIdNotifier,
                      builder: (context, selectedDeptId, _) {
                        final activeDept = selectedDeptId != null
                            ? blueprint.getDepartment(selectedDeptId)
                            : (blueprint.departments.isNotEmpty ? blueprint.departments.first : null);

                        if (activeDept == null) {
                          return const Center(child: Text('No active department selected.'));
                        }

                        return SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildCategoryGroup(
                                title: 'Clinical & 3D Vector Systems',
                                icon: LucideIcons.stethoscope,
                                color: AppColors.info,
                                isDark: isDark,
                                activeDept: activeDept,
                                capabilities: const [
                                  AtomicCapability.clinicalEncounter3dCanvas,
                                  AtomicCapability.specializedClinicalCharting,
                                  AtomicCapability.diagnosticRadiologyLightbox,
                                  AtomicCapability.laboratorySpecimenTracking,
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildCategoryGroup(
                                title: 'Inventory & Physical Dispensing',
                                icon: LucideIcons.package,
                                color: AppColors.warning,
                                isDark: isDark,
                                activeDept: activeDept,
                                capabilities: const [
                                  AtomicCapability.fefoBatchInventory,
                                  AtomicCapability.standardRetailBarcoding,
                                  AtomicCapability.consumableAutoDepletion,
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildCategoryGroup(
                                title: 'Hospitality, Booking & Services',
                                icon: LucideIcons.calendarClock,
                                color: AppColors.primaryLight,
                                isDark: isDark,
                                activeDept: activeDept,
                                capabilities: const [
                                  AtomicCapability.timeSlotAppointmentEngine,
                                  AtomicCapability.tableFloorMapManagement,
                                  AtomicCapability.multiSessionPackageCredit,
                                  AtomicCapability.multiDayStayBoarding,
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildCategoryGroup(
                                title: 'Financial Ledgers & Omnicart',
                                icon: LucideIcons.receipt,
                                color: AppColors.success,
                                isDark: isDark,
                                activeDept: activeDept,
                                capabilities: const [
                                  AtomicCapability.multiProviderCommission,
                                  AtomicCapability.insuranceCopayDeductible,
                                  AtomicCapability.unifiedCrossDepartmentCart,
                                  AtomicCapability.unifiedQueueDispatchHub,
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  const Divider(height: 20),
                  // ── Bottom Confirmation ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '⚡ Runtime modifications apply instantly to the active BLoC & Navigation stack.',
                        style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
                      ),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        icon: const Icon(LucideIcons.check, size: 16),
                        label: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryGroup({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required DepartmentNode activeDept,
    required List<AtomicCapability> capabilities,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: color)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...capabilities.map((cap) {
            final isEnabled = activeDept.has(cap);
            return SwitchListTile(
              dense: true,
              value: isEnabled,
              title: Text(cap.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              activeThumbColor: color,
              onChanged: (val) {
                controller.toggleDepartmentCapability(
                  departmentId: activeDept.departmentId,
                  capability: cap,
                  enabled: val,
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
