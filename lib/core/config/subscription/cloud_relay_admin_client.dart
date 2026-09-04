import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'cloud_relay_models.dart';

/// Super-Admin Cloud Relay Client.
///
/// Connects the Super-Admin panel to the OmniSys Cloud Relay to dispatch
/// real-time subscription & capability toggle mutations to remote clinic instances.
/// Tracks per-account presence and live vs queued delivery statuses.
class CloudRelayAdminClient extends ChangeNotifier {
  static final CloudRelayAdminClient _instance = CloudRelayAdminClient._internal();
  factory CloudRelayAdminClient() => _instance;
  static CloudRelayAdminClient get instance => _instance;

  final String relayUrl;
  final String adminId;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isDisposed = false;
  bool _isConnected = false;

  final Map<String, RelayDeliveryStatus> _accountDeliveryStatus = {};
  final Map<String, AccountRelayPresence> _accountPresence = {};
  final Map<String, Completer<RelayDeliveryReceipt>> _pendingAcks = {};
  final Map<String, Timer> _pendingTimers = {};

  bool get isConnected => _isConnected;

  CloudRelayAdminClient._internal({
    String? relayUrl,
    String? adminId,
  })  : relayUrl = relayUrl ??
            const String.fromEnvironment(
              'CLOUD_RELAY_URL',
              defaultValue: 'ws://127.0.0.1:4040',
            ),
        adminId = adminId ?? 'superadmin';

  @visibleForTesting
  factory CloudRelayAdminClient.createForTesting({
    required String relayUrl,
    String adminId = 'superadmin',
  }) {
    return CloudRelayAdminClient._internal(relayUrl: relayUrl, adminId: adminId);
  }

  /// Establishes connection to the Cloud Relay service.
  Future<void> connect() async {
    if (_isDisposed || _isConnected) return;

    try {
      final uri = Uri.parse(relayUrl);
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _onMessageReceived,
        onDone: _onDisconnected,
        onError: (err) {
          debugPrint('[CloudRelayAdmin] Socket error: $err');
          _onDisconnected();
        },
        cancelOnError: true,
      );

      // Register admin role
      _sendJson({
        'type': 'register',
        'role': 'admin',
        'adminId': adminId,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      debugPrint('[CloudRelayAdmin] Connection failed: $e');
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
          _isConnected = true;
          final activeList = data['activeClinics'] as List? ?? [];
          for (final item in activeList) {
            if (item is Map) {
              final pres = AccountRelayPresence.fromJson(Map<String, dynamic>.from(item));
              _accountPresence[pres.accountId] = pres;
            }
          }
          notifyListeners();
          break;

        case 'ack':
          final eventId = data['eventId'] as String?;
          final accountId = data['accountId'] as String?;
          final statusStr = data['deliveryStatus'] as String?;
          final queueSize = data['queueSize'] as int?;

          final status = statusStr == 'delivered'
              ? RelayDeliveryStatus.liveDelivered
              : RelayDeliveryStatus.queuedOffline;

          if (accountId != null) {
            _accountDeliveryStatus[accountId] = status;
          }

          if (eventId != null && _pendingAcks.containsKey(eventId)) {
            _pendingTimers.remove(eventId)?.cancel();
            final receipt = RelayDeliveryReceipt(
              eventId: eventId,
              accountId: accountId ?? '',
              status: status,
              queueSize: queueSize,
              timestamp: DateTime.now(),
            );
            _pendingAcks.remove(eventId)!.complete(receipt);
          }
          notifyListeners();
          break;

        case 'presence_update':
          final accountId = data['accountId'] as String?;
          if (accountId != null) {
            _accountPresence[accountId] = AccountRelayPresence.fromJson(data);
            notifyListeners();
          }
          break;

        case 'presence_list':
          final accounts = data['accounts'] as List? ?? [];
          for (final item in accounts) {
            if (item is Map) {
              final pres = AccountRelayPresence.fromJson(Map<String, dynamic>.from(item));
              _accountPresence[pres.accountId] = pres;
            }
          }
          notifyListeners();
          break;
      }
    } catch (e) {
      debugPrint('[CloudRelayAdmin] Message parse error: $e');
    }
  }

