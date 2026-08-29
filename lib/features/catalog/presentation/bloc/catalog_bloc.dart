import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/delete_product_usecase.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/get_products_usecase.dart';
import '../../domain/usecases/save_category_usecase.dart';
import '../../domain/usecases/save_product_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/toggle_category_status_usecase.dart';
import '../../domain/repositories/catalog_repository.dart';
import 'catalog_event.dart';
import 'catalog_state.dart';

class CatalogBloc extends Bloc<CatalogEvent, CatalogState> {
  final GetProductsUseCase getProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final SaveProductUseCase saveProductUseCase;
  final DeleteProductUseCase deleteProductUseCase;
  final SaveCategoryUseCase saveCategoryUseCase;
  final ToggleCategoryStatusUseCase toggleCategoryStatusUseCase;
  final CatalogRepository? catalogRepository;

  CatalogBloc({
    required this.getProductsUseCase,
    required this.getCategoriesUseCase,
    required this.searchProductsUseCase,
    required this.saveProductUseCase,
    required this.deleteProductUseCase,
    required this.saveCategoryUseCase,
    required this.toggleCategoryStatusUseCase,
    this.catalogRepository,
  }) : super(const CatalogInitial()) {
    on<LoadCatalog>(_onLoadCatalog);
    on<SearchCatalog>(_onSearchCatalog);
    on<SelectCategory>(_onSelectCategory);
    on<FilterByStockStatus>(_onFilterByStockStatus);
    on<ToggleCategoryStatus>(_onToggleCategoryStatus);
    on<SaveProductEvent>(_onSaveProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
    on<SaveCategoryEvent>(_onSaveCategory);
    on<SeedCatalogForBlueprintEvent>(_onSeedCatalogForBlueprint);
  }

  Future<void> _onSeedCatalogForBlueprint(
    SeedCatalogForBlueprintEvent event,
    Emitter<CatalogState> emit,
  ) async {
    emit(const CatalogLoading());
    if (catalogRepository != null && event.blueprint != null) {
      await catalogRepository!.seedCatalogForBlueprint(event.blueprint, force: event.force);
    }
    add(const LoadCatalog(forceRefresh: true));
  }

  Future<void> _onLoadCatalog(
    LoadCatalog event,
    Emitter<CatalogState> emit,
  ) async {
    emit(const CatalogLoading());

    final categoriesResult = await getCategoriesUseCase();
    final productsResult = await getProductsUseCase();

    categoriesResult.fold(
      (failure) => emit(CatalogError(failure.message)),
      (categories) {
        productsResult.fold(
          (failure) => emit(CatalogError(failure.message)),
          (products) {
            emit(CatalogLoaded(
              allProducts: products,
              displayedProducts: products,
              categories: categories,
              selectedCategoryId: null,
              searchQuery: '',
              stockFilter: StockFilter.all,
            ));
          },
        );
      },
    );
  }

  void _onSearchCatalog(
    SearchCatalog event,
    Emitter<CatalogState> emit,
  ) {
    if (state is CatalogLoaded) {
      final current = state as CatalogLoaded;
      final filtered = _filterProducts(
        allProducts: current.allProducts,
        searchQuery: event.query,
        categoryId: current.selectedCategoryId,
        stockFilter: current.stockFilter,
      );
      emit(current.copyWith(
        searchQuery: event.query,
        displayedProducts: filtered,
      ));
    }
  }

  void _onSelectCategory(
    SelectCategory event,
    Emitter<CatalogState> emit,
  ) {
    if (state is CatalogLoaded) {
      final current = state as CatalogLoaded;
      final newCategoryId = (event.categoryId == null || event.categoryId == 'ALL')
          ? null
          : event.categoryId;

      final filtered = _filterProducts(
        allProducts: current.allProducts,
        searchQuery: current.searchQuery,
        categoryId: newCategoryId,
        stockFilter: current.stockFilter,
      );
      emit(current.copyWith(
        selectedCategoryId: () => newCategoryId,
        displayedProducts: filtered,
      ));
    }
  }

  void _onFilterByStockStatus(
    FilterByStockStatus event,
    Emitter<CatalogState> emit,
  ) {
    if (state is CatalogLoaded) {
      final current = state as CatalogLoaded;
      final filtered = _filterProducts(
        allProducts: current.allProducts,
        searchQuery: current.searchQuery,
        categoryId: current.selectedCategoryId,
        stockFilter: event.filter,
      );
      emit(current.copyWith(
        stockFilter: event.filter,
        displayedProducts: filtered,
      ));
    }
  }

  Future<void> _onToggleCategoryStatus(
    ToggleCategoryStatus event,
    Emitter<CatalogState> emit,
  ) async {
    final result = await toggleCategoryStatusUseCase(
      event.categoryId,
      event.isEnabled,
    );

    result.fold(
      (failure) {
        if (state is CatalogLoaded) {
          final current = state as CatalogLoaded;
          emit(current.copyWith(
            toastMessage: () => 'Failed to update category: ${failure.message}',
          ));
        }
      },
      (_) {
        if (state is CatalogLoaded) {
          final current = state as CatalogLoaded;
          final updatedCategories = current.categories.map((c) {
            if (c.id == event.categoryId) {
              return c.copyWith(isEnabled: event.isEnabled);
            }
            return c;
          }).toList();

          emit(current.copyWith(
            categories: updatedCategories,
            toastMessage: () => 'Category status updated.',
          ));
        }
      },
    );
  }

  Future<void> _onSaveProduct(
    SaveProductEvent event,
    Emitter<CatalogState> emit,
  ) async {
    final result = await saveProductUseCase(event.product);

    result.fold(
      (failure) {
        if (state is CatalogLoaded) {
          final current = state as CatalogLoaded;
          emit(current.copyWith(
            toastMessage: () => 'Failed to save product: ${failure.message}',
          ));
        }
      },
      (_) {
        if (state is CatalogLoaded) {
          final current = state as CatalogLoaded;
          final existingIndex = current.allProducts.indexWhere((p) => p.id == event.product.id);
          final updatedAll = List<Product>.from(current.allProducts);

          if (existingIndex >= 0) {
            updatedAll[existingIndex] = event.product;
          } else {
            updatedAll.add(event.product);
          }

          final filtered = _filterProducts(
            allProducts: updatedAll,
            searchQuery: current.searchQuery,
            categoryId: current.selectedCategoryId,
            stockFilter: current.stockFilter,
          );

          emit(current.copyWith(
            allProducts: updatedAll,
            displayedProducts: filtered,
            toastMessage: () => 'Product "${event.product.nameEn}" saved successfully.',
          ));
        }
      },
    );
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<CatalogState> emit,
  ) async {
    final result = await deleteProductUseCase(event.productId);

    result.fold(
      (failure) {
        if (state is CatalogLoaded) {
          final current = state as CatalogLoaded;
          emit(current.copyWith(
            toastMessage: () => 'Failed to delete product: ${failure.message}',
          ));
        }
      },
      (_) {
        if (state is CatalogLoaded) {
          final current = state as CatalogLoaded;
          final updatedAll = current.allProducts.where((p) => p.id != event.productId).toList();
          final filtered = _filterProducts(
            allProducts: updatedAll,
            searchQuery: current.searchQuery,
            categoryId: current.selectedCategoryId,
            stockFilter: current.stockFilter,
          );

          emit(current.copyWith(
            allProducts: updatedAll,
            displayedProducts: filtered,
            toastMessage: () => 'Product deleted.',
          ));
        }
      },
    );
  }

  Future<void> _onSaveCategory(
    SaveCategoryEvent event,
    Emitter<CatalogState> emit,
  ) async {
    final result = await saveCategoryUseCase(event.category);

    result.fold(
      (failure) {
        if (state is CatalogLoaded) {
          final current = state as CatalogLoaded;
          emit(current.copyWith(
            toastMessage: () => 'Failed to save category: ${failure.message}',
          ));
        }
      },
      (_) {
        if (state is CatalogLoaded) {
          final current = state as CatalogLoaded;
          final existingIndex = current.categories.indexWhere((c) => c.id == event.category.id);
          final updatedCats = List<Category>.from(current.categories);

          if (existingIndex >= 0) {
            updatedCats[existingIndex] = event.category;
          } else {
            updatedCats.add(event.category);
          }

          emit(current.copyWith(
            categories: updatedCats,
            toastMessage: () => 'Category "${event.category.name}" saved.',
          ));
        }
      },
    );
  }

  List<Product> _filterProducts({
    required List<Product> allProducts,
    required String searchQuery,
    required String? categoryId,
    required StockFilter stockFilter,
  }) {
    final query = searchQuery.trim().toLowerCase();

    return allProducts.where((p) {
      // 1. Category Filter
      if (categoryId != null && categoryId.isNotEmpty && p.categoryId != categoryId) {
        return false;
      }

      // 2. Search Query (English name, Arabic name, barcode, category ID)
      if (query.isNotEmpty) {
        final matchEn = p.nameEn.toLowerCase().contains(query);
        final matchAr = p.nameAr?.toLowerCase().contains(query) ?? false;
        final matchBarcode = p.barcode.toLowerCase().contains(query);
        final matchCat = p.categoryId.toLowerCase().contains(query);
        if (!matchEn && !matchAr && !matchBarcode && !matchCat) {
          return false;
        }
      }

      // 3. Stock Status Filter
      switch (stockFilter) {
        case StockFilter.all:
          return true;
        case StockFilter.inStock:
          return !p.isOutOfStock && p.trackQty;
        case StockFilter.lowStock:
          return p.isLowStock;
        case StockFilter.outOfStock:
          return p.isOutOfStock;
        case StockFilter.services:
          return !p.trackQty;
      }
    }).toList();
  }
}
