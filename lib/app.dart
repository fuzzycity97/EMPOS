import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'core/config/presentation/bloc/config_bloc.dart';
import 'core/config/presentation/bloc/config_event.dart';
import 'core/config/presentation/bloc/config_state.dart';
import 'core/config/presentation/pages/store_builder_wizard_page.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_dimensions.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';

class EmposApp extends StatelessWidget {
  final ConfigBloc? bloc;

  const EmposApp({
    super.key,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfigBloc>(
      create: (_) => (bloc ?? sl<ConfigBloc>())..add(const LoadConfigEvent()),
      child: const _EmposAppView(),
    );
  }
}

class _EmposAppView extends StatelessWidget {
  const _EmposAppView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, state) {
        if (state is ConfigLoading || state is ConfigInitial) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const _BootstrapSplashScreen(),
          );
        }

        if (state is ConfigError) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            home: const StoreBuilderWizardPage(),
          );
        }

        if (state is ConfigLoaded) {
          final blueprint = state.blueprint;
          final primaryColor = AppTheme.parseHexColor(blueprint.themeColorHex);

          return MaterialApp(
            title: '${blueprint.storeName} — Enterprise POS & ERP',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.dynamicDarkTheme(primaryColor),
            darkTheme: AppTheme.dynamicDarkTheme(primaryColor),
            themeMode: blueprint.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: MainShell(),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Splash Screen while loading Blueprint configuration
// ─────────────────────────────────────────────────────────────────────────────
class _BootstrapSplashScreen extends StatelessWidget {
  const _BootstrapSplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppDimensions.space20),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
              ),
              child: const Icon(
                LucideIcons.store,
                color: AppColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: AppDimensions.space24),
            Text(
              'EMPOS ENTERPRISE',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimaryDark,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Loading Turnkey Store Blueprint & Hardware Toggles...',
              style: TextStyle(fontSize: 13, color: AppColors.textMutedDark),
            ),
            const SizedBox(height: AppDimensions.space32),
            const SizedBox(
              width: 140,
              child: LinearProgressIndicator(
                backgroundColor: AppColors.surfaceDark,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
