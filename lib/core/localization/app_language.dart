import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../di/injection_container.dart';

class AppLanguage {
  static const String _prefKey = 'empos_app_language';

  /// Reactive locale notifier (default: English)
  static final ValueNotifier<Locale> currentLocale = ValueNotifier<Locale>(const Locale('en'));

  static bool get isArabic => currentLocale.value.languageCode == 'ar';
  static bool get isEnglish => currentLocale.value.languageCode == 'en';
  static String get languageCode => currentLocale.value.languageCode;

  /// Bootstrap and load saved language preference
  static Future<void> init() async {
    try {
      SharedPreferences? prefs;
      if (sl.isRegistered<SharedPreferences>()) {
        prefs = sl<SharedPreferences>();
      } else {
        prefs = await SharedPreferences.getInstance();
      }
      final saved = prefs.getString(_prefKey);
      if (saved == 'ar' || saved == 'en') {
        currentLocale.value = Locale(saved!);
      }
    } catch (_) {}
  }

  /// Toggle between English and Arabic
  static Future<void> toggleLanguage() async {
    final nextCode = isArabic ? 'en' : 'ar';
    await setLanguage(nextCode);
  }

  /// Explicitly set the language
  static Future<void> setLanguage(String code) async {
    currentLocale.value = Locale(code);
    try {
      if (sl.isRegistered<SharedPreferences>()) {
        final prefs = sl<SharedPreferences>();
        await prefs.setString(_prefKey, code);
      } else {
        final prefs = await SharedPreferences.getInstance().timeout(
          const Duration(milliseconds: 50),
        );
        await prefs.setString(_prefKey, code);
      }
    } catch (_) {}
  }

  /// Quick translation helper returning `ar` if currently in Arabic, otherwise `en`
  static String tr(String en, String ar) {
    return isArabic ? ar : en;
  }
}

/// Interactive Language Toggle Switch for Top Bar and Toolbars
class LanguageToggleSwitch extends StatelessWidget {
  final bool compact;
  final Color? activeColor;

  const LanguageToggleSwitch({
    super.key,
    this.compact = false,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Locale>(
      valueListenable: AppLanguage.currentLocale,
      builder: (context, locale, _) {
        final isAr = locale.languageCode == 'ar';
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final highlightColor = activeColor ?? theme.colorScheme.primary;

        return InkWell(
          onTap: () => AppLanguage.toggleLanguage(),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white12 : Colors.black12,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // EN Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 7 : 9,
                    vertical: compact ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: !isAr ? highlightColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'EN',
                    style: TextStyle(
                      fontSize: compact ? 10.5 : 11.5,
                      fontWeight: FontWeight.bold,
                      color: !isAr ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                // AR Pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: compact ? 7 : 9,
                    vertical: compact ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: isAr ? highlightColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'عربي',
                    style: TextStyle(
                      fontSize: compact ? 10.5 : 11.5,
                      fontWeight: FontWeight.bold,
                      color: isAr ? Colors.white : (isDark ? Colors.white60 : Colors.black54),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
