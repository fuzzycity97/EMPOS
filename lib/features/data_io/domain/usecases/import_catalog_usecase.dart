import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/import_result.dart';
import '../repositories/data_io_repository.dart';

class ImportCatalogUseCase {
  final DataIoRepository repository;

  ImportCatalogUseCase(this.repository);

  Future<Either<Failure, ImportResult>> call(String filePath) async {
    return await repository.importCatalog(filePath);
  }
}
