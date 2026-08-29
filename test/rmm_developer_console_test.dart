import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/network/lan_sync/domain/entities/connected_node.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import 'package:empos/features/rmm/data/repositories/rmm_repository_impl.dart';
import 'package:empos/features/rmm/domain/entities/fleet_node.dart';
import 'package:empos/features/rmm/domain/repositories/rmm_repository.dart';
import 'package:empos/features/rmm/presentation/pages/developer_console_page.dart';

class MockLanSyncRepository extends Mock implements LanSyncRepository {}
class MockRmmRepository extends Mock implements RmmRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      SyncEnvelope.create(
        type: 'test',
        scope: 'test',
        senderId: 'test',
        senderRole: 'admin',
      ),
    );
  });

  group('FleetNode Domain Entity Tests', () {
    test('FleetNode copyWith and status checks', () {
      final node = FleetNode(
        id: 'node_1',
        branchName: 'Branch North',
        ipAddress: '192.168.1.50',
        role: 'cashier',
        status: FleetNodeStatus.online,
        lastHeartbeat: DateTime.now(),
        latencyMs: 15,
      );

      expect(node.isOnline, isTrue);
      expect(node.isOffline, isFalse);
      expect(node.isSyncing, isFalse);

      final updated = node.copyWith(status: FleetNodeStatus.syncing, latencyMs: 25);
      expect(updated.isSyncing, isTrue);
      expect(updated.latencyMs, 25);
    });

    test('FleetNode JSON serialization and deserialization', () {
      final json = {
        'id': 'node_json',
        'branchName': 'Downtown Store',
        'ipAddress': '10.0.0.5',
        'role': 'doctor',
        'status': 'syncing',
        'lastHeartbeat': '2026-08-29T12:00:00.000Z',
        'latencyMs': 18,
      };

      final node = FleetNode.fromJson(json);
      expect(node.id, 'node_json');
      expect(node.role, 'doctor');
      expect(node.status, FleetNodeStatus.syncing);
      expect(node.latencyMs, 18);

      final output = node.toJson();
      expect(output['id'], 'node_json');
      expect(output['status'], 'syncing');
    });
  });

  group('RmmRepositoryImpl Data Layer Tests', () {
    late MockLanSyncRepository mockLanRepo;
    late StreamController<List<ConnectedNode>> connectedNodesController;
    late RmmRepositoryImpl repo;

    setUp(() {
      mockLanRepo = MockLanSyncRepository();
      connectedNodesController = StreamController<List<ConnectedNode>>.broadcast();
      when(() => mockLanRepo.connectedNodesStream).thenAnswer((_) => connectedNodesController.stream);
      when(() => mockLanRepo.broadcast(any())).thenAnswer((_) async {});

      repo = RmmRepositoryImpl(lanSyncRepository: mockLanRepo);
    });

    tearDown(() {
      repo.dispose();
      connectedNodesController.close();
    });

    test('Initializes with default host hub node', () {
      expect(repo.currentNodes.length, 1);
      expect(repo.currentNodes.first.id, 'node_main_hub');
      expect(repo.currentNodes.first.isOnline, isTrue);
    });

    test('Dynamically maps connected LAN sync peers into fleet nodes stream', () async {
      final peers = [
        ConnectedNode(id: 'peer_station_2', role: 'cashier', ipAddress: '192.168.1.102'),
        ConnectedNode(id: 'peer_station_3', role: 'doctor', ipAddress: '192.168.1.103'),
      ];

      connectedNodesController.add(peers);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(repo.currentNodes.length, 3);
      expect(repo.currentNodes.any((n) => n.id == 'peer_station_2'), isTrue);
      expect(repo.currentNodes.any((n) => n.id == 'peer_station_3'), isTrue);
    });

    test('sendRemoteCommand broadcasts system envelope via LAN sync', () async {
      await repo.sendRemoteCommand('node_main_hub', 'cache.flush');
      verify(() => mockLanRepo.broadcast(any(
        that: predicate<SyncEnvelope>((env) =>
            env.type == 'rmm.command' &&
            env.payload?['command'] == 'cache.flush'),
      ))).called(1);
    });

    test('pushSoftwareUpdate broadcasts OTA version envelope', () async {
      await repo.pushSoftwareUpdate('v3.0.0-PROD');
      verify(() => mockLanRepo.broadcast(any(
        that: predicate<SyncEnvelope>((env) =>
            env.type == 'rmm.software_update' &&
            env.payload?['version'] == 'v3.0.0-PROD'),
      ))).called(1);
    });

    test('pingNode updates node heartbeat and latency', () async {
      final ms = await repo.pingNode('node_main_hub');
      expect(ms, greaterThanOrEqualTo(4));
      expect(repo.currentNodes.first.latencyMs, ms);
    });
  });

  group('DeveloperConsolePage Widget Tests', () {
    late MockRmmRepository mockRmmRepo;
    late StreamController<List<FleetNode>> nodesController;

    setUp(() {
      mockRmmRepo = MockRmmRepository();
      nodesController = StreamController<List<FleetNode>>.broadcast();

      final initialNodes = [
        FleetNode(
          id: 'node_hub',
          branchName: 'Main Store / Hub',
          ipAddress: '192.168.1.100',
          role: 'Host Gateway',
          status: FleetNodeStatus.online,
          lastHeartbeat: DateTime.now(),
          latencyMs: 3,
        ),
        FleetNode(
          id: 'node_cashier_1',
          branchName: 'Front Register 1',
          ipAddress: '192.168.1.105',
          role: 'cashier',
          status: FleetNodeStatus.online,
          lastHeartbeat: DateTime.now(),
          latencyMs: 14,
        ),
      ];

      when(() => mockRmmRepo.currentNodes).thenReturn(initialNodes);
      when(() => mockRmmRepo.fleetNodesStream).thenAnswer((_) => nodesController.stream);
      when(() => mockRmmRepo.sendRemoteCommand(any(), any())).thenAnswer((_) async {});
      when(() => mockRmmRepo.pushSoftwareUpdate(any())).thenAnswer((_) async {});
      when(() => mockRmmRepo.pingNode(any())).thenAnswer((_) async => 8);
      when(() => mockRmmRepo.forceDbSync(any())).thenAnswer((_) async {});
      when(() => mockRmmRepo.restartNode(any())).thenAnswer((_) async {});
    });

    tearDown(() {
      nodesController.close();
    });

    testWidgets('Renders KPI tiles, action bar, fleet table, and telemetry console', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: DeveloperConsolePage(customRepository: mockRmmRepo),
        ),
      );

      expect(find.text('RMM Fleet Developer Console'), findsOneWidget);
      expect(find.text('SUPERVISOR MODE'), findsOneWidget);
      expect(find.text('TOTAL FLEET NODES'), findsOneWidget);
      expect(find.text('ONLINE / ACTIVE'), findsOneWidget);
      expect(find.text('Broadcast Command'), findsOneWidget);
      expect(find.text('Push OTA Update'), findsOneWidget);
      expect(find.text('REGISTERED FLEET STATIONS & GATEWAYS'), findsOneWidget);
      expect(find.text('node_hub'), findsOneWidget);
      expect(find.text('node_cashier_1'), findsOneWidget);
      expect(find.text('RMM LIVE TELEMETRY & AUDIT STREAM'), findsOneWidget);
    });

    testWidgets('Clicking Ping invokes pingNode and writes to live audit stream', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: DeveloperConsolePage(customRepository: mockRmmRepo),
        ),
      );

      final pingButtons = find.text('Ping');
      expect(pingButtons, findsWidgets);
      await tester.tap(pingButtons.first);
      await tester.pump();

      verify(() => mockRmmRepo.pingNode('node_hub')).called(1);
      expect(find.textContaining('PING response from node_hub'), findsOneWidget);
    });

    testWidgets('Clicking Broadcast Command dispatches remote command', (tester) async {
      tester.view.physicalSize = const Size(1280, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        MaterialApp(
          home: DeveloperConsolePage(customRepository: mockRmmRepo),
        ),
      );

      await tester.tap(find.text('Broadcast Command'));
      await tester.pump();

      verify(() => mockRmmRepo.sendRemoteCommand('*', 'system.diagnostics.health_check')).called(1);
      expect(find.textContaining('Broadcast command dispatched: "system.diagnostics.health_check"'), findsOneWidget);
    });
  });
}
