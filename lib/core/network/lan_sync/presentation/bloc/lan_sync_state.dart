import 'package:equatable/equatable.dart';
import '../../domain/entities/connected_node.dart';

abstract class LanSyncState extends Equatable {
  const LanSyncState();

  @override
  List<Object?> get props => [];
}

class LanSyncInitial extends LanSyncState {
  const LanSyncInitial();
}

class LanSyncConnecting extends LanSyncState {
  const LanSyncConnecting();
}

class LanSyncConnected extends LanSyncState {
  final bool isHost;
  final String address;
  final int port;
  final List<ConnectedNode> nodes;

  const LanSyncConnected({
    required this.isHost,
    required this.address,
    this.port = 9090,
    this.nodes = const [],
  });

  @override
  List<Object?> get props => [isHost, address, port, nodes];
}

class LanSyncDisconnected extends LanSyncState {
  final String? reason;

  const LanSyncDisconnected({this.reason});

  @override
  List<Object?> get props => [reason];
}

class LanSyncError extends LanSyncState {
  final String message;

  const LanSyncError(this.message);

  @override
  List<Object?> get props => [message];
}
