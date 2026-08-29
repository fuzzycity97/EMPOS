import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.nameAr,
    super.icon,
    super.isEnabled = true,
    super.orderIndex = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['nameEn']?.toString() ?? 'General',
      nameAr: json['nameAr']?.toString(),
      icon: json['icon']?.toString(),
      isEnabled: json['isEnabled'] == null ? true : (json['isEnabled'] == true || json['isEnabled'] == 1 || json['isEnabled'] == 'true'),
      orderIndex: (json['orderIndex'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameAr,
      'icon': icon,
      'isEnabled': isEnabled,
      'orderIndex': orderIndex,
    };
  }

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      nameAr: entity.nameAr,
      icon: entity.icon,
      isEnabled: entity.isEnabled,
      orderIndex: entity.orderIndex,
    );
  }
}
