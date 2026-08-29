import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/catalog/domain/entities/category.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/catalog/domain/usecases/delete_product_usecase.dart';
import 'package:empos/features/catalog/domain/usecases/get_categories_usecase.dart';
import 'package:empos/features/catalog/domain/usecases/get_products_usecase.dart';
import 'package:empos/features/catalog/domain/usecases/save_category_usecase.dart';
import 'package:empos/features/catalog/domain/usecases/save_product_usecase.dart';
import 'package:empos/features/catalog/domain/usecases/search_products_usecase.dart';
import 'package:empos/features/catalog/domain/usecases/toggle_category_status_usecase.dart';
import 'package:empos/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:empos/features/catalog/presentation/bloc/catalog_event.dart';
import 'package:empos/features/catalog/presentation/bloc/catalog_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}
class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}
class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}
class MockSaveProductUseCase extends Mock implements SaveProductUseCase {}
class MockDeleteProductUseCase extends Mock implements DeleteProductUseCase {}
class MockSaveCategoryUseCase extends Mock implements SaveCategoryUseCase {}
class MockToggleCategoryStatusUseCase extends Mock implements ToggleCategoryStatusUseCase {}

void main() {
  late MockGetProductsUseCase mockGetProducts;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockSearchProductsUseCase mockSearchProducts;
  late MockSaveProductUseCase mockSaveProduct;
  late MockDeleteProductUseCase mockDeleteProduct;
  late MockSaveCategoryUseCase mockSaveCategory;
  late MockToggleCategoryStatusUseCase mockToggleCategory;
  late CatalogBloc bloc;

  const tCategories = [
    Category(id: 'cat-1', name: 'Beverages', isEnabled: true),
  ];

  const tProducts = [
    Product(
      id: 'p-1',
      nameEn: 'Espresso',
      categoryId: 'cat-1',
      price: 45.0,
      stock: 50,
      barcode: '12345',
    ),
  ];

  setUp(() {
    mockGetProducts = MockGetProductsUseCase();
    mockGetCategories = MockGetCategoriesUseCase();
    mockSearchProducts = MockSearchProductsUseCase();
    mockSaveProduct = MockSaveProductUseCase();
    mockDeleteProduct = MockDeleteProductUseCase();
    mockSaveCategory = MockSaveCategoryUseCase();
    mockToggleCategory = MockToggleCategoryStatusUseCase();

    bloc = CatalogBloc(
      getProductsUseCase: mockGetProducts,
      getCategoriesUseCase: mockGetCategories,
      searchProductsUseCase: mockSearchProducts,
      saveProductUseCase: mockSaveProduct,
      deleteProductUseCase: mockDeleteProduct,
      saveCategoryUseCase: mockSaveCategory,
      toggleCategoryStatusUseCase: mockToggleCategory,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CatalogBloc Tests', () {
    test('initial state should be CatalogInitial', () {
      expect(bloc.state, equals(const CatalogInitial()));
    });

    blocTest<CatalogBloc, CatalogState>(
      'emits [CatalogLoading, CatalogLoaded] when LoadCatalog succeeds',
      build: () {
        when(() => mockGetCategories()).thenAnswer((_) async => const Right(tCategories));
        when(() => mockGetProducts()).thenAnswer((_) async => const Right(tProducts));
        return bloc;
      },
      act: (b) => b.add(const LoadCatalog()),
      expect: () => [
        const CatalogLoading(),
        const CatalogLoaded(
          allProducts: tProducts,
          displayedProducts: tProducts,
          categories: tCategories,
          selectedCategoryId: null,
          searchQuery: '',
          stockFilter: StockFilter.all,
        ),
      ],
    );

    blocTest<CatalogBloc, CatalogState>(
      'filters displayed products when SearchCatalog is added',
      build: () {
        when(() => mockGetCategories()).thenAnswer((_) async => const Right(tCategories));
        when(() => mockGetProducts()).thenAnswer((_) async => const Right(tProducts));
        return bloc;
      },
      seed: () => const CatalogLoaded(
        allProducts: tProducts,
        displayedProducts: tProducts,
        categories: tCategories,
      ),
      act: (b) => b.add(const SearchCatalog('nonexistent')),
      expect: () => [
        const CatalogLoaded(
          allProducts: tProducts,
          displayedProducts: [],
          categories: tCategories,
          searchQuery: 'nonexistent',
        ),
      ],
    );
  });
}
