import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../catalog/domain/entities/product.dart';
import '../../../catalog/domain/repositories/catalog_repository.dart';
import '../entities/clinic_visit.dart';
import '../repositories/clinic_repository.dart';

class CompleteVisitUseCase {
  final ClinicRepository repository;
  final CatalogRepository? catalogRepository;

  CompleteVisitUseCase(this.repository, [this.catalogRepository]);

  static const Map<String, List<String>> defaultProcedureConsumables = {
    'root_canal': [
      'prod_dental_anesthetic',
      'prod_gutta_percha',
      'prod_dental_files',
    ],
    'composite_filling': [
      'prod_dental_composite',
      'prod_bonding_agent',
      'prod_articulating_paper',
    ],
    'tooth_extraction': [
      'prod_dental_anesthetic',
      'prod_gauze_pads',
      'prod_suture',
    ],
    'teeth_cleaning': [
      'prod_prophy_paste',
      'prod_fluoride_varnish',
    ],
    'general_consultation': [
      'prod_disposable_gloves',
      'prod_dental_mask',
    ],
  };

  Future<Either<Failure, ClinicVisit>> call(ClinicVisit visit) async {
    final result = await repository.completeVisit(visit);

    return result.fold(
      (failure) => Left(failure),
      (completedVisit) async {
        if (catalogRepository != null) {
          await _deductClinicConsumables(completedVisit);
        }
        return Right(completedVisit);
      },
    );
  }

  Future<void> _deductClinicConsumables(ClinicVisit visit) async {
    final productsResult = await catalogRepository!.getProducts();
    final List<Product> allProducts = List<Product>.from(productsResult.getOrElse(() => []));

    for (final proc in visit.appliedProcedures) {
      final requiredConsumables = <String>[...proc.requiredConsumables];

      if (requiredConsumables.isEmpty) {
        final codeLower = proc.code.toLowerCase().replaceAll(' ', '_');
        for (final entry in defaultProcedureConsumables.entries) {
          if (codeLower.contains(entry.key) || entry.key.contains(codeLower)) {
            requiredConsumables.addAll(entry.value);
            break;
          }
        }
      }

      for (final consumableId in requiredConsumables) {
        // Find existing product or create match placeholder
        final cleanId = consumableId.toLowerCase().replaceAll('prod_', '').replaceAll('_', ' ');
        final match = allProducts.firstWhere(
          (p) =>
              p.id == consumableId ||
              p.barcode == consumableId ||
              p.nameEn.toLowerCase() == cleanId,
          orElse: () => allProducts.firstWhere(
            (p) => p.nameEn.toLowerCase().contains(cleanId),
            orElse: () => Product(
              id: consumableId,
              nameEn: consumableId,
              categoryId: 'cat_clinic_supplies',
              price: 0.0,
              stock: 0,
              barcode: consumableId,
            ),
          ),
        );

        await catalogRepository!.updateStock(match.id, -1);
      }
    }
  }
}

typedef CompleteExaminationUseCase = CompleteVisitUseCase;
