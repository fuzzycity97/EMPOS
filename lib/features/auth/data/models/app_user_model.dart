import '../../domain/entities/app_user.dart';
import '../../domain/entities/user_role.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.id,
    required super.name,
    required super.role,
    required super.pinCodeHash,
    super.isActive = true,
  });

  factory AppUserModel.fromJson(Map<String, dynamic> json) {
    return AppUserModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: UserRole.fromString(json['role']?.toString() ?? 'cashier'),
      pinCodeHash: json['pinCodeHash']?.toString() ?? json['pin']?.toString() ?? '',
      isActive: json['isActive'] == null ? true : (json['isActive'] == true || json['isActive'] == 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'role': role.name,
      'pinCodeHash': pinCodeHash,
      'isActive': isActive,
    };
  }

  factory AppUserModel.fromEntity(AppUser user) {
    return AppUserModel(
      id: user.id,
      name: user.name,
      role: user.role,
      pinCodeHash: user.pinCodeHash,
      isActive: user.isActive,
    );
  }
}
