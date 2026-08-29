import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_feature_toggle_usecase.dart';
import '../../domain/usecases/load_store_blueprint_usecase.dart';
import '../../domain/usecases/save_store_blueprint_usecase.dart';
import 'config_event.dart';
import 'config_state.dart';

class ConfigBloc extends Bloc<ConfigEvent, ConfigState> {
  final LoadStoreBlueprintUseCase loadStoreBlueprintUseCase;
  final SaveStoreBlueprintUseCase saveStoreBlueprintUseCase;
  final GetFeatureToggleUseCase getFeatureToggleUseCase;

  ConfigBloc({
    required this.loadStoreBlueprintUseCase,
    required this.saveStoreBlueprintUseCase,
    required this.getFeatureToggleUseCase,
  }) : super(const ConfigInitial()) {
    on<LoadConfigEvent>(_onLoadConfig);
    on<SaveStoreBlueprintEvent>(_onSaveStoreBlueprint);
    on<UpdateBlueprintEvent>(_onUpdateBlueprint);
    on<SetToggleEvent>(_onSetToggle);
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

    final result = await saveStoreBlueprintUseCase(updatedBlueprint);

    result.fold(
      (failure) => emit(ConfigError(failure.message)),
      (_) => emit(ConfigLoaded(blueprint: updatedBlueprint)),
    );
  }
}
