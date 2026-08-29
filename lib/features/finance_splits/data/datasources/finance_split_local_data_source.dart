import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/revenue_split_rule_model.dart';

abstract class FinanceSplitLocalDataSource {
  Future<List<FinanceSettlementLogModel>> getSettlements();
  Future<FinanceSettlementLogModel?> getSettlementById(String id);
  Future<void> saveSettlement(FinanceSettlementLogModel settlement);
}

class FinanceSplitLocalDataSourceImpl implements FinanceSplitLocalDataSource {
  static const String financeSplitsBoxName = 'empos_finance_splits_box';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(financeSplitsBoxName)) {
      return Hive.box<dynamic>(financeSplitsBoxName);
    }
    return await Hive.openBox<dynamic>(financeSplitsBoxName);
  }

  @override
  Future<List<FinanceSettlementLogModel>> getSettlements() async {
    try {
      final box = await _openBox();
      final List<FinanceSettlementLogModel> list = [];
      for (final raw in box.values) {
        if (raw != null) {
          if (raw is String) {
            list.add(FinanceSettlementLogModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)));
          } else if (raw is Map) {
            list.add(FinanceSettlementLogModel.fromJson(Map<String, dynamic>.from(raw)));
          }
        }
      }
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve finance settlement logs: $e');
    }
  }

  @override
  Future<FinanceSettlementLogModel?> getSettlementById(String id) async {
    try {
      final box = await _openBox();
      final raw = box.get(id);
      if (raw == null) return null;
      if (raw is String) {
        return FinanceSettlementLogModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
      }
      return FinanceSettlementLogModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve settlement $id: $e');
    }
  }

  @override
  Future<void> saveSettlement(FinanceSettlementLogModel settlement) async {
    try {
      final box = await _openBox();
      await box.put(settlement.id, jsonEncode(settlement.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save settlement: $e');
    }
  }
}
