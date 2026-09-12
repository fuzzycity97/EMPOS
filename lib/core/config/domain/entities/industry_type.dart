enum IndustryVertical {
  automotive('Automotive & Garage Services', 'automotive'),
  beautyPersonalCare('Beauty, Salon & Spa', 'beauty_personal_care'),
  educationTutoring('Education & Tutoring', 'education_tutoring'),
  eventsHospitality('Events & Hospitality', 'events_hospitality'),
  fitnessSports('Fitness, Gym & Sports', 'fitness_sports'),
  foodBeverage('Food & Beverage', 'food_beverage'),
  generalServices('General Services', 'general_services'),
  homeTradeServices('Home & Trade Field Services', 'home_trade_services'),
  medical('Medical, Dental & Clinical Practice', 'medical'),
  professionalServices('Professional Services', 'professional_services'),
  retail('Retail & Supermarkets', 'retail');

  final String label;
  final String id;

  const IndustryVertical(this.label, this.id);

  static IndustryVertical fromString(String? val) {
    if (val == null) return IndustryVertical.retail;
    final lower = val.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    for (final v in IndustryVertical.values) {
      if (v.id == lower || v.name.toLowerCase() == lower) return v;
    }
    if (lower.contains('auto') || lower.contains('car') || lower.contains('tire')) {
      return IndustryVertical.automotive;
    }
    if (lower.contains('beauty') || lower.contains('salon') || lower.contains('spa')) {
      return IndustryVertical.beautyPersonalCare;
    }
    if (lower.contains('tutor') || lower.contains('school') || lower.contains('education')) {
      return IndustryVertical.educationTutoring;
    }
    if (lower.contains('hotel') || lower.contains('event') || lower.contains('venue')) {
      return IndustryVertical.eventsHospitality;
    }
    if (lower.contains('gym') || lower.contains('fitness') || lower.contains('yoga')) {
      return IndustryVertical.fitnessSports;
    }
    if (lower.contains('food') || lower.contains('restaurant') || lower.contains('cafe') || lower.contains('bar')) {
      return IndustryVertical.foodBeverage;
    }
    if (lower.contains('clean') || lower.contains('trade') || lower.contains('hvac') || lower.contains('landscape')) {
      return IndustryVertical.homeTradeServices;
    }
    if (lower.contains('medic') || lower.contains('clinic') || lower.contains('dental') || lower.contains('pharma') || lower.contains('lab') || lower.contains('vet')) {
      return IndustryVertical.medical;
    }
    if (lower.contains('law') || lower.contains('account') || lower.contains('realt') || lower.contains('estate') || lower.contains('photo')) {
      return IndustryVertical.professionalServices;
    }
    if (lower.contains('service')) return IndustryVertical.generalServices;
    return IndustryVertical.retail;
  }
}

enum SpecificIndustry {
  // Automotive (3)
  autoRepairGarage('Auto Repair Shop & Garage', 'auto_repair_garage', IndustryVertical.automotive),
  carWashDetailing('Car Wash & Auto Detailing', 'car_wash_detailing', IndustryVertical.automotive),
  tireShop('Tire Shop & Wheel Alignment', 'tire_shop', IndustryVertical.automotive),

  // Beauty & Personal Care (4)
  hairSalonBarbershop('Hair Salon & Barbershop', 'hair_salon_barbershop', IndustryVertical.beautyPersonalCare),
  nailSalon('Nail Salon & Brow Bar', 'nail_salon', IndustryVertical.beautyPersonalCare),
  spaWellnessCenter('Spa & Wellness Center', 'spa_wellness_center', IndustryVertical.beautyPersonalCare),
  tattooPiercingStudio('Tattoo & Piercing Studio', 'tattoo_piercing_studio', IndustryVertical.beautyPersonalCare),

  // Education & Tutoring (2)
  drivingSchool('Driving School & Instruction', 'driving_school', IndustryVertical.educationTutoring),
  tutoringLearningCenter('Tutoring Center & Academy', 'tutoring_learning_center', IndustryVertical.educationTutoring),

  // Events & Hospitality (2)
  eventVenueBanquet('Event Venue & Banquet Hall', 'event_venue_banquet', IndustryVertical.eventsHospitality),
  hotelGuesthouse('Hotel, Boutique Guesthouse & Inn', 'hotel_guesthouse', IndustryVertical.eventsHospitality),

