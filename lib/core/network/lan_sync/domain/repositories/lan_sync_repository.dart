import '../../data/services/lan_discovery_service.dart';
import '../entities/connected_node.dart';
import '../entities/sync_envelope.dart';

abstract class LanSyncRepository {
  Stream<SyncEnvelope> get incomingEvents;
  Stream<List<ConnectedNode>> get connectedNodesStream;
  List<ConnectedNode> get connectedNodes;

  bool get isHost;
  bool get isConnected;

  Stream<List<DiscoveredHost>> get discoveredHostsStream => const Stream.empty();
  List<DiscoveredHost> get discoveredHosts => const [];
  void startDiscoveryScanner() {}
  void stopDiscoveryScanner() {}

  Future<void> startHostServer({int port = 9090});
  Future<void> connectToHost(String hostIp, {int port = 9090});
  Future<void> autoRestoreConnection();
  Future<void> broadcast(SyncEnvelope envelope);
  Future<void> disconnect({bool clearPersistedRole = true});
  Future<void> updateStationIdentity({required String id, required String role, String? appName});
  bool wouldAcceptEnvelope(SyncEnvelope envelope) => true;
}
