import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/subscription/subscription_audit_log.dart';
import 'package:empos/core/config/subscription/subscription_tier_controller.dart';
import 'package:empos/core/config/subscription/subscription_tier_models.dart';
import 'package:empos/core/config/super_admin_feature_guard.dart';
import 'package:empos/features/super_admin/domain/services/super_admin_auth_service.dart';
import 'package:empos/features/super_admin/domain/services/totp_authenticator.dart';
import 'package:empos/features/super_admin/presentation/widgets/super_admin_audit_trail_view.dart';
import 'package:empos/features/super_admin/presentation/widgets/super_admin_auth_gate.dart';

void main() {
  group('Task 10c Super-Admin Security - Part 1: Compile-Time Flag Isolation', () {
    test('Route generator returns null when kEnableSuperAdmin is false', () {
      // In default test execution without --dart-define=ENABLE_SUPER_ADMIN=true,
      // kEnableSuperAdmin evaluates to false, ensuring complete tree-shaking isolation.
      expect(kEnableSuperAdmin, isFalse);
      expect(SuperAdminSecurityGuard.isSuperAdminEnabled, isFalse);

      final route = SuperAdminSecurityGuard.onGenerateRoute(
        const RouteSettings(name: '/super-admin'),
      );
      expect(route, isNull, reason: 'Super-admin route must be completely unreachable without compile flag');

      final subRoute = SuperAdminSecurityGuard.onGenerateRoute(
        const RouteSettings(name: '/super-admin/subscriptions'),
      );
      expect(subRoute, isNull, reason: 'Nested super-admin route must also be unreachable');
    });
  });

  group('Task 10c Super-Admin Security - Part 2: Real RFC 6238 TOTP 2FA', () {
    const testSecret = 'JBSWY3DPEHPK3PXP'; // Base32 test secret

    test('Generates deterministic 6-digit TOTP code and validates with window tolerance', () {
      final now = DateTime.now();
      final code = TotpAuthenticator.generateCode(testSecret, time: now);

      expect(code.length, 6);
      expect(int.tryParse(code), isNotNull);

      // Exact match at generation timestamp
      expect(TotpAuthenticator.verifyCode(testSecret, code, time: now), isTrue);

      // Reject arbitrary or incorrect code
      expect(TotpAuthenticator.verifyCode(testSecret, '999999', time: now), isFalse);
      expect(TotpAuthenticator.verifyCode(testSecret, '000000', time: now), isFalse);
      expect(TotpAuthenticator.verifyCode(testSecret, '12345', time: now), isFalse);

      // Verify ±30s clock skew window tolerance
      final driftForward = now.add(const Duration(seconds: 25));
      final driftBackward = now.subtract(const Duration(seconds: 25));
      expect(TotpAuthenticator.verifyCode(testSecret, code, time: driftForward, window: 1), isTrue);
      expect(TotpAuthenticator.verifyCode(testSecret, code, time: driftBackward, window: 1), isTrue);

      // Outside window (e.g. 90 seconds ago) must fail
      final expired = now.subtract(const Duration(seconds: 95));
      expect(TotpAuthenticator.verifyCode(testSecret, code, time: expired, window: 1), isFalse);
    });

    test('SuperAdminAuthService strictly enforces dual-factor authentication', () async {
      final authService = SuperAdminAuthService.instance;
      authService.configureForTesting(
        masterKey: 'TestVendorSecret#2026',
        totpSecret: testSecret,
      );

      final now = DateTime.now();
      final validTotp = TotpAuthenticator.generateCode(testSecret, time: now);

      // Test Case 1: Password-only login attempt (empty TOTP) MUST FAIL
      final resultNoTotp = await authService.login(
        adminId: 'operator1',
        password: 'TestVendorSecret#2026',
        totpCode: '',
        verificationTime: now,
      );
      expect(resultNoTotp.isSuccess, isFalse);
      expect(resultNoTotp.failure, SuperAdminAuthFailure.invalidTotpCode);
      expect(authService.isAuthenticated, isFalse);

      // Test Case 2: Correct password + invalid TOTP code MUST FAIL
      final resultBadTotp = await authService.login(
        adminId: 'operator1',
        password: 'TestVendorSecret#2026',
        totpCode: '000000',
        verificationTime: now,
      );
      expect(resultBadTotp.isSuccess, isFalse);
      expect(resultBadTotp.failure, SuperAdminAuthFailure.invalidTotpCode);
      expect(authService.isAuthenticated, isFalse);

      // Test Case 3: Invalid password + valid TOTP code MUST FAIL
      final resultBadPass = await authService.login(
        adminId: 'operator1',
        password: 'WrongPassword123',
        totpCode: validTotp,
        verificationTime: now,
      );
      expect(resultBadPass.isSuccess, isFalse);
      expect(resultBadPass.failure, SuperAdminAuthFailure.invalidPassword);
      expect(authService.isAuthenticated, isFalse);

      // Test Case 4: BOTH factors valid MUST SUCCEED
      final resultSuccess = await authService.login(
        adminId: 'sec-admin-42',
        password: 'TestVendorSecret#2026',
        totpCode: validTotp,
        verificationTime: now,
      );
      expect(resultSuccess.isSuccess, isTrue);
      expect(authService.isAuthenticated, isTrue);
      expect(authService.currentAdminId, 'sec-admin-42');

      // Logout resets session completely
      authService.logout();
      expect(authService.isAuthenticated, isFalse);
      expect(authService.currentAdminId, isNull);
    });
  });

  group('Task 10c Super-Admin Security - Part 3: Append-Only Toggle Audit Trail', () {
    late SubscriptionTierController controller;
    final auditLog = SubscriptionAuditLog.instance;

    setUp(() {
      auditLog.clearForTesting();
      controller = SubscriptionTierController();
      controller.getOrCreateAccount(
        accountId: 'acc_audit_test',
        businessName: 'Audit Test Clinic',
        initialTier: SubscriptionPlanTier.basic,
      );
    });

    test('Audit log records tier changes, capability overrides, and resets with operator identity', () {
      expect(auditLog.count, 0);

      // 1. Change plan tier
      controller.assignTierPreset(
        'acc_audit_test',
        SubscriptionPlanTier.pro,
        adminId: 'superadmin_alice',
      );
      expect(auditLog.count, 1);
      final r1 = auditLog.records.first;
      expect(r1.accountId, 'acc_audit_test');
      expect(r1.adminId, 'superadmin_alice');
      expect(r1.action, SubscriptionAuditAction.tierChanged);
      expect(r1.targetKey, 'tier');
      expect(r1.oldValue, 'basic');
      expect(r1.newValue, 'pro');

      // 2. Set individual capability override
      controller.setCapabilityOverride(
        'acc_audit_test',
        'sw.dental_3d_modbl_polygons',
        true,
        adminId: 'superadmin_bob',
      );
      expect(auditLog.count, 2);
      final r2 = auditLog.records.first; // Reverse chronological
      expect(r2.adminId, 'superadmin_bob');
      expect(r2.action, SubscriptionAuditAction.overrideSet);
      expect(r2.targetKey, 'sw.dental_3d_modbl_polygons');
      expect(r2.newValue, 'true');

      // 3. Clear individual capability override
      controller.removeCapabilityOverride(
        'acc_audit_test',
        'sw.dental_3d_modbl_polygons',
        adminId: 'superadmin_bob',
      );
      expect(auditLog.count, 3);
      final r3 = auditLog.records.first;
      expect(r3.action, SubscriptionAuditAction.overrideCleared);
      expect(r3.targetKey, 'sw.dental_3d_modbl_polygons');
      expect(r3.newValue, 'preset_default');

      // 4. Set another override and reset all
      controller.setCapabilityOverride('acc_audit_test', 'sw.pharmacy_pos_terminal', true);
      controller.resetOverridesToPreset('acc_audit_test', adminId: 'superadmin_charlie');
      expect(auditLog.count, 5);
      final r5 = auditLog.records.first;
      expect(r5.adminId, 'superadmin_charlie');
      expect(r5.action, SubscriptionAuditAction.overridesReset);

      // Filter by account returns all 5 entries
      final accountRecords = auditLog.getRecordsForAccount('acc_audit_test');
      expect(accountRecords.length, 5);

      // Verify unmodifiable list enforcement
      expect(() => auditLog.records.add(r1), throwsUnsupportedError);
    });
  });

  group('Task 10c Super-Admin Security - Part 4: UI & Gate Integration', () {
    const testSecret = 'JBSWY3DPEHPK3PXP';

    setUp(() {
      SuperAdminAuthService.instance.configureForTesting(
        masterKey: 'OmniAdmin#2026!',
        totpSecret: testSecret,
      );
    });

    testWidgets('SuperAdminAuthGate displays 2FA gate, rejects password-only, and admits valid dual-factor', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SuperAdminAuthGate(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify gate components
      expect(find.text('SUPER-ADMIN SECURITY GATE'), findsOneWidget);
      expect(find.byKey(const ValueKey('super_admin_id_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('super_admin_password_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('super_admin_totp_input')), findsOneWidget);
      expect(find.byKey(const ValueKey('super_admin_login_button')), findsOneWidget);

      // Attempt 1: Enter valid password but NO TOTP
      await tester.enterText(find.byKey(const ValueKey('super_admin_password_input')), 'OmniAdmin#2026!');
      await tester.tap(find.byKey(const ValueKey('super_admin_login_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('super_admin_auth_error')), findsOneWidget);
      expect(find.textContaining('Second-factor TOTP 6-digit code is required'), findsOneWidget);
      expect(SuperAdminAuthService.instance.isAuthenticated, isFalse);

      // Attempt 2: Enter valid password AND valid TOTP
      final now = DateTime.now();
      final validTotp = TotpAuthenticator.generateCode(testSecret, time: now);
      await tester.enterText(find.byKey(const ValueKey('super_admin_totp_input')), validTotp);
      await tester.tap(find.byKey(const ValueKey('super_admin_login_button')));
      await tester.pumpAndSettle();

      // Gate unlocked: SuperAdminSubscriptionManagementPage is rendered
      expect(SuperAdminAuthService.instance.isAuthenticated, isTrue);
      expect(find.text('SUPER-ADMIN SECURITY GATE'), findsNothing);
      expect(find.textContaining('Super-Admin Subscription & Capability Fleet Console'), findsOneWidget);
      expect(find.byKey(const ValueKey('super_admin_logout_button')), findsOneWidget);

      // Logout restores security gate
      await tester.tap(find.byKey(const ValueKey('super_admin_logout_button')));
      await tester.pumpAndSettle();
      expect(SuperAdminAuthService.instance.isAuthenticated, isFalse);
      expect(find.text('SUPER-ADMIN SECURITY GATE'), findsOneWidget);
    });

    testWidgets('SuperAdminAuditTrailView renders recorded audit records cleanly', (tester) async {
      SubscriptionAuditLog.instance.clearForTesting();
      SubscriptionAuditLog.instance.record(
        accountId: 'acc_demo',
        adminId: 'sec_admin_root',
        action: SubscriptionAuditAction.overrideSet,
        targetKey: 'sw.rule_a_telemetry',
        oldValue: 'false',
        newValue: 'true',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperAdminAuditTrailView(accountIdFilter: 'acc_demo'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Capability Override Set'), findsOneWidget);
      expect(find.text('by sec_admin_root'), findsOneWidget);
      expect(find.text('sw.rule_a_telemetry'), findsOneWidget);
    });
  });
}
