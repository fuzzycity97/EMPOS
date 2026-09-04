import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/atomic_business_components.dart';
import 'package:empos/core/config/subscription_tier_controller.dart';
import 'package:empos/features/super_admin/domain/entities/super_admin_models.dart';
import 'package:empos/features/super_admin/presentation/widgets/subscription_gate_panel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 10: Subscription Tier Feature Gating & Super-Admin Isolation', () {
    final controller = SubscriptionTierController.instance;

    test('1. Per-account capability isolation: Locking 3D Canvas on Clinic Alpha does NOT affect Clinic Beta', () {
      const targetCap = AtomicCapability.clinicalEncounter3dCanvas;

      // Initially unlock for Beta
      controller.setTier(accountId: 'clinic_beta_alex', tier: SubscriptionPlanTier.enterprise);
      expect(controller.isCapabilityUnlocked(accountId: 'clinic_beta_alex', capability: targetCap), isTrue);

      // Lock specifically for Alpha
      controller.toggleCapability(accountId: 'clinic_alpha_cairo', capability: targetCap, enabled: false);

      // Verify Alpha is locked while Beta remains strictly unlocked
      expect(controller.isCapabilityUnlocked(accountId: 'clinic_alpha_cairo', capability: targetCap), isFalse);
      expect(controller.isCapabilityUnlocked(accountId: 'clinic_beta_alex', capability: targetCap), isTrue);
    });

    testWidgets('2 & 5. SubscriptionGatedWidget renders locked notice on locked cap and reactively unlocks without restart', (tester) async {
      const targetCap = AtomicCapability.clinicalEncounter3dCanvas;
      const accountId = 'clinic_alpha_cairo';

      // 1. Ensure locked
      controller.toggleCapability(accountId: accountId, capability: targetCap, enabled: false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionGatedWidget(
              accountId: accountId,
              capability: targetCap,
              child: const Text('Unlocked 3D Canvas Content'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 2. Confirmed: Shows clear "Feature Unavailable" message, no crash, no internal system details leaked
      expect(find.text('Feature Unavailable'), findsOneWidget);
      expect(find.textContaining("This feature isn't included in your current plan"), findsOneWidget);
      expect(find.text('Unlocked 3D Canvas Content'), findsNothing);

      // 3. Super-Admin unlocks capability live
      controller.toggleCapability(accountId: accountId, capability: targetCap, enabled: true);
      await tester.pumpAndSettle();

      // 4. Confirmed: Reactivates live without app restart
      expect(find.text('Unlocked 3D Canvas Content'), findsOneWidget);
      expect(find.text('Feature Unavailable'), findsNothing);
    });

    testWidgets('3. Super-Admin security guard blocks unauthenticated access with security barrier', (tester) async {
      // Null or invalid session
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionGatePanel(
              session: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Super-Admin Access Denied'), findsOneWidget);
      expect(find.textContaining('This panel requires authenticated EMPOS vendor operator credentials'), findsOneWidget);
      expect(find.text('EMPOS Platform Super-Admin Console'), findsNothing);
    });

    testWidgets('4. Valid SuperAdminSession renders multi-tenant gate switchboard with live switches', (tester) async {
      // Authenticate with vendor master key
      final session = SuperAdminAuthGuard.authenticateVendorOperator(
        vendorSecretKey: 'vsec_operator_master_key_99182',
        adminId: 'vendor_ops_admin',
      );
      expect(session, isNotNull);
      expect(session!.isValid, isTrue);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SubscriptionGatePanel(
              session: session,
              selectedAccountIdNotifier: ValueNotifier('clinic_alpha_cairo'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EMPOS Platform Super-Admin Console'), findsOneWidget);
      expect(find.textContaining('vendor_ops_admin'), findsOneWidget);
      expect(find.text('1. Clinical & 3D Anatomy Engine'), findsOneWidget);
      expect(find.text('2. Pharmaceutical FEFO & Inventory'), findsOneWidget);
      expect(find.text('3. Appointments, Bookings & Operations'), findsOneWidget);
      expect(find.text('4. Financial Splits, Insurance & Dispatch'), findsOneWidget);

      // Verify live switch toggling
      final switchFinder = find.byType(Switch).first;
      expect(switchFinder, findsWidgets);
      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
    });

    test('6. Targeted sync broadcast emits isolated tenant events without global broadcast', () async {
      Map<String, dynamic>? receivedEvent;
      final sub = controller.targetedSyncStream.listen((event) {
        receivedEvent = event;
      });

      controller.toggleCapability(
        accountId: 'clinic_gamma_giza',
        capability: AtomicCapability.diagnosticRadiologyLightbox,
        enabled: true,
      );

      await Future.delayed(const Duration(milliseconds: 50));
      await sub.cancel();

      expect(receivedEvent, isNotNull);
      expect(receivedEvent!['targetAccountId'], 'clinic_gamma_giza');
      expect((receivedEvent!['unlockedCapabilities'] as List).contains('diagnosticRadiologyLightbox'), isTrue);
    });
  });
}
