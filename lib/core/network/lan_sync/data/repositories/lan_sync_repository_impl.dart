import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/connected_node.dart';
import '../../domain/entities/sync_envelope.dart';
import '../../domain/repositories/lan_sync_repository.dart';
import '../message_routes.dart';

class LanSyncRepositoryImpl implements LanSyncRepository {
  static const String offlineQueueBoxName = 'empos_offline_sync_queue';
  static const String _lanProfileStorageKey = 'empos_lan_sync_profile';

  HttpServer? _server;
  WebSocketChannel? _clientChannel;
  StreamSubscription? _clientSubscription;
  Timer? _reconnectTimer;
  final List<Timer> _pendingTimers = [];

  String? _targetHostIp;
  int _targetPort = 9090;
  bool _shouldAutoReconnect = false;

  final Set<WebSocketChannel> _activeChannels = {};
  final Map<WebSocketChannel, ConnectedNode> _nodeMap = {};
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
  List<ConnectedNode> get connectedNodes {
    if (_isHost) {
      if (_hostNode != null) {
        return [_hostNode!, ..._nodeMap.values];
      }
      return _nodeMap.values.toList();
    }
    return _clientNetworkNodes;
  }

  @override
  bool get isHost => _isHost;

  @override
  bool get isConnected => _isConnected;

  static String getLocalInstanceId() {
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
    final id = getLocalInstanceId().toLowerCase();
    if (id.contains('doc')) return 'Doctor Station';
    if (id.contains('recept')) return isHost ? 'Reception Desk (Host)' : 'Reception Desk';
    if (id.contains('cashier') || id.contains('pos')) return 'POS Cashier';
    if (isHost) return 'Primary Hub Host';
    return 'Client Station';
  }

