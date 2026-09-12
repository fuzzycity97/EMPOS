import 'package:equatable/equatable.dart';
import 'industry_type.dart';

class ModuleFeatureFlags extends Equatable {
  final bool enableClinicalSuite;
  final bool enablePharmacyDispensing;
  final bool enableRetailSupermarket;
  final bool enableRestaurantDineIn;
  final bool enableLabDiagnostics;
  final List<SpecificIndustry> activeSpecialties;
  final bool enable3dAnatomicalViewer;
  final bool enableDiagnosticLightbox;
  final bool enableBloodworkPanel;
  final bool enableOpticalPrescriptions;
  final bool enableGrowthCharts;

  const ModuleFeatureFlags({
    this.enableClinicalSuite = false,
    this.enablePharmacyDispensing = false,
    this.enableRetailSupermarket = false,
    this.enableRestaurantDineIn = false,
    this.enableLabDiagnostics = false,
    this.activeSpecialties = const [],
    this.enable3dAnatomicalViewer = true,
    this.enableDiagnosticLightbox = true,
    this.enableBloodworkPanel = true,
    this.enableOpticalPrescriptions = false,
    this.enableGrowthCharts = false,
  });

  @override
  List<Object?> get props => [
        enableClinicalSuite,
        enablePharmacyDispensing,
        enableRetailSupermarket,
        enableRestaurantDineIn,
        enableLabDiagnostics,
        activeSpecialties,
        enable3dAnatomicalViewer,
        enableDiagnosticLightbox,
        enableBloodworkPanel,
        enableOpticalPrescriptions,
        enableGrowthCharts,
      ];
}

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
  final ModuleFeatureFlags featureFlags;

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
    this.featureFlags = const ModuleFeatureFlags(),
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
  bool get isOphthalmology =>
      specificIndustry == SpecificIndustry.optometryClinic ||
      specificIndustry.id.contains('eye') ||
      specificIndustry.id.contains('ophthalm') ||
      specificIndustry.id.contains('optom');
  bool get isOrthopedics =>
      specificIndustry == SpecificIndustry.orthopedicClinic ||
      specificIndustry.id.contains('ortho') ||
      specificIndustry.id.contains('bone') ||
      specificIndustry.id.contains('skelet');
  bool get isPhysiotherapy =>
      specificIndustry == SpecificIndustry.physiotherapyRehab ||
      specificIndustry.id.contains('physio') ||
      specificIndustry.id.contains('muscle') ||
      specificIndustry.id.contains('rehab');
  bool get isGastroenterology =>
      specificIndustry == SpecificIndustry.gastroClinic ||
      specificIndustry.id.contains('gastro') ||
      specificIndustry.id.contains('digest') ||
      specificIndustry.id.contains('intestin') ||
      specificIndustry.id.contains('colon');
  bool get isCardiology =>
      specificIndustry == SpecificIndustry.cardiologyClinic ||
      specificIndustry.id.contains('cardio') ||
      specificIndustry.id.contains('heart');
  bool get isDermatology =>
      specificIndustry == SpecificIndustry.dermatologyClinic ||
      specificIndustry.id.contains('dermat') ||
      specificIndustry.id.contains('skin');
  bool get isENT =>
      specificIndustry == SpecificIndustry.entClinic ||
      specificIndustry.id == 'ent' ||
      specificIndustry.id.startsWith('ent_') ||
      specificIndustry.id.contains('_ent') ||
      specificIndustry.id.contains('ear');
  bool get isNeurology =>
      specificIndustry == SpecificIndustry.neurologyClinic ||
      specificIndustry == SpecificIndustry.neurologyNeurosurgery ||
      specificIndustry.id.contains('neuro') ||
      specificIndustry.id.contains('brain');
  bool get isNeuroOtology =>
      specificIndustry == SpecificIndustry.neuroOtologyBalance ||
      specificIndustry.id.contains('otology') ||
      specificIndustry.id.contains('vestibul');
  bool get isNeuroPsychiatry =>
      specificIndustry == SpecificIndustry.neuroPsychiatryTms ||
      specificIndustry.id.contains('psychiatry') ||
      specificIndustry.id.contains('tms');
  bool get isRhinologySinus =>
      specificIndustry == SpecificIndustry.rhinologySinusEnt ||
      specificIndustry.id.contains('rhino') ||
      specificIndustry.id.contains('sinus');
  bool get isVascularVein =>
      specificIndustry == SpecificIndustry.veinVascularPhlebology ||
      specificIndustry.id.contains('vein') ||
      specificIndustry.id.contains('phleb');
  bool get isPulmonology =>
      specificIndustry == SpecificIndustry.pulmonologyRespiratory ||
      specificIndustry.id.contains('pulmon') ||
      specificIndustry.id.contains('respir');
  bool get isEndocrinology =>
      specificIndustry == SpecificIndustry.endocrinologyClinic ||
      specificIndustry.id.contains('endocrin') ||
      specificIndustry.id.contains('thyroid');
  bool get isUrology =>
      specificIndustry == SpecificIndustry.urologyMensHealth ||
      specificIndustry.id.contains('uro');
  bool get isObGyn =>
      specificIndustry == SpecificIndustry.obgynFertilityRei ||
      specificIndustry.id.contains('obgyn') ||
      specificIndustry.id.contains('gyne') ||
      specificIndustry.id.contains('obstet');
  bool get isPodiatry =>
      specificIndustry == SpecificIndustry.podiatryOrthotics ||
      specificIndustry.id.contains('podiat') ||
      specificIndustry.id.contains('foot');
  bool get isPlasticSurgery =>
      specificIndustry == SpecificIndustry.plasticSurgeryCosmetic ||
      specificIndustry.id.contains('plastic');
  bool get isMedicalAesthetics =>
      specificIndustry == SpecificIndustry.medicalAestheticsInjectors ||
      specificIndustry.id.contains('aesthetic') ||
      specificIndustry.id.contains('injector');
  bool get isPainManagement =>
      specificIndustry == SpecificIndustry.interventionalPainManagement ||
      specificIndustry.id.contains('pain');
  bool get isAcupuncture =>
      specificIndustry == SpecificIndustry.acupunctureEasternMedicine ||
      specificIndustry.id.contains('acupunct');
  bool get isSpeechPathology =>
      specificIndustry == SpecificIndustry.speechLanguagePathology ||
      specificIndustry.id.contains('speech') ||
      specificIndustry.id.contains('slp');
  bool get isPediatric =>
      specificIndustry == SpecificIndustry.pediatricClinic ||
      specificIndustry.id.contains('pediatric') ||
      specificIndustry.id.contains('child');
  bool get isGeneralClinic => specificIndustry == SpecificIndustry.clinic;
  bool get isVeterinary =>
      specificIndustry == SpecificIndustry.veterinaryClinic ||
      specificIndustry.id.contains('vet');
  bool get isMentalHealth =>
      specificIndustry == SpecificIndustry.mentalHealthCounseling ||
      specificIndustry.id.contains('mental');
  bool get isDiagnosticLab =>
      specificIndustry == SpecificIndustry.diagnosticLab ||
      specificIndustry.id.contains('lab');
  bool get isPharmacy =>
      specificIndustry == SpecificIndustry.pharmacy || industryType == IndustryType.pharmacy;
  bool get isSupermarket =>
      specificIndustry == SpecificIndustry.grocerySupermarket ||
      industryType == IndustryType.supermarket;
  bool get isRestaurant =>
      specificIndustry == SpecificIndustry.restaurantDinein ||
      industryType == IndustryType.foodAndBeverage;
  bool get isTattooStudio =>
      specificIndustry == SpecificIndustry.tattooPiercingStudio ||
      specificIndustry.id.contains('tattoo') ||
      specificIndustry.id.contains('piercing');
  bool get isClothingBoutique =>
      specificIndustry == SpecificIndustry.clothingBoutique ||
      specificIndustry.id.contains('clothing') ||
      specificIndustry.id.contains('boutique');
  bool get isElectronicsPhoneShop =>
      specificIndustry == SpecificIndustry.electronicsPhoneShop ||
      specificIndustry.id.contains('electronic') ||
      specificIndustry.id.contains('phone');

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
    ModuleFeatureFlags? featureFlags,
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
      featureFlags: featureFlags ?? this.featureFlags,
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
        featureFlags,
      ];
}
