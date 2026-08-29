import '../entities/connected_node.dart';
import '../entities/sync_envelope.dart';

abstract class LanSyncRepository {
  Stream<SyncEnvelope> get incomingEvents;
  Stream<List<ConnectedNode>> get connectedNodesStream;
  List<ConnectedNode> get connectedNodes;

  bool get isHost;
  bool get isConnected;

  Future<void> startHostServer({int port = 9090});
  Future<void> connectToHost(String hostIp, {int port = 9090});
  Future<void> broadcast(SyncEnvelope envelope);
  Future<void> disconnect();
}
