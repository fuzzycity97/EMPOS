import '../config/atomic_business_components.dart';
import '../config/facility_blueprint.dart';

class OmniFulfillmentResolver {
  OmniFulfillmentResolver._();

  /// Routes cart item settlement dynamically across the required backend engine
  static Future<Map<String, dynamic>> processItemFulfillment({
    required String itemId,
    required DepartmentNode department,
    required double quantity,
    required Map<String, dynamic> metadata,
  }) async {
    final fulfillmentLog = <String, dynamic>{
      'itemId': itemId,
      'departmentId': department.departmentId,
      'quantity': quantity,
      'timestamp': DateTime.now().toIso8601String(),
      'actions': <String>[],
    };

    final actions = fulfillmentLog['actions'] as List<String>;

    // 1. FEFO Batch Dispensing (Pharmacy / Medical supplies)
    if (department.has(AtomicCapability.fefoBatchInventory)) {
      final batchId = metadata['batchId']?.toString() ?? 'AUTO_FEFO_NEAREST_EXPIRY';
      actions.add('FEFO_BATCH_DEDUCTED: $batchId (Qty: $quantity)');
    }
    // 2. Standard Retail Barcode Inventory (Supermarkets / Optical frames / Pet shops)
    else if (department.has(AtomicCapability.standardRetailBarcoding)) {
      actions.add('STANDARD_SHELF_STOCK_DECREMENTED: (Qty: $quantity)');
    }

    // 3. Clinical Consumables Depletion (Dental implants, surgical kits)
    if (department.has(AtomicCapability.consumableAutoDepletion)) {
      actions.add('PROCEDURE_TIED_CONSUMABLES_DEPLETED: $itemId');
    }

    // 4. Session Punch-Card Depletion (Physio, Gym, Spa)
    if (department.has(AtomicCapability.multiSessionPackageCredit)) {
      final customerId = metadata['customerId']?.toString() ?? 'UNKNOWN_CUSTOMER';
      actions.add('CUSTOMER_PUNCH_CARD_DEBITED: $customerId (Item: $itemId)');
    }

    // 5. Multi-Provider Commission Split
    if (department.has(AtomicCapability.multiProviderCommission)) {
      final providerId = metadata['providerId']?.toString() ?? 'ATTENDING_PROVIDER';
      final unitPrice = (metadata['unitPrice'] as num?)?.toDouble() ?? 0.0;
      final rate = (metadata['commissionRate'] as num?)?.toDouble() ?? 0.15;
      final commission = unitPrice * quantity * rate;
      actions.add('PROVIDER_COMMISSION_RECORDED: $providerId ($commission EGP)');
      fulfillmentLog['commissionEarned'] = commission;
    }

    return fulfillmentLog;
  }
}
