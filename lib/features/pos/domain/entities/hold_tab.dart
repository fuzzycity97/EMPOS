import 'package:equatable/equatable.dart';
import 'cart.dart';

class HoldTab extends Equatable {
  final String id;
  final String title;
  final Cart cart;
  final String? customerPhone;
  final String? customerName;
  final DateTime createdAt;

  const HoldTab({
    required this.id,
    required this.title,
    required this.cart,
    this.customerPhone,
    this.customerName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        cart,
        customerPhone,
        customerName,
        createdAt,
      ];
}
