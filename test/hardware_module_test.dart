import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/hardware/domain/repositories/hardware_repository.dart';
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
import 'package:empos/features/pos/presentation/bloc/pos_state.dart';
import 'package:dartz/dartz.dart';

class MockHardwareRepository extends Mock implements HardwareRepository {}
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
  TestWidgetsFlutterBinding.ensureInitialized();

  const tProduct = Product(
    id: 'prod-001',
    nameEn: 'Espresso Double',
    categoryId: 'cat-general',
    price: 45.0,
    stock: 100,
    barcode: '622100000001',
  );

  setUpAll(() {
    registerFallbackValue(
      const AddItemToCartParams(
        currentCart: Cart(),
        product: tProduct,
        quantity: 1,
      ),
    );
    registerFallbackValue(const GetProductsParams());
  });

  late MockHardwareRepository mockHardwareRepository;
  late MockGetActiveCartUseCase mockGetActiveCartUseCase;
  late MockAddItemToCartUseCase mockAddItemToCartUseCase;
  late MockUpdateCartQuantityUseCase mockUpdateCartQuantityUseCase;
  late MockRemoveItemFromCartUseCase mockRemoveItemFromCartUseCase;
  late MockApplyCartDiscountUseCase mockApplyCartDiscountUseCase;
  late MockClearCartUseCase mockClearCartUseCase;
  late MockHoldTabUseCase mockHoldTabUseCase;
  late MockGetHeldTabsUseCase mockGetHeldTabsUseCase;
  late MockResumeHeldTabUseCase mockResumeHeldTabUseCase;
  late MockDeleteHeldTabUseCase mockDeleteHeldTabUseCase;
  late MockProcessCheckoutUseCase mockProcessCheckoutUseCase;
  late MockGetProductsUseCase mockGetProductsUseCase;
  late MockGetCategoriesUseCase mockGetCategoriesUseCase;
  late MockGetProductByBarcodeUseCase mockGetProductByBarcodeUseCase;
  late StreamController<String> barcodeStreamController;

  setUp(() {
    mockHardwareRepository = MockHardwareRepository();
    mockGetActiveCartUseCase = MockGetActiveCartUseCase();
    mockAddItemToCartUseCase = MockAddItemToCartUseCase();
    mockUpdateCartQuantityUseCase = MockUpdateCartQuantityUseCase();
    mockRemoveItemFromCartUseCase = MockRemoveItemFromCartUseCase();
    mockApplyCartDiscountUseCase = MockApplyCartDiscountUseCase();
    mockClearCartUseCase = MockClearCartUseCase();
    mockHoldTabUseCase = MockHoldTabUseCase();
    mockGetHeldTabsUseCase = MockGetHeldTabsUseCase();
    mockResumeHeldTabUseCase = MockResumeHeldTabUseCase();
    mockDeleteHeldTabUseCase = MockDeleteHeldTabUseCase();
    mockProcessCheckoutUseCase = MockProcessCheckoutUseCase();
    mockGetProductsUseCase = MockGetProductsUseCase();
    mockGetCategoriesUseCase = MockGetCategoriesUseCase();
    mockGetProductByBarcodeUseCase = MockGetProductByBarcodeUseCase();
    barcodeStreamController = StreamController<String>.broadcast();

    when(() => mockHardwareRepository.barcodeScanStream).thenAnswer((_) => barcodeStreamController.stream);
  });

  tearDown(() {
    barcodeStreamController.close();
  });

  group('Hardware Barcode Auto-Scan in PosBloc', () {
    test('PosBloc automatically intercepts barcode stream from HardwareRepository and adds item to cart', () async {
      final initialCart = const Cart(taxRate: 0.14);
      final updatedCart = const Cart(
        items: [
          CartItem(product: tProduct, quantity: 1, unitPrice: 45.0),
        ],
        taxRate: 0.14,
      );

      when(() => mockGetActiveCartUseCase()).thenAnswer((_) async => Right(initialCart));
      when(() => mockGetHeldTabsUseCase()).thenAnswer((_) async => const Right([]));
      when(() => mockGetProductsUseCase(any())).thenAnswer((_) async => const Right([tProduct]));
      when(() => mockGetCategoriesUseCase(onlyActive: any(named: 'onlyActive'))).thenAnswer((_) async => const Right([]));
      when(() => mockGetProductByBarcodeUseCase('622100000001')).thenAnswer((_) async => const Right(tProduct));
      when(() => mockAddItemToCartUseCase(any())).thenAnswer((_) async => Right(updatedCart));

      final bloc = PosBloc(
        getActiveCartUseCase: mockGetActiveCartUseCase,
        addItemToCartUseCase: mockAddItemToCartUseCase,
        updateCartQuantityUseCase: mockUpdateCartQuantityUseCase,
        removeItemFromCartUseCase: mockRemoveItemFromCartUseCase,
        applyCartDiscountUseCase: mockApplyCartDiscountUseCase,
        clearCartUseCase: mockClearCartUseCase,
        holdTabUseCase: mockHoldTabUseCase,
        getHeldTabsUseCase: mockGetHeldTabsUseCase,
        resumeHeldTabUseCase: mockResumeHeldTabUseCase,
        deleteHeldTabUseCase: mockDeleteHeldTabUseCase,
        processCheckoutUseCase: mockProcessCheckoutUseCase,
        getProductsUseCase: mockGetProductsUseCase,
        getCategoriesUseCase: mockGetCategoriesUseCase,
        getProductByBarcodeUseCase: mockGetProductByBarcodeUseCase,
        hardwareRepository: mockHardwareRepository,
      );

      // Initialize session first
      bloc.emit(PosReady(
        cart: initialCart,
        allProducts: const [tProduct],
        displayedProducts: const [tProduct],
        categories: const [],
        heldTabs: const [],
      ));

      // Simulate physical scanner hardware emission
      barcodeStreamController.add('622100000001');

      await expectLater(
        bloc.stream,
        emitsThrough(
          predicate<PosState>((state) {
            if (state is PosReady) {
              return state.cart.items.length == 1 &&
                  state.toastMessage == 'Scanned "Espresso Double"';
            }
            return false;
          }),
        ),
      );

      verify(() => mockGetProductByBarcodeUseCase('622100000001')).called(1);
      verify(() => mockAddItemToCartUseCase(any())).called(1);

      await bloc.close();
    });
  });
}
