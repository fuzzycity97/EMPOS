import 'package:equatable/equatable.dart';
import '../config/universal_capability_matrix.dart';

enum OmniItemType {
  pharmaceuticalDrug,
  clinicalProcedure,
  retailProduct,
  professionalService,
  labInvestigation,
  opticalHardware,
}

class OmniCartItem extends Equatable {
  final String itemId;
  final String departmentId;
  final String title;
  final double unitPrice;
  final double quantity;
  final OmniItemType itemType;
  final String? batchNumber;
  final DateTime? expiryDate;
  final String? performingProviderId;
  final double providerCommissionRate;
  final List<String> tiedConsumableProductIds;
  final Map<String, dynamic> clinicalOrServicePayload;

  const OmniCartItem({
    required this.itemId,
    required this.departmentId,
    required this.title,
    required this.unitPrice,
    required this.quantity,
    this.itemType = OmniItemType.retailProduct,
    this.batchNumber,
    this.expiryDate,
    this.performingProviderId,
    this.providerCommissionRate = 0.0,
    this.tiedConsumableProductIds = const [],
    this.clinicalOrServicePayload = const {},
  });

  double get totalPrice => unitPrice * quantity;
  double get commissionAmount => totalPrice * providerCommissionRate;

  @override
  List<Object?> get props => [
        itemId,
        departmentId,
        title,
        unitPrice,
        quantity,
        itemType,
        batchNumber,
        expiryDate,
        performingProviderId,
        providerCommissionRate,
        tiedConsumableProductIds,
        clinicalOrServicePayload,
      ];
}

class InventoryDeductionAction extends Equatable {
  final String targetProductId;
  final String targetWarehouseId;
  final double quantityToDeduct;
  final String? specificBatchNumber;
  final String reason;

  const InventoryDeductionAction({
    required this.targetProductId,
    required this.targetWarehouseId,
    required this.quantityToDeduct,
    this.specificBatchNumber,
    required this.reason,
  });

  @override
  List<Object?> get props => [
        targetProductId,
        targetWarehouseId,
        quantityToDeduct,
        specificBatchNumber,
        reason,
      ];
}

class OmniCartResolutionResult extends Equatable {
  final double grossTotal;
  final List<OmniCartItem> resolvedItems;
  final List<InventoryDeductionAction> inventoryDeductions;
  final Map<String, double> providerCommissions;
  final Map<String, double> departmentalRevenue;

  const OmniCartResolutionResult({
    required this.grossTotal,
    required this.resolvedItems,
    required this.inventoryDeductions,
    required this.providerCommissions,
    required this.departmentalRevenue,
  });

  @override
  List<Object?> get props => [
        grossTotal,
        resolvedItems,
        inventoryDeductions,
        providerCommissions,
        departmentalRevenue,
      ];
}

class OmniCartResolver {
  OmniCartResolver._();

  static OmniCartResolutionResult resolveTransaction({
    required List<OmniCartItem> items,
    required UniversalStoreProfile storeProfile,
  }) {
    double gross = 0.0;
    final deductions = <InventoryDeductionAction>[];
    final commissions = <String, double>{};
    final deptRevenue = <String, double>{};

    for (final item in items) {
      final lineTotal = item.totalPrice;
      gross += lineTotal;

      // 1. Departmental Revenue Breakdown
      deptRevenue[item.departmentId] = (deptRevenue[item.departmentId] ?? 0.0) + lineTotal;

      // 2. Provider Commission Routing
      if (item.performingProviderId != null && item.providerCommissionRate > 0) {
        final provId = item.performingProviderId!;
        commissions[provId] = (commissions[provId] ?? 0.0) + item.commissionAmount;
      }

      // 3. Dynamic Universal Inventory Routing
      switch (item.itemType) {
        case OmniItemType.pharmaceuticalDrug:
          // FEFO batch deduction
          deductions.add(
            InventoryDeductionAction(
              targetProductId: item.itemId,
              targetWarehouseId: 'warehouse_pharmacy',
              quantityToDeduct: item.quantity,
              specificBatchNumber: item.batchNumber,
              reason: 'FEFO Dispense: ${item.title}',
            ),
          );
          break;

        case OmniItemType.clinicalProcedure:
          // Decrement tied consumables
          for (final consumableId in item.tiedConsumableProductIds) {
            deductions.add(
              InventoryDeductionAction(
                targetProductId: consumableId,
                targetWarehouseId: 'warehouse_clinic_consumables',
                quantityToDeduct: item.quantity,
                reason: 'Clinical Procedure Consumable: ${item.title}',
              ),
            );
          }
          break;

        case OmniItemType.retailProduct:
        case OmniItemType.opticalHardware:
          deductions.add(
            InventoryDeductionAction(
              targetProductId: item.itemId,
              targetWarehouseId: 'warehouse_retail_main',
              quantityToDeduct: item.quantity,
              reason: 'POS Sale: ${item.title}',
            ),
          );
          break;

        case OmniItemType.professionalService:
        case OmniItemType.labInvestigation:
          // Pure service or laboratory test with zero direct retail stock decrement
          break;
      }
    }

    return OmniCartResolutionResult(
      grossTotal: gross,
      resolvedItems: items,
      inventoryDeductions: deductions,
      providerCommissions: commissions,
      departmentalRevenue: deptRevenue,
    );
  }
}
