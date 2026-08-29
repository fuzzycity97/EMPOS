import '../../domain/entities/cart.dart';
import 'cart_discount_model.dart';
import 'cart_item_model.dart';

class CartModel extends Cart {
  const CartModel({
    super.items = const [],
    super.discount = const CartDiscountModel(),
    super.taxRate = 0.0,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((i) => CartItemModel.fromJson(i as Map<String, dynamic>))
        .toList();

    final discountMap = json['discount'] as Map<String, dynamic>?;
    final discount = discountMap != null
        ? CartDiscountModel.fromJson(discountMap)
        : const CartDiscountModel();

    return CartModel(
      items: items,
      discount: discount,
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((i) => CartItemModel.fromEntity(i).toJson()).toList(),
      'discount': CartDiscountModel.fromEntity(discount).toJson(),
      'taxRate': taxRate,
    };
  }

  factory CartModel.fromEntity(Cart entity) {
    return CartModel(
      items: entity.items,
      discount: entity.discount,
      taxRate: entity.taxRate,
    );
  }
}
