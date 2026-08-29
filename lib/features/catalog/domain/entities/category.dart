import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String? nameAr;
  final String? icon;
  final bool isEnabled;
  final int orderIndex;

  const Category({
    required this.id,
    required this.name,
    this.nameAr,
    this.icon,
    this.isEnabled = true,
    this.orderIndex = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? icon,
    bool? isEnabled,
    int? orderIndex,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      orderIndex: orderIndex ?? this.orderIndex,
    );
  }

  @override
  List<Object?> get props => [id, name, nameAr, icon, isEnabled, orderIndex];
}
