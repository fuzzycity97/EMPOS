// integration_test/app_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:empos/main.dart' as app;
import 'package:empos/features/auth/presentation/widgets/pin_lock_screen.dart';
import 'package:empos/core/widgets/main_shell.dart';
import 'package:empos/core/config/presentation/pages/store_builder_wizard_page.dart';
import 'package:empos/features/sync/presentation/first_run_sync_wizard_page.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EMPOS App Smoke Integration Test', () {
    testWidgets('boots successfully to either PinLockScreen, MainShell, or Initial Setup Wizard', (tester) async {
      debugPrint('>>> BEFORE app.main()');
      await app.main();
      debugPrint('>>> AFTER app.main()');
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final activeWidgets = find.byType(Widget).evaluate().map((e) => e.widget.runtimeType.toString()).toSet().toList();
      debugPrint('EMPOS BOOT ACTIVE WIDGETS: $activeWidgets');

      // Upon boot, the app displays either the authentication pin screen,
      // the main operational shell, or the first-run configuration wizard.
      final hasPinLock = find.byType(PinLockScreen).evaluate().isNotEmpty;
      final hasMainShell = find.byType(MainShell).evaluate().isNotEmpty;
      final hasStoreWizard = find.byType(StoreBuilderWizardPage).evaluate().isNotEmpty;
      final hasSyncWizard = find.byType(FirstRunSyncWizardPage).evaluate().isNotEmpty;

      expect(
        hasPinLock || hasMainShell || hasStoreWizard || hasSyncWizard,
        isTrue,
        reason: 'Application must boot to either the secure PIN lock screen, MainShell, Store Wizard, or Sync Wizard',
      );
    });
  });
}
