import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/store_blueprint_model.dart';
import '../../domain/usecases/get_feature_toggle_usecase.dart';
import '../../domain/usecases/load_store_blueprint_usecase.dart';
import '../../domain/usecases/save_store_blueprint_usecase.dart';
import '../../../network/lan_sync/data/repositories/lan_sync_repository_impl.dart';
import '../../../network/lan_sync/domain/repositories/lan_sync_repository.dart';
import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final LoadStoreBlueprintUseCase loadStoreBlueprintUseCase;
  final SaveStoreBlueprintUseCase saveStoreBlueprintUseCase;
  final GetFeatureToggleUseCase getFeatureToggleUseCase;
  final LanSyncRepository? lanSyncRepository;
  StreamSubscription? _lanSyncSubscription;

  ConfigBloc({
    required this.loadStoreBlueprintUseCase,
    required this.saveStoreBlueprintUseCase,
    required this.getFeatureToggleUseCase,
    this.lanSyncRepository,
  }) : super(const ConfigInitial()) {
    on<LoadConfigEvent>(_onLoadConfig);
    on<SaveStoreBlueprintEvent>(_onSaveStoreBlueprint);
    on<UpdateBlueprintEvent>(_onUpdateBlueprint);
    on<SetToggleEvent>(_onSetToggle);

    // Listen for remote configuration deployments pushed across the LAN
    _lanSyncSubscription = lanSyncRepository?.incomingEvents.listen((envelope) {
      if (envelope.type == 'CONFIG_UPDATE' || envelope.type == 'CONFIG_PUSH') {
        final payload = envelope.payload;
        if (payload != null && payload['blueprint'] != null) {
          try {
            final rawBp = payload['blueprint'];
            final map = rawBp is Map<String, dynamic> ? rawBp : Map<String, dynamic>.from(rawBp as Map);
            final targetId = payload['targetStationId']?.toString().toLowerCase().trim();
            final localId = LanSyncRepositoryImpl.getLocalInstanceId().toLowerCase().trim();
            final isTargetedToMe = targetId == null ||
                targetId.isEmpty ||
                targetId == 'all' ||
                targetId == 'all_stations' ||
                targetId == 'god-mode-hub' ||
                targetId == localId ||
                localId.contains(targetId) ||
                targetId.contains(localId);

            if (isTargetedToMe) {
              final newBp = StoreBlueprintModel.fromJson(map);
              add(UpdateBlueprintEvent(newBp));
            }
          } catch (_) {}
        }
      }
    });
  }

  @override
  Future<void> close() {
    _lanSyncSubscription?.cancel();
    return super.close();
  }

  Future<void> _onSaveStoreBlueprint(
    SaveStoreBlueprintEvent event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());
    final result = await saveStoreBlueprintUseCase(event.blueprint);

    result.fold(
      (failure) => emit(ConfigError(failure.message)),
      (_) => emit(ConfigLoaded(blueprint: event.blueprint)),
    );
  }

  Future<void> _onLoadConfig(
    LoadConfigEvent event,
    Emitter<ConfigState> emit,
  ) async {
    emit(const ConfigLoading());

    final result = await loadStoreBlueprintUseCase();

    result.fold(
      (failure) => emit(ConfigError(failure.message)),
      (blueprint) => emit(ConfigLoaded(blueprint: blueprint)),
    );
  }

  Future<void> _onUpdateBlueprint(
    UpdateBlueprintEvent event,
    Emitter<ConfigState> emit,
  ) async {
    final result = await saveStoreBlueprintUseCase(event.blueprint);

    result.fold(
      (failure) => emit(ConfigError(failure.message)),
      (_) => emit(ConfigLoaded(blueprint: event.blueprint)),
    );
  }

  Future<void> _onSetToggle(
    SetToggleEvent event,
    Emitter<ConfigState> emit,
  ) async {
    if (state is! ConfigLoaded) return;
    final currentBlueprint = (state as ConfigLoaded).blueprint;

    final updatedToggles = Map<String, bool>.from(currentBlueprint.toggles);
    updatedToggles[event.toggleKey] = event.isEnabled;

    final updatedBlueprint = currentBlueprint.copyWith(toggles: updatedToggles);

    // 1. Immediate reactive emission for 0ms UI reactivity across the entire system
    emit(ConfigLoaded(blueprint: updatedBlueprint));

    // 2. Persist to storage in background
    final result = await saveStoreBlueprintUseCase(updatedBlueprint);

    result.fold(
      (failure) {
        // Rollback if persistence encounters an error
        emit(ConfigLoaded(blueprint: currentBlueprint));
        emit(ConfigError(failure.message));
      },
      (_) {},
    );
  }
}
