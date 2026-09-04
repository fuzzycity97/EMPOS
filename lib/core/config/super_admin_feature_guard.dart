import 'package:flutter/material.dart';
import '../../features/super_admin/presentation/widgets/super_admin_auth_gate.dart';

/// Compile-time constant gating the Super-Admin subsystem.
///
/// Passed at compile time via: `--dart-define=ENABLE_SUPER_ADMIN=true`.
/// In standard clinic-facing builds, this evaluates to `false` at compile time,
/// allowing the Dart AOT / tree-shaking compiler to strip super-admin pages,
/// widgets, and auth logic entirely from the final executable / APK.
const bool kEnableSuperAdmin = bool.fromEnvironment(
  'ENABLE_SUPER_ADMIN',
  defaultValue: false,
);

class SuperAdminSecurityGuard {
  SuperAdminSecurityGuard._();

  static const String superAdminRoutePath = '/super-admin';
  static const String subscriptionsRoutePath = '/super-admin/subscriptions';

  /// Returns whether super-admin features were compiled into this binary.
  static bool get isSuperAdminEnabled => kEnableSuperAdmin;

  /// Generates the super-admin route ONLY if enabled at compile time.
  ///
  /// When [kEnableSuperAdmin] is false, dead code elimination eliminates the
  /// target screen and route logic entirely.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    if (kEnableSuperAdmin) {
      if (settings.name == superAdminRoutePath ||
          settings.name == subscriptionsRoutePath) {
        return MaterialPageRoute(
          builder: (context) => const SuperAdminAuthGate(),
          settings: settings,
        );
      }
    }
    return null;
  }
}
