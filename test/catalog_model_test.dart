import 'package:flutter_test/flutter_test.dart';
import 'package:empos/features/catalog/data/models/product_model.dart';
import 'package:empos/features/catalog/data/models/category_model.dart';

void main() {
  group('Catalog Models & Entities Unit Tests', () {
    test('ProductModel should correctly serialize to and from JSON', () {
      const model = ProductModel(
        id: 'test-1',
        nameEn: 'Espresso',
        nameAr: 'اسبريسو',
        categoryId: 'cat-beverages',
        price: 45.0,
        cost: 15.0,
        stock: 50,
        barcode: '123456789012',
        trackQty: true,
      );

      final json = model.toJson();
      final fromJson = ProductModel.fromJson(json);

      expect(fromJson.id, equals('test-1'));
      expect(fromJson.nameEn, equals('Espresso'));
      expect(fromJson.price, equals(45.0));
      expect(fromJson.isOutOfStock, isFalse);
    });

    test('CategoryModel should correctly support copyWith and serialization', () {
      const cat = CategoryModel(
        id: 'cat-1',
        name: 'Beverages',
        nameAr: 'مشروبات',
        isEnabled: true,
      );

      final updated = cat.copyWith(isEnabled: false);
      expect(updated.isEnabled, isFalse);

      final json = CategoryModel.fromEntity(updated).toJson();
      final fromJson = CategoryModel.fromJson(json);
      expect(fromJson.isEnabled, isFalse);
    });
  });
}
