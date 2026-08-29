import 'package:flutter_test/flutter_test.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_discount.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/entities/payment_detail.dart';
import 'package:empos/features/pos/data/models/cart_model.dart';
import 'package:empos/features/pos/data/models/payment_detail_model.dart';

void main() {
  group('POS Cart Math & Business Logic Unit Tests', () {
    const productA = Product(
      id: 'p-1',
      nameEn: 'Espresso Double',
      categoryId: 'cat-beverages',
      price: 45.0,
      stock: 100,
      barcode: '622100000001',
    );

    const productB = Product(
      id: 'p-2',
      nameEn: 'Club Sandwich',
      categoryId: 'cat-food',
      price: 85.0,
      stock: 50,
      barcode: '622100000002',
    );

    test('calculates subtotal and item count accurately without discounts', () {
      final cart = Cart(
        items: const [
          CartItem(product: productA, quantity: 2, unitPrice: 45.0),
          CartItem(product: productB, quantity: 1, unitPrice: 85.0),
        ],
        taxRate: 0.0,
      );

      // (45 * 2) + (85 * 1) = 90 + 85 = 175.0
      expect(cart.totalItemCount, equals(3));
      expect(cart.subtotal, equals(175.0));
      expect(cart.discountAmount, equals(0.0));
      expect(cart.taxAmount, equals(0.0));
      expect(cart.grandTotal, equals(175.0));
    });

    test('calculates percentage discount accurately (e.g. 10%)', () {
      final cart = Cart(
        items: const [
          CartItem(product: productA, quantity: 2, unitPrice: 50.0), // 100.0
        ],
        discount: const CartDiscount.percentage(10.0),
        taxRate: 0.0,
      );

      expect(cart.subtotal, equals(100.0));
      expect(cart.discountAmount, equals(10.0));
      expect(cart.taxableAmount, equals(90.0));
      expect(cart.grandTotal, equals(90.0));
    });

    test('calculates fixed discount accurately and clamps at subtotal', () {
      final cart = Cart(
        items: const [
          CartItem(product: productA, quantity: 1, unitPrice: 50.0),
        ],
        discount: const CartDiscount.fixed(20.0),
        taxRate: 0.0,
      );

      expect(cart.subtotal, equals(50.0));
      expect(cart.discountAmount, equals(20.0));
      expect(cart.grandTotal, equals(30.0));

      final cartOverDiscount = cart.copyWith(
        discount: const CartDiscount.fixed(100.0),
      );
      expect(cartOverDiscount.discountAmount, equals(50.0));
      expect(cartOverDiscount.grandTotal, equals(0.0));
    });

    test('calculates VAT tax on discounted taxable amount', () {
      final cart = Cart(
        items: const [
          CartItem(product: productA, quantity: 2, unitPrice: 100.0), // 200.0 subtotal
        ],
        discount: const CartDiscount.percentage(50.0), // 100.0 discount -> 100.0 taxable
        taxRate: 0.14, // 14% VAT
      );

      expect(cart.subtotal, equals(200.0));
      expect(cart.discountAmount, equals(100.0));
      expect(cart.taxableAmount, equals(100.0));
      expect(cart.taxAmount, closeTo(14.0, 0.001));
      expect(cart.grandTotal, closeTo(114.0, 0.001));
    });

    test('CartModel correctly serializes to and from JSON', () {
      final cart = Cart(
        items: const [
          CartItem(product: productA, quantity: 3, unitPrice: 45.0),
        ],
        discount: const CartDiscount.percentage(15.0),
        taxRate: 0.14,
      );

      final model = CartModel.fromEntity(cart);
      final json = model.toJson();
      final restored = CartModel.fromJson(json);

      expect(restored.totalItemCount, equals(3));
      expect(restored.subtotal, equals(135.0));
      expect(restored.discount.type, equals(DiscountType.percentage));
      expect(restored.discount.value, equals(15.0));
    });

    test('PaymentDetailModel handles multi-tender split serializations', () {
      const payment1 = PaymentDetail(
        tenderType: TenderType.cash,
        amount: 100.0,
      );
      const payment2 = PaymentDetail(
        tenderType: TenderType.instapay,
        amount: 50.0,
        referenceNumber: 'IP-998822',
      );

      final p1Json = PaymentDetailModel.fromEntity(payment1).toJson();
      final p2Json = PaymentDetailModel.fromEntity(payment2).toJson();

      final p1Restored = PaymentDetailModel.fromJson(p1Json);
      final p2Restored = PaymentDetailModel.fromJson(p2Json);

      expect(p1Restored.tenderType, equals(TenderType.cash));
      expect(p1Restored.amount, equals(100.0));
      expect(p2Restored.tenderType, equals(TenderType.instapay));
      expect(p2Restored.referenceNumber, equals('IP-998822'));
    });
  });
}
