import 'package:equatable/equatable.dart';
import '../../domain/entities/import_result.dart';

abstract class DataIoState extends Equatable {
  const DataIoState();

  @override
  List<Object?> get props => [];
}

class DataIoInitial extends DataIoState {
  const DataIoInitial();
}

class DataIoLoading extends DataIoState {
  final String operation;

  const DataIoLoading(this.operation);

  @override
  List<Object?> get props => [operation];
}

class DataIoSuccess extends DataIoState {
  final String message;
  final ImportResult? importResult;
  final String? filePath;

  const DataIoSuccess(
    this.message, {
    this.importResult,
    this.filePath,
  });

  @override
  List<Object?> get props => [message, importResult, filePath];
}

class DataIoError extends DataIoState {
  final String message;

  const DataIoError(this.message);

  @override
  List<Object?> get props => [message];
}
