import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../models/customer_ledger_entry_model.dart';
import '../models/customer_model.dart';

abstract class CustomerLocalDataSource {
  Future<List<CustomerModel>> getCustomers();
  Future<CustomerModel?> getCustomerById(String customerId);
  Future<void> saveCustomer(CustomerModel customer);
  Future<void> deleteCustomer(String customerId);

  Future<List<CustomerLedgerEntryModel>> getLedgerEntries(String customerId);
  Future<void> saveLedgerEntry(CustomerLedgerEntryModel entry);
}

class CustomerLocalDataSourceImpl implements CustomerLocalDataSource {
  static const String customersBoxName = 'empos_customers_box';
  static const String ledgerBoxName = 'empos_customer_ledger_box';

  Future<Box<dynamic>> _openBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return await Hive.openBox<dynamic>(boxName);
  }

  Future<Box<dynamic>> get _customersBox async => _openBox(customersBoxName);
  Future<Box<dynamic>> get _ledgerBox async => _openBox(ledgerBoxName);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    try {
      final box = await _customersBox;
      final List<CustomerModel> customers = [];

      for (final raw in box.values) {
        if (raw != null) {
          customers.add(CustomerModel.fromRaw(raw));
        }
      }

      customers.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return customers;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve customers: $e');
    }
  }

  @override
  Future<CustomerModel?> getCustomerById(String customerId) async {
    try {
      final box = await _customersBox;
      final raw = box.get(customerId);
      if (raw != null) {
        return CustomerModel.fromRaw(raw);
      }

      // Robust fallback: search across all records by ID or phone
      final cleanQuery = customerId.trim().toLowerCase();
      for (final item in box.values) {
        if (item != null) {
          final cust = CustomerModel.fromRaw(item);
          if (cust.id.toLowerCase() == cleanQuery || cust.phone.trim().toLowerCase() == cleanQuery) {
            return cust;
          }
        }
      }
      return null;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve customer $customerId: $e');
    }
  }

  @override
  Future<void> saveCustomer(CustomerModel customer) async {
    try {
      final box = await _customersBox;
      await box.put(customer.id, jsonEncode(customer.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save customer: $e');
    }
  }

  @override
  Future<void> deleteCustomer(String customerId) async {
    try {
      final box = await _customersBox;
      await box.delete(customerId);
    } catch (e) {
      throw CacheException(message: 'Failed to delete customer: $e');
    }
  }

  @override
  Future<List<CustomerLedgerEntryModel>> getLedgerEntries(String customerId) async {
    try {
      final box = await _ledgerBox;
      final List<CustomerLedgerEntryModel> entries = [];

      // Find customer to obtain their canonical ID and phone for cross-referencing
      final cust = await getCustomerById(customerId);
      final canonicalId = cust?.id ?? customerId;
      final phone = cust?.phone.trim();

      for (final raw in box.values) {
        if (raw != null) {
          final entry = CustomerLedgerEntryModel.fromRaw(raw);
          final entryCustId = entry.customerId.trim();
          if (entryCustId == customerId ||
              entryCustId == canonicalId ||
              (phone != null && phone.isNotEmpty && entryCustId == phone)) {
            entries.add(entry);
          }
        }
      }

      entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return entries;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve ledger entries for $customerId: $e');
    }
  }

  @override
  Future<void> saveLedgerEntry(CustomerLedgerEntryModel entry) async {
    try {
      final box = await _ledgerBox;
      await box.put(entry.id, jsonEncode(entry.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save customer ledger entry: $e');
    }
  }
}
