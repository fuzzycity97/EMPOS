import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/atomic_business_components.dart';
import '../../../../core/config/facility_blueprint.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Visual Blueprint Studio for Unlimited Dynamic Facility Composition.
/// 100% [StatelessWidget] architecture.
class FacilityBlueprintBuilderScreen extends StatelessWidget {
  final ValueNotifier<FacilityBlueprint> blueprintNotifier;
  final ValueNotifier<int> selectedDeptIndexNotifier;
  final VoidCallback? onSaveAndExport;

  FacilityBlueprintBuilderScreen({
    super.key,
    ValueNotifier<FacilityBlueprint>? blueprintNotifier,
    ValueNotifier<int>? selectedDeptIndexNotifier,
    this.onSaveAndExport,
  })  : blueprintNotifier = blueprintNotifier ??
            ValueNotifier<FacilityBlueprint>(_initialBlueprint),
        selectedDeptIndexNotifier = selectedDeptIndexNotifier ?? ValueNotifier<int>(0);

  static final FacilityBlueprint _initialBlueprint = FacilityBlueprint(
    facilityId: 'fac_omni_main',
    facilityName: 'Omni Healthcare & Wellness Complex',
    departments: [
      const DepartmentNode(
        departmentId: 'dept_dental',
        nameEn: 'Dental & Maxillofacial Wing',
        nameAr: 'قسم طب وجراحة الفم والأسنان',
        capabilities: {
          AtomicCapability.clinicalEncounter3dCanvas,
          AtomicCapability.specializedClinicalCharting,
          AtomicCapability.consumableAutoDepletion,
          AtomicCapability.multiProviderCommission,
        },
        customConfig: {'spatial3dProfile': 'dental_clinic', 'defaultWarehouse': 'wh_dental'},
      ),
      const DepartmentNode(
        departmentId: 'dept_pharmacy',
        nameEn: 'In-House Clinical Pharmacy',
        nameAr: 'الصيدلية الإكلينيكية الداخلية',
        capabilities: {
          AtomicCapability.fefoBatchInventory,
          AtomicCapability.standardRetailBarcoding,
        },
        customConfig: {'defaultWarehouse': 'wh_pharmacy_fefo'},
      ),
      const DepartmentNode(
        departmentId: 'dept_radiology',
        nameEn: 'Diagnostic Imaging & Lab Center',
        nameAr: 'مركز الأشعة والتحاليل الطبية',
        capabilities: {
          AtomicCapability.diagnosticRadiologyLightbox,
          AtomicCapability.laboratorySpecimenTracking,
        },
        customConfig: {'dicomServerPort': 104},
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(LucideIcons.boxes, size: 20, color: AppColors.primaryLight),
            SizedBox(width: 10),
            Text(
              'Dynamic Facility Studio — Infinite Modular Composition',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
              icon: const Icon(LucideIcons.save, size: 16),
              label: const Text('Export Blueprint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              onPressed: () => _validateAndExport(context),
            ),
          ),
        ],
      ),
      body: ValueListenableBuilder<FacilityBlueprint>(
        valueListenable: blueprintNotifier,
        builder: (context, blueprint, _) {
          return ValueListenableBuilder<int>(
            valueListenable: selectedDeptIndexNotifier,
            builder: (context, selectedIdx, _) {
              final activeDept = (selectedIdx >= 0 && selectedIdx < blueprint.departments.length)
                  ? blueprint.departments[selectedIdx]
                  : null;

              return Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── LEFT: DEPARTMENTS LIST & MANAGER ─────────────────────────
                  SizedBox(
                    width: 320,
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        border: Border(right: BorderSide(color: isDark ? AppColors.borderDark : Colors.black12)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Departments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                IconButton(
                                  icon: const Icon(LucideIcons.plusCircle, color: AppColors.primary, size: 20),
                                  tooltip: 'Add Department',
                                  onPressed: () => _showAddDepartmentDialog(context),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1),
                          Expanded(
                            child: ListView.separated(
                              itemCount: blueprint.departments.length,
                              separatorBuilder: (_, _) => const Divider(height: 1),
                              itemBuilder: (ctx, idx) {
                                final dept = blueprint.departments[idx];
                                final isSelected = idx == selectedIdx;
                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: AppColors.primary.withValues(alpha: 0.12),
                                  title: Text(
                                    dept.nameEn,
                                    style: TextStyle(
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      color: isSelected ? AppColors.primaryLight : null,
                                      fontSize: 13,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${dept.nameAr} • ${dept.capabilities.length} capabilities',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(LucideIcons.trash2, size: 16, color: AppColors.danger),
                                    onPressed: blueprint.departments.length > 1
                                        ? () => _removeDepartment(idx)
                                        : null,
                                  ),
                                  onTap: () => selectedDeptIndexNotifier.value = idx,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── RIGHT: ATOMIC CAPABILITY SWITCHBOARD ───────────────────
                  Expanded(
                    child: activeDept == null
                        ? const Center(child: Text('Select or add a department to configure capabilities.'))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Department Header Card
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                    border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                        ),
                                        child: const Icon(LucideIcons.building2, color: AppColors.primaryLight, size: 22),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              activeDept.nameEn,
                                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              '${activeDept.nameAr} • Department ID: ${activeDept.departmentId}',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                const Text(
                                  'Atomic Capability Matrix',
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 12),

                                // 1. Clinical & Anatomical Visualization
                                _buildCapabilityCategory(
                                  title: 'Clinical & Anatomical Visualization',
                                  icon: LucideIcons.stethoscope,
                                  color: AppColors.info,
                                  isDark: isDark,
                                  capabilities: const [
                                    AtomicCapability.clinicalEncounter3dCanvas,
                                    AtomicCapability.specializedClinicalCharting,
                                    AtomicCapability.diagnosticRadiologyLightbox,
                                    AtomicCapability.laboratorySpecimenTracking,
                                  ],
                                  activeDept: activeDept,
                                  deptIndex: selectedIdx,
                                ),
                                const SizedBox(height: 14),

                                // 2. Physical Inventory & Dispensing
                                _buildCapabilityCategory(
                                  title: 'Physical Inventory & Dispensing',
                                  icon: LucideIcons.package,
                                  color: AppColors.warning,
                                  isDark: isDark,
                                  capabilities: const [
                                    AtomicCapability.fefoBatchInventory,
                                    AtomicCapability.standardRetailBarcoding,
                                    AtomicCapability.consumableAutoDepletion,
                                  ],
                                  activeDept: activeDept,
                                  deptIndex: selectedIdx,
                                ),
                                const SizedBox(height: 14),

                                // 3. Service, Booking & Hospitality
                                _buildCapabilityCategory(
                                  title: 'Service, Booking & Hospitality',
                                  icon: LucideIcons.calendarClock,
                                  color: AppColors.primaryLight,
                                  isDark: isDark,
                                  capabilities: const [
                                    AtomicCapability.timeSlotAppointmentEngine,
                                    AtomicCapability.tableFloorMapManagement,
                                    AtomicCapability.multiSessionPackageCredit,
                                    AtomicCapability.multiDayStayBoarding,
                                  ],
                                  activeDept: activeDept,
                                  deptIndex: selectedIdx,
                                ),
                                const SizedBox(height: 14),

                                // 4. Financial, Commission & Ledger
                                _buildCapabilityCategory(
                                  title: 'Financial, Commission & Ledger',
                                  icon: LucideIcons.receipt,
                                  color: AppColors.success,
                                  isDark: isDark,
                                  capabilities: const [
                                    AtomicCapability.multiProviderCommission,
                                    AtomicCapability.insuranceCopayDeductible,
                                    AtomicCapability.unifiedCrossDepartmentCart,
                                    AtomicCapability.unifiedQueueDispatchHub,
                                  ],
                                  activeDept: activeDept,
                                  deptIndex: selectedIdx,
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCapabilityCategory({
    required String title,
    required IconData icon,
    required Color color,
    required bool isDark,
    required List<AtomicCapability> capabilities,
    required DepartmentNode activeDept,
    required int deptIndex,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 8),
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...capabilities.map((cap) {
            final isEnabled = activeDept.has(cap);
            return SwitchListTile(
              dense: true,
              value: isEnabled,
              title: Text(_capabilityLabel(cap), style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
              subtitle: Text(_capabilityDesc(cap), style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
              activeColor: color,
              onChanged: (val) => _toggleCapability(deptIndex, cap, val),
            );
          }),
        ],
      ),
    );
  }

  void _toggleCapability(int deptIdx, AtomicCapability cap, bool enabled) {
    final current = blueprintNotifier.value;
    final dept = current.departments[deptIdx];
    final updatedCaps = Set<AtomicCapability>.from(dept.capabilities);

    if (enabled) {
      updatedCaps.add(cap);
    } else {
      updatedCaps.remove(cap);
    }

    final updatedDept = DepartmentNode(
      departmentId: dept.departmentId,
      nameEn: dept.nameEn,
      nameAr: dept.nameAr,
      capabilities: updatedCaps,
      customConfig: dept.customConfig,
    );

    final updatedList = List<DepartmentNode>.from(current.departments);
    updatedList[deptIdx] = updatedDept;

    blueprintNotifier.value = FacilityBlueprint(
      facilityId: current.facilityId,
      facilityName: current.facilityName,
      departments: updatedList,
      sharedGlobalCapabilities: current.sharedGlobalCapabilities,
    );
  }

  void _removeDepartment(int idx) {
    final current = blueprintNotifier.value;
    final updatedList = List<DepartmentNode>.from(current.departments)..removeAt(idx);
    blueprintNotifier.value = FacilityBlueprint(
      facilityId: current.facilityId,
      facilityName: current.facilityName,
      departments: updatedList,
      sharedGlobalCapabilities: current.sharedGlobalCapabilities,
    );
    selectedDeptIndexNotifier.value = 0;
  }

  void _showAddDepartmentDialog(BuildContext context) {
    final enController = TextEditingController();
    final arController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Department Node', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: enController,
                decoration: const InputDecoration(labelText: 'Department Name (English)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: arController,
                decoration: const InputDecoration(labelText: 'اسم القسم (العربية)'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final en = enController.text.trim();
                final ar = arController.text.trim();
                if (en.isNotEmpty) {
                  final id = 'dept_${DateTime.now().millisecondsSinceEpoch}';
                  final newDept = DepartmentNode(
                    departmentId: id,
                    nameEn: en,
                    nameAr: ar.isNotEmpty ? ar : en,
                    capabilities: {AtomicCapability.standardRetailBarcoding},
                  );
                  final current = blueprintNotifier.value;
                  blueprintNotifier.value = FacilityBlueprint(
                    facilityId: current.facilityId,
                    facilityName: current.facilityName,
                    departments: [...current.departments, newDept],
                  );
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _validateAndExport(BuildContext context) {
    final bp = blueprintNotifier.value;
    if (bp.departments.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: Facility must have at least one department.')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.success,
        content: Text('Facility Blueprint exported successfully! (${bp.departments.length} departments active)'),
      ),
    );
    onSaveAndExport?.call();
  }

  static String _capabilityLabel(AtomicCapability cap) {
    switch (cap) {
      case AtomicCapability.clinicalEncounter3dCanvas:
        return '3D Interactive Anatomical Vector Canvas';
      case AtomicCapability.specializedClinicalCharting:
        return 'Specialized Clinical Charting & Diagnostics';
      case AtomicCapability.diagnosticRadiologyLightbox:
        return 'Diagnostic Lightbox (DICOM / X-Ray / CT / MRI)';
      case AtomicCapability.laboratorySpecimenTracking:
        return 'Laboratory Specimen & Bloodwork Tracking';
      case AtomicCapability.fefoBatchInventory:
        return 'FEFO Expiry Batch Inventory Management';
      case AtomicCapability.standardRetailBarcoding:
        return 'Standard Retail Barcode & Stock Tracking';
      case AtomicCapability.consumableAutoDepletion:
        return 'Procedure Consumables Auto-Depletion';
      case AtomicCapability.timeSlotAppointmentEngine:
        return 'Time-Slot Appointment & Provider Booking';
      case AtomicCapability.tableFloorMapManagement:
        return 'Table Floor Map & Kitchen Orders (KDS)';
      case AtomicCapability.multiSessionPackageCredit:
        return 'Multi-Session Packages & Punch-Cards';
      case AtomicCapability.multiDayStayBoarding:
        return 'Multi-Day Stay, Room & Bed Boarding';
      case AtomicCapability.multiProviderCommission:
        return 'Multi-Provider Commission & Revenue Split';
      case AtomicCapability.insuranceCopayDeductible:
        return 'Insurance Policy, Copay & Ledger Credit';
      case AtomicCapability.unifiedCrossDepartmentCart:
        return 'Unified Cross-Department Single Invoice Cart';
      case AtomicCapability.unifiedQueueDispatchHub:
        return 'Unified Reception Queue & Kiosk Dispatch';
    }
  }

  static String _capabilityDesc(AtomicCapability cap) {
    switch (cap) {
      case AtomicCapability.clinicalEncounter3dCanvas:
        return 'Enables polymorphic 3D vector morphology projection and anatomical condition tracking.';
      case AtomicCapability.specializedClinicalCharting:
        return 'Enables periodontal, optical Rx, audiogram, growth curves, or antenatal charting.';
      case AtomicCapability.diagnosticRadiologyLightbox:
        return 'Provides 0.5x–4.0x zoom, pan, rotation, and grayscale contrast inversion.';
      case AtomicCapability.laboratorySpecimenTracking:
        return 'Enables structured tabular lab parameter logging with automatic range flags.';
      case AtomicCapability.fefoBatchInventory:
        return 'First-Expiry-First-Out dispensing for pharmaceuticals and cold-chain items.';
      case AtomicCapability.standardRetailBarcoding:
        return 'High-speed barcode scanner checkout and real-time shelf inventory decrements.';
      case AtomicCapability.consumableAutoDepletion:
        return 'Auto-decrements linked supplies (syringes, gloves, implants) when procedures run.';
      case AtomicCapability.timeSlotAppointmentEngine:
        return 'Prevents double-booking and manages practitioner schedule slots.';
      case AtomicCapability.tableFloorMapManagement:
        return 'Visual table layouts, split bills, kitchen tickets, and table transfers.';
      case AtomicCapability.multiSessionPackageCredit:
        return 'Punch-card credit deduction for PT packages, gym packs, or spa courses.';
      case AtomicCapability.multiDayStayBoarding:
        return 'Nightly rate tracking for hospital wards, boutique hotels, or pet boarding.';
      case AtomicCapability.multiProviderCommission:
        return 'Dynamically splits consultation or service revenue across attending staff.';
      case AtomicCapability.insuranceCopayDeductible:
        return 'Computes copay percentages, patient debt ledgers, and insurance claims.';
      case AtomicCapability.unifiedCrossDepartmentCart:
        return 'Consolidates multi-department goods and services into a single receipt.';
      case AtomicCapability.unifiedQueueDispatchHub:
        return 'Single front-desk reception ticket routes dynamically to multiple stations.';
    }
  }
}
