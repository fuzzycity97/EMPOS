import 'package:equatable/equatable.dart';
import '../../../catalog/domain/entities/category.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../domain/entities/cart.dart';
import '../../domain/entities/hold_tab.dart';
import '../../domain/entities/order.dart';

abstract class PosState extends Equatable {
  const PosState();

  @override
  List<Object?> get props => [];
}

class PosInitial extends PosState {
  const PosInitial();
}

class PosLoading extends PosState {
  const PosLoading();
}

class PosReady extends PosState {
  final Cart cart;
  final List<HoldTab> heldTabs;
  final List<Product> allProducts;
  final List<Product> displayedProducts;
  final List<Category> categories;
  final String? selectedCategoryId;
  final String searchQuery;
  final PosOrder? lastCompletedOrder;
  final bool isProcessingCheckout;
  final String? toastMessage;

  const PosReady({
    required this.cart,
    this.heldTabs = const [],
    this.allProducts = const [],
    this.displayedProducts = const [],
    this.categories = const [],
    this.selectedCategoryId,
    this.searchQuery = '',
    this.lastCompletedOrder,
    this.isProcessingCheckout = false,
    this.toastMessage,
  });

  PosReady copyWith({
    Cart? cart,
    List<HoldTab>? heldTabs,
    List<Product>? allProducts,
    List<Product>? displayedProducts,
    List<Category>? categories,
    String? Function()? selectedCategoryId,
    String? searchQuery,
    PosOrder? Function()? lastCompletedOrder,
    bool? isProcessingCheckout,
    String? Function()? toastMessage,
  }) {
    return PosReady(
      cart: cart ?? this.cart,
      heldTabs: heldTabs ?? this.heldTabs,
      allProducts: allProducts ?? this.allProducts,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId != null
          ? selectedCategoryId()
          : this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      lastCompletedOrder: lastCompletedOrder != null
          ? lastCompletedOrder()
          : this.lastCompletedOrder,
      isProcessingCheckout: isProcessingCheckout ?? this.isProcessingCheckout,
      toastMessage: toastMessage != null ? toastMessage() : this.toastMessage,
    );
  }

  @override
  List<Object?> get props => [
        cart,
        heldTabs,
        allProducts,
        displayedProducts,
        categories,
        selectedCategoryId,
        searchQuery,
        lastCompletedOrder,
        isProcessingCheckout,
        toastMessage,
      ];
}

class PosError extends PosState {
  final String message;

  const PosError(this.message);

  @override
  List<Object?> get props => [message];
}
