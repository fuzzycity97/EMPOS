import 'package:dartz/dartz.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../catalog/data/datasources/catalog_local_data_source.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/cart_discount.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/entities/hold_tab.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/payment_detail.dart';
import '../../domain/repositories/pos_repository.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../datasources/pos_local_data_source.dart';
import '../models/cart_model.dart';
import '../models/hold_tab_model.dart';
import '../models/order_model.dart';

class PosRepositoryImpl implements PosRepository {
  final PosLocalDataSource localDataSource;
  final CatalogLocalDataSource catalogLocalDataSource;
  final CustomerRepository? customerRepository;

  PosRepositoryImpl({
    required this.localDataSource,
    required this.catalogLocalDataSource,
    this.customerRepository,
  });

  @override
  Future<Either<Failure, Cart>> getActiveCart() async {
    try {
      final cart = await localDataSource.getActiveCart();
      return Right(cart);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Error fetching cart: $e'));
    }
  }

  @override
  Future<Either<Failure, Cart>> addItemToCart({
    required Cart currentCart,
    required Product product,
    int quantity = 1,
  }) async {
    try {
      if (quantity <= 0) {
        return Left(const ValidationFailure(message: 'Quantity must be at least 1.'));
      }

      if (product.trackQty && product.stock <= 0) {
        return Left(ValidationFailure(
          message: 'Item "${product.nameEn}" is out of stock.',
        ));
      }

      final existingIndex = currentCart.items.indexWhere(
        (item) => item.product.id == product.id,
      );

      final updatedItems = List<CartItem>.from(currentCart.items);

      if (existingIndex >= 0) {
        final existingItem = updatedItems[existingIndex];
        final newQuantity = existingItem.quantity + quantity;

        if (product.trackQty && newQuantity > product.stock) {
          return Left(ValidationFailure(
            message:
                'Cannot add more "${product.nameEn}". Maximum available stock is ${product.stock}.',
          ));
        }

        updatedItems[existingIndex] = existingItem.copyWith(
          quantity: newQuantity,
        );
      } else {
        if (product.trackQty && quantity > product.stock) {
          return Left(ValidationFailure(
            message:
                'Cannot add $quantity of "${product.nameEn}". Available stock is ${product.stock}.',
          ));
        }

        updatedItems.add(
          CartItem(
            product: product,
            quantity: quantity,
            unitPrice: product.price,
          ),
        );
      }

      final newCart = currentCart.copyWith(items: updatedItems);
      await localDataSource.saveActiveCart(CartModel.fromEntity(newCart));
      return Right(newCart);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to add item to cart: $e'));
    }
  }

  @override
  Future<Either<Failure, Cart>> updateItemQuantity({
    required Cart currentCart,
    required String productId,
    required int quantity,
  }) async {
    try {
      final updatedItems = List<CartItem>.from(currentCart.items);
      final index = updatedItems.indexWhere((i) => i.product.id == productId);

      if (index < 0) {
        return Right(currentCart);
      }

      if (quantity <= 0) {
        updatedItems.removeAt(index);
      } else {
        final item = updatedItems[index];
        if (item.product.trackQty && quantity > item.product.stock) {
          return Left(ValidationFailure(
            message:
                'Maximum available stock for "${item.product.nameEn}" is ${item.product.stock}.',
          ));
        }
        updatedItems[index] = item.copyWith(quantity: quantity);
      }

      final newCart = currentCart.copyWith(items: updatedItems);
      await localDataSource.saveActiveCart(CartModel.fromEntity(newCart));
      return Right(newCart);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to update quantity: $e'));
    }
  }

  @override
  Future<Either<Failure, Cart>> removeItemFromCart({
    required Cart currentCart,
    required String productId,
  }) async {
    try {
      final updatedItems =
          currentCart.items.where((i) => i.product.id != productId).toList();
      final newCart = currentCart.copyWith(items: updatedItems);
      await localDataSource.saveActiveCart(CartModel.fromEntity(newCart));
      return Right(newCart);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to remove item: $e'));
    }
  }

  @override
  Future<Either<Failure, Cart>> applyCartDiscount({
    required Cart currentCart,
    required CartDiscount discount,
  }) async {
    try {
      final newCart = currentCart.copyWith(discount: discount);
      await localDataSource.saveActiveCart(CartModel.fromEntity(newCart));
      return Right(newCart);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to apply discount: $e'));
    }
  }

