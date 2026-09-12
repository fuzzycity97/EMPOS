import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/network/lan_sync/domain/entities/connected_node.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import 'package:empos/core/network/lan_sync/data/services/lan_discovery_service.dart';
import 'package:empos/core/network/lan_sync/presentation/bloc/lan_sync_bloc.dart';
import 'package:empos/core/network/lan_sync/presentation/bloc/lan_sync_event.dart';
import 'package:empos/core/network/lan_sync/presentation/bloc/lan_sync_state.dart';
import 'package:empos/core/network/lan_sync/presentation/widgets/lan_sync_dialog.dart';

class MockLanSyncRepository extends Mock implements LanSyncRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SyncEnvelope.create(
        type: 'test.route',
        senderId: 'test-id',
        senderRole: 'test-role',
      ),
    );
  });

  group('LanSyncBloc Unit Tests', () {
    late MockLanSyncRepository mockRepo;
    late StreamController<List<ConnectedNode>> nodesController;

    setUp(() {
      mockRepo = MockLanSyncRepository();
      nodesController = StreamController<List<ConnectedNode>>.broadcast();
      when(() => mockRepo.connectedNodesStream).thenAnswer((_) => nodesController.stream);
      when(() => mockRepo.connectedNodes).thenReturn([]);
      when(() => mockRepo.isConnected).thenReturn(false);
      when(() => mockRepo.isHost).thenReturn(false);
      when(() => mockRepo.discoveredHostsStream).thenAnswer((_) => const Stream.empty());
      when(() => mockRepo.discoveredHosts).thenReturn([]);
      when(() => mockRepo.startDiscoveryScanner()).thenReturn(null);
      when(() => mockRepo.stopDiscoveryScanner()).thenReturn(null);
    });

    tearDown(() {
      nodesController.close();
    });

    test('StartHostServerEvent transitions to LanSyncConnecting then LanSyncConnected with host info', () async {
      when(() => mockRepo.startHostServer(port: 9090)).thenAnswer((_) async {});
      when(() => mockRepo.isConnected).thenReturn(true);
      when(() => mockRepo.isHost).thenReturn(true);
      when(() => mockRepo.connectedNodes).thenReturn([
        ConnectedNode(id: 'receptionist', role: 'Hub Host (Reception Desk)', ipAddress: '192.168.1.10'),
      ]);

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);

      expect(bloc.state, isA<LanSyncInitial>());

      bloc.add(const StartHostServerEvent(port: 9090));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LanSyncConnecting>(),
          isA<LanSyncConnected>().having((s) => s.isHost, 'isHost', true),
        ]),
      );

      await bloc.close();
    });

    test('ConnectToHostEvent failure emits LanSyncConnecting then LanSyncError with failedIp', () async {
      when(() => mockRepo.connectToHost('192.168.1.50', port: 9090))
          .thenThrow(Exception('Socket connection refused'));

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);

      bloc.add(const ConnectToHostEvent(hostIp: '192.168.1.50', port: 9090));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LanSyncConnecting>(),
          isA<LanSyncError>()
              .having((s) => s.message, 'message', contains('Socket connection refused'))
              .having((s) => s.failedIp, 'failedIp', '192.168.1.50'),
        ]),
      );

      // Verify that connectedNodes update does NOT erase LanSyncError
      nodesController.add([]);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(bloc.state, isA<LanSyncError>());

      await bloc.close();
    });

    test('DisconnectLanSyncEvent dispatches repo disconnect and emits LanSyncDisconnected', () async {
      when(() => mockRepo.disconnect()).thenAnswer((_) async {});

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);
      bloc.add(const DisconnectLanSyncEvent());

      await expectLater(
        bloc.stream,
        emits(isA<LanSyncDisconnected>()),
      );

      verify(() => mockRepo.disconnect()).called(1);
      await bloc.close();
    });
  });

  group('LanSyncDialog Widget Presentation Tests', () {
    late MockLanSyncRepository mockRepo;
    late StreamController<List<ConnectedNode>> nodesController;
    late StreamController<List<DiscoveredHost>> discoveryController;

    setUp(() {
      mockRepo = MockLanSyncRepository();
      nodesController = StreamController<List<ConnectedNode>>.broadcast();
      discoveryController = StreamController<List<DiscoveredHost>>.broadcast();
      when(() => mockRepo.connectedNodesStream).thenAnswer((_) => nodesController.stream);
      when(() => mockRepo.connectedNodes).thenReturn([]);
      when(() => mockRepo.isConnected).thenReturn(false);
      when(() => mockRepo.isHost).thenReturn(false);
      when(() => mockRepo.discoveredHostsStream).thenAnswer((_) => discoveryController.stream);
      when(() => mockRepo.discoveredHosts).thenReturn([]);
      when(() => mockRepo.startDiscoveryScanner()).thenReturn(null);
      when(() => mockRepo.stopDiscoveryScanner()).thenReturn(null);
    });

    tearDown(() {
      nodesController.close();
      discoveryController.close();
    });

    testWidgets('Renders offline standalone mode with start host, auto-discovery scanner and connect buttons', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: const LanSyncDialog(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('LAN Real-Time Sync Engine'), findsOneWidget);
      expect(find.text('Offline / Standalone Mode'), findsOneWidget);
      expect(find.text('Start as Host Server'), findsOneWidget);
      expect(find.textContaining('Auto-Discovered LAN Servers'), findsOneWidget);
      expect(find.text('Connect to Hub Server'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async => await bloc.close());
    });

    testWidgets('Renders diagnostic error card with troubleshooting checklist when LanSyncError occurs', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockRepo.connectToHost('192.168.1.99', port: 9090))
          .thenThrow(Exception('No EMPOS Host Server found at 192.168.1.99:9090.'));

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);
      bloc.add(const ConnectToHostEvent(hostIp: '192.168.1.99', port: 9090));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: const LanSyncDialog(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Cannot Reach Server (192.168.1.99)'), findsOneWidget);
      expect(find.text('Diagnostic Troubleshooting Checklist:'), findsOneWidget);
      expect(find.text('Retry Connection'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async => await bloc.close());
    });

    testWidgets('Renders discovered LAN servers and auto-populates on 1-Tap Connect', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockRepo.discoveredHosts).thenReturn([
        DiscoveredHost(
          id: 'reception-host',
          role: 'Hub Host',
          ip: '192.168.1.42',
          port: 9090,
          lastSeen: DateTime.now(),
        ),
      ]);
      when(() => mockRepo.connectToHost('192.168.1.42', port: 9090)).thenAnswer((_) async {});

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: const LanSyncDialog(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('reception-host'), findsOneWidget);
      expect(find.text('1-Tap Connect'), findsOneWidget);

      await tester.tap(find.text('1-Tap Connect'));
      await tester.pump();

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async => await bloc.close());
    });

    testWidgets('Renders Host Server mode with connected client stations and Disconnect button', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockRepo.startHostServer(port: 9090)).thenAnswer((_) async {});
      when(() => mockRepo.isConnected).thenReturn(true);
      when(() => mockRepo.isHost).thenReturn(true);
      when(() => mockRepo.connectedNodes).thenReturn([
        ConnectedNode(id: 'host-reception', role: 'Hub Host', ipAddress: '192.168.1.10'),
        ConnectedNode(id: 'doctor-station', role: 'Doctor Station', ipAddress: '192.168.1.15'),
      ]);

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);
      bloc.add(const StartHostServerEvent(port: 9090));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: const LanSyncDialog(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Hub Server Active'), findsOneWidget);
      expect(find.textContaining('Connected Client Stations (1)'), findsOneWidget);
      expect(find.text('doctor-station'), findsOneWidget);
      expect(find.text('Doctor Station'), findsOneWidget);
      expect(find.text('Stop Server'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async => await bloc.close());
    });

    testWidgets('Renders Client mode with Station Connected and network nodes', (tester) async {
      tester.view.physicalSize = const Size(1280, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      when(() => mockRepo.connectToHost('192.168.1.10', port: 9090)).thenAnswer((_) async {});
      when(() => mockRepo.isConnected).thenReturn(true);
      when(() => mockRepo.isHost).thenReturn(false);
      when(() => mockRepo.connectedNodes).thenReturn([
        ConnectedNode(id: 'reception-host', role: 'Hub Host', ipAddress: '192.168.1.10'),
        ConnectedNode(id: 'doctor', role: 'Doctor Station', ipAddress: '192.168.1.15'),
      ]);

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);
      bloc.add(const ConnectToHostEvent(hostIp: '192.168.1.10', port: 9090));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: const LanSyncDialog(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.textContaining('Station Connected to 192.168.1.10:9090'), findsOneWidget);
      expect(find.textContaining('Connected Stations in Network (2)'), findsOneWidget);
      expect(find.text('reception-host'), findsOneWidget);
      expect(find.text('doctor'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async => await bloc.close());
    });
  });
}
