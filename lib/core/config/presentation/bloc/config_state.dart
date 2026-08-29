import 'package:equatable/equatable.dart';
import '../../domain/entities/store_blueprint.dart';

abstract class ConfigState extends Equatable {
  const ConfigState();

  @override
  List<Object?> get props => [];
}

class ConfigInitial extends ConfigState {
  const ConfigInitial();
}

class ConfigLoading extends ConfigState {
  const ConfigLoading();
}

class ConfigLoaded extends ConfigState {
  final StoreBlueprint blueprint;

  const ConfigLoaded({required this.blueprint});

  @override
  List<Object?> get props => [blueprint];
}

class ConfigError extends ConfigState {
  final String message;

  const ConfigError(this.message);

  @override
  List<Object?> get props => [message];
}
