import 'package:flutter_test/flutter_test.dart';
import 'package:empos/core/config/data/models/store_blueprint_model.dart';
import 'package:empos/core/config/domain/entities/industry_type.dart';

void main() {
  group('Expanded Industry Taxonomy Tests', () {
    test('IndustryVertical contains exactly 11 verticals and parses correctly', () {
      expect(IndustryVertical.values.length, 11);

      expect(IndustryVertical.fromString('automotive'), IndustryVertical.automotive);
      expect(IndustryVertical.fromString('beauty_personal_care'), IndustryVertical.beautyPersonalCare);
      expect(IndustryVertical.fromString('education_tutoring'), IndustryVertical.educationTutoring);
      expect(IndustryVertical.fromString('events_hospitality'), IndustryVertical.eventsHospitality);
      expect(IndustryVertical.fromString('fitness_sports'), IndustryVertical.fitnessSports);
      expect(IndustryVertical.fromString('food_beverage'), IndustryVertical.foodBeverage);
      expect(IndustryVertical.fromString('general_services'), IndustryVertical.generalServices);
      expect(IndustryVertical.fromString('home_trade_services'), IndustryVertical.homeTradeServices);
      expect(IndustryVertical.fromString('medical'), IndustryVertical.medical);
      expect(IndustryVertical.fromString('professional_services'), IndustryVertical.professionalServices);
      expect(IndustryVertical.fromString('retail'), IndustryVertical.retail);
    });

    test('SpecificIndustry contains exactly 41 blueprint identifiers with accurate vertical mapping', () {
      expect(SpecificIndustry.values.length, 41);

      // Medical Vertical (8)
      expect(SpecificIndustry.dentalClinic.vertical, IndustryVertical.medical);
      expect(SpecificIndustry.clinic.vertical, IndustryVertical.medical);
      expect(SpecificIndustry.diagnosticLab.vertical, IndustryVertical.medical);
      expect(SpecificIndustry.pharmacy.vertical, IndustryVertical.medical);
      expect(SpecificIndustry.veterinaryClinic.vertical, IndustryVertical.medical);
      expect(SpecificIndustry.optometryClinic.vertical, IndustryVertical.medical);
      expect(SpecificIndustry.physiotherapyRehab.vertical, IndustryVertical.medical);
      expect(SpecificIndustry.mentalHealthCounseling.vertical, IndustryVertical.medical);

      // Automotive Vertical (3)
      expect(SpecificIndustry.autoRepairGarage.vertical, IndustryVertical.automotive);
      expect(SpecificIndustry.carWashDetailing.vertical, IndustryVertical.automotive);
      expect(SpecificIndustry.tireShop.vertical, IndustryVertical.automotive);

      // Food & Beverage Vertical (5)
      expect(SpecificIndustry.bakeryPatisserie.vertical, IndustryVertical.foodBeverage);
      expect(SpecificIndustry.barPub.vertical, IndustryVertical.foodBeverage);
      expect(SpecificIndustry.cafeCoffeeshop.vertical, IndustryVertical.foodBeverage);
      expect(SpecificIndustry.cloudKitchenDelivery.vertical, IndustryVertical.foodBeverage);
      expect(SpecificIndustry.restaurantDinein.vertical, IndustryVertical.foodBeverage);

      // Events & Hospitality (2)
      expect(SpecificIndustry.hotelGuesthouse.vertical, IndustryVertical.eventsHospitality);
      expect(SpecificIndustry.eventVenueBanquet.vertical, IndustryVertical.eventsHospitality);

      // Professional Services (4)
      expect(SpecificIndustry.realEstateAgency.vertical, IndustryVertical.professionalServices);
      expect(SpecificIndustry.lawFirm.vertical, IndustryVertical.professionalServices);
      expect(SpecificIndustry.accountingBookkeeping.vertical, IndustryVertical.professionalServices);
      expect(SpecificIndustry.photographyStudio.vertical, IndustryVertical.professionalServices);
    });

    test('SpecificIndustry.fromString parses legacy JSON identifiers accurately', () {
      expect(SpecificIndustry.fromString('dental_clinic'), SpecificIndustry.dentalClinic);
      expect(SpecificIndustry.fromString('auto_repair_garage'), SpecificIndustry.autoRepairGarage);
      expect(SpecificIndustry.fromString('restaurant_dinein'), SpecificIndustry.restaurantDinein);
      expect(SpecificIndustry.fromString('hotel_guesthouse'), SpecificIndustry.hotelGuesthouse);
      expect(SpecificIndustry.fromString('real_estate_agency'), SpecificIndustry.realEstateAgency);
      expect(SpecificIndustry.fromString('grocery_supermarket'), SpecificIndustry.grocerySupermarket);
    });
  });

  group('StoreBlueprint Helper Getters Tests', () {
    test('Dental blueprint returns isMedical=true and isDental=true', () {
      final bp = StoreBlueprintModel.defaultDentalBlueprint();
      expect(bp.isMedical, true);
      expect(bp.isDental, true);
      expect(bp.isFoodBeverage, false);
      expect(bp.isEnabled('sw.dental_tooth_chart_editor'), true);
      expect(bp.isEnabled('sw.dental_compliance_record'), true);
    });

    test('General clinic blueprint returns isMedical=true and isGeneralClinic=true', () {
      final bp = StoreBlueprintModel.defaultClinicBlueprint();
      expect(bp.isMedical, true);
      expect(bp.isGeneralClinic, true);
      expect(bp.isEnabled('sw.clinic_allergy_flags'), true);
      expect(bp.isEnabled('sw.clinic_wait_time_estimation'), true);
    });

    test('Restaurant blueprint returns isFoodBeverage=true and isRestaurant=true', () {
      final bp = StoreBlueprintModel.defaultRestaurantBlueprint();
      expect(bp.isFoodBeverage, true);
      expect(bp.isRestaurant, true);
      expect(bp.isEnabled('sw.table_management'), true);
      expect(bp.isEnabled('sw.kds_kitchen_display'), true);
    });

    test('Hotel blueprint returns isHospitality=true', () {
      final bp = StoreBlueprintModel.defaultHotelBlueprint();
      expect(bp.isHospitality, true);
      expect(bp.isEnabled('sw.hotel_room_booking_calendar'), true);
    });

    test('Auto repair blueprint returns isAutomotive=true', () {
      final bp = StoreBlueprintModel.defaultAutoRepairBlueprint();
      expect(bp.isAutomotive, true);
      expect(bp.isEnabled('sw.auto_repair_vin_lookup'), true);
    });

    test('Real estate blueprint returns isRealEstate=true', () {
      final bp = StoreBlueprintModel.defaultRealEstateBlueprint();
      expect(bp.isRealEstate, true);
      expect(bp.isEnabled('sw.realty_listing_pipeline_active_pending'), true);
    });
  });

  group('StoreBlueprintModel JSON Round-Trip Serialization', () {
    test('Serializes and deserializes all 11 presets without data loss', () {
      final presets = [
        StoreBlueprintModel.defaultRetailBlueprint(),
        StoreBlueprintModel.defaultDentalBlueprint(),
        StoreBlueprintModel.defaultClinicBlueprint(),
        StoreBlueprintModel.defaultRestaurantBlueprint(),
        StoreBlueprintModel.defaultSupermarketBlueprint(),
        StoreBlueprintModel.defaultPharmacyBlueprint(),
        StoreBlueprintModel.defaultHotelBlueprint(),
        StoreBlueprintModel.defaultAutoRepairBlueprint(),
        StoreBlueprintModel.defaultRealEstateBlueprint(),
        StoreBlueprintModel.defaultSalonBlueprint(),
        StoreBlueprintModel.defaultGymBlueprint(),
      ];

      for (final original in presets) {
        final json = original.toJson();
        final reconstructed = StoreBlueprintModel.fromJson(json);

        expect(reconstructed.storeName, original.storeName);
        expect(reconstructed.vertical, original.vertical);
        expect(reconstructed.specificIndustry, original.specificIndustry);
        expect(reconstructed.themeColorHex, original.themeColorHex);
        expect(reconstructed.toggles.length, original.toggles.length);
      }
    });
  });
}
