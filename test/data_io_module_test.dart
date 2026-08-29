import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:empos/features/catalog/data/models/product_model.dart';
import 'package:empos/features/data_io/data/repositories/data_io_repository_impl.dart';
import 'package:empos/features/data_io/domain/usecases/export_catalog_usecase.dart';
import 'package:empos/features/data_io/domain/usecases/generate_template_usecase.dart';
import 'package:empos/features/data_io/domain/usecases/import_catalog_usecase.dart';
import 'package:empos/features/data_io/presentation/bloc/data_io_bloc.dart';
import 'package:empos/features/data_io/presentation/bloc/data_io_event.dart';
import 'package:empos/features/data_io/presentation/bloc/data_io_state.dart';

class MockCatalogLocalDataSource extends Mock implements CatalogLocalDataSource {}

void main() {
  late MockCatalogLocalDataSource mockCatalogDataSource;
  late DataIoRepositoryImpl repository;
  late Directory tempDir;

  setUpAll(() {
    registerFallbackValue(
      const ProductModel(
        id: 'fallback',
        nameEn: 'fallback',
        categoryId: 'cat-general',
        price: 10.0,
        stock: 10,
        barcode: '123',
      ),
    );
  });

  setUp(() async {
    mockCatalogDataSource = MockCatalogLocalDataSource();
    repository = DataIoRepositoryImpl(catalogLocalDataSource: mockCatalogDataSource);
    tempDir = await Directory.systemTemp.createTemp('empos_data_io_test_');
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  const tExistingProduct = ProductModel(
    id: 'prod-001',
    nameEn: 'Arabic Coffee 500g',
    nameAr: 'قهوة عربي',
    categoryId: 'cat-coffee',
    price: 120.0,
    cost: 80.0,
    stock: 45,
    barcode: '622100000099',
  );

  group('DataIoRepositoryImpl - Template & Export Verification', () {
    test('generateCatalogTemplate creates CSV template with 7 mandatory columns', () async {
      final templatePath = '${tempDir.path}/catalog_template.csv';
      final result = await repository.generateCatalogTemplate(templatePath);

      expect(result.isRight(), isTrue);
      final file = File(templatePath);
      expect(file.existsSync(), isTrue);

      final content = await file.readAsString();
      expect(content, contains('Barcode,Name_EN,Name_AR,Category,CostPrice,RetailPrice,StockQty'));
      expect(content, contains('Espresso Blend 250g'));
      expect(content, contains('Mineral Water 1.5L'));
    });

    test('exportCatalog queries catalog and formats all rows into CSV', () async {
      final exportPath = '${tempDir.path}/catalog_export.csv';
      when(() => mockCatalogDataSource.getProducts()).thenAnswer((_) async => [tExistingProduct]);

      final result = await repository.exportCatalog(exportPath);

      expect(result.isRight(), isTrue);
      final file = File(exportPath);
      expect(file.existsSync(), isTrue);

      final content = await file.readAsString();
      expect(content, contains('622100000099,Arabic Coffee 500g,قهوة عربي,coffee,80.0,120.0,45'));
    });
  });

  group('DataIoRepositoryImpl - Smart Import & Auto-Barcode Generation', () {
    test('importCatalog parses rows and auto-generates 8-digit numeric barcode if empty', () async {
      final importPath = '${tempDir.path}/valid_products.csv';
      final csvContent = '''
Barcode,Name_EN,Name_AR,Category,CostPrice,RetailPrice,StockQty
622100000100,Dark Roast Beans,بن غامق,Coffee,70.0,130.0,60
,Fresh Croissant,,Bakery,15.0,35.0,25
''';
      await File(importPath).writeAsString(csvContent);

      final savedProducts = <ProductModel>[];
      when(() => mockCatalogDataSource.saveProduct(any())).thenAnswer((invocation) async {
        final product = invocation.positionalArguments[0] as ProductModel;
        savedProducts.add(product);
      });

      final result = await repository.importCatalog(importPath);

      expect(result.isRight(), isTrue);
      result.fold((l) => fail('Should succeed'), (importResult) {
        expect(importResult.successCount, equals(2));
        expect(importResult.failCount, equals(0));
        expect(importResult.isFullSuccess, isTrue);
      });

      expect(savedProducts.length, equals(2));
      // First product kept existing barcode
      expect(savedProducts[0].barcode, equals('622100000100'));
      expect(savedProducts[0].nameEn, equals('Dark Roast Beans'));

      // Second product received auto-generated 8-digit barcode
      expect(savedProducts[1].barcode.length, equals(8));
      expect(int.tryParse(savedProducts[1].barcode), isNotNull);
      expect(savedProducts[1].nameEn, equals('Fresh Croissant'));
      expect(savedProducts[1].price, equals(35.0));
    });

    test('importCatalog is resilient: skips malformed rows and imports valid ones', () async {
      final importPath = '${tempDir.path}/mixed_products.csv';
      final csvContent = '''
Barcode,Name_EN,Name_AR,Category,CostPrice,RetailPrice,StockQty
622100000101,Valid Item 1,,General,10.0,25.0,50
,Missing Name Row,,General,10.0,INVALID_PRICE,50
622100000103,Valid Item 2,,General,12.0,30.0,40
, ,Arabic Only,General,5.0,20.0,10
''';
      await File(importPath).writeAsString(csvContent);

      when(() => mockCatalogDataSource.saveProduct(any())).thenAnswer((_) async {});

      final result = await repository.importCatalog(importPath);

      expect(result.isRight(), isTrue);
      result.fold((l) => fail('Should succeed'), (importResult) {
        expect(importResult.successCount, equals(2));
        expect(importResult.failCount, equals(2));
        expect(importResult.hasErrors, isTrue);
        expect(importResult.errorMessages.length, equals(2));
        expect(importResult.errorMessages[0], contains('Row 3'));
        expect(importResult.errorMessages[1], contains('Row 5'));
      });
    });
  });

  group('DataIo Use Cases Execution', () {
    test('GenerateTemplateUseCase delegates to repository', () async {
      final useCase = GenerateTemplateUseCase(repository);
      final dest = '${tempDir.path}/usecase_template.csv';
      final res = await useCase(dest);
      expect(res.isRight(), isTrue);
    });

    test('ExportCatalogUseCase delegates to repository', () async {
      final useCase = ExportCatalogUseCase(repository);
      when(() => mockCatalogDataSource.getProducts()).thenAnswer((_) async => []);
      final dest = '${tempDir.path}/usecase_export.csv';
      final res = await useCase(dest);
      expect(res.isRight(), isTrue);
    });

    test('ImportCatalogUseCase delegates to repository', () async {
      final useCase = ImportCatalogUseCase(repository);
      final dest = '${tempDir.path}/usecase_import.csv';
      await File(dest).writeAsString('Barcode,Name_EN,Name_AR,Category,CostPrice,RetailPrice,StockQty\n');
      final res = await useCase(dest);
      expect(res.isRight(), isTrue);
    });
  });

  group('DataIoBloc State Management Tests', () {
    late DataIoBloc bloc;

    setUp(() {
      bloc = DataIoBloc(
        generateTemplateUseCase: GenerateTemplateUseCase(repository),
        exportCatalogUseCase: ExportCatalogUseCase(repository),
        importCatalogUseCase: ImportCatalogUseCase(repository),
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is DataIoInitial', () {
      expect(bloc.state, equals(const DataIoInitial()));
    });

    test('emits [DataIoLoading, DataIoSuccess] when GenerateTemplateEvent succeeds', () async {
      final dest = '${tempDir.path}/bloc_template.csv';
      final expectedStates = [
        const DataIoLoading('Generating CSV Template...'),
        DataIoSuccess('CSV template successfully saved!', filePath: dest),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(GenerateTemplateEvent(dest));
    });

    test('emits [DataIoLoading, DataIoSuccess] when ExportCatalogEvent succeeds', () async {
      final dest = '${tempDir.path}/bloc_export.csv';
      when(() => mockCatalogDataSource.getProducts()).thenAnswer((_) async => []);

      final expectedStates = [
        const DataIoLoading('Exporting Catalog to CSV...'),
        DataIoSuccess('Catalog successfully exported!', filePath: dest),
      ];

      expectLater(bloc.stream, emitsInOrder(expectedStates));
      bloc.add(ExportCatalogEvent(dest));
    });
  });
}
