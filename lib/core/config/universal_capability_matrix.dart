import 'package:equatable/equatable.dart';

enum BusinessCapability {
  // Clinical & Specialized Care
  medicalConsultation, // Doctor station, vitals, clinical history
  anatomical3dViewer, // Interactive 3D anatomical vector canvases
  specializedDiagnostics, // Optical Rx, Perio, ROM, Audiometry, Antenatal
  diagnosticLightbox, // DICOM/Radiology image analyzer (X-Ray, MRI, CT)
  laboratoryInvestigation, // Structured lab panels & bloodwork tracking

  // Fulfillment & Operations
  pharmacyDispensingFefo, // Prescription batching, expiry FEFO management
  retailBarcodeScanning, // Barcode scanning, inventory shelf levels
  hospitalityTableDineIn, // Table management, KDS, split bills, modifiers
  appointmentBookingSlots, // Multi-provider scheduling & conflict engine
  serviceSessionPackages, // Gym, spa, physiotherapy multi-session packages

  // Checkout & Shared Services
  multiProviderRoutingQueue, // Unified reception/kiosk queue dispatch
  unifiedOmniCartBilling, // Cross-department single-invoice checkout
  sharedCrossInventory, // Multi-warehouse cross-deductions
  loyaltyMembershipEngine, // Patient/Customer loyalty, store credit, debt ledger
}

enum CrossBillingPolicy {
  singleConsolidatedInvoice,
  departmentalSplitInvoices,
  itemizedReceiptPerProvider,
}

enum InventoryDeductionMatrix {
  fefoExpiryFirst,
  primaryWarehouseFirst,
  departmentalLocalBatch,
}

class DepartmentConfig extends Equatable {
  final String id;
  final String nameEn;
  final String nameAr;
  final Set<BusinessCapability> capabilities;
  final String? defaultWarehouseId;

  const DepartmentConfig({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.capabilities,
    this.defaultWarehouseId,
  });

  @override
  List<Object?> get props => [id, nameEn, nameAr, capabilities, defaultWarehouseId];
}

class UniversalStoreProfile extends Equatable {
  final String organizationName;
  final Set<BusinessCapability> enabledCapabilities;
  final List<DepartmentConfig> departments;
  final CrossBillingPolicy billingPolicy;
  final InventoryDeductionMatrix inventoryMatrix;

  const UniversalStoreProfile({
    required this.organizationName,
    required this.enabledCapabilities,
    required this.departments,
    this.billingPolicy = CrossBillingPolicy.singleConsolidatedInvoice,
    this.inventoryMatrix = InventoryDeductionMatrix.fefoExpiryFirst,
  });

  bool has(BusinessCapability capability) => enabledCapabilities.contains(capability);

  UniversalStoreProfile copyWith({
    String? organizationName,
    Set<BusinessCapability>? enabledCapabilities,
    List<DepartmentConfig>? departments,
    CrossBillingPolicy? billingPolicy,
    InventoryDeductionMatrix? inventoryMatrix,
  }) {
    return UniversalStoreProfile(
      organizationName: organizationName ?? this.organizationName,
      enabledCapabilities: enabledCapabilities ?? this.enabledCapabilities,
      departments: departments ?? this.departments,
      billingPolicy: billingPolicy ?? this.billingPolicy,
      inventoryMatrix: inventoryMatrix ?? this.inventoryMatrix,
    );
  }

  @override
  List<Object?> get props => [
        organizationName,
        enabledCapabilities,
        departments,
        billingPolicy,
        inventoryMatrix,
      ];
}
