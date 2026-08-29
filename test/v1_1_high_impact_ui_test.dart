import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/theme/app_theme.dart';
import 'package:empos/features/clinic/presentation/bloc/clinic_bloc.dart';
import 'package:empos/features/clinic/presentation/bloc/clinic_event.dart';
import 'package:empos/features/clinic/presentation/widgets/patient_intake_dialog.dart';
import 'package:empos/features/clinic/presentation/widgets/doctor_attachments_lightbox.dart';
import 'package:empos/features/pos/presentation/widgets/restaurant_table_map_widget.dart';
import 'package:empos/features/pos/presentation/pages/kitchen_display_system_page.dart';

class MockClinicBloc extends Mock implements ClinicBloc {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      const CheckInPatientEvent(
        patientId: 'pat_test',
        patientName: 'Test Patient',
        doctorName: 'usr_doctor',
        chiefComplaint: 'Checkup',
      ),
    );
  });

  group('V1.1.0 High Impact UI Tests', () {
    testWidgets('PatientIntakeDialog renders age, phone, doctor dropdown, and dispatches CheckInPatientEvent with exact seeded doctor ID', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final mockClinicBloc = MockClinicBloc();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: PatientIntakeDialog(
              bloc: mockClinicBloc,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify UI elements
      expect(find.text('Patient Intake & Check-In'), findsOneWidget);
      expect(find.text('Patient Full Name *'), findsOneWidget);
      expect(find.text('Age (Years)'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Assigned Doctor / Practitioner *'), findsOneWidget);

      // Enter details
      await tester.enterText(find.widgetWithText(TextField, 'Patient Full Name *'), 'Alexander Pierce');
      await tester.enterText(find.widgetWithText(TextField, 'Age (Years)'), '42');
      await tester.enterText(find.widgetWithText(TextField, 'Phone Number'), '+201099887766');
      await tester.enterText(find.widgetWithText(TextField, 'Chief Complaint / Reason for Visit'), 'Severe molar pain');
      await tester.pump();

      // Click Check In Patient
      await tester.tap(find.text('Check In Patient'));
      await tester.pump();

      // Verify CheckInPatientEvent was dispatched with doctorName == 'usr_doctor'
      verify(() => mockClinicBloc.add(any(that: isA<CheckInPatientEvent>().having(
            (CheckInPatientEvent e) => e.doctorName,
            'doctorName',
            equals('usr_doctor'),
          ).having(
            (CheckInPatientEvent e) => e.patientName,
            'patientName',
            equals('Alexander Pierce'),
          )))).called(1);
    });

    testWidgets('RestaurantTableMapWidget renders 2D canvas, sections, and triggers onTableSelected', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      RestaurantTable? selectedTable;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 700,
              child: RestaurantTableMapWidget(
                onTableSelected: (t) => selectedTable = t,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header & Legend
      expect(find.text('Restaurant Visual Floor Plan'), findsOneWidget);
      expect(find.text('Main Dining'), findsOneWidget);
      expect(find.text('Patio & Terrace'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
      expect(find.text('Occupied'), findsOneWidget);

      // Verify Tables on canvas
      expect(find.text('Table 1'), findsOneWidget);
      expect(find.text('Table 2'), findsOneWidget);
      expect(find.text('Booth 5'), findsOneWidget);

      // Tap Table 1
      await tester.tap(find.text('Table 1'));
      await tester.pump();

      expect(selectedTable, isNotNull);
      expect(selectedTable!.label, equals('Table 1'));
    });

    testWidgets('KitchenDisplaySystemPage renders order rail and advances ticket statuses', (tester) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: KitchenDisplaySystemPage(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Header
      expect(find.text('Kitchen Display System (KDS)'), findsOneWidget);
      expect(find.text('NEW ORDERS'), findsOneWidget);
      expect(find.text('IN PREPARATION'), findsOneWidget);
      expect(find.text('READY FOR EXPO'), findsOneWidget);

      // Verify ticket items
      expect(find.text('#101'), findsOneWidget);
      expect(find.text('Double Cheeseburger'), findsOneWidget);

      // Tap 'Start Cook' on ticket #101
      expect(find.text('Start Cook'), findsOneWidget);
      await tester.tap(find.text('Start Cook'));
      await tester.pumpAndSettle();

      // Ticket should now have 'Mark Ready'
      expect(find.text('Mark Ready'), findsAtLeastNWidgets(1));
    });

    testWidgets('DoctorAttachmentsLightbox renders thumbnails, allows adding attachments, and opens radiograph lightbox', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: DoctorAttachmentsLightbox(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Dock Title
      expect(find.text('Medical Imaging & Attachments Dock'), findsOneWidget);
      expect(find.text('Attach X-Ray / DICOM'), findsOneWidget);

      // Verify Seeded Thumbnails
      expect(find.text('Periapical X-Ray Tooth #19 & #20'), findsOneWidget);
      expect(find.text('Panoramic OPG Radiograph Scan'), findsOneWidget);

      // Click on thumbnail to open Lightbox
      await tester.tap(find.text('Periapical X-Ray Tooth #19 & #20'));
      await tester.pumpAndSettle();

      // Verify Lightbox Viewer is opened
      expect(find.text('Digital Radiograph / DICOM Lightbox Viewer • 4.2 MB'), findsOneWidget);
      expect(find.textContaining('Shows deep radiolucency on distal root apex'), findsOneWidget);

      // Close Lightbox
      await tester.tap(find.byIcon(LucideIcons.x).first);
      await tester.pumpAndSettle();

      // Tap 'Attach X-Ray / DICOM'
      await tester.tap(find.text('Attach X-Ray / DICOM'));
      await tester.pumpAndSettle();

      // Submit upload dialog
      expect(find.text('Attach to Patient File'), findsOneWidget);
      await tester.tap(find.text('Attach to Patient File'));
      await tester.pumpAndSettle();

      // Verify new attachment was added to dock
      expect(find.text('Bite-Wing Radiograph #4'), findsOneWidget);
    });
  });
}
