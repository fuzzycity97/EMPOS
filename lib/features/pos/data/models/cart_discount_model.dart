import '../../domain/entities/cart_discount.dart';

class CartDiscountModel extends CartDiscount {
  const CartDiscountModel({
    super.type = DiscountType.none,
    super.value = 0.0,
  });

  factory CartDiscountModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['type']?.toString().toLowerCase();
    DiscountType type = DiscountType.none;
    if (typeStr == 'pct' || typeStr == 'percentage') {
      type = DiscountType.percentage;
    } else if (typeStr == 'fixed' || typeStr == 'fixedamount') {
      type = DiscountType.fixedAmount;
    }

    return CartDiscountModel(
      type: type,
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'value': value,
    };
  }

  factory CartDiscountModel.fromEntity(CartDiscount entity) {
    return CartDiscountModel(
      type: entity.type,
      value: entity.value,
    );
  }
}
