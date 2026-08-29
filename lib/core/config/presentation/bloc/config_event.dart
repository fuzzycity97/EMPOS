import 'package:equatable/equatable.dart';
import '../../domain/entities/store_blueprint.dart';

abstract class ConfigEvent extends Equatable {
  const ConfigEvent();

  @override
  List<Object?> get props => [];
}

class LoadConfigEvent extends ConfigEvent {
  final bool forceReload;

  const LoadConfigEvent({this.forceReload = false});

  @override
  List<Object?> get props => [forceReload];
}

class SaveStoreBlueprintEvent extends ConfigEvent {
  final StoreBlueprint blueprint;

  const SaveStoreBlueprintEvent(this.blueprint);

  @override
  List<Object?> get props => [blueprint];
}

class UpdateBlueprintEvent extends ConfigEvent {
  final StoreBlueprint blueprint;

  const UpdateBlueprintEvent(this.blueprint);

  @override
  List<Object?> get props => [blueprint];
}

class SetToggleEvent extends ConfigEvent {
  final String toggleKey;
  final bool isEnabled;

  const SetToggleEvent({
    required this.toggleKey,
    required this.isEnabled,
  });

  @override
  List<Object?> get props => [toggleKey, isEnabled];
}
