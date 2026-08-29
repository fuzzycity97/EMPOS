import '../../../catalog/data/models/product_model.dart';
import '../../domain/entities/cart_item.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.product,
    required super.quantity,
    required super.unitPrice,
    super.itemDiscount = 0.0,
    super.notes,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0.0,
      itemDiscount: (json['itemDiscount'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': ProductModel.fromEntity(product).toJson(),
      'quantity': quantity,
      'unitPrice': unitPrice,
      'itemDiscount': itemDiscount,
      'notes': notes,
    };
  }

  factory CartItemModel.fromEntity(CartItem entity) {
    return CartItemModel(
      product: entity.product,
      quantity: entity.quantity,
      unitPrice: entity.unitPrice,
      itemDiscount: entity.itemDiscount,
      notes: entity.notes,
    );
  }
}
