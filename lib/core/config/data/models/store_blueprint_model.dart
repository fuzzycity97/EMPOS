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
  factory StoreBlueprintModel.defaultGeneralClinicBlueprint() => StoreBlueprintModel.defaultClinicBlueprint();
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
        'sw.dental_tooth_chart_editor': true,
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

  /// 3a. Ophthalmology & Eye Care Center
  factory StoreBlueprintModel.defaultOphthalmologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Eye Clinic & Optometry',
      storeBranch: 'Eye Care Suite 1',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.optometryClinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#0284C7',
      secondaryColorHex: '#38BDF8',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.eye_3d_layer_viewer': true,
        'sw.optical_prescriptions': true,
        'sw.oct_diagnostic_imaging': true,
        'sw.visual_field_testing': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3b. Orthopedics & Bone Surgery
  factory StoreBlueprintModel.defaultOrthopedicsBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Orthopedic & Spine Center',
      storeBranch: 'Orthopedic Wing',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.orthopedicClinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#0D9488',
      secondaryColorHex: '#14B8A6',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.bone_3d_skeleton_viewer': true,
        'sw.orthopedics_trauma_action_matrix': true,
        'sw.joint_goniometry': true,
        'sw.casting_splinting_log': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3c. Physiotherapy & Muscular Rehab
  factory StoreBlueprintModel.defaultPhysiotherapyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Physiotherapy & Sports Rehab',
      storeBranch: 'Rehab Center',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.physiotherapyRehab,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#10B981',
      secondaryColorHex: '#34D399',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.muscle_3d_anatomy_viewer': true,
        'sw.physio_muscular_action_matrix': true,
        'sw.rehab_session_tracking': true,
        'sw.dry_needling_therapy': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3d. Gastroenterology & Intestinal Medicine
  factory StoreBlueprintModel.defaultGastroenterologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Gastroenterology & Endoscopy Center',
      storeBranch: 'Digestive Health Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.gastroClinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#F59E0B',
      secondaryColorHex: '#FBBF24',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.intestines_3d_digestive_viewer': true,
        'sw.gastro_endoscopy_action_matrix': true,
        'sw.gi_biopsy_tracking': true,
        'sw.colonoscopy_prep_log': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3e. Cardiology & Heart Care
  factory StoreBlueprintModel.defaultCardiologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Cardiology & Heart Center',
      storeBranch: 'Cardiac Care Unit',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.cardiologyClinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#EF4444',
      secondaryColorHex: '#F87171',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.heart_3d_vascular_viewer': true,
        'sw.cardiology_vascular_action_matrix': true,
        'sw.ecg_holter_tracking': true,
        'sw.echocardiography_panel': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3f. Dermatology & Aesthetic Medicine
  factory StoreBlueprintModel.defaultDermatologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Dermatology & Skin Health',
      storeBranch: 'Aesthetic Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.dermatologyClinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#EC4899',
      secondaryColorHex: '#F472B6',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.skin_3d_dermatome_viewer': true,
        'sw.dermatology_lesion_action_matrix': true,
        'sw.rule_of_nines_tbsa': true,
        'sw.skin_biopsy_log': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3g. Veterinary Clinic & Animal Hospital
  factory StoreBlueprintModel.defaultVeterinaryBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Veterinary Hospital & Animal Care',
      storeBranch: 'Veterinary Center',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.veterinaryClinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#10B981',
      secondaryColorHex: '#34D399',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.veterinary_3d_quadruped_viewer': true,
        'sw.veterinary_action_matrix': true,
        'sw.vaccination_reminders': true,
        'sw.microchip_scanner': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3h. Diagnostic Pathology & Laboratory Center
  factory StoreBlueprintModel.defaultDiagnosticLabBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Diagnostic Pathology & Clinical Lab',
      storeBranch: 'Central Laboratory',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.diagnosticLab,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#8B5CF6',
      secondaryColorHex: '#A78BFA',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.lab_3d_specimen_viewer': true,
        'sw.dicom_multislice_viewer': true,
        'sw.bloodwork_hemogram_panel': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3i. Mental Health & Behavioral Counseling
  factory StoreBlueprintModel.defaultMentalHealthBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Behavioral & Mental Health Center',
      storeBranch: 'Neuro-Cognitive Clinic',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.mentalHealthCounseling,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#06B6D4',
      secondaryColorHex: '#22D3EE',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.mental_3d_brain_axis_viewer': true,
        'sw.phq9_gad7_psychometrics': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3j. Pediatrics & Child Health
  factory StoreBlueprintModel.defaultPediatricsBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Pediatrics & Child Development Center',
      storeBranch: 'Children Clinic',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.pediatricClinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#F59E0B',
      secondaryColorHex: '#FCD34D',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.pediatric_3d_growth_viewer': true,
        'sw.growth_charts': true,
        'sw.vaccination_reminders': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3k. Neurology & Neurosurgery Institute
  factory StoreBlueprintModel.defaultNeurologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Neurology & Neurosurgery Institute',
      storeBranch: 'Neuroscience Center',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.neurologyNeurosurgery,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#6366F1',
      secondaryColorHex: '#818CF8',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.neuro_3d_brain_viewer': true,
        'sw.craniotomy_navigation': true,
        'sw.eeg_recording_logs': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3l. Neuro-Otology & Vestibular Balance Center
  factory StoreBlueprintModel.defaultNeuroOtologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Neuro-Otology & Vestibular Balance Center',
      storeBranch: 'Balance & Hearing Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.neuroOtologyBalance,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#4F46E5',
      secondaryColorHex: '#6366F1',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.neuro_otology_3d_vestibular_viewer': true,
        'sw.audiogram_test_reports': true,
        'sw.vng_nystagmus_analysis': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3m. Neuro-Psychiatry & TMS Behavioral Clinic
  factory StoreBlueprintModel.defaultNeuroPsychiatryBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Neuro-Psychiatry & TMS Behavioral Center',
      storeBranch: 'TMS & Neuromodulation Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.neuroPsychiatryTms,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#7C3AED',
      secondaryColorHex: '#A78BFA',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.neuro_psychiatry_3d_tms_viewer': true,
        'sw.tms_coil_mapping': true,
        'sw.psychiatric_scales_dsm5': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3n. ENT & Rhinology Sinus Clinic
  factory StoreBlueprintModel.defaultEntRhinologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Ear, Nose & Throat (ENT) & Sinus Center',
      storeBranch: 'Rhinology & Airway Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.rhinologySinusEnt,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#0284C7',
      secondaryColorHex: '#38BDF8',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.sinus_3d_rhinology_viewer': true,
        'sw.nasal_endoscopy_reports': true,
        'sw.airway_allergy_profile': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3o. Vein & Vascular Phlebology Clinic
  factory StoreBlueprintModel.defaultVascularVeinBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Vein & Vascular Phlebology Center',
      storeBranch: 'Vascular Duplex Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.veinVascularPhlebology,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#2563EB',
      secondaryColorHex: '#60A5FA',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.vein_3d_phlebology_viewer': true,
        'sw.ceap_reflux_mapping': true,
        'sw.vascular_ultrasound_duplex': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3p. Pulmonology & Respiratory Medicine
  factory StoreBlueprintModel.defaultPulmonologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Pulmonology & Respiratory Institute',
      storeBranch: 'Chest & Airway Care',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.pulmonologyRespiratory,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#0D9488',
      secondaryColorHex: '#2DD4BF',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.lungs_3d_respiratory_viewer': true,
        'sw.spirometry_pft_records': true,
        'sw.ebus_bronchoscopy_reports': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3q. Endocrinology & Glandular Medicine
  factory StoreBlueprintModel.defaultEndocrinologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Endocrinology & Metabolism Center',
      storeBranch: 'Thyroid & Diabetes Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.endocrinologyClinic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#D97706',
      secondaryColorHex: '#FBBF24',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.thyroid_3d_endocrine_viewer': true,
        'sw.tirads_nodule_scoring': true,
        'sw.cgm_glycemic_logs': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3r. Urology & Men's Health Clinic
  factory StoreBlueprintModel.defaultUrologyBlueprint() {
    return StoreBlueprintModel(
      storeName: "OmniTrack Urology & Men's Health Center",
      storeBranch: 'Urological Care Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.urologyMensHealth,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#0891B2',
      secondaryColorHex: '#22D3EE',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.urology_3d_pelvic_viewer': true,
        'sw.psa_prostate_tracking': true,
        'sw.uroflowmetry_reports': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3s. Obstetrics, Gynecology & Fertility (REI)
  factory StoreBlueprintModel.defaultObGynBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Obstetrics, Gynecology & Fertility Center',
      storeBranch: 'Maternal & Fetal Medicine',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.obgynFertilityRei,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#EC4899',
      secondaryColorHex: '#F472B6',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.obgyn_3d_pelvic_fetal_viewer': true,
        'sw.fetal_growth_biometrics': true,
        'sw.ivf_cycle_tracking': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3t. Podiatry & Custom Orthotics (P&O)
  factory StoreBlueprintModel.defaultPodiatryBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Podiatry & Foot Biomechanics Center',
      storeBranch: 'Foot & Ankle Care',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.podiatryOrthotics,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#059669',
      secondaryColorHex: '#34D399',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.foot_3d_podiatry_viewer': true,
        'sw.baropodometry_gait_analysis': true,
        'sw.orthotics_prescription': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3u. Cosmetic Plastic & Reconstructive Surgery
  factory StoreBlueprintModel.defaultPlasticSurgeryBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Cosmetic Plastic & Reconstructive Surgery',
      storeBranch: 'Aesthetic Surgery Center',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.plasticSurgeryCosmetic,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#BE185D',
      secondaryColorHex: '#F43F5E',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.face_3d_plastic_surgery_viewer': true,
        'sw.surgical_vector_planning': true,
        'sw.breast_implant_sizing': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3v. Medical Aesthetics & Facial Injectors Clinic
  factory StoreBlueprintModel.defaultMedicalAestheticsBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Medical Aesthetics & Injectors Clinic',
      storeBranch: 'Dermal & Neurotoxin Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.medicalAestheticsInjectors,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#E11D48',
      secondaryColorHex: '#FB7185',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.face_3d_injectors_mapper': true,
        'sw.botox_filler_unit_logs': true,
        'sw.facial_danger_zone_alerts': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3w. Dermatology & Hair Restoration
  factory StoreBlueprintModel.defaultDermatologyHairRestorationBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Trichology & Hair Restoration Center',
      storeBranch: 'Hair Restoration & FUE Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.dermatologyHairRestoration,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#9333EA',
      secondaryColorHex: '#C084FC',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.skin_3d_dermatome_viewer': true,
        'sw.hair_follicle_mapper': true,
        'sw.fue_graft_counter': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3x. Interventional Pain Management Clinic
  factory StoreBlueprintModel.defaultPainManagementBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Interventional Pain & Spine Clinic',
      storeBranch: 'Fluoroscopy Block Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.interventionalPainManagement,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#EA580C',
      secondaryColorHex: '#FB923C',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.pain_3d_spine_block_viewer': true,
        'sw.fluoroscopy_c_arm_planning': true,
        'sw.epidural_facet_block_records': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3y. Acupuncture & Eastern Medicine Clinic
  factory StoreBlueprintModel.defaultAcupunctureBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Acupuncture & Eastern Medicine Center',
      storeBranch: 'Meridian Therapy Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.acupunctureEasternMedicine,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#16A34A',
      secondaryColorHex: '#4ADE80',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.meridian_3d_acupoint_viewer': true,
        'sw.pulse_tongue_diagnostics': true,
        'sw.herbal_formulation_catalog': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
      },
      createdAt: DateTime(2026, 1, 1),
    );
  }

  /// 3z. Speech-Language Pathology (SLP) Clinic
  factory StoreBlueprintModel.defaultSpeechPathologyBlueprint() {
    return StoreBlueprintModel(
      storeName: 'OmniTrack Speech-Language Pathology & Voice Center',
      storeBranch: 'Voice & Articulation Suite',
      industryType: IndustryType.medical,
      vertical: IndustryVertical.medical,
      specificIndustry: SpecificIndustry.speechLanguagePathology,
      currency: 'EGP',
      taxRate: 0.0,
      taxMode: TaxMode.taxExclusive,
      themeColorHex: '#4338CA',
      secondaryColorHex: '#6366F1',
      isDarkMode: true,
      toggles: const {
        'sw.clinic_reception': true,
        'sw.clinic_doctor_station': true,
        'sw.vocal_3d_articulatory_viewer': true,
        'sw.swallowing_fees_assessment': true,
        'sw.phonetic_frequency_charting': true,
        'sw.bookings_calendar': true,
        'sw.customers_crm': true,
        'sw.inventory_catalog': true,
        'sw.boss_erp': true,
        'sw.retail_pos': false,
        'sw.orders_returns': false,
        'sw.clinic_returning_patient_detection': true,
        'sw.clinic_allergy_flags': true,
        'sw.clinic_visit_attachments': true,
        'sw.clinic_inventory_management': true,
        'sw.clinic_low_stock_alerts': true,
        'hw.receipt_printer_80mm': true,
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
        'sw.auto_vehicle_3d_inspector': true,
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