  /// Dispatches a subscription/capability mutation to the Cloud Relay.
  ///
  /// Returns a [RelayDeliveryReceipt] containing whether the event was
  /// delivered live to an active clinic or queued server-side for delivery on reconnect.
  Future<RelayDeliveryReceipt> dispatchToggle({
    required String accountId,
    required String action,
    required String targetKey,
    required dynamic newValue,
    String? adminOverrideId,
  }) async {
    final eventId = 'evt_${DateTime.now().microsecondsSinceEpoch}';

    if (!_isConnected || _channel == null) {
      // Offline fallback: returns immediately with zero timers
      final receipt = RelayDeliveryReceipt(
        eventId: eventId,
        accountId: accountId,
        status: RelayDeliveryStatus.failed,
        timestamp: DateTime.now(),
      );
      _accountDeliveryStatus[accountId] = RelayDeliveryStatus.failed;
      notifyListeners();
      return receipt;
    }

    final completer = Completer<RelayDeliveryReceipt>();
    _pendingAcks[eventId] = completer;

    _accountDeliveryStatus[accountId] = RelayDeliveryStatus.pending;
    notifyListeners();

    _sendJson({
      'type': 'subscription_toggle',
      'eventId': eventId,
      'accountId': accountId,
      'action': action,
      'targetKey': targetKey,
      'newValue': newValue,
      'adminId': adminOverrideId ?? adminId,
      'timestamp': DateTime.now().toIso8601String(),
    });

    final timer = Timer(const Duration(seconds: 4), () {
      if (!completer.isCompleted) {
        _pendingAcks.remove(eventId);
        _pendingTimers.remove(eventId);
        final timeoutReceipt = RelayDeliveryReceipt(
          eventId: eventId,
          accountId: accountId,
          status: RelayDeliveryStatus.failed,
          timestamp: DateTime.now(),
        );
        _accountDeliveryStatus[accountId] = RelayDeliveryStatus.failed;
        notifyListeners();
        completer.complete(timeoutReceipt);
      }
    });
    _pendingTimers[eventId] = timer;

    return completer.future;
  }

  /// Queries current presence info for an account.
  AccountRelayPresence? getPresence(String accountId) => _accountPresence[accountId];

  /// Queries last-known relay delivery status for an account.
  RelayDeliveryStatus getDeliveryStatus(String accountId) =>
      _accountDeliveryStatus[accountId] ?? RelayDeliveryStatus.queuedOffline;

  void _sendJson(Map<String, dynamic> payload) {
    if (_channel != null) {
      try {
        _channel!.sink.add(json.encode(payload));
      } catch (e) {
        debugPrint('[CloudRelayAdmin] Send error: $e');
      }
    }
  }

  void _onDisconnected() {
    _isConnected = false;
    _subscription?.cancel();
    _channel = null;
    _clearPendingTimers();
    notifyListeners();
  }

  void _clearPendingTimers() {
    for (final timer in _pendingTimers.values) {
      timer.cancel();
    }
    _pendingTimers.clear();
    for (final completer in _pendingAcks.values) {
      if (!completer.isCompleted) {
        completer.complete(
          RelayDeliveryReceipt(
            eventId: 'cancelled',
            accountId: '',
            status: RelayDeliveryStatus.failed,
            timestamp: DateTime.now(),
          ),
        );
      }
    }
    _pendingAcks.clear();
  }

  Future<void> disconnect() async {
    _clearPendingTimers();
    _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _isConnected = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clearPendingTimers();
    _subscription?.cancel();
    _channel?.sink.close();
    super.dispose();
  }

  @visibleForTesting
  void resetForTesting() {
    _clearPendingTimers();
    _accountDeliveryStatus.clear();
    _accountPresence.clear();
    _pendingAcks.clear();
  }
}
