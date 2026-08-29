import 'package:equatable/equatable.dart';

abstract class DataIoEvent extends Equatable {
  const DataIoEvent();

  @override
  List<Object?> get props => [];
}

class GenerateTemplateEvent extends DataIoEvent {
  final String destinationPath;

  const GenerateTemplateEvent(this.destinationPath);

  @override
  List<Object?> get props => [destinationPath];
}

class ExportCatalogEvent extends DataIoEvent {
  final String destinationPath;

  const ExportCatalogEvent(this.destinationPath);

  @override
  List<Object?> get props => [destinationPath];
}

class ImportCatalogEvent extends DataIoEvent {
  final String filePath;

  const ImportCatalogEvent(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class ResetDataIoStateEvent extends DataIoEvent {
  const ResetDataIoStateEvent();
}
