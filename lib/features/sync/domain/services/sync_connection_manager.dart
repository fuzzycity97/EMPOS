import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum SyncConnectionState { connected, disconnected, connecting, reconnecting }

class ConnectionHistoryProfile {
  final String serverUrl;
  final String mode; // 'LAN' or 'CLOUD'
  final DateTime lastSuccessfulConnection;
  final String? authToken;

  const ConnectionHistoryProfile({
    required this.serverUrl,
    required this.mode,
    required this.lastSuccessfulConnection,
    this.authToken,
  });

  Map<String, dynamic> toJson() => {
        'serverUrl': serverUrl,
        'mode': mode,
        'lastSuccessfulConnection': lastSuccessfulConnection.toIso8601String(),
        'authToken': authToken,
      };

  factory ConnectionHistoryProfile.fromJson(Map<String, dynamic> json) {
    return ConnectionHistoryProfile(
      serverUrl: json['serverUrl'] as String,
      mode: json['mode'] as String,
      lastSuccessfulConnection: DateTime.parse(json['lastSuccessfulConnection'] as String),
      authToken: json['authToken'] as String?,
    );
  }
}

class SyncConnectionManager extends ChangeNotifier {
  static const String _storageKey = 'cached_server_profile';

  io.Socket? _socket;
  SyncConnectionState _state = SyncConnectionState.disconnected;
  ConnectionHistoryProfile? _cachedProfile;
  final List<Map<String, dynamic>> _connectionChangelog = [];
  int _latencyMs = 0;

  SyncConnectionState get state => _state;
  bool get isConnected => _state == SyncConnectionState.connected;
  int get latencyMs => _latencyMs;
  ConnectionHistoryProfile? get cachedProfile => _cachedProfile;
  List<Map<String, dynamic>> get connectionChangelog => List.unmodifiable(_connectionChangelog);

  /// Auto-connects automatically on app bootstrap if history exists
  Future<void> bootstrapAutoConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);

    if (rawJson != null) {
      try {
        final map = jsonDecode(rawJson) as Map<String, dynamic>;
        _cachedProfile = ConnectionHistoryProfile.fromJson(map);
        if (_cachedProfile != null) {
          _logEvent('AUTO_BOOTSTRAP', 'Found cached server history. Initiating handshake to ${_cachedProfile!.serverUrl}');
          await connectToServer(_cachedProfile!.serverUrl, _cachedProfile!.mode, authToken: _cachedProfile!.authToken);
        }
      } catch (e) {
        _logEvent('BOOTSTRAP_ERROR', 'Failed to parse cached server profile: $e', isSuccess: false);
      }
    } else {
      _logEvent('BOOTSTRAP_IDLE', 'No previous server history found. Awaiting First-Run Wizard setup.');
    }
  }

  Future<void> connectToServer(String serverUrl, String mode, {String? authToken}) async {
    _state = SyncConnectionState.connecting;
    notifyListeners();

    _socket?.dispose();
    final stopwatch = Stopwatch()..start();

    _socket = io.io(
      serverUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setReconnectionAttempts(double.infinity)
          .setQuery({'authToken': authToken ?? ''})
          .build(),
    );

    _socket!.onConnect((_) async {
      stopwatch.stop();
      _latencyMs = stopwatch.elapsedMilliseconds;
      _state = SyncConnectionState.connected;

      final updatedProfile = ConnectionHistoryProfile(
        serverUrl: serverUrl,
        mode: mode,
        lastSuccessfulConnection: DateTime.now(),
        authToken: authToken,
      );
      _cachedProfile = updatedProfile;
      await _persistProfile(updatedProfile);

      _logEvent('CONNECTED', 'Established live connection to $serverUrl (${_latencyMs}ms)', isSuccess: true);
      notifyListeners();
    });

    _socket!.onDisconnect((reason) {
      _state = SyncConnectionState.disconnected;
      _logEvent('DISCONNECTED', 'Connection closed: $reason (Server stopped or network down)', isSuccess: false);
      notifyListeners();
    });

    _socket!.onConnectError((err) {
      _state = SyncConnectionState.reconnecting;
      _logEvent('CONNECT_ERROR', 'Handshake failed: $err. Retrying...', isSuccess: false);
      notifyListeners();
    });

    _socket!.on('server_shutdown', (_) {
      _state = SyncConnectionState.disconnected;
      _logEvent('SERVER_SHUTDOWN', 'Server issued graceful shutdown packet. Client disconnected.', isSuccess: false);
      notifyListeners();
    });
  }

  Future<void> _persistProfile(ConnectionHistoryProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(profile.toJson()));
  }

  void _logEvent(String eventType, String message, {bool isSuccess = true}) {
    _connectionChangelog.insert(0, {
      'timestamp': DateTime.now().toIso8601String(),
      'type': eventType,
      'message': message,
      'isSuccess': isSuccess,
    });
    if (_connectionChangelog.length > 50) _connectionChangelog.removeLast();
  }

  void disconnectManual() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _state = SyncConnectionState.disconnected;
    _logEvent('MANUAL_DISCONNECT', 'Client disconnected manually by user.');
    notifyListeners();
  }
}
