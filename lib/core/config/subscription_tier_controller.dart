import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'atomic_business_components.dart';

/// Available subscription plan tiers for EMPOS clinic tenants.
enum SubscriptionPlanTier {
  starter('Starter Tier', 'Core POS, basic queue, appointments & retail catalog'),
  professional('Professional Tier', 'FEFO pharmaceuticals, diagnostics, lab tracking & insurance copay'),
  enterprise('Enterprise Tier', 'Full multi-specialty 3D canvas, commission splits & omni-cart engine'),
  custom('Custom Operator Tier', 'Individually tailored capability set managed by Super-Admin');

  final String label;
  final String description;
  const SubscriptionPlanTier(this.label, this.description);
}

/// Tenant clinic account subscription state.
class ClinicSubscriptionProfile {
  final String accountId;
  final String clinicName;
  final SubscriptionPlanTier tier;
  final Set<AtomicCapability> unlockedCapabilities;
  final bool isActive;
  final DateTime lastSyncedAt;

  const ClinicSubscriptionProfile({
    required this.accountId,
    required this.clinicName,
    required this.tier,
    required this.unlockedCapabilities,
    this.isActive = true,
    required this.lastSyncedAt,
  });

  bool isCapabilityUnlocked(AtomicCapability capability) =>
      isActive && unlockedCapabilities.contains(capability);

