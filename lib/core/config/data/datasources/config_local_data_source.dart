import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/store_blueprint_model.dart';

abstract class ConfigLocalDataSource {
  Future<StoreBlueprintModel> getStoreBlueprint();
  Future<void> saveStoreBlueprint(StoreBlueprintModel model);
  Future<void> clearStoreBlueprint();
}

class ConfigLocalDataSourceImpl implements ConfigLocalDataSource {
  static const String configBoxName = 'empos_config_box';
  static const String blueprintKey = 'store_blueprint';

  Future<Box<String>> get _box async => await Hive.openBox<String>(configBoxName);

  @override
  Future<StoreBlueprintModel> getStoreBlueprint() async {
    try {
      final box = await _box;
      final raw = box.get(blueprintKey);
      if (raw != null && raw.isNotEmpty) {
        return StoreBlueprintModel.fromRaw(raw);
      }
      // If no blueprint exists in Hive, throw CacheException to route to StoreBuilderWizardPage
      throw CacheException(message: 'No store blueprint configured in database');
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Failed to read store blueprint from Hive: $e');
    }
  }

  @override
  Future<void> saveStoreBlueprint(StoreBlueprintModel model) async {
    try {
      final box = await _box;
      final encoded = jsonEncode(model.toJson());
      await box.put(blueprintKey, encoded);
    } catch (e) {
      throw CacheException(message: 'Failed to save store blueprint to Hive: $e');
    }
  }

  @override
  Future<void> clearStoreBlueprint() async {
    try {
      final box = await _box;
      await box.delete(blueprintKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear store blueprint from Hive: $e');
    }
  }
}
