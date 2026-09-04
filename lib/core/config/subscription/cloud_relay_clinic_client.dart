import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'cloud_relay_models.dart';
import 'subscription_tier_controller.dart';
import 'subscription_tier_models.dart';

/// Clinic-Side Cloud Relay Client.
///
/// Connects outbound from a remote clinic instance to the OmniSys Cloud Relay.
/// Receives capability overrides and tier mutations in real-time, applies them
/// to the local [SubscriptionTierController], and persists the state locally so
/// offline restarts remain functional even if the cloud relay is unreachable.
class CloudRelayClinicClient extends ChangeNotifier {
  final String accountId;
  final String instanceId;
  final String relayUrl;
  final SubscriptionTierController controller;

  // In-memory local cache store for offline persistence
  static final Map<String, Map<String, dynamic>> _offlinePersistenceStore = {};

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _reconnectTimer;
  bool _isDisposed = false;

  bool _isConnected = false;
  DateTime? _lastSyncTime;
  int _appliedEventsCount = 0;

  bool get isConnected => _isConnected;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get appliedEventsCount => _appliedEventsCount;

  CloudRelayClinicClient({
    required this.accountId,
    this.instanceId = '1',
    String? relayUrl,
    SubscriptionTierController? controller,
  })  : relayUrl = relayUrl ??
            const String.fromEnvironment(
              'CLOUD_RELAY_URL',
              defaultValue: 'ws://127.0.0.1:4040',
            ),
        controller = controller ?? SubscriptionTierController() {
    _hydrateFromLocalCache();
  }

  /// Hydrates subscription state from local persistent cache if available.
  void _hydrateFromLocalCache() {
    final cached = _offlinePersistenceStore[accountId];
    if (cached != null) {
      try {
        final profile = AccountSubscriptionProfile.fromJson(cached);
        controller.importState({
          'accounts': {accountId: profile.toJson()}
        });
        _lastSyncTime = profile.updatedAt;
      } catch (e) {
        debugPrint('[CloudRelayClinic] Failed to hydrate local cache: $e');
      }
    }
  }

  /// Persists current subscription state to local offline store.
  void _persistLocalCache() {
    final account = controller.getAccount(accountId);
    if (account != null) {
      _offlinePersistenceStore[accountId] = account.toJson();
    }
  }

  /// Connects to the Cloud Relay service.
  Future<void> connect() async {
    if (_isDisposed || _isConnected) return;
    _reconnectTimer?.cancel();

    try {
      final uri = Uri.parse(relayUrl);
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _onMessageReceived,
        onDone: _onDisconnected,
        onError: (err) {
          debugPrint('[CloudRelayClinic] Socket error: $err');
          _onDisconnected();
        },
        cancelOnError: true,
      );

      _isConnected = true;
      notifyListeners();

      // Register clinic identity with Cloud Relay
      _sendJson({
        'type': 'register',
        'role': 'clinic',
        'accountId': accountId,
        'instanceId': instanceId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[CloudRelayClinic] Connection attempt failed: $e');
      _onDisconnected();
    }
  }

  void _onMessageReceived(dynamic message) {
    if (message == null) return;
    try {
      final text = message.toString();
      final data = json.decode(text) as Map<String, dynamic>;
      final type = data['type'] as String?;

      switch (type) {
        case 'registered':
          _lastSyncTime = DateTime.now();
          notifyListeners();
          break;

        case 'subscription_update':
          _applySingleEvent(data);
          break;

        case 'subscription_batch_update':
          _applyBatchEvents(data);
          break;

        case 'ping':
          _sendJson({'type': 'pong', 'timestamp': DateTime.now().toIso8601String()});
          break;
      }
    } catch (e) {
      debugPrint('[CloudRelayClinic] Message processing error: $e');
    }
  }

  void _applySingleEvent(Map<String, dynamic> data) {
    final event = RelaySubscriptionEvent.fromJson(data);
    _executeEventMutation(event);

    _appliedEventsCount++;
    _lastSyncTime = DateTime.now();
    _persistLocalCache();
    notifyListeners();

    // Acknowledge receipt back to relay
    _sendJson({
      'type': 'ack_update',
      'eventId': event.eventId,
      'accountId': accountId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _applyBatchEvents(Map<String, dynamic> data) {
    final eventsList = data['events'] as List? ?? [];
    final ackedIds = <String>[];

    for (final item in eventsList) {
      if (item is Map) {
        final event = RelaySubscriptionEvent.fromJson(Map<String, dynamic>.from(item));
        _executeEventMutation(event);
        ackedIds.add(event.eventId);
        _appliedEventsCount++;
      }
    }

    _lastSyncTime = DateTime.now();
    _persistLocalCache();
    notifyListeners();

    // Acknowledge entire batch to remove from relay offline queue
    _sendJson({
      'type': 'ack_batch',
      'accountId': accountId,
      'eventIds': ackedIds,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  void _executeEventMutation(RelaySubscriptionEvent event) {
    switch (event.action) {
      case 'set_override':
        controller.setCapabilityOverride(
          event.accountId,
          event.targetKey,
          event.newValue == true || event.newValue.toString() == 'true',
          adminId: event.adminId,
        );
        break;

      case 'remove_override':
        controller.removeCapabilityOverride(
          event.accountId,
          event.targetKey,
          adminId: event.adminId,
        );
        break;

      case 'assign_tier':
        final tierName = event.newValue.toString().toLowerCase();
        final tier = SubscriptionPlanTier.values.firstWhere(
          (t) => t.name.toLowerCase() == tierName,
          orElse: () => SubscriptionPlanTier.basic,
        );
        controller.assignTierPreset(
          event.accountId,
          tier,
          adminId: event.adminId,
        );
        break;

      case 'reset_overrides':
        controller.resetOverridesToPreset(
          event.accountId,
          adminId: event.adminId,
        );
        break;
    }
  }

  void _sendJson(Map<String, dynamic> payload) {
    if (_channel != null && _isConnected) {
      try {
        _channel!.sink.add(json.encode(payload));
      } catch (e) {
        debugPrint('[CloudRelayClinic] Send failed: $e');
      }
    }
  }

  void _onDisconnected() {
    _isConnected = false;
    _subscription?.cancel();
    _channel = null;
    notifyListeners();

    if (!_isDisposed) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(const Duration(seconds: 3), () {
        if (!_isDisposed && !_isConnected) {
          connect();
        }
      });
    }
  }

  /// Disconnects socket and stops auto-reconnect.
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _reconnectTimer?.cancel();
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  /// Testing helper to inspect offline cache.
  @visibleForTesting
  static Map<String, dynamic>? getCachedAccount(String accountId) =>
      _offlinePersistenceStore[accountId];

  @visibleForTesting
  static void clearCacheForTesting() => _offlinePersistenceStore.clear();
}
