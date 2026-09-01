import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

enum AppNodeRole { host, client, unconfigured }
enum SyncConnectionState { connected, disconnected, connecting, reconnecting, hosting }

class NodeProfileConfig {
  final AppNodeRole role;
  final String serverUrl;       // Used if role == client
  final int hostPort;           // Used if role == host (default 3000)
  final String mode;            // 'LAN' or 'CLOUD'
  final DateTime lastActive;
  final String? authToken;

  const NodeProfileConfig({
    required this.role,
    required this.serverUrl,
    this.hostPort = 3000,
    required this.mode,
    required this.lastActive,
    this.authToken,
  });

  Map<String, dynamic> toJson() => {
    'role': role.name,
    'serverUrl': serverUrl,
    'hostPort': hostPort,
    'mode': mode,
    'lastActive': lastActive.toIso8601String(),
    'authToken': authToken,
  };

  factory NodeProfileConfig.fromJson(Map<String, dynamic> json) {
    return NodeProfileConfig(
      role: AppNodeRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => AppNodeRole.unconfigured,
      ),
      serverUrl: json['serverUrl'] as String? ?? '',
      hostPort: json['hostPort'] as int? ?? 3000,
      mode: json['mode'] as String? ?? 'LAN',
      lastActive: DateTime.tryParse(json['lastActive'] as String? ?? '') ?? DateTime.now(),
      authToken: json['authToken'] as String?,
    );
  }
}

class SyncConnectionManager extends ChangeNotifier {
  static const String _storageKey = 'omni_node_profile_state';

  AppNodeRole _activeRole = AppNodeRole.unconfigured;
  SyncConnectionState _state = SyncConnectionState.disconnected;
  NodeProfileConfig? _cachedProfile;
  io.Socket? _clientSocket;
  final List<Map<String, dynamic>> _connectionChangelog = [];
  int _latencyMs = 0;

  AppNodeRole get activeRole => _activeRole;
  SyncConnectionState get state => _state;
  bool get isConnected => _state == SyncConnectionState.connected || _state == SyncConnectionState.hosting;
  bool get isHost => _activeRole == AppNodeRole.host;
  int get latencyMs => _latencyMs;
  NodeProfileConfig? get cachedProfile => _cachedProfile;
  List<Map<String, dynamic>> get connectionChangelog => List.unmodifiable(_connectionChangelog);

  /// Auto-boots on app launch, restoring host or client mode from persistent storage
  Future<void> bootstrapAutoConnect() async {
    final prefs = await SharedPreferences.getInstance();
    final rawJson = prefs.getString(_storageKey);

    if (rawJson != null) {
      try {
        final decoded = jsonDecode(rawJson) as Map<String, dynamic>;
        _cachedProfile = NodeProfileConfig.fromJson(decoded);

        if (_cachedProfile != null && _cachedProfile!.role != AppNodeRole.unconfigured) {
          _logEvent('ROLE_RESTORE', 'Restoring last known node role: ${_cachedProfile!.role.name.toUpperCase()}');
          if (_cachedProfile!.role == AppNodeRole.host) {
            await startHostMode(port: _cachedProfile!.hostPort, persist: false);
          } else if (_cachedProfile!.role == AppNodeRole.client) {
            await connectAsClient(
              _cachedProfile!.serverUrl,
              _cachedProfile!.mode,
              authToken: _cachedProfile!.authToken,
              persist: false,
            );
          }
        }
      } catch (e) {
        _logEvent('BOOTSTRAP_ERROR', 'Failed to restore node profile state: $e', isSuccess: false);
      }
    } else {
      _logEvent('BOOTSTRAP_IDLE', 'No previous node role found. Awaiting First-Run Wizard setup.');
    }
  }

  /// Configures and launches the application as a Host Server
  Future<void> startHostMode({int port = 3000, bool persist = true}) async {
    _activeRole = AppNodeRole.host;
    _state = SyncConnectionState.hosting;
    _latencyMs = 0;

    _clientSocket?.dispose();
    _clientSocket = null;

    final profile = NodeProfileConfig(
      role: AppNodeRole.host,
      serverUrl: 'http://localhost:$port',
      hostPort: port,
      mode: 'LAN',
      lastActive: DateTime.now(),
    );

    _cachedProfile = profile;
    if (persist) await _persistProfile(profile);

    _logEvent('HOST_STARTED', 'Operating as Host Master on port $port', isSuccess: true);
    notifyListeners();
  }

  /// Configures and connects the application as a Client Terminal
  Future<void> connectAsClient(
    String serverUrl,
    String mode, {
    String? authToken,
    bool persist = true,
  }) async {
    _activeRole = AppNodeRole.client;
    _state = SyncConnectionState.connecting;
    notifyListeners();

    _clientSocket?.dispose();
    final stopwatch = Stopwatch()..start();

    _clientSocket = io.io(
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

    _clientSocket!.onConnect((_) async {
      stopwatch.stop();
      _latencyMs = stopwatch.elapsedMilliseconds;
      _state = SyncConnectionState.connected;

      final profile = NodeProfileConfig(
        role: AppNodeRole.client,
        serverUrl: serverUrl,
        mode: mode,
        lastActive: DateTime.now(),
        authToken: authToken,
      );

      _cachedProfile = profile;
      if (persist) await _persistProfile(profile);

      _logEvent('CLIENT_CONNECTED', 'Connected to host $serverUrl (${_latencyMs}ms)', isSuccess: true);
      notifyListeners();
    });

    _clientSocket!.onDisconnect((reason) {
      _state = SyncConnectionState.disconnected;
      _logEvent('DISCONNECTED', 'Connection closed: $reason', isSuccess: false);
      notifyListeners();
    });

    _clientSocket!.onConnectError((err) {
      _state = SyncConnectionState.reconnecting;
      _logEvent('CONNECT_ERROR', 'Failed to reach host: $err. Retrying...', isSuccess: false);
      notifyListeners();
    });

    _clientSocket!.on('server_shutdown', (_) {
      _state = SyncConnectionState.disconnected;
      _logEvent('SERVER_SHUTDOWN', 'Host server terminated. Switched to offline.', isSuccess: false);
      notifyListeners();
    });
  }

  /// Updates node role dynamically and saves the change
  Future<void> switchRole(AppNodeRole newRole, {String? serverUrl, int port = 3000}) async {
    if (newRole == AppNodeRole.host) {
      await startHostMode(port: port, persist: true);
    } else if (newRole == AppNodeRole.client && serverUrl != null) {
      await connectAsClient(serverUrl, 'LAN', persist: true);
    } else {
      _activeRole = AppNodeRole.unconfigured;
      _state = SyncConnectionState.disconnected;
      _clientSocket?.dispose();
      _clientSocket = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
      _logEvent('ROLE_RESET', 'Node role reset to unconfigured.');
      notifyListeners();
    }
  }

  Future<void> _persistProfile(NodeProfileConfig profile) async {
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
    _clientSocket?.disconnect();
    _clientSocket?.dispose();
    _clientSocket = null;
    _state = SyncConnectionState.disconnected;
    _logEvent('MANUAL_DISCONNECT', 'Client disconnected manually by user.');
    notifyListeners();
  }
}
