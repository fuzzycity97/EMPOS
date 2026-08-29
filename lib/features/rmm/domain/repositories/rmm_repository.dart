import '../entities/fleet_node.dart';

abstract class RmmRepository {
  Stream<List<FleetNode>> get fleetNodesStream;
  List<FleetNode> get currentNodes;

  Future<void> sendRemoteCommand(String nodeId, String command);
  Future<void> pushSoftwareUpdate(String targetVersion);
  Future<int> pingNode(String nodeId);
  Future<void> forceDbSync(String nodeId);
  Future<void> restartNode(String nodeId);
}
