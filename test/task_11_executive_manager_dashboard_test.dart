import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/features/catalog/domain/entities/product.dart';
import 'package:empos/features/manager/domain/entities/manager_profit_split_engine.dart';
import 'package:empos/features/manager/presentation/pages/executive_manager_dashboard_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 11/11: Executive Manager Live Monitoring Dashboard Suite', () {
    testWidgets('1. Live Sales Stream updates Gross Revenue & Net Profit KPIs reactively', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final salesController = StreamController<Map<String, dynamic>>.broadcast();
      final liveSalesNotifier = ValueNotifier<List<Map<String, dynamic>>>([
        {
          'invoiceId': 'INV-TEST-01',
          'dept': 'Dental Wing',
          'patient': 'Ahmed Taha',
          'amount': 1000.0,
          'time': '10:00 AM',
          'status': 'PAID',
        },
      ]);

      await tester.pumpWidget(
        MaterialApp(
          home: ExecutiveManagerDashboardPage(
            liveSalesNotifier: liveSalesNotifier,
            liveSalesStream: salesController.stream,
          ),
        ),
      );

      // Initial state: 1000.00 Gross (KPI card + list item), 600.00 Net (60%)
      expect(find.text('1000.00 EGP'), findsNWidgets(2));
      expect(find.text('600.00 EGP'), findsOneWidget);

      // Receive real-time sale event over stream
      salesController.add({
        'invoiceId': 'INV-TEST-02',
        'dept': 'In-House Pharmacy',
        'patient': 'Sara Hany',
        'amount': 2500.0,
        'time': 'Just now',
        'status': 'PAID',
      });
      await tester.pump();

      // Updated state: 3500.00 Gross, 2100.00 Net (60%)
      expect(find.text('3500.00 EGP'), findsOneWidget);
      expect(find.text('2100.00 EGP'), findsOneWidget);

      await salesController.close();
    });

    testWidgets('2. Employee debt ledger panel calculates correct net payable & advance debt', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final testPayroll = [
        const StaffPayrollEntry(
          staffId: 'stf_01',
          staffName: 'Dr. Sarah Hassan',
          baseSalary: 10000.0,
          commissions: 2000.0,
          unsettledAdvances: 1500.0,
          bonuses: 500.0,
        ),
        const StaffPayrollEntry(
          staffId: 'stf_02',
          staffName: 'Ahmed Nabil',
          baseSalary: 6000.0,
          commissions: 500.0,
          unsettledAdvances: 0.0,
          bonuses: 0.0,
        ),
      ];

      final payrollNotifier = ValueNotifier<List<StaffPayrollEntry>>(testPayroll);

      await tester.pumpWidget(
        MaterialApp(
          home: ExecutiveManagerDashboardPage(
            payrollNotifier: payrollNotifier,
          ),
        ),
      );

      // Verify KPI shows 1500.00 EGP advances across 1 employee
      expect(find.text('1500.00 EGP'), findsOneWidget);
      expect(find.text('1 Employees'), findsOneWidget);

      // Verify individual employee ledger calculations:
      // Dr. Sarah: 10000 + 2000 + 500 - 1500 = 11000.00 EGP
      expect(find.text('Net: 11000.00 EGP'), findsOneWidget);
      expect(find.text('Advance: -1500 EGP'), findsOneWidget);

      // Ahmed: 6000 + 500 = 6500.00 EGP
      expect(find.text('Net: 6500.00 EGP'), findsOneWidget);
      expect(find.text('Advance: -0 EGP'), findsOneWidget);
    });

    testWidgets('3. Settle Payroll Period records real settlement entry and clears advances', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final testPayroll = [
        const StaffPayrollEntry(
          staffId: 'stf_01',
          staffName: 'Dr. Sarah Hassan',
          baseSalary: 10000.0,
          unsettledAdvances: 2000.0,
        ),
      ];

      final payrollNotifier = ValueNotifier<List<StaffPayrollEntry>>(testPayroll);
      final settlementAuditNotifier = ValueNotifier<List<Map<String, dynamic>>>([]);
      Map<String, dynamic>? recordedSettlement;

      await tester.pumpWidget(
        MaterialApp(
          home: ExecutiveManagerDashboardPage(
            payrollNotifier: payrollNotifier,
            settlementAuditNotifier: settlementAuditNotifier,
            onRecordSettlement: (record) => recordedSettlement = record,
          ),
        ),
      );

      expect(find.text('2000.00 EGP'), findsOneWidget);
      expect(find.text('1 Employees'), findsOneWidget);

      // Tap Settle Period button
      await tester.tap(find.text('Settle Period'));
      await tester.pumpAndSettle();

      // Confirms audit record created
      expect(recordedSettlement, isNotNull);
      expect(recordedSettlement!['status'], equals('SETTLED'));
      expect(recordedSettlement!['totalAdvancesCleared'], equals(2000.0));
      expect(recordedSettlement!['totalNetPaid'], equals(8000.0));
      expect(settlementAuditNotifier.value.length, equals(1));

      // Confirms reactive KPI clearance
      expect(find.text('0.00 EGP'), findsOneWidget);
      expect(find.text('0 Employees'), findsOneWidget);
      expect(find.text('Advance: -0 EGP'), findsOneWidget);
      expect(find.text('Net: 10000.00 EGP'), findsOneWidget);
    });

    test('4. Low-stock and FEFO alerts utility accurately surfaces real catalog items and batch expiries', () {
      final testProducts = [
        const Product(
          id: 'prod_01',
          nameEn: 'Sterile Gauze Pads',
          categoryId: 'cat_consumables',
          price: 15.0,
          stock: 2,
          barcode: '111111',
          trackQty: true,
        ),
        const Product(
          id: 'prod_02',
          nameEn: 'Latex Gloves (Box of 100)',
          categoryId: 'cat_consumables',
          price: 120.0,
          stock: 0,
          barcode: '222222',
          trackQty: true,
        ),
        const Product(
          id: 'prod_03',
          nameEn: 'Standard Stethoscope',
          categoryId: 'cat_equipment',
          price: 850.0,
          stock: 15,
          barcode: '333333',
          trackQty: true,
        ),
      ];

      final testFefoBatches = [
        {
          'productName': 'Ceftriaxone 1g Vial',
          'batchNumber': 'CFT-2026-01',
          'daysUntilExpiry': -2,
          'quantity': 10,
        },
        {
          'productName': 'Amoxicillin 500mg',
          'batchNumber': 'AMX-2026-08',
          'daysUntilExpiry': 15,
          'quantity': 50,
        },
      ];

      final alerts = ExecutiveManagerDashboardPage.generateAlertsFromInventory(
        products: testProducts,
        fefoBatches: testFefoBatches,
      );

      expect(alerts.length, equals(4));

      final expiredAlert = alerts.firstWhere((a) => a['type'] == 'EXPIRED');
      expect(expiredAlert['name'], contains('Ceftriaxone 1g Vial'));
      expect(expiredAlert['severity'], equals('CRITICAL'));

      final expiringSoonAlert = alerts.firstWhere((a) => a['type'] == 'EXPIRING_SOON');
      expect(expiringSoonAlert['name'], contains('Amoxicillin 500mg'));
      expect(expiringSoonAlert['severity'], equals('HIGH'));

      final outOfStockAlert = alerts.firstWhere((a) => a['type'] == 'OUT_OF_STOCK');
      expect(outOfStockAlert['name'], equals('Latex Gloves (Box of 100)'));
      expect(outOfStockAlert['severity'], equals('CRITICAL'));

      final lowStockAlert = alerts.firstWhere((a) => a['type'] == 'LOW_STOCK');
      expect(lowStockAlert['name'], equals('Sterile Gauze Pads'));
      expect(lowStockAlert['severity'], equals('MEDIUM'));
    });
  });
}
