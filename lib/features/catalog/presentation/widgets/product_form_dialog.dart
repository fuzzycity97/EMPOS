import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/product.dart';
import '../bloc/catalog_bloc.dart';
import '../bloc/catalog_event.dart';

class ProductFormDialog extends StatelessWidget {
  final Product? productToEdit;
  final List<Category> categories;
  final TextEditingController nameEnController;
  final TextEditingController nameArController;
  final TextEditingController priceController;
  final TextEditingController costController;
  final TextEditingController stockController;
  final TextEditingController barcodeController;
  final ValueNotifier<String> categoryIdNotifier;
  final ValueNotifier<bool> trackQtyNotifier;

  const ProductFormDialog._({
    super.key,
    this.productToEdit,
    required this.categories,
    required this.nameEnController,
    required this.nameArController,
    required this.priceController,
    required this.costController,
    required this.stockController,
    required this.barcodeController,
    required this.categoryIdNotifier,
    required this.trackQtyNotifier,
  });

  factory ProductFormDialog({
    Key? key,
    Product? productToEdit,
    required List<Category> categories,
  }) {
    final defaultCatId = categories.isNotEmpty ? categories.first.id : 'cat-general';
    final initialBarcode = productToEdit?.barcode ??
        '622${(10000000 + (DateTime.now().millisecondsSinceEpoch % 90000000))}';

    return ProductFormDialog._(
      key: key,
      productToEdit: productToEdit,
      categories: categories,
      nameEnController: TextEditingController(text: productToEdit?.nameEn ?? ''),
      nameArController: TextEditingController(text: productToEdit?.nameAr ?? ''),
      priceController: TextEditingController(
        text: productToEdit != null ? productToEdit.price.toStringAsFixed(2) : '50.00',
      ),
      costController: TextEditingController(
        text: productToEdit?.cost != null ? productToEdit!.cost!.toStringAsFixed(2) : '20.00',
      ),
      stockController: TextEditingController(
        text: productToEdit != null ? productToEdit.stock.toString() : '50',
      ),
      barcodeController: TextEditingController(text: initialBarcode),
      categoryIdNotifier: ValueNotifier<String>(
        productToEdit?.categoryId ?? defaultCatId,
      ),
      trackQtyNotifier: ValueNotifier<bool>(productToEdit?.trackQty ?? true),
    );
  }

  void _submit(BuildContext context) {
    final nameEn = nameEnController.text.trim();
    if (nameEn.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an English product name.')),
      );
      return;
    }

    final price = double.tryParse(priceController.text.trim()) ?? 0.0;
    final cost = double.tryParse(costController.text.trim());
    final isTracked = trackQtyNotifier.value;
    final stock = isTracked
        ? (int.tryParse(stockController.text.trim()) ?? 0)
        : 999999;
    final barcode = barcodeController.text.trim();
    final catId = categoryIdNotifier.value;

    final newProduct = Product(
      id: productToEdit?.id ?? 'prod-${const Uuid().v4().substring(0, 8)}',
      nameEn: nameEn,
      nameAr: nameArController.text.trim().isNotEmpty
          ? nameArController.text.trim()
          : null,
      categoryId: catId,
      price: price,
      cost: cost,
      stock: stock,
      barcode: barcode,
      trackQty: isTracked,
      isEnabled: productToEdit?.isEnabled ?? true,
    );

    context.read<CatalogBloc>().add(SaveProductEvent(newProduct));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = productToEdit != null;

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space24),
        constraints: const BoxConstraints(maxWidth: 540),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEditing ? LucideIcons.pencil : LucideIcons.boxes,
                        size: 20,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: AppDimensions.space8),
                      Text(
                        isEditing ? 'Edit Catalog Item' : 'Add New Product / Service',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),
              const Divider(),
              const SizedBox(height: AppDimensions.space16),

              // Product Name EN
              _buildFieldLabel('Product Name (EN) *'),
              TextField(
                controller: nameEnController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Double Espresso, Mineral Water',
                ),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Product Name AR
              _buildFieldLabel('Product Name (Arabic - Optional)'),
              TextField(
                controller: nameArController,
                decoration: const InputDecoration(
                  hintText: 'e.g. اسبريسو دبل, مياه معدنية',
                ),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Category & Barcode Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Category'),
                        ValueListenableBuilder<String>(
                          valueListenable: categoryIdNotifier,
                          builder: (context, currentCatId, _) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevatedDark,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                border: Border.all(color: AppColors.borderDark),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: currentCatId,
                                  isExpanded: true,
                                  dropdownColor: AppColors.surfaceDark,
                                  items: categories.map((c) {
                                    return DropdownMenuItem(
                                      value: c.id,
                                      child: Text(
                                        c.name,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    if (val != null) categoryIdNotifier.value = val;
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Barcode / SKU'),
                        TextField(
                          controller: barcodeController,
                          decoration: const InputDecoration(
                            hintText: '622...',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Price & Cost Row
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Selling Price (EGP) *'),
                        TextField(
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0.00',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFieldLabel('Cost (EGP)'),
                        TextField(
                          controller: costController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '0.00',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Track Stock Toggle & Initial Stock
              ValueListenableBuilder<bool>(
                valueListenable: trackQtyNotifier,
                builder: (context, trackQty, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                trackQty ? LucideIcons.box : LucideIcons.sparkles,
                                size: 16,
                                color: trackQty ? AppColors.primaryLight : AppColors.accent,
                              ),
                              const SizedBox(width: AppDimensions.space8),
                              const Text(
                                'Track Physical Inventory Quantity',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: trackQty,
                            activeTrackColor: AppColors.primary,
                            onChanged: (val) => trackQtyNotifier.value = val,
                          ),
                        ],
                      ),
                      if (trackQty) ...[
                        const SizedBox(height: AppDimensions.space8),
                        _buildFieldLabel('Current Inventory Stock Qty'),
                        TextField(
                          controller: stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: '50',
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  ElevatedButton.icon(
                    onPressed: () => _submit(context),
                    icon: const Icon(LucideIcons.check, size: 16),
                    label: Text(isEditing ? 'Update Item' : 'Save Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondaryDark,
        ),
      ),
    );
  }
}
