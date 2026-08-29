import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String nameEn;
  final String? nameAr;
  final String categoryId;
  final double price;
  final double? cost;
  final int stock;
  final String barcode;
  final bool trackQty;
  final bool isEnabled;
  final double taxRate;
  final String? description;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.nameEn,
    this.nameAr,
    required this.categoryId,
    required this.price,
    this.cost,
    required this.stock,
    required this.barcode,
    this.trackQty = true,
    this.isEnabled = true,
    this.taxRate = 0.0,
    this.description,
    this.imageUrl,
  });

  bool get isOutOfStock => trackQty && stock <= 0;
  bool get isLowStock => trackQty && stock > 0 && stock <= 5;
  String get displayName => (nameAr != null && nameAr!.isNotEmpty) ? nameAr! : nameEn;

  Product copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? categoryId,
    double? price,
    double? cost,
    int? stock,
    String? barcode,
    bool? trackQty,
    bool? isEnabled,
    double? taxRate,
    String? description,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      categoryId: categoryId ?? this.categoryId,
      price: price ?? this.price,
      cost: cost ?? this.cost,
      stock: stock ?? this.stock,
      barcode: barcode ?? this.barcode,
      trackQty: trackQty ?? this.trackQty,
      isEnabled: isEnabled ?? this.isEnabled,
      taxRate: taxRate ?? this.taxRate,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nameEn,
        nameAr,
        categoryId,
        price,
        cost,
        stock,
        barcode,
        trackQty,
        isEnabled,
        taxRate,
        description,
        imageUrl,
      ];
}
