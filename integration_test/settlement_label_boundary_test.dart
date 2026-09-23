// integration_test/settlement_label_boundary_test.dart
//
// PURPOSE: This test verifies settlement label display boundaries and
// floating-point precision in the POS Checkout UI (and Order Details).
//
// Tests assert EXACT visible strings rendered via `settlement_status_label`
// and `settlement_balance_label`, preventing UI regressions where payment
// calculations and user-facing status labels fall out of sync.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/order.dart';
import 'package:empos/features/pos/presentation/widgets/checkout_dialog.dart';
import 'package:empos/features/orders/presentation/widgets/order_details_dialog.dart';

Product _createProduct({required String id, required double price, double taxRate = 0.0}) {
  return Product(
    id: id,
    nameEn: 'Test Item $id',
    nameAr: 'صنف تجريبي $id',
    categoryId: 'test_cat',
    price: price,
    stock: 100,
    barcode: 'BAR_$id',
    taxRate: taxRate,
  );
}

Cart _createCartWithItem({required double itemPrice, double taxRate = 0.0}) {
  final product = _createProduct(id: 'item_1', price: itemPrice, taxRate: taxRate);
  return Cart(
    items: [
      CartItem(
        product: product,
        quantity: 1,
        unitPrice: itemPrice,
      ),
    ],
    taxRate: taxRate,
  );
}

Future<void> _pumpCheckoutDialog(
  WidgetTester tester, {
  required double itemPrice,
  required double cashPaid,
  double taxRate = 0.0,
}) async {
  final cart = _createCartWithItem(itemPrice: itemPrice, taxRate: taxRate);

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: CheckoutDialog(cart: cart),
      ),
    ),
  );
  await tester.pumpAndSettle();

  // Enter the cash paid into the payment amount field
  final paymentField = find.byKey(const Key('payment_amount_field'));
  expect(paymentField, findsOneWidget);

  await tester.enterText(
    paymentField,
    cashPaid > 0 ? cashPaid.toStringAsFixed(2) : '0.00',
  );
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Settlement label — exact boundary conditions', () {
    testWidgets(
      'amountPaid == 0 renders exactly "Payment Status: Unpaid", never "Partially Paid"',
      (tester) async {
        await _pumpCheckoutDialog(tester, itemPrice: 100.00, cashPaid: 0.0);

        expect(find.byKey(const Key('settlement_status_label')), findsOneWidget);
        expect(find.text('Payment Status: Unpaid'), findsOneWidget);
        expect(find.text('Payment Status: Partially Paid'), findsNothing);
        expect(find.text('Payment Status: Fully Paid'), findsNothing);
        expect(find.text('Remaining: EGP 100.00'), findsOneWidget);
      },
    );

    testWidgets(
      '0 < amountPaid < totalDue renders exactly "Payment Status: Partially Paid" and '
      'the remaining balance shown equals totalDue - amountPaid to the cent',
      (tester) async {
        await _pumpCheckoutDialog(tester, itemPrice: 150.00, cashPaid: 60.00);

        expect(find.byKey(const Key('settlement_status_label')), findsOneWidget);
        expect(find.text('Payment Status: Partially Paid'), findsOneWidget);
        expect(find.text('Payment Status: Fully Paid'), findsNothing);
        expect(find.text('Payment Status: Unpaid'), findsNothing);

        // Assert the remaining balance figure is formatted exactly to EGP 90.00
        expect(find.text('Remaining: EGP 90.00'), findsOneWidget);
      },
    );

    testWidgets(
      'amountPaid == totalDue EXACTLY renders "Payment Status: Fully Paid", never "Partially Paid" '
      '— the true equality boundary',
      (tester) async {
        await _pumpCheckoutDialog(tester, itemPrice: 100.00, cashPaid: 100.00);

        expect(find.byKey(const Key('settlement_status_label')), findsOneWidget);
        expect(find.text('Payment Status: Fully Paid'), findsOneWidget);
        expect(find.text('Payment Status: Partially Paid'), findsNothing);
        expect(find.text('Change Due: EGP 0.00'), findsOneWidget);
      },
    );

    testWidgets(
      'floating-point near-equality (totalDue computed as 19.999999999 due to tax-rate multiplication) '
      'still renders "Payment Status: Fully Paid" when cashPaid is exactly 20.00 entered by the cashier',
      (tester) async {
        // Construct a cart where taxableAmount * 1.14 creates a floating-point IEEE 754 precision slip
        // 17.543859649122807 * 1.14 = 19.999999999999996 in binary double representation
        const recurringPrice = 17.543859649122807;
        await _pumpCheckoutDialog(
          tester,
          itemPrice: recurringPrice,
          cashPaid: 20.00,
          taxRate: 0.14,
        );

        // Cent-rounding ensures that 20.00 - 19.999999999999996 does not produce a false "Partially Paid"
        expect(find.text('Payment Status: Fully Paid'), findsOneWidget);
        expect(find.text('Payment Status: Partially Paid'), findsNothing);
        expect(
          find.textContaining('0.00000'),
          findsNothing,
          reason: 'A visible near-zero fractional remainder is the signature of IEEE 754 rounding bugs',
        );
      },
    );

    testWidgets(
      'overpayment (cashPaid > totalDue) still renders "Payment Status: Fully Paid", '
      'never a fabricated status, and changeGiven is displayed separately',
      (tester) async {
        await _pumpCheckoutDialog(tester, itemPrice: 100.00, cashPaid: 150.00);

        expect(find.text('Payment Status: Fully Paid'), findsOneWidget);
        expect(find.text('Payment Status: Partially Paid'), findsNothing);
        expect(find.text('Change Due: EGP 50.00'), findsOneWidget);
      },
    );

    testWidgets(
      'refunded order (OrderStatus.refunded) renders a settlement label '
      'distinct from "PAID" — confirms refund status is not silently collapsed',
      (tester) async {
        final sampleOrder = PosOrder(
          id: 'test_order_refund',
          orderNumber: 'ORD-999',
          cart: _createCartWithItem(itemPrice: 100.00),
          payments: const [],
          status: OrderStatus.refunded,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OrderDetailsDialog(order: sampleOrder),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Expect REFUNDED badge, not PAID
        expect(find.byKey(const Key('order_status_badge')), findsOneWidget);
        expect(find.text('REFUNDED'), findsOneWidget);
        expect(find.text('PAID'), findsNothing);
      },
    );
  });
}
