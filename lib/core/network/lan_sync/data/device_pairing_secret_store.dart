// lib/core/network/lan_sync/data/device_pairing_secret_store.dart
//
// Manages the shared secret(s) used to sign/verify SyncEnvelopes.
//
// CRITICAL RULES:
//   1. The secret must NEVER be hardcoded in source, committed to git,
//      or embedded identically in every install (that would make it
//      recoverable from any single decompiled APK and defeat the whole
//      purpose — every device/branch needs its OWN secret).
//   2. The secret must be provisioned out-of-band at pairing time — e.g.
//      the admin/technician scans a QR code shown once on the "primary"
//      device, or types a one-time pairing code shown on-screen, which
//      is then used to derive/exchange the secret. It must not be sent
//      in plaintext over the same LAN socket that will later carry
//      signed traffic (that's just moving the vulnerability, not fixing
//      it) — do the pairing handshake once, ideally requiring physical
//      proximity/manual entry, precisely so it can't be done remotely by
//      an attacker.
//   3. Store the secret using flutter_secure_storage (Keychain/Keystore-
//      backed) rather than SharedPreferences or a plain Hive box, since
//      those are readable by anyone with filesystem access on a rooted/
//      jailbroken device or an admin account on Windows.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class DevicePairingSecretStore {
  DevicePairingSecretStore([FlutterSecureStorage? secureStorage])
      : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;
  final Map<String, String> _memoryCache = {};

  static const _keyPrefix = 'lan_sync_secret_for_device_';
  static const _clusterKey = 'lan_sync_cluster_shared_secret';

  /// Stores the shared secret for a specific paired peer device, keyed by
  /// that device's stable ID. Call this once during the pairing handshake,
  /// never on every app launch.
  Future<void> storeSecretForPeer({
    required String peerDeviceId,
    required String secretHex,
  }) async {
    _memoryCache[peerDeviceId] = secretHex;
    await _secureStorage.write(
      key: '$_keyPrefix$peerDeviceId',
      value: secretHex,
    );
  }

  /// Retrieves the shared secret for a given peer, or null if that peer
  /// has never been paired. LanSyncRepositoryImpl MUST treat a null
  /// result as "reject this envelope outright" — never fall back to a
  /// default/shared secret, as that reintroduces the original hole.
  Future<String?> getSecretForPeer(String peerDeviceId) async {
    final cached = _memoryCache[peerDeviceId];
    if (cached != null) return cached;
    final secret = await _secureStorage.read(key: '$_keyPrefix$peerDeviceId');
    if (secret != null) {
      _memoryCache[peerDeviceId] = secret;
    }
    return secret;
  }

  /// Synchronously looks up cached secret for a peer.
  String? getSecretForPeerSync(String peerDeviceId) => _memoryCache[peerDeviceId];

  /// Revokes a peer device's pairing secret.
  Future<void> revokePeer(String peerDeviceId) async {
    _memoryCache.remove(peerDeviceId);
    await _secureStorage.delete(key: '$_keyPrefix$peerDeviceId');
  }

  /// Stores or updates the branch/cluster shared secret.
  Future<void> storeClusterSecret(String secretHex) async {
    await _secureStorage.write(
      key: _clusterKey,
      value: secretHex,
    );
  }

  /// Retrieves the branch/cluster shared secret.
  Future<String?> getClusterSecret() async {
    return _secureStorage.read(key: _clusterKey);
  }

  /// Clears the cluster secret.
  Future<void> clearClusterSecret() async {
    await _secureStorage.delete(key: _clusterKey);
  }
}
