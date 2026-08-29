import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class PinLockScreen extends StatelessWidget {
  final ValueNotifier<String> pinNotifier;

  const PinLockScreen._({
    super.key,
    required this.pinNotifier,
  });

  factory PinLockScreen({Key? key}) {
    return PinLockScreen._(
      key: key,
      pinNotifier: ValueNotifier<String>(''),
    );
  }

  void _onDigitPressed(BuildContext context, String digit) {
    if (pinNotifier.value.length < 4) {
      pinNotifier.value = pinNotifier.value + digit;
      if (pinNotifier.value.length == 4) {
        final pin = pinNotifier.value;
        context.read<AuthBloc>().add(LoginRequested(pin));
        // Reset local pin buffer after small delay
        Future.delayed(const Duration(milliseconds: 300), () {
          pinNotifier.value = '';
        });
      }
    }
  }

  void _onBackspacePressed() {
    if (pinNotifier.value.isNotEmpty) {
      pinNotifier.value = pinNotifier.value.substring(0, pinNotifier.value.length - 1);
    }
  }

  void _onClearPressed() {
    pinNotifier.value = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.4),
            radius: 1.2,
            colors: [
              AppColors.primary.withValues(alpha: 0.12),
              AppColors.backgroundDark,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Container(
                margin: const EdgeInsets.all(AppDimensions.space24),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.space32,
                  vertical: AppDimensions.space32,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  border: Border.all(color: AppColors.borderDark),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── LOGO & LOCK ICON ────────────────────────────────────
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.secondary],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        LucideIcons.lock,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.space16),

                    // ── TITLE & SUBTITLE ────────────────────────────────────
                    Text(
                      'EMPOS™ Station Security',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Enter your 4-digit security PIN to unlock station',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // ── ERROR BANNER ────────────────────────────────────────
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        if (state is AuthUnauthenticated && state.errorMessage != null) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: AppDimensions.space16),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(LucideIcons.shieldAlert, color: AppColors.danger, size: 16),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(
                                      color: AppColors.danger,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        if (state is AuthLoading) {
                          return const Padding(
                            padding: EdgeInsets.only(bottom: AppDimensions.space16),
                            child: SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // ── PIN DOTS INDICATOR ──────────────────────────────────
                    ValueListenableBuilder<String>(
                      valueListenable: pinNotifier,
                      builder: (context, currentPin, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(4, (index) {
                            final isFilled = index < currentPin.length;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              margin: const EdgeInsets.symmetric(horizontal: 10),
                              width: isFilled ? 18 : 14,
                              height: isFilled ? 18 : 14,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isFilled ? AppColors.primary : Colors.transparent,
                                border: Border.all(
                                  color: isFilled ? AppColors.primary : AppColors.borderDark,
                                  width: 2,
                                ),
                                boxShadow: isFilled
                                    ? [
                                        BoxShadow(
                                          color: AppColors.primary.withValues(alpha: 0.6),
                                          blurRadius: 10,
                                          spreadRadius: 1,
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // ── NUMERIC KEYPAD ──────────────────────────────────────
                    Column(
                      children: [
                        _buildKeypadRow(context, ['1', '2', '3']),
                        const SizedBox(height: 12),
                        _buildKeypadRow(context, ['4', '5', '6']),
                        const SizedBox(height: 12),
                        _buildKeypadRow(context, ['7', '8', '9']),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildKeypadButton(
                              context,
                              label: 'C',
                              isAction: true,
                              icon: LucideIcons.rotateCcw,
                              onTap: _onClearPressed,
                            ),
                            const SizedBox(width: 14),
                            _buildKeypadButton(
                              context,
                              label: '0',
                              onTap: () => _onDigitPressed(context, '0'),
                            ),
                            const SizedBox(width: 14),
                            _buildKeypadButton(
                              context,
                              label: 'DEL',
                              isAction: true,
                              icon: LucideIcons.delete,
                              onTap: _onBackspacePressed,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppDimensions.space24),

                    // ── QUICK TEST ROLE SWITCH CHIPS ────────────────────────
                    const Text(
                      'QUICK TEST DEMO ACCOUNTS:',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondaryDark,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      alignment: WrapAlignment.center,
                      children: [
                        _buildDemoChip(context, 'Admin (0000)', '0000', AppColors.primary),
                        _buildDemoChip(context, 'Doctor (1111)', '1111', AppColors.success),
                        _buildDemoChip(context, 'Cashier (2222)', '2222', AppColors.warning),
                        _buildDemoChip(context, 'Reception (3333)', '3333', AppColors.info),
                        _buildDemoChip(context, 'Manager (4444)', '4444', AppColors.secondary),
                        _buildDemoChip(context, 'Tech (5555)', '5555', AppColors.emerald),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(BuildContext context, List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < digits.length; i++) ...[
          if (i > 0) const SizedBox(width: 14),
          _buildKeypadButton(
            context,
            label: digits[i],
            onTap: () => _onDigitPressed(context, digits[i]),
          ),
        ],
      ],
    );
  }

  Widget _buildKeypadButton(
    BuildContext context, {
    required String label,
    IconData? icon,
    bool isAction = false,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isAction ? AppColors.surfaceElevatedDark : AppColors.surfaceElevatedDark.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        splashColor: AppColors.primary.withValues(alpha: 0.2),
        highlightColor: AppColors.primary.withValues(alpha: 0.1),
        child: Container(
          width: 72,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(
              color: isAction ? AppColors.borderDark : AppColors.borderDark.withValues(alpha: 0.5),
            ),
          ),
          alignment: Alignment.center,
          child: icon != null
              ? Icon(icon, color: AppColors.textSecondaryDark, size: 20)
              : Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildDemoChip(BuildContext context, String title, String pin, Color color) {
    return InkWell(
      onTap: () {
        pinNotifier.value = pin;
        context.read<AuthBloc>().add(LoginRequested(pin));
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
