import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/localization/app_language.dart';

void main() {
  setUp(() {
    AppLanguage.currentLocale.value = const Locale('en');
  });

  tearDown(() {
    AppLanguage.currentLocale.value = const Locale('en');
  });

  testWidgets('Language toggle switch changes locale and renders RTL in Arabic without error', (tester) async {
    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: AppLanguage.currentLocale,
        builder: (context, locale, _) {
          final isAr = locale.languageCode == 'ar';
          return MaterialApp(
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            builder: (context, child) {
              return Directionality(
                textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
                child: child ?? const SizedBox.shrink(),
              );
            },
            home: Scaffold(
              appBar: AppBar(
                title: Text(AppLanguage.tr('English Title', 'عنوان عربي')),
                actions: const [
                  LanguageToggleSwitch(),
                ],
              ),
              body: Center(
                child: Tooltip(
                  message: AppLanguage.tr('Sample Tooltip', 'تلميح توضيحي'),
                  child: Text(AppLanguage.tr('Content Body', 'محتوى الصفحة')),
                ),
              ),
            ),
          );
        },
      ),
    );

    // Verify initial English state
    expect(find.text('English Title'), findsOneWidget);
    expect(find.text('Content Body'), findsOneWidget);
    expect(AppLanguage.isEnglish, isTrue);
    expect(AppLanguage.isArabic, isFalse);
    expect(tester.takeException(), isNull);

    // Tap the language toggle switch (to switch to Arabic)
    await tester.tap(find.byType(LanguageToggleSwitch));
    await tester.pumpAndSettle();

    // Verify Arabic state without any assertion or localization exceptions
    expect(tester.takeException(), isNull);
    expect(AppLanguage.isArabic, isTrue);
    expect(AppLanguage.isEnglish, isFalse);
    expect(find.text('عنوان عربي'), findsOneWidget);
    expect(find.text('محتوى الصفحة'), findsOneWidget);

    // Verify Directionality is RTL
    final directionality = tester.widget<Directionality>(
      find.byWidgetPredicate(
        (w) => w is Directionality && w.textDirection == TextDirection.rtl,
      ).first,
    );
    expect(directionality.textDirection, TextDirection.rtl);

    // Toggle back to English
    await tester.tap(find.byType(LanguageToggleSwitch));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(AppLanguage.isEnglish, isTrue);
    expect(find.text('English Title'), findsOneWidget);
  });

  testWidgets('AppBar and ChoiceChip / RawChip widgets resolve MaterialLocalizations in Arabic without error', (tester) async {
    AppLanguage.currentLocale.value = const Locale('ar');

    await tester.pumpWidget(
      ValueListenableBuilder<Locale>(
        valueListenable: AppLanguage.currentLocale,
        builder: (context, locale, _) {
          return MaterialApp(
            locale: locale,
            supportedLocales: const [Locale('en'), Locale('ar')],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: Scaffold(
              appBar: AppBar(
                title: const Text('عيادة'),
              ),
              body: Column(
                children: [
                  ChoiceChip(
                    label: const Text('قائمة الانتظار (1)'),
                    selected: true,
                    onSelected: (_) {},
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(ChoiceChip), findsOneWidget);
    expect(find.text('قائمة الانتظار (1)'), findsOneWidget);
  });
}

