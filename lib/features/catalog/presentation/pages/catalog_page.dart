import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/responsive/responsive_layout.dart';
import '../../domain/entities/product.dart';
import '../../../data_io/presentation/bloc/data_io_bloc.dart';
import '../../../data_io/presentation/widgets/data_io_manager_dialog.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';
import '../bloc/catalog_state.dart';
import '../widgets/catalog_search_bar.dart';
import '../widgets/catalog_stats_header.dart';
import '../widgets/category_filter_list.dart';
import '../widgets/product_card.dart';
import '../widgets/product_form_dialog.dart';

class CatalogPage extends StatelessWidget {
  final CatalogBloc? bloc;

  const CatalogPage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<CatalogBloc>.value(
        value: bloc!,
        child: const _CatalogPageView(),
      );
    }

    return BlocProvider(
      create: (_) => sl<CatalogBloc>()..add(const LoadCatalog()),
      child: const _CatalogPageView(),
    );
  }
}

class _CatalogPageView extends StatelessWidget {
  const _CatalogPageView();

  void _openProductDialog(
    BuildContext context, {
    Product? productToEdit,
    required CatalogLoaded loadedState,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<CatalogBloc>(),
          child: ProductFormDialog(
            productToEdit: productToEdit,
            categories: loadedState.categories,
          ),
        );
      },
    );
  }

  void _openDataIoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider(
          create: (_) => sl<DataIoBloc>(),
          child: DataIoManagerDialog(
            onImportCompleted: () {
              context.read<CatalogBloc>().add(const LoadCatalog());
            },
          ),
        );
      },
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            side: const BorderSide(color: AppColors.borderDark),
          ),
          title: Row(
            children: const [
              Icon(LucideIcons.triangleAlert, color: AppColors.danger, size: 20),
              SizedBox(width: AppDimensions.space8),
              Text('Delete Catalog Item?'),
            ],
          ),
          content: Text(
            'Are you sure you want to permanently remove "${product.nameEn}" from the catalog?',
            style: const TextStyle(color: AppColors.textSecondaryDark),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
              onPressed: () {
                context.read<CatalogBloc>().add(DeleteProductEvent(product.id));
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<CatalogBloc, CatalogState>(
        listener: (context, state) {
          if (state is CatalogLoaded && state.toastMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.toastMessage!),
                backgroundColor: AppColors.surfaceElevatedDark,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CatalogLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CatalogError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    LucideIcons.circleAlert,
                    color: AppColors.danger,
                    size: 48,
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  Text(
                    'Failed to load catalog',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: AppDimensions.space8),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        context.read<CatalogBloc>().add(const LoadCatalog()),
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CatalogLoaded) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.space16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Stats & Action Header
                    CatalogStatsHeader(
                      onAddProduct: () => _openProductDialog(
                        context,
                        loadedState: state,
                      ),
                      onImportExport: () => _openDataIoDialog(context),
                    ),
                    const SizedBox(height: AppDimensions.space12),

                    // 2. Search Bar
                    const CatalogSearchBar(),
                    const SizedBox(height: AppDimensions.space12),

                    // 3. Category Filter Tabs
                    const CategoryFilterList(),
                    const SizedBox(height: AppDimensions.space16),

                    // 4. Responsive Product Grid
                    Expanded(
                      child: state.displayedProducts.isEmpty
                          ? _buildEmptyState(context, state)
                          : ResponsiveLayout(
                              mobile: _ProductGrid(
                                crossAxisCount: 1,
                                childAspectRatio: 2.0,
                                products: state.displayedProducts,
                                onEdit: (p) => _openProductDialog(
                                  context,
                                  productToEdit: p,
                                  loadedState: state,
                                ),
                                onDelete: (p) =>
                                    _confirmDeleteProduct(context, p),
                              ),
                              tablet: _ProductGrid(
                                crossAxisCount: 2,
                                childAspectRatio: 1.5,
                                products: state.displayedProducts,
                                onEdit: (p) => _openProductDialog(
                                  context,
                                  productToEdit: p,
                                  loadedState: state,
                                ),
                                onDelete: (p) =>
                                    _confirmDeleteProduct(context, p),
                              ),
                              desktop: _ProductGrid(
                                crossAxisCount: 4,
                                childAspectRatio: 1.35,
                                products: state.displayedProducts,
                                onEdit: (p) => _openProductDialog(
                                  context,
                                  productToEdit: p,
                                  loadedState: state,
                                ),
                                onDelete: (p) =>
                                    _confirmDeleteProduct(context, p),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, CatalogLoaded state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space20),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevatedDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              LucideIcons.packageSearch,
              size: 48,
              color: AppColors.textMutedDark,
            ),
          ),
          const SizedBox(height: AppDimensions.space16),
          Text(
            state.searchQuery.isNotEmpty
                ? 'No items found matching "${state.searchQuery}"'
                : 'No products in this category',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppDimensions.space8),
          const Text(
            'Try adjusting your search query, selecting another category, or add a new product.',
            style: TextStyle(color: AppColors.textSecondaryDark),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProductGrid extends StatelessWidget {
  final int crossAxisCount;
  final double childAspectRatio;
  final List<Product> products;
  final ValueChanged<Product> onEdit;
  final ValueChanged<Product> onDelete;

  const _ProductGrid({
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.products,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppDimensions.space12,
        mainAxisSpacing: AppDimensions.space12,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onEdit: () => onEdit(product),
          onDelete: () => onDelete(product),
        );
      },
    );
  }
}
