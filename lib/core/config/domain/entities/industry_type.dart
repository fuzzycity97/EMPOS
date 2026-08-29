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

  // Medical, Dental & Clinical Practice (8)
  clinic('General Clinic & Specialist Practice', 'clinic', IndustryVertical.medical),
  dentalClinic('Dental Clinic & Orthodontics', 'dental_clinic', IndustryVertical.medical),
  diagnosticLab('Diagnostic Lab & Imaging Center', 'diagnostic_lab', IndustryVertical.medical),
  mentalHealthCounseling('Mental Health & Counseling Practice', 'mental_health_counseling', IndustryVertical.medical),
  optometryClinic('Optometry & Eyewear Clinic', 'optometry_clinic', IndustryVertical.medical),
  pharmacy('Community & Clinical Pharmacy', 'pharmacy', IndustryVertical.medical),
  physiotherapyRehab('Physiotherapy & Sports Rehab Center', 'physiotherapy_rehab', IndustryVertical.medical),
  veterinaryClinic('Veterinary Clinic & Animal Hospital', 'veterinary_clinic', IndustryVertical.medical),

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
    // Semantic fallbacks
    if (lower.contains('dental') || lower.contains('tooth') || lower.contains('teeth')) {
      return SpecificIndustry.dentalClinic;
    }
    if (lower.contains('pharma')) return SpecificIndustry.pharmacy;
    if (lower.contains('lab')) return SpecificIndustry.diagnosticLab;
    if (lower.contains('vet') || lower.contains('animal')) return SpecificIndustry.veterinaryClinic;
    if (lower.contains('eye') || lower.contains('optom')) return SpecificIndustry.optometryClinic;
    if (lower.contains('physio') || lower.contains('rehab')) return SpecificIndustry.physiotherapyRehab;
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
