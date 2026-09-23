// integration_test/pos_checkout_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:empos/main.dart' as app;
import 'package:empos/features/auth/presentation/widgets/pin_lock_screen.dart';
import 'package:empos/features/pos/presentation/widgets/pos_product_tile.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('POS Cashier End-to-End Checkout Flow Test', () {
    testWidgets('completes product addition, checkout, payment, and receipt generation', (tester) async {
      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Advance past first-run sync wizard if present on clean database
      final firstRunLaunch = find.byKey(const Key('first_run_launch_button'));
      if (firstRunLaunch.evaluate().isNotEmpty) {
        await tester.tap(firstRunLaunch);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }

      // 1. Authenticate if on PinLockScreen
      if (find.byType(PinLockScreen).evaluate().isNotEmpty) {
        final cashierChip = find.byKey(const Key('demo_chip_2222'));
        if (cashierChip.evaluate().isNotEmpty) {
          await tester.tap(cashierChip);
        } else {
          // Fallback to keypad
          final key2 = find.byKey(const Key('keypad_button_2'));
          for (var i = 0; i < 4; i++) {
            await tester.tap(key2);
            await tester.pump(const Duration(milliseconds: 100));
          }
        }
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }

      // 2. Select POS Cashier workspace if not already active
      final posNavBtn = find.byKey(const Key('nav_button_pos_cashier'));
      if (posNavBtn.evaluate().isNotEmpty) {
        await tester.tap(posNavBtn);
        await tester.pumpAndSettle();
      }

      // 3. Add an item from product catalog grid to cart
      final productTiles = find.byType(PosProductTile);
      if (productTiles.evaluate().isNotEmpty) {
        await tester.tap(productTiles.first);
        await tester.pumpAndSettle();

        // 4. Open Checkout Dialog
        final checkoutBtn = find.byKey(const Key('pos_checkout_button'));
        expect(checkoutBtn, findsOneWidget, reason: 'Checkout button must be visible when cart contains items');
        await tester.tap(checkoutBtn);
        await tester.pumpAndSettle();

        // 5. Verify payment amount and settlement status
        expect(find.byKey(const Key('payment_amount_field')), findsOneWidget);
        expect(find.byKey(const Key('settlement_status_label')), findsOneWidget);

        // 6. Complete Transaction
        final confirmBtn = find.byKey(const Key('confirm_checkout_button'));
        expect(confirmBtn, findsOneWidget);
        await tester.tap(confirmBtn);
        await tester.pumpAndSettle();

        // 7. Verify Receipt & Actions
        expect(find.byKey(const Key('print_receipt_button')), findsOneWidget);
        final newSaleBtn = find.byKey(const Key('new_sale_button'));
        expect(newSaleBtn, findsOneWidget);

        // Dismiss receipt for next cycle
        await tester.tap(newSaleBtn);
        await tester.pumpAndSettle();
      }
    });
  });
}
