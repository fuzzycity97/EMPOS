// integration_test/responsive_viewport_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:empos/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Responsive Viewport Adaptability Integration Tests', () {
    testWidgets('adapts smoothly to 1080p Desktop Terminal (1920x1080)', (tester) async {
      tester.view.physicalSize = const Size(1920, 1080);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(tester.takeException(), isNull, reason: '1080p desktop layout must not overflow');
    });

    testWidgets('adapts smoothly to Tablet POS Form Factor (1024x768)', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(tester.takeException(), isNull, reason: 'Tablet landscape layout must not overflow');
    });

    testWidgets('adapts smoothly to Handheld Mobile Terminal (412x915)', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await app.main();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(tester.takeException(), isNull, reason: 'Handheld mobile terminal layout must not overflow');
    });
  });
}
