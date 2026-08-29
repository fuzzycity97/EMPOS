import 'package:equatable/equatable.dart';

enum DiscountType { none, percentage, fixedAmount }

class CartDiscount extends Equatable {
  final DiscountType type;
  final double value; // Percentage (e.g. 10 for 10%) or Fixed amount (e.g. 25.0)

  const CartDiscount({
    this.type = DiscountType.none,
    this.value = 0.0,
  });

  const CartDiscount.none()
      : type = DiscountType.none,
        value = 0.0;

  const CartDiscount.percentage(double percentage)
      : type = DiscountType.percentage,
        value = percentage;

  const CartDiscount.fixed(double amount)
      : type = DiscountType.fixedAmount,
        value = amount;

  double calculateDiscountAmount(double subtotal) {
    if (subtotal <= 0) return 0.0;
    switch (type) {
      case DiscountType.percentage:
        final pct = value.clamp(0.0, 100.0);
        return (subtotal * (pct / 100.0));
      case DiscountType.fixedAmount:
        return value.clamp(0.0, subtotal);
      case DiscountType.none:
        return 0.0;
    }
  }

  @override
  List<Object?> get props => [type, value];
}