  ClinicSubscriptionProfile copyWith({
    String? accountId,
    String? clinicName,
    SubscriptionPlanTier? tier,
    Set<AtomicCapability>? unlockedCapabilities,
    bool? isActive,
    DateTime? lastSyncedAt,
  }) {
    return ClinicSubscriptionProfile(
      accountId: accountId ?? this.accountId,
      clinicName: clinicName ?? this.clinicName,
      tier: tier ?? this.tier,
      unlockedCapabilities: unlockedCapabilities ?? this.unlockedCapabilities,
      isActive: isActive ?? this.isActive,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'clinicName': clinicName,
        'tier': tier.name,
        'unlockedCapabilities': unlockedCapabilities.map((c) => c.name).toList(),
        'isActive': isActive,
        'lastSyncedAt': lastSyncedAt.toIso8601String(),
      };

  factory ClinicSubscriptionProfile.fromJson(Map<String, dynamic> json) {
    return ClinicSubscriptionProfile(
      accountId: json['accountId'] as String,
      clinicName: json['clinicName'] as String,
      tier: SubscriptionPlanTier.values.firstWhere(
        (t) => t.name == json['tier'],
        orElse: () => SubscriptionPlanTier.custom,
      ),
      unlockedCapabilities: (json['unlockedCapabilities'] as List? ?? [])
          .map((item) => AtomicCapability.values.firstWhere(
                (c) => c.name == item,
                orElse: () => AtomicCapability.standardRetailBarcoding,
              ))
          .toSet(),
      isActive: json['isActive'] as bool? ?? true,
      lastSyncedAt: DateTime.tryParse(json['lastSyncedAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

/// Central controller managing per-account subscription tier feature gating.
/// Architecturally decoupled from clinic-facing user roles.
class SubscriptionTierController {
  static final SubscriptionTierController instance = SubscriptionTierController._internal();

  SubscriptionTierController._internal() {
    _initDefaultProfiles();
  }

  String currentAccountId = 'clinic_alpha_cairo';

  late final ValueNotifier<Map<String, ClinicSubscriptionProfile>> profilesNotifier;
  final StreamController<Map<String, dynamic>> _targetedSyncStreamController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get targetedSyncStream => _targetedSyncStreamController.stream;

  static final Map<SubscriptionPlanTier, Set<AtomicCapability>> tierCapabilityMatrix = {
    SubscriptionPlanTier.starter: {
      AtomicCapability.standardRetailBarcoding,
      AtomicCapability.unifiedCrossDepartmentCart,
      AtomicCapability.timeSlotAppointmentEngine,
      AtomicCapability.unifiedQueueDispatchHub,
    },
    SubscriptionPlanTier.professional: {
      AtomicCapability.standardRetailBarcoding,
      AtomicCapability.unifiedCrossDepartmentCart,
      AtomicCapability.timeSlotAppointmentEngine,
      AtomicCapability.unifiedQueueDispatchHub,
      AtomicCapability.fefoBatchInventory,
      AtomicCapability.consumableAutoDepletion,
      AtomicCapability.specializedClinicalCharting,
      AtomicCapability.diagnosticRadiologyLightbox,
      AtomicCapability.laboratorySpecimenTracking,
      AtomicCapability.insuranceCopayDeductible,
    },
    SubscriptionPlanTier.enterprise: AtomicCapability.values.toSet(),
    SubscriptionPlanTier.custom: {},
  };

  void _initDefaultProfiles() {
    final now = DateTime.now();
    profilesNotifier = ValueNotifier<Map<String, ClinicSubscriptionProfile>>({
      'clinic_alpha_cairo': ClinicSubscriptionProfile(
        accountId: 'clinic_alpha_cairo',
        clinicName: 'Cairo Downtown Medical & Dental Center',
        tier: SubscriptionPlanTier.professional,
        unlockedCapabilities: Set<AtomicCapability>.from(tierCapabilityMatrix[SubscriptionPlanTier.professional]!),
        isActive: true,
        lastSyncedAt: now,
      ),
      'clinic_beta_alex': ClinicSubscriptionProfile(
        accountId: 'clinic_beta_alex',
        clinicName: 'Alexandria Seafront Polyclinic',
        tier: SubscriptionPlanTier.enterprise,
        unlockedCapabilities: Set<AtomicCapability>.from(tierCapabilityMatrix[SubscriptionPlanTier.enterprise]!),
        isActive: true,
        lastSyncedAt: now,
      ),
      'clinic_gamma_giza': ClinicSubscriptionProfile(
        accountId: 'clinic_gamma_giza',
        clinicName: 'Giza Suburban Clinic & Pharmacy',
        tier: SubscriptionPlanTier.starter,
        unlockedCapabilities: Set<AtomicCapability>.from(tierCapabilityMatrix[SubscriptionPlanTier.starter]!),
        isActive: true,
        lastSyncedAt: now,
      ),
    });
  }

  /// Checks if a capability is unlocked for a given tenant account.
  bool isCapabilityUnlocked({required String accountId, required AtomicCapability capability}) {
    final profile = profilesNotifier.value[accountId];
    if (profile == null) return false;
    return profile.isCapabilityUnlocked(capability);
  }

  /// Checks if a capability is unlocked for the active clinic instance.
  bool isUnlockedForCurrentAccount(AtomicCapability capability) {
    return isCapabilityUnlocked(accountId: currentAccountId, capability: capability);
  }

  /// Super-admin manual toggle of an individual capability for a specific tenant account.
  void toggleCapability({
    required String accountId,
    required AtomicCapability capability,
    required bool enabled,
  }) {
    final currentMap = Map<String, ClinicSubscriptionProfile>.from(profilesNotifier.value);
    final existing = currentMap[accountId];
    if (existing == null) return;

    final updatedCaps = Set<AtomicCapability>.from(existing.unlockedCapabilities);
    if (enabled) {
      updatedCaps.add(capability);
    } else {
      updatedCaps.remove(capability);
    }

    final updatedProfile = existing.copyWith(
      tier: SubscriptionPlanTier.custom,
      unlockedCapabilities: updatedCaps,
      lastSyncedAt: DateTime.now(),
    );

    currentMap[accountId] = updatedProfile;
    profilesNotifier.value = currentMap;

    // Dispatch targeted real-time sync event to that specific clinic's connected clients
    _dispatchTargetedSync(updatedProfile);
  }

  /// Super-admin plan tier assignment for a specific tenant account.
  void setTier({
    required String accountId,
    required SubscriptionPlanTier tier,
  }) {
    final currentMap = Map<String, ClinicSubscriptionProfile>.from(profilesNotifier.value);
    final existing = currentMap[accountId];
    if (existing == null) return;

    final baseCaps = tier == SubscriptionPlanTier.custom
        ? existing.unlockedCapabilities
        : Set<AtomicCapability>.from(tierCapabilityMatrix[tier] ?? {});

    final updatedProfile = existing.copyWith(
      tier: tier,
      unlockedCapabilities: baseCaps,
      lastSyncedAt: DateTime.now(),
    );

    currentMap[accountId] = updatedProfile;
    profilesNotifier.value = currentMap;

    // Dispatch targeted real-time sync event
    _dispatchTargetedSync(updatedProfile);
  }

  void _dispatchTargetedSync(ClinicSubscriptionProfile profile) {
    _targetedSyncStreamController.add({
      'type': 'system.subscription_capabilities_updated',
      'targetAccountId': profile.accountId,
      'tier': profile.tier.name,
      'unlockedCapabilities': profile.unlockedCapabilities.map((c) => c.name).toList(),
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

/// Generic clinic-facing wrapper that gates features behind subscription tiers.
/// Displays a polite, generic "not available on your plan" notice without exposing system details.
class SubscriptionGatedWidget extends StatelessWidget {
  final AtomicCapability capability;
  final Widget child;
  final Widget? lockedPlaceholder;
  final String? accountId;

  const SubscriptionGatedWidget({
    super.key,
    required this.capability,
    required this.child,
    this.lockedPlaceholder,
    this.accountId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = SubscriptionTierController.instance;
    final targetAccount = accountId ?? controller.currentAccountId;

    return ValueListenableBuilder<Map<String, ClinicSubscriptionProfile>>(
      valueListenable: controller.profilesNotifier,
      builder: (context, profiles, _) {
        final profile = profiles[targetAccount];
        final isUnlocked = profile?.isCapabilityUnlocked(capability) ?? false;

        if (isUnlocked) {
          return child;
        }

        return lockedPlaceholder ?? _buildGenericLockedNotice(context);
      },
    );
  }

  Widget _buildGenericLockedNotice(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        constraints: const BoxConstraints(maxWidth: 440),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                LucideIcons.lock,
                size: 24,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Feature Unavailable',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: -0.2,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "This feature isn't included in your current plan. Please contact your EMPOS administrator or vendor representative to upgrade your subscription.",
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
