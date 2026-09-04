import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/core/config/subscription/capability_registry.dart';
import 'package:empos/core/config/subscription/subscription_tier_models.dart';
import 'package:empos/core/config/subscription/subscription_tier_controller.dart';

void main() {
  group('Task 10a/11: Universal Subscription Tier Presets & Granular Capability Model', () {
    late CapabilityRegistry registry;
    late SubscriptionTierController controller;

    setUp(() {
      registry = CapabilityRegistry.instance;
      controller = SubscriptionTierController(registry: registry);
    });

    test('1. Registry exhaustively catalogs 500+ granular capabilities across 11 verticals & 41 blueprints', () {
      expect(registry.count, greaterThanOrEqualTo(500));

      // Check all 16 CapabilityCategory values exist in catalog
      for (final cat in CapabilityCategory.values) {
        final items = registry.getByCategory(cat);
        expect(items, isNotEmpty, reason: 'Category ${cat.name} must have registered capabilities');
      }

      // Check core modular sub-features highlighted in specification
      expect(registry.getCapability('dental3D.rotateZoom'), isNotNull);
      expect(registry.getCapability('dental3D.tapToEditStatus'), isNotNull);
      expect(registry.getCapability('dental3D.modblSurfaceCharting'), isNotNull);
      expect(registry.getCapability('dental3D.realTextureModels'), isNotNull);

      expect(registry.getCapability('scheduling.basicBooking'), isNotNull);
      expect(registry.getCapability('scheduling.conflictGuard'), isNotNull);
      expect(registry.getCapability('scheduling.multiDoctorFilter'), isNotNull);
      expect(registry.getCapability('scheduling.recallReminders'), isNotNull);
      expect(registry.getCapability('scheduling.noShowTracking'), isNotNull);

      expect(registry.getCapability('inventory.basicStock'), isNotNull);
      expect(registry.getCapability('inventory.lowStockAlerts'), isNotNull);
      expect(registry.getCapability('inventory.fefoExpiryTracking'), isNotNull);
      expect(registry.getCapability('inventory.usageAnalytics'), isNotNull);

      expect(registry.getCapability('finance.basicCheckout'), isNotNull);
      expect(registry.getCapability('finance.splitPayments'), isNotNull);
      expect(registry.getCapability('finance.partialPaymentLedger'), isNotNull);
      expect(registry.getCapability('finance.insuranceDiscountFields'), isNotNull);
      expect(registry.getCapability('finance.multiPartySplitEngine'), isNotNull);

      expect(registry.getCapability('sync.singleDeviceOnly'), isNotNull);
      expect(registry.getCapability('sync.multiDeviceLAN'), isNotNull);
      expect(registry.getCapability('sync.autoReconnect'), isNotNull);
      expect(registry.getCapability('sync.cloudTunnelSupport'), isNotNull);

      // Spot-check real blueprint toggles across distinct verticals
      expect(registry.getCapability('sw.clinic_allergy_flags'), isNotNull);
      expect(registry.getCapability('sw.dental_tooth_chart_editor'), isNotNull);
      expect(registry.getCapability('sw.rest_table_layout_map'), isNotNull);
      expect(registry.getCapability('sw.auto_parts_inventory_autodeduct'), isNotNull);
      expect(registry.getCapability('sw.gym_membership_qr_checkin_validator'), isNotNull);
      expect(registry.getCapability('sw.retail_operator_shift_switch'), isNotNull);
      expect(registry.getCapability('sw.trade_van_truck_stock_inventory'), isNotNull);
    });

    test('2. Rule B typed search finds capabilities by name, ID, category, and plain-language terms', () {
      // Search by plain-language synonyms
      final dentalSearch = registry.search('tooth');
      expect(dentalSearch, isNotEmpty);
      expect(dentalSearch.any((c) => c.category == CapabilityCategory.dental3D), isTrue);

      final conflictSearch = registry.search('double_booking');
      expect(conflictSearch, isNotEmpty);
      expect(conflictSearch.any((c) => c.id == 'scheduling.conflictGuard'), isTrue);

      final fefoSearch = registry.search('fefo');
      expect(fefoSearch, isNotEmpty);
      expect(fefoSearch.any((c) => c.id == 'inventory.fefoExpiryTracking'), isTrue);

      final kdsSearch = registry.search('kds');
      expect(kdsSearch, isNotEmpty);

      final turnstileSearch = registry.search('turnstile');
      expect(turnstileSearch, isNotEmpty);

      final emptySearch = registry.search('');
      expect(emptySearch.length, equals(registry.count));
    });

    test('3. Tier presets define distinct capability sets and Enterprise auto-unlocks all capabilities', () {
      final freePreset = registry.getPreset(SubscriptionPlanTier.free);
      final basicPreset = registry.getPreset(SubscriptionPlanTier.basic);
      final proPreset = registry.getPreset(SubscriptionPlanTier.pro);
      final enterprisePreset = registry.getPreset(SubscriptionPlanTier.enterprise);

      // Free tier is minimal and strictly limited
      expect(freePreset.isCapabilityIncluded('finance.basicCheckout'), isTrue);
      expect(freePreset.isCapabilityIncluded('sync.singleDeviceOnly'), isTrue);
      expect(freePreset.isCapabilityIncluded('dental3D.modblSurfaceCharting'), isFalse);
      expect(freePreset.isCapabilityIncluded('inventory.fefoExpiryTracking'), isFalse);
      expect(freePreset.isCapabilityIncluded('sync.multiDeviceLAN'), isFalse);
      expect(freePreset.maxTerminals, equals(1));

      // Basic tier adds core operations
      expect(basicPreset.isCapabilityIncluded('sync.multiDeviceLAN'), isTrue);
      expect(basicPreset.isCapabilityIncluded('scheduling.conflictGuard'), isTrue);
      expect(basicPreset.isCapabilityIncluded('finance.partialPaymentLedger'), isTrue);
      expect(basicPreset.isCapabilityIncluded('dental3D.modblSurfaceCharting'), isFalse);
      expect(basicPreset.isCapabilityIncluded('inventory.fefoExpiryTracking'), isFalse);

      // Pro tier adds specialty & 3D clinical tools
      expect(proPreset.isCapabilityIncluded('dental3D.modblSurfaceCharting'), isTrue);
      expect(proPreset.isCapabilityIncluded('inventory.fefoExpiryTracking'), isTrue);
      expect(proPreset.isCapabilityIncluded('clinical3D.cardiologyCaliper'), isTrue);
      expect(proPreset.isCapabilityIncluded('finance.multiPartySplitEngine'), isTrue);

      // Enterprise tier unlocks everything by default
      expect(enterprisePreset.includesAllByDefault, isTrue);
      expect(enterprisePreset.isCapabilityIncluded('dental3D.modblSurfaceCharting'), isTrue);
      expect(enterprisePreset.isCapabilityIncluded('inventory.multiWarehouseTransfer'), isTrue);
      expect(enterprisePreset.isCapabilityIncluded('sync.otaFirmwarePush'), isTrue);

      // Dynamic new capability auto-unlocked in Enterprise
      const futureCap = CapabilityItem(
        id: 'future.teleportationSync',
        name: 'Quantum Teleportation Sync',
        description: 'Instant zero-latency teleportation synchronization',
        category: CapabilityCategory.sync,
        minTier: SubscriptionPlanTier.enterprise,
      );
      registry.register(futureCap);
      expect(enterprisePreset.isCapabilityIncluded('future.teleportationSync'), isTrue);
    });

    test('4. SubscriptionTierController isolates accounts and layers overrides without corrupting presets', () {
      final clinic = controller.getOrCreateAccount(
        accountId: 'acc_dental_cairo',
        businessName: 'Cairo Dental Excellence',
        vertical: IndustryVertical.medical,
        initialTier: SubscriptionPlanTier.basic,
      );

      final gym = controller.getOrCreateAccount(
        accountId: 'acc_gym_alex',
        businessName: 'Alexandria Power Gym',
        vertical: IndustryVertical.fitnessSports,
        initialTier: SubscriptionPlanTier.basic,
      );

      // Initial state: Basic tier does not have MODBL 3D surface charting (Pro feature)
      expect(controller.isCapabilityEnabled(clinic.accountId, 'dental3D.modblSurfaceCharting'), isFalse);
      expect(controller.isCapabilityEnabled(clinic.accountId, 'scheduling.conflictGuard'), isTrue);

      // Customer pays for MODBL add-on: Super-admin overrides capability UP
      controller.setCapabilityOverride(clinic.accountId, 'dental3D.modblSurfaceCharting', true);
      expect(controller.isCapabilityEnabled(clinic.accountId, 'dental3D.modblSurfaceCharting'), isTrue);

      // Verify Gym account is unaffected (Tenant Isolation)
      expect(controller.isCapabilityEnabled(gym.accountId, 'dental3D.modblSurfaceCharting'), isFalse);

      // Verify Base Basic Preset definition is completely unmutated
      final basicPreset = registry.getPreset(SubscriptionPlanTier.basic);
      expect(basicPreset.isCapabilityIncluded('dental3D.modblSurfaceCharting'), isFalse);

      // Super-admin overrides a Basic feature DOWN (e.g. customer disabled conflict guard)
      controller.setCapabilityOverride(clinic.accountId, 'scheduling.conflictGuard', false);
      expect(controller.isCapabilityEnabled(clinic.accountId, 'scheduling.conflictGuard'), isFalse);

      // Reset overrides to preset defaults
      controller.resetOverridesToPreset(clinic.accountId);
      expect(controller.isCapabilityEnabled(clinic.accountId, 'dental3D.modblSurfaceCharting'), isFalse);
      expect(controller.isCapabilityEnabled(clinic.accountId, 'scheduling.conflictGuard'), isTrue);
    });

    test('5. Serialization and state export/import accurately preserves account profiles and overrides', () {
      controller.getOrCreateAccount(
        accountId: 'acc_pharma_01',
        businessName: 'Al-Shifa Community Pharmacy',
        vertical: IndustryVertical.medical,
        initialTier: SubscriptionPlanTier.pro,
      );

      controller.setCapabilityOverride('acc_pharma_01', 'sync.otaFirmwarePush', true);
      controller.updateAccountMetadata('acc_pharma_01', {
        'billingContact': 'dr.omar@alshifa.com',
        'superAdminNotes': 'VIP Clinical Beta Partner',
      });

      // Export state
      final exportedJson = controller.exportState();
      expect(exportedJson['accounts'], isNotNull);

      // Re-hydrate into new controller instance
      final newController = SubscriptionTierController(registry: registry);
      newController.importState(exportedJson);

      final rehydrated = newController.getAccount('acc_pharma_01');
      expect(rehydrated, isNotNull);
      expect(rehydrated!.businessName, equals('Al-Shifa Community Pharmacy'));
      expect(rehydrated.assignedTier, equals(SubscriptionPlanTier.pro));
      expect(rehydrated.individualOverrides['sync.otaFirmwarePush'], isTrue);
      expect(rehydrated.metadata['superAdminNotes'], equals('VIP Clinical Beta Partner'));

      // Check resolved capabilities via rehydrated controller
      expect(newController.isCapabilityEnabled('acc_pharma_01', 'sync.otaFirmwarePush'), isTrue);
      expect(newController.isCapabilityEnabled('acc_pharma_01', 'inventory.fefoExpiryTracking'), isTrue);
    });
  });
}
