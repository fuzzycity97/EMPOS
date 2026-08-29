import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final int quantity;
  final double unitPrice;
  final double itemDiscount;
  final String? notes;

  const CartItem({
    required this.product,
    required this.quantity,
    required this.unitPrice,
    this.itemDiscount = 0.0,
    this.notes,
  });

  double get lineTotal => (unitPrice * quantity) - itemDiscount;

  CartItem copyWith({
    Product? product,
    int? quantity,
    double? unitPrice,
    double? itemDiscount,
    String? notes,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      itemDiscount: itemDiscount ?? this.itemDiscount,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        product,
        quantity,
        unitPrice,
        itemDiscount,
        notes,
      ];
}
