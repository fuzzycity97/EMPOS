import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import 'catalog_event.dart';

abstract class CatalogState extends Equatable {
  const CatalogState();

  @override
  List<Object?> get props => [];
}

class CatalogInitial extends CatalogState {
  const CatalogInitial();
}

class CatalogLoading extends CatalogState {
  const CatalogLoading();
}

class CatalogLoaded extends CatalogState {
  final List<Product> allProducts;
  final List<Product> displayedProducts;
  final List<Category> categories;
  final String? selectedCategoryId;
  final String searchQuery;
  final StockFilter stockFilter;
  final String? toastMessage;

  const CatalogLoaded({
    required this.allProducts,
    required this.displayedProducts,
    required this.categories,
    this.selectedCategoryId,
    this.searchQuery = '',
    this.stockFilter = StockFilter.all,
    this.toastMessage,
  });

  int get totalCount => allProducts.length;
  int get lowStockCount => allProducts.where((p) => p.isLowStock).length;
  int get outOfStockCount => allProducts.where((p) => p.isOutOfStock).length;
  int get inStockCount => allProducts.where((p) => !p.isOutOfStock && p.trackQty).length;
  int get servicesCount => allProducts.where((p) => !p.trackQty).length;

  CatalogLoaded copyWith({
    List<Product>? allProducts,
    List<Product>? displayedProducts,
    List<Category>? categories,
    String? Function()? selectedCategoryId,
    String? searchQuery,
    StockFilter? stockFilter,
    String? Function()? toastMessage,
  }) {
    return CatalogLoaded(
      allProducts: allProducts ?? this.allProducts,
      displayedProducts: displayedProducts ?? this.displayedProducts,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId != null
          ? selectedCategoryId()
          : this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
      stockFilter: stockFilter ?? this.stockFilter,
      toastMessage: toastMessage != null ? toastMessage() : this.toastMessage,
    );
  }

  @override
  List<Object?> get props => [
        allProducts,
        displayedProducts,
        categories,
        selectedCategoryId,
        searchQuery,
        stockFilter,
        toastMessage,
      ];
}

class CatalogError extends CatalogState {
  final String message;

  const CatalogError(this.message);

  @override
  List<Object?> get props => [message];
}
