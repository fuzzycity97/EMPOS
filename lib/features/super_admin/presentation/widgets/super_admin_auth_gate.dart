import '../../domain/entities/super_admin_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/services/super_admin_auth_service.dart';
import '../pages/super_admin_subscription_management_page.dart';

/// Authentication Gate wrapping all Super-Admin operations.
///
/// Enforces dual-factor authentication (Password + TOTP code) before rendering
/// any super-admin console interface or capabilities.
class SuperAdminAuthGate extends StatefulWidget {
  const SuperAdminAuthGate({super.key});

  @override
  State<SuperAdminAuthGate> createState() => _SuperAdminAuthGateState();
}

class _SuperAdminAuthGateState extends State<SuperAdminAuthGate> {
  final _adminIdController = TextEditingController(text: 'superadmin');
  final _passwordController = TextEditingController();
  final _totpController = TextEditingController();

  final _authService = SuperAdminAuthService.instance;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _adminIdController.dispose();
    _passwordController.dispose();
    _totpController.dispose();
    super.dispose();
  }

  Future<void> _attemptLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _authService.login(
      adminId: _adminIdController.text,
      password: _passwordController.text,
      totpCode: _totpController.text,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (!result.isSuccess) {
          _errorMessage = result.message ?? 'Authentication failed.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _authService,
      builder: (context, _) {
        if (_authService.isAuthenticated) {
          return SuperAdminSubscriptionManagementPage(
            session: SuperAdminSession(
              adminId: _authService.currentAdminId ?? 'superadmin',
              vendorOrganization: 'OmniSys Global Cloud Mesh',
              role: SuperAdminRole.vendorOperator,
              sessionToken: 'sec_admin_session_token',
              authenticatedAt: DateTime.now(),
              isCryptographicallyVerified: true,
            ),
            adminId: _authService.currentAdminId ?? 'superadmin',
            onLogout: () => _authService.logout(),
          );
        }

        return _buildLoginView();
      },
    );
  }

  Widget _buildLoginView() {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Container(
            width: 460,
            padding: const EdgeInsets.all(AppDimensions.space32),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
              border: Border.all(color: AppColors.borderDark, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      LucideIcons.shieldCheck,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space20),
                Text(
                  'SUPER-ADMIN SECURITY GATE',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimaryDark,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Strict dual-factor access boundary. Password and 6-digit TOTP authenticator token are both required.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.textMutedDark,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                if (_errorMessage != null) ...[
                  Container(
                    key: const ValueKey('super_admin_auth_error'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.space12,
                      vertical: AppDimensions.space8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.shieldAlert, size: 16, color: AppColors.error),
                        const SizedBox(width: AppDimensions.space8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.space16),
                ],

                // Admin Identifier Field
                Text(
                  'OPERATOR IDENTITY',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMutedDark,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  key: const ValueKey('super_admin_id_input'),
                  controller: _adminIdController,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimaryDark),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.user, size: 16, color: AppColors.textMutedDark),
                    hintText: 'Enter super-admin username',
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // Master Password Field
                Text(
                  'MASTER VENDOR CREDENTIAL',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMutedDark,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  key: const ValueKey('super_admin_password_input'),
                  controller: _passwordController,
                  obscureText: true,
                  style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimaryDark),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.keyRound, size: 16, color: AppColors.textMutedDark),
                    hintText: 'Enter vendor secret password',
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // 2FA TOTP Code Field
                Text(
                  'AUTHENTICATOR CODE (RFC 6238 TOTP)',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMutedDark,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  key: const ValueKey('super_admin_totp_input'),
                  controller: _totpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 4,
                    color: AppColors.primary,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.clock, size: 16, color: AppColors.textMutedDark),
                    hintText: '000000',
                    counterText: '',
                    filled: true,
                    fillColor: AppColors.surfaceDark,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      borderSide: const BorderSide(color: AppColors.borderDark),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.space24),

                // Submit Button
                ElevatedButton(
                  key: const ValueKey('super_admin_login_button'),
                  onPressed: _isLoading ? null : _attemptLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Verify 2FA & Enter Console',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(height: AppDimensions.space16),
                Center(
                  child: Text(
                    'Protected by Compile-Flag Isolation & Time-based OTP',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: AppColors.textMutedDark.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
