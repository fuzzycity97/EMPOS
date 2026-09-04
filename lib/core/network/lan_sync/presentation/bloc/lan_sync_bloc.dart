import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/lan_sync_repository_impl.dart';
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
    on<AutoRestoreLanSyncEvent>(_onAutoRestore);

    _nodesSubscription = lanSyncRepository.connectedNodesStream.listen((nodes) {
      if (lanSyncRepository.isConnected) {
        add(const RefreshLanSyncStatusEvent());
      } else if (state is! LanSyncDisconnected && state is! LanSyncInitial) {
        add(const RefreshLanSyncStatusEvent());
      }
    });
  }

  Future<void> _onAutoRestore(
    AutoRestoreLanSyncEvent event,
    Emitter<LanSyncState> emit,
  ) async {
    try {
      await lanSyncRepository.autoRestoreConnection();
      if (lanSyncRepository.isConnected) {
        final localId = LanSyncRepositoryImpl.getLocalInstanceId();
        final localRole = LanSyncRepositoryImpl.getLocalStationRole(isHost: lanSyncRepository.isHost);
        final localIp = await LanSyncRepositoryImpl.getPrimaryLocalIp();
        emit(
          LanSyncConnected(
            isHost: lanSyncRepository.isHost,
            address: localIp,
            port: 9090,
            nodes: lanSyncRepository.connectedNodes,
            localStationId: localId,
            localStationRole: localRole,
          ),
        );
      }
    } catch (_) {}
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
      final localIp = await LanSyncRepositoryImpl.getPrimaryLocalIp();
      final localId = LanSyncRepositoryImpl.getLocalInstanceId();
      final localRole = LanSyncRepositoryImpl.getLocalStationRole(isHost: true);
      emit(
        LanSyncConnected(
          isHost: true,
          address: localIp,
          port: event.port,
          nodes: lanSyncRepository.connectedNodes,
          localStationId: localId,
          localStationRole: localRole,
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
    emit(LanSyncConnecting(targetAddress: '${event.hostIp}:${event.port}'));
    try {
      await lanSyncRepository.connectToHost(event.hostIp, port: event.port);
      final localId = LanSyncRepositoryImpl.getLocalInstanceId();
      final localRole = LanSyncRepositoryImpl.getLocalStationRole(isHost: false);
      emit(
        LanSyncConnected(
          isHost: false,
          address: event.hostIp,
          port: event.port,
          nodes: lanSyncRepository.connectedNodes,
          localStationId: localId,
          localStationRole: localRole,
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
      final currentAddress = (state is LanSyncConnected)
          ? (state as LanSyncConnected).address
          : (lanSyncRepository.isHost ? '127.0.0.1' : 'Host Connected');
      final currentPort =
          (state is LanSyncConnected) ? (state as LanSyncConnected).port : 9090;
      final localId = LanSyncRepositoryImpl.getLocalInstanceId();
      final localRole =
          LanSyncRepositoryImpl.getLocalStationRole(isHost: lanSyncRepository.isHost);
      emit(
        LanSyncConnected(
          isHost: lanSyncRepository.isHost,
          address: currentAddress,
          port: currentPort,
          nodes: lanSyncRepository.connectedNodes,
          localStationId: localId,
          localStationRole: localRole,
        ),
      );
    } else {
      emit(const LanSyncDisconnected());
    }
  }
}
