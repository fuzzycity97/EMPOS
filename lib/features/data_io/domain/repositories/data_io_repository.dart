import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/import_result.dart';

abstract class DataIoRepository {
  Future<Either<Failure, String>> generateCatalogTemplate(String destinationPath);
  Future<Either<Failure, String>> exportCatalog(String destinationPath);
  Future<Either<Failure, ImportResult>> importCatalog(String filePath);
}
