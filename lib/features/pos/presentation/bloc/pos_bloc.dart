import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/hardware/domain/repositories/hardware_repository.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/usecases/get_categories_usecase.dart';
import '../../../catalog/domain/usecases/get_product_by_barcode_usecase.dart';
import '../../../catalog/domain/usecases/get_products_usecase.dart';
import '../../domain/entities/cart.dart';
import '../../domain/usecases/add_item_to_cart_usecase.dart';
import '../../domain/usecases/apply_cart_discount_usecase.dart';
import '../../domain/usecases/clear_cart_usecase.dart';
import '../../domain/usecases/delete_held_tab_usecase.dart';
import '../../domain/usecases/get_active_cart_usecase.dart';
import '../../domain/usecases/get_held_tabs_usecase.dart';
import '../../domain/usecases/hold_tab_usecase.dart';
import '../../domain/usecases/process_checkout_usecase.dart';
import '../../domain/usecases/remove_item_from_cart_usecase.dart';
import '../../domain/usecases/resume_held_tab_usecase.dart';
import '../../domain/usecases/update_cart_quantity_usecase.dart';
import 'pos_event.dart';
import 'pos_state.dart';

class PosBloc extends Bloc<PosEvent, PosState> {
  final GetActiveCartUseCase getActiveCartUseCase;
  final AddItemToCartUseCase addItemToCartUseCase;
  final UpdateCartQuantityUseCase updateCartQuantityUseCase;
  final RemoveItemFromCartUseCase removeItemFromCartUseCase;
  final ApplyCartDiscountUseCase applyCartDiscountUseCase;
  final ClearCartUseCase clearCartUseCase;
  final HoldTabUseCase holdTabUseCase;
  final GetHeldTabsUseCase getHeldTabsUseCase;
  final ResumeHeldTabUseCase resumeHeldTabUseCase;
  final DeleteHeldTabUseCase deleteHeldTabUseCase;
  final ProcessCheckoutUseCase processCheckoutUseCase;

  // Catalog integrations
  final GetProductsUseCase getProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final GetProductByBarcodeUseCase getProductByBarcodeUseCase;

  // Hardware integration
  final HardwareRepository? hardwareRepository;
  StreamSubscription<String>? _barcodeSubscription;

  PosBloc({
    required this.getActiveCartUseCase,
    required this.addItemToCartUseCase,
    required this.updateCartQuantityUseCase,
    required this.removeItemFromCartUseCase,
    required this.applyCartDiscountUseCase,
    required this.clearCartUseCase,
    required this.holdTabUseCase,
    required this.getHeldTabsUseCase,
    required this.resumeHeldTabUseCase,
    required this.deleteHeldTabUseCase,
    required this.processCheckoutUseCase,
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
    required this.getProductByBarcodeUseCase,
    this.hardwareRepository,
  }) : super(const PosInitial()) {
    if (hardwareRepository != null) {
      _barcodeSubscription = hardwareRepository!.barcodeScanStream.listen((barcode) {
        if (barcode.trim().isNotEmpty) {
          add(ScanBarcodeEvent(barcode.trim()));
        }
      });
    }

    on<InitPosSession>(_onInitPosSession);
    on<AddProductToCart>(_onAddProductToCart);
    on<ScanBarcodeEvent>(_onScanBarcode);
    on<UpdateQuantityEvent>(_onUpdateQuantity);
    on<RemoveCartItemEvent>(_onRemoveCartItem);
    on<ApplyDiscountEvent>(_onApplyDiscount);
    on<ClearCartEvent>(_onClearCart);
    on<HoldCurrentTabEvent>(_onHoldCurrentTabEvent);
    on<ResumeTabEvent>(_onResumeTab);
    on<DeleteHeldTabEvent>(_onDeleteHeldTab);
    on<SearchPosProductsEvent>(_onSearchPosProducts);
    on<SelectPosCategoryEvent>(_onSelectPosCategory);
    on<ProcessCheckoutEvent>(_onProcessCheckout);
    on<DismissReceiptEvent>(_onDismissReceipt);
  }

  Future<void> _onInitPosSession(
    InitPosSession event,
    Emitter<PosState> emit,
  ) async {
    emit(const PosLoading());

    final cartResult = await getActiveCartUseCase();
    final heldTabsResult = await getHeldTabsUseCase();
    final productsResult = await getProductsUseCase(
      const GetProductsParams(onlyActive: true),
    );
    final categoriesResult = await getCategoriesUseCase(onlyActive: true);

    cartResult.fold(
      (failure) => emit(PosError(failure.message)),
      (cart) {
        final heldTabs = heldTabsResult.getOrElse(() => []);
        final products = productsResult.getOrElse(() => []);
        final categories = categoriesResult.getOrElse(() => []);

        emit(PosReady(
          cart: cart.taxRate == 0.0 ? cart.copyWith(taxRate: 0.14) : cart, // 14% default VAT
          heldTabs: heldTabs,
          allProducts: products,
          displayedProducts: products,
          categories: categories,
        ));
      },
    );
  }

