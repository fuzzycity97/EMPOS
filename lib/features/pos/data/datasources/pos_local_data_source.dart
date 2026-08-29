import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/cart_model.dart';
import '../models/hold_tab_model.dart';
import '../models/order_model.dart';

abstract class PosLocalDataSource {
  Future<CartModel> getActiveCart();
  Future<void> saveActiveCart(CartModel cart);
  Future<void> clearActiveCart();

  Future<List<HoldTabModel>> getHeldTabs();
  Future<void> saveHeldTab(HoldTabModel tab);
  Future<HoldTabModel> getHeldTabById(String tabId);
  Future<void> deleteHeldTab(String tabId);

  Future<void> saveOrder(PosOrderModel order);
  Future<List<PosOrderModel>> getOrders();
}

class PosLocalDataSourceImpl implements PosLocalDataSource {
  static const String activeCartBoxName = 'empos_active_cart_box';
  static const String heldTabsBoxName = 'empos_held_tabs_box';
  static const String ordersBoxName = 'empos_orders_box';
  static const String activeCartKey = 'current_active_cart';

  Future<Box<dynamic>> _openBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return await Hive.openBox<dynamic>(boxName);
  }

  Future<Box<dynamic>> get _activeCartBox async => _openBox(activeCartBoxName);
  Future<Box<dynamic>> get _heldTabsBox async => _openBox(heldTabsBoxName);
  Future<Box<dynamic>> get _ordersBox async => _openBox(ordersBoxName);

  @override
  Future<CartModel> getActiveCart() async {
    try {
      final box = await _activeCartBox;
      final raw = box.get(activeCartKey);
      if (raw == null) {
        return const CartModel();
      }
      if (raw is String) {
        return CartModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
      return CartModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve active cart: $e');
    }
  }

  @override
  Future<void> saveActiveCart(CartModel cart) async {
    try {
      final box = await _activeCartBox;
      await box.put(activeCartKey, jsonEncode(cart.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to persist active cart: $e');
    }
  }

  @override
  Future<void> clearActiveCart() async {
    try {
      final box = await _activeCartBox;
      await box.delete(activeCartKey);
    } catch (e) {
      throw CacheException(message: 'Failed to clear active cart: $e');
    }
  }

  @override
  Future<List<HoldTabModel>> getHeldTabs() async {
    try {
      final box = await _heldTabsBox;
      final List<HoldTabModel> tabs = [];

      for (final v in box.values) {
        if (v != null) {
          if (v is String) {
            tabs.add(HoldTabModel.fromJson(jsonDecode(v) as Map<String, dynamic>));
          } else if (v is Map) {
            tabs.add(HoldTabModel.fromJson(Map<String, dynamic>.from(v)));
          }
        }
      }

      tabs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tabs;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve held tabs: $e');
    }
  }

  @override
  Future<void> saveHeldTab(HoldTabModel tab) async {
    try {
      final box = await _heldTabsBox;
      await box.put(tab.id, jsonEncode(tab.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save held tab: $e');
    }
  }

  @override
  Future<HoldTabModel> getHeldTabById(String tabId) async {
    try {
      final box = await _heldTabsBox;
      final raw = box.get(tabId);
      if (raw == null) {
        throw CacheException(message: 'Held tab with ID "$tabId" not found.');
      }
      if (raw is String) {
        return HoldTabModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      }
      return HoldTabModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Error fetching held tab $tabId: $e');
    }
  }

  @override
  Future<void> deleteHeldTab(String tabId) async {
    try {
      final box = await _heldTabsBox;
      await box.delete(tabId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete held tab: $e');
    }
  }

  @override
  Future<void> saveOrder(PosOrderModel order) async {
    try {
      final box = await _ordersBox;
      await box.put(order.id, jsonEncode(order.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save order: $e');
    }
  }

  @override
  Future<List<PosOrderModel>> getOrders() async {
    try {
      final box = await _ordersBox;
      final List<PosOrderModel> orders = [];

      for (final v in box.values) {
        if (v != null) {
          orders.add(PosOrderModel.fromRaw(v));
        }
      }

      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve orders: $e');
    }
  }
}
