import 'package:hive/hive.dart';
import '../models/cash_transaction_model.dart';
import '../models/shift_model.dart';

abstract class ShiftLocalDataSource {
  Future<ShiftModel?> getActiveShift();
  Future<ShiftModel?> getShiftById(String id);
  Future<List<ShiftModel>> getAllShifts();
  Future<void> saveShift(ShiftModel shift);
  Future<void> setActiveShiftId(String? shiftId);

  Future<void> saveCashTransaction(CashTransactionModel transaction);
  Future<List<CashTransactionModel>> getCashTransactionsForShift(String shiftId);
}

class ShiftLocalDataSourceImpl implements ShiftLocalDataSource {
  static const String shiftsBoxName = 'empos_shifts_box';
  static const String cashTxBoxName = 'empos_cash_transactions_box';
  static const String activeShiftMetaKey = 'ACTIVE_SHIFT_ID';

  Future<Box<dynamic>> _openShiftsBox() async {
    if (Hive.isBoxOpen(shiftsBoxName)) {
      return Hive.box<dynamic>(shiftsBoxName);
    }
    return await Hive.openBox<dynamic>(shiftsBoxName);
  }

  Future<Box<dynamic>> _openCashTxBox() async {
    if (Hive.isBoxOpen(cashTxBoxName)) {
      return Hive.box<dynamic>(cashTxBoxName);
    }
    return await Hive.openBox<dynamic>(cashTxBoxName);
  }

  @override
  Future<ShiftModel?> getActiveShift() async {
    final box = await _openShiftsBox();
    final activeId = box.get(activeShiftMetaKey) as String?;
    if (activeId == null) return null;

    final raw = box.get(activeId);
    if (raw == null) return null;

    final map = Map<String, dynamic>.from(raw as Map);
    return ShiftModel.fromJson(map);
  }

  @override
  Future<ShiftModel?> getShiftById(String id) async {
    final box = await _openShiftsBox();
    final raw = box.get(id);
    if (raw == null) return null;

    final map = Map<String, dynamic>.from(raw as Map);
    return ShiftModel.fromJson(map);
  }

  @override
  Future<List<ShiftModel>> getAllShifts() async {
    final box = await _openShiftsBox();
    final List<ShiftModel> list = [];

    for (final key in box.keys) {
      if (key == activeShiftMetaKey) continue;
      final raw = box.get(key);
      if (raw != null) {
        list.add(ShiftModel.fromJson(Map<String, dynamic>.from(raw as Map)));
      }
    }

    list.sort((a, b) => b.startTime.compareTo(a.startTime));
    return list;
  }

  @override
  Future<void> saveShift(ShiftModel shift) async {
    final box = await _openShiftsBox();
    await box.put(shift.id, shift.toJson());
  }

  @override
  Future<void> setActiveShiftId(String? shiftId) async {
    final box = await _openShiftsBox();
    if (shiftId == null) {
      await box.delete(activeShiftMetaKey);
    } else {
      await box.put(activeShiftMetaKey, shiftId);
    }
  }

  @override
  Future<void> saveCashTransaction(CashTransactionModel transaction) async {
    final box = await _openCashTxBox();
    await box.put(transaction.id, transaction.toJson());
  }

  @override
  Future<List<CashTransactionModel>> getCashTransactionsForShift(
    String shiftId,
  ) async {
    final box = await _openCashTxBox();
    final List<CashTransactionModel> list = [];

    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw != null) {
        final tx = CashTransactionModel.fromJson(
          Map<String, dynamic>.from(raw as Map),
        );
        if (tx.shiftId == shiftId) {
          list.add(tx);
        }
      }
    }

    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    return list;
  }
}
