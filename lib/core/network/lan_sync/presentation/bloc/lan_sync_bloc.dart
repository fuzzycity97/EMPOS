import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/lan_sync_repository.dart';
import 'lan_sync_event.dart';
import 'lan_sync_state.dart';

class LanSyncBloc extends Bloc<LanSyncEvent, LanSyncState> {
  final LanSyncRepository lanSyncRepository;
  StreamSubscription? _nodesSubscription;

  LanSyncBloc({required this.lanSyncRepository}) : super(const LanSyncInitial()) {
    on<StartHostServerEvent>(_onStartHostServer);
    on<ConnectToHostEvent>(_onConnectToHost);
    on<DisconnectLanSyncEvent>(_onDisconnect);
    on<RefreshLanSyncStatusEvent>(_onRefreshStatus);

    _nodesSubscription = lanSyncRepository.connectedNodesStream.listen((nodes) {
      if (lanSyncRepository.isConnected) {
        add(const RefreshLanSyncStatusEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _nodesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onStartHostServer(
    StartHostServerEvent event,
    Emitter<LanSyncState> emit,
  ) async {
    emit(const LanSyncConnecting());
    try {
      await lanSyncRepository.startHostServer(port: event.port);
      emit(
        LanSyncConnected(
          isHost: true,
          address: '0.0.0.0 (All LAN Interfaces)',
          port: event.port,
          nodes: lanSyncRepository.connectedNodes,
        ),
      );
    } catch (e) {
      emit(LanSyncError('Failed to start host server: $e'));
    }
  }

  Future<void> _onConnectToHost(
    ConnectToHostEvent event,
    Emitter<LanSyncState> emit,
  ) async {
    emit(const LanSyncConnecting());
    try {
      await lanSyncRepository.connectToHost(event.hostIp, port: event.port);
      emit(
        LanSyncConnected(
          isHost: false,
          address: event.hostIp,
          port: event.port,
          nodes: lanSyncRepository.connectedNodes,
        ),
      );
    } catch (e) {
      emit(LanSyncError('Failed to connect to host "${event.hostIp}": $e'));
    }
  }

  Future<void> _onDisconnect(
    DisconnectLanSyncEvent event,
    Emitter<LanSyncState> emit,
  ) async {
    await lanSyncRepository.disconnect();
    emit(const LanSyncDisconnected());
  }

  void _onRefreshStatus(
    RefreshLanSyncStatusEvent event,
    Emitter<LanSyncState> emit,
  ) {
    if (lanSyncRepository.isConnected) {
      emit(
        LanSyncConnected(
          isHost: lanSyncRepository.isHost,
          address: lanSyncRepository.isHost ? '0.0.0.0' : 'Host Connected',
          nodes: lanSyncRepository.connectedNodes,
        ),
      );
    } else {
      emit(const LanSyncDisconnected());
    }
  }
}
