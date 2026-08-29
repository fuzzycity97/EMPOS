import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/cart.dart';
import '../entities/order.dart';
import '../entities/payment_detail.dart';
import '../repositories/pos_repository.dart';

class ProcessCheckoutParams {
  final Cart cart;
  final List<PaymentDetail> payments;
  final String? cashierId;
  final String? customerPhone;
  final String? customerName;
  final double changeGiven;

  const ProcessCheckoutParams({
    required this.cart,
    required this.payments,
    this.cashierId,
    this.customerPhone,
    this.customerName,
    this.changeGiven = 0.0,
  });
}

class ProcessCheckoutUseCase {
  final PosRepository repository;

  ProcessCheckoutUseCase(this.repository);

  Future<Either<Failure, PosOrder>> call(ProcessCheckoutParams params) async {
    return await repository.processCheckout(
      cart: params.cart,
      payments: params.payments,
      cashierId: params.cashierId,
      customerPhone: params.customerPhone,
      customerName: params.customerName,
      changeGiven: params.changeGiven,
    );
  }
}
