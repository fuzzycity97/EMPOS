import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.nameEn,
    super.nameAr,
    required super.categoryId,
    required super.price,
    super.cost,
    required super.stock,
    required super.barcode,
    super.trackQty = true,
    super.isEnabled = true,
    super.taxRate = 0.0,
    super.description,
    super.imageUrl,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawTrackQty = json['trackQty'];
    final bool isTracked = rawTrackQty == null
        ? true
        : (rawTrackQty == true || rawTrackQty == 1 || rawTrackQty == 'true');

    return ProductModel(
      id: json['id']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? json['name']?.toString() ?? 'Unnamed Product',
      nameAr: json['nameAr']?.toString(),
      categoryId: json['categoryId']?.toString() ?? json['cat']?.toString() ?? 'General',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      cost: (json['cost'] as num?)?.toDouble(),
      stock: (json['stock'] as num?)?.toInt() ?? (isTracked ? 50 : 999999),
      barcode: json['barcode']?.toString() ?? '',
      trackQty: isTracked,
      isEnabled: json['isEnabled'] == null ? true : (json['isEnabled'] == true || json['isEnabled'] == 1 || json['isEnabled'] == 'true'),
      taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      description: json['description']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nameEn': nameEn,
      'nameAr': nameAr,
      'categoryId': categoryId,
      'price': price,
      'cost': cost,
      'stock': stock,
      'barcode': barcode,
      'trackQty': trackQty,
      'isEnabled': isEnabled,
      'taxRate': taxRate,
      'description': description,
      'imageUrl': imageUrl,
    };
  }

  factory ProductModel.fromEntity(Product entity) {
    return ProductModel(
      id: entity.id,
      nameEn: entity.nameEn,
      nameAr: entity.nameAr,
      categoryId: entity.categoryId,
      price: entity.price,
      cost: entity.cost,
      stock: entity.stock,
      barcode: entity.barcode,
      trackQty: entity.trackQty,
      isEnabled: entity.isEnabled,
      taxRate: entity.taxRate,
      description: entity.description,
      imageUrl: entity.imageUrl,
    );
  }
}