  Future<void> _onAddProductToCart(
    AddProductToCart event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final result = await addItemToCartUseCase(
      AddItemToCartParams(
        currentCart: current.cart,
        product: event.product,
        quantity: event.quantity,
      ),
    );

    result.fold(
      (failure) => emit(current.copyWith(toastMessage: () => failure.message)),
      (newCart) => emit(current.copyWith(
        cart: newCart,
        toastMessage: () => 'Added "${event.product.nameEn}" to order.',
      )),
    );
  }

  Future<void> _onScanBarcode(
    ScanBarcodeEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;
    final barcode = event.barcode.trim();

    if (barcode.isEmpty) return;

    final productResult = await getProductByBarcodeUseCase(barcode);

    await productResult.fold(
      (failure) async {
        emit(current.copyWith(
          toastMessage: () => 'Barcode "$barcode" not recognized.',
        ));
      },
      (product) async {
        final addResult = await addItemToCartUseCase(
          AddItemToCartParams(
            currentCart: current.cart,
            product: product,
            quantity: 1,
          ),
        );

        addResult.fold(
          (failure) => emit(current.copyWith(toastMessage: () => failure.message)),
          (newCart) => emit(current.copyWith(
            cart: newCart,
            toastMessage: () => 'Scanned "${product.nameEn}"',
          )),
        );
      },
    );
  }

  Future<void> _onUpdateQuantity(
    UpdateQuantityEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final result = await updateCartQuantityUseCase(
      UpdateCartQuantityParams(
        currentCart: current.cart,
        productId: event.productId,
        quantity: event.quantity,
      ),
    );

    result.fold(
      (failure) => emit(current.copyWith(toastMessage: () => failure.message)),
      (newCart) => emit(current.copyWith(cart: newCart)),
    );
  }

  Future<void> _onRemoveCartItem(
    RemoveCartItemEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final result = await removeItemFromCartUseCase(
      RemoveItemFromCartParams(
        currentCart: current.cart,
        productId: event.productId,
      ),
    );

    result.fold(
      (failure) => emit(current.copyWith(toastMessage: () => failure.message)),
      (newCart) => emit(current.copyWith(cart: newCart)),
    );
  }

  Future<void> _onApplyDiscount(
    ApplyDiscountEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final result = await applyCartDiscountUseCase(
      ApplyCartDiscountParams(
        currentCart: current.cart,
        discount: event.discount,
      ),
    );

    result.fold(
      (failure) => emit(current.copyWith(toastMessage: () => failure.message)),
      (newCart) => emit(current.copyWith(
        cart: newCart,
        toastMessage: () => 'Discount updated.',
      )),
    );
  }

  Future<void> _onClearCart(
    ClearCartEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final result = await clearCartUseCase();

    result.fold(
      (failure) => emit(current.copyWith(toastMessage: () => failure.message)),
      (emptyCart) => emit(current.copyWith(
        cart: emptyCart.copyWith(taxRate: current.cart.taxRate),
        toastMessage: () => 'Order voided / cleared.',
      )),
    );
  }

  Future<void> _onHoldCurrentTabEvent(
    HoldCurrentTabEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    if (current.cart.isEmpty) {
      emit(current.copyWith(toastMessage: () => 'Cannot hold an empty cart.'));
      return;
    }

    final result = await holdTabUseCase(
      HoldTabParams(
        cart: current.cart,
        tabTitle: event.tabTitle,
        customerPhone: event.customerPhone,
        customerName: event.customerName,
      ),
    );

    await result.fold(
      (failure) async => emit(current.copyWith(toastMessage: () => failure.message)),
      (_) async {
        final updatedHeldTabs = await getHeldTabsUseCase();
        final heldList = updatedHeldTabs.getOrElse(() => []);

        emit(current.copyWith(
          cart: Cart(taxRate: current.cart.taxRate),
          heldTabs: heldList,
          toastMessage: () => 'Order parked under "${event.tabTitle}".',
        ));
      },
    );
  }

