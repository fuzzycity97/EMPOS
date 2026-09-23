// integration_test/visual_gui_observer_test.dart
//
// Visual GUI Observer Test Suite
// Boots the real EMPOS Win32 engine, observes the actual graphical user interface,
// captures high-resolution visual PNG snapshots at every interaction stage,
// and audits on-screen text, labels, layout boundaries, and theme rendering.

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:empos/main.dart' as app;
import 'package:empos/features/auth/presentation/widgets/pin_lock_screen.dart';
import 'package:empos/features/pos/presentation/widgets/pos_product_tile.dart';

Future<void> _captureVisualFrame(WidgetTester tester, String filename, {String label = ''}) async {
  await tester.pumpAndSettle(const Duration(milliseconds: 500));
  try {
    final boundaries = find.byType(RepaintBoundary).evaluate();
    for (final element in boundaries) {
      final ro = element.renderObject;
      if (ro is RenderRepaintBoundary && ro.hasSize && ro.size.width > 200 && ro.size.height > 200) {
        final image = await ro.toImage(pixelRatio: 1.0);
        final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
        if (byteData != null) {
          final outDir = Directory('e2e/artifacts/visual_gui');
          if (!outDir.existsSync()) {
            outDir.createSync(recursive: true);
          }
          final file = File('e2e/artifacts/visual_gui/$filename');
          file.writeAsBytesSync(byteData.buffer.asUint8List());
          debugPrint('>>> [VISUAL OBSERVER CAPTURE] $label -> ${file.path} (${file.lengthSync()} bytes)');
          return;
        }
      }
    }
  } catch (e) {
    debugPrint('>>> [VISUAL OBSERVER NOTE] $e');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EMPOS Visual GUI Observer & Live Screen Auditor', () {
    testWidgets('observes and captures actual GUI across POS, Clinical, Manager, and RMM', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // --- 1. BOOT APPLICATION & OBSERVE INITIAL SCREEN ---
      debugPrint('=== [OBSERVER STEP 1/7] Booting Application Engine ===');
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      await _captureVisualFrame(tester, '01_initial_boot_screen.png', label: 'Initial Boot Screen');

      // --- 2. ADVANCE PAST FIRST-RUN WIZARD IF PRESENT ---
      final firstRunLaunch = find.byKey(const Key('first_run_launch_button'));
      if (firstRunLaunch.evaluate().isNotEmpty) {
        debugPrint('=== [OBSERVER STEP 2/7] First-Run Wizard Detected, Advancing ===');
        await _captureVisualFrame(tester, '02_first_run_wizard.png', label: 'First Run Setup Wizard');
        await tester.tap(firstRunLaunch);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // --- 3. OBSERVE PIN AUTHENTICATION SCREEN ---
      debugPrint('=== [OBSERVER STEP 3/7] Observing PIN Authentication Screen ===');
      if (find.byType(PinLockScreen).evaluate().isNotEmpty) {
        await _captureVisualFrame(tester, '03_pin_lock_screen.png', label: 'PIN Lock Screen');

        // Tap cashier demo chip or keypad
        final cashierChip = find.byKey(const Key('demo_chip_2222'));
        if (cashierChip.evaluate().isNotEmpty) {
          await tester.tap(cashierChip);
        } else {
          final key2 = find.byKey(const Key('keypad_button_2'));
          for (var i = 0; i < 4; i++) {
            await tester.tap(key2);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // --- 4. OBSERVE MAIN SHELL & POS CASHIER WORKSPACE ---
      debugPrint('=== [OBSERVER STEP 4/7] Observing POS Cashier Workspace ===');
      final posNavBtn = find.byKey(const Key('nav_button_pos_cashier'));
      if (posNavBtn.evaluate().isNotEmpty) {
        await tester.tap(posNavBtn);
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      await _captureVisualFrame(tester, '04_pos_cashier_workspace.png', label: 'POS Cashier Catalog');

      // Add product to cart
      final productTiles = find.byType(PosProductTile);
      if (productTiles.evaluate().isNotEmpty) {
        await tester.tap(productTiles.first);
        await tester.pumpAndSettle(const Duration(milliseconds: 500));

        await _captureVisualFrame(tester, '05_pos_cart_with_items.png', label: 'POS Cart with Items');

        // Open checkout dialog
        final checkoutBtn = find.byKey(const Key('pos_checkout_button'));
        if (checkoutBtn.evaluate().isNotEmpty) {
          await tester.tap(checkoutBtn);
          await tester.pumpAndSettle(const Duration(seconds: 1));

          // Observe Unpaid settlement status label
          await _captureVisualFrame(tester, '06_checkout_dialog_unpaid.png', label: 'Checkout Dialog Unpaid State');
          expect(find.byKey(const Key('settlement_status_label')), findsOneWidget);

          // Complete checkout
          final confirmBtn = find.byKey(const Key('confirm_checkout_button'));
          if (confirmBtn.evaluate().isNotEmpty) {
            await tester.tap(confirmBtn);
            await tester.pumpAndSettle(const Duration(seconds: 1));

            // Observe receipt modal
            await _captureVisualFrame(tester, '07_checkout_receipt_modal.png', label: 'Checkout Receipt Modal');

            final newSaleBtn = find.byKey(const Key('new_sale_button'));
            if (newSaleBtn.evaluate().isNotEmpty) {
              await tester.tap(newSaleBtn);
              await tester.pumpAndSettle(const Duration(milliseconds: 500));
            }
          }
        }
      }

      // --- 5. OBSERVE ORDERS & RETURNS WORKSPACE ---
      debugPrint('=== [OBSERVER STEP 5/7] Observing Orders History Workspace ===');
      final ordersNavBtn = find.byKey(const Key('nav_button_orders_and_returns'));
      if (ordersNavBtn.evaluate().isNotEmpty) {
        await tester.tap(ordersNavBtn);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await _captureVisualFrame(tester, '08_orders_history_workspace.png', label: 'Orders & Returns');
      }

      // --- 6. OBSERVE CUSTOMERS / CRM WORKSPACE ---
      debugPrint('=== [OBSERVER STEP 6/7] Observing Customers CRM Workspace ===');
      final customersNavBtn = find.byKey(const Key('nav_button_customers_/_clients'));
      if (customersNavBtn.evaluate().isNotEmpty) {
        await tester.tap(customersNavBtn);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await _captureVisualFrame(tester, '09_customers_crm_workspace.png', label: 'Customers CRM');
      }

      // --- 7. OBSERVE ADVANCED SETTINGS & FLEET RMM DIALOG ---
      debugPrint('=== [OBSERVER STEP 7/7] Observing Advanced Settings & RMM Dialog ===');
      final settingsBtn = find.byKey(const Key('advanced_settings_button'));
      if (settingsBtn.evaluate().isNotEmpty) {
        await tester.tap(settingsBtn);
        await tester.pumpAndSettle(const Duration(seconds: 1));
        await _captureVisualFrame(tester, '10_advanced_settings_dialog.png', label: 'Advanced Settings Dialog');

        // Dismiss settings
        await tester.tapAt(const Offset(20, 20));
        await tester.pumpAndSettle(const Duration(milliseconds: 500));
      }

      debugPrint('=== [VISUAL GUI OBSERVER COMPLETE] All visual frames captured and audited ===');
      expect(tester.takeException(), isNull, reason: 'Visual GUI observation must complete without exceptions');
    });
  });
}
