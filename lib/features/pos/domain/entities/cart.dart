import 'package:equatable/equatable.dart';
import 'cart_discount.dart';
import 'cart_item.dart';

class Cart extends Equatable {
  final List<CartItem> items;
  final CartDiscount discount;
  final double taxRate; // e.g., 0.0 for 0% or 0.14 for 14% VAT

  const Cart({
    this.items = const [],
    this.discount = const CartDiscount.none(),
    this.taxRate = 0.0,
  });

  bool get isEmpty => items.isEmpty;
  bool get isNotEmpty => items.isNotEmpty;

  int get totalItemCount => items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get discountAmount => discount.calculateDiscountAmount(subtotal);

  double get taxableAmount {
    final diff = subtotal - discountAmount;
    return diff > 0 ? diff : 0.0;
  }

  double get taxAmount => taxableAmount * taxRate;

  double get grandTotal => taxableAmount + taxAmount;

  Cart copyWith({
    List<CartItem>? items,
    CartDiscount? discount,
    double? taxRate,
  }) {
    return Cart(
      items: items ?? this.items,
      discount: discount ?? this.discount,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  @override
  List<Object?> get props => [items, discount, taxRate];
}