  // Fitness & Sports (3)
  gymFitnessCenter('Gym & Fitness Center', 'gym_fitness_center', IndustryVertical.fitnessSports),
  personalTraining1on1('1-on-1 Personal Training & Coaching', 'personal_training_1on1', IndustryVertical.fitnessSports),
  yogaPilatesStudio('Yoga, Pilates & Dance Studio', 'yoga_pilates_studio', IndustryVertical.fitnessSports),

  // Food & Beverage (5)
  bakeryPatisserie('Bakery & Artisan Patisserie', 'bakery_patisserie', IndustryVertical.foodBeverage),
  barPub('Bar, Pub & Lounge', 'bar_pub', IndustryVertical.foodBeverage),
  cafeCoffeeshop('Cafe & Specialty Coffee Shop', 'cafe_coffeeshop', IndustryVertical.foodBeverage),
  cloudKitchenDelivery('Food Delivery & Cloud Kitchen', 'cloud_kitchen_delivery', IndustryVertical.foodBeverage),
  restaurantDinein('Restaurant (Full-Service Dine-In)', 'restaurant_dinein', IndustryVertical.foodBeverage),

  // General Services (1)
  generalServices('General Services & Business Flow', 'general_services', IndustryVertical.generalServices),

  // Home & Trade Field Services (3)
  cleaningService('Residential & Commercial Cleaning', 'cleaning_service', IndustryVertical.homeTradeServices),
  fieldTradesHvac('Plumbing, Electrical & HVAC', 'field_trades_hvac', IndustryVertical.homeTradeServices),
  landscapingLawncare('Landscaping & Lawn Care', 'landscaping_lawncare', IndustryVertical.homeTradeServices),

  // Medical, Dental & Clinical Practice (34)
  clinic('General Clinic & Specialist Practice', 'clinic', IndustryVertical.medical),
  dentalClinic('Dental Clinic & Orthodontics', 'dental_clinic', IndustryVertical.medical),
  optometryClinic('Ophthalmology, Optometry & Eye Care', 'optometry_clinic', IndustryVertical.medical),
  orthopedicClinic('Orthopedics, Bone & Joint Surgery', 'orthopedic_clinic', IndustryVertical.medical),
  physiotherapyRehab('Physiotherapy & Musculoskeletal Rehab', 'physiotherapy_rehab', IndustryVertical.medical),
  gastroClinic('Gastroenterology & Intestinal Medicine', 'gastro_clinic', IndustryVertical.medical),
  cardiologyClinic('Cardiology & Heart Care', 'cardiology_clinic', IndustryVertical.medical),
  dermatologyClinic('Dermatology & Aesthetic Medicine', 'dermatology_clinic', IndustryVertical.medical),
  entClinic('ENT (Ear, Nose & Throat) Practice', 'ent_clinic', IndustryVertical.medical),
  neurologyClinic('Neurology & Spine Clinic', 'neurology_clinic', IndustryVertical.medical),
  pediatricClinic('Pediatrics & Child Health', 'pediatric_clinic', IndustryVertical.medical),
  diagnosticLab('Diagnostic Lab & Imaging Center', 'diagnostic_lab', IndustryVertical.medical),
  mentalHealthCounseling('Mental Health & Counseling Practice', 'mental_health_counseling', IndustryVertical.medical),
  pharmacy('Community & Clinical Pharmacy', 'pharmacy', IndustryVertical.medical),
  veterinaryClinic('Veterinary Clinic & Animal Hospital', 'veterinary_clinic', IndustryVertical.medical),

  // 1. Head, Brain & Neurological Specialties
  neurologyNeurosurgery('Neurology & Neurosurgery', 'neurology_neurosurgery', IndustryVertical.medical),
  neuroOtologyBalance('Neuro-Otology & Balance Clinic', 'neuro_otology_balance', IndustryVertical.medical),
  neuroPsychiatryTms('Neuro-Psychiatry & TMS Behavioral Clinic', 'neuro_psychiatry_tms', IndustryVertical.medical),

  // 2. Eye, ENT, Dental & Face Clinics
  ophthalmologyClinic('Ophthalmology, Cornea & Retina', 'ophthalmology_clinic', IndustryVertical.medical),
  rhinologySinusEnt('Rhinology & Sinus ENT Clinic', 'rhinology_sinus_ent', IndustryVertical.medical),
  endodonticsDental('Endodontics & Periodontics (Dental CBCT)', 'endodontics_dental', IndustryVertical.medical),

