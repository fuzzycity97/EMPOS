import 'dart:convert';
import 'package:hive/hive.dart';
import '../models/app_user_model.dart';
import '../../domain/entities/user_role.dart';

abstract class AuthLocalDataSource {
  Future<AppUserModel?> loginWithPin(String pin);
  Future<void> logout();
  Future<AppUserModel?> getCurrentUser();
  Future<void> seedDefaultUsers({bool force = false});
  Future<List<AppUserModel>> getAllUsers();
  Future<void> saveUser(AppUserModel user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  static const String authBoxName = 'empos_auth_box';
  static const String currentSessionKey = 'CURRENT_USER_SESSION';

  Future<Box<dynamic>> _openAuthBox() async {
    if (Hive.isBoxOpen(authBoxName)) {
      return Hive.box<dynamic>(authBoxName);
    }
    return await Hive.openBox<dynamic>(authBoxName);
  }

  @override
  Future<void> seedDefaultUsers({bool force = false}) async {
    final box = await _openAuthBox();
    final hasUsers = box.keys.any((k) => k.toString().startsWith('usr_'));

    if (hasUsers && !force) return;

    final defaultUsers = [
      const AppUserModel(
        id: 'usr_admin',
        name: 'Admin Director',
        role: UserRole.admin,
        pinCodeHash: '0000',
        isActive: true,
      ),
      const AppUserModel(
        id: 'usr_doctor',
        name: 'Dr. Sarah Connor',
        role: UserRole.doctor,
        pinCodeHash: '1111',
        isActive: true,
      ),
      const AppUserModel(
        id: 'usr_cashier',
        name: 'Ahmed Cashier',
        role: UserRole.cashier,
        pinCodeHash: '2222',
        isActive: true,
      ),
      const AppUserModel(
        id: 'usr_reception',
        name: 'Mona Receptionist',
        role: UserRole.receptionist,
        pinCodeHash: '3333',
        isActive: true,
      ),
      const AppUserModel(
        id: 'usr_manager',
        name: 'Karim Store Manager',
        role: UserRole.manager,
        pinCodeHash: '4444',
        isActive: true,
      ),
      const AppUserModel(
        id: 'usr_technician',
        name: 'Tarek Lead Technician',
        role: UserRole.technician,
        pinCodeHash: '5555',
        isActive: true,
      ),
    ];

    for (final user in defaultUsers) {
      await box.put(user.id, jsonEncode(user.toJson()));
    }
  }

  @override
  Future<AppUserModel?> loginWithPin(String pin) async {
    await seedDefaultUsers();
    final box = await _openAuthBox();

    for (final key in box.keys) {
      if (key.toString().startsWith('usr_')) {
        final raw = box.get(key);
        if (raw != null) {
          final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
          final user = AppUserModel.fromJson(map);
          if (user.isActive && user.pinCodeHash == pin.trim()) {
            // Save active session
            await box.put(currentSessionKey, jsonEncode(user.toJson()));
            return user;
          }
        }
      }
    }
    return null;
  }

  @override
  Future<AppUserModel?> getCurrentUser() async {
    final box = await _openAuthBox();
    final raw = box.get(currentSessionKey);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
      return AppUserModel.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    final box = await _openAuthBox();
    await box.delete(currentSessionKey);
  }

  @override
  Future<List<AppUserModel>> getAllUsers() async {
    await seedDefaultUsers();
    final box = await _openAuthBox();
    final list = <AppUserModel>[];

    for (final key in box.keys) {
      if (key.toString().startsWith('usr_')) {
        final raw = box.get(key);
        if (raw != null) {
          try {
            final map = jsonDecode(raw.toString()) as Map<String, dynamic>;
            list.add(AppUserModel.fromJson(map));
          } catch (_) {}
        }
      }
    }
    return list;
  }

  @override
  Future<void> saveUser(AppUserModel user) async {
    final box = await _openAuthBox();
    await box.put(user.id, jsonEncode(user.toJson()));
  }
}
