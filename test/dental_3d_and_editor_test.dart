import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/features/clinic/domain/entities/tooth_chart_entry.dart';
import 'package:empos/features/clinic/domain/entities/clinic_visit.dart';
import 'package:empos/features/clinic/presentation/widgets/dental_tooth_3d_canvas_widget.dart';
import 'package:empos/features/clinic/presentation/widgets/dental_tooth_matrix_widget.dart';
import 'package:empos/features/clinic/presentation/widgets/tooth_editor_sheet.dart';
import 'package:empos/features/clinic/presentation/widgets/tooth_glb_mesh.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('3D Dental Odontogram & Tap-to-Edit Editor Tests', () {
    setUpAll(() async {
      await ToothGlbMeshLibrary.preloadAll();
    });

    test('ToothGlbMeshLibrary loads all four category GLB meshes', () {
      expect(ToothGlbMeshLibrary.isReady, isTrue);
      for (final category in ToothCategory.values) {
        final mesh = ToothGlbMeshLibrary.meshForSync(category);
        expect(mesh.vertices, isNotEmpty);
        expect(mesh.indices.length, greaterThanOrEqualTo(3));
        expect(mesh.maxRadius, greaterThan(0));
      }
    });

    testWidgets('DentalToothMatrixWidget renders 3D View by default with camera presets', (tester) async {
      final defaultTeeth = List.generate(
        32,
        (i) => ToothChartEntry(toothNumber: i + 1, toothCode: (i + 1).toString()),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DentalToothMatrixWidget(
              toothChart: defaultTeeth,
              isPediatric: false,
              doctorName: 'Dr. Tarek',
              onToothUpdated: null,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header and Dentition Badge
      expect(find.text('Adult Odontogram (Permanent 32 Teeth)'), findsOneWidget);
      expect(find.text('Adult (12y+)'), findsOneWidget);
      expect(find.text('3D View'), findsOneWidget);
      expect(find.text('2D Grid'), findsOneWidget);

      // Verify 3D Canvas and Camera Preset Buttons
      expect(find.byType(DentalTooth3dCanvasWidget), findsOneWidget);
      expect(find.text('Front 3D'), findsOneWidget);
      expect(find.text('Upper Arch'), findsOneWidget);
      expect(find.text('Lower Arch'), findsOneWidget);
      expect(find.text('Right Sagittal'), findsOneWidget);
      expect(find.text('Left Sagittal'), findsOneWidget);

      // Tap Upper Arch preset
      await tester.tap(find.text('Upper Arch'));
      await tester.pumpAndSettle();

      // Tap 2D Grid switch
      await tester.tap(find.text('2D Grid'));
      await tester.pumpAndSettle();

      // 2D grid should now be visible
      expect(find.textContaining('Upper Maxillary Arch'), findsOneWidget);
      expect(find.textContaining('Lower Mandibular Arch'), findsOneWidget);
      expect(find.text('FDI 18'), findsOneWidget);
      expect(find.text('FDI 11'), findsOneWidget);
      expect(find.text('FDI 21'), findsOneWidget);
    });

    testWidgets('ToothEditorSheet renders all 12 statuses, special case types, and saves free-text notes with history', (tester) async {
      const initialEntry = ToothChartEntry(
        toothNumber: 3,
        toothCode: '3',
        state: ToothState.decayed,
        pocketDepthMm: 2,
        notes: 'Initial small lesion',
      );

      ToothChartEntry? savedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToothEditorSheet(
              entry: initialEntry,
              isPediatric: false,
              doctorName: 'Dr. Tarek',
              onSave: (updated) => savedResult = updated,
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Header metadata
      expect(find.text('FDI 16'), findsOneWidget);
      expect(find.text('Univ #3'), findsOneWidget);
      expect(find.text('Molar'), findsOneWidget);
      expect(find.text('Upper Right 1st Molar (FDI 16)'), findsOneWidget);

      // 2. Verify all 12 status options
      expect(find.text('Healthy'), findsOneWidget);
      expect(find.text('Decayed / Cavity'), findsOneWidget);
      expect(find.text('Filled'), findsOneWidget);
      expect(find.text('Crowned'), findsOneWidget);
      expect(find.text('Root Canal Treated'), findsOneWidget);
      expect(find.text('Missing'), findsOneWidget);
      expect(find.text('Extracted'), findsOneWidget);
      expect(find.text('Impacted'), findsOneWidget);
      expect(find.text('Bridge'), findsOneWidget);
      expect(find.text('Implant'), findsOneWidget);
      expect(find.text('Fractured'), findsOneWidget);
      expect(find.text('Special Case'), findsOneWidget);

      // 3. Select 'Special Case'
      await tester.ensureVisible(find.text('Special Case'));
      await tester.tap(find.text('Special Case'));
      await tester.pumpAndSettle();

      // Special case chips should now be visible
      expect(find.text('SPECIAL CASE ANOMALY TYPE'), findsOneWidget);
      expect(find.text('Supernumerary / Double Tooth'), findsOneWidget);
      expect(find.text('Congenitally Missing'), findsOneWidget);
      expect(find.text('Retained Primary Tooth'), findsOneWidget);
      expect(find.text('Fused / Geminated'), findsOneWidget);
      expect(find.text('Custom / Other'), findsOneWidget);

      // Select 'Supernumerary / Double Tooth'
      await tester.ensureVisible(find.text('Supernumerary / Double Tooth'));
      await tester.tap(find.text('Supernumerary / Double Tooth'));
      await tester.pumpAndSettle();

      // 4. Select Periodontal Pocket Depth '5'
      await tester.ensureVisible(find.text('5'));
      await tester.tap(find.text('5'));
      await tester.pumpAndSettle();

      // 5. Select Affected Surfaces (Mesial, Occlusal)
      await tester.ensureVisible(find.text('Mesial (M)'));
      await tester.tap(find.text('Mesial (M)'));
      await tester.ensureVisible(find.text('Occlusal (O)'));
      await tester.tap(find.text('Occlusal (O)'));
      await tester.pumpAndSettle();

      // 6. Enter Free-Text Description
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(
        find.byType(TextField),
        'Supernumerary microdont erupted distobuccal to #16 with deep 5mm periodontal pocket.',
      );
      await tester.pumpAndSettle();

      // 7. Save Tooth Record
      await tester.ensureVisible(find.text('Save Tooth Record'));
      await tester.tap(find.text('Save Tooth Record'));
      await tester.pumpAndSettle();

      // Verify saved data structure
      expect(savedResult, isNotNull);
      expect(savedResult!.state, ToothState.specialCase);
      expect(savedResult!.specialCaseType, SpecialCaseType.supernumerary);
      expect(savedResult!.pocketDepthMm, 5);
      expect(savedResult!.surfaceNotation.contains('M'), isTrue);
      expect(savedResult!.surfaceNotation.contains('O'), isTrue);
      expect(savedResult!.notes, 'Supernumerary microdont erupted distobuccal to #16 with deep 5mm periodontal pocket.');

      // Verify append-only history log
      expect(savedResult!.history.length, 1);
      expect(savedResult!.history.first.state, ToothState.specialCase);
      expect(savedResult!.history.first.specialCaseType, SpecialCaseType.supernumerary);
      expect(savedResult!.history.first.doctorName, 'Dr. Tarek');
    });

    testWidgets('Tooth status selection maintains active state and does not revert to Healthy', (tester) async {
      ToothChartEntry? savedResult;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToothEditorSheet(
              entry: const ToothChartEntry(
                toothNumber: 14,
                toothCode: '14',
                state: ToothState.healthy,
              ),
              isPediatric: false,
              doctorName: 'Dr. Sarah',
              onSave: (updated) => savedResult = updated,
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Decayed / Cavity'
      await tester.ensureVisible(find.text('Decayed / Cavity'));
      await tester.tap(find.text('Decayed / Cavity'));
      await tester.pumpAndSettle();

      // Verify that 'Decayed / Cavity' is highlighted as selected (white text & bold) and 'Healthy' is unselected
      final decayedText = tester.widget<Text>(find.text('Decayed / Cavity'));
      expect(decayedText.style?.color, Colors.white);
      expect(decayedText.style?.fontWeight, FontWeight.bold);

      final healthyText = tester.widget<Text>(find.text('Healthy'));
      expect(healthyText.style?.fontWeight, FontWeight.normal);

      // Trigger a keyboard/text event or pump to ensure rebuild does not reset state to healthy
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'Class II mesial caries');
      await tester.pumpAndSettle();

      final decayedTextAfterInput = tester.widget<Text>(find.text('Decayed / Cavity'));
      expect(decayedTextAfterInput.style?.color, Colors.white);
      expect(decayedTextAfterInput.style?.fontWeight, FontWeight.bold);

      // Save and verify result
      await tester.ensureVisible(find.text('Save Tooth Record'));
      await tester.tap(find.text('Save Tooth Record'));
      await tester.pumpAndSettle();

      expect(savedResult, isNotNull);
      expect(savedResult!.state, ToothState.decayed);
    });

    test('Doctor station financial settlement calculation accurately segregates paid, unpaid, and insurance', () {
      final visits = [
        // Visit 1: Self-pay (100% copay), paid
        ClinicVisit(
          id: 'v1',
          patientId: 'p1',
          patientName: 'John',
          doctorName: 'Dr. A',
          queueNumber: 1,
          chiefComplaint: 'Checkup',
          checkInTime: DateTime.now(),
          totalFee: 500.0,
          patientCopay: 500.0,
          insurancePaid: 0.0,
          isPaid: true,
        ),
        // Visit 2: Insured (20% copay, 80% insurance), paid copay
        ClinicVisit(
          id: 'v2',
          patientId: 'p1',
          patientName: 'John',
          doctorName: 'Dr. A',
          queueNumber: 2,
          chiefComplaint: 'Extraction',
          checkInTime: DateTime.now(),
          totalFee: 1000.0,
          patientCopay: 200.0,
          insurancePaid: 800.0,
          isPaid: true,
        ),
        // Visit 3: Insured (20% copay, 80% insurance), UNPAID copay
        ClinicVisit(
          id: 'v3',
          patientId: 'p1',
          patientName: 'John',
          doctorName: 'Dr. A',
          queueNumber: 3,
          chiefComplaint: 'Crown',
          checkInTime: DateTime.now(),
          totalFee: 2000.0,
          patientCopay: 400.0,
          insurancePaid: 1600.0,
          isPaid: false,
        ),
      ];

      double totalPaid = 0.0;
      double totalPending = 0.0;
      for (final v in visits) {
        if (v.isPaid || v.totalFee <= 0.001) {
          totalPaid += v.totalFee;
        } else {
          totalPaid += v.insurancePaid;
          totalPending += v.patientCopay;
        }
      }

      // Total billed: 500 + 1000 + 2000 = 3500
      // v1 settled = 500
      // v2 settled = 1000 (200 copay paid + 800 insurance)
      // v3 settled = 1600 (insurance portion settled), pending due = 400 (unpaid patient copay)
      // totalPaid should be 500 + 1000 + 1600 = 3100
      // totalPending should be 400
      expect(totalPaid, 3100.0);
      expect(totalPending, 400.0);
    });

    test('FDI and Universal numbering cross-mapping calculates accurately', () {
      // Adult Upper Right 1st Molar: Univ 3 -> FDI 16
      const tooth3 = ToothChartEntry(toothNumber: 3, toothCode: '3');
      expect(tooth3.fdiNumber, '16');
      expect(tooth3.plainLanguagePosition, 'Upper Right 1st Molar (FDI 16)');
      expect(tooth3.category, ToothCategory.molar);

      // Adult Upper Left Central Incisor: Univ 9 -> FDI 21
      const tooth9 = ToothChartEntry(toothNumber: 9, toothCode: '9');
      expect(tooth9.fdiNumber, '21');
      expect(tooth9.plainLanguagePosition, 'Upper Left Central Incisor (FDI 21)');
      expect(tooth9.category, ToothCategory.incisor);

      // Adult Lower Left 3rd Molar (Wisdom): Univ 17 -> FDI 38
      const tooth17 = ToothChartEntry(toothNumber: 17, toothCode: '17');
      expect(tooth17.fdiNumber, '38');
      expect(tooth17.plainLanguagePosition, 'Lower Left 3rd Molar / Wisdom (FDI 38)');

      // Pediatric Upper Right 2nd Primary Molar: Code A -> FDI 55
      const toothA = ToothChartEntry(toothNumber: 1, toothCode: 'A', isDeciduous: true);
      expect(toothA.fdiNumber, '55');
      expect(toothA.plainLanguagePosition, 'Upper Right 2nd Primary Molar (FDI 55)');
      expect(toothA.category, ToothCategory.molar);

      // Pediatric Lower Right Primary Central Incisor: Code P -> FDI 81
      const toothP = ToothChartEntry(toothNumber: 16, toothCode: 'P', isDeciduous: true);
      expect(toothP.fdiNumber, '81');
      expect(toothP.plainLanguagePosition, 'Lower Right Primary Central Incisor (FDI 81)');
      expect(toothP.category, ToothCategory.incisor);
    });
  });
}
