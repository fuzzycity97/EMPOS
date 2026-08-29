import 'package:equatable/equatable.dart';
import 'cart.dart';
import 'payment_detail.dart';

enum OrderStatus { paid, refunded, partiallyRefunded, pending }

class PosOrder extends Equatable {
  final String id;
  final String orderNumber;
  final Cart cart;
  final List<PaymentDetail> payments;
  final OrderStatus status;
  final String? cashierId;
  final String? customerPhone;
  final String? customerName;
  final double changeGiven;
  final DateTime createdAt;

  const PosOrder({
    required this.id,
    required this.orderNumber,
    required this.cart,
    required this.payments,
    this.status = OrderStatus.paid,
    this.cashierId,
    this.customerPhone,
    this.customerName,
    this.changeGiven = 0.0,
    required this.createdAt,
  });

  double get totalPaid => payments.fold(0.0, (sum, p) => sum + p.amount);

  PosOrder copyWith({
    String? id,
    String? orderNumber,
    Cart? cart,
    List<PaymentDetail>? payments,
    OrderStatus? status,
    String? cashierId,
    String? customerPhone,
    String? customerName,
    double? changeGiven,
    DateTime? createdAt,
  }) {
    return PosOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      cart: cart ?? this.cart,
      payments: payments ?? this.payments,
      status: status ?? this.status,
      cashierId: cashierId ?? this.cashierId,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName ?? this.customerName,
      changeGiven: changeGiven ?? this.changeGiven,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        cart,
        payments,
        status,
        cashierId,
        customerPhone,
        customerName,
        changeGiven,
        createdAt,
      ];
}
