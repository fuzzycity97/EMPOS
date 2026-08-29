import 'dart:async';
import '../../../../core/network/lan_sync/domain/entities/sync_envelope.dart';
import '../../../../core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import '../../domain/entities/fleet_node.dart';
import '../../domain/repositories/rmm_repository.dart';

class RmmRepositoryImpl implements RmmRepository {
  final LanSyncRepository lanSyncRepository;
  final StreamController<List<FleetNode>> _nodesController =
      StreamController<List<FleetNode>>.broadcast();

  final List<FleetNode> _nodes = [];
  StreamSubscription? _lanNodesSub;

  RmmRepositoryImpl({required this.lanSyncRepository}) {
    _initHostAndSubscribers();
  }

  void _initHostAndSubscribers() {
    // Primary host / local node
    _nodes.add(
      FleetNode(
        id: 'node_main_hub',
        branchName: 'Main Store / Hub',
        ipAddress: '192.168.1.100',
        role: 'Host Server & Gateway',
        status: FleetNodeStatus.online,
        lastHeartbeat: DateTime.now(),
        latencyMs: 1,
      ),
    );

    // Initial emit
    _nodesController.add(List.unmodifiable(_nodes));

    // Listen to LAN Sync peers
    _lanNodesSub = lanSyncRepository.connectedNodesStream.listen((connected) {
      _syncFromLanPeers(connected);
    });
  }

  void _syncFromLanPeers(List<dynamic> connected) {
    // Preserve local host
    final host = _nodes.firstWhere(
      (n) => n.id == 'node_main_hub',
      orElse: () => FleetNode(
        id: 'node_main_hub',
        branchName: 'Main Store / Hub',
        ipAddress: '192.168.1.100',
        role: 'Host Server & Gateway',
        status: FleetNodeStatus.online,
        lastHeartbeat: DateTime.now(),
        latencyMs: 1,
      ),
    );

    _nodes.clear();
    _nodes.add(host);

    for (final peer in connected) {
      final peerId = peer.id?.toString() ?? 'node_${peer.hashCode}';
      final peerIp = peer.ipAddress?.toString() ?? '192.168.1.105';
      final peerRole = peer.role?.toString() ?? 'station';

      _nodes.add(
        FleetNode(
          id: peerId,
          branchName: 'LAN Station ($peerRole)',
          ipAddress: peerIp,
          role: peerRole,
          status: FleetNodeStatus.online,
          lastHeartbeat: DateTime.now(),
          latencyMs: 12 + (peerId.hashCode % 15).abs(),
        ),
      );
    }

    _nodesController.add(List.unmodifiable(_nodes));
  }

  @override
  Stream<List<FleetNode>> get fleetNodesStream => _nodesController.stream;

  @override
  List<FleetNode> get currentNodes => List.unmodifiable(_nodes);

  @override
  Future<void> sendRemoteCommand(String nodeId, String command) async {
    final envelope = SyncEnvelope.create(
      type: 'rmm.command',
      scope: 'system',
      senderId: 'dev_console',
      senderRole: 'admin',
      payload: {
        'targetNodeId': nodeId,
        'command': command,
      },
    );
    await lanSyncRepository.broadcast(envelope);
  }

  @override
  Future<void> pushSoftwareUpdate(String targetVersion) async {
    final envelope = SyncEnvelope.create(
      type: 'rmm.software_update',
      scope: 'fleet',
      senderId: 'dev_console',
      senderRole: 'admin',
      payload: {
        'version': targetVersion,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
    );
    await lanSyncRepository.broadcast(envelope);
  }

  @override
  Future<int> pingNode(String nodeId) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    final latency = 4 + (DateTime.now().millisecond % 18);

    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(
        status: FleetNodeStatus.online,
        lastHeartbeat: DateTime.now(),
        latencyMs: latency,
      );
      _nodesController.add(List.unmodifiable(_nodes));
    }

    return latency;
  }

  @override
  Future<void> forceDbSync(String nodeId) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(status: FleetNodeStatus.syncing);
      _nodesController.add(List.unmodifiable(_nodes));
    }

    final envelope = SyncEnvelope.create(
      type: 'sync.force',
      scope: 'database',
      senderId: 'dev_console',
      senderRole: 'admin',
      payload: {'targetNodeId': nodeId},
    );
    await lanSyncRepository.broadcast(envelope);

    // Reset status after short delay
    Future.delayed(const Duration(milliseconds: 600), () {
      final idx = _nodes.indexWhere((n) => n.id == nodeId);
      if (idx != -1) {
        _nodes[idx] = _nodes[idx].copyWith(status: FleetNodeStatus.online);
        _nodesController.add(List.unmodifiable(_nodes));
      }
    });
  }

  @override
  Future<void> restartNode(String nodeId) async {
    final index = _nodes.indexWhere((n) => n.id == nodeId);
    if (index != -1) {
      _nodes[index] = _nodes[index].copyWith(status: FleetNodeStatus.offline);
      _nodesController.add(List.unmodifiable(_nodes));
    }

    final envelope = SyncEnvelope.create(
      type: 'rmm.restart',
      scope: 'system',
      senderId: 'dev_console',
      senderRole: 'admin',
      payload: {'targetNodeId': nodeId},
    );
    await lanSyncRepository.broadcast(envelope);

    // Re-enable after restart simulation
    Future.delayed(const Duration(milliseconds: 1200), () {
      final idx = _nodes.indexWhere((n) => n.id == nodeId);
      if (idx != -1) {
        _nodes[idx] = _nodes[idx].copyWith(
          status: FleetNodeStatus.online,
          lastHeartbeat: DateTime.now(),
        );
        _nodesController.add(List.unmodifiable(_nodes));
      }
    });
  }

  void dispose() {
    _lanNodesSub?.cancel();
    _nodesController.close();
  }
}
