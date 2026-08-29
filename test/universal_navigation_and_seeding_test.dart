import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/data/models/store_blueprint_model.dart';
import 'package:empos/features/catalog/data/datasources/catalog_local_data_source.dart';
import 'package:hive/hive.dart';
import 'dart:io';

void main() {
  late Directory tempDir;
  late CatalogLocalDataSource localDataSource;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('empos_universal_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  setUp(() async {
    await Hive.openBox<String>(CatalogLocalDataSourceImpl.productsBoxName);
    await Hive.openBox<String>(CatalogLocalDataSourceImpl.categoriesBoxName);
    localDataSource = CatalogLocalDataSourceImpl();
  });

  tearDown(() async {
    final prodBox = await Hive.openBox<String>(CatalogLocalDataSourceImpl.productsBoxName);
    final catBox = await Hive.openBox<String>(CatalogLocalDataSourceImpl.categoriesBoxName);
    await prodBox.clear();
    await catBox.clear();
  });

  group('Universal 11-Vertical Blueprint Preset Defaults', () {
    test('Automotive preset defaults configure pipeline and stock, disable retail pos', () {
      final bp = StoreBlueprintModel.defaultAutoRepairBlueprint();
      expect(bp.isEnabled('sw.service_pipeline'), isTrue);
      expect(bp.isEnabled('sw.inventory_catalog'), isTrue);
      expect(bp.isEnabled('sw.retail_pos'), isFalse);
      expect(bp.isEnabled('sw.clinic_reception'), isFalse);
    });

    test('Dental & Medical preset defaults configure clinical reception & doctor station', () {
      final dental = StoreBlueprintModel.defaultDentalBlueprint();
      expect(dental.isEnabled('sw.clinic_reception'), isTrue);
      expect(dental.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(dental.isEnabled('sw.bookings_calendar'), isTrue);
      expect(dental.isEnabled('sw.retail_pos'), isFalse);

      final clinic = StoreBlueprintModel.defaultClinicBlueprint();
      expect(clinic.isEnabled('sw.clinic_reception'), isTrue);
      expect(clinic.isEnabled('sw.clinic_doctor_station'), isTrue);
      expect(clinic.isEnabled('sw.retail_pos'), isFalse);
    });

    test('Hospitality, Beauty & Fitness presets configure schedule and bookings', () {
      final hotel = StoreBlueprintModel.defaultHotelBlueprint();
      expect(hotel.isEnabled('sw.bookings_calendar'), isTrue);
      expect(hotel.isEnabled('sw.customers_crm'), isTrue);
      expect(hotel.isEnabled('sw.retail_pos'), isFalse);

      final salon = StoreBlueprintModel.defaultSalonBlueprint();
      expect(salon.isEnabled('sw.bookings_calendar'), isTrue);
      expect(salon.isEnabled('sw.customers_crm'), isTrue);
      expect(salon.isEnabled('sw.retail_pos'), isFalse);

      final gym = StoreBlueprintModel.defaultGymBlueprint();
      expect(gym.isEnabled('sw.bookings_calendar'), isTrue);
      expect(gym.isEnabled('sw.customers_crm'), isTrue);
      expect(gym.isEnabled('sw.retail_pos'), isFalse);
    });

    test('Retail & Food Beverage presets configure retail pos and catalog', () {
      final retail = StoreBlueprintModel.defaultRetailBlueprint();
      expect(retail.isEnabled('sw.retail_pos'), isTrue);
      expect(retail.isEnabled('sw.orders_returns'), isTrue);
      expect(retail.isEnabled('sw.inventory_catalog'), isTrue);
      expect(retail.isEnabled('sw.clinic_reception'), isFalse);

      final restaurant = StoreBlueprintModel.defaultRestaurantBlueprint();
      expect(restaurant.isEnabled('sw.retail_pos'), isTrue);
      expect(restaurant.isEnabled('sw.orders_returns'), isTrue);
      expect(restaurant.isEnabled('sw.inventory_catalog'), isTrue);
      expect(restaurant.isEnabled('sw.clinic_reception'), isFalse);
    });
  });

  group('Universal Dynamic Catalog Seed Data Generator', () {
    test('Seeds Automotive maintenance & parts items', () async {
      final bp = StoreBlueprintModel.defaultAutoRepairBlueprint();
      await localDataSource.seedCatalogForBlueprint(bp, force: true);

      final products = await localDataSource.getProducts();
      final categories = await localDataSource.getCategories();

      expect(products.isNotEmpty, isTrue);
      expect(categories.isNotEmpty, isTrue);
      expect(products.any((p) => p.nameEn.contains('Oil Change')), isTrue);
      expect(products.any((p) => p.nameEn.contains('Brake Pad')), isTrue);
    });

    test('Seeds Dental & Medical clinical procedure codes', () async {
      final bp = StoreBlueprintModel.defaultDentalBlueprint();
      await localDataSource.seedCatalogForBlueprint(bp, force: true);

      final products = await localDataSource.getProducts();
      expect(products.any((p) => p.nameEn.contains('Consultation')), isTrue);
      expect(products.any((p) => p.nameEn.contains('Tooth Filling') || p.nameEn.contains('Restoration')), isTrue);
      expect(products.any((p) => p.nameEn.contains('Scaling & Polishing')), isTrue);
    });

    test('Seeds Beauty & Spa salon treatment items', () async {
      final bp = StoreBlueprintModel.defaultSalonBlueprint();
      await localDataSource.seedCatalogForBlueprint(bp, force: true);

      final products = await localDataSource.getProducts();
      expect(products.any((p) => p.nameEn.contains('Haircut') || p.nameEn.contains('Keratin')), isTrue);
      expect(products.any((p) => p.nameEn.contains('Massage')), isTrue);
    });

    test('Seeds Fitness gym memberships & PT sessions', () async {
      final bp = StoreBlueprintModel.defaultGymBlueprint();
      await localDataSource.seedCatalogForBlueprint(bp, force: true);

      final products = await localDataSource.getProducts();
      expect(products.any((p) => p.nameEn.contains('Gym Pass') || p.nameEn.contains('Membership')), isTrue);
      expect(products.any((p) => p.nameEn.contains('PT Session')), isTrue);
    });

    test('Seeds Hospitality hotel room rates and venues', () async {
      final bp = StoreBlueprintModel.defaultHotelBlueprint();
      await localDataSource.seedCatalogForBlueprint(bp, force: true);

      final products = await localDataSource.getProducts();
      expect(products.any((p) => p.nameEn.contains('Room') || p.nameEn.contains('Suite')), isTrue);
      expect(products.any((p) => p.nameEn.contains('Banquet Hall')), isTrue);
    });
  });
}