  // 3. Cardiovascular, Thoracic & Vein Clinics
  veinVascularPhlebology('Vein & Vascular Clinic (Phlebology)', 'vein_vascular_phlebology', IndustryVertical.medical),
  pulmonologyRespiratory('Pulmonology & Respiratory Clinic', 'pulmonology_respiratory', IndustryVertical.medical),
  endocrinologyClinic('Endocrinology & Glandular Clinic', 'endocrinology_clinic', IndustryVertical.medical),

  // 4. Abdominal, Pelvic & Endocrine Clinics
  urologyMensHealth('Urology & Men\'s Health Clinic', 'urology_mens_health', IndustryVertical.medical),
  obgynFertilityRei('Obstetrics, Gynecology & Fertility (REI)', 'obgyn_fertility_rei', IndustryVertical.medical),

  // 5. Musculoskeletal, Sports & Physical Rehab
  orthopedicSportsTrauma('Orthopedic Trauma & Sports Medicine', 'orthopedic_sports_trauma', IndustryVertical.medical),
  physiotherapyChiropractic('Physiotherapy, Chiropractic & Rehab', 'physiotherapy_chiropractic', IndustryVertical.medical),
  podiatryOrthotics('Podiatry & Custom Orthotics (P&O)', 'podiatry_orthotics', IndustryVertical.medical),

  // 6. Plastic Surgery, Aesthetics & Dermatology
  plasticSurgeryCosmetic('Cosmetic Plastic & Reconstructive Surgery', 'plastic_surgery_cosmetic', IndustryVertical.medical),
  medicalAestheticsInjectors('Medical Aesthetics & Injectors Clinic', 'medical_aesthetics_injectors', IndustryVertical.medical),
  dermatologyHairRestoration('Dermatology & Hair Restoration', 'dermatology_hair_restoration', IndustryVertical.medical),

  // 7. Interventional Pain, Anesthesia & Allied Specialties
  interventionalPainManagement('Interventional Pain Management Clinic', 'interventional_pain_management', IndustryVertical.medical),
  acupunctureEasternMedicine('Acupuncture & Eastern Medicine Clinic', 'acupuncture_eastern_medicine', IndustryVertical.medical),
  speechLanguagePathology('Speech-Language Pathology (SLP) Clinic', 'speech_language_pathology', IndustryVertical.medical),

  // Professional Services (4)
  accountingBookkeeping('Accounting & Bookkeeping Firm', 'accounting_bookkeeping', IndustryVertical.professionalServices),
  lawFirm('Law Firm & Legal Practice', 'law_firm', IndustryVertical.professionalServices),
  photographyStudio('Photography & Creative Studio', 'photography_studio', IndustryVertical.professionalServices),
  realEstateAgency('Real Estate Agency & Brokerage', 'real_estate_agency', IndustryVertical.professionalServices),

  // Retail & Supermarkets (6)
  bookstoreStationery('Bookstore & Stationery Shop', 'bookstore_stationery', IndustryVertical.retail),
  cashierPos('General Retail & Cashier POS', 'cashier_pos', IndustryVertical.retail),
  clothingBoutique('Clothing & Fashion Boutique', 'clothing_boutique', IndustryVertical.retail),
  convenienceKiosk('Convenience Store & Kiosk', 'convenience_kiosk', IndustryVertical.retail),
  electronicsPhoneShop('Electronics & Mobile Phone Repair Shop', 'electronics_phone_shop', IndustryVertical.retail),
  grocerySupermarket('Grocery & Supermarket POS', 'grocery_supermarket', IndustryVertical.retail);

  final String label;
  final String id;
  final IndustryVertical vertical;

  const SpecificIndustry(this.label, this.id, this.vertical);

