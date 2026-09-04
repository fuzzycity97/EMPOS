import 'package:flutter/foundation.dart';
import '../domain/entities/industry_type.dart';
import 'capability_registry.dart';
import 'subscription_tier_models.dart';

/// Super-Admin Subscription Tier Controller.
/// Manages tenant business accounts, tier preset assignments, and granular
/// capability overrides per account (not globally).
class SubscriptionTierController extends ChangeNotifier {
  final CapabilityRegistry registry;
  final Map<String, AccountSubscriptionProfile> _accounts = {};

  SubscriptionTierController({
    CapabilityRegistry? registry,
  }) : registry = registry ?? CapabilityRegistry.instance;

  /// Retrieves an existing account profile or creates a default one.
  AccountSubscriptionProfile getOrCreateAccount({
    required String accountId,
    required String businessName,
    IndustryVertical vertical = IndustryVertical.retail,
    SubscriptionPlanTier initialTier = SubscriptionPlanTier.basic,
  }) {
    if (_accounts.containsKey(accountId)) {
      return _accounts[accountId]!;
    }

    final now = DateTime.now();
    final profile = AccountSubscriptionProfile(
      accountId: accountId,
      businessName: businessName,
      vertical: vertical,
      assignedTier: initialTier,
      createdAt: now,
      updatedAt: now,
    );

    _accounts[accountId] = profile;
    notifyListeners();
    return profile;
  }

  /// Assigns a named tier preset to a specific account.
  /// If [clearOverrides] is true, removes all individual overrides.
  /// If false, retains existing custom overrides layered over the new preset.
  void assignTierPreset(
    String accountId,
    SubscriptionPlanTier tier, {
    bool clearOverrides = false,
  }) {
    final account = _accounts[accountId];
    if (account == null) return;

    final updated = account.copyWith(
      assignedTier: tier,
      individualOverrides: clearOverrides ? {} : account.individualOverrides,
      updatedAt: DateTime.now(),
    );

    _accounts[accountId] = updated;
    notifyListeners();
  }

  /// Sets an individual capability override (up or down) for a specific account.
  /// Overrides layer on top of the preset without mutating the preset itself.
  void setCapabilityOverride(
    String accountId,
    String capabilityId,
    bool isEnabled,
  ) {
    final account = _accounts[accountId];
    if (account == null) return;

    final newOverrides = Map<String, bool>.from(account.individualOverrides);
    newOverrides[capabilityId] = isEnabled;

    final updated = account.copyWith(
      individualOverrides: newOverrides,
      updatedAt: DateTime.now(),
    );

    _accounts[accountId] = updated;
    notifyListeners();
  }

  /// Removes an individual capability override, reverting it back to preset default.
  void removeCapabilityOverride(String accountId, String capabilityId) {
    final account = _accounts[accountId];
    if (account == null) return;

    final newOverrides = Map<String, bool>.from(account.individualOverrides);
    newOverrides.remove(capabilityId);

    final updated = account.copyWith(
      individualOverrides: newOverrides,
      updatedAt: DateTime.now(),
    );

    _accounts[accountId] = updated;
    notifyListeners();
  }

  /// Clears all individual overrides for an account, returning strictly to preset defaults.
  void resetOverridesToPreset(String accountId) {
    final account = _accounts[accountId];
    if (account == null) return;

    final updated = account.copyWith(
      individualOverrides: {},
      updatedAt: DateTime.now(),
    );

    _accounts[accountId] = updated;
    notifyListeners();
  }

  /// Checks if a specific capability is enabled for a given account.
  /// Evaluation:
  /// 1. If account is deactivated, all non-compliance capabilities return false.
  /// 2. If an individual override exists, returns that override.
  /// 3. Otherwise, returns the assigned tier preset determination.
  bool isCapabilityEnabled(String accountId, String capabilityId) {
    final account = _accounts[accountId];
    if (account == null) return false;

    final capItem = registry.getCapability(capabilityId);
    final isCompliance = capItem?.isRequiredCompliance ?? false;

    final preset = registry.getPreset(account.assignedTier);
    return account.isCapabilityEnabled(
      capabilityId,
      preset: preset,
      isRequiredCompliance: isCompliance,
    );
  }

  /// Resolves the complete set of enabled capability IDs for an account.
  Set<String> getResolvedCapabilities(String accountId) {
    final account = _accounts[accountId];
    if (account == null) return {};

    final preset = registry.getPreset(account.assignedTier);
    final resolved = <String>{};

    for (final item in registry.allCapabilities) {
      if (account.isCapabilityEnabled(
        item.id,
        preset: preset,
        isRequiredCompliance: item.isRequiredCompliance,
      )) {
        resolved.add(item.id);
      }
    }

    return resolved;
  }

  /// Retrieves an account profile.
  AccountSubscriptionProfile? getAccount(String accountId) => _accounts[accountId];

  /// Returns all tracked tenant accounts.
  List<AccountSubscriptionProfile> getAllAccounts() =>
      List.unmodifiable(_accounts.values);

  /// Activates or deactivates an account subscription.
  void setAccountActive(String accountId, bool isActive) {
    final account = _accounts[accountId];
    if (account == null) return;

    final updated = account.copyWith(
      isActive: isActive,
      updatedAt: DateTime.now(),
    );

    _accounts[accountId] = updated;
    notifyListeners();
  }

  /// Updates extensible metadata on an account (used for Task 10c audit logging).
  void updateAccountMetadata(
    String accountId,
    Map<String, dynamic> metadataUpdates,
  ) {
    final account = _accounts[accountId];
    if (account == null) return;

    final merged = Map<String, dynamic>.from(account.metadata)..addAll(metadataUpdates);
    final updated = account.copyWith(
      metadata: merged,
      updatedAt: DateTime.now(),
    );

    _accounts[accountId] = updated;
    notifyListeners();
  }

  /// Convenience lookup for tier presets.
  SubscriptionTierPreset getPreset(SubscriptionPlanTier tier) =>
      registry.getPreset(tier);

  /// Exports full state to JSON map.
  Map<String, dynamic> exportState() {
    return {
      'accounts': _accounts.map((k, v) => MapEntry(k, v.toJson())),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Imports accounts state from JSON map.
  void importState(Map<String, dynamic> json) {
    final accountsMap = json['accounts'] as Map? ?? {};
    for (final entry in accountsMap.entries) {
      if (entry.value is Map) {
        final profile = AccountSubscriptionProfile.fromJson(
          Map<String, dynamic>.from(entry.value as Map),
        );
        _accounts[profile.accountId] = profile;
      }
    }
    notifyListeners();
  }
}
