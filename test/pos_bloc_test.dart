import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/catalog/domain/usecases/get_categories_usecase.dart';
import 'package:empos/features/catalog/domain/usecases/get_product_by_barcode_usecase.dart';
import 'package:empos/features/catalog/domain/usecases/get_products_usecase.dart';
import 'package:empos/features/pos/domain/entities/cart.dart';
import 'package:empos/features/pos/domain/entities/cart_item.dart';
import 'package:empos/features/pos/domain/usecases/add_item_to_cart_usecase.dart';
import 'package:empos/features/pos/domain/usecases/apply_cart_discount_usecase.dart';
import 'package:empos/features/pos/domain/usecases/clear_cart_usecase.dart';
import 'package:empos/features/pos/domain/usecases/delete_held_tab_usecase.dart';
import 'package:empos/features/pos/domain/usecases/get_active_cart_usecase.dart';
import 'package:empos/features/pos/domain/usecases/get_held_tabs_usecase.dart';
import 'package:empos/features/pos/domain/usecases/hold_tab_usecase.dart';
import 'package:empos/features/pos/domain/usecases/process_checkout_usecase.dart';
import 'package:empos/features/pos/domain/usecases/remove_item_from_cart_usecase.dart';
import 'package:empos/features/pos/domain/usecases/resume_held_tab_usecase.dart';
import 'package:empos/features/pos/domain/usecases/update_cart_quantity_usecase.dart';
import 'package:empos/features/pos/presentation/bloc/pos_bloc.dart';
import 'package:empos/features/pos/presentation/bloc/pos_event.dart';
import 'package:empos/features/pos/presentation/bloc/pos_state.dart';

class MockGetActiveCartUseCase extends Mock implements GetActiveCartUseCase {}
class MockAddItemToCartUseCase extends Mock implements AddItemToCartUseCase {}
class MockUpdateCartQuantityUseCase extends Mock implements UpdateCartQuantityUseCase {}
class MockRemoveItemFromCartUseCase extends Mock implements RemoveItemFromCartUseCase {}
class MockApplyCartDiscountUseCase extends Mock implements ApplyCartDiscountUseCase {}
class MockClearCartUseCase extends Mock implements ClearCartUseCase {}
class MockHoldTabUseCase extends Mock implements HoldTabUseCase {}
class MockGetHeldTabsUseCase extends Mock implements GetHeldTabsUseCase {}
class MockResumeHeldTabUseCase extends Mock implements ResumeHeldTabUseCase {}
class MockDeleteHeldTabUseCase extends Mock implements DeleteHeldTabUseCase {}
class MockProcessCheckoutUseCase extends Mock implements ProcessCheckoutUseCase {}
class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}
class MockGetProductByBarcodeUseCase extends Mock implements GetProductByBarcodeUseCase {}

