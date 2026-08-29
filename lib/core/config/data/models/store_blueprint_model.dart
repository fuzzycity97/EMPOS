import 'dart:convert';
import '../../domain/entities/industry_type.dart';
import '../../domain/entities/store_blueprint.dart';

class StoreBlueprintModel extends StoreBlueprint {
  const StoreBlueprintModel({
    required super.storeName,
    super.storeBranch = 'Main Branch',
    super.industryType = IndustryType.retail,
    super.vertical = IndustryVertical.retail,
    super.specificIndustry = SpecificIndustry.cashierPos,
    super.currency = 'EGP',
    super.taxRate = 14.0,
    super.taxMode = TaxMode.taxExclusive,
    super.serverSyncUrl,
    super.themeColorHex = '#6366F1',
    super.secondaryColorHex = '#10B981',
    super.isDarkMode = true,
    super.toggles = const {},
    super.createdAt,
  });

  factory StoreBlueprintModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse StoreBlueprintModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return StoreBlueprintModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return StoreBlueprintModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for StoreBlueprintModel: ${raw.runtimeType}');
  }

  factory StoreBlueprintModel.fromJson(Map<String, dynamic> json) {
    // 1. Toggles resolution (handles direct Map or legacy hardwareToggles/softwareToggles Lists)
    final Map<String, bool> parsedToggles = {};

    if (json['toggles'] is Map) {
      final rawMap = json['toggles'] as Map;
      for (final entry in rawMap.entries) {
        parsedToggles[entry.key.toString()] = entry.value == true || entry.value == 'true';
      }
    }

    if (json['softwareToggles'] is List) {
      for (final item in json['softwareToggles'] as List) {
        if (item is Map && item['key'] != null) {
          final key = item['key'].toString();
          final val = item['enabled'] ?? item['default'] ?? true;
          parsedToggles[key] = val == true || val == 'true';
        }
      }
    }

    if (json['hardwareToggles'] is List) {
      for (final item in json['hardwareToggles'] as List) {
        if (item is Map && item['key'] != null) {
          final key = item['key'].toString();
          final val = item['enabled'] ?? item['default'] ?? true;
          parsedToggles[key] = val == true || val == 'true';
        }
      }
    }

    // 2. Industry resolution
    final specificIndustry = SpecificIndustry.fromString(
      json['specificIndustry']?.toString() ??
          json['id']?.toString() ??
          json['industryType']?.toString() ??
          json['industry']?.toString(),
    );

    final vertical = IndustryVertical.fromString(
      json['vertical']?.toString() ??
          json['category']?.toString() ??
          json['industry']?.toString() ??
          specificIndustry.vertical.id,
    );

    final industry = IndustryType.fromString(
      json['industryType']?.toString() ?? specificIndustry.id,
    );

    // 3. Metadata extraction
    final name = json['storeName']?.toString() ?? json['name']?.toString() ?? 'OmniStore';
    final branch = json['storeBranch']?.toString() ?? 'Main Branch';
    final currency = json['currency']?.toString() ?? json['currencySymbol']?.toString() ?? 'EGP';
    final taxRate = (json['taxRate'] as num?)?.toDouble() ?? 14.0;
    final taxMode = TaxMode.fromString(
      json['taxMode']?.toString() ?? json['taxCalculationMode']?.toString(),
    );
    final serverUrl = json['serverSyncUrl']?.toString();
    final themeHex = json['themeColorHex']?.toString() ?? json['primaryColor']?.toString() ?? '#6366F1';
    final secHex = json['secondaryColorHex']?.toString() ?? json['secondaryColor']?.toString() ?? '#10B981';
    final isDark = json['isDarkMode'] as bool? ?? true;
    final created = DateTime.tryParse(json['createdAt']?.toString() ?? '');

    return StoreBlueprintModel(
      storeName: name,
      storeBranch: branch,
      industryType: industry,
      vertical: vertical,
      specificIndustry: specificIndustry,
      currency: currency,
      taxRate: taxRate,
      taxMode: taxMode,
      serverSyncUrl: serverUrl,
      themeColorHex: themeHex,
      secondaryColorHex: secHex,
      isDarkMode: isDark,
      toggles: parsedToggles,
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'storeName': storeName,
      'storeBranch': storeBranch,
      'industryType': industryType.name,
      'vertical': vertical.id,
      'specificIndustry': specificIndustry.id,
      'currency': currency,
      'taxRate': taxRate,
      'taxMode': taxMode.name,
      'serverSyncUrl': serverSyncUrl,
      'themeColorHex': themeColorHex,
      'secondaryColorHex': secondaryColorHex,
      'isDarkMode': isDarkMode,
      'toggles': toggles,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory StoreBlueprintModel.fromEntity(StoreBlueprint entity) {
    return StoreBlueprintModel(
      storeName: entity.storeName,
      storeBranch: entity.storeBranch,
      industryType: entity.industryType,
      vertical: entity.vertical,
      specificIndustry: entity.specificIndustry,
      currency: entity.currency,
      taxRate: entity.taxRate,
      taxMode: entity.taxMode,
      serverSyncUrl: entity.serverSyncUrl,
      themeColorHex: entity.themeColorHex,
      secondaryColorHex: entity.secondaryColorHex,
      isDarkMode: entity.isDarkMode,
      toggles: entity.toggles,
      createdAt: entity.createdAt,
    );
  }

  /// Turnkey Factory Presets across major verticals:

  /// 1. Retail & Cashier POS
  factory StoreBlueprintModel.defaultRetailBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Retail Store',
      storeBranch: 'Main Branch 01',
      industryType: IndustryType.retail,
      vertical: IndustryVertical.retail,
      specificIndustry: SpecificIndustry.cashierPos,
      currency: 'EGP',
      taxRate: 14.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#6366F1',
      secondaryColorHex: '#10B981',
      isDarkMode: true,
      toggles: const {
        'sw.retail_pos': true,
        'sw.orders_returns': true,
        'sw.inventory_catalog': true,
        'sw.customers_crm': true,
        'sw.boss_erp': true,
        'sw.clinic_reception': false,
        'sw.clinic_doctor_station': false,
        'sw.service_pipeline': false,
        'sw.bookings_calendar': false,
        'hw.retail_barcode_scanner': true,
        'hw.receipt_printer_80mm': true,
        'hw.cash_drawer_kick': true,
        'sw.customer_debt_tracking': true,
        'sw.discounts_and_promotions': true,
        'sw.expense_drawer_deductions': true,
        'sw.partner_equity_profit_sharing': true,
        'sw.shift_drawer_reconciliation': true,
        'sw.quick_pay_cash_tender': true,
        'sw.auto_stock_restock_on_refund': true,
        'sw.compliance_audit_logs': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 2. Dental Clinic & Orthodontics
  factory StoreBlueprintModel.defaultDentalBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Dental & Orthodontics Center',
      storeBranch: 'Main Clinic',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.dentalClinic,
      currency: 'EGP',
      taxRate: 0.0, // Medical exempt
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#0284C7',
      secondaryColorHex: '#06B6D4',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.service_pipeline': false,
        'hw.clinic_receipt_printer': true,
        'hw.dental_intraoral_camera': true,
        'hw.dental_xray_sensor': true,
        'hw.dental_chairside_display': true,
        'sw.dental_tooth_chart_editor': true,
        'sw.dental_staged_treatment_plans': true,
        'sw.dental_multivisit_tracking': true,
        'sw.dental_insurance_preauth': true,
        'sw.dental_lab_work_orders': true,
        'sw.dental_perio_charting': true,
        'sw.dental_sedation_consent_gate': true,
        'sw.dental_material_usage_log': true,
        'sw.dental_compliance_record': true,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_wait_time_estimation': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3. General Medical Clinic
  factory StoreBlueprintModel.defaultClinicBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Specialist Medical Clinic',
      storeBranch: 'Medical Tower Suite 4',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.clinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#0284C7',
      secondaryColorHex: '#10B981',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.service_pipeline': false,
        'hw.clinic_receipt_printer': true,
        'hw.clinic_camera_gate': true,
        'hw.clinic_barcode_scanner': true,
        'hw.dicom_xray_sensor': true,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_recall_reminders': true,
        'sw.clinic_multi_doctor_filter': true,
        'sw.clinic_wait_time_estimation': true,
        'sw.clinic_no_show_tracking': true,
        'sw.clinic_partial_payments': true,
        'sw.clinic_insurance_discounts': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'sw.clinic_expiry_tracking': true,
        'sw.clinic_compliance_audit_log': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 4. Restaurant & Dine-In
  factory StoreBlueprintModel.defaultRestaurantBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Gourmet Restaurant',
      storeBranch: 'Downtown Location',
      industryType: IndustryType.foodAndBeverage,
      vertical: IndustryVertical.foodBeverage,
      specificIndustry: SpecificIndustry.restaurantDinein,
      currency: 'EGP',
      taxRate: 14.0,
      taxMode: TaxMode.taxInclusive,
      themeColorHex: '#F59E0B',
      secondaryColorHex: '#EF4444',
      isDarkMode: true,
      toggles: const {
        'sw.retail_pos': true,
        'sw.orders_returns': true,
        'sw.inventory_catalog': true,
        'sw.customers_crm': true,
        'sw.boss_erp': true,
        'sw.bookings_calendar': true,
        'sw.clinic_reception': false,
        'sw.clinic_doctor_station': false,
        'sw.service_pipeline': false,
        'hw.receipt_printer_80mm': true,
        'hw.cash_drawer_kick': true,
        'sw.table_management': true,
        'sw.kds_kitchen_display': true,
        'sw.split_bill_by_seat': true,
        'sw.course_firing_sequence': true,
        'sw.food_safety_temperature_log': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 5. Supermarket & Grocery
  factory StoreBlueprintModel.defaultSupermarketBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Hypermarket',
      storeBranch: 'Flagship Store',
      industryType: IndustryType.supermarket,
      vertical: IndustryVertical.retail,
      specificIndustry: SpecificIndustry.grocerySupermarket,
      currency: 'EGP',
      taxRate: 14.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#10B981',
      secondaryColorHex: '#06B6D4',
      isDarkMode: true,
      toggles: const {
        'sw.retail_pos': true,
        'sw.orders_returns': true,
        'sw.inventory_catalog': true,
        'sw.customers_crm': true,
        'sw.boss_erp': true,
        'sw.clinic_reception': false,
        'sw.service_pipeline': false,
        'sw.bookings_calendar': false,
        'hw.retail_barcode_scanner': true,
        'hw.receipt_printer_80mm': true,
        'hw.cash_drawer_kick': true,
        'hw.grocery_scale': true,
        'hw.customer_display': true,
        'sw.grocery_weight_pricing': true,
        'sw.expiry_tracking': true,
        'sw.batch_numbers': true,
        'sw.loyalty_points': true,
        'sw.compliance_audit_logs': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 6. Pharmacy & Drugs
  factory StoreBlueprintModel.defaultPharmacyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Care Pharmacy',
      storeBranch: 'Main Street 10',
      industryType: IndustryType.pharmacy,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.pharmacy,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#06B6D4',
      secondaryColorHex: '#10B981',
      isDarkMode: true,
      toggles: const {
        'sw.retail_pos': true,
        'sw.orders_returns': true,
        'sw.inventory_catalog': true,
        'sw.customers_crm': true,
        'sw.boss_erp': true,
        'sw.clinic_reception': false,
        'sw.service_pipeline': false,
        'sw.bookings_calendar': false,
        'hw.retail_barcode_scanner': true,
        'hw.receipt_printer_80mm': true,
        'hw.cash_drawer_kick': true,
        'hw.optical_prescription_scanner': true,
        'sw.prescription_scanning': true,
        'sw.box_and_strip_selling': true,
        'sw.expiry_tracking': true,
        'sw.batch_numbers': true,
        'sw.compliance_audit_logs': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 7. Hotel & Guesthouse
  factory StoreBlueprintModel.defaultHotelBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Boutique Hotel & Suites',
      storeBranch: 'Resort 01',
      industryType: IndustryType.hospitality,
      vertical: IndustryVertical.eventsHospitality,
      specificIndustry: SpecificIndustry.hotelGuesthouse,
      currency: 'EGP',
      taxRate: 14.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#8B5CF6',
      secondaryColorHex: '#F59E0B',
      isDarkMode: true,
      toggles: const {
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.service_pipeline': false,
        'sw.clinic_reception': false,
        'hw.receipt_printer_80mm': true,
        'hw.hotel_rfid_keycard_encoder': true,
        'hw.hotel_passport_document_scanner': true,
        'sw.hotel_room_booking_calendar': true,
        'sw.hotel_night_audit_reconciliation': true,
        'sw.hotel_housekeeping_room_status_grid': true,
        'sw.hotel_minibar_roomservice_folio_post': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 8. Auto Repair & Garage
  factory StoreBlueprintModel.defaultAutoRepairBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Auto Service & Garage',
      storeBranch: 'Bay Area Service Center',
      industryType: IndustryType.automotive,
      vertical: IndustryVertical.automotive,
      specificIndustry: SpecificIndustry.autoRepairGarage,
      currency: 'EGP',
      taxRate: 14.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#EA580C',
      secondaryColorHex: '#64748B',
      isDarkMode: true,
      toggles: const {
        'sw.service_pipeline': true,
        'sw.inventory_catalog': true,
        'sw.customers_crm': true,
        'sw.boss_erp': true,
        'sw.bookings_calendar': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_reception': false,
        'hw.receipt_printer_80mm': true,
        'hw.auto_obd2_diagnostic_scanner': true,
        'sw.auto_repair_vin_lookup': true,
        'sw.auto_workorder_labor_parts_split': true,
        'sw.auto_service_bay_assignment_queue': true,
        'sw.auto_epa_oil_disposal_compliance_log': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 9. Real Estate Agency & Brokerage
  factory StoreBlueprintModel.defaultRealEstateBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Realty & Brokerage',
      storeBranch: 'Headquarters',
      industryType: IndustryType.realEstate,
      vertical: IndustryVertical.professionalServices,
      specificIndustry: SpecificIndustry.realEstateAgency,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#0F766E',
      secondaryColorHex: '#F59E0B',
      isDarkMode: true,
      toggles: const {
        'sw.service_pipeline': true,
        'sw.customers_crm': true,
        'sw.bookings_calendar': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.clinic_reception': false,
        'hw.realty_receipt_printer': true,
        'sw.realty_listing_pipeline_active_pending': true,
        'sw.realty_property_showing_scheduler': true,
        'sw.realty_multiple_offer_comparison_sheet': true,
        'sw.realty_commission_split_calculator': true,
        'sw.realty_fair_housing_compliance_log': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 10. Beauty Salon & Spa
  factory StoreBlueprintModel.defaultSalonBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Luxury Salon & Spa',
      storeBranch: 'Main Salon',
      industryType: IndustryType.services,
      vertical: IndustryVertical.beautyPersonalCare,
      specificIndustry: SpecificIndustry.hairSalonBarbershop,
      currency: 'EGP',
      taxRate: 14.0,
      taxMode: TaxMode.taxInclusive,
      themeColorHex: '#EC4899',
      secondaryColorHex: '#8B5CF6',
      isDarkMode: true,
      toggles: const {
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.service_pipeline': false,
        'sw.clinic_reception': false,
        'hw.receipt_printer_80mm': true,
        'sw.salon_chair_appointment_scheduler': true,
        'sw.salon_stylist_commission_split': true,
        'sw.salon_chemical_color_formula_history': true,
        'sw.loyalty_points': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 11. Gym & Fitness Center
  factory StoreBlueprintModel.defaultGymBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Athletic Gym & Fitness',
      storeBranch: 'Downtown Club',
      industryType: IndustryType.fitness,
      vertical: IndustryVertical.fitnessSports,
      specificIndustry: SpecificIndustry.gymFitnessCenter,
      currency: 'EGP',
      taxRate: 14.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#EF4444',
      secondaryColorHex: '#F59E0B',
      isDarkMode: true,
      toggles: const {
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.service_pipeline': false,
        'sw.clinic_reception': false,
        'hw.receipt_printer_80mm': true,
        'hw.gym_turnstile_rfid_relay': true,
        'sw.gym_membership_recurring_billing': true,
        'sw.gym_rfid_turnstile_access_gate': true,
        'sw.gym_guest_pass_waiver_tracking': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }
}
