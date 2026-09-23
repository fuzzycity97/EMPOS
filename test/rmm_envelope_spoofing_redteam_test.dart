// test/rmm_envelope_spoofing_redteam_test.dart
//
// ============================================================================
// SECURITY TEST SUITE — ENVELOPE AUTHENTICITY & HMAC VALIDATION
// ============================================================================
//
// Context: SyncEnvelope carries senderRole over LAN WebSocket/TCP sockets.
// With EnvelopeSigner (HMAC-SHA256) and LanSyncRepositoryImpl.wouldAcceptEnvelope:
//   1. Unsigned or invalidly signed admin/RMM commands are REJECTED outright.
//   2. Legitimate envelopes signed with the paired cluster secret are ACCEPTED.
//   3. Payload tampering after signing causes signature verification failure.
//   4. Stale/replayed envelopes (> 5 minutes) are REJECTED.

import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/data/repositories/lan_sync_repository_impl.dart';

void main() {
  group('RMM / LAN Sync — envelope authenticity (SECURITY)', () {
    const clusterSecret = 'empos_production_cluster_secret_key_849204';

    tearDown(() {
      LanSyncRepositoryImpl.setClusterSecretHex(null);
    });

    test(
      'a forged envelope claiming senderRole=admin from an unverified '
      'sender must be REJECTED, not processed as an authoritative command',
      () {
        // Simulate an attacker on the same LAN crafting an envelope by
        // hand without cryptographic material, claiming admin role.
        final forgedEnvelope = SyncEnvelope.create(
          type: 'rmm.command',
          senderId: 'untrusted-rogue-station',
          senderRole: 'admin',
          payload: {
            'command': 'disable_subscription_gate',
            'targetBranchId': 'branch-1',
          },
        );

        final repository = LanSyncRepositoryImpl();
        final wasAccepted = repository.wouldAcceptEnvelope(forgedEnvelope);

        expect(
          wasAccepted,
          isFalse,
          reason: 'An envelope claiming admin without valid signature must be rejected.',
        );
      },
    );

    test(
      'a legitimate envelope signed with the paired cluster secret is ACCEPTED',
      () {
        LanSyncRepositoryImpl.setClusterSecretHex(clusterSecret);

        final legitimateEnvelope = SyncEnvelope.create(
          type: 'rmm.command',
          senderId: 'trusted-admin-terminal',
          senderRole: 'admin',
          payload: {
            'command': 'sync_catalogs',
            'targetBranchId': 'branch-1',
          },
          sharedSecretHex: clusterSecret,
        );

        final repository = LanSyncRepositoryImpl();
        final wasAccepted = repository.wouldAcceptEnvelope(legitimateEnvelope);

        expect(
          wasAccepted,
          isTrue,
          reason: 'Authentic admin envelope with matching HMAC signature must be accepted.',
        );
      },
    );

    test(
      'an envelope signed with an INVALID / UNPAIRED secret is REJECTED',
      () {
        LanSyncRepositoryImpl.setClusterSecretHex(clusterSecret);

        final rogueEnvelope = SyncEnvelope.create(
          type: 'rmm.command',
          senderId: 'rogue-station',
          senderRole: 'admin',
          payload: {
            'command': 'disable_subscription_gate',
            'targetBranchId': 'branch-1',
          },
          sharedSecretHex: 'attacker_wrong_secret_123',
        );

        final repository = LanSyncRepositoryImpl();
        final wasAccepted = repository.wouldAcceptEnvelope(rogueEnvelope);

        expect(
          wasAccepted,
          isFalse,
          reason: 'Envelope signed with incorrect secret must fail HMAC verification.',
        );
      },
    );

    test(
      'an envelope whose payload has been tampered with after signing is REJECTED',
      () {
        LanSyncRepositoryImpl.setClusterSecretHex(clusterSecret);

        final validEnvelope = SyncEnvelope.create(
          type: 'rmm.command',
          senderId: 'trusted-admin-terminal',
          senderRole: 'admin',
          payload: {
            'command': 'sync_catalogs',
            'targetBranchId': 'branch-1',
          },
          sharedSecretHex: clusterSecret,
        );

        // MITM tamper with payload keeping the old signature
        final tamperedEnvelope = validEnvelope.copyWith(
          payload: {
            'command': 'drop_database',
            'targetBranchId': 'branch-1',
          },
        );

        final repository = LanSyncRepositoryImpl();
        final wasAccepted = repository.wouldAcceptEnvelope(tamperedEnvelope);

        expect(
          wasAccepted,
          isFalse,
          reason: 'Tampered payload must invalidate the HMAC digest.',
        );
      },
    );

    test(
      'a replayed envelope with timestamp older than 5 minutes is REJECTED',
      () {
        LanSyncRepositoryImpl.setClusterSecretHex(clusterSecret);

        final staleTimestamp = DateTime.now()
            .subtract(const Duration(minutes: 10))
            .millisecondsSinceEpoch;

        final replayedEnvelope = SyncEnvelope.create(
          type: 'rmm.command',
          senderId: 'trusted-admin-terminal',
          senderRole: 'admin',
          timestamp: staleTimestamp,
          payload: {
            'command': 'sync_catalogs',
            'targetBranchId': 'branch-1',
          },
          sharedSecretHex: clusterSecret,
        );

        final repository = LanSyncRepositoryImpl();
        final wasAccepted = repository.wouldAcceptEnvelope(replayedEnvelope);

        expect(
          wasAccepted,
          isFalse,
          reason: 'Stale envelope exceeding 5 minute replay window must be rejected.',
        );
      },
    );
  });
}
