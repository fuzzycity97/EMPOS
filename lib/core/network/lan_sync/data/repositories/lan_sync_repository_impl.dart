import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/connected_node.dart';
import '../../domain/entities/sync_envelope.dart';
import '../../domain/entities/sync_envelope_signing.dart';
import '../../domain/repositories/lan_sync_repository.dart';
import '../device_pairing_secret_store.dart';
import '../message_routes.dart';
import '../services/lan_discovery_service.dart';

class LanSyncRepositoryImpl implements LanSyncRepository {
  LanSyncRepositoryImpl({DevicePairingSecretStore? secretStore})
      : _secretStore = secretStore;

  final DevicePairingSecretStore? _secretStore;
  static const String offlineQueueBoxName = 'empos_offline_sync_queue';
  static const String _lanProfileStorageKey = 'empos_lan_sync_profile';

  HttpServer? _server;
  WebSocketChannel? _clientChannel;
  StreamSubscription? _clientSubscription;
  Timer? _reconnectTimer;
  Timer? _hostHeartbeatTimer;
  Timer? _clientWatchdogTimer;
  final List<Timer> _pendingTimers = [];

  final LanDiscoveryService _discoveryService = LanDiscoveryService();

  String? _targetHostIp;
  int _targetPort = 9090;
  bool _shouldAutoReconnect = false;
  bool _isReconnecting = false;
  int _reconnectAttempts = 0;

  final Set<WebSocketChannel> _activeChannels = {};
  final Map<WebSocketChannel, ConnectedNode> _nodeMap = {};
  final Map<WebSocketChannel, DateTime> _channelLastSeen = {};
  DateTime? _lastHostContact;

  ConnectedNode? _hostNode;
  List<ConnectedNode> _clientNetworkNodes = [];

  final StreamController<SyncEnvelope> _incomingEventsController =
      StreamController<SyncEnvelope>.broadcast();
  final StreamController<List<ConnectedNode>> _connectedNodesController =
      StreamController<List<ConnectedNode>>.broadcast();

  bool _isHost = false;
  bool _isConnected = false;

  @override
  Stream<SyncEnvelope> get incomingEvents => _incomingEventsController.stream;

  @override
  Stream<List<ConnectedNode>> get connectedNodesStream =>
      _connectedNodesController.stream;

  @override
  Stream<List<DiscoveredHost>> get discoveredHostsStream =>
      _discoveryService.discoveredHostsStream;

  @override
  List<DiscoveredHost> get discoveredHosts => _discoveryService.discoveredHosts;

  @override
  void startDiscoveryScanner() => _discoveryService.startListening();

  @override
  void stopDiscoveryScanner() => _discoveryService.stopListening();

  @override
  List<ConnectedNode> get connectedNodes {
    final result = <ConnectedNode>[];

    if (_isHost) {
      if (_hostNode != null) {
        result.add(_hostNode!);
      }
      final clientSeen = <String>{};
      for (final node in _nodeMap.values) {
        final id = node.id.toLowerCase();
        if (!clientSeen.contains(id)) {
          clientSeen.add(id);
          result.add(node);
        }
      }
      return result;
    }

    final seen = <String>{};
    for (final node in _clientNetworkNodes) {
      final id = node.id.toLowerCase();
      if (!seen.contains(id)) {
        seen.add(id);
        result.add(node);
      }
    }
    return result;
  }

  @override
  bool get isHost => _isHost;

  @override
  bool get isConnected => _isConnected;

  static String? _instanceIdOverride;
  static String? _localRoleOverride;
  static String? _localAppNameOverride;
  static String? _primaryLocalIpOverride;

  static void setInstanceIdOverride(String? id) => _instanceIdOverride = id;
  static void setLocalRoleOverride(String? role) => _localRoleOverride = role;
  static void setLocalAppNameOverride(String? app) => _localAppNameOverride = app;
  static String? get localAppNameOverride => _localAppNameOverride;
  static void setPrimaryLocalIpOverride(String? ip) => _primaryLocalIpOverride = ip;

  static String getLocalInstanceId() {
    if (_instanceIdOverride != null && _instanceIdOverride!.isNotEmpty) {
      return _instanceIdOverride!;
    }
    const envId = String.fromEnvironment('INSTANCE_ID', defaultValue: '');
    if (envId.isNotEmpty) return envId;
    try {
      final name = Platform.localHostname.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
      return name.isNotEmpty ? 'station-$name' : 'station-local';
    } catch (_) {
      return 'station-local';
    }
  }

