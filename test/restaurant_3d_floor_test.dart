import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/theme/app_theme.dart';
import 'package:empos/core/localization/app_language.dart';
import 'package:empos/features/pos/presentation/widgets/restaurant_table_map_widget.dart';

void main() {
  setUp(() {
    AppLanguage.currentLocale.value = const Locale('en');
  });

  Widget buildTestApp(Widget child) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: SizedBox(
          width: 1200,
          height: 800,
          child: child,
        ),
      ),
    );
  }

  group('Restaurant 3D Floor Plan & Table Management Tests', () {
    testWidgets('Renders 2D floor plan by default with sections and tables', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        buildTestApp(RestaurantTableMapWidget()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Restaurant Visual Floor Plan'), findsOneWidget);
      expect(find.text('2D Layout'), findsOneWidget);
      expect(find.text('3D Dining Hall'), findsOneWidget);
      expect(find.text('Main Dining'), findsOneWidget);
      expect(find.text('+ Add Table'), findsOneWidget);

      expect(find.text('Table 1'), findsOneWidget);
      expect(find.text('Table 2'), findsOneWidget);
      expect(find.text('Booth 5'), findsOneWidget);
    });

    testWidgets('Switches to 3D Dining Hall mode and displays 3D Isometric View', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final viewNotifier = ValueNotifier<int>(0);

      await tester.pumpWidget(
        buildTestApp(
          RestaurantTableMapWidget(
            viewModeNotifier: viewNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 3D Dining Hall
      await tester.tap(find.text('3D Dining Hall'));
      await tester.pumpAndSettle();

      expect(viewNotifier.value, equals(1));
      // 3D navigation guide is visible
      expect(find.text('Drag to rotate 3D Isometric View • Drag tables to rearrange layout'), findsOneWidget);
      // Tables are rendered on the 3D floor
      expect(find.text('Table 1'), findsOneWidget);
      expect(find.text('Table 2'), findsOneWidget);
    });

    testWidgets('Restaurant manager can add a new table to the 3D floor with custom shape and capacity', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final tablesNotifier = ValueNotifier<List<RestaurantTable>>(
        List<RestaurantTable>.from(RestaurantTableMapWidget.defaultTables),
      );

      await tester.pumpWidget(
        buildTestApp(
          RestaurantTableMapWidget(
            tablesNotifier: tablesNotifier,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final initialCount = tablesNotifier.value.length;

      // Tap "+ Add Table"
      await tester.tap(find.text('+ Add Table'));
      await tester.pumpAndSettle();

      // Verify modal dialog appeared
      expect(find.text('Add New Table to 3D Floor'), findsOneWidget);
      expect(find.text('ROUND'), findsOneWidget);
      expect(find.text('BOOTH'), findsOneWidget);

      // Select BOOTH shape
      await tester.tap(find.text('BOOTH'));
      await tester.pumpAndSettle();

      // Submit dialog
      await tester.tap(find.widgetWithText(ElevatedButton, 'Add Table'));
      await tester.pumpAndSettle();

      // Verify new table was added
      expect(tablesNotifier.value.length, equals(initialCount + 1));
      expect(tablesNotifier.value.last.shape, equals(TableShape.booth));
    });

    testWidgets('Tapping table on 3D floor triggers onTableSelected callback', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      RestaurantTable? tappedTable;

      await tester.pumpWidget(
        buildTestApp(
          RestaurantTableMapWidget(
            viewModeNotifier: ValueNotifier<int>(1),
            onTableSelected: (table) => tappedTable = table,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Table 1 in 3D
      await tester.tap(find.text('Table 1'));
      await tester.pumpAndSettle();

      expect(tappedTable, isNotNull);
      expect(tappedTable!.label, equals('Table 1'));
    });

    testWidgets('Arabic localization translates table manager without text leakage', (tester) async {
      AppLanguage.currentLocale.value = const Locale('ar');
      await tester.binding.setSurfaceSize(const Size(1280, 900));
      addTearDown(() {
        AppLanguage.currentLocale.value = const Locale('en');
        tester.binding.setSurfaceSize(null);
      });

      await tester.pumpWidget(
        buildTestApp(
          RestaurantTableMapWidget(
            viewModeNotifier: ValueNotifier<int>(1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('صالة الطعام 3D'), findsOneWidget);
      expect(find.text('+ إضافة طاولة'), findsOneWidget);
      expect(find.text('اسحب لتدوير المنظور ثلاثي الأبعاد • اسحب الطاولات لإعادة الترتيب'), findsOneWidget);
    });
  });
}
