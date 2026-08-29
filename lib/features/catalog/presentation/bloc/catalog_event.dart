import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';

enum StockFilter { all, inStock, lowStock, outOfStock, services }

abstract class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadCatalog extends CatalogEvent {
  final bool forceRefresh;

  const LoadCatalog({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class SearchCatalog extends CatalogEvent {
  final String query;

  const SearchCatalog(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectCategory extends CatalogEvent {
  final String? categoryId; // null or 'ALL' represents all categories

  const SelectCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

class FilterByStockStatus extends CatalogEvent {
  final StockFilter filter;

  const FilterByStockStatus(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ToggleCategoryStatus extends CatalogEvent {
  final String categoryId;
  final bool isEnabled;

  const ToggleCategoryStatus({
    required this.categoryId,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [categoryId, isEnabled];
}

class SaveProductEvent extends CatalogEvent {
  final Product product;

  const SaveProductEvent(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProductEvent extends CatalogEvent {
  final String productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}

class SaveCategoryEvent extends CatalogEvent {
  final Category category;

  const SaveCategoryEvent(this.category);

  @override
  List<Object?> get props => [category];
}

class SeedCatalogForBlueprintEvent extends CatalogEvent {
  final dynamic blueprint;
  final bool force;

  const SeedCatalogForBlueprintEvent(this.blueprint, {this.force = true});

  @override
  List<Object?> get props => [blueprint, force];
}
