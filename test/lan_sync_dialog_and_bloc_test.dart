import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/network/lan_sync/domain/entities/connected_node.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
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

    test('ConnectToHostEvent failure emits LanSyncConnecting then LanSyncError', () async {
      when(() => mockRepo.connectToHost('192.168.1.50', port: 9090))
          .thenThrow(Exception('Socket connection refused'));

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);

      bloc.add(const ConnectToHostEvent(hostIp: '192.168.1.50', port: 9090));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<LanSyncConnecting>(),
          isA<LanSyncError>().having((s) => s.message, 'message', contains('Socket connection refused')),
        ]),
      );

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

    setUp(() {
      mockRepo = MockLanSyncRepository();
      nodesController = StreamController<List<ConnectedNode>>.broadcast();
      when(() => mockRepo.connectedNodesStream).thenAnswer((_) => nodesController.stream);
      when(() => mockRepo.connectedNodes).thenReturn([]);
      when(() => mockRepo.isConnected).thenReturn(false);
      when(() => mockRepo.isHost).thenReturn(false);
    });

    tearDown(() {
      nodesController.close();
    });

    testWidgets('Renders offline standalone mode with start host and connect buttons', (tester) async {
      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: LanSyncDialog(),
            ),
          ),
        ),
      );

      expect(find.text('LAN Real-Time Sync Engine'), findsOneWidget);
      expect(find.text('Offline / Standalone Mode'), findsOneWidget);
      expect(find.text('Start as Host Server'), findsOneWidget);
      expect(find.text('Connect to Hub Server'), findsOneWidget);

      await bloc.close();
    });

    testWidgets('Renders Host Server mode with connected client stations and Disconnect button', (tester) async {
      when(() => mockRepo.startHostServer(port: 9090)).thenAnswer((_) async {});
      when(() => mockRepo.isConnected).thenReturn(true);
      when(() => mockRepo.isHost).thenReturn(true);
      when(() => mockRepo.connectedNodes).thenReturn([
        ConnectedNode(id: 'host-reception', role: 'Hub Host', ipAddress: '192.168.1.10'),
        ConnectedNode(id: 'doctor-station', role: 'Doctor Station', ipAddress: '192.168.1.15'),
      ]);

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);
      bloc.add(const StartHostServerEvent(port: 9090));
      await bloc.stream.firstWhere((s) => s is LanSyncConnected);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: LanSyncDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Hub Server Active'), findsOneWidget);
      expect(find.textContaining('Connected Client Stations (1)'), findsOneWidget);
      expect(find.text('doctor-station'), findsOneWidget);
      expect(find.text('Doctor Station'), findsOneWidget);
      expect(find.text('Stop Server'), findsOneWidget);

      await bloc.close();
    });

    testWidgets('Renders Client mode with Station Connected and network nodes', (tester) async {
      when(() => mockRepo.connectToHost('192.168.1.10', port: 9090)).thenAnswer((_) async {});
      when(() => mockRepo.isConnected).thenReturn(true);
      when(() => mockRepo.isHost).thenReturn(false);
      when(() => mockRepo.connectedNodes).thenReturn([
        ConnectedNode(id: 'reception-host', role: 'Hub Host', ipAddress: '192.168.1.10'),
        ConnectedNode(id: 'doctor', role: 'Doctor Station', ipAddress: '192.168.1.15'),
      ]);

      final bloc = LanSyncBloc(lanSyncRepository: mockRepo);
      bloc.add(const ConnectToHostEvent(hostIp: '192.168.1.10', port: 9090));
      await bloc.stream.firstWhere((s) => s is LanSyncConnected);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: bloc,
              child: LanSyncDialog(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Station Connected to 192.168.1.10:9090'), findsOneWidget);
      expect(find.textContaining('Connected Stations in Network (2)'), findsOneWidget);
      expect(find.text('reception-host'), findsOneWidget);
      expect(find.text('doctor'), findsOneWidget);
      expect(find.text('Disconnect'), findsOneWidget);

      await bloc.close();
    });
  });
}
