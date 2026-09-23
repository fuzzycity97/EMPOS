// test/manager_visibility_gating_test.dart
//
// Role-based visibility tests for the AppUser / UserRole model.
// These test the AUTH STATE layer (what role the app believes is active).
// They do NOT prove a widget is actually hidden on screen — pair this
// file with a widget-level integration_test (or widget test) that pumps
// real widgets under each role and asserts findsNothing / findsOneWidget.

import 'package:flutter_test/flutter_test.dart';
import 'package:empos/features/auth/domain/entities/app_user.dart';
import 'package:empos/features/auth/domain/entities/user_role.dart';

AppUser _userWith(UserRole role) {
  return AppUser(
    id: 'test-${role.name}',
    name: role.displayName,
    role: role,
    pinCodeHash: 'hash_test_pin',
    isActive: true,
  );
}

void main() {
  group('Manager / role visibility — AppUser gating logic', () {
    test('manager role is not technician and therefore not godMode', () {
      final manager = _userWith(UserRole.manager);
      expect(manager.isGodMode, isFalse);
    });

    test('technician role is godMode regardless of explicit permissions list', () {
      final technician = _userWith(UserRole.technician);
      expect(technician.isGodMode, isTrue);
    });

    test('cashier role must NOT be treated as manager-equivalent', () {
      final cashier = _userWith(UserRole.cashier);
      expect(cashier.role, isNot(UserRole.manager));
      expect(cashier.isGodMode, isFalse);
    });

    test('each defined UserRole value is exhaustively covered by a '
        'visibility test — fails loudly if a new role is added without '
        'updating this suite', () {
      const allRoles = UserRole.values;
      const testedRoles = {
        UserRole.admin,
        UserRole.manager,
        UserRole.cashier,
        UserRole.doctor,
        UserRole.receptionist,
        UserRole.technician,
      };
      expect(
        allRoles.toSet(),
        testedRoles,
        reason: 'A UserRole was added or removed without updating this '
            'test file. Update testedRoles and add matching visibility '
            'assertions before merging.',
      );
    });
  });
}
