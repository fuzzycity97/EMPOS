import 'package:flutter/foundation.dart';
import 'totp_authenticator.dart';

enum SuperAdminAuthFailure {
  missingCredentials,
  invalidPassword,
  invalidTotpCode,
}

class SuperAdminAuthResult {
  final bool isSuccess;
  final SuperAdminAuthFailure? failure;
  final String? message;

  const SuperAdminAuthResult.success()
      : isSuccess = true,
        failure = null,
        message = null;

  const SuperAdminAuthResult.failure(this.failure, this.message)
      : isSuccess = false;
}

/// Genuinely isolated authentication service for the Super-Admin subsystem.
///
/// Completely independent from clinic staff authentication (UserRole / AuthBloc).
/// Requires both a vendor master secret credential AND an RFC 6238 TOTP 6-digit
/// authenticator token for every single login session.
class SuperAdminAuthService extends ChangeNotifier {
  static final SuperAdminAuthService _instance = SuperAdminAuthService._internal();
  factory SuperAdminAuthService() => _instance;
  static SuperAdminAuthService get instance => _instance;

  SuperAdminAuthService._internal();

  // Environment-configurable or secure vendor master defaults
  static const String _defaultMasterKey = String.fromEnvironment(
    'SUPER_ADMIN_MASTER_KEY',
    defaultValue: 'OmniAdmin#2026!',
  );

  static const String _defaultTotpSecret = String.fromEnvironment(
    'SUPER_ADMIN_TOTP_SECRET',
    defaultValue: 'JBSWY3DPEHPK3PXP', // Base32 RFC 6238 test seed
  );

  bool _isAuthenticated = false;
  String? _activeAdminId;
  String _totpSecret = _defaultTotpSecret;
  String _masterKey = _defaultMasterKey;

  bool get isAuthenticated => _isAuthenticated;
  String? get currentAdminId => _activeAdminId;
  String get totpSecret => _totpSecret;

  String get otpAuthUri => TotpAuthenticator.generateOtpAuthUri(
        accountName: _activeAdminId ?? 'superadmin',
        issuer: 'OmniSys-EMPOS',
        secretBase32: _totpSecret,
      );

  /// Authenticates a super-admin operator using two factors:
  /// 1. Vendor master password/credential
  /// 2. RFC 6238 TOTP 6-digit code
  ///
  /// Neither factor alone is sufficient; both must validate successfully.
  Future<SuperAdminAuthResult> login({
    required String adminId,
    required String password,
    required String totpCode,
    DateTime? verificationTime,
  }) async {
    final cleanId = adminId.trim();
    final cleanPass = password.trim();
    final cleanTotp = totpCode.trim();

    if (cleanId.isEmpty || cleanPass.isEmpty) {
      return const SuperAdminAuthResult.failure(
        SuperAdminAuthFailure.missingCredentials,
        'Admin ID and master password are required.',
      );
    }

    // Factor 1: Validate vendor master credential
    if (cleanPass != _masterKey) {
      return const SuperAdminAuthResult.failure(
        SuperAdminAuthFailure.invalidPassword,
        'Invalid super-admin master credential.',
      );
    }

    // Factor 2: Validate RFC 6238 TOTP code (Both factors mandatory)
    if (cleanTotp.isEmpty) {
      return const SuperAdminAuthResult.failure(
        SuperAdminAuthFailure.invalidTotpCode,
        'Second-factor TOTP 6-digit code is required.',
      );
    }

    final isTotpValid = TotpAuthenticator.verifyCode(
      _totpSecret,
      cleanTotp,
      time: verificationTime,
      window: 1, // ±30s clock drift tolerance
    );

    if (!isTotpValid) {
      return const SuperAdminAuthResult.failure(
        SuperAdminAuthFailure.invalidTotpCode,
        'Invalid or expired 6-digit 2FA authenticator code.',
      );
    }

    // Both factors verified successfully
    _isAuthenticated = true;
    _activeAdminId = cleanId;
    notifyListeners();
    return const SuperAdminAuthResult.success();
  }

  /// Terminates the current super-admin session.
  void logout() {
    _isAuthenticated = false;
    _activeAdminId = null;
    notifyListeners();
  }

  /// Test harness helper to configure custom credentials and seeds.
  @visibleForTesting
  void configureForTesting({String? masterKey, String? totpSecret}) {
    if (masterKey != null) _masterKey = masterKey;
    if (totpSecret != null) _totpSecret = totpSecret;
    _isAuthenticated = false;
    _activeAdminId = null;
  }
}
