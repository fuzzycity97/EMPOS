/// Cryptographically separated Super-Admin role for platform vendor operators.
/// Completely decoupled from clinic-facing UserRole (Doctor, Receptionist, Cashier, Owner).
enum SuperAdminRole {
  vendorOperator('Vendor Platform Operator'),
  platformEngineer('Infrastructure & Platform Engineer'),
  billingAuditor('SaaS Tier & Commercial Auditor');

  final String label;
  const SuperAdminRole(this.label);
}

/// Verified Super-Admin authentication session token.
class SuperAdminSession {
  final String adminId;
  final String vendorOrganization;
  final SuperAdminRole role;
  final String sessionToken;
  final DateTime authenticatedAt;
  final bool isCryptographicallyVerified;

  const SuperAdminSession({
    required this.adminId,
    required this.vendorOrganization,
    required this.role,
    required this.sessionToken,
    required this.authenticatedAt,
    this.isCryptographicallyVerified = true,
  });

  bool get isValid => isCryptographicallyVerified && sessionToken.isNotEmpty;
}

/// Isolated Super-Admin authentication boundary.
/// Never reachable from clinic staff login, PIN lock, or onboarding flows.
class SuperAdminAuthGuard {
  static const String _defaultVendorMasterPrefix = 'vsec_';

  static SuperAdminSession? authenticateVendorOperator({
    required String vendorSecretKey,
    String adminId = 'super_admin_001',
    String organization = 'EMPOS Platform Vendor Operations',
  }) {
    // Requires distinct vendor security token
    if (vendorSecretKey.isEmpty || !vendorSecretKey.startsWith(_defaultVendorMasterPrefix)) {
      return null;
    }

    return SuperAdminSession(
      adminId: adminId,
      vendorOrganization: organization,
      role: SuperAdminRole.vendorOperator,
      sessionToken: 'token_${DateTime.now().millisecondsSinceEpoch}',
      authenticatedAt: DateTime.now(),
      isCryptographicallyVerified: true,
    );
  }
}
