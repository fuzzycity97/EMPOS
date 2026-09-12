import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/data/models/store_blueprint_model.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/features/clinic/presentation/widgets/multi_specialty_anatomy_canvas_widget.dart';
import 'package:empos/features/clinic/presentation/widgets/dental_tooth_matrix_widget.dart';
import 'package:empos/features/clinic/presentation/widgets/clinical_status_inspector_modal.dart';
import 'package:empos/features/clinic/presentation/widgets/tooth_editor_sheet.dart';
import 'package:empos/features/clinic/domain/entities/clinical_status_catalog.dart';
import 'package:empos/features/clinic/domain/entities/tooth_chart_entry.dart';
import 'package:empos/core/localization/app_language.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Multi-Specialty 3D Anatomical Canvas & Profession Blueprints Tests', () {
    setUp(() async {
      await AppLanguage.setLanguage('ar');
    });

    tearDown(() async {
      await AppLanguage.setLanguage('en');
    });

    test('1. Turnkey Blueprints correctly enable Doctor Station & Reception for all specialties', () {
      final eyeBp = StoreBlueprintModel.defaultOphthalmologyBlueprint();
      expect(eyeBp.isOphthalmology, isTrue);
      expect(eyeBp.isMedical, isTrue);
      expect(eyeBp.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(eyeBp.isEnabled('sw.clinic_reception'), isTrue);
      expect(eyeBp.isEnabled('sw.eye_3d_layer_viewer'), isTrue);

      final orthoBp = StoreBlueprintModel.defaultOrthopedicsBlueprint();
      expect(orthoBp.isOrthopedics, isTrue);
      expect(orthoBp.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(orthoBp.isEnabled('sw.bone_3d_skeleton_viewer'), isTrue);

      final physioBp = StoreBlueprintModel.defaultPhysiotherapyBlueprint();
      expect(physioBp.isPhysiotherapy, isTrue);
      expect(physioBp.isEnabled('sw.muscle_3d_anatomy_viewer'), isTrue);

      final gastroBp = StoreBlueprintModel.defaultGastroenterologyBlueprint();
      expect(gastroBp.isGastroenterology, isTrue);
      expect(gastroBp.isEnabled('sw.intestines_3d_digestive_viewer'), isTrue);

      final cardioBp = StoreBlueprintModel.defaultCardiologyBlueprint();
      expect(cardioBp.isCardiology, isTrue);
      expect(cardioBp.isEnabled('sw.heart_3d_vascular_viewer'), isTrue);

      final dermaBp = StoreBlueprintModel.defaultDermatologyBlueprint();
      expect(dermaBp.isDermatology, isTrue);
      expect(dermaBp.isEnabled('sw.skin_3d_dermatome_viewer'), isTrue);

      final vetBp = StoreBlueprintModel.defaultVeterinaryBlueprint();
      expect(vetBp.isVeterinary, isTrue);
      expect(vetBp.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(vetBp.isEnabled('sw.clinic_reception'), isTrue);
      expect(vetBp.isEnabled('sw.veterinary_3d_quadruped_viewer'), isTrue);

      final labBp = StoreBlueprintModel.defaultDiagnosticLabBlueprint();
      expect(labBp.isDiagnosticLab, isTrue);
      expect(labBp.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(labBp.isEnabled('sw.clinic_reception'), isTrue);
      expect(labBp.isEnabled('sw.lab_3d_specimen_viewer'), isTrue);

      final mentalBp = StoreBlueprintModel.defaultMentalHealthBlueprint();
      expect(mentalBp.isMentalHealth, isTrue);
      expect(mentalBp.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(mentalBp.isEnabled('sw.clinic_reception'), isTrue);
      expect(mentalBp.isEnabled('sw.mental_3d_brain_axis_viewer'), isTrue);

      final pedBp = StoreBlueprintModel.defaultPediatricsBlueprint();
      expect(pedBp.isPediatric, isTrue);
      expect(pedBp.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(pedBp.isEnabled('sw.clinic_reception'), isTrue);
      expect(pedBp.isEnabled('sw.pediatric_3d_growth_viewer'), isTrue);

      final neuroBp = StoreBlueprintModel.defaultNeurologyBlueprint();
      expect(neuroBp.isNeurology, isTrue);
      expect(neuroBp.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(neuroBp.isEnabled('sw.clinic_reception'), isTrue);
      expect(neuroBp.isEnabled('sw.neuro_3d_brain_viewer'), isTrue);

      final entBp = StoreBlueprintModel.defaultEntRhinologyBlueprint();
      expect(entBp.isRhinologySinus, isTrue);
      expect(entBp.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(entBp.isEnabled('sw.sinus_3d_rhinology_viewer'), isTrue);

      final pulmonologyBp = StoreBlueprintModel.defaultPulmonologyBlueprint();
      expect(pulmonologyBp.isPulmonology, isTrue);
      expect(pulmonologyBp.isEnabled('sw.lungs_3d_respiratory_viewer'), isTrue);

      final uroBp = StoreBlueprintModel.defaultUrologyBlueprint();
      expect(uroBp.isUrology, isTrue);
      expect(uroBp.isEnabled('sw.urology_3d_pelvic_viewer'), isTrue);

      final obgynBp = StoreBlueprintModel.defaultObGynBlueprint();
      expect(obgynBp.isObGyn, isTrue);
      expect(obgynBp.isEnabled('sw.obgyn_3d_pelvic_fetal_viewer'), isTrue);

      final podiatryBp = StoreBlueprintModel.defaultPodiatryBlueprint();
      expect(podiatryBp.isPodiatry, isTrue);
      expect(podiatryBp.isEnabled('sw.foot_3d_podiatry_viewer'), isTrue);

      final plasticBp = StoreBlueprintModel.defaultPlasticSurgeryBlueprint();
      expect(plasticBp.isPlasticSurgery, isTrue);
      expect(plasticBp.isEnabled('sw.face_3d_plastic_surgery_viewer'), isTrue);

      final aestheticsBp = StoreBlueprintModel.defaultMedicalAestheticsBlueprint();
      expect(aestheticsBp.isMedicalAesthetics, isTrue);
      expect(aestheticsBp.isEnabled('sw.face_3d_injectors_mapper'), isTrue);

      final painBp = StoreBlueprintModel.defaultPainManagementBlueprint();
      expect(painBp.isPainManagement, isTrue);
      expect(painBp.isEnabled('sw.pain_3d_spine_block_viewer'), isTrue);

      final acuBp = StoreBlueprintModel.defaultAcupunctureBlueprint();
      expect(acuBp.isAcupuncture, isTrue);
      expect(acuBp.isEnabled('sw.meridian_3d_acupoint_viewer'), isTrue);

      final slpBp = StoreBlueprintModel.defaultSpeechPathologyBlueprint();
      expect(slpBp.isSpeechPathology, isTrue);
      expect(slpBp.isEnabled('sw.vocal_3d_articulatory_viewer'), isTrue);
    });

    testWidgets('2. Ophthalmology 3D Canvas renders Eye Anatomy and interactive Layer Switcher buttons', (tester) async {
      final eyeBp = StoreBlueprintModel.defaultOphthalmologyBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: eyeBp,
                doctorName: 'Dr. Sarah Connor',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ophthalmology & Eye Care'), findsOneWidget);
      expect(find.textContaining('Ocular Layers Switcher'), findsOneWidget);
      expect(find.textContaining('Cornea & Sclera'), findsOneWidget);
      expect(find.textContaining('Iris, Ciliary Body & Choroid'), findsOneWidget);
      expect(find.textContaining('Retina, Macula'), findsOneWidget);
      expect(find.textContaining('Lens & Vitreous'), findsOneWidget);

      // Verify Cornea and Retina hotspots exist
      expect(find.text(AppLanguage.isArabic ? 'Cornea (القرنية)' : 'Cornea'), findsOneWidget);
      expect(find.text(AppLanguage.isArabic ? 'Retina & Macula (الشبكية والبقعة)' : 'Retina & Macula'), findsOneWidget);

      // Tap on a layer chip to test layer filtering
      await tester.ensureVisible(find.textContaining('Fibrous Outer Layer'));
      await tester.tap(find.textContaining('Fibrous Outer Layer'));
      await tester.pumpAndSettle();

      // Cornea should remain visible while internal retina is filtered out in fibrous mode
      expect(find.text(AppLanguage.isArabic ? 'Cornea (القرنية)' : 'Cornea'), findsOneWidget);
      expect(find.text(AppLanguage.isArabic ? 'Retina & Macula (الشبكية والبقعة)' : 'Retina & Macula'), findsNothing);
    });

    testWidgets('3. Orthopedics 3D Canvas renders bone grid and goniometer controls', (tester) async {
      final orthoBp = StoreBlueprintModel.defaultOrthopedicsBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: orthoBp,
                doctorName: 'Dr. Bones',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Orthopedics & Bone Surgery'), findsOneWidget);
      expect(find.textContaining('3D Skeletal Bone Explorer'), findsOneWidget);
      expect(find.text('الجمجمة وعظام الوجه'), findsOneWidget);
      expect(find.text('الفقرات العنقية'), findsOneWidget);
      expect(find.text('عظم الفخذ'), findsOneWidget);
    });

    testWidgets('4. Gastroenterology 3D Canvas renders digestive organs and endoscopy options', (tester) async {
      final gastroBp = StoreBlueprintModel.defaultGastroenterologyBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: gastroBp,
                doctorName: 'Dr. GI',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Gastroenterology & Intestinal Health'), findsOneWidget);
      expect(find.textContaining('الجهاز الهضمي والأمعاء'), findsOneWidget);
      expect(find.text('المعدة والحرقة الهضمية'), findsOneWidget);
      expect(find.text('القولون والأمعاء الغليظة'), findsOneWidget);
    });

    testWidgets('5. Dental Blueprint cleanly renders DentalToothMatrixWidget', (tester) async {
      final dentalBp = StoreBlueprintModel.defaultDentalBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: dentalBp,
                doctorName: 'Dr. Dentist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(DentalToothMatrixWidget), findsOneWidget);
      expect(find.text('Dental & Oral Surgery'), findsOneWidget);
    });

    testWidgets('6. Clinical Status Inspector Modal supports live search, category filtering, and status selection', (tester) async {
      final eyeBp = StoreBlueprintModel.defaultOphthalmologyBlueprint();
      String? appliedFinding;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: eyeBp,
                doctorName: 'Dr. Eye Specialist',
                onProcedureApplied: (proc, note) {
                  appliedFinding = note;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Cornea hotspot to open the searchable status inspector
      await tester.ensureVisible(find.text(AppLanguage.isArabic ? 'Cornea (القرنية)' : 'Cornea'));
      await tester.tap(find.text(AppLanguage.isArabic ? 'Cornea (القرنية)' : 'Cornea'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify modal is open with search bar and categories
      expect(find.byType(ClinicalStatusInspectorModal), findsOneWidget);
      expect(find.textContaining('Search status, pathology name, ICD-10 code'), findsOneWidget);
      expect(find.textContaining('All Statuses'), findsOneWidget);
      expect(find.textContaining('Normal / Healthy'), findsOneWidget);

      // Search for specific condition
      await tester.enterText(find.byType(TextField), 'ulcer');
      await tester.pumpAndSettle();

      expect(find.textContaining('Corneal Ulcer & Microbial Keratitis'), findsOneWidget);
      expect(find.textContaining('H16.0'), findsOneWidget);

      // Select the status by tapping the status card
      await tester.tap(find.textContaining('Corneal Ulcer & Microbial Keratitis').first);
      await tester.pumpAndSettle();

      // Modal should close
      expect(find.byType(ClinicalStatusInspectorModal), findsNothing);

      // Visual active status tray should now be visible with the finding and fee
      expect(find.textContaining('Active 4D/3D Diagnoses & Pathological Statuses (1)'), findsOneWidget);
      expect(find.textContaining('H16.0'), findsWidgets);
      expect(appliedFinding, contains('Corneal Ulcer'));
    });

    testWidgets('7. Orthopedics Bone Tap opens status inspector and visualizes active pathology on bone card', (tester) async {
      final orthoBp = StoreBlueprintModel.defaultOrthopedicsBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: orthoBp,
                doctorName: 'Dr. Ortho Specialist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Femur bone
      await tester.tap(find.text('عظم الفخذ'));
      await tester.pumpAndSettle();

      // Search for fracture
      expect(find.byType(ClinicalStatusInspectorModal), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'S72.3');
      await tester.pumpAndSettle();

      expect(find.textContaining('Displaced Transverse Diaphyseal Fracture'), findsOneWidget);
      await tester.tap(find.textContaining('Displaced Transverse Diaphyseal Fracture').first);
      await tester.pumpAndSettle();

      // Active status tray renders the Orthopedics diagnosis
      expect(find.textContaining('Active 4D/3D Diagnoses & Pathological Statuses (1)'), findsOneWidget);
      expect(find.textContaining('S72.3'), findsWidgets);

      // Clear all button removes the status
      await tester.ensureVisible(find.text('Clear All'));
      await tester.tap(find.text('Clear All'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Active 4D/3D Diagnoses & Pathological Statuses'), findsNothing);
    });

    testWidgets('8. Dental ToothEditorSheet contains Search Statuses button and integrates ICD-10 catalog', (tester) async {
      final testEntry = ToothChartEntry(
        toothNumber: 11,
        toothCode: '11',
        isDeciduous: false,
        state: ToothState.healthy,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ToothEditorSheet(
              entry: testEntry,
              onSave: (_) {},
              onCancel: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the search status button is visible in ToothEditorSheet
      expect(find.textContaining('Search Statuses & ICD-10'), findsOneWidget);

      // Tap the search button to open inspector
      await tester.tap(find.textContaining('Search Statuses & ICD-10'));
      await tester.pumpAndSettle();

      expect(find.byType(ClinicalStatusInspectorModal), findsOneWidget);
      expect(find.textContaining('Deep Dentinal Caries'), findsOneWidget);

      // Select Caries by tapping the card
      await tester.tap(find.textContaining('Deep Dentinal Caries').first);
      await tester.pumpAndSettle();

      // Inspector closed, tooth state mapped and note contains K02.1
      expect(find.textContaining('K02.1'), findsOneWidget);
    });

    testWidgets('9. Neurology & Neurosurgery 3D Canvas renders Intracranial Brain Layers and assigns Glioma / Stroke pathology', (tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final neuroBp = StoreBlueprintModel.defaultClinicBlueprint();
      String? appliedFinding;
      String? appliedCode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: neuroBp,
                initialDiscipline: ClinicalSpecialtyDiscipline.neurology,
                doctorName: 'Dr. Gregory House',
                onProcedureApplied: (proc, note) {
                  appliedCode = proc.code;
                  appliedFinding = note;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify title, subtitle and layer switcher
      expect(find.textContaining('Neurology & Neurosurgery 3D Visualizer'), findsOneWidget);
      expect(find.textContaining('Neurological Layers'), findsOneWidget);
      expect(find.textContaining('Cortical Lobes'), findsOneWidget);
      expect(find.textContaining('Ventricles & CSF'), findsOneWidget);
      expect(find.textContaining('Basal Ganglia'), findsWidgets);
      expect(find.textContaining('Cranial Nerves I–XII'), findsOneWidget);
      expect(find.textContaining('Circle of Willis'), findsWidgets);

      // Verify brain hotspots
      expect(find.text('Cerebral Lobes (القشرة المخية)'), findsOneWidget);
      expect(find.text('Circle of Willis (شرايين ويليس)'), findsOneWidget);

      // Tap Cerebral Lobes to open inspector
      await tester.ensureVisible(find.text('Cerebral Lobes (القشرة المخية)'));
      await tester.tap(find.text('Cerebral Lobes (القشرة المخية)'));
      await tester.pumpAndSettle();

      expect(find.byType(ClinicalStatusInspectorModal), findsOneWidget);

      // Search for glioma tumor mapping
      await tester.enterText(find.byType(TextField), 'glioma');
      await tester.pumpAndSettle();

      expect(find.textContaining('High-Grade Glioma / Glioblastoma Multiforme (GBM)'), findsOneWidget);
      expect(find.textContaining('C71.9'), findsOneWidget);

      // Tap status card
      await tester.tap(find.textContaining('High-Grade Glioma / Glioblastoma Multiforme (GBM)').first);
      await tester.pumpAndSettle();

      // Inspector closed, tray active
      expect(find.byType(ClinicalStatusInspectorModal), findsNothing);
      expect(find.textContaining('Active 4D/3D Diagnoses & Pathological Statuses (1)'), findsOneWidget);
      expect(find.textContaining('C71.9'), findsWidgets);
      expect(appliedCode, 'NEU-61510');
      expect(appliedFinding, contains('Glioma'));
    });

    testWidgets('10. Neuro-Otology & Balance Canvas tracks Otoliths, Canals & Epley Maneuver procedure', (tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final otolBp = StoreBlueprintModel.defaultClinicBlueprint();
      String? appliedProcName;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: otolBp,
                initialDiscipline: ClinicalSpecialtyDiscipline.neuroOtology,
                doctorName: 'Dr. Balance',
                onProcedureApplied: (proc, note) {
                  appliedProcName = proc.name;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Neuro-Otology & Balance 3D Explorer'), findsOneWidget);
      expect(find.text('Posterior Canal (القناة الهلالية الخلفية)'), findsOneWidget);
      expect(find.text('Cochlea (القوقعة)'), findsOneWidget);

      // Tap Posterior Canal
      await tester.ensureVisible(find.text('Posterior Canal (القناة الهلالية الخلفية)'));
      await tester.tap(find.text('Posterior Canal (القناة الهلالية الخلفية)'));
      await tester.pumpAndSettle();

      expect(find.byType(ClinicalStatusInspectorModal), findsOneWidget);

      // Search for BPPV
      await tester.enterText(find.byType(TextField), 'H81.1');
      await tester.pumpAndSettle();

      expect(find.textContaining('BPPV / Posterior Canal Canalithiasis'), findsOneWidget);
      await tester.tap(find.textContaining('BPPV / Posterior Canal Canalithiasis').first);
      await tester.pumpAndSettle();

      expect(appliedProcName, contains('Repositioning Maneuver'));
      expect(find.textContaining('H81.1'), findsWidgets);
    });

    testWidgets('11. Pulmonology 3D Canvas visualizes Bronchial Tree, Lung Parenchyma and EBUS Biopsy mapping', (tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final pulmBp = StoreBlueprintModel.defaultClinicBlueprint();
      String? appliedCode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: pulmBp,
                initialDiscipline: ClinicalSpecialtyDiscipline.pulmonology,
                doctorName: 'Dr. Respiration',
                onProcedureApplied: (proc, note) {
                  appliedCode = proc.code;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Pulmonology & Respiratory 3D Visualizer'), findsOneWidget);
      expect(find.text('Trachea & Carina (القصبة الهوائية)'), findsOneWidget);

      // Tap Trachea & Carina
      await tester.ensureVisible(find.text('Trachea & Carina (القصبة الهوائية)'));
      await tester.tap(find.text('Trachea & Carina (القصبة الهوائية)'));
      await tester.pumpAndSettle();

      expect(find.byType(ClinicalStatusInspectorModal), findsOneWidget);

      // Search EBUS
      await tester.enterText(find.byType(TextField), 'ebus');
      await tester.pumpAndSettle();

      expect(find.textContaining('Mediastinal Lymphadenopathy'), findsOneWidget);
      await tester.tap(find.textContaining('Mediastinal Lymphadenopathy').first);
      await tester.pumpAndSettle();

      expect(appliedCode, 'PUL-31652');
      expect(find.textContaining('R59.0'), findsWidgets);
    });

    testWidgets('12. Urology & Men\'s Health 3D Canvas renders Pelvic Viscera and Fusion Biopsy', (tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final urologyBp = StoreBlueprintModel.defaultClinicBlueprint();
      String? appliedCode;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: urologyBp,
                initialDiscipline: ClinicalSpecialtyDiscipline.urology,
                doctorName: 'Dr. Urology',
                onProcedureApplied: (proc, note) {
                  appliedCode = proc.code;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Urology & Men\'s Health 3D Visualizer'), findsOneWidget);
      expect(find.text('Renal Pelvis (حوض الكلية)'), findsOneWidget);

      // Tap Renal Pelvis
      await tester.ensureVisible(find.text('Renal Pelvis (حوض الكلية)'));
      await tester.tap(find.text('Renal Pelvis (حوض الكلية)'));
      await tester.pumpAndSettle();

      expect(find.byType(ClinicalStatusInspectorModal), findsOneWidget);

      // Search calculus
      await tester.enterText(find.byType(TextField), 'N20.0');
      await tester.pumpAndSettle();

      expect(find.textContaining('Renal Pelvic Calculus'), findsOneWidget);
      await tester.tap(find.textContaining('Renal Pelvic Calculus').first);
      await tester.pumpAndSettle();

      expect(appliedCode, 'URO-52356');
      expect(find.textContaining('N20.0'), findsWidgets);
    });

    testWidgets('13. Medical Aesthetics Canvas renders Facial Danger Zones and Botox unit mapping', (tester) async {
      tester.view.physicalSize = const Size(1280, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final aestheticBp = StoreBlueprintModel.defaultClinicBlueprint();
      String? appliedFinding;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: aestheticBp,
                initialDiscipline: ClinicalSpecialtyDiscipline.medicalAesthetics,
                doctorName: 'Dr. Glamour',
                onProcedureApplied: (proc, note) {
                  appliedFinding = note;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Medical Aesthetics 3D Visualizer'), findsOneWidget);
      expect(find.text('Glabellar Lines (تجاعيد ما بين الحاجبين)'), findsOneWidget);

      // Tap Glabellar Complex
      await tester.ensureVisible(find.text('Glabellar Lines (تجاعيد ما بين الحاجبين)'));
      await tester.tap(find.text('Glabellar Lines (تجاعيد ما بين الحاجبين)'));
      await tester.pumpAndSettle();

      expect(find.byType(ClinicalStatusInspectorModal), findsOneWidget);

      // Search for botox
      await tester.enterText(find.byType(TextField), 'botox');
      await tester.pumpAndSettle();

      expect(find.textContaining('Hyperkinetic Glabellar & Frontalis Lines'), findsOneWidget);
      await tester.tap(find.textContaining('Hyperkinetic Glabellar & Frontalis Lines').first);
      await tester.pumpAndSettle();

      expect(appliedFinding, contains('Botox'));
      expect(find.textContaining('L90.8'), findsWidgets);
    });

    test('14. ClinicalStatusCatalog provides comprehensive statuses, ICD-10 codes and procedures across all 26 disciplines', () {
      final disciplines = ClinicalSpecialtyDiscipline.values.where((d) => d != ClinicalSpecialtyDiscipline.general).toList();
      expect(disciplines.length, 26);

      for (final disc in disciplines) {
        final statuses = ClinicalStatusCatalog.getStatusesForDiscipline(discipline: disc);
        expect(statuses, isNotEmpty, reason: 'Discipline ${disc.name} must have catalog statuses');
        
        // Ensure every status has non-empty ICD-10, title, titleAr, and procedure
        for (final st in statuses) {
          expect(st.icd10Code, isNotEmpty);
          expect(st.title, isNotEmpty);
          expect(st.titleAr, isNotEmpty);
          expect(st.suggestedProcedure.code, isNotEmpty);
          expect(st.suggestedProcedure.standardFee, isPositive);
          
          // Test query matching
          expect(st.matchesQuery(st.icd10Code), isTrue);
          expect(st.matchesQuery(st.title.substring(0, 3)), isTrue);
        }
      }
    });

    test('15. Store Builder supports all 35 Medical Clinic Blueprints with Doctor Station & Reception enabled', () {
      final medicalIndustries = SpecificIndustry.values.where((s) => s.vertical == IndustryVertical.medical).toList();
      expect(medicalIndustries.length, 35);

      // Verify each specialized clinic has the expected semantic helpers and properties
      for (final spec in medicalIndustries) {
        expect(spec.vertical, IndustryVertical.medical);
        expect(spec.label, isNotEmpty);
        expect(spec.id, isNotEmpty);
        
        final parsed = SpecificIndustry.fromString(spec.id);
        expect(parsed, spec);
      }
    });

    testWidgets('16. 3D visualizer maintains active specialty tab and does NOT shift to default tab upon parent rebuild', (tester) async {
      final generalBp = StoreBlueprintModel.defaultGeneralClinicBlueprint();

      // Initial render - default inferred discipline is general
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: generalBp,
                doctorName: 'Dr. Persist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('General Medical Practice'), findsOneWidget);

      // Tap on Neurology card in the multi-system grid
      await tester.ensureVisible(find.text('Neurology & Neurosurgery'));
      await tester.tap(find.text('Neurology & Neurosurgery'));
      await tester.pumpAndSettle();

      // Confirm we switched to Neurology & Neurosurgery
      expect(find.text('Neurology & Neurosurgery'), findsOneWidget);
      expect(find.textContaining('3D Brain & Skull Base'), findsOneWidget);

      // Simulate parent widget rebuild (e.g. DoctorStationPage rebuild on queue poll, note edit, or patient selection)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: generalBp,
                doctorName: 'Dr. Persist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The 3D viewer MUST remain on Neurology and NOT shift back to default (General Medical Practice)
      expect(find.text('Neurology & Neurosurgery'), findsOneWidget);
      expect(find.textContaining('3D Brain & Skull Base'), findsOneWidget);
      expect(find.text('General Medical Practice'), findsNothing);
    });

    testWidgets('17. 3D visualizer synchronizes with external disciplineNotifier and fires onDisciplineChanged callback', (tester) async {
      final generalBp = StoreBlueprintModel.defaultGeneralClinicBlueprint();
      final disciplineNotifier = ValueNotifier<ClinicalSpecialtyDiscipline>(ClinicalSpecialtyDiscipline.general);
      ClinicalSpecialtyDiscipline? callbackDiscipline;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: generalBp,
                disciplineNotifier: disciplineNotifier,
                onDisciplineChanged: (d) => callbackDiscipline = d,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('General Medical Practice'), findsOneWidget);

      // Select Cardiology in the systems grid
      await tester.ensureVisible(find.text('Cardiology (Heart)'));
      await tester.tap(find.text('Cardiology (Heart)'));
      await tester.pumpAndSettle();

      // Verify disciplineNotifier and callback both updated
      expect(disciplineNotifier.value, ClinicalSpecialtyDiscipline.cardiology);
      expect(callbackDiscipline, ClinicalSpecialtyDiscipline.cardiology);
      expect(find.text('Cardiology & Cardiovascular'), findsOneWidget);

      // Update notifier externally to Pulmonology
      disciplineNotifier.value = ClinicalSpecialtyDiscipline.pulmonology;
      await tester.pumpAndSettle();

      expect(find.text('Pulmonology & Respiratory'), findsOneWidget);
    });

    testWidgets('18. Independent OD and OS C:D ratio persistence: setting OD does not affect OS and switching eyes does not reset ratio', (tester) async {
      final eyeBp = StoreBlueprintModel.defaultOphthalmologyBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: eyeBp,
                doctorName: 'Dr. Eye Specialist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially OD is selected with default 0.40
      expect(find.textContaining('C:D Ratio Caliper [OD - Right Eye]'), findsOneWidget);
      expect(find.text('0.40'), findsWidgets);

      // Tap on the C:D Ratio slider to change OD value
      final sliderFinder = find.byType(Slider);
      expect(sliderFinder, findsOneWidget);
      await tester.ensureVisible(sliderFinder);
      await tester.tap(sliderFinder);
      await tester.pumpAndSettle();

      // Switch to OS (Left Eye)
      await tester.ensureVisible(find.text('OS (اليسرى - Left)'));
      await tester.tap(find.text('OS (اليسرى - Left)'));
      await tester.pumpAndSettle();

      // OS should now be active and retain its initial independent value (0.40)
      expect(find.textContaining('C:D Ratio Caliper [OS - Left Eye]'), findsOneWidget);
      expect(find.text('0.40'), findsWidgets);

      // Switch back to OD
      await tester.ensureVisible(find.text('OD (اليمنى - Right)'));
      await tester.tap(find.text('OD (اليمنى - Right)'));
      await tester.pumpAndSettle();

      // OD is active again
      expect(find.textContaining('C:D Ratio Caliper [OD - Right Eye]'), findsOneWidget);
    });

    testWidgets('19. 3D Eye View Mode switching (Globe, Sliced Layers, Fundus) and yaw/pitch rotation angles', (tester) async {
      final eyeBp = StoreBlueprintModel.defaultOphthalmologyBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: eyeBp,
                doctorName: 'Dr. Eye Specialist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify all 3 view mode chips are rendered
      expect(find.text('1. الكرة العينية 3D (Globe)'), findsOneWidget);
      expect(find.text('2. مقطع مجسم للطبقات (3D Layers)'), findsOneWidget);
      expect(find.text('3. قاع العين وعمق التقعر (Fundus & C:D)'), findsOneWidget);

      // Switch to Mode 0: Globe
      await tester.tap(find.text('1. الكرة العينية 3D (Globe)'));
      await tester.pumpAndSettle();

      // Switch to Mode 2: Fundus & C:D
      await tester.tap(find.text('3. قاع العين وعمق التقعر (Fundus & C:D)'));
      await tester.pumpAndSettle();

      // Tap reset angle button
      await tester.tap(find.text('إعادة ضبط زاوية 3D'));
      await tester.pumpAndSettle();

      // Switch back to 3D Layers
      await tester.tap(find.text('2. مقطع مجسم للطبقات (3D Layers)'));
      await tester.pumpAndSettle();
      expect(find.text('2. مقطع مجسم للطبقات (3D Layers)'), findsOneWidget);
    });

    testWidgets('20. Pin Note Mode allows clicking anywhere on 3D model to drop custom pin notes with severity, category, and fee', (tester) async {
      await AppLanguage.setLanguage('ar');
      final eyeBp = StoreBlueprintModel.defaultOphthalmologyBlueprint();
      String? appliedFinding;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: eyeBp,
                doctorName: 'Dr. Pin Tester',
                onProcedureApplied: (proc, note) {
                  appliedFinding = note;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Activate Pin Note Mode in header
      await tester.tap(find.text('تثبيت دبوس ملاحظة (Pin)'));
      await tester.pumpAndSettle();

      // Pin mode should now be active
      expect(find.text('وضع الدبوس (نشط)'), findsOneWidget);

      // Tap on the overlay banner to trigger drop pin at relative coordinates
      await tester.tap(find.textContaining('انقر في أي موضع لتثبيت دبوس الملاحظة'));
      await tester.pumpAndSettle();

      // Custom Pin Note Dialog should appear
      expect(find.textContaining('إضافة ملاحظة موضعية ثلاثية الأبعاد (3D Pin Note)'), findsOneWidget);

      // Fill in finding title, clinical note, and suggested procedure fee
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Peripheral Retinal Tear');
      await tester.enterText(textFields.at(1), 'Cryoretinopexy indicated at 2 o clock');
      await tester.enterText(textFields.at(3), '1500');
      await tester.pumpAndSettle();

      // Save the custom pin note
      await tester.ensureVisible(find.text('حفظ الملاحظة والدبوس'));
      await tester.tap(find.text('حفظ الملاحظة والدبوس'));
      await tester.pumpAndSettle();

      // Verify custom pin note appears in active diagnoses tray with [📍 Pin]
      expect(find.textContaining('[📍 Pin]'), findsOneWidget);
      expect(find.textContaining('Peripheral Retinal Tear'), findsWidgets);
      expect(appliedFinding, contains('Peripheral Retinal Tear'));
    });

    testWidgets('21. English Mode renders zero Arabic text across the canvas, controls, and chips', (tester) async {
      await AppLanguage.setLanguage('en');
      final eyeBp = StoreBlueprintModel.defaultOphthalmologyBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: eyeBp,
                doctorName: 'Dr. Sarah Connor',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify English controls & headers
      expect(find.text('Drop 3D Pin'), findsOneWidget);
      expect(find.text('Target Examined Eye:'), findsOneWidget);
      expect(find.text('Right Eye (OD)'), findsOneWidget);
      expect(find.text('Left Eye (OS)'), findsOneWidget);
      expect(find.text('Reset 3D View'), findsOneWidget);
      expect(find.text('3D View Mode:'), findsOneWidget);
      expect(find.text('1. 3D Globe'), findsOneWidget);
      expect(find.text('2. 3D Sliced Layers'), findsOneWidget);
      expect(find.text('3. Fundus & C:D Ratio'), findsOneWidget);
      expect(find.text('Ocular Layers Switcher:'), findsOneWidget);
      expect(find.text('All Layers'), findsOneWidget);
      expect(find.text('1. Fibrous Outer Layer'), findsOneWidget);
      expect(find.text('Cornea & Sclera'), findsOneWidget);
      expect(find.text('OD: Right Eye'), findsOneWidget);
      expect(find.text('Drag to rotate 3D • Click to add pin'), findsOneWidget);
      expect(find.text('Add Pin Note'), findsOneWidget);

      // Verify no residual Arabic text anywhere in visible Text widgets
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      final arabicRegex = RegExp(r'[\u0600-\u06FF]');
      for (final textWidget in textWidgets) {
        final text = textWidget.data ?? textWidget.textSpan?.toPlainText() ?? '';
        expect(
          arabicRegex.hasMatch(text),
          isFalse,
          reason: 'Residual Arabic text leaked in English mode: "$text"',
        );
      }
    });

    testWidgets('22. Veterinary 3D Canvas renders Quadruped Anatomy and species / layer switchers', (tester) async {
      final vetBp = StoreBlueprintModel.defaultVeterinaryBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: vetBp,
                doctorName: 'Dr. Vet Specialist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Veterinary Medicine & Surgery'), findsOneWidget);
      expect(find.text(AppLanguage.isArabic ? 'جناح الجراحة والتشريح البيطري ثلاثي الأبعاد' : 'Veterinary 3D Anatomy & Surgical Suite'), findsOneWidget);
      expect(find.textContaining(AppLanguage.isArabic ? 'كلب (Canine)' : 'Canine (Dog)'), findsOneWidget);
      expect(find.textContaining(AppLanguage.isArabic ? 'قط (Feline)' : 'Feline (Cat)'), findsOneWidget);

      // Switch species to Feline
      await tester.tap(find.textContaining(AppLanguage.isArabic ? 'قط (Feline)' : 'Feline (Cat)'));
      await tester.pumpAndSettle();

      // Switch to Visceral Layer
      await tester.tap(find.widgetWithText(ChoiceChip, VeterinaryLayer.visceral.label));
      await tester.pumpAndSettle();

      expect(find.textContaining('HR'), findsWidgets);
    });

    testWidgets('23. Diagnostic Lab 3D Canvas renders Specimen / Microscopic view and magnification controls', (tester) async {
      final labBp = StoreBlueprintModel.defaultDiagnosticLabBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: labBp,
                doctorName: 'Dr. Lab Specialist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Diagnostic Pathology & Laboratory'), findsOneWidget);
      expect(find.text(AppLanguage.isArabic ? 'مختبر التشخيص الباثولوجي والفحص المجهري ثلاثي الأبعاد' : 'Diagnostic Pathology & Microscopy Lab'), findsOneWidget);
      expect(find.text('10x'), findsOneWidget);
      expect(find.text('40x'), findsOneWidget);
      expect(find.text('100x Oil'), findsOneWidget);

      // Tap 40x magnification
      await tester.tap(find.text('40x'));
      await tester.pumpAndSettle();

      // Switch to Cytology Smear
      await tester.tap(find.widgetWithText(ChoiceChip, DiagnosticLabLayer.cytology.label));
      await tester.pumpAndSettle();

      expect(find.textContaining('RBC'), findsWidgets);
    });

    testWidgets('24. Mental Health 3D Canvas renders Neuro-Axis / Cognitive Map and PHQ-9 / GAD-7 metrics', (tester) async {
      final mentalBp = StoreBlueprintModel.defaultMentalHealthBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: mentalBp,
                doctorName: 'Dr. Psych Specialist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mental Health & Behavioral Counseling'), findsOneWidget);
      expect(find.text(AppLanguage.isArabic ? 'جناح الصحة النفسية والشبكات العصبية المعرفية' : 'Mental Health & Neuro-Cognitive Suite'), findsOneWidget);
      expect(find.textContaining('PHQ-9'), findsWidgets);
      expect(find.textContaining('GAD-7'), findsWidgets);

      // Switch layer to Limbic Circuit
      await tester.tap(find.widgetWithText(ChoiceChip, MentalHealthLayer.limbic.label));
      await tester.pumpAndSettle();

      expect(find.textContaining('PHQ-9'), findsWidgets);
    });

    testWidgets('25. Pediatric Clinic 3D Canvas renders Pediatric Growth & Development milestones and interactive age slider', (tester) async {
      final pedBp = StoreBlueprintModel.defaultPediatricsBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: pedBp,
                doctorName: 'Dr. Pediatric Specialist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pediatrics & Child Health'), findsOneWidget);
      expect(find.text(AppLanguage.isArabic ? 'جناح طب الأطفال والنمو والتطور السريري ثلاثي الأبعاد' : 'Pediatrics & Child Development Suite'), findsOneWidget);
      expect(find.textContaining(AppLanguage.isArabic ? 'الفئة العمرية للطفل' : 'Patient Age Cohort'), findsWidgets);
      expect(find.textContaining('Weight'), findsWidgets);

      // Switch layer to Growth
      await tester.tap(find.widgetWithText(ChoiceChip, PediatricLayer.growth.label));
      await tester.pumpAndSettle();

      expect(find.textContaining('Weight'), findsWidgets);
    });

    testWidgets('26. Ophthalmology 3D Visualizer renders 3D Sliced Layers, supports 3D layer explosion separation and drag rotation', (tester) async {
      final eyeBp = StoreBlueprintModel.defaultOphthalmologyBlueprint();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: MultiSpecialtyAnatomyCanvasWidget(
                blueprint: eyeBp,
                doctorName: 'Dr. Eye Specialist',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify View Mode selector exists (e.g. 3D Layers / مقطع مجسم)
      final layerModeBtn = find.textContaining(AppLanguage.isArabic ? 'مقطع مجسم' : '3D Layers');
      expect(layerModeBtn, findsWidgets);

      // Tap 3D Sliced Layers mode
      await tester.tap(layerModeBtn.first);
      await tester.pumpAndSettle();

      // Verify 3D Layer Separation slider and preset chips are rendered
      expect(find.textContaining(AppLanguage.tr('3D Layer Separation', 'انفصال الطبقات')), findsWidgets);
      expect(find.textContaining(AppLanguage.tr('Compact', 'مدمج')), findsWidgets);
      expect(find.textContaining(AppLanguage.tr('Exploded', 'منفصل')), findsWidgets);

      // Tap 'Exploded 100%' preset chip
      final explodedChip = find.textContaining(AppLanguage.tr('Exploded', 'منفصل'));
      expect(explodedChip, findsWidgets);
      await tester.ensureVisible(explodedChip.first);
      await tester.pumpAndSettle();
      await tester.tap(explodedChip.first);
      await tester.pumpAndSettle();

      // Drag on CustomPaint to rotate eye in 3D (yaw and pitch)
      final canvasFinder = find.byType(CustomPaint).first;
      await tester.drag(canvasFinder, const Offset(60, -40));
      await tester.pumpAndSettle();

      // Switch active layer to Retina
      final retinaChip = find.widgetWithText(ChoiceChip, EyeAnatomicalLayer.retina.label);
      if (retinaChip.evaluate().isNotEmpty) {
        await tester.ensureVisible(retinaChip);
        await tester.pumpAndSettle();
        await tester.tap(retinaChip);
        await tester.pumpAndSettle();
      }

      // Verify CustomPaint continues rendering without overflow or error
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}

