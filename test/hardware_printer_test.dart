import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/hardware/data/repositories/printer_repository_impl.dart';
import 'package:empos/core/hardware/domain/entities/printer_device.dart';
import 'package:empos/core/hardware/domain/repositories/printer_repository.dart';
import 'package:empos/core/hardware/presentation/widgets/hardware_diagnostics_dialog.dart';

class MockPrinterRepository extends Mock implements PrinterRepository {}

void main() {
  group('Printer Domain & Data Layer Tests', () {
    late PrinterRepositoryImpl repo;

    setUp(() {
      repo = PrinterRepositoryImpl();
    });

    tearDown(() async {
      await repo.disconnectPrinter();
    });

    test('PrinterDevice equality and copyWith', () {
      const dev1 = PrinterDevice(
        id: 'p1',
        name: 'Thermal 80mm',
        ipAddress: '192.168.1.100',
        port: 9100,
        isConnected: false,
      );

      final dev2 = dev1.copyWith(isConnected: true);
      expect(dev2.isConnected, isTrue);
      expect(dev2.ipAddress, '192.168.1.100');
      expect(dev1 == dev2, isFalse);
    });

    test('buildTestReceiptBytes contains standard ESC/POS header, text, and cut command', () {
      final bytes = repo.buildTestReceiptBytes();

      // ESC @ (0x1B, 0x40): Initialize
      expect(bytes.sublist(0, 2), [0x1B, 0x40]);

      // Contains EMPOS POS header text
      final textContent = utf8.decode(bytes, allowMalformed: true);
      expect(textContent.contains('EMPOS™ POS'), isTrue);
      expect(textContent.contains('HARDWARE DIAGNOSTICS TEST'), isTrue);
      expect(textContent.contains('TCP Port 9100'), isTrue);

      // Ends with Full Cut: GS V A 16 (0x1D, 0x56, 0x41, 0x10)
      final len = bytes.length;
      expect(bytes.sublist(len - 4, len), [0x1D, 0x56, 0x41, 0x10]);
    });

    test('printReceipt throws exception if printer is not connected', () async {
      expect(
        () => repo.printReceipt([0x1B, 0x40]),
        throwsA(isA<Exception>()),
      );
    });

    test('connectPrinter fails gracefully when host is unreachable', () async {
      // Connect to non-existent local port with immediate fail
      final result = await repo.connectPrinter('127.0.0.1', port: 59999);
      expect(result, isFalse);
      expect(repo.isConnected, isFalse);
      expect(repo.currentDevice?.isConnected, isFalse);
    });
  });

  group('HardwareDiagnosticsDialog Widget Tests', () {
    late MockPrinterRepository mockPrinterRepo;

    setUp(() {
      mockPrinterRepo = MockPrinterRepository();
      when(() => mockPrinterRepo.currentDevice).thenReturn(
        const PrinterDevice(
          id: 'escpos_192.168.1.200',
          name: 'ESC/POS Thermal Printer (192.168.1.200)',
          ipAddress: '192.168.1.200',
          port: 9100,
          isConnected: true,
        ),
      );
      when(() => mockPrinterRepo.isConnected).thenReturn(true);
      when(() => mockPrinterRepo.buildTestReceiptBytes()).thenReturn([0x1B, 0x40, 0x1D, 0x56, 0x41, 0x10]);
      when(() => mockPrinterRepo.printReceipt(any())).thenAnswer((_) async {});
      when(() => mockPrinterRepo.kickCashDrawer()).thenAnswer((_) async {});
    });

    testWidgets('Renders all diagnostic sections, inputs, and buttons', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HardwareDiagnosticsDialog(customRepo: mockPrinterRepo),
          ),
        ),
      );

      expect(find.text('Hardware & Peripherals Diagnostics'), findsOneWidget);
      expect(find.text('1. Barcode & QR Wedge Scanner Test'), findsOneWidget);
      expect(find.text('2. ESC/POS LAN Thermal Printer (TCP 9100)'), findsOneWidget);
      expect(find.text('3. Diagnostics Console Stream'), findsOneWidget);
      expect(find.text('Print Test Page (ESC/POS)'), findsOneWidget);
      expect(find.text('Kick Cash Drawer (RJ11)'), findsOneWidget);
      expect(find.text('Printer Online (Port 9100)'), findsOneWidget);
    });

    testWidgets('Entering barcode wedge input captures and displays barcode history', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HardwareDiagnosticsDialog(customRepo: mockPrinterRepo),
          ),
        ),
      );

      final barcodeField = find.byType(TextField).first;
      await tester.enterText(barcodeField, '6221234567890');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.textContaining('6221234567890'), findsWidgets);
    });

    testWidgets('Clicking Print Test Page invokes printReceipt with test bytes', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HardwareDiagnosticsDialog(customRepo: mockPrinterRepo),
          ),
        ),
      );

      await tester.tap(find.text('Print Test Page (ESC/POS)'));
      await tester.pump();

      verify(() => mockPrinterRepo.buildTestReceiptBytes()).called(1);
      verify(() => mockPrinterRepo.printReceipt(any())).called(1);
      expect(find.textContaining('SUCCESS: Test page sent to printer.'), findsOneWidget);
    });

    testWidgets('Clicking Kick Cash Drawer invokes kickCashDrawer', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HardwareDiagnosticsDialog(customRepo: mockPrinterRepo),
          ),
        ),
      );

      await tester.tap(find.text('Kick Cash Drawer (RJ11)'));
      await tester.pump();

      verify(() => mockPrinterRepo.kickCashDrawer()).called(1);
      expect(find.textContaining('SUCCESS: Cash drawer kick command dispatched.'), findsOneWidget);
    });
  });
}
