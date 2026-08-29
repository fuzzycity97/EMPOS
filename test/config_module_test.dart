import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/core/config/data/datasources/config_local_data_source.dart';
import 'package:empos/core/config/data/models/store_blueprint_model.dart';
import 'package:empos/core/config/data/repositories/config_repository_impl.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';
import 'package:empos/core/error/exceptions.dart';

class MockConfigLocalDataSource extends Mock implements ConfigLocalDataSource {}

void main() {
  group('StoreBlueprintModel Serialization & Parsing', () {
    test('parses from modern JSON with direct toggles map', () {
      final json = {
        'storeName': 'PharmaCare Plus',
        'storeBranch': 'Zamalek Branch',
        'industryType': 'pharmacy',
        'currency': 'EGP',
        'taxRate': 14.0,
        'taxMode': 'taxExclusive',
        'themeColorHex': '#10B981',
        'secondaryColorHex': '#6366F1',
        'isDarkMode': true,
        'toggles': {
          'sw.box_and_strip_selling': true,
          'sw.insurance_copay': true,
          'hw.barcode_scanner': true,
        },
      };

      final model = StoreBlueprintModel.fromJson(json);

      expect(model.storeName, equals('PharmaCare Plus'));
      expect(model.storeBranch, equals('Zamalek Branch'));
      expect(model.industryType, equals(IndustryType.pharmacy));
      expect(model.isPharmacy, isTrue);
      expect(model.currency, equals('EGP'));
      expect(model.themeColorHex, equals('#10B981'));
      expect(model.isEnabled('sw.box_and_strip_selling'), isTrue);
      expect(model.isEnabled('sw.non_existent'), isFalse);
    });

    test('parses legacy builder JSON structure with softwareToggles and hardwareToggles lists', () {
      final legacyJson = {
        'name': 'Metro Supermarket',
        'industry': 'retail',
        'currencySymbol': 'E£',
        'taxCalculationMode': 'TaxInclusive',
        'primaryColor': '#F59E0B',
        'hardwareToggles': [
          {'key': 'hw.grocery_scale', 'default': true},
          {'key': 'hw.customer_display', 'default': false},
        ],
        'softwareToggles': [
          {'key': 'sw.grocery_weight_pricing', 'default': true},
          {'key': 'sw.loyalty_points', 'default': true},
        ],
      };

      final model = StoreBlueprintModel.fromJson(legacyJson);

      expect(model.storeName, equals('Metro Supermarket'));
      expect(model.industryType, equals(IndustryType.retail));
      expect(model.currency, equals('E£'));
      expect(model.taxMode, equals(TaxMode.taxInclusive));
      expect(model.themeColorHex, equals('#F59E0B'));
      expect(model.isEnabled('hw.grocery_scale'), isTrue);
      expect(model.isEnabled('hw.customer_display'), isFalse);
      expect(model.isEnabled('sw.grocery_weight_pricing'), isTrue);
    });

    test('defaultRetailBlueprint provides full turnkey toggles ready for immediate POS launch', () {
      final defaultBp = StoreBlueprintModel.defaultRetailBlueprint();

      expect(defaultBp.storeName, equals('OmniTrack Retail Store'));
      expect(defaultBp.isEnabled('hw.retail_barcode_scanner'), isTrue);
      expect(defaultBp.isEnabled('sw.customer_debt_tracking'), isTrue);
      expect(defaultBp.isEnabled('sw.shift_drawer_reconciliation'), isTrue);
    });
  });

  group('ConfigRepositoryImpl & Hive LocalDataSource Integration', () {
    late MockConfigLocalDataSource mockDataSource;
    late ConfigRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(
        StoreBlueprintModel.fromEntity(StoreBlueprintModel.defaultRetailBlueprint()),
      );
    });

    setUp(() {
      mockDataSource = MockConfigLocalDataSource();
      repository = ConfigRepositoryImpl(localDataSource: mockDataSource);
    });

    test('loadStoreBlueprint returns stored blueprint when Hive has data', () async {
      final tModel = StoreBlueprintModel(
        storeName: 'Al-Ahram Supermarket',
        industryType: IndustryType.supermarket,
        currency: 'EGP',
        toggles: const {'sw.grocery_weight_pricing': true},
      );
      when(() => mockDataSource.getStoreBlueprint()).thenAnswer((_) async => tModel);

      final result = await repository.loadStoreBlueprint();

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail(f.message),
        (bp) {
          expect(bp.storeName, equals('Al-Ahram Supermarket'));
          expect(bp.industryType, equals(IndustryType.supermarket));
          expect(bp.isSupermarket, isTrue);
          expect(bp.isEnabled('sw.grocery_weight_pricing'), isTrue);
        },
      );
    });

    test('loadStoreBlueprint returns Left(CacheFailure) when Hive has no blueprint stored', () async {
      when(() => mockDataSource.getStoreBlueprint())
          .thenThrow(CacheException(message: 'No store blueprint configured in database'));

      final result = await repository.loadStoreBlueprint();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f.message, contains('No store blueprint configured')),
        (_) => fail('Expected failure'),
      );
    });

    test('getFeatureToggle returns correct boolean for specified key', () async {
      final tModel = StoreBlueprintModel(
        storeName: 'Store',
        toggles: const {'sw.quick_pay': true},
      );
      when(() => mockDataSource.getStoreBlueprint()).thenAnswer((_) async => tModel);

      final resultTrue = await repository.getFeatureToggle('sw.quick_pay');
      final resultFalse = await repository.getFeatureToggle('sw.not_configured');

      expect(resultTrue.getOrElse(() => false), isTrue);
      expect(resultFalse.getOrElse(() => false), isFalse);
    });

    test('saveStoreBlueprint delegates to mockDataSource.saveStoreBlueprint', () async {
      final tModel = StoreBlueprintModel.defaultRetailBlueprint();
      when(() => mockDataSource.saveStoreBlueprint(any())).thenAnswer((_) async {});

      final result = await repository.saveStoreBlueprint(tModel);

      expect(result.isRight(), isTrue);
      verify(() => mockDataSource.saveStoreBlueprint(any())).called(1);
    });
  });
}
