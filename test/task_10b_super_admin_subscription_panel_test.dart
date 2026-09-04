import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/core/config/subscription/capability_registry.dart';
import 'package:empos/core/config/subscription/subscription_tier_models.dart';
import 'package:empos/core/config/subscription/subscription_tier_controller.dart';
import 'package:empos/features/super_admin/domain/entities/super_admin_models.dart';
import 'package:empos/features/super_admin/presentation/pages/super_admin_subscription_management_page.dart';
import 'package:empos/features/super_admin/presentation/widgets/super_admin_account_detail_view.dart';
import 'package:empos/core/config/subscription/cloud_relay_admin_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 10b/11: Super-Admin Subscription Panel Suite', () {
    late CapabilityRegistry registry;
    late SubscriptionTierController controller;
    late SuperAdminSession validSession;

    setUp(() {
      CloudRelayAdminClient.instance.resetForTesting();
      registry = CapabilityRegistry.instance;
      controller = SubscriptionTierController(registry: registry);
      validSession = SuperAdminSession(
        adminId: 'super_admin_alpha',
        vendorOrganization: 'EMPOS Operations Platform',
        role: SuperAdminRole.vendorOperator,
        sessionToken: 'token_verified_operator_123',
        authenticatedAt: DateTime(2026, 9, 4),
        isCryptographicallyVerified: true,
      );

      // Seed explicit accounts for deterministic testing
      controller.getOrCreateAccount(
        accountId: 'acc_01_dental',
        businessName: 'Apex Dental Specialists',
        vertical: IndustryVertical.medical,
        initialTier: SubscriptionPlanTier.pro,
      );
      controller.updateAccountMetadata('acc_01_dental', {
        'lastSyncTimestamp': '2026-09-04 07:15',
        'connectedTerminals': 4,
        'totalPatientRecords': 520,
        'totalInvoices': 1280,
        'notes': 'Preferred dental beta account',
      });

      controller.getOrCreateAccount(
        accountId: 'acc_02_gym',
        businessName: 'Iron Forge Fitness Gym',
        vertical: IndustryVertical.fitnessSports,
        initialTier: SubscriptionPlanTier.free,
      );
      controller.updateAccountMetadata('acc_02_gym', {
        'lastSyncTimestamp': '2026-09-03 18:00',
        'connectedTerminals': 1,
        'totalCustomerRecords': 85,
        'totalInvoices': 120,
        'notes': 'Free tier gym evaluating upgrade',
      });

      controller.getOrCreateAccount(
        accountId: 'acc_03_restaurant',
        businessName: 'Bella Italia Ristorante',
        vertical: IndustryVertical.foodBeverage,
        initialTier: SubscriptionPlanTier.enterprise,
      );

      controller.getOrCreateAccount(
        accountId: 'acc_04_boutique',
        businessName: 'Silk & Linen Fashion Boutique',
        vertical: IndustryVertical.retail,
        initialTier: SubscriptionPlanTier.basic,
      );
    });

        tearDown(() {
      CloudRelayAdminClient.instance.resetForTesting();
    });

void setDesktopViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('1. Security Guard: Invalid or absent SuperAdminSession renders access denied barrier', (tester) async {
      setDesktopViewport(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: SuperAdminSubscriptionManagementPage(
            session: null, // Unauthenticated
            controller: controller,
          ),
        ),
      );

      expect(find.text('Super-Admin Access Denied'), findsOneWidget);
      expect(find.textContaining('restricted exclusively to authenticated EMPOS platform vendor operators'), findsOneWidget);
      expect(find.text('Apex Dental Specialists'), findsNothing);
    });

    testWidgets('2. Account list displays business name, vertical category, tier badge, and creation date', (tester) async {
      setDesktopViewport(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: SuperAdminSubscriptionManagementPage(
            session: validSession,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check account business names rendered
      expect(find.text('Apex Dental Specialists'), findsWidgets);
      expect(find.text('Iron Forge Fitness Gym'), findsOneWidget);
      expect(find.text('Bella Italia Ristorante'), findsOneWidget);
      expect(find.text('Silk & Linen Fashion Boutique'), findsOneWidget);

      // Check tier badges rendered
      expect(find.text('PRO'), findsWidgets);
      expect(find.text('FREE'), findsWidgets);
      expect(find.text('ENTERPRISE'), findsWidgets);
      expect(find.text('BASIC'), findsWidgets);

      // Check count indicator
      expect(find.text('Showing 4 of 4 registered tenant accounts'), findsOneWidget);
    });

    testWidgets('3. Real-time search and multi-faceted filtering genuinely narrows account list', (tester) async {
      setDesktopViewport(tester);

      await tester.pumpWidget(
        MaterialApp(
          home: SuperAdminSubscriptionManagementPage(
            session: validSession,
            controller: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Search by name "Gym"
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Gym');
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InkWell, 'Iron Forge Fitness Gym'), findsOneWidget);
      expect(find.widgetWithText(InkWell, 'Apex Dental Specialists'), findsNothing);
      expect(find.widgetWithText(InkWell, 'Bella Italia Ristorante'), findsNothing);
      expect(find.text('Showing 1 of 4 registered tenant accounts'), findsOneWidget);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();
      expect(find.text('Showing 4 of 4 registered tenant accounts'), findsOneWidget);

      // Filter by Vertical Category
      await tester.tap(find.text('All Verticals'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Medical, Dental & Clinical Practice').last);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(InkWell, 'Apex Dental Specialists'), findsOneWidget);
      expect(find.widgetWithText(InkWell, 'Iron Forge Fitness Gym'), findsNothing);
      expect(find.text('Showing 1 of 4 registered tenant accounts'), findsOneWidget);
    });

    testWidgets('4. Detailed view shows capability breakdown, distinguishing preset defaults from overrides', (tester) async {
      setDesktopViewport(tester);

      // Add custom override on acc_04_boutique (Basic tier + Pro FEFO feature)
      controller.setCapabilityOverride('acc_04_boutique', 'inventory.fefoExpiryTracking', true);

      final account = controller.getAccount('acc_04_boutique')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperAdminAccountDetailView(
              account: account,
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Silk & Linen Fashion Boutique'), findsOneWidget);
      expect(find.text('OVERRIDE'), findsOneWidget);
      expect(find.text('Preset Default'), findsWidgets);

      // Search specifically for fefo to bring it into instant view
      final searchBox = find.widgetWithText(TextField, 'Search capabilities in this vertical...');
      await tester.enterText(searchBox, 'fefo');
      await tester.pumpAndSettle();

      // Tap revert override button
      final revertButton = find.byTooltip('Revert to preset default');
      expect(revertButton, findsOneWidget);
      await tester.ensureVisible(revertButton);
      await tester.pumpAndSettle();
      await tester.tap(revertButton);
      await tester.pumpAndSettle();

      expect(controller.getAccount('acc_04_boutique')!.hasOverride('inventory.fefoExpiryTracking'), isFalse);
    });

    testWidgets('5. Usage signals display real stored metadata metrics (sync, terminals, records, invoices)', (tester) async {
      setDesktopViewport(tester);

      final account = controller.getAccount('acc_01_dental')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperAdminAccountDetailView(
              account: account,
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('2026-09-04 07:15'), findsOneWidget);
      expect(find.text('4 Terminals Connected'), findsOneWidget);
      expect(find.text('520 Records'), findsOneWidget);
      expect(find.text('1280 Invoices'), findsOneWidget);
    });

    testWidgets('6. Notes field persists edited notes across reloads and updates account metadata', (tester) async {
      setDesktopViewport(tester);

      final account = controller.getAccount('acc_01_dental')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperAdminAccountDetailView(
              account: account,
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Preferred dental beta account'), findsOneWidget);

      // Edit notes field
      final noteField = find.widgetWithText(TextField, 'Preferred dental beta account');
      await tester.enterText(noteField, 'Trial upgraded to Pro tier with 5 chair licenses');
      await tester.pumpAndSettle();

      // Tap Save Note button
      await tester.tap(find.text('Save Note'));
      await tester.pumpAndSettle();

      // Verify persisted in controller
      expect(
        controller.getAccount('acc_01_dental')!.metadata['notes'],
        equals('Trial upgraded to Pro tier with 5 chair licenses'),
      );
    });

    testWidgets('7. Billing history view displays reserved structure with empty state', (tester) async {
      setDesktopViewport(tester);

      final account = controller.getAccount('acc_01_dental')!;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SuperAdminAccountDetailView(
              account: account,
              controller: controller,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Billing & Payment History (Structured Slot)'), findsOneWidget);
      expect(find.text('No billing records yet — payment integration coming soon'), findsOneWidget);
      expect(find.textContaining('Manual super-admin tier assignment active'), findsOneWidget);
    });
  });
}
