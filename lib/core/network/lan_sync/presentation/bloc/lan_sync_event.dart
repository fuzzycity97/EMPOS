import 'package:equatable/equatable.dart';

abstract class LanSyncEvent extends Equatable {
  const LanSyncEvent();

  @override
  List<Object?> get props => [];
}

class StartHostServerEvent extends LanSyncEvent {
  final int port;

  const StartHostServerEvent({this.port = 9090});

  @override
  List<Object?> get props => [port];
}

class ConnectToHostEvent extends LanSyncEvent {
  final String hostIp;
  final int port;

  const ConnectToHostEvent({required this.hostIp, this.port = 9090});

  @override
  List<Object?> get props => [hostIp, port];
}

class DisconnectLanSyncEvent extends LanSyncEvent {
  const DisconnectLanSyncEvent();
}

class RefreshLanSyncStatusEvent extends LanSyncEvent {
  const RefreshLanSyncStatusEvent();
}

class AutoRestoreLanSyncEvent extends LanSyncEvent {
  const AutoRestoreLanSyncEvent();
}
