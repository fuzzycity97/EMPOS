import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/atomic_business_components.dart';
import 'package:empos/core/config/facility_blueprint.dart';
import 'package:empos/core/config/universal_capability_matrix.dart';
import 'package:empos/core/engine/omni_cart_resolver.dart';
import 'package:empos/core/engine/omni_fulfillment_resolver.dart';
import 'package:empos/core/navigation/dynamic_station_router.dart';
import 'package:empos/features/auth/domain/entities/user_role.dart';
import 'package:empos/features/reports/domain/entities/clinical_report_templates.dart';

void main() {
  group('End-to-End Dynamic Hybrid Facility Integration Tests', () {
    late FacilityBlueprint complexFacility;
    late UniversalStoreProfile storeProfile;

    setUp(() {
      complexFacility = const FacilityBlueprint(
        facilityId: 'fac_hybrid_polycenter',
        facilityName: 'Omni Healthcare & Lifestyle Polycenter',
        departments: [
          DepartmentNode(
            departmentId: 'dept_dental',
            nameEn: 'Dental & Maxillofacial Wing',
            nameAr: 'قسم جراحة الفم والأسنان',
            capabilities: {
              AtomicCapability.clinicalEncounter3dCanvas,
              AtomicCapability.specializedClinicalCharting,
              AtomicCapability.consumableAutoDepletion,
              AtomicCapability.multiProviderCommission,
            },
          ),
          DepartmentNode(
            departmentId: 'dept_pharmacy',
            nameEn: 'In-House Clinical Pharmacy',
            nameAr: 'صيدلية المركز الداخلية',
            capabilities: {
              AtomicCapability.fefoBatchInventory,
              AtomicCapability.standardRetailBarcoding,
            },
          ),
          DepartmentNode(
            departmentId: 'dept_optical',
            nameEn: 'Optical Boutique & Refraction',
            nameAr: 'بوتيك البصريات وفحص النظر',
            capabilities: {
              AtomicCapability.standardRetailBarcoding,
              AtomicCapability.specializedClinicalCharting,
            },
          ),
          DepartmentNode(
            departmentId: 'dept_cafe',
            nameEn: 'Hospitality Lounge & Cafe',
            nameAr: 'كافيه واستراحة الزوار',
            capabilities: {
              AtomicCapability.tableFloorMapManagement,
              AtomicCapability.standardRetailBarcoding,
            },
          ),
        ],
        sharedGlobalCapabilities: {
          AtomicCapability.unifiedCrossDepartmentCart,
          AtomicCapability.unifiedQueueDispatchHub,
        },
      );

      storeProfile = UniversalStoreProfile(
        organizationName: 'Omni Polycenter',
        enabledCapabilities: {
          BusinessCapability.medicalConsultation,
          BusinessCapability.anatomical3dViewer,
          BusinessCapability.pharmacyDispensingFefo,
          BusinessCapability.retailBarcodeScanning,
          BusinessCapability.unifiedOmniCartBilling,
        },
        departments: const [
          DepartmentConfig(
            id: 'dept_dental',
            nameEn: 'Dental',
            nameAr: 'الأسنان',
            capabilities: {BusinessCapability.medicalConsultation},
          ),
          DepartmentConfig(
            id: 'dept_pharmacy',
            nameEn: 'Pharmacy',
            nameAr: 'الصيدلية',
            capabilities: {BusinessCapability.pharmacyDispensingFefo},
          ),
        ],
      );
    });

    test('1. Facility Blueprint capability introspection behaves correctly', () {
      expect(complexFacility.supports(AtomicCapability.clinicalEncounter3dCanvas), isTrue);
      expect(complexFacility.supports(AtomicCapability.fefoBatchInventory), isTrue);
      expect(complexFacility.supports(AtomicCapability.tableFloorMapManagement), isTrue);
      expect(complexFacility.supports(AtomicCapability.unifiedCrossDepartmentCart), isTrue);
      expect(complexFacility.supports(AtomicCapability.multiDayStayBoarding), isFalse);
    });

    test('2. Dynamic Station Router resolves routes and RBAC guards dynamically', () {
      // Doctor inspecting Dental wing
      final doctorRoutes = DynamicStationRouter.resolveRoutes(
        blueprint: complexFacility,
        activeDepartmentId: 'dept_dental',
        userRole: UserRole.doctor,
      );
      expect(doctorRoutes.any((r) => r.destination == StationDestination.clinicalConsultation), isTrue);

      // Receptionist at Dental wing -> sees Reception Queue and POS
      final receptionRoutes = DynamicStationRouter.resolveRoutes(
        blueprint: complexFacility,
        activeDepartmentId: 'dept_dental',
        userRole: UserRole.receptionist,
      );
      expect(receptionRoutes.any((r) => r.destination == StationDestination.universalReceptionQueue), isTrue);
      expect(receptionRoutes.any((r) => r.destination == StationDestination.retailPosCheckout), isTrue);

      // Cashier inspecting Pharmacy wing
      final pharmacyRoutes = DynamicStationRouter.resolveRoutes(
        blueprint: complexFacility,
        activeDepartmentId: 'dept_pharmacy',
        userRole: UserRole.cashier,
      );
      expect(pharmacyRoutes.any((r) => r.destination == StationDestination.pharmacyDispensing), isTrue);
    });

    test('3. Omni-Cart Resolver resolves cross-department items, commissions, and revenue', () {
      final cartItems = [
        const OmniCartItem(
          itemId: 'proc_root_canal',
          departmentId: 'dept_dental',
          title: 'Molar Root Canal Treatment',
          unitPrice: 1500.0,
          quantity: 1,
          itemType: OmniItemType.clinicalProcedure,
          performingProviderId: 'dr_sarah_dentist',
          providerCommissionRate: 0.20,
          tiedConsumableProductIds: ['mat_endo_file_kit', 'mat_gutta_percha'],
        ),
        const OmniCartItem(
          itemId: 'drug_amox_500',
          departmentId: 'dept_pharmacy',
          title: 'Amoxicillin 500mg Capsules',
          unitPrice: 85.0,
          quantity: 2,
          itemType: OmniItemType.pharmaceuticalDrug,
          batchNumber: 'BATCH-2026-AUG',
        ),
        const OmniCartItem(
          itemId: 'frame_rayban_aviator',
          departmentId: 'dept_optical',
          title: 'Designer Optical Frame',
          unitPrice: 2200.0,
          quantity: 1,
          itemType: OmniItemType.opticalHardware,
        ),
        const OmniCartItem(
          itemId: 'cafe_espresso_double',
          departmentId: 'dept_cafe',
          title: 'Double Espresso Roast',
          unitPrice: 45.0,
          quantity: 1,
          itemType: OmniItemType.retailProduct,
        ),
      ];

      final result = OmniCartResolver.resolveTransaction(
        items: cartItems,
        storeProfile: storeProfile,
      );

      // Total: 1500 + (85*2) + 2200 + 45 = 1500 + 170 + 2200 + 45 = 3915.0
      expect(result.grossTotal, equals(3915.0));

      // Provider commission: 1500 * 0.20 = 300.0 for dr_sarah_dentist
      expect(result.providerCommissions['dr_sarah_dentist'], equals(300.0));

      // Department revenue breakdown
      expect(result.departmentalRevenue['dept_dental'], equals(1500.0));
      expect(result.departmentalRevenue['dept_pharmacy'], equals(170.0));
      expect(result.departmentalRevenue['dept_optical'], equals(2200.0));
      expect(result.departmentalRevenue['dept_cafe'], equals(45.0));

      // Inventory deductions: 2 consumables for root canal + 1 pharmacy FEFO batch + 1 optical frame + 1 espresso = 5 actions
      expect(result.inventoryDeductions.length, equals(5));
      expect(result.inventoryDeductions.any((d) => d.targetWarehouseId == 'warehouse_pharmacy'), isTrue);
      expect(result.inventoryDeductions.any((d) => d.targetWarehouseId == 'warehouse_clinic_consumables'), isTrue);
      expect(result.inventoryDeductions.any((d) => d.targetWarehouseId == 'warehouse_retail_main'), isTrue);
    });

    test('4. OmniFulfillmentResolver executes granular capability fulfillment actions', () async {
      final dentalDept = complexFacility.getDepartment('dept_dental')!;
      final pharmacyDept = complexFacility.getDepartment('dept_pharmacy')!;

      // Dental fulfillment
      final dentalLog = await OmniFulfillmentResolver.processItemFulfillment(
        itemId: 'proc_implant_crown',
        department: dentalDept,
        quantity: 1,
        metadata: {
          'providerId': 'dr_alex_dentist',
          'unitPrice': 3000.0,
          'commissionRate': 0.25,
        },
      );
      final dentalActions = dentalLog['actions'] as List<String>;
      expect(dentalActions.any((a) => a.contains('PROCEDURE_TIED_CONSUMABLES_DEPLETED')), isTrue);
      expect(dentalActions.any((a) => a.contains('PROVIDER_COMMISSION_RECORDED')), isTrue);
      expect(dentalLog['commissionEarned'], equals(750.0));

      // Pharmacy fulfillment
      final pharmacyLog = await OmniFulfillmentResolver.processItemFulfillment(
        itemId: 'drug_cipro_750',
        department: pharmacyDept,
        quantity: 1,
        metadata: {'batchId': 'BATCH-CIP-2026'},
      );
      final pharmacyActions = pharmacyLog['actions'] as List<String>;
      expect(pharmacyActions.any((a) => a.contains('FEFO_BATCH_DEDUCTED: BATCH-CIP-2026')), isTrue);
    });

    test('5. Clinical Report Entry data structures serialize and preserve clinical data', () {
      final opticalReport = ClinicalReportEntry(
        patientId: 'pat_1092',
        patientName: 'Ahmed Mansoor',
        doctorId: 'dr_tariq_optometrist',
        doctorName: 'Dr. Tariq Optical',
        encounterDate: DateTime(2026, 9, 1, 14, 30),
        reportType: ReportDataType.opticalPrescription,
        structuredData: const {
          'od_sph': '-1.50',
          'od_cyl': '-0.50',
          'od_axis': '90°',
          'os_sph': '-1.75',
          'os_cyl': '-0.25',
          'os_axis': '85°',
          'pd': '64mm',
        },
      );

      expect(opticalReport.reportType, equals(ReportDataType.opticalPrescription));
      expect(opticalReport.structuredData['od_sph'], equals('-1.50'));
      expect(opticalReport.structuredData['pd'], equals('64mm'));
    });
  });
}
