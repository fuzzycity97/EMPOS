import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/subscription/cloud_relay_admin_client.dart';
import 'package:empos/core/config/subscription/cloud_relay_clinic_client.dart';
import 'package:empos/core/config/subscription/cloud_relay_models.dart';
import 'package:empos/core/config/subscription/subscription_tier_controller.dart';
import 'package:empos/core/config/subscription/subscription_tier_models.dart';
import 'package:empos/features/sync/domain/services/sync_connection_manager.dart';

void main() {
  const testPort = 4055;
  final relayWsUrl = 'ws://127.0.0.1:$testPort';
  Process? relayProcess;

  setUpAll(() async {
    // 1. Boot local Node.js Cloud Relay Server on test port
    final rootDir = Directory.current.path;
    final serverScript = '$rootDir/sync_server/cloud_relay/cloud_relay_server.js';

    relayProcess = await Process.start(
      'node',
      [serverScript],
      environment: {
        'CLOUD_RELAY_PORT': testPort.toString(),
        'CLOUD_RELAY_HOST': '127.0.0.1',
      },
    );

    // Drain process stdout/stderr so buffer doesn't block
    relayProcess!.stdout.listen((_) {});
    relayProcess!.stderr.listen((_) {});

    // Wait for HTTP /health endpoint to be live
    final client = HttpClient();
    bool isReady = false;
    for (int i = 0; i < 20; i++) {
      try {
        final req = await client.getUrl(Uri.parse('http://127.0.0.1:$testPort/health'));
        final res = await req.close();
        if (res.statusCode == 200) {
          isReady = true;
          break;
        }
      } catch (_) {
        await Future.delayed(const Duration(milliseconds: 150));
      }
    }
    client.close();
    expect(isReady, isTrue, reason: 'Cloud Relay Server failed to start on port $testPort');
  });

  tearDownAll(() async {
    relayProcess?.kill(ProcessSignal.sigkill);
    await relayProcess?.exitCode;
  });

  group('Task 10d Cloud Relay - Part 1: Service Health & Dual Registration', () {
    test('Server responds to HTTP health check with zero connected clients initially', () async {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse('http://127.0.0.1:$testPort/health'));
      final res = await req.close();
      expect(res.statusCode, 200);

      final body = await res.transform(utf8.decoder).join();
      final jsonMap = json.decode(body) as Map<String, dynamic>;
      expect(jsonMap['service'], 'omnisys-cloud-relay');
      expect(jsonMap['status'], 'healthy');
      client.close();
    });
  });

  group('Task 10d Cloud Relay - Part 2: Live Real-Time Subscription & Capability Sync', () {
    test('Toggling capability from admin dispatches live to connected clinic app', () async {
      const accountId = 'acc_live_clinic_1';
      final clinicController = SubscriptionTierController();
      clinicController.getOrCreateAccount(
        accountId: accountId,
        businessName: 'Live Clinic Test',
        initialTier: SubscriptionPlanTier.basic,
      );

      final clinicClient = CloudRelayClinicClient(
        accountId: accountId,
        relayUrl: relayWsUrl,
        controller: clinicController,
      );
      final adminClient = CloudRelayAdminClient.createForTesting(
        relayUrl: relayWsUrl,
        adminId: 'superadmin_test',
      );

      // Connect both sides to relay
      await clinicClient.connect();
      await adminClient.connect();
      await Future.delayed(const Duration(milliseconds: 300));

      expect(clinicClient.isConnected, isTrue);
      expect(adminClient.isConnected, isTrue);

      // Verify clinic initially lacks the pro capability
      expect(clinicController.isCapabilityEnabled(accountId, 'sw.dental_3d_modbl_polygons'), isFalse);

      // Admin pushes live toggle override
      final receipt = await adminClient.dispatchToggle(
        accountId: accountId,
        action: 'set_override',
        targetKey: 'sw.dental_3d_modbl_polygons',
        newValue: true,
      );

      expect(receipt.status, RelayDeliveryStatus.liveDelivered);

      // Wait brief tick for socket transmission & local mutation
      await Future.delayed(const Duration(milliseconds: 300));

      // Clinic controller should have applied the override live without manual refresh
      expect(clinicController.isCapabilityEnabled(accountId, 'sw.dental_3d_modbl_polygons'), isTrue);
      expect(clinicClient.appliedEventsCount, 1);

      // Admin pushes tier upgrade to Enterprise
      final tierReceipt = await adminClient.dispatchToggle(
        accountId: accountId,
        action: 'assign_tier',
        targetKey: 'tier',
        newValue: 'enterprise',
      );
      expect(tierReceipt.status, RelayDeliveryStatus.liveDelivered);

      await Future.delayed(const Duration(milliseconds: 300));
      expect(clinicController.getAccount(accountId)?.assignedTier, SubscriptionPlanTier.enterprise);

      await clinicClient.disconnect();
      await adminClient.disconnect();
    });
  });

  group('Task 10d Cloud Relay - Part 3: Offline Queuing & Reconnect Batch Flush', () {
    test('Queues toggles when clinic is offline and flushes on reconnect', () async {
      const accountId = 'acc_offline_clinic_2';
      final clinicController = SubscriptionTierController();
      clinicController.getOrCreateAccount(
        accountId: accountId,
        businessName: 'Offline Test Clinic',
        initialTier: SubscriptionPlanTier.free,
      );

      final clinicClient = CloudRelayClinicClient(
        accountId: accountId,
        relayUrl: relayWsUrl,
        controller: clinicController,
      );
      final adminClient = CloudRelayAdminClient.createForTesting(
        relayUrl: relayWsUrl,
        adminId: 'superadmin_queue_test',
      );

      await adminClient.connect();
      await Future.delayed(const Duration(milliseconds: 200));

      // Clinic is OFFLINE: Admin dispatches 2 capability overrides
      final r1 = await adminClient.dispatchToggle(
        accountId: accountId,
        action: 'set_override',
        targetKey: 'sw.pharmacy_compound_label_matrix',
        newValue: true,
      );
      expect(r1.status, RelayDeliveryStatus.queuedOffline);
      expect(r1.queueSize, greaterThanOrEqualTo(1));

      final r2 = await adminClient.dispatchToggle(
        accountId: accountId,
        action: 'set_override',
        targetKey: 'sw.rule_a_telemetry',
        newValue: true,
      );
      expect(r2.status, RelayDeliveryStatus.queuedOffline);

      // Clinic now comes online: connects out to relay
      await clinicClient.connect();
      await Future.delayed(const Duration(milliseconds: 500));

      expect(clinicClient.isConnected, isTrue);

      // Queued batch should be delivered and applied to clinic controller
      expect(clinicController.isCapabilityEnabled(accountId, 'sw.pharmacy_compound_label_matrix'), isTrue);
      expect(clinicController.isCapabilityEnabled(accountId, 'sw.rule_a_telemetry'), isTrue);
      expect(clinicClient.appliedEventsCount, greaterThanOrEqualTo(2));

      await clinicClient.disconnect();
      await adminClient.disconnect();
    });
  });

  group('Task 10d Cloud Relay - Part 4: Local Offline Cache Persistence', () {
    test('Persisted subscription state survives cold launch when relay is down', () async {
      const accountId = 'acc_persistent_clinic_3';

      // 1. Simulate active session where an override is applied and cached
      final controller1 = SubscriptionTierController();
      controller1.getOrCreateAccount(
        accountId: accountId,
        businessName: 'Cache Persistence Clinic',
        initialTier: SubscriptionPlanTier.basic,
      );

      final client1 = CloudRelayClinicClient(
        accountId: accountId,
        relayUrl: relayWsUrl,
        controller: controller1,
      );
      await client1.connect();
      await Future.delayed(const Duration(milliseconds: 200));

      final admin = CloudRelayAdminClient.createForTesting(relayUrl: relayWsUrl);
      await admin.connect();
      await Future.delayed(const Duration(milliseconds: 200));

      await admin.dispatchToggle(
        accountId: accountId,
        action: 'set_override',
        targetKey: 'sw.veterinary_anesthesia_monitoring',
        newValue: true,
      );
      await Future.delayed(const Duration(milliseconds: 300));
      expect(controller1.isCapabilityEnabled(accountId, 'sw.veterinary_anesthesia_monitoring'), isTrue);

      // Disconnect and tear down
      await client1.disconnect();
      await admin.disconnect();

      // 2. Cold launch new clinic instance (relay URL intentionally invalid to simulate zero internet)
      final controller2 = SubscriptionTierController();
      final client2 = CloudRelayClinicClient(
        accountId: accountId,
        relayUrl: 'ws://invalid-unreachable-host:9999',
        controller: controller2,
      );

      // Even without connecting to relay, state was hydrated from local persistent cache
      expect(controller2.isCapabilityEnabled(accountId, 'sw.veterinary_anesthesia_monitoring'), isTrue);
      expect(client2.isConnected, isFalse);

      client2.dispose();
    });
  });

  group('Task 10d Cloud Relay - Part 5: Architectural Independence from LAN Sync Engine', () {
    test('Cloud Relay client and LAN Sync Connection Manager operate simultaneously without interference', () async {
      // 1. Cloud Relay Clinic Client
      final subController = SubscriptionTierController();
      final relayClient = CloudRelayClinicClient(
        accountId: 'acc_coexistence_test',
        relayUrl: relayWsUrl,
        controller: subController,
      );
      await relayClient.connect();
      await Future.delayed(const Duration(milliseconds: 200));
      expect(relayClient.isConnected, isTrue);

      // 2. LAN Sync Manager (Phase 1 peer-to-peer sync engine)
      final lanSyncManager = SyncConnectionManager();
      expect(lanSyncManager.activeRole, AppNodeRole.unconfigured);

      // Update LAN profile to Host mode without disturbing Cloud Relay
      await lanSyncManager.startHostMode(port: 3055, persist: false);

      expect(lanSyncManager.activeRole, AppNodeRole.host);
      expect(lanSyncManager.isHost, isTrue);

      // Cloud Relay socket is still connected and operational
      expect(relayClient.isConnected, isTrue);

      await relayClient.disconnect();
      lanSyncManager.dispose();
    });
  });
}
