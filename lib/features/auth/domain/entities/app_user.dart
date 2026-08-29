import 'package:equatable/equatable.dart';
import 'user_role.dart';

class AppUser extends Equatable {
  final String id;
  final String name;
  final UserRole role;
  final String pinCodeHash;
  final bool isActive;

  const AppUser({
    required this.id,
    required this.name,
    required this.role,
    required this.pinCodeHash,
    this.isActive = true,
  });

  AppUser copyWith({
    String? id,
    String? name,
    UserRole? role,
    String? pinCodeHash,
    bool? isActive,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      pinCodeHash: pinCodeHash ?? this.pinCodeHash,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, role, pinCodeHash, isActive];
}
