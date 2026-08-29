import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/product.dart';
import '../entities/cart.dart';
import '../entities/cart_discount.dart';
import '../entities/hold_tab.dart';
import '../entities/order.dart';
import '../entities/payment_detail.dart';

abstract class PosRepository {
  Future<Either<Failure, Cart>> getActiveCart();

  Future<Either<Failure, Cart>> addItemToCart({
    required Cart currentCart,
    required Product product,
    int quantity = 1,
  });

  Future<Either<Failure, Cart>> updateItemQuantity({
    required Cart currentCart,
    required String productId,
    required int quantity,
  });

  Future<Either<Failure, Cart>> removeItemFromCart({
    required Cart currentCart,
    required String productId,
  });

  Future<Either<Failure, Cart>> applyCartDiscount({
    required Cart currentCart,
    required CartDiscount discount,
  });

  Future<Either<Failure, Cart>> clearCart();

  Future<Either<Failure, Unit>> holdTab({
    required Cart cart,
    required String tabTitle,
    String? customerPhone,
    String? customerName,
  });

  Future<Either<Failure, List<HoldTab>>> getHeldTabs();

  Future<Either<Failure, Cart>> resumeHeldTab(String tabId);

  Future<Either<Failure, Unit>> deleteHeldTab(String tabId);

  Future<Either<Failure, PosOrder>> processCheckout({
    required Cart cart,
    required List<PaymentDetail> payments,
    String? cashierId,
    String? customerPhone,
    String? customerName,
    double changeGiven = 0.0,
  });
}
