import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/cart_discount.dart';
import '../../domain/entities/payment_detail.dart';

abstract class PosEvent extends Equatable {
  const PosEvent();

  @override
  List<Object?> get props => [];
}

class InitPosSession extends PosEvent {
  const InitPosSession();
}

class AddProductToCart extends PosEvent {
  final Product product;
  final int quantity;

  const AddProductToCart(this.product, {this.quantity = 1});

  @override
  List<Object?> get props => [product, quantity];
}

class ScanBarcodeEvent extends PosEvent {
  final String barcode;

  const ScanBarcodeEvent(this.barcode);

  @override
  List<Object?> get props => [barcode];
}

class UpdateQuantityEvent extends PosEvent {
  final String productId;
  final int quantity;

  const UpdateQuantityEvent({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

class RemoveCartItemEvent extends PosEvent {
  final String productId;

  const RemoveCartItemEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class ApplyDiscountEvent extends PosEvent {
  final CartDiscount discount;

  const ApplyDiscountEvent(this.discount);

  @override
  List<Object?> get props => [discount];
}

class ClearCartEvent extends PosEvent {
  const ClearCartEvent();
}

class HoldCurrentTabEvent extends PosEvent {
  final String tabTitle;
  final String? customerPhone;
  final String? customerName;

  const HoldCurrentTabEvent({
    required this.tabTitle,
    this.customerPhone,
    this.customerName,
  });

  @override
  List<Object?> get props => [tabTitle, customerPhone, customerName];
}

class ResumeTabEvent extends PosEvent {
  final String tabId;

  const ResumeTabEvent(this.tabId);

  @override
  List<Object?> get props => [tabId];
}

class DeleteHeldTabEvent extends PosEvent {
  final String tabId;

  const DeleteHeldTabEvent(this.tabId);

  @override
  List<Object?> get props => [tabId];
}

class SearchPosProductsEvent extends PosEvent {
  final String query;

  const SearchPosProductsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectPosCategoryEvent extends PosEvent {
  final String? categoryId;

  const SelectPosCategoryEvent(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class ProcessCheckoutEvent extends PosEvent {
  final List<PaymentDetail> payments;
  final String? customerPhone;
  final String? customerName;
  final double changeGiven;

  const ProcessCheckoutEvent({
    required this.payments,
    this.customerPhone,
    this.customerName,
    this.changeGiven = 0.0,
  });

  @override
  List<Object?> get props => [
        payments,
        customerPhone,
        customerName,
        changeGiven,
      ];
}

class DismissReceiptEvent extends PosEvent {
  const DismissReceiptEvent();
}
