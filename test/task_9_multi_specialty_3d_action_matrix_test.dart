import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/features/clinic/domain/entities/anatomical_annotation_models.dart';
import 'package:empos/features/clinic/presentation/widgets/dental_modbl_action_widget.dart';
import 'package:empos/features/clinic/presentation/widgets/cardiology_vascular_action_widget.dart';
import 'package:empos/features/clinic/presentation/widgets/ophthalmology_action_widget.dart';
import 'package:empos/features/clinic/presentation/widgets/orthopedics_trauma_action_widget.dart';
import 'package:empos/features/clinic/presentation/widgets/dermatology_action_widget.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Task 9: Multi-Specialty 3D Clinical Action Matrix & Billing Bindings', () {
    // ─────────────────────────────────────────────────────────────────────────
    // Specialty 1: Dental MODBL Polygon & Billing
    // ─────────────────────────────────────────────────────────────────────────
    test('1. Dental: 5-surface MODBL generates correct composite resin billing items by surface count', () {
      // 1-surface
      const annot1 = DentalModblAnnotation(
        toothNumberFdi: 16,
        selectedSurfaces: {DentalModblSurface.occlusal},
      );
      final items1 = annot1.getGeneratedBillingItems();
      expect(items1.length, 1);
      expect(items1.first.code, 'D2391');
      expect(items1.first.standardFee, 120.0);

      // 2-surface
      const annot2 = DentalModblAnnotation(
        toothNumberFdi: 16,
        selectedSurfaces: {DentalModblSurface.mesial, DentalModblSurface.occlusal},
      );
      final items2 = annot2.getGeneratedBillingItems();
      expect(items2.length, 1);
      expect(items2.first.code, 'D2392');
      expect(items2.first.standardFee, 200.0);

      // 3+ surfaces complex
      const annot3 = DentalModblAnnotation(
        toothNumberFdi: 16,
        selectedSurfaces: {DentalModblSurface.mesial, DentalModblSurface.occlusal, DentalModblSurface.distal},
      );
      final items3 = annot3.getGeneratedBillingItems();
      expect(items3.length, 1);
      expect(items3.first.code, 'D2393');
      expect(items3.first.standardFee, 280.0);
    });

    testWidgets('1b. DentalModblActionWidget renders 5-surface buttons and applies restoration', (tester) async {
      DentalModblAnnotation? appliedAnnot;
      List<ProcedureItem>? appliedItems;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DentalModblActionWidget(
              toothNumberFdi: 26,
              onApply: (annot, items) {
                appliedAnnot = annot;
                appliedItems = items;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tooth #26'), findsOneWidget);
      expect(find.text('5-Surface MODBL Restoration'), findsOneWidget);
      expect(find.text('Apply MODBL Restoration to Cart'), findsOneWidget);

      await tester.tap(find.text('Apply MODBL Restoration to Cart'));
      await tester.pumpAndSettle();

      expect(appliedAnnot, isNotNull);
      expect(appliedAnnot!.toothNumberFdi, 26);
      expect(appliedItems, isNotNull);
      expect(appliedItems!.length, 1);
      expect(appliedItems!.first.code, 'D2391');
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Specialty 2: Cardiology / Vascular Caliper & Spline
    // ─────────────────────────────────────────────────────────────────────────
    test('2. Cardiology: Stenosis caliper and stent spline generate diagnostic vs PCI vs CABG billing', () {
      // Diagnostic (< 50%)
      const diagAnnot = CardiologyVascularAnnotation(
        vesselName: 'LAD',
        stenosisPercentage: 40.0,
        interventionType: VascularInterventionType.balloonAngioplasty,
      );
      final diagItems = diagAnnot.getGeneratedBillingItems();
      expect(diagItems.first.code, 'CARD-93458');
      expect(diagItems.first.standardFee, 350.0);

      // PCI with Drug-Eluting Stent (>= 70%)
      const pciAnnot = CardiologyVascularAnnotation(
        vesselName: 'LAD',
        stenosisPercentage: 85.0,
        interventionType: VascularInterventionType.drugElutingStent,
      );
      final pciItems = pciAnnot.getGeneratedBillingItems();
      expect(pciItems.first.code, 'CARD-92928');
      expect(pciItems.first.standardFee, 1800.0);

      // CABG Bypass Graft Spline
      const cabgAnnot = CardiologyVascularAnnotation(
        vesselName: 'RCA',
        stenosisPercentage: 90.0,
        interventionType: VascularInterventionType.bypassGraftSpline,
      );
      final cabgItems = cabgAnnot.getGeneratedBillingItems();
      expect(cabgItems.first.code, 'CARD-33510');
      expect(cabgItems.first.standardFee, 3500.0);
    });

    testWidgets('2b. CardiologyVascularActionWidget renders caliper slider and triggers cart callback', (tester) async {
      CardiologyVascularAnnotation? appliedAnnot;
      List<ProcedureItem>? appliedItems;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CardiologyVascularActionWidget(
              onApply: (annot, items) {
                appliedAnnot = annot;
                appliedItems = items;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Coronary Caliper & Stent Spline'), findsOneWidget);
      expect(find.text('Apply Vascular Caliper & Stent to Cart'), findsOneWidget);

      await tester.tap(find.text('Apply Vascular Caliper & Stent to Cart'));
      await tester.pumpAndSettle();

      expect(appliedAnnot, isNotNull);
      expect(appliedItems, isNotNull);
      expect(appliedItems!.first.code, 'CARD-92928');
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Specialty 3: Ophthalmology C:D Ratio Dial & Diagnostic Suggestions
    // ─────────────────────────────────────────────────────────────────────────
    test('3. Ophthalmology: C:D ratio dial triggers automated OCT and Visual Field recommendations', () {
      // Normal eye (C:D = 0.3)
      const normalAnnot = OphthalmologyCupDiscAnnotation(
        cupToDiscRatio: 0.3,
        rightEyeOD: true,
      );
      expect(normalAnnot.isGlaucomaSuspect, isFalse);
      final normalItems = normalAnnot.getGeneratedBillingItems();
      expect(normalItems.length, 1);
      expect(normalItems.first.code, 'OPH-92014');

      // Glaucoma Suspect (C:D = 0.75)
      const suspectAnnot = OphthalmologyCupDiscAnnotation(
        cupToDiscRatio: 0.75,
        rightEyeOD: true,
        requestVisualFieldTest: true,
        requestOctScan: true,
      );
      expect(suspectAnnot.isGlaucomaSuspect, isTrue);
      final suspectItems = suspectAnnot.getGeneratedBillingItems();
      expect(suspectItems.length, 3);
      expect(suspectItems.any((i) => i.code == 'OPH-92083'), isTrue); // Humphrey Visual Field
      expect(suspectItems.any((i) => i.code == 'OPH-92134'), isTrue); // OCT RNFL Scan
    });

    testWidgets('3b. OphthalmologyActionWidget auto-triggers follow-up orders when C:D > 0.50', (tester) async {
      OphthalmologyCupDiscAnnotation? appliedAnnot;
      List<ProcedureItem>? appliedItems;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OphthalmologyActionWidget(
              cupDiscRatioNotifier: ValueNotifier(0.70),
              visualFieldNotifier: ValueNotifier(true),
              octScanNotifier: ValueNotifier(true),
              onApply: (annot, items) {
                appliedAnnot = annot;
                appliedItems = items;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Optic Nerve Cup-to-Disc (C:D) Ratio'), findsOneWidget);
      expect(find.textContaining('GLAUCOMA SUSPECT'), findsOneWidget);

      await tester.ensureVisible(find.text('Apply C:D Ratio & Orders to Cart'));
      await tester.tap(find.text('Apply C:D Ratio & Orders to Cart'));
      await tester.pumpAndSettle();

      expect(appliedAnnot, isNotNull);
      expect(appliedItems!.length, 3);
      expect(appliedItems!.any((i) => i.code == 'OPH-92083'), isTrue);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Specialty 4: Orthopedics / Trauma Cut-Plane & Joint Goniometer
    // ─────────────────────────────────────────────────────────────────────────
    test('4. Orthopedics: Straight cut-plane and goniometer generate surgical kit and ROM items', () {
      const orthoAnnot = OrthopedicsCutPlaneGoniometerAnnotation(
        targetLimbOrJoint: 'Right Femur',
        cutPlane: CutPlaneAnnotation(
          startNormalized: Offset(0.2, 0.6),
          endNormalized: Offset(0.8, 0.6),
          angleRadians: 0,
        ),
        fadeDistalToWireframe: true,
        goniometerAngleDegrees: 110.0,
      );

      final items = orthoAnnot.getGeneratedBillingItems();
      expect(items.length, 2);
      expect(items.any((i) => i.code == 'ORTHO-27705'), isTrue); // Osteotomy Planning Kit
      expect(items.any((i) => i.code == 'ORTHO-95851'), isTrue); // Joint ROM Goniometry
    });

    testWidgets('4b. OrthopedicsTraumaActionWidget renders truncation controls and applies to cart', (tester) async {
      OrthopedicsCutPlaneGoniometerAnnotation? appliedAnnot;
      List<ProcedureItem>? appliedItems;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OrthopedicsTraumaActionWidget(
              onApply: (annot, items) {
                appliedAnnot = annot;
                appliedItems = items;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Osteotomy Cut-Plane & Goniometer'), findsOneWidget);
      expect(find.text('Apply Osteotomy & Goniometry to Cart'), findsOneWidget);

      await tester.tap(find.text('Apply Osteotomy & Goniometry to Cart'));
      await tester.pumpAndSettle();

      expect(appliedAnnot, isNotNull);
      expect(appliedItems!.length, 2);
    });

    // ─────────────────────────────────────────────────────────────────────────
    // Specialty 5: Dermatology Rule-of-Nines & Suture Marker
    // ─────────────────────────────────────────────────────────────────────────
    test('5. Dermatology: Rule-of-nines TBSA calculation and suture marker generate critical care billing', () {
      const dermAnnot = DermatologyBurnAreaSutureAnnotation(
        affectedBurnRegions: {BodyBurnRegion.chest, BodyBurnRegion.abdomen, BodyBurnRegion.leftArm}, // 9 + 9 + 9 = 27%
        incisionLengthCm: 7.5,
        sutureCount: 6,
      );

      expect(dermAnnot.totalTbsaPercentage, 27.0);
      final items = dermAnnot.getGeneratedBillingItems();
      expect(items.length, 2);
      expect(items.any((i) => i.code == 'DERM-16020'), isTrue); // Burn TBSA Care
      expect(items.any((i) => i.code == 'DERM-12002'), isTrue); // Linear Suture Closure
    });

    testWidgets('5b. DermatologyActionWidget renders TBSA chips and updates cart', (tester) async {
      DermatologyBurnAreaSutureAnnotation? appliedAnnot;
      List<ProcedureItem>? appliedItems;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DermatologyActionWidget(
              onApply: (annot, items) {
                appliedAnnot = annot;
                appliedItems = items;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rule-of-Nines & Suture Marker'), findsOneWidget);
      expect(find.text('TBSA: 18%'), findsOneWidget); // Default chest + abdomen = 18%

      await tester.ensureVisible(find.text('Apply Burn & Suture Procedure to Cart'));
      await tester.tap(find.text('Apply Burn & Suture Procedure to Cart'));
      await tester.pumpAndSettle();

      expect(appliedAnnot, isNotNull);
      expect(appliedAnnot!.totalTbsaPercentage, 18.0);
      expect(appliedItems!.length, 2);
    });
  });
}
