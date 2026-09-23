// test/rmm_envelope_signing_test.dart
//
// Verifies cryptographic signing and authenticity validation for LAN sync envelopes,
// ensuring legitimate traffic works with paired secrets and forged/unpaired traffic is rejected.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope.dart';
import 'package:empos/core/network/lan_sync/domain/entities/sync_envelope_signing.dart';
import 'package:empos/core/network/lan_sync/data/device_pairing_secret_store.dart';
import 'package:empos/core/network/lan_sync/data/repositories/lan_sync_repository_impl.dart';

class InMemorySecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _storage[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }
}

void main() {
  group('LAN sync envelope signing — real security behavior', () {
    const sharedSecret = 'test-only-secret-do-not-use-in-prod-abc123';
    const wrongSecret = 'attacker-guessed-secret-xyz789';

    test('envelope signed with the correct shared secret verifies successfully', () {
      final canonical = EnvelopeSigner.canonicalize(
        senderRole: 'admin',
        senderId: 'device-paired-001',
        payload: {'command': 'disable_subscription_gate'},
        timestampEpochMs: 1735000000000,
      );
      final signature = EnvelopeSigner.sign(
        canonicalPayload: canonical,
        sharedSecretHex: sharedSecret,
      );

      final isValid = EnvelopeSigner.verify(
        canonicalPayload: canonical,
        sharedSecretHex: sharedSecret,
        providedSignatureHex: signature,
      );

      expect(
        isValid,
        isTrue,
        reason: 'Legitimate traffic signed with the correct paired secret must be accepted.',
      );
    });

    test(
      'envelope signed with a DIFFERENT (attacker-guessed) secret is rejected, '
      'even with an identical payload and claimed senderRole',
      () {
        final canonical = EnvelopeSigner.canonicalize(
          senderRole: 'admin',
          senderId: 'device-paired-001',
          payload: {'command': 'disable_subscription_gate'},
          timestampEpochMs: 1735000000000,
        );
        final forgedSignature = EnvelopeSigner.sign(
          canonicalPayload: canonical,
          sharedSecretHex: wrongSecret,
        );

        final isValid = EnvelopeSigner.verify(
          canonicalPayload: canonical,
          sharedSecretHex: sharedSecret,
          providedSignatureHex: forgedSignature,
        );

        expect(
          isValid,
          isFalse,
          reason: 'An attacker without the paired secret cannot produce a signature that verifies.',
        );
      },
    );

    test(
      'tampering with the payload after signing (e.g. changing targetBranchId) '
      'invalidates the signature even if senderRole is left untouched',
      () {
        final originalCanonical = EnvelopeSigner.canonicalize(
          senderRole: 'admin',
          senderId: 'device-paired-001',
          payload: {'targetBranchId': 'branch-1'},
          timestampEpochMs: 1735000000000,
        );
        final signature = EnvelopeSigner.sign(
          canonicalPayload: originalCanonical,
          sharedSecretHex: sharedSecret,
        );

        // Attacker intercepts a legitimately signed envelope and changes branch
        final tamperedCanonical = EnvelopeSigner.canonicalize(
          senderRole: 'admin',
          senderId: 'device-paired-001',
          payload: {'targetBranchId': 'branch-2'},
          timestampEpochMs: 1735000000000,
        );

        final isValid = EnvelopeSigner.verify(
          canonicalPayload: tamperedCanonical,
          sharedSecretHex: sharedSecret,
          providedSignatureHex: signature,
        );

        expect(
          isValid,
          isFalse,
          reason: 'Signature must cover all payload fields; tampered payload invalidates digest.',
        );
      },
    );

    test(
      'an unpaired device (no stored secret) cannot be granted admin trust by any envelope, signed or not',
      () async {
        final fakeStorage = InMemorySecureStorage();
        final secretStore = DevicePairingSecretStore(fakeStorage);
        final repository = LanSyncRepositoryImpl(secretStore: secretStore);

        // Confirm unpaired device has no secret
        final secret = await secretStore.getSecretForPeer('unknown-device-999');
        expect(secret, isNull);

        // Envelope from unknown unpaired device claiming admin
        final rogueEnvelope = SyncEnvelope.create(
          type: 'rmm.command',
          senderId: 'unknown-device-999',
          senderRole: 'admin',
          payload: {'command': 'disable_subscription_gate'},
          signature: 'forged_or_random_signature',
        );

        expect(repository.wouldAcceptEnvelope(rogueEnvelope), isFalse);
      },
    );

    test(
      'a legitimately paired device with its own stored secret is ACCEPTED by the repository',
      () async {
        final fakeStorage = InMemorySecureStorage();
        final secretStore = DevicePairingSecretStore(fakeStorage);
        final repository = LanSyncRepositoryImpl(secretStore: secretStore);

        const peerId = 'paired-station-007';
        const peerSecret = 'peer_secret_777_abcdef012345';

        // Pair the device
        await secretStore.storeSecretForPeer(
          peerDeviceId: peerId,
          secretHex: peerSecret,
        );

        final authenticEnvelope = SyncEnvelope.create(
          type: 'rmm.command',
          senderId: peerId,
          senderRole: 'admin',
          payload: {'command': 'sync_state'},
          sharedSecretHex: peerSecret,
        );

        expect(repository.wouldAcceptEnvelope(authenticEnvelope), isTrue);
      },
    );
  });
}
