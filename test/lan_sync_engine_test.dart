import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/domain/entities/connected_node.dart';
import 'package:empos/core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import 'package:empos/core/network/lan_sync/data/message_routes.dart';
import 'package:empos/core/network/lan_sync/data/repositories/lan_sync_repository_impl.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('empos_lan_engine_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Legacy C# SyncEnvelope Entity Tests', () {
    test('Serializes to and from JSON matching legacy C# schema', () {
      final envelope = SyncEnvelope.create(
        type: MessageRoutes.patientCheckedIn,
        scope: 'clinic',
        senderId: 'reception-desk-01',
        senderRole: 'receptionist',
        payload: {
          'patientId': 'pat-123',
          'patientName': 'Sarah Connor',
          'queueNumber': 4,
          'chiefComplaint': 'Routine dental checkup',
        },
      );

      final json = envelope.toJson();
      expect(json['type'], MessageRoutes.patientCheckedIn);
      expect(json['scope'], 'clinic');
      expect(json['senderId'], 'reception-desk-01');
      expect(json['senderRole'], 'receptionist');
      expect(json['ts'], isA<int>());
      expect(json['payload']['patientName'], 'Sarah Connor');

      final deserialized = SyncEnvelope.fromJson(json);
      expect(deserialized.type, envelope.type);
      expect(deserialized.scope, envelope.scope);
      expect(deserialized.senderId, envelope.senderId);
      expect(deserialized.senderRole, envelope.senderRole);
      expect(deserialized.ts, envelope.ts);
      expect(deserialized.payload?['patientName'], 'Sarah Connor');
    });

    test('ConnectedNode serializes correctly', () {
      final node = ConnectedNode(
        id: 'node-doctor-01',
        role: 'doctor_station',
        ipAddress: '192.168.1.15',
      );

      final json = node.toJson();
      expect(json['id'], 'node-doctor-01');
      expect(json['role'], 'doctor_station');
      expect(json['ipAddress'], '192.168.1.15');

      final fromJson = ConnectedNode.fromJson(json);
      expect(fromJson.id, node.id);
      expect(fromJson.role, node.role);
      expect(fromJson.ipAddress, node.ipAddress);
    });

    test('MessageRoutes validates legacy event types', () {
      expect(MessageRoutes.isValidRoute(MessageRoutes.patientCheckedIn), isTrue);
      expect(MessageRoutes.isValidRoute(MessageRoutes.visitCompleted), isTrue);
      expect(MessageRoutes.isValidRoute(MessageRoutes.saleCompleted), isTrue);
      expect(MessageRoutes.isValidRoute(MessageRoutes.toothChartUpdated), isTrue);
      expect(MessageRoutes.isValidRoute('unknown.invalid.route'), isFalse);
    });
  });

  group('LanSyncRepository WebSocket Sync Engine Tests', () {
    late LanSyncRepository hostRepo;
    late LanSyncRepository clientRepo;

    setUp(() {
      hostRepo = LanSyncRepositoryImpl();
      clientRepo = LanSyncRepositoryImpl();
    });

    tearDown(() async {
      await clientRepo.disconnect();
      await hostRepo.disconnect();
    });

    test('Host starts WebSocket server and accepts client connection with bidirectional messaging', () async {
      const testPort = 9876;

      // 1. Host starts server
      await hostRepo.startHostServer(port: testPort);
      expect(hostRepo.isHost, isTrue);
      expect(hostRepo.isConnected, isTrue);

      // 2. Client connects to Host
      final clientReceivedEvents = <SyncEnvelope>[];
      final clientSub = clientRepo.incomingEvents.listen(clientReceivedEvents.add);

      final hostReceivedEvents = <SyncEnvelope>[];
      final hostSub = hostRepo.incomingEvents.listen(hostReceivedEvents.add);

      await clientRepo.connectToHost('127.0.0.1', port: testPort);
      expect(clientRepo.isHost, isFalse);
      expect(clientRepo.isConnected, isTrue);

      // Wait briefly for handshake
      await Future.delayed(const Duration(milliseconds: 100));

      // 3. Host broadcasts event
      final doctorEvent = SyncEnvelope.create(
        type: MessageRoutes.visitCompleted,
        senderId: 'doctor-station-01',
        senderRole: 'doctor',
        payload: {
          'visitId': 'vis-999',
          'diagnosis': 'Gingivitis Mild',
          'fee': 450.0,
        },
      );

      await hostRepo.broadcast(doctorEvent);

      // Wait for network propagation
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert client received the broadcasted event
      expect(clientReceivedEvents.any((e) => e.type == MessageRoutes.visitCompleted), isTrue);
      final received = clientReceivedEvents.firstWhere((e) => e.type == MessageRoutes.visitCompleted);
      expect(received.payload?['diagnosis'], 'Gingivitis Mild');
      expect(received.payload?['fee'], 450.0);

      // 4. Client sends event to Host
      final paymentEvent = SyncEnvelope.create(
        type: MessageRoutes.saleCompleted,
        senderId: 'cashier-station-01',
        senderRole: 'cashier',
        payload: {
          'orderId': 'ord-777',
          'amountPaid': 450.0,
          'method': 'cash',
        },
      );

      await clientRepo.broadcast(paymentEvent);
      await Future.delayed(const Duration(milliseconds: 200));

      expect(hostReceivedEvents.any((e) => e.type == MessageRoutes.saleCompleted), isTrue);
      final hostReceived = hostReceivedEvents.firstWhere((e) => e.type == MessageRoutes.saleCompleted);
      expect(hostReceived.payload?['orderId'], 'ord-777');

      await clientSub.cancel();
      await hostSub.cancel();
    });
  });
}
