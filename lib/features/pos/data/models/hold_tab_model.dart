import '../../domain/entities/hold_tab.dart';
import 'cart_model.dart';

class HoldTabModel extends HoldTab {
  const HoldTabModel({
    required super.id,
    required super.title,
    required super.cart,
    super.customerPhone,
    super.customerName,
    required super.createdAt,
  });

  factory HoldTabModel.fromJson(Map<String, dynamic> json) {
    return HoldTabModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'HOLD',
      cart: CartModel.fromJson(json['cart'] as Map<String, dynamic>),
      customerPhone: json['customerPhone']?.toString(),
      customerName: json['customerName']?.toString(),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'cart': CartModel.fromEntity(cart).toJson(),
      'customerPhone': customerPhone,
      'customerName': customerName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory HoldTabModel.fromEntity(HoldTab entity) {
    return HoldTabModel(
      id: entity.id,
      title: entity.title,
      cart: entity.cart,
      customerPhone: entity.customerPhone,
      customerName: entity.customerName,
      createdAt: entity.createdAt,
    );
  }
}
