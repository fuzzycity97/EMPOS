import 'dart:io';
import 'package:csv/csv.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../catalog/data/datasources/catalog_local_data_source.dart';
import '../../../catalog/data/models/product_model.dart';
import '../../domain/entities/import_result.dart';
import '../../domain/repositories/data_io_repository.dart';

class DataIoRepositoryImpl implements DataIoRepository {
  final CatalogLocalDataSource catalogLocalDataSource;

  static const List<String> csvHeaders = [
    'Barcode',
    'Name_EN',
    'Name_AR',
    'Category',
    'CostPrice',
    'RetailPrice',
    'StockQty',
  ];

  DataIoRepositoryImpl({required this.catalogLocalDataSource});

  @override
  Future<Either<Failure, String>> generateCatalogTemplate(String destinationPath) async {
    try {
      final List<List<dynamic>> rows = [
        csvHeaders,
        ['622100000001', 'Espresso Blend 250g', 'بن اسبريسو حبوب', 'Coffee', 65.0, 110.0, 50],
        ['', 'Butter Croissant Large', 'كرواسون زبدة فرنسي', 'Bakery', 20.0, 45.0, 30],
        ['622100000003', 'Mineral Water 1.5L', 'مياه معدنية 1.5 لتر', 'Beverages', 4.0, 9.0, 100],
      ];

      final csvData = const ListToCsvConverter().convert(rows);
      final file = File(destinationPath);
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      await file.writeAsString(csvData);

      return Right(destinationPath);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to generate CSV template: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> exportCatalog(String destinationPath) async {
    try {
      final products = await catalogLocalDataSource.getProducts();

      final List<List<dynamic>> rows = [
        csvHeaders,
        ...products.map((p) => [
              p.barcode,
              p.nameEn,
              p.nameAr ?? '',
              p.categoryId.replaceAll('cat-', '').replaceAll('_', ' '),
              p.cost ?? 0.0,
              p.price,
              p.stock,
            ]),
      ];

      final csvData = const ListToCsvConverter().convert(rows);
      final file = File(destinationPath);
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      await file.writeAsString(csvData);

      return Right(destinationPath);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to export catalog: $e'));
    }
  }

  @override
  Future<Either<Failure, ImportResult>> importCatalog(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return Left(ServerFailure(message: 'CSV file not found at path: $filePath'));
      }

      final rawCsv = await file.readAsString();
      if (rawCsv.trim().isEmpty) {
        return Left(ServerFailure(message: 'CSV file is completely empty'));
      }

      final List<List<dynamic>> rows = const CsvToListConverter(
        shouldParseNumbers: false,
        eol: '\n',
      ).convert(rawCsv.replaceAll('\r\n', '\n'));

      if (rows.isEmpty) {
        return Left(ServerFailure(message: 'No data rows found in CSV file'));
      }

      int successCount = 0;
      int failCount = 0;
      final List<String> errorMessages = [];

      // Determine if first row is header row
      int startRow = 0;
      if (rows.isNotEmpty) {
        final firstCell = rows[0].isNotEmpty ? rows[0][0]?.toString().toLowerCase() : '';
        if (firstCell != null && (firstCell.contains('barcode') || firstCell.contains('name'))) {
          startRow = 1;
        }
      }

      for (int i = startRow; i < rows.length; i++) {
        final row = rows[i];
        if (row.isEmpty || (row.length == 1 && row[0]?.toString().trim().isEmpty == true)) {
          continue; // Skip blank lines
        }

        final rowIndex = i + 1;

        try {
          // 1. Name EN (Mandatory)
          final nameEn = row.length > 1 ? row[1]?.toString().trim() ?? '' : '';
          if (nameEn.isEmpty) {
            throw Exception('Missing required product Name_EN');
          }

          // 2. Barcode (Auto-generate unique 8-digit numeric if empty)
          String barcode = row.isNotEmpty ? row[0]?.toString().trim() ?? '' : '';
          if (barcode.isEmpty) {
            final uniqueSeed = (DateTime.now().microsecondsSinceEpoch + i) % 90000000 + 10000000;
            barcode = uniqueSeed.toString();
          }

          // 3. Name AR (Optional)
          final nameAr = row.length > 2 ? row[2]?.toString().trim() : null;

          // 4. Category
          final categoryRaw = row.length > 3 ? row[3]?.toString().trim() ?? 'General' : 'General';
          final categoryId = categoryRaw.isEmpty
              ? 'cat-general'
              : (categoryRaw.toLowerCase().startsWith('cat-')
                  ? categoryRaw.toLowerCase()
                  : 'cat-${categoryRaw.toLowerCase().replaceAll(RegExp(r'\s+'), '_')}');

          // 5. Cost Price
          final costPrice = row.length > 4 ? double.tryParse(row[4]?.toString().trim() ?? '') ?? 0.0 : 0.0;

          // 6. Retail Price (Mandatory & Positive)
          final rawPrice = row.length > 5 ? row[5]?.toString().trim() ?? '' : '';
          final price = double.tryParse(rawPrice);
          if (price == null || price <= 0) {
            throw Exception('Invalid Retail Price: "$rawPrice"');
          }

          // 7. Stock Qty
          final stock = row.length > 6 ? int.tryParse(row[6]?.toString().trim() ?? '') ?? 50 : 50;

          final productModel = ProductModel(
            id: 'PROD-${DateTime.now().millisecondsSinceEpoch}-$i',
            nameEn: nameEn,
            nameAr: (nameAr != null && nameAr.isNotEmpty) ? nameAr : null,
            categoryId: categoryId,
            price: price,
            cost: costPrice > 0 ? costPrice : null,
            stock: stock,
            barcode: barcode,
            trackQty: true,
            isEnabled: true,
          );

          await catalogLocalDataSource.saveProduct(productModel);
          successCount++;
        } catch (e) {
          failCount++;
          errorMessages.add('Row $rowIndex: $e');
        }
      }

      return Right(
        ImportResult(
          successCount: successCount,
          failCount: failCount,
          errorMessages: errorMessages,
        ),
      );
    } catch (e) {
      return Left(ServerFailure(message: 'Unexpected error during CSV catalog import: $e'));
    }
  }
}
