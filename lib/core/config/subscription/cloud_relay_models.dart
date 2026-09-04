library;

/// Data models for the Cloud Relay Subscription Sync System.
///
/// Facilitates cross-network capability and subscription updates between the
/// Super-Admin console and remote clinic app instances across the internet.

enum RelayDeliveryStatus {
  liveDelivered('Live Delivered', 'Delivered live to connected clinic app instance'),
  queuedOffline('Clinic Offline — Queued', 'Clinic app is currently offline; change is queued at cloud relay and will apply on next connect'),
  pending('Dispatching', 'Sending toggle event to cloud relay...'),
  failed('Relay Unreachable', 'Could not reach cloud relay server');

  final String label;
  final String description;
  const RelayDeliveryStatus(this.label, this.description);
}

class RelaySubscriptionEvent {
  final String eventId;
  final String accountId;
  final String action;
  final String targetKey;
  final dynamic newValue;
  final String adminId;
  final DateTime timestamp;

  RelaySubscriptionEvent({
    required this.eventId,
    required this.accountId,
    required this.action,
    required this.targetKey,
    required this.newValue,
    required this.adminId,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'accountId': accountId,
        'action': action,
        'targetKey': targetKey,
        'newValue': newValue,
        'adminId': adminId,
        'timestamp': timestamp.toIso8601String(),
      };

  factory RelaySubscriptionEvent.fromJson(Map<String, dynamic> json) {
    return RelaySubscriptionEvent(
      eventId: json['eventId'] as String? ?? 'evt_${DateTime.now().millisecondsSinceEpoch}',
      accountId: json['accountId'] as String,
      action: json['action'] as String,
      targetKey: json['targetKey'] as String,
      newValue: json['newValue'],
      adminId: json['adminId'] as String? ?? 'superadmin',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class AccountRelayPresence {
  final String accountId;
  final bool isOnline;
  final DateTime? lastSeen;
  final int connectedTerminals;
  final int queuedEventsCount;

  AccountRelayPresence({
    required this.accountId,
    required this.isOnline,
    this.lastSeen,
    this.connectedTerminals = 0,
    this.queuedEventsCount = 0,
  });

  factory AccountRelayPresence.fromJson(Map<String, dynamic> json) {
    return AccountRelayPresence(
      accountId: json['accountId'] as String,
      isOnline: json['isOnline'] as bool? ?? false,
      lastSeen: json['lastSeen'] != null ? DateTime.tryParse(json['lastSeen'] as String) : null,
      connectedTerminals: json['connectedTerminals'] as int? ?? 0,
      queuedEventsCount: json['queuedCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'isOnline': isOnline,
        'lastSeen': lastSeen?.toIso8601String(),
        'connectedTerminals': connectedTerminals,
        'queuedCount': queuedEventsCount,
      };
}

class RelayDeliveryReceipt {
  final String eventId;
  final String accountId;
  final RelayDeliveryStatus status;
  final int? queueSize;
  final DateTime timestamp;

  RelayDeliveryReceipt({
    required this.eventId,
    required this.accountId,
    required this.status,
    this.queueSize,
    required this.timestamp,
  });
}
