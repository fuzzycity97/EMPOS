import 'package:equatable/equatable.dart';
import 'industry_type.dart';

class StoreBlueprint extends Equatable {
  final String storeName;
  final String storeBranch;
  final IndustryType industryType;
  final IndustryVertical vertical;
  final SpecificIndustry specificIndustry;
  final String currency;
  final double taxRate;
  final TaxMode taxMode;
  final String? serverSyncUrl;
  final String themeColorHex;
  final String? secondaryColorHex;
  final bool isDarkMode;
  final Map<String, bool> toggles;
  final DateTime? createdAt;

  const StoreBlueprint({
    required this.storeName,
    this.storeBranch = 'Main Branch',
    this.industryType = IndustryType.retail,
    this.vertical = IndustryVertical.retail,
    this.specificIndustry = SpecificIndustry.cashierPos,
    this.currency = 'EGP',
    this.taxRate = 14.0,
    this.taxMode = TaxMode.taxExclusive,
    this.serverSyncUrl,
    this.themeColorHex = '#6366F1',
    this.secondaryColorHex = '#10B981',
    this.isDarkMode = true,
    this.toggles = const {},
    this.createdAt,
  });

  bool isEnabled(String toggleKey, {bool defaultValue = false}) {
    return toggles[toggleKey] ?? defaultValue;
  }

  // Vertical convenience helpers
  bool get isMedical =>
      vertical == IndustryVertical.medical || industryType == IndustryType.medical;
  bool get isAutomotive =>
      vertical == IndustryVertical.automotive || industryType == IndustryType.automotive;
  bool get isBeautySpa => vertical == IndustryVertical.beautyPersonalCare;
  bool get isHospitality =>
      vertical == IndustryVertical.eventsHospitality || industryType == IndustryType.hospitality;
  bool get isFitness =>
      vertical == IndustryVertical.fitnessSports || industryType == IndustryType.fitness;
  bool get isRealEstate =>
      vertical == IndustryVertical.professionalServices || industryType == IndustryType.realEstate;
  bool get isHomeTrade =>
      vertical == IndustryVertical.homeTradeServices;
  bool get isServices =>
      vertical == IndustryVertical.generalServices ||
      vertical == IndustryVertical.professionalServices ||
      vertical == IndustryVertical.educationTutoring;
  bool get isFoodBeverage =>
      vertical == IndustryVertical.foodBeverage || industryType == IndustryType.foodAndBeverage;
  bool get isRetail =>
      vertical == IndustryVertical.retail || industryType == IndustryType.retail;

  // Specific industry helpers
  bool get isDental => specificIndustry == SpecificIndustry.dentalClinic;
  bool get isGeneralClinic => specificIndustry == SpecificIndustry.clinic;
  bool get isPharmacy =>
      specificIndustry == SpecificIndustry.pharmacy || industryType == IndustryType.pharmacy;
  bool get isSupermarket =>
      specificIndustry == SpecificIndustry.grocerySupermarket ||
      industryType == IndustryType.supermarket;
  bool get isRestaurant =>
      specificIndustry == SpecificIndustry.restaurantDinein ||
      industryType == IndustryType.foodAndBeverage;

  StoreBlueprint copyWith({
    String? storeName,
    String? storeBranch,
    IndustryType? industryType,
    IndustryVertical? vertical,
    SpecificIndustry? specificIndustry,
    String? currency,
    double? taxRate,
    TaxMode? taxMode,
    String? serverSyncUrl,
    String? themeColorHex,
    String? secondaryColorHex,
    bool? isDarkMode,
    Map<String, bool>? toggles,
    DateTime? createdAt,
  }) {
    return StoreBlueprint(
      storeName: storeName ?? this.storeName,
      storeBranch: storeBranch ?? this.storeBranch,
      industryType: industryType ?? this.industryType,
      vertical: vertical ?? this.vertical,
      specificIndustry: specificIndustry ?? this.specificIndustry,
      currency: currency ?? this.currency,
      taxRate: taxRate ?? this.taxRate,
      taxMode: taxMode ?? this.taxMode,
      serverSyncUrl: serverSyncUrl ?? this.serverSyncUrl,
      themeColorHex: themeColorHex ?? this.themeColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      toggles: toggles ?? this.toggles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        storeName,
        storeBranch,
        industryType,
        vertical,
        specificIndustry,
        currency,
        taxRate,
        taxMode,
        serverSyncUrl,
        themeColorHex,
        secondaryColorHex,
        isDarkMode,
        toggles,
        createdAt,
      ];
}