  @override
  Future<Either<Failure, Cart>> clearCart() async {
    try {
      await localDataSource.clearActiveCart();
      return const Right(Cart());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to clear cart: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> holdTab({
    required Cart cart,
    required String tabTitle,
    String? customerPhone,
    String? customerName,
  }) async {
    try {
      if (cart.isEmpty) {
        return Left(const ValidationFailure(message: 'Cannot park an empty cart.'));
      }

      final holdId = 'HOLD-${const Uuid().v4().substring(0, 6).toUpperCase()}';
      final tab = HoldTabModel(
        id: holdId,
        title: tabTitle.isNotEmpty ? tabTitle : holdId,
        cart: cart,
        customerPhone: customerPhone,
        customerName: customerName,
        createdAt: DateTime.now(),
      );

      await localDataSource.saveHeldTab(tab);
      await localDataSource.clearActiveCart();
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to park tab: $e'));
    }
  }

  @override
  Future<Either<Failure, List<HoldTab>>> getHeldTabs() async {
    try {
      final tabs = await localDataSource.getHeldTabs();
      return Right(tabs);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve held tabs: $e'));
    }
  }

  @override
  Future<Either<Failure, Cart>> resumeHeldTab(String tabId) async {
    try {
      final tab = await localDataSource.getHeldTabById(tabId);
      await localDataSource.deleteHeldTab(tabId);
      await localDataSource.saveActiveCart(CartModel.fromEntity(tab.cart));
      return Right(tab.cart);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to resume held tab: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteHeldTab(String tabId) async {
    try {
      await localDataSource.deleteHeldTab(tabId);
      return const Right(unit);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete held tab: $e'));
    }
  }

  @override
  Future<Either<Failure, PosOrder>> processCheckout({
    required Cart cart,
    required List<PaymentDetail> payments,
    String? cashierId,
    String? customerPhone,
    String? customerName,
    double changeGiven = 0.0,
  }) async {
    try {
      if (cart.isEmpty) {
        return Left(const ValidationFailure(message: 'Cannot checkout an empty cart.'));
      }

      final totalPaid = payments.fold(0.0, (sum, p) => sum + p.amount);
      if (totalPaid < cart.grandTotal && (cart.grandTotal - totalPaid) > 0.009) {
        return Left(ValidationFailure(
          message:
              'Insufficient payment. Total due is ${cart.grandTotal.toStringAsFixed(2)}, but paid amount is ${totalPaid.toStringAsFixed(2)}.',
        ));
      }

      // Deduct inventory for physical products with FEFO batch awareness
      for (final item in cart.items) {
        if (item.product.trackQty) {
          await catalogLocalDataSource.updateStock(
            item.product.id,
            -item.quantity,
          );
        }
      }

      final orderNumber = 'TXN-${(100000 + (DateTime.now().millisecondsSinceEpoch % 900000))}';

      // Customer Loyalty Points Accrual & Store Credit Debt Charges
      if (customerRepository != null && customerPhone != null && customerPhone.trim().isNotEmpty) {
        final earnedPoints = (cart.grandTotal / 10.0).floor();
        try {
          final custResult = await customerRepository!.getCustomers(searchQuery: customerPhone.trim());
          await custResult.fold(
            (_) async {},
            (customers) async {
              for (final c in customers) {
                if (c.phone == customerPhone.trim()) {
                  // Accrue loyalty points
                  if (earnedPoints > 0) {
                    final updatedCustomer = c.copyWith(
                      loyaltyPoints: c.loyaltyPoints + earnedPoints,
                    );
                    await customerRepository!.saveCustomer(updatedCustomer);
                  }

                  // If checkout was paid via Store Credit, charge customer ledger
                  for (final p in payments) {
                    if (p.tenderType == TenderType.customerAccount && p.amount > 0) {
                      await customerRepository!.chargeCustomerDebt(
                        customerId: c.id,
                        amount: p.amount,
                        relatedOrderId: orderNumber,
                        notes: 'Store Credit Charge (Order #$orderNumber)',
                      );
                    }
                  }
                  break;
                }
              }
            },
          );
        } catch (_) {}
      }
      final order = PosOrderModel(
        id: 'ord-${const Uuid().v4()}',
        orderNumber: orderNumber,
        cart: cart,
        payments: payments,
        status: OrderStatus.paid,
        cashierId: cashierId,
        customerPhone: customerPhone,
        customerName: customerName,
        changeGiven: changeGiven,
        createdAt: DateTime.now(),
      );

      await localDataSource.saveOrder(order);
      await localDataSource.clearActiveCart();

      return Right(order);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(CacheFailure(message: 'Checkout transaction failed: $e'));
    }
  }
}