  static String getLocalStationRole({bool isHost = false}) {
    if (_localRoleOverride != null && _localRoleOverride!.isNotEmpty) {
      return _localRoleOverride!;
    }
    final id = getLocalInstanceId().toLowerCase();
    if (id.contains('god') || id.contains('tech') || id.contains('admin')) {
      return isHost ? 'Technician Hub (Host God Mode)' : 'Technician Hub (God Mode)';
    }
    if (id.contains('doc')) return 'Doctor Station';
    if (id.contains('recept')) return isHost ? 'Reception Desk (Host)' : 'Reception Desk';
    if (id.contains('cashier') || id.contains('pos')) return 'POS Cashier';
    if (isHost) return 'Primary Hub Host';
    return 'Client Station';
  }

  static Future<String> getPrimaryLocalIp() async {
    if (_primaryLocalIpOverride != null && _primaryLocalIpOverride!.isNotEmpty) {
      return _primaryLocalIpOverride!;
    }
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return '127.0.0.1';
    }
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      ).timeout(const Duration(milliseconds: 600), onTimeout: () => []);
      for (final interface in interfaces) {
        for (final addr in interface.addresses) {
          if (!addr.isLoopback && !addr.isLinkLocal) {
            return addr.address;
          }
        }
      }
    } catch (_) {}
    return '127.0.0.1';
  }

  /// Validates IPv4 syntax with descriptive exceptions
  static void validateIpSyntax(String hostIp) {
    final clean = hostIp.trim();
    if (clean.isEmpty) {
      throw const FormatException('Host IP address cannot be empty.');
    }
    if (clean.toLowerCase() == 'localhost' || clean == '127.0.0.1') {
      return;
    }
    final parsed = InternetAddress.tryParse(clean);
    if (parsed == null || parsed.type != InternetAddressType.IPv4) {
      throw FormatException('Invalid IP format "$clean". Please enter a valid IPv4 address (e.g. 192.168.1.50).');
    }
  }

  /// Fast TCP pre-flight check to provide instantaneous diagnostic feedback
  static Future<void> preflightCheck(String hostIp, int port) async {
    validateIpSyntax(hostIp);
    final clean = hostIp.trim();

    // Fast-path bypass for unit test environments
    if (Platform.environment.containsKey('FLUTTER_TEST') && (clean == '127.0.0.1' || clean == 'localhost')) {
      return;
    }

    try {
      final socket = await Socket.connect(clean, port, timeout: const Duration(milliseconds: 2500));
      await socket.close();
    } on SocketException catch (e) {
      final code = e.osError?.errorCode ?? 0;
      final msg = e.message.toLowerCase();
      if (code == 1225 || code == 111 || msg.contains('connection refused') || msg.contains('refused')) {
        throw SocketException(
          'No EMPOS Host Server is running at $clean:$port.\n'
          'Verify that the Host Server is started on that PC.',
        );
      } else if (code == 10051 || code == 113 || msg.contains('unreachable') || msg.contains('no route')) {
        throw SocketException(
          'Host $clean is unreachable.\n'
          'Ensure both this station and the Host PC are on the same Wi-Fi / LAN network.',
        );
      } else {
        throw SocketException('Cannot connect to $clean:$port: ${e.message}');
      }
    } on TimeoutException {
      throw TimeoutException(
        'Connection to $clean:$port timed out.\n'
        'Check the IP address or verify that Windows Firewall is not blocking port $port.',
      );
    }
  }

  static Future<String?> discoverHostServer({int port = 9090}) async {
    // 1. Probe localhost first (e.g. multi-instance on same desktop)
    try {
      final socket = await Socket.connect('127.0.0.1', port, timeout: const Duration(milliseconds: 150));
      socket.destroy();
      return '127.0.0.1';
    } catch (_) {}

    // 2. Probe last saved IP from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedIp = prefs.getString('empos_last_connected_host_ip');
      if (savedIp != null && savedIp.isNotEmpty && savedIp != '127.0.0.1') {
        final socket = await Socket.connect(savedIp, port, timeout: const Duration(milliseconds: 300));
        socket.destroy();
        return savedIp;
      }
    } catch (_) {}

    // 3. Scan local network subnet
    try {
      final localIp = await getPrimaryLocalIp();
      if (localIp != '127.0.0.1' && localIp.contains('.')) {
        final subnet = localIp.substring(0, localIp.lastIndexOf('.') + 1);
        final completer = Completer<String?>();
        var pending = 0;
        for (var i = 1; i <= 254; i++) {
          final ip = '$subnet$i';
          if (ip == localIp) continue;
          pending++;
          Socket.connect(ip, port, timeout: const Duration(milliseconds: 500)).then((s) {
            s.destroy();
            if (!completer.isCompleted) {
              completer.complete(ip);
            }
          }).catchError((_) {
            pending--;
            if (pending <= 0 && !completer.isCompleted) {
              completer.complete(null);
            }
          });
        }

        final discovered = await completer.future.timeout(
          const Duration(milliseconds: 800),
          onTimeout: () => null,
        );
        if (discovered != null) return discovered;
      }
    } catch (_) {}

    return null;
  }

  Future<Box<dynamic>?> _getOfflineQueueBox() async {
    try {
      return await Hive.openBox<dynamic>(offlineQueueBoxName).catchError((_) {
        return null as dynamic;
      });
    } catch (_) {
      return null;
    }
  }

  Future<void> _enqueueOffline(String rawJson) async {
    try {
      final box = await _getOfflineQueueBox();
      if (box != null && box.isOpen) {
        final key = 'outbox_${DateTime.now().microsecondsSinceEpoch}_${box.length}';
        await box.put(key, rawJson);
      }
    } catch (_) {}
  }

  Future<void> _flushOfflineQueue() async {
    try {
      final box = await _getOfflineQueueBox();
      if (box == null || !box.isOpen || box.isEmpty) return;

      final keys = box.keys.toList();
      for (final key in keys) {
        final raw = box.get(key);
        if (raw != null) {
          final rawStr = raw.toString();
          if (_isHost) {
            for (final ch in _activeChannels) {
              _safeSend(ch, rawStr);
            }
          } else if (_clientChannel != null && _isConnected) {
            _safeSend(_clientChannel, rawStr);
          }
          await box.delete(key);
        }
      }
    } catch (_) {}
  }

  bool _safeSend(WebSocketChannel? channel, String rawData) {
    if (channel == null) return false;
    try {
      channel.sink.add(rawData);
      return true;
    } catch (e) {
      debugPrint('LanSync safeSend suppressed: $e');
      return false;
    }
  }

  @override
  Future<void> startHostServer({int port = 9090}) async {
    await disconnect();

    final localIp = await getPrimaryLocalIp();
    final localId = getLocalInstanceId();
    final localRole = getLocalStationRole(isHost: true);

    _hostNode = ConnectedNode(
      id: localId.isNotEmpty ? localId : 'host-server',
      role: localRole,
      ipAddress: localIp,
    );

    final wsHandler = webSocketHandler((WebSocketChannel channel) {
      final nodeId = 'station-${DateTime.now().millisecondsSinceEpoch}-${_activeChannels.length + 1}';
      final placeholderNode = ConnectedNode(
        id: nodeId,
        role: 'Client Station',
        ipAddress: 'lan_peer',
      );

      _activeChannels.add(channel);
      _nodeMap[channel] = placeholderNode;
      _channelLastSeen[channel] = DateTime.now();

      if (!_connectedNodesController.isClosed) {
        _connectedNodesController.add(connectedNodes);
      }

      // Flush offline outbox queue to the newly joined peer
      _flushOfflineQueue();

      channel.stream.listen(
        (data) {
          try {
            _channelLastSeen[channel] = DateTime.now();
            final raw = data.toString();
            final envelope = SyncEnvelope.fromRawJson(raw);

            // Handle Heartbeat Pong
            if (envelope.type == MessageRoutes.pong) {
              return;
            }

            // Handle Heartbeat Ping (reply with pong)
            if (envelope.type == MessageRoutes.ping) {
              final pong = SyncEnvelope.create(
                type: MessageRoutes.pong,
                senderId: _hostNode?.id ?? 'host-server',
                senderRole: _hostNode?.role ?? 'Hub Host Server',
              );
              _safeSend(channel, pong.toRawJson());
              return;
            }

            // Handle Node Joined Handshake
            if (envelope.type == MessageRoutes.nodeJoined) {
              final senderId = envelope.senderId.isNotEmpty ? envelope.senderId : placeholderNode.id;
              final senderRole = envelope.senderRole.isNotEmpty ? envelope.senderRole : placeholderNode.role;
              final senderIp = envelope.payload?['ip']?.toString() ?? placeholderNode.ipAddress;
              final appName = envelope.payload?['appName']?.toString();

              // If an existing channel in _nodeMap already had this senderId, evict and close the older one
              final staleChannels = <WebSocketChannel>[];
              _nodeMap.forEach((ch, existingNode) {
                if (ch != channel && existingNode.id.toLowerCase() == senderId.toLowerCase()) {
                  staleChannels.add(ch);
                }
              });
              for (final stale in staleChannels) {
                _activeChannels.remove(stale);
                _nodeMap.remove(stale);
                _channelLastSeen.remove(stale);
                try {
                  stale.sink.close();
                } catch (_) {}
              }

              final realNode = ConnectedNode(
                id: senderId,
                role: senderRole,
                ipAddress: senderIp,
                appName: appName,
                connectedAt: DateTime.now(),
              );
              _nodeMap[channel] = realNode;

              if (!_connectedNodesController.isClosed) {
                _connectedNodesController.add(connectedNodes);
              }

              // Send back peer list update to all connected stations
              _broadcastPeerListToClients();
            } else if (envelope.type == MessageRoutes.nodeLeft) {
              _activeChannels.remove(channel);
              _nodeMap.remove(channel);
              _channelLastSeen.remove(channel);
              if (!_connectedNodesController.isClosed) {
                _connectedNodesController.add(connectedNodes);
              }
              _broadcastPeerListToClients();
            }

            if (wouldAcceptEnvelope(envelope) && !_incomingEventsController.isClosed) {
              _incomingEventsController.add(envelope);
            }

            // Relay to all other connected clients (Hub topology)
            for (final other in _activeChannels) {
              if (other != channel) {
                _safeSend(other, raw);
              }
            }
          } catch (_) {}
        },
        onDone: () {
          _activeChannels.remove(channel);
          _nodeMap.remove(channel);
          _channelLastSeen.remove(channel);
          if (!_connectedNodesController.isClosed) {
            _connectedNodesController.add(connectedNodes);
          }
          _broadcastPeerListToClients();
        },
        onError: (err) {
          _activeChannels.remove(channel);
          _nodeMap.remove(channel);
          _channelLastSeen.remove(channel);
          if (!_connectedNodesController.isClosed) {
            _connectedNodesController.add(connectedNodes);
          }
          _broadcastPeerListToClients();
        },
        cancelOnError: true,
      );
    });

    // Shelf cascade handler: serves HTTP /health and /status, passes WebSocket upgrades through
    final cascade = shelf.Cascade().add((shelf.Request request) {
      final isUpgrade = request.headers['upgrade']?.toLowerCase() == 'websocket';
      if (!isUpgrade &&
          request.method == 'GET' &&
          (request.url.path == 'health' || request.url.path == 'status')) {
        return shelf.Response.ok(
          jsonEncode({
            'status': 'active',
            'app': 'EMPOS',
            'isHost': true,
            'hostId': _hostNode?.id ?? 'host-server',
            'port': port,
            'connectedStations': _activeChannels.length,
            'timestamp': DateTime.now().toIso8601String(),
          }),
          headers: {
            'content-type': 'application/json',
            'access-control-allow-origin': '*',
          },
        );
      }
      return wsHandler(request);
    });

    _server = await shelf_io.serve(cascade.handler, InternetAddress.anyIPv4, port, shared: false);
    _isHost = true;
    _isConnected = true;

    // Start UDP Host Beacon for Zero-Config Client Auto-Discovery
    _discoveryService.startHostBeacon(
      hostId: localId,
      hostRole: localRole,
      hostIp: localIp,
      port: port,
    );

    // Start 6-Second Bidirectional Ping-Pong Heartbeat
    _hostHeartbeatTimer?.cancel();
    _hostHeartbeatTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (!_isHost || _server == null) return;

      final now = DateTime.now();
      final deadChannels = <WebSocketChannel>[];

      // Prune inactive channels that missed 2 consecutive pings (16s)
      _channelLastSeen.forEach((channel, lastSeen) {
        if (now.difference(lastSeen).inSeconds > 16) {
          deadChannels.add(channel);
        }
      });

      for (final dead in deadChannels) {
        _activeChannels.remove(dead);
        _nodeMap.remove(dead);
        _channelLastSeen.remove(dead);
        try {
          dead.sink.close();
        } catch (_) {}
      }

      if (deadChannels.isNotEmpty) {
        if (!_connectedNodesController.isClosed) {
          _connectedNodesController.add(connectedNodes);
        }
        _broadcastPeerListToClients();
      }

      // Send Ping envelope to all surviving stations
      final ping = SyncEnvelope.create(
        type: MessageRoutes.ping,
        senderId: _hostNode?.id ?? 'host-server',
        senderRole: _hostNode?.role ?? 'Hub Host Server',
      );
      final raw = ping.toRawJson();
      for (final ch in _activeChannels) {
        _safeSend(ch, raw);
      }
    });

    // Persist Host profile for auto-reconnection on next boot
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lanProfileStorageKey, jsonEncode({
        'role': 'host',
        'port': port,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (_) {}

    if (!_connectedNodesController.isClosed) {
      _connectedNodesController.add(connectedNodes);
    }
  }

  void _broadcastPeerListToClients() {
    if (!_isHost || _activeChannels.isEmpty) return;

    final peerListEnvelope = SyncEnvelope.create(
      type: MessageRoutes.peerListUpdate,
      senderId: _hostNode?.id ?? 'host-server',
      senderRole: _hostNode?.role ?? 'Hub Host Server',
      payload: {
        'nodes': connectedNodes.map((n) => n.toJson()).toList(),
      },
    );

    final raw = peerListEnvelope.toRawJson();
    for (final channel in _activeChannels) {
      _safeSend(channel, raw);
    }
  }

  @override
  Future<void> connectToHost(String hostIp, {int port = 9090}) async {
    await disconnect();

    _shouldAutoReconnect = true;
    _targetHostIp = hostIp.trim();
    _targetPort = port;
    _reconnectAttempts = 0;

    // Persist Client profile for auto-reconnection on next boot
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lanProfileStorageKey, jsonEncode({
        'role': 'client',
        'hostIp': _targetHostIp,
        'port': port,
        'timestamp': DateTime.now().toIso8601String(),
      }));
      await prefs.setString('empos_last_connected_host_ip', hostIp);
    } catch (_) {}

    await _establishClientConnection(_targetHostIp!, port, isRetry: false);
  }

  Future<void> _establishClientConnection(String hostIp, int port, {bool isRetry = false}) async {
    // Run instant pre-flight diagnostic check on first attempt
    if (!isRetry) {
      await preflightCheck(hostIp, port);
    }

    try {
      final uri = Uri.parse('ws://$hostIp:$port');
      final channel = WebSocketChannel.connect(uri);

      // Await connection handshake with a 3.5-second timeout
      await channel.ready.timeout(
        const Duration(milliseconds: 3500),
        onTimeout: () => throw TimeoutException('Connection to $hostIp:$port timed out.'),
      );

      _clientChannel = channel;
      _isHost = false;
      _isConnected = true;
      _reconnectAttempts = 0;
      _isReconnecting = false;
      _lastHostContact = DateTime.now();

      final localIp = await getPrimaryLocalIp();
      final localId = getLocalInstanceId();
      final localRole = getLocalStationRole(isHost: false);

      final clientSelfNode = ConnectedNode(
        id: localId,
        role: localRole,
        ipAddress: localIp,
      );

      // Initialize network nodes with self and host
      _clientNetworkNodes = [
        ConnectedNode(id: 'host-server', role: 'Hub Host', ipAddress: hostIp),
        clientSelfNode,
      ];

      if (!_connectedNodesController.isClosed) {
        _connectedNodesController.add(_clientNetworkNodes);
      }

      _clientSubscription = channel.stream.listen(
        (data) {
          try {
            _lastHostContact = DateTime.now();
            final raw = data.toString();
            final envelope = SyncEnvelope.fromRawJson(raw);

            // Respond to Host Ping with Pong
            if (envelope.type == MessageRoutes.ping) {
              final pong = SyncEnvelope.create(
                type: MessageRoutes.pong,
                senderId: localId,
                senderRole: localRole,
              );
              _safeSend(_clientChannel, pong.toRawJson());
              return;
            }

            // Handle Peer List Update from Host
            if (envelope.type == MessageRoutes.peerListUpdate ||
                envelope.type == MessageRoutes.nodeJoinedAck) {
              final rawNodes = envelope.payload?['nodes'] as List<dynamic>?;
              if (rawNodes != null) {
                _clientNetworkNodes = rawNodes
                    .whereType<Map>()
                    .map((n) => ConnectedNode.fromJson(Map<String, dynamic>.from(n)))
                    .toList();
                if (!_connectedNodesController.isClosed) {
                  _connectedNodesController.add(_clientNetworkNodes);
                }
              }
            }

            if (wouldAcceptEnvelope(envelope) && !_incomingEventsController.isClosed) {
              _incomingEventsController.add(envelope);
            }
          } catch (_) {}
        },
        onDone: () {
          _handleClientDisconnect();
        },
        onError: (err) {
          _handleClientDisconnect();
        },
        cancelOnError: true,
      );

      // Setup Client Watchdog Timer: Checks host liveness every 5 seconds
      _clientWatchdogTimer?.cancel();
      _clientWatchdogTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!_isConnected || _clientChannel == null) return;
        if (_lastHostContact != null &&
            DateTime.now().difference(_lastHostContact!).inSeconds > 16) {
          debugPrint('LanSync: Host heartbeat lost (>16s). Initiating auto-reconnect...');
          _handleClientDisconnect();
        }
      });

      // Send node joined handshake with real instance ID and role
      final joinEnvelope = SyncEnvelope.create(
        type: MessageRoutes.nodeJoined,
        senderId: localId,
        senderRole: localRole,
        payload: {
          'ip': localIp,
          'hostname': Platform.localHostname,
          if (_localAppNameOverride != null) 'appName': _localAppNameOverride,
        },
      );
      await broadcast(joinEnvelope);

      // Flush offline outbox queue BEFORE state reconciliation
      await _flushOfflineQueue();

      // Multi-ping handshake: send at 1s, 3s, and 6s to guarantee state reconciliation
      void sendStateRequest() {
        if (_isConnected && _clientChannel != null) {
          final syncRequestEnvelope = SyncEnvelope.create(
            type: MessageRoutes.syncRequestActiveState,
            senderId: localId,
            senderRole: localRole,
          );
          broadcast(syncRequestEnvelope);
        }
      }

      _pendingTimers.add(Timer(const Duration(milliseconds: 1000), sendStateRequest));
      _pendingTimers.add(Timer(const Duration(seconds: 3), sendStateRequest));
      _pendingTimers.add(Timer(const Duration(seconds: 6), sendStateRequest));
    } catch (e) {
      _handleClientDisconnect();
      rethrow;
    }
  }

  void _handleClientDisconnect() {
    _isConnected = false;
    _clientSubscription?.cancel();
    _clientSubscription = null;
    _clientChannel = null;
    _clientNetworkNodes = [];
    _clientWatchdogTimer?.cancel();
    _clientWatchdogTimer = null;

    _cancelPendingTimers();

    if (!_connectedNodesController.isClosed) {
      _connectedNodesController.add([]);
    }

    if (_shouldAutoReconnect && !_isHost && _targetHostIp != null) {
      _scheduleReconnect();
    }
  }

  void _cancelPendingTimers() {
    for (final timer in _pendingTimers) {
      timer.cancel();
    }
    _pendingTimers.clear();
  }

  void _scheduleReconnect() {
    if (!_shouldAutoReconnect || _isConnected || _isHost || _targetHostIp == null) {
      return;
    }
    if (_isReconnecting) return;

    _reconnectTimer?.cancel();

    // Exponential backoff: 2s, 4s, 8s, max 16s + jitter
    final baseSeconds = math.min(16, 2 * math.pow(2, math.min(3, _reconnectAttempts)).toInt());
    final jitterMs = math.Random().nextInt(600);
    final delay = Duration(milliseconds: (baseSeconds * 1000) + jitterMs);

    _reconnectTimer = Timer(delay, () async {
      if (!_shouldAutoReconnect || _isConnected || _isHost || _targetHostIp == null) {
        return;
      }
      _isReconnecting = true;
      try {
        await _establishClientConnection(_targetHostIp!, _targetPort, isRetry: true);
        _reconnectAttempts = 0;
      } catch (_) {
        _reconnectAttempts++;
        if (_shouldAutoReconnect && !_isConnected && !_isHost) {
          _isReconnecting = false;
          _scheduleReconnect();
        }
      } finally {
        _isReconnecting = false;
      }
    });
  }

  @override
  Future<void> broadcast(SyncEnvelope envelope) async {
    SyncEnvelope outgoing = envelope;
    if (_clusterSecretHex != null && _clusterSecretHex!.isNotEmpty && envelope.signature == null) {
      final sig = EnvelopeSigner.sign(
        canonicalPayload: EnvelopeSigner.canonicalize(
          type: envelope.type,
          scope: envelope.scope,
          senderRole: envelope.senderRole,
          senderId: envelope.senderId,
          payload: envelope.payload,
          timestampEpochMs: envelope.ts,
        ),
        sharedSecretHex: _clusterSecretHex!,
      );
      outgoing = envelope.copyWith(signature: sig);
    }

    final raw = outgoing.toRawJson();

    final isTransient = envelope.type == MessageRoutes.syncRequestActiveState ||
        envelope.type == MessageRoutes.nodeJoined ||
        envelope.type == MessageRoutes.nodeJoinedAck ||
        envelope.type == MessageRoutes.peerListUpdate ||
        envelope.type == MessageRoutes.nodeLeft ||
        envelope.type == MessageRoutes.ping ||
        envelope.type == MessageRoutes.pong;

    if (_isHost) {
      if (_activeChannels.isNotEmpty) {
        // Broadcast to all connected clients
        for (final channel in _activeChannels) {
          _safeSend(channel, raw);
        }
      } else if (!isTransient) {
        // Host has no connected peers - queue envelope in outbox
        await _enqueueOffline(raw);
      }
      // Also notify local listeners
      if (!_incomingEventsController.isClosed) {
        _incomingEventsController.add(envelope);
      }
    } else {
      if (_clientChannel != null && _isConnected) {
        final sent = _safeSend(_clientChannel, raw);
        if (!sent && !isTransient) {
          await _enqueueOffline(raw);
        }
      } else if (!isTransient) {
        // Client is offline - queue envelope in outbox
        await _enqueueOffline(raw);
      }
    }
  }

  @override
  Future<void> disconnect({bool clearPersistedRole = true}) async {
    _shouldAutoReconnect = false;
    _isReconnecting = false;
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _hostHeartbeatTimer?.cancel();
    _hostHeartbeatTimer = null;
    _clientWatchdogTimer?.cancel();
    _clientWatchdogTimer = null;
    _cancelPendingTimers();

    await _discoveryService.stopHostBeacon();

    // If client, notify host gracefully
    if (!_isHost && _clientChannel != null && _isConnected) {
      try {
        final leaveEnvelope = SyncEnvelope.create(
          type: MessageRoutes.nodeLeft,
          senderId: getLocalInstanceId(),
          senderRole: getLocalStationRole(isHost: false),
        );
        _safeSend(_clientChannel, leaveEnvelope.toRawJson());
      } catch (_) {}
    }

    // Close client subscription and channel
    await _clientSubscription?.cancel();
    _clientSubscription = null;
    await _clientChannel?.sink.close();
    _clientChannel = null;

    // Close all host active client channels
    final channelsToClose = _activeChannels.toList();
    _activeChannels.clear();
    _nodeMap.clear();
    _channelLastSeen.clear();
    _hostNode = null;
    _clientNetworkNodes = [];

    for (final ch in channelsToClose) {
      try {
        await ch.sink.close();
      } catch (_) {}
    }

    // Close host server
    if (_server != null) {
      await _server!.close(force: true);
      _server = null;
    }

    _isHost = false;
    _isConnected = false;
    if (!_connectedNodesController.isClosed) {
      _connectedNodesController.add([]);
    }

    if (clearPersistedRole) {
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_lanProfileStorageKey);
      } catch (_) {}
    }
  }

  @override
  Future<void> autoRestoreConnection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_lanProfileStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final data = jsonDecode(raw) as Map<String, dynamic>;
        final role = data['role'] as String?;
        final port = data['port'] as int? ?? 9090;
        final hostIp = data['hostIp'] as String?;

        if (role == 'host') {
          await startHostServer(port: port);
        } else if (role == 'client' && hostIp != null && hostIp.isNotEmpty) {
          await connectToHost(hostIp, port: port);
        }
      }
    } catch (_) {}
  }

  @override
  Future<void> updateStationIdentity({
    required String id,
    required String role,
    String? appName,
  }) async {
    _instanceIdOverride = id;
    _localRoleOverride = role;
    _localAppNameOverride = appName;

    if (_isConnected) {
      final localIp = await getPrimaryLocalIp();
      final handshake = SyncEnvelope.create(
        type: MessageRoutes.nodeJoined,
        senderId: id,
        senderRole: role,
        payload: {
          'ip': localIp,
          'hostname': Platform.localHostname,
          'appName': appName ?? (role.toLowerCase().contains('doctor')
              ? 'EMPOS Clinical / Dental Suite'
              : role.toLowerCase().contains('recept')
                  ? 'EMPOS Front-Desk Reception Suite'
                  : 'EMPOS Client Workstation'),
        },
      );
      try {
        await broadcast(handshake);
      } catch (_) {}
    }

    if (!_connectedNodesController.isClosed) {
      _connectedNodesController.add(connectedNodes);
    }
  }

  static String? _clusterSecretHex;
  static void setClusterSecretHex(String? secret) => _clusterSecretHex = secret;
  static String? get clusterSecretHex => _clusterSecretHex;

  @override
  bool wouldAcceptEnvelope(SyncEnvelope envelope) {
    final role = envelope.senderRole.toLowerCase();
    final type = envelope.type.toLowerCase();
    final isPrivileged = role.contains('admin') ||
        role.contains('god') ||
        role.contains('tech') ||
        type.startsWith('rmm.') ||
        type.contains('command');

    // Reject unsigned or invalid privileged envelopes immediately
    if (isPrivileged) {
      if (envelope.signature == null || envelope.signature!.isEmpty) {
        return false;
      }

      final peerSecret = _secretStore?.getSecretForPeerSync(envelope.senderId);
      final secret = peerSecret ?? _clusterSecretHex;
      if (secret == null || secret.isEmpty) {
        // Node has no secret configured or paired for this peer to authenticate admin commands
        return false;
      }

      final canonical = EnvelopeSigner.canonicalize(
        type: envelope.type,
        scope: envelope.scope,
        senderRole: envelope.senderRole,
        senderId: envelope.senderId,
        payload: envelope.payload,
        timestampEpochMs: envelope.ts,
      );

      final isValid = EnvelopeSigner.verify(
        canonicalPayload: canonical,
        sharedSecretHex: secret,
        providedSignatureHex: envelope.signature!,
      );

      if (!isValid) return false;

      // Replay attack prevention: verify envelope is not older than 5 minutes
      final now = DateTime.now().millisecondsSinceEpoch;
      if ((now - envelope.ts).abs() > 300000) {
        return false;
      }

      return true;
    }

    // If a peer or cluster secret is provisioned, verify signature on signed envelopes
    final peerSecret = _secretStore?.getSecretForPeerSync(envelope.senderId);
    final secret = peerSecret ?? _clusterSecretHex;
    if (secret != null && secret.isNotEmpty && envelope.signature != null) {
      final canonical = EnvelopeSigner.canonicalize(
        type: envelope.type,
        scope: envelope.scope,
        senderRole: envelope.senderRole,
        senderId: envelope.senderId,
        payload: envelope.payload,
        timestampEpochMs: envelope.ts,
      );

      return EnvelopeSigner.verify(
        canonicalPayload: canonical,
        sharedSecretHex: secret,
        providedSignatureHex: envelope.signature!,
      );
    }

    return true;
  }

  void dispose() {
    disconnect();
    _discoveryService.dispose();
    if (!_incomingEventsController.isClosed) {
      _incomingEventsController.close();
    }
    if (!_connectedNodesController.isClosed) {
      _connectedNodesController.close();
    }
  }
}
