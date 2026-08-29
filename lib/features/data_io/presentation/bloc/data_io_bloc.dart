import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/export_catalog_usecase.dart';
import '../../domain/usecases/generate_template_usecase.dart';
import '../../domain/usecases/import_catalog_usecase.dart';
import 'data_io_event.dart';
import 'data_io_state.dart';

class DataIoBloc extends Bloc<DataIoEvent, DataIoState> {
  final GenerateTemplateUseCase generateTemplateUseCase;
  final ExportCatalogUseCase exportCatalogUseCase;
  final ImportCatalogUseCase importCatalogUseCase;

  DataIoBloc({
    required this.generateTemplateUseCase,
    required this.exportCatalogUseCase,
    required this.importCatalogUseCase,
  }) : super(const DataIoInitial()) {
    on<GenerateTemplateEvent>(_onGenerateTemplate);
    on<ExportCatalogEvent>(_onExportCatalog);
    on<ImportCatalogEvent>(_onImportCatalog);
    on<ResetDataIoStateEvent>(_onResetState);
  }

  Future<void> _onGenerateTemplate(
    GenerateTemplateEvent event,
    Emitter<DataIoState> emit,
  ) async {
    emit(const DataIoLoading('Generating CSV Template...'));
    final result = await generateTemplateUseCase(event.destinationPath);
    result.fold(
      (failure) => emit(DataIoError(failure.message)),
      (path) => emit(DataIoSuccess(
        'CSV template successfully saved!',
        filePath: path,
      )),
    );
  }

  Future<void> _onExportCatalog(
    ExportCatalogEvent event,
    Emitter<DataIoState> emit,
  ) async {
    emit(const DataIoLoading('Exporting Catalog to CSV...'));
    final result = await exportCatalogUseCase(event.destinationPath);
    result.fold(
      (failure) => emit(DataIoError(failure.message)),
      (path) => emit(DataIoSuccess(
        'Catalog successfully exported!',
        filePath: path,
      )),
    );
  }

  Future<void> _onImportCatalog(
    ImportCatalogEvent event,
    Emitter<DataIoState> emit,
  ) async {
    emit(const DataIoLoading('Parsing & Importing CSV Rows...'));
    final result = await importCatalogUseCase(event.filePath);
    result.fold(
      (failure) => emit(DataIoError(failure.message)),
      (importResult) => emit(DataIoSuccess(
        'Import completed: ${importResult.successCount} imported, ${importResult.failCount} skipped',
        importResult: importResult,
        filePath: event.filePath,
      )),
    );
  }

  void _onResetState(
    ResetDataIoStateEvent event,
    Emitter<DataIoState> emit,
  ) {
    emit(const DataIoInitial());
  }
}