  static SpecificIndustry fromString(String? val) {
    if (val == null) return SpecificIndustry.cashierPos;
    final lower = val.toLowerCase().replaceAll(' ', '_').replaceAll('-', '_');
    for (final s in SpecificIndustry.values) {
      if (s.id == lower || s.name.toLowerCase() == lower) return s;
    }
    // Specialized Medical Clinics Semantic fallbacks
    if (lower.contains('otology') || lower.contains('balance') || lower.contains('vestibul') || lower.contains('bppv')) {
      return SpecificIndustry.neuroOtologyBalance;
    }
    if (lower.contains('tms') || lower.contains('psychiatry')) {
      return SpecificIndustry.neuroPsychiatryTms;
    }
    if (lower.contains('rhino') || lower.contains('sinus')) {
      return SpecificIndustry.rhinologySinusEnt;
    }
    if (lower.contains('endo') || lower.contains('perio') || lower.contains('cbct')) {
      return SpecificIndustry.endodonticsDental;
    }
    if (lower.contains('vein') || lower.contains('phleb') || lower.contains('angiogram')) {
      return SpecificIndustry.veinVascularPhlebology;
    }
    if (lower.contains('pulmon') || lower.contains('respir') || lower.contains('lung') || lower.contains('bronch')) {
      return SpecificIndustry.pulmonologyRespiratory;
    }
    if (lower.contains('endocrin') || lower.contains('thyroid') || lower.contains('hormone')) {
      return SpecificIndustry.endocrinologyClinic;
    }
    if (lower.contains('uro') || lower.contains('prostate') || lower.contains('bladder') || lower.contains('kidney')) {
      return SpecificIndustry.urologyMensHealth;
    }
    if (lower.contains('obgyn') || lower.contains('gyne') || lower.contains('obstet') || lower.contains('fetal') || lower.contains('fertility') || lower.contains('rei')) {
      return SpecificIndustry.obgynFertilityRei;
    }
    if (lower.contains('podiat') || lower.contains('foot') || lower.contains('orthotic')) {
      return SpecificIndustry.podiatryOrthotics;
    }
    if (lower.contains('plastic') || lower.contains('rhinoplasty') || lower.contains('facelift')) {
      return SpecificIndustry.plasticSurgeryCosmetic;
    }
    if (lower.contains('aesthetic') || lower.contains('injector') || lower.contains('botox') || lower.contains('filler')) {
      return SpecificIndustry.medicalAestheticsInjectors;
    }
    if (lower.contains('pain') || lower.contains('interventional_pain') || lower.contains('rfa')) {
      return SpecificIndustry.interventionalPainManagement;
    }
    if (lower.contains('acupunct') || lower.contains('meridian') || lower.contains('eastern_medicine')) {
      return SpecificIndustry.acupunctureEasternMedicine;
    }
    if (lower.contains('speech') || lower.contains('swallow') || lower.contains('slp') || lower.contains('vocal')) {
      return SpecificIndustry.speechLanguagePathology;
    }
    if (lower.contains('dental') || lower.contains('tooth') || lower.contains('teeth')) {
      return SpecificIndustry.dentalClinic;
    }
    if (lower.contains('eye') || lower.contains('optom') || lower.contains('ophthalm')) {
      return SpecificIndustry.optometryClinic;
    }
    if (lower.contains('ortho') || lower.contains('bone') || lower.contains('skelet') || lower.contains('fracture')) {
      return SpecificIndustry.orthopedicClinic;
    }
    if (lower.contains('physio') || lower.contains('rehab') || lower.contains('muscle')) {
      return SpecificIndustry.physiotherapyRehab;
    }
    if (lower.contains('gastro') || lower.contains('digest') || lower.contains('intestin') || lower.contains('colon') || lower.contains('stomach')) {
      return SpecificIndustry.gastroClinic;
    }
    if (lower.contains('cardio') || lower.contains('heart') || lower.contains('vascular')) {
      return SpecificIndustry.cardiologyClinic;
    }
    if (lower.contains('dermat') || lower.contains('skin') || lower.contains('hair_restoration') || lower.contains('cosmetic_derma')) {
      return SpecificIndustry.dermatologyClinic;
    }
    if (lower.contains('ent') || lower.contains('ear') || lower.contains('throat') || lower.contains('nose')) {
      return SpecificIndustry.entClinic;
    }
    if (lower.contains('neuro') || lower.contains('brain') || lower.contains('spine')) {
      return SpecificIndustry.neurologyClinic;
    }
    if (lower.contains('pediatric') || lower.contains('child') || lower.contains('infant')) {
      return SpecificIndustry.pediatricClinic;
    }
    if (lower.contains('mental') || lower.contains('counsel')) return SpecificIndustry.mentalHealthCounseling;
    if (lower.contains('clinic') || lower.contains('doctor')) return SpecificIndustry.clinic;
    if (lower.contains('supermarket') || lower.contains('grocery')) return SpecificIndustry.grocerySupermarket;
    if (lower.contains('restaurant') || lower.contains('dine')) return SpecificIndustry.restaurantDinein;
    if (lower.contains('cafe') || lower.contains('coffee')) return SpecificIndustry.cafeCoffeeshop;
    if (lower.contains('bakery')) return SpecificIndustry.bakeryPatisserie;
    if (lower.contains('bar') || lower.contains('pub')) return SpecificIndustry.barPub;
    if (lower.contains('hotel') || lower.contains('guest')) return SpecificIndustry.hotelGuesthouse;
    if (lower.contains('gym') || lower.contains('fitness')) return SpecificIndustry.gymFitnessCenter;
    if (lower.contains('salon') || lower.contains('barber')) return SpecificIndustry.hairSalonBarbershop;
    if (lower.contains('spa')) return SpecificIndustry.spaWellnessCenter;
    if (lower.contains('nail')) return SpecificIndustry.nailSalon;
    if (lower.contains('auto') || lower.contains('garage') || lower.contains('repair')) return SpecificIndustry.autoRepairGarage;
    if (lower.contains('wash')) return SpecificIndustry.carWashDetailing;
    if (lower.contains('tire')) return SpecificIndustry.tireShop;
    if (lower.contains('estate') || lower.contains('realt')) return SpecificIndustry.realEstateAgency;
    if (lower.contains('law') || lower.contains('legal')) return SpecificIndustry.lawFirm;
    if (lower.contains('account') || lower.contains('bookkeep')) return SpecificIndustry.accountingBookkeeping;
    if (lower.contains('cloth') || lower.contains('boutique')) return SpecificIndustry.clothingBoutique;
    if (lower.contains('electronic') || lower.contains('phone')) return SpecificIndustry.electronicsPhoneShop;
    if (lower.contains('book')) return SpecificIndustry.bookstoreStationery;
    if (lower.contains('kiosk')) return SpecificIndustry.convenienceKiosk;
    return SpecificIndustry.cashierPos;
  }
}

