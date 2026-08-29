import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/work_order_ticket_model.dart';

abstract class WorkOrderLocalDataSource {
  Future<List<WorkOrderTicketModel>> getWorkOrders();
  Future<WorkOrderTicketModel?> getWorkOrderById(String id);
  Future<void> saveWorkOrder(WorkOrderTicketModel ticket);
  Future<void> deleteWorkOrder(String id);
}

class WorkOrderLocalDataSourceImpl implements WorkOrderLocalDataSource {
  static const String workOrdersBoxName = 'empos_work_orders_box';

  Future<Box<dynamic>> _openBox() async {
    if (Hive.isBoxOpen(workOrdersBoxName)) {
      return Hive.box<dynamic>(workOrdersBoxName);
    }
    return await Hive.openBox<dynamic>(workOrdersBoxName);
  }

  @override
  Future<List<WorkOrderTicketModel>> getWorkOrders() async {
    try {
      final box = await _openBox();
      final List<WorkOrderTicketModel> list = [];
      for (final raw in box.values) {
        if (raw != null) {
          if (raw is String) {
            list.add(WorkOrderTicketModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)));
          } else if (raw is Map) {
            list.add(WorkOrderTicketModel.fromJson(Map<String, dynamic>.from(raw)));
          }
        }
      }
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve work orders: $e');
    }
  }

  @override
  Future<WorkOrderTicketModel?> getWorkOrderById(String id) async {
    try {
      final box = await _openBox();
      final raw = box.get(id);
      if (raw == null) return null;
      if (raw is String) {
        return WorkOrderTicketModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
      }
      return WorkOrderTicketModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve work order $id: $e');
    }
  }

  @override
  Future<void> saveWorkOrder(WorkOrderTicketModel ticket) async {
    try {
      final box = await _openBox();
      await box.put(ticket.id, jsonEncode(ticket.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save work order: $e');
    }
  }

  @override
  Future<void> deleteWorkOrder(String id) async {
    try {
      final box = await _openBox();
      await box.delete(id);
    } catch (e) {
      throw CacheException(message: 'Failed to delete work order: $e');
    }
  }
}
