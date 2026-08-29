import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../domain/entities/connected_node.dart';
import '../../domain/entities/sync_envelope.dart';
import '../../domain/repositories/lan_sync_repository.dart';
import '../message_routes.dart';

class LanSyncRepositoryImpl implements LanSyncRepository {
  HttpServer? _server;
  WebSocketChannel? _clientChannel;
  StreamSubscription? _clientSubscription;

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
      _connectedNodesController.add(connectedNodes);

      channel.stream.listen(
        (data) {
          try {
            final raw = data.toString();
            final envelope = SyncEnvelope.fromRawJson(raw);
            _incomingEventsController.add(envelope);

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
          _connectedNodesController.add(connectedNodes);
        },
        onError: (err) {
          _activeChannels.remove(channel);
          _nodeMap.remove(channel);
          _connectedNodesController.add(connectedNodes);
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
    _connectedNodesController.add([hostNode]);
  }

  @override
  Future<void> connectToHost(String hostIp, {int port = 9090}) async {
    await disconnect();

    final uri = Uri.parse('ws://$hostIp:$port');
    final channel = WebSocketChannel.connect(uri);

    _clientChannel = channel;
    _isHost = false;
    _isConnected = true;

    _clientSubscription = channel.stream.listen(
      (data) {
        try {
          final envelope = SyncEnvelope.fromRawJson(data.toString());
          _incomingEventsController.add(envelope);
        } catch (_) {}
      },
      onDone: () {
        _isConnected = false;
        _clientSubscription?.cancel();
        _clientChannel = null;
      },
      onError: (err) {
        _isConnected = false;
        _clientSubscription?.cancel();
        _clientChannel = null;
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

    // Wait 800ms to ensure the Host's server has fully registered the peer before requesting state
    await Future.delayed(const Duration(milliseconds: 800));

    if (_isConnected && _clientChannel != null) {
      // Send state reconciliation request to sync any missed state
      final syncRequestEnvelope = SyncEnvelope.create(
        type: MessageRoutes.syncRequestActiveState,
        senderId: 'client-station',
        senderRole: 'station',
      );
      await broadcast(syncRequestEnvelope);
    }
  }

  @override
  Future<void> broadcast(SyncEnvelope envelope) async {
    final raw = envelope.toRawJson();

    if (_isHost) {
      // Broadcast to all connected clients
      for (final channel in _activeChannels) {
        try {
          channel.sink.add(raw);
        } catch (_) {}
      }
      // Also notify local listeners
      _incomingEventsController.add(envelope);
    } else if (_clientChannel != null && _isConnected) {
      try {
        _clientChannel!.sink.add(raw);
      } catch (_) {}
    }
  }

  @override
  Future<void> disconnect() async {
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
    _connectedNodesController.add([]);
  }

  void dispose() {
    disconnect();
    _incomingEventsController.close();
    _connectedNodesController.close();
  }
}