  static Future<String> getPrimaryLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLoopback: false,
      );
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
              try {
                ch.sink.add(rawStr);
              } catch (_) {}
            }
          } else if (_clientChannel != null && _isConnected) {
            try {
              _clientChannel!.sink.add(rawStr);
            } catch (_) {}
          }
          await box.delete(key);
        }
      }
    } catch (_) {}
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

    final handler = webSocketHandler((WebSocketChannel channel) {
      final nodeId = 'station-${DateTime.now().millisecondsSinceEpoch}-${_activeChannels.length + 1}';
      final placeholderNode = ConnectedNode(
        id: nodeId,
        role: 'Client Station',
        ipAddress: 'lan_peer',
      );

      _activeChannels.add(channel);
      _nodeMap[channel] = placeholderNode;

      if (!_connectedNodesController.isClosed) {
        _connectedNodesController.add(connectedNodes);
      }

      // Flush offline outbox queue to the newly joined peer
      _flushOfflineQueue();

      channel.stream.listen(
        (data) {
          try {
            final raw = data.toString();
            final envelope = SyncEnvelope.fromRawJson(raw);

            // Handle Node Joined Handshake
            if (envelope.type == MessageRoutes.nodeJoined) {
              final realNode = ConnectedNode(
                id: envelope.senderId.isNotEmpty ? envelope.senderId : placeholderNode.id,
                role: envelope.senderRole.isNotEmpty ? envelope.senderRole : placeholderNode.role,
                ipAddress: envelope.payload?['ip']?.toString() ?? placeholderNode.ipAddress,
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
              if (!_connectedNodesController.isClosed) {
                _connectedNodesController.add(connectedNodes);
              }
              _broadcastPeerListToClients();
            }

            if (!_incomingEventsController.isClosed) {
              _incomingEventsController.add(envelope);
            }

            // Relay to all other connected clients (Hub topology)
            for (final other in _activeChannels) {
              if (other != channel) {
                try {
                  other.sink.add(raw);
                } catch (_) {}
              }
            }
          } catch (_) {}
        },
        onDone: () {
          _activeChannels.remove(channel);
          _nodeMap.remove(channel);
          if (!_connectedNodesController.isClosed) {
            _connectedNodesController.add(connectedNodes);
          }
          _broadcastPeerListToClients();
        },
        onError: (err) {
          _activeChannels.remove(channel);
          _nodeMap.remove(channel);
          if (!_connectedNodesController.isClosed) {
            _connectedNodesController.add(connectedNodes);
          }
          _broadcastPeerListToClients();
        },
        cancelOnError: true,
      );
    });

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    _isHost = true;
    _isConnected = true;

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
      try {
        channel.sink.add(raw);
      } catch (_) {}
    }
  }

  @override
  Future<void> connectToHost(String hostIp, {int port = 9090}) async {
    await disconnect();

    _shouldAutoReconnect = true;
    _targetHostIp = hostIp;
    _targetPort = port;

    // Persist Client profile for auto-reconnection on next boot
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lanProfileStorageKey, jsonEncode({
        'role': 'client',
        'hostIp': hostIp,
        'port': port,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    } catch (_) {}

    await _establishClientConnection(hostIp, port);
  }

  Future<void> _establishClientConnection(String hostIp, int port) async {
    try {
      final uri = Uri.parse('ws://$hostIp:$port');
      final channel = WebSocketChannel.connect(uri);

      // Await real connection establishment to prevent false-positive optimistic connection
      await channel.ready.timeout(
        const Duration(seconds: 4),
        onTimeout: () => throw TimeoutException('Connection to $hostIp:$port timed out'),
      );

      _clientChannel = channel;
      _isHost = false;
      _isConnected = true;

      final localIp = await getPrimaryLocalIp();
      final localId = getLocalInstanceId();
      final localRole = getLocalStationRole(isHost: false);

      final clientSelfNode = ConnectedNode(
        id: localId,
        role: localRole,
        ipAddress: localIp,
      );

      // Initialize mesh nodes with self and host
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
            final raw = data.toString();
            final envelope = SyncEnvelope.fromRawJson(raw);

            // Handle Peer List Update from Host
            if (envelope.type == MessageRoutes.peerListUpdate ||
                envelope.type == MessageRoutes.nodeJoinedAck) {
              final rawNodes = envelope.payload?['nodes'] as List<dynamic>?;
              if (rawNodes != null) {
                _clientNetworkNodes = rawNodes
                    .whereType<Map<String, dynamic>>()
                    .map((n) => ConnectedNode.fromJson(n))
                    .toList();
                if (!_connectedNodesController.isClosed) {
                  _connectedNodesController.add(_clientNetworkNodes);
                }
              }
            }

            if (!_incomingEventsController.isClosed) {
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

      // Send node joined handshake with real instance ID and role
      final joinEnvelope = SyncEnvelope.create(
        type: MessageRoutes.nodeJoined,
        senderId: localId,
        senderRole: localRole,
        payload: {
          'ip': localIp,
          'hostname': Platform.localHostname,
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

      // Ping 1 at 1 second
      _pendingTimers.add(Timer(const Duration(milliseconds: 1000), sendStateRequest));

      // Ping 2 at 3 seconds
      _pendingTimers.add(Timer(const Duration(seconds: 3), sendStateRequest));

      // Ping 3 at 6 seconds
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
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 3), () async {
      if (_shouldAutoReconnect && !_isConnected && !_isHost && _targetHostIp != null) {
        try {
          await _establishClientConnection(_targetHostIp!, _targetPort);
        } catch (_) {
          // If attempt fails, schedule next retry loop
          if (_shouldAutoReconnect && !_isConnected && !_isHost) {
            _scheduleReconnect();
          }
        }
      }
    });
  }

  @override
  Future<void> broadcast(SyncEnvelope envelope) async {
    final raw = envelope.toRawJson();

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
          try {
            channel.sink.add(raw);
          } catch (_) {}
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
        try {
          _clientChannel!.sink.add(raw);
        } catch (_) {
          if (!isTransient) {
            await _enqueueOffline(raw);
          }
        }
      } else if (!isTransient) {
        // Client is offline - queue envelope in outbox
        await _enqueueOffline(raw);
      }
    }
  }

  @override
  Future<void> disconnect() async {
    _shouldAutoReconnect = false;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _cancelPendingTimers();

    // If client, notify host gracefully if possible
    if (!_isHost && _clientChannel != null && _isConnected) {
      try {
        final leaveEnvelope = SyncEnvelope.create(
          type: MessageRoutes.nodeLeft,
          senderId: getLocalInstanceId(),
          senderRole: getLocalStationRole(isHost: false),
        );
        _clientChannel!.sink.add(leaveEnvelope.toRawJson());
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

  void dispose() {
    disconnect();
    if (!_incomingEventsController.isClosed) {
      _incomingEventsController.close();
    }
    if (!_connectedNodesController.isClosed) {
      _connectedNodesController.close();
    }
  }
}