  Future<void> _onResumeTab(
    ResumeTabEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final result = await resumeHeldTabUseCase(event.tabId);

    await result.fold(
      (failure) async => emit(current.copyWith(toastMessage: () => failure.message)),
      (resumedCart) async {
        final updatedHeldTabs = await getHeldTabsUseCase();
        final heldList = updatedHeldTabs.getOrElse(() => []);

        emit(current.copyWith(
          cart: resumedCart,
          heldTabs: heldList,
          toastMessage: () => 'Held tab resumed into active order.',
        ));
      },
    );
  }

  Future<void> _onDeleteHeldTab(
    DeleteHeldTabEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final result = await deleteHeldTabUseCase(event.tabId);

    await result.fold(
      (failure) async => emit(current.copyWith(toastMessage: () => failure.message)),
      (_) async {
        final updatedHeldTabs = await getHeldTabsUseCase();
        final heldList = updatedHeldTabs.getOrElse(() => []);

        emit(current.copyWith(
          heldTabs: heldList,
          toastMessage: () => 'Parked tab deleted.',
        ));
      },
    );
  }

  void _onSearchPosProducts(
    SearchPosProductsEvent event,
    Emitter<PosState> emit,
  ) {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final filtered = _filterPosProducts(
      allProducts: current.allProducts,
      searchQuery: event.query,
      categoryId: current.selectedCategoryId,
    );

    emit(current.copyWith(
      searchQuery: event.query,
      displayedProducts: filtered,
    ));
  }

  void _onSelectPosCategory(
    SelectPosCategoryEvent event,
    Emitter<PosState> emit,
  ) {
    if (state is! PosReady) return;
    final current = state as PosReady;

    final newCatId = (event.categoryId == null || event.categoryId == 'ALL')
        ? null
        : event.categoryId;

    final filtered = _filterPosProducts(
      allProducts: current.allProducts,
      searchQuery: current.searchQuery,
      categoryId: newCatId,
    );

    emit(current.copyWith(
      selectedCategoryId: () => newCatId,
      displayedProducts: filtered,
    ));
  }

  Future<void> _onProcessCheckout(
    ProcessCheckoutEvent event,
    Emitter<PosState> emit,
  ) async {
    if (state is! PosReady) return;
    final current = state as PosReady;

    emit(current.copyWith(isProcessingCheckout: true));

    final result = await processCheckoutUseCase(
      ProcessCheckoutParams(
        cart: current.cart,
        payments: event.payments,
        customerPhone: event.customerPhone,
        customerName: event.customerName,
        changeGiven: event.changeGiven,
      ),
    );

    result.fold(
      (failure) {
        emit(current.copyWith(
          isProcessingCheckout: false,
          toastMessage: () => failure.message,
        ));
      },
      (order) {
        // Refresh product stock in memory
        final updatedProducts = current.allProducts.map((p) {
          final cartItem = current.cart.items.where((i) => i.product.id == p.id).firstOrNull;
          if (cartItem != null && p.trackQty) {
            return p.copyWith(stock: (p.stock - cartItem.quantity).clamp(0, 999999));
          }
          return p;
        }).toList();

        final filtered = _filterPosProducts(
          allProducts: updatedProducts,
          searchQuery: current.searchQuery,
          categoryId: current.selectedCategoryId,
        );

        emit(current.copyWith(
          cart: Cart(taxRate: current.cart.taxRate),
          allProducts: updatedProducts,
          displayedProducts: filtered,
          lastCompletedOrder: () => order,
          isProcessingCheckout: false,
          toastMessage: () => 'Payment completed. Order #${order.orderNumber}',
        ));
      },
    );
  }

  void _onDismissReceipt(
    DismissReceiptEvent event,
    Emitter<PosState> emit,
  ) {
    if (state is! PosReady) return;
    final current = state as PosReady;
    emit(current.copyWith(lastCompletedOrder: () => null));
  }

  List<Product> _filterPosProducts({
    required List<Product> allProducts,
    required String searchQuery,
    required String? categoryId,
  }) {
    final query = searchQuery.trim().toLowerCase();

    return allProducts.where((p) {
      if (!p.isEnabled) return false;

      if (categoryId != null && categoryId.isNotEmpty && p.categoryId != categoryId) {
        return false;
      }

      if (query.isNotEmpty) {
        final matchEn = p.nameEn.toLowerCase().contains(query);
        final matchAr = p.nameAr?.toLowerCase().contains(query) ?? false;
        final matchBarcode = p.barcode.toLowerCase().contains(query);
        if (!matchEn && !matchAr && !matchBarcode) return false;
      }

      return true;
    }).toList();
  }

  @override
  Future<void> close() {
    _barcodeSubscription?.cancel();
    return super.close();
  }
}
