import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/data_io_repository.dart';

class GenerateTemplateUseCase {
  final DataIoRepository repository;

  GenerateTemplateUseCase(this.repository);

  Future<Either<Failure, String>> call(String destinationPath) async {
    return await repository.generateCatalogTemplate(destinationPath);
  }
}
