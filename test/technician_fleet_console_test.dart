import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:empos/core/network/lan_sync/domain/entities/connected_node.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import 'package:empos/core/network/lan_sync/presentation/bloc/lan_sync_bloc.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/core/config/domain/entities/store_blueprint.dart';
import 'package:empos/core/config/data/models/store_blueprint_model.dart';
import 'package:empos/core/config/presentation/bloc/config_bloc.dart';
import 'package:empos/core/config/presentation/bloc/config_state.dart';
import 'package:empos/core/config/presentation/bloc/config_event.dart';
import 'package:empos/core/config/domain/usecases/load_store_blueprint_usecase.dart';
import 'package:empos/core/config/domain/usecases/save_store_blueprint_usecase.dart';
import 'package:empos/core/config/domain/usecases/get_feature_toggle_usecase.dart';
import 'package:empos/features/rmm/presentation/pages/technician_fleet_console_page.dart';

class MockLanSyncRepository extends Mock implements LanSyncRepository {}
class MockLoadStoreBlueprintUseCase extends Mock implements LoadStoreBlueprintUseCase {}
class MockSaveStoreBlueprintUseCase extends Mock implements SaveStoreBlueprintUseCase {}
class MockGetFeatureToggleUseCase extends Mock implements GetFeatureToggleUseCase {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SyncEnvelope.create(
        type: 'test',
        scope: 'test',
        senderId: 'test',
        senderRole: 'technician',
      ),
    );
    registerFallbackValue(
      const StoreBlueprint(storeName: 'fallback_store'),
    );
  });

  group('ConnectedNode appName & Fleet Inspection Tests', () {
    test('ConnectedNode infers and serializes appName correctly', () {
      final docNode = ConnectedNode(
        id: 'station_doc_1',
        role: 'doctor',
        ipAddress: '192.168.1.101',
        connectedAt: DateTime.now(),
      );
      expect(docNode.appName, equals('EMPOS Clinical / Dental Suite'));

      final posNode = ConnectedNode(
        id: 'station_pos_1',
        role: 'pos',
        ipAddress: '192.168.1.102',
        connectedAt: DateTime.now(),
      );
      expect(posNode.appName, equals('EMPOS Retail POS Register'));

      final receptNode = ConnectedNode(
        id: 'station_rec_1',
        role: 'receptionist',
        ipAddress: '192.168.1.103',
        connectedAt: DateTime.now(),
      );
      expect(receptNode.appName, equals('EMPOS Reception & Queue Desk'));

      final json = docNode.toJson();
      expect(json['appName'], equals('EMPOS Clinical / Dental Suite'));

      final fromJson = ConnectedNode.fromJson(json);
      expect(fromJson.appName, equals('EMPOS Clinical / Dental Suite'));
    });
  });

  group('TechnicianFleetConsolePage Widget & Remote Deployment Tests', () {
    late MockLanSyncRepository mockLanSyncRepo;
    late MockLoadStoreBlueprintUseCase mockLoadUseCase;
    late MockSaveStoreBlueprintUseCase mockSaveUseCase;
    late MockGetFeatureToggleUseCase mockGetToggleUseCase;
    late StreamController<List<ConnectedNode>> connectedNodesController;
    late StreamController<SyncEnvelope> incomingEventsController;
    late LanSyncBloc lanSyncBloc;

    final baseBlueprint = StoreBlueprint(
      storeName: 'Main Medical Center',
      industryType: IndustryType.medical,
      themeColorHex: '#0D9488',
      toggles: const {
        'sw.box_and_strip_selling': true,
        'sw.dental_tooth_chart_editor': false,
        'sw.dental_3d_odontogram': false,
      },
    );

    setUp(() {
      mockLanSyncRepo = MockLanSyncRepository();
      mockLoadUseCase = MockLoadStoreBlueprintUseCase();
      mockSaveUseCase = MockSaveStoreBlueprintUseCase();
      mockGetToggleUseCase = MockGetFeatureToggleUseCase();
      connectedNodesController = StreamController<List<ConnectedNode>>.broadcast();
      incomingEventsController = StreamController<SyncEnvelope>.broadcast();

      when(() => mockLanSyncRepo.connectedNodesStream)
          .thenAnswer((_) => connectedNodesController.stream);
      when(() => mockLanSyncRepo.incomingEvents)
          .thenAnswer((_) => incomingEventsController.stream);
      when(() => mockLanSyncRepo.isHost).thenReturn(false);
      when(() => mockLanSyncRepo.isConnected).thenReturn(false);
      when(() => mockLanSyncRepo.connectedNodes).thenReturn([]);
      when(() => mockLanSyncRepo.broadcast(any())).thenAnswer((_) async {});

      when(() => mockLoadUseCase()).thenAnswer((_) async => Right(baseBlueprint));
      when(() => mockSaveUseCase(any())).thenAnswer((_) async => const Right(null));

      lanSyncBloc = LanSyncBloc(lanSyncRepository: mockLanSyncRepo);
    });

    tearDown(() {
      connectedNodesController.close();
      incomingEventsController.close();
      lanSyncBloc.close();
    });

    testWidgets('Renders Technician Console with Server Connect Bar and Fleet Nodes', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final configBloc = ConfigBloc(
        loadStoreBlueprintUseCase: mockLoadUseCase,
        saveStoreBlueprintUseCase: mockSaveUseCase,
        getFeatureToggleUseCase: mockGetToggleUseCase,
        lanSyncRepository: mockLanSyncRepo,
      );
      addTearDown(configBloc.close);

      configBloc.add(const LoadConfigEvent());

      final nodes = [
        ConnectedNode(
          id: 'station_clinic_doctor',
          role: 'doctor',
          ipAddress: '192.168.1.150',
          connectedAt: DateTime.now(),
          appName: 'EMPOS Clinical / Dental Suite',
        ),
      ];

      when(() => mockLanSyncRepo.connectedNodes).thenReturn(nodes);

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ConfigBloc>.value(value: configBloc),
              BlocProvider<LanSyncBloc>.value(value: lanSyncBloc),
            ],
            child: TechnicianFleetConsolePage(customRepository: mockLanSyncRepo),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify header & server connection bar
      expect(find.text('GOD MODE'), findsOneWidget);
      expect(find.text('Technician Fleet & Provisioning Hub'), findsOneWidget);
      expect(find.text('Connect as Client'), findsOneWidget);

      // Verify discovered fleet devices
      expect(find.textContaining('EMPOS Clinical / Dental Suite'), findsWidgets);
      expect(find.textContaining('192.168.1.150'), findsWidgets);

      // Verify Switchboard
      expect(find.text('Deploy & Save to Station'), findsOneWidget);
      expect(find.text('Dental Tooth Chart Editor'), findsWidgets);
      expect(find.text('3D ANATOMY'), findsWidgets);
    });

    testWidgets('Tapping Deploy on This Station saves to local ConfigBloc', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final configBloc = ConfigBloc(
        loadStoreBlueprintUseCase: mockLoadUseCase,
        saveStoreBlueprintUseCase: mockSaveUseCase,
        getFeatureToggleUseCase: mockGetToggleUseCase,
        lanSyncRepository: mockLanSyncRepo,
      );
      addTearDown(configBloc.close);

      configBloc.add(const LoadConfigEvent());

      SyncEnvelope? sentEnvelope;
      when(() => mockLanSyncRepo.broadcast(any())).thenAnswer((inv) async {
        sentEnvelope = inv.positionalArguments[0] as SyncEnvelope;
      });

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<ConfigBloc>.value(value: configBloc),
              BlocProvider<LanSyncBloc>.value(value: lanSyncBloc),
            ],
            child: TechnicianFleetConsolePage(customRepository: mockLanSyncRepo),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Click Deploy on This Station (Local Terminal)
      final deployBtn = find.text('Deploy & Save to Station');
      expect(deployBtn, findsOneWidget);
      await tester.tap(deployBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Verify broadcast was triggered
      expect(sentEnvelope, isNotNull);
      expect(sentEnvelope!.type, equals('CONFIG_UPDATE'));

      // Verify banner feedback shows local save confirmation
      expect(find.textContaining('Settings saved & refreshed successfully on this machine'), findsOneWidget);
    });

    test('Remote station ConfigBloc receives CONFIG_UPDATE and updates locally without technician remaining connected', () async {
      final targetConfigBloc = ConfigBloc(
        loadStoreBlueprintUseCase: mockLoadUseCase,
        saveStoreBlueprintUseCase: mockSaveUseCase,
        getFeatureToggleUseCase: mockGetToggleUseCase,
        lanSyncRepository: mockLanSyncRepo,
      );

      // Simulate initial load
      targetConfigBloc.add(const LoadConfigEvent());
      await Future.delayed(const Duration(milliseconds: 50));

      final updatedBp = baseBlueprint.copyWith(
        toggles: {
          'sw.dental_tooth_chart_editor': true,
          'sw.dental_3d_odontogram': true,
        },
      );

      // Simulate incoming LAN sync envelope sent by technician
      final envelope = SyncEnvelope.create(
        type: 'CONFIG_UPDATE',
        scope: 'global',
        senderId: 'technician_laptop_station',
        senderRole: 'technician',
        payload: {
          'targetStationId': 'all',
          'blueprint': StoreBlueprintModel.fromEntity(updatedBp).toJson(),
        },
      );

      incomingEventsController.add(envelope);
      await Future.delayed(const Duration(milliseconds: 100));

      // Target machine's ConfigBloc should have processed it and updated state
      expect(targetConfigBloc.state, isA<ConfigLoaded>());
      final loadedState = targetConfigBloc.state as ConfigLoaded;
      expect(loadedState.blueprint.isEnabled('sw.dental_tooth_chart_editor'), isTrue);
      expect(loadedState.blueprint.isEnabled('sw.dental_3d_odontogram'), isTrue);

      // Verify save was called to persist locally to Hive
      verify(() => mockSaveUseCase(any())).called(greaterThanOrEqualTo(1));

      await targetConfigBloc.close();
    });
  });
}
