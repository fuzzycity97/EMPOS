// lib/core/network/lan_sync/domain/entities/sync_envelope_signing.dart
//
// Adds cryptographic authenticity to SyncEnvelope. This does NOT replace
// SyncEnvelope — it's the signing/verification logic called from
// SyncEnvelope.create() and from LanSyncRepositoryImpl's receive path.
//
// DESIGN:
//   - Each paired device holds a shared secret (per-branch, ideally
//     per-device) provisioned at pairing time, NOT hardcoded in source or
//     shipped in the APK/exe.
//   - Envelope payload is canonicalized to a deterministic string, then
//     HMAC-SHA256'd with that secret. The signature travels alongside the
//     envelope as a new `signature` field.
//   - The receiver recomputes the HMAC over the received payload using
//     its own copy of the shared secret and does a constant-time
//     comparison. Only if it matches does senderRole get trusted at all.
//   - A timestamp/nonce field is included in the signed payload to
//     prevent replay of a captured legitimate envelope hours/days later.

import 'dart:convert';
import 'package:crypto/crypto.dart';

class EnvelopeSigner {
  /// Computes the HMAC-SHA256 signature for a canonicalized payload string,
  /// using the given shared secret. Returns a hex-encoded signature.
  static String sign({
    required String canonicalPayload,
    required String sharedSecretHex,
  }) {
    final key = utf8.encode(sharedSecretHex);
    final bytes = utf8.encode(canonicalPayload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return digest.toString(); // hex string
  }

  /// Verifies a signature in constant time (avoids timing side-channel
  /// leaks about how many leading bytes matched).
  static bool verify({
    required String canonicalPayload,
    required String sharedSecretHex,
    required String providedSignatureHex,
  }) {
    final expected = sign(
      canonicalPayload: canonicalPayload,
      sharedSecretHex: sharedSecretHex,
    );
    return _constantTimeEquals(expected, providedSignatureHex);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var result = 0;
    for (var i = 0; i < a.length; i++) {
      result |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return result == 0;
  }

  /// Produces a deterministic string representation of the envelope's
  /// meaningful fields for signing. Field order is strictly sorted and
  /// key fields affecting trust decisions are included.
  static String canonicalize({
    required String senderRole,
    required String senderId,
    Map<String, dynamic>? payload,
    required int timestampEpochMs,
    String type = '',
    String scope = 'global',
  }) {
    // Sort payload keys for determinism regardless of Map insertion order.
    final effectivePayload = payload ?? const <String, dynamic>{};
    final sortedKeys = effectivePayload.keys.toList()..sort();
    final payloadPart = sortedKeys
        .map((k) => '$k=${jsonEncode(effectivePayload[k])}')
        .join('&');
    final base = 'senderRole=$senderRole&senderId=$senderId&ts=$timestampEpochMs';
    if (type.isNotEmpty) {
      return 'type=$type&scope=$scope&$base&$payloadPart';
    }
    return '$base&$payloadPart';
  }
}
