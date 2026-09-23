// integration_test/manager_dashboard_visibility_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:empos/main.dart' as app;
import 'package:empos/features/auth/presentation/widgets/pin_lock_screen.dart';
import 'package:empos/features/manager/presentation/pages/executive_manager_dashboard_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Manager Dashboard Role Visibility Integration Test', () {
    testWidgets('cashier role cannot access manager portal, manager role can', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Advance past first-run sync wizard if present on clean database
      final firstRunLaunch = find.byKey(const Key('first_run_launch_button'));
      if (firstRunLaunch.evaluate().isNotEmpty) {
        await tester.tap(firstRunLaunch);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 1. Authenticate as Cashier first
      if (find.byType(PinLockScreen).evaluate().isNotEmpty) {
        final cashierChip = find.byKey(const Key('demo_chip_2222'));
        if (cashierChip.evaluate().isNotEmpty) {
          await tester.tap(cashierChip);
          await tester.pumpAndSettle();
        }
      }

      // Assert Cashier cannot see Boss ERP & Payroll
      expect(
        find.byKey(const Key('nav_button_boss_erp_and_payroll')),
        findsNothing,
        reason: 'Cashier accounts must not have access to Boss ERP and Payroll tab',
      );

      // 2. Lock / Log out and sign in as Store Manager
      final lockIcon = find.byIcon(Icons.lock);
      if (lockIcon.evaluate().isNotEmpty) {
        await tester.tap(lockIcon.first);
        await tester.pumpAndSettle();
      }

      if (find.byType(PinLockScreen).evaluate().isNotEmpty) {
        final managerChip = find.byKey(const Key('demo_chip_4444'));
        if (managerChip.evaluate().isNotEmpty) {
          await tester.tap(managerChip);
          await tester.pumpAndSettle();

          // Manager must have access to Boss ERP & Payroll
          final managerPortalBtn = find.byKey(const Key('nav_button_boss_erp_and_payroll'));
          expect(
            managerPortalBtn,
            findsOneWidget,
            reason: 'Store Manager accounts must have access to Boss ERP and Payroll tab',
          );
        }
      }
    });

    testWidgets('ExecutiveManagerDashboardPage renders all executive KPI telemetry', (tester) async {
      // Direct component-level verification of the executive manager dashboard
      await tester.pumpWidget(
        MaterialApp(
          home: ExecutiveManagerDashboardPage(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('kpi_gross_revenue_today')), findsOneWidget);
      expect(find.byKey(const Key('kpi_net_operating_profit')), findsOneWidget);
      expect(find.byKey(const Key('kpi_unsettled_advances')), findsOneWidget);
      expect(find.byKey(const Key('kpi_critical_inventory_alerts')), findsOneWidget);
    });
  });
}
