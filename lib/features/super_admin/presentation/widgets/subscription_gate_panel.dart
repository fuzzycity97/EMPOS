import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/atomic_business_components.dart';
import '../../../../core/config/subscription_tier_controller.dart';
import '../../domain/entities/super_admin_models.dart';

/// Vendor Super-Admin Control Panel for managing tenant clinic subscription tiers
/// and individual atomic capability gates.
/// 100% [StatelessWidget] architecture.
class SubscriptionGatePanel extends StatelessWidget {
  final SuperAdminSession? session;
  final ValueNotifier<String> selectedAccountIdNotifier;
  final SubscriptionTierController controller;

  SubscriptionGatePanel({
    super.key,
    required this.session,
    ValueNotifier<String>? selectedAccountIdNotifier,
    SubscriptionTierController? controller,
  })  : controller = controller ?? SubscriptionTierController.instance,
        selectedAccountIdNotifier = selectedAccountIdNotifier ?? ValueNotifier<String>('clinic_alpha_cairo');

  @override
  Widget build(BuildContext context) {
    // 1. Strict Security Guard: Verify Super-Admin cryptographic session
    if (session == null || !session!.isValid) {
      return _buildAccessDeniedBarrier(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: Super-Admin Operator Badge
          _buildHeader(context, isDark),
          const SizedBox(height: 16),

          // Clinic Accounts Selector Bar
          _buildClinicAccountSelector(context, isDark),
          const SizedBox(height: 16),

          // Active Clinic Account Detail & Capability Gate Switchboard
          Expanded(
            child: SingleChildScrollView(
              child: ValueListenableBuilder<String>(
                valueListenable: selectedAccountIdNotifier,
                builder: (context, activeId, _) {
                  return ValueListenableBuilder<Map<String, ClinicSubscriptionProfile>>(
                    valueListenable: controller.profilesNotifier,
                    builder: (context, profiles, _) {
                      final profile = profiles[activeId];
                      if (profile == null) {
                        return const Center(child: Text('Clinic account not found.'));
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Summary Card with Tier Dropdown
                          _buildProfileSummaryCard(context, profile, isDark),
                          const SizedBox(height: 20),

                          // Capability Gating Switchboard (Categorized)
                          const Text(
                            'Atomic Capability Gating Switchboard (Per-Account Permissions)',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 10),

                          _buildCategorySection(
                            context: context,
                            title: '1. Clinical & 3D Anatomy Engine',
                            icon: LucideIcons.scanFace,
                            isDark: isDark,
                            capabilities: [
                              AtomicCapability.clinicalEncounter3dCanvas,
                              AtomicCapability.specializedClinicalCharting,
                              AtomicCapability.diagnosticRadiologyLightbox,
                              AtomicCapability.laboratorySpecimenTracking,
                            ],
                            profile: profile,
                          ),
                          const SizedBox(height: 12),

                          _buildCategorySection(
                            context: context,
                            title: '2. Pharmaceutical FEFO & Inventory',
                            icon: LucideIcons.package2,
                            isDark: isDark,
                            capabilities: [
                              AtomicCapability.fefoBatchInventory,
                              AtomicCapability.standardRetailBarcoding,
                              AtomicCapability.consumableAutoDepletion,
                            ],
                            profile: profile,
                          ),
                          const SizedBox(height: 12),

                          _buildCategorySection(
                            context: context,
                            title: '3. Appointments, Bookings & Operations',
                            icon: LucideIcons.calendarClock,
                            isDark: isDark,
                            capabilities: [
                              AtomicCapability.timeSlotAppointmentEngine,
                              AtomicCapability.tableFloorMapManagement,
                              AtomicCapability.multiSessionPackageCredit,
                              AtomicCapability.multiDayStayBoarding,
                            ],
                            profile: profile,
                          ),
                          const SizedBox(height: 12),

                          _buildCategorySection(
                            context: context,
                            title: '4. Financial Splits, Insurance & Dispatch',
                            icon: LucideIcons.landmark,
                            isDark: isDark,
                            capabilities: [
                              AtomicCapability.multiProviderCommission,
                              AtomicCapability.insuranceCopayDeductible,
                              AtomicCapability.unifiedCrossDepartmentCart,
                              AtomicCapability.unifiedQueueDispatchHub,
                            ],
                            profile: profile,
                          ),
                          const SizedBox(height: 16),

                          // Targeted Sync Confirmation Banner
                          _buildTargetedSyncBanner(profile, isDark),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.indigo.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.shieldCheck, color: Colors.indigoAccent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'EMPOS Platform Super-Admin Console',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Subscription Tier & Capability Gating • Vendor Security Clearance',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Security Credential Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(LucideIcons.keyRound, size: 12, color: Colors.green),
              const SizedBox(width: 6),
              Text(
                '${session!.adminId} (${session!.role.name})',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.green),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClinicAccountSelector(BuildContext context, bool isDark) {
    return ValueListenableBuilder<Map<String, ClinicSubscriptionProfile>>(
      valueListenable: controller.profilesNotifier,
      builder: (context, profiles, _) {
        return ValueListenableBuilder<String>(
          valueListenable: selectedAccountIdNotifier,
          builder: (context, activeId, _) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: profiles.values.map((p) {
                  final isSelected = p.accountId == activeId;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => selectedAccountIdNotifier.value = p.accountId,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.indigo.withValues(alpha: 0.2)
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.indigoAccent : (isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              LucideIcons.building,
                              size: 14,
                              color: isSelected ? Colors.indigoAccent : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.clinicName,
                                  style: TextStyle(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'ID: ${p.accountId} • ${p.tier.name.toUpperCase()}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProfileSummaryCard(BuildContext context, ClinicSubscriptionProfile profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.clinicName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                'Tenant ID: ${profile.accountId} • Unlocked: ${profile.unlockedCapabilities.length} of ${AtomicCapability.values.length} capabilities',
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
            ),
          ),
          const SizedBox(width: 8),
          // Tier Selector Dropdown
          Row(
            children: [
              const Text('Assigned Tier: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const SizedBox(width: 8),
              DropdownButton<SubscriptionPlanTier>(
                value: profile.tier,
                isDense: true,
                underline: const SizedBox(),
                items: SubscriptionPlanTier.values.map((tier) {
                  return DropdownMenuItem(
                    value: tier,
                    child: Text(tier.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
                onChanged: (newTier) {
                  if (newTier != null) {
                    controller.setTier(accountId: profile.accountId, tier: newTier);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isDark,
    required List<AtomicCapability> capabilities,
    required ClinicSubscriptionProfile profile,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.indigoAccent),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const Divider(height: 16),
          ...capabilities.map((cap) {
            final isUnlocked = profile.isCapabilityUnlocked(cap);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatCapabilityName(cap),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isUnlocked ? null : Colors.grey,
                          ),
                        ),
                        Text(
                          'Key: ${cap.name}',
                          style: const TextStyle(fontSize: 10, color: Colors.grey, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: isUnlocked,
                    activeThumbColor: Colors.indigoAccent,
                    onChanged: (val) {
                      controller.toggleCapability(
                        accountId: profile.accountId,
                        capability: cap,
                        enabled: val,
                      );
                    },
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTargetedSyncBanner(ClinicSubscriptionProfile profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(LucideIcons.radio, size: 14, color: Colors.blue),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Targeted Sync Active: Capability mutations propagate strictly to tenant "${profile.accountId}" peers in real-time.',
              style: const TextStyle(fontSize: 11, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDeniedBarrier(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(LucideIcons.shieldAlert, size: 36, color: Color(0xFFEF4444)),
            SizedBox(height: 12),
            Text(
              'Super-Admin Access Denied',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFFEF4444)),
            ),
            SizedBox(height: 6),
            Text(
              'This panel requires authenticated EMPOS vendor operator credentials. Regular clinic roles (Doctor, Receptionist, Manager, Owner) cannot access this interface.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCapabilityName(AtomicCapability cap) {
    switch (cap) {
      case AtomicCapability.clinicalEncounter3dCanvas:
        return '3D Clinical Encounter Canvas (Dental/Skeletal/Organ)';
      case AtomicCapability.specializedClinicalCharting:
        return 'Specialized Clinical & Odontogram Charting';
      case AtomicCapability.diagnosticRadiologyLightbox:
        return 'Diagnostic Radiology & DICOM Lightbox';
      case AtomicCapability.laboratorySpecimenTracking:
        return 'Laboratory Specimen & Pathology Tracking';
      case AtomicCapability.fefoBatchInventory:
        return 'Pharmaceutical FEFO Batch & Expiry Inventory';
      case AtomicCapability.standardRetailBarcoding:
        return 'Standard Retail Barcoding & Stock Depletion';
      case AtomicCapability.consumableAutoDepletion:
        return 'Automated Clinical Consumable Auto-Deductions';
      case AtomicCapability.timeSlotAppointmentEngine:
        return 'Smart Appointment & Conflict Prevention Engine';
      case AtomicCapability.tableFloorMapManagement:
        return '2D Visual Floor Map & Table Dining Engine';
      case AtomicCapability.multiSessionPackageCredit:
        return 'Multi-Session Punch-Card Package Credits';
      case AtomicCapability.multiDayStayBoarding:
        return 'Multi-Day Boarding & Kennel / Bed Stay';
      case AtomicCapability.multiProviderCommission:
        return 'Multi-Provider Commission & Profit Split';
      case AtomicCapability.insuranceCopayDeductible:
        return 'Insurance Copay & Patient Debt Ledger';
      case AtomicCapability.unifiedCrossDepartmentCart:
        return 'Unified Omni-Cart Cross-Department Billing';
      case AtomicCapability.unifiedQueueDispatchHub:
        return 'Unified Reception Queue & Station Dispatch Hub';
    }
  }
}