void main() {
  late MockGetActiveCartUseCase mockGetActiveCart;
  late MockAddItemToCartUseCase mockAddItemToCart;
  late MockUpdateCartQuantityUseCase mockUpdateCartQuantity;
  late MockRemoveItemFromCartUseCase mockRemoveItemFromCart;
  late MockApplyCartDiscountUseCase mockApplyCartDiscount;
  late MockClearCartUseCase mockClearCart;
  late MockHoldTabUseCase mockHoldTab;
  late MockGetHeldTabsUseCase mockGetHeldTabs;
  late MockResumeHeldTabUseCase mockResumeHeldTab;
  late MockDeleteHeldTabUseCase mockDeleteHeldTab;
  late MockProcessCheckoutUseCase mockProcessCheckout;
  late MockGetProductsUseCase mockGetProducts;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockGetProductByBarcodeUseCase mockGetProductByBarcode;
  late PosBloc posBloc;

  const tProduct = Product(
    id: 'p-1',
    nameEn: 'Espresso',
    categoryId: 'cat-1',
    price: 45.0,
    stock: 100,
    barcode: '622100',
  );

  const tCart = Cart(
    items: [CartItem(product: tProduct, quantity: 1, unitPrice: 45.0)],
    taxRate: 0.14,
  );

  setUpAll(() {
    registerFallbackValue(const AddItemToCartParams(
      currentCart: Cart(),
      product: tProduct,
      quantity: 1,
    ));
    registerFallbackValue(const ProcessCheckoutParams(
      cart: Cart(),
      payments: [],
    ));
  });

  setUp(() {
    mockGetActiveCart = MockGetActiveCartUseCase();
    mockAddItemToCart = MockAddItemToCartUseCase();
    mockUpdateCartQuantity = MockUpdateCartQuantityUseCase();
    mockRemoveItemFromCart = MockRemoveItemFromCartUseCase();
    mockApplyCartDiscount = MockApplyCartDiscountUseCase();
    mockClearCart = MockClearCartUseCase();
    mockHoldTab = MockHoldTabUseCase();
    mockGetHeldTabs = MockGetHeldTabsUseCase();
    mockResumeHeldTab = MockResumeHeldTabUseCase();
    mockDeleteHeldTab = MockDeleteHeldTabUseCase();
    mockProcessCheckout = MockProcessCheckoutUseCase();
    mockGetProducts = MockGetProductsUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockGetProductByBarcode = MockGetProductByBarcodeUseCase();

    posBloc = PosBloc(
      getActiveCartUseCase: mockGetActiveCart,
      addItemToCartUseCase: mockAddItemToCart,
      updateCartQuantityUseCase: mockUpdateCartQuantity,
      removeItemFromCartUseCase: mockRemoveItemFromCart,
      applyCartDiscountUseCase: mockApplyCartDiscount,
      clearCartUseCase: mockClearCart,
      holdTabUseCase: mockHoldTab,
      getHeldTabsUseCase: mockGetHeldTabs,
      resumeHeldTabUseCase: mockResumeHeldTab,
      deleteHeldTabUseCase: mockDeleteHeldTab,
      processCheckoutUseCase: mockProcessCheckout,
      getProductsUseCase: mockGetProducts,
      getCategoriesUseCase: mockGetCategories,
      getProductByBarcodeUseCase: mockGetProductByBarcode,
    );
  });

  tearDown(() {
    posBloc.close();
  });

  group('PosBloc Tests', () {
    test('initial state should be PosInitial', () {
      expect(posBloc.state, equals(const PosInitial()));
    });

    blocTest<PosBloc, PosState>(
      'emits [PosLoading, PosReady] when InitPosSession succeeds',
      build: () {
        when(() => mockGetActiveCart()).thenAnswer((_) async => const Right(Cart()));
        when(() => mockGetHeldTabs()).thenAnswer((_) async => const Right([]));
        when(() => mockGetProducts(any())).thenAnswer((_) async => const Right([tProduct]));
        when(() => mockGetCategories(onlyActive: true)).thenAnswer((_) async => const Right([]));
        return posBloc;
      },
      act: (b) => b.add(const InitPosSession()),
      expect: () => [
        const PosLoading(),
        const PosReady(
          cart: Cart(taxRate: 0.14),
          allProducts: [tProduct],
          displayedProducts: [tProduct],
          categories: [],
          heldTabs: [],
        ),
      ],
    );

    blocTest<PosBloc, PosState>(
      'adds product to active cart and emits updated PosReady',
      build: () {
        when(() => mockAddItemToCart(any())).thenAnswer((_) async => const Right(tCart));
        return posBloc;
      },
      seed: () => const PosReady(
        cart: Cart(taxRate: 0.14),
        allProducts: [tProduct],
        displayedProducts: [tProduct],
      ),
      act: (b) => b.add(const AddProductToCart(tProduct)),
      expect: () => [
        const PosReady(
          cart: tCart,
          allProducts: [tProduct],
          displayedProducts: [tProduct],
          toastMessage: 'Added "Espresso" to order.',
        ),
      ],
    );
  });
}