/// Backwards-compatible core industry classification
enum IndustryType {
  retail,
  supermarket,
  pharmacy,
  foodAndBeverage,
  clothingBoutique,
  electronics,
  automotive,
  services,
  medical,
  hospitality,
  fitness,
  realEstate,
  other;

  static IndustryType fromString(String? val) {
    if (val == null) return IndustryType.retail;
    final lower = val.toLowerCase().replaceAll(' ', '_').replaceAll('&', 'and');
    if (lower.contains('supermarket') || lower.contains('grocery')) {
      return IndustryType.supermarket;
    }
    if (lower.contains('dental') || lower.contains('clinic') || lower.contains('doctor') || lower.contains('medical') || lower.contains('lab') || lower.contains('vet')) {
      return IndustryType.medical;
    }
    if (lower.contains('pharmacy')) {
      return IndustryType.pharmacy;
    }
    if (lower.contains('food') || lower.contains('beverage') || lower.contains('restaurant') || lower.contains('cafe') || lower.contains('bar') || lower.contains('bakery')) {
      return IndustryType.foodAndBeverage;
    }
    if (lower.contains('clothing') || lower.contains('boutique') || lower.contains('apparel')) {
      return IndustryType.clothingBoutique;
    }
    if (lower.contains('electronics') || lower.contains('phone')) {
      return IndustryType.electronics;
    }
    if (lower.contains('automotive') || lower.contains('car') || lower.contains('garage') || lower.contains('tire')) {
      return IndustryType.automotive;
    }
    if (lower.contains('hotel') || lower.contains('hospitality') || lower.contains('venue')) {
      return IndustryType.hospitality;
    }
    if (lower.contains('gym') || lower.contains('fitness') || lower.contains('sports') || lower.contains('yoga')) {
      return IndustryType.fitness;
    }
    if (lower.contains('real_estate') || lower.contains('realty') || lower.contains('property')) {
      return IndustryType.realEstate;
    }
    if (lower.contains('service') || lower.contains('clean') || lower.contains('salon') || lower.contains('spa')) {
      return IndustryType.services;
    }
    return IndustryType.retail;
  }
}

enum TaxMode {
  taxExclusive,
  taxInclusive;

  static TaxMode fromString(String? val) {
    if (val == null) return TaxMode.taxExclusive;
    final lower = val.toLowerCase();
    if (lower.contains('inclusive')) return TaxMode.taxInclusive;
    return TaxMode.taxExclusive;
  }
}
