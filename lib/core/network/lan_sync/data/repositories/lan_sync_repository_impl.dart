import 'dart:async';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/connected_node.dart';
import '../../domain/entities/sync_envelope.dart';
import '../../domain/repositories/lan_sync_repository.dart';
import '../message_routes.dart';

class LanSyncRepositoryImpl implements LanSyncRepository {
  static const String offlineQueueBoxName = 'empos_offline_sync_queue';

  HttpServer? _server;
  WebSocketChannel? _clientChannel;
  StreamSubscription? _clientSubscription;
  Timer? _reconnectTimer;

  String? _targetHostIp;
  int _targetPort = 9090;
  bool _shouldAutoReconnect = false;

  final Set<WebSocketChannel> _activeChannels = {};
  final Map<WebSocketChannel, ConnectedNode> _nodeMap = {};

  final StreamController<SyncEnvelope> _incomingEventsController =
      StreamController<SyncEnvelope>.broadcast();
  final StreamController<List<ConnectedNode>> _connectedNodesController =
      StreamController<List<ConnectedNode>>.broadcast();

  bool _isHost = false;
  bool _isConnected = false;

  @override
  Stream<SyncEnvelope> get incomingEvents => _incomingEventsController.stream;

  @override
  Stream<List<ConnectedNode>> get connectedNodesStream => _connectedNodesController.stream;

  @override
  List<ConnectedNode> get connectedNodes => _nodeMap.values.toList();

  @override
  bool get isHost => _isHost;

  @override
  bool get isConnected => _isConnected;

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

    final handler = webSocketHandler((WebSocketChannel channel) {
      final nodeId = 'node-${DateTime.now().millisecondsSinceEpoch}-${_activeChannels.length + 1}';
      final node = ConnectedNode(
        id: nodeId,
        role: 'station_client',
        ipAddress: 'lan_peer',
      );

      _activeChannels.add(channel);
      _nodeMap[channel] = node;
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
        },
        onError: (err) {
          _activeChannels.remove(channel);
          _nodeMap.remove(channel);
          if (!_connectedNodesController.isClosed) {
            _connectedNodesController.add(connectedNodes);
          }
        },
        cancelOnError: true,
      );
    });

    _server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);
    _isHost = true;
    _isConnected = true;

    // Register host node
    final hostNode = ConnectedNode(
      id: 'host-server',
      role: 'hub_host',
      ipAddress: '127.0.0.1',
    );
    if (!_connectedNodesController.isClosed) {
      _connectedNodesController.add([hostNode]);
    }
  }

  @override
  Future<void> connectToHost(String hostIp, {int port = 9090}) async {
    await disconnect();

    _shouldAutoReconnect = true;
    _targetHostIp = hostIp;
    _targetPort = port;

    await _establishClientConnection(hostIp, port);
  }

  Future<void> _establishClientConnection(String hostIp, int port) async {
    try {
      final uri = Uri.parse('ws://$hostIp:$port');
      final channel = WebSocketChannel.connect(uri);

      _clientChannel = channel;
      _isHost = false;
      _isConnected = true;

      _clientSubscription = channel.stream.listen(
        (data) {
          try {
            final envelope = SyncEnvelope.fromRawJson(data.toString());
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

      // Send node joined handshake
      final joinEnvelope = SyncEnvelope.create(
        type: MessageRoutes.nodeJoined,
        senderId: 'client-station',
        senderRole: 'station',
      );
      await broadcast(joinEnvelope);

      // Flush offline outbox queue BEFORE state reconciliation
      await _flushOfflineQueue();

      // Multi-ping handshake: send at 1s, 3s, and 6s to guarantee state reconciliation
      void sendStateRequest() {
        if (_isConnected && _clientChannel != null) {
          final syncRequestEnvelope = SyncEnvelope.create(
            type: MessageRoutes.syncRequestActiveState,
            senderId: 'client-station',
            senderRole: 'station',
          );
          broadcast(syncRequestEnvelope);
        }
      }

      // Ping 1 at 1 second
      await Future.delayed(const Duration(milliseconds: 1000));
      sendStateRequest();

      // Ping 2 at 3 seconds (1s + 2s)
      Future.delayed(const Duration(seconds: 2), sendStateRequest);

      // Ping 3 at 6 seconds (1s + 5s)
      Future.delayed(const Duration(seconds: 5), sendStateRequest);
    } catch (_) {
      _handleClientDisconnect();
    }
  }

  void _handleClientDisconnect() {
    _isConnected = false;
    _clientSubscription?.cancel();
    _clientSubscription = null;
    _clientChannel = null;

    if (_shouldAutoReconnect && !_isHost && _targetHostIp != null) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () async {
      if (_shouldAutoReconnect && !_isConnected && !_isHost && _targetHostIp != null) {
        await _establishClientConnection(_targetHostIp!, _targetPort);
      }
    });
  }

  @override
  Future<void> broadcast(SyncEnvelope envelope) async {
    final raw = envelope.toRawJson();

    final isTransient = envelope.type == MessageRoutes.syncRequestActiveState ||
        envelope.type == MessageRoutes.nodeJoined ||
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

    // Close client subscription and channel
    await _clientSubscription?.cancel();
    _clientSubscription = null;
    await _clientChannel?.sink.close();
    _clientChannel = null;

    // Close all host active client channels
    final channelsToClose = _activeChannels.toList();
    _activeChannels.clear();
    _nodeMap.clear();

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
