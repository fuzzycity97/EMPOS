import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'sync_envelope_signing.dart';

class SyncEnvelope extends Equatable {
  final String type;
  final String scope;
  final String senderId;
  final String senderRole;
  final int ts;
  final Map<String, dynamic>? payload;
  final String? signature;

  const SyncEnvelope({
    required this.type,
    this.scope = 'global',
    required this.senderId,
    required this.senderRole,
    required this.ts,
    this.payload,
    this.signature,
  });

  factory SyncEnvelope.create({
    required String type,
    String scope = 'global',
    required String senderId,
    required String senderRole,
    Map<String, dynamic>? payload,
    int? timestamp,
    String? signature,
    String? sharedSecretHex,
  }) {
    final effectiveTs = timestamp ?? DateTime.now().millisecondsSinceEpoch;
    final sig = signature ??
        (sharedSecretHex != null && sharedSecretHex.isNotEmpty
            ? EnvelopeSigner.sign(
                canonicalPayload: EnvelopeSigner.canonicalize(
                  type: type,
                  scope: scope,
                  senderRole: senderRole,
                  senderId: senderId,
                  payload: payload,
                  timestampEpochMs: effectiveTs,
                ),
                sharedSecretHex: sharedSecretHex,
              )
            : null);

    return SyncEnvelope(
      type: type,
      scope: scope,
      senderId: senderId,
      senderRole: senderRole,
      ts: effectiveTs,
      payload: payload,
      signature: sig,
    );
  }

  factory SyncEnvelope.fromJson(Map<String, dynamic> json) {
    return SyncEnvelope(
      type: json['type']?.toString() ?? '',
      scope: json['scope']?.toString() ?? 'global',
      senderId: json['senderId']?.toString() ?? json['sender_id']?.toString() ?? 'unknown',
      senderRole: json['senderRole']?.toString() ?? json['sender_role']?.toString() ?? 'station',
      ts: (json['ts'] as num?)?.toInt() ?? DateTime.now().millisecondsSinceEpoch,
      payload: json['payload'] is Map<String, dynamic>
          ? json['payload'] as Map<String, dynamic>
          : json['payload'] is Map
              ? Map<String, dynamic>.from(json['payload'] as Map)
              : null,
      signature: json['signature']?.toString(),
    );
  }

  factory SyncEnvelope.fromRawJson(String raw) {
    return SyncEnvelope.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'scope': scope,
      'senderId': senderId,
      'senderRole': senderRole,
      'ts': ts,
      if (payload != null) 'payload': payload,
      if (signature != null) 'signature': signature,
    };
  }

  String toRawJson() => jsonEncode(toJson());

  SyncEnvelope copyWith({
    String? type,
    String? scope,
    String? senderId,
    String? senderRole,
    int? ts,
    Map<String, dynamic>? payload,
    String? signature,
  }) {
    return SyncEnvelope(
      type: type ?? this.type,
      scope: scope ?? this.scope,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      ts: ts ?? this.ts,
      payload: payload ?? this.payload,
      signature: signature ?? this.signature,
    );
  }

  @override
  List<Object?> get props => [type, scope, senderId, senderRole, ts, payload, signature];
}
