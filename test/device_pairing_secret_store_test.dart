// test/device_pairing_secret_store_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:empos/core/network/lan_sync/data/device_pairing_secret_store.dart';

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
  group('DevicePairingSecretStore', () {
    late InMemorySecureStorage fakeStorage;
    late DevicePairingSecretStore store;

    setUp(() {
      fakeStorage = InMemorySecureStorage();
      store = DevicePairingSecretStore(fakeStorage);
    });

    test('returns null for an unpaired peer device', () async {
      final secret = await store.getSecretForPeer('station-unknown');
      expect(secret, isNull);
    });

    test('stores and retrieves secret for a specific paired peer device', () async {
      const peerId = 'station-doctor-01';
      const secretHex = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';

      await store.storeSecretForPeer(
        peerDeviceId: peerId,
        secretHex: secretHex,
      );

      final retrieved = await store.getSecretForPeer(peerId);
      expect(retrieved, equals(secretHex));
    });

    test('revoking a peer deletes the secret and subsequently returns null', () async {
      const peerId = 'station-cashier-02';
      const secretHex = '7d57a5a743894a0e';

      await store.storeSecretForPeer(
        peerDeviceId: peerId,
        secretHex: secretHex,
      );

      expect(await store.getSecretForPeer(peerId), equals(secretHex));

      await store.revokePeer(peerId);
      expect(await store.getSecretForPeer(peerId), isNull);
    });

    test('manages cluster-wide shared secret lifecycle', () async {
      expect(await store.getClusterSecret(), isNull);

      const clusterSecret = 'cluster_secret_982347102934';
      await store.storeClusterSecret(clusterSecret);
      expect(await store.getClusterSecret(), equals(clusterSecret));

      await store.clearClusterSecret();
      expect(await store.getClusterSecret(), isNull);
    });
  });
}
