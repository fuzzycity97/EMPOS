import 'dart:convert';
import 'package:equatable/equatable.dart';

class SyncEnvelope extends Equatable {
  final String type;
  final String scope;
  final String senderId;
  final String senderRole;
  final int ts;
  final Map<String, dynamic>? payload;

  const SyncEnvelope({
    required this.type,
    this.scope = 'global',
    required this.senderId,
    required this.senderRole,
    required this.ts,
    this.payload,
  });

  factory SyncEnvelope.create({
    required String type,
    String scope = 'global',
    required String senderId,
    required String senderRole,
    Map<String, dynamic>? payload,
    int? timestamp,
  }) {
    return SyncEnvelope(
      type: type,
      scope: scope,
      senderId: senderId,
      senderRole: senderRole,
      ts: timestamp ?? DateTime.now().millisecondsSinceEpoch,
      payload: payload,
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
  }) {
    return SyncEnvelope(
      type: type ?? this.type,
      scope: scope ?? this.scope,
      senderId: senderId ?? this.senderId,
      senderRole: senderRole ?? this.senderRole,
      ts: ts ?? this.ts,
      payload: payload ?? this.payload,
    );
  }

  @override
  List<Object?> get props => [type, scope, senderId, senderRole, ts, payload];
}
