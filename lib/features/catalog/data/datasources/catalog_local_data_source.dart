import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/config/data/models/store_blueprint_model.dart';
import '../../../../core/config/domain/entities/industry_type.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/error/exceptions.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

abstract class CatalogLocalDataSource {
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    bool? onlyActive,
  });

  Future<ProductModel> getProductById(String id);

  Future<ProductModel> getProductByBarcode(String barcode);

  Future<List<ProductModel>> searchProducts(String query);

  Future<List<CategoryModel>> getCategories({bool? onlyActive});

  Future<void> saveProduct(ProductModel product);

  Future<void> deleteProduct(String id);

  Future<void> saveCategory(CategoryModel category);

  Future<void> deleteCategory(String id);

  Future<void> toggleCategoryStatus(String id, bool isEnabled);

  Future<void> updateStock(String productId, int quantityDelta);

  Future<void> seedCatalogForBlueprint(StoreBlueprint blueprint, {bool force = false});
}

class CatalogLocalDataSourceImpl implements CatalogLocalDataSource {
  static const String productsBoxName = 'empos_products_box';
  static const String categoriesBoxName = 'empos_categories_box';

  Future<Box<String>> get _productsBox async =>
      await Hive.openBox<String>(productsBoxName);

  Future<Box<String>> get _categoriesBox async =>
      await Hive.openBox<String>(categoriesBoxName);

  Future<void> _ensureInitialSeed() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    if (catBox.isEmpty || prodBox.isEmpty) {
      StoreBlueprint? activeBlueprint;
      try {
        final configBox = await Hive.openBox<String>('empos_config_box');
        final rawConfig = configBox.get('store_blueprint');
        if (rawConfig != null && rawConfig.isNotEmpty) {
          activeBlueprint = StoreBlueprintModel.fromRaw(rawConfig);
        }
      } catch (_) {}

      if (activeBlueprint != null) {
        await seedCatalogForBlueprint(activeBlueprint, force: true);
      } else {
        await _seedDefaultRetail(force: true);
      }
    }
  }

  @override
  Future<void> seedCatalogForBlueprint(StoreBlueprint blueprint, {bool force = false}) async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    if (!force && catBox.isNotEmpty && prodBox.isNotEmpty) {
      return;
    }

    if (force) {
      await catBox.clear();
      await prodBox.clear();
    }

    switch (blueprint.vertical) {
      case IndustryVertical.automotive:
        await _seedAutomotive();
        break;
      case IndustryVertical.beautyPersonalCare:
        await _seedBeauty();
        break;
      case IndustryVertical.fitnessSports:
        await _seedFitness();
        break;
      case IndustryVertical.eventsHospitality:
        await _seedHospitality();
        break;
      case IndustryVertical.foodBeverage:
        await _seedFoodBeverage();
        break;
      case IndustryVertical.medical:
        await _seedMedicalDental();
        break;
      case IndustryVertical.professionalServices:
        await _seedProfessionalRealEstate();
        break;
      case IndustryVertical.educationTutoring:
        await _seedEducation();
        break;
      case IndustryVertical.homeTradeServices:
        await _seedHomeTrade();
        break;
      case IndustryVertical.generalServices:
        await _seedGeneralServices();
        break;
      case IndustryVertical.retail:
        await _seedDefaultRetail(force: force);
        break;
    }
  }

  Future<void> _seedAutomotive() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-auto-maint', name: 'Maintenance & Labor', nameAr: 'خدمات وصيانة', icon: 'wrench', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-auto-diag', name: 'Diagnostics & Inspection', nameAr: 'فحص وتشخيص', icon: 'laptop', isEnabled: true, orderIndex: 1),
      const CategoryModel(id: 'cat-auto-parts', name: 'Mechanical Parts', nameAr: 'قطع غيار ميكانيكية', icon: 'settings', isEnabled: true, orderIndex: 2),
      const CategoryModel(id: 'cat-auto-fluids', name: 'Oils & Fluids', nameAr: 'زيوت وسوائل', icon: 'droplet', isEnabled: true, orderIndex: 3),
    ];

    final products = [
      const ProductModel(id: 'prod-auto-01', nameEn: 'Engine Oil Change', nameAr: 'تغيير زيت وفلتر محرك', categoryId: 'cat-auto-maint', price: 850.0, cost: 450.0, stock: 999999, barcode: 'AUTO-001', trackQty: false),
      const ProductModel(id: 'prod-auto-02', nameEn: 'Brake Pad Inspection', nameAr: 'فحص وتغيير تيل فرامل', categoryId: 'cat-auto-maint', price: 450.0, cost: 150.0, stock: 999999, barcode: 'AUTO-002', trackQty: false),
      const ProductModel(id: 'prod-auto-03', nameEn: 'Tire Alignment', nameAr: 'ضبط زوايا واتزان إطارات', categoryId: 'cat-auto-maint', price: 250.0, cost: 0.0, stock: 999999, barcode: 'AUTO-003', trackQty: false),
      const ProductModel(id: 'prod-auto-04', nameEn: 'Premium Brake Pads Set', nameAr: 'طقم تيل فرامل سيراميك', categoryId: 'cat-auto-parts', price: 950.0, cost: 650.0, stock: 25, barcode: 'AUTO-004', trackQty: true),
      const ProductModel(id: 'prod-auto-05', nameEn: 'Engine Oil 5W-30 (4L)', nameAr: 'زيت محرك تخليقي 5W-30', categoryId: 'cat-auto-fluids', price: 680.0, cost: 490.0, stock: 40, barcode: 'AUTO-005', trackQty: true),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedBeauty() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-beauty-hair', name: 'Hair & Styling', nameAr: 'قص وتصفيف شعر', icon: 'scissors', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-beauty-spa', name: 'Spa & Massage', nameAr: 'سبا ومساج', icon: 'sparkles', isEnabled: true, orderIndex: 1),
      const CategoryModel(id: 'cat-beauty-retail', name: 'Beauty Products', nameAr: 'منتجات عناية', icon: 'shopping-bag', isEnabled: true, orderIndex: 2),
    ];

    final products = [
      const ProductModel(id: 'prod-b-01', nameEn: 'Haircut & Styling', nameAr: 'قص وتصفيف شعر', categoryId: 'cat-beauty-hair', price: 250.0, cost: 0.0, stock: 999999, barcode: 'BEAUTY-001', trackQty: false),
      const ProductModel(id: 'prod-b-02', nameEn: 'Hydrating Facial', nameAr: 'جلسة نضارة وترطيب بشرة', categoryId: 'cat-beauty-spa', price: 500.0, cost: 80.0, stock: 999999, barcode: 'BEAUTY-002', trackQty: false),
      const ProductModel(id: 'prod-b-03', nameEn: 'Full Body Massage', nameAr: 'جلسة مساج كامل للجسم', categoryId: 'cat-beauty-spa', price: 650.0, cost: 100.0, stock: 999999, barcode: 'BEAUTY-003', trackQty: false),
      const ProductModel(id: 'prod-b-04', nameEn: 'Argan Oil Hair Serum 100ml', nameAr: 'سيروم الأرجان للشعر', categoryId: 'cat-beauty-retail', price: 320.0, cost: 180.0, stock: 35, barcode: 'BEAUTY-004', trackQty: true),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedFitness() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-fit-pass', name: 'Memberships & Passes', nameAr: 'اشتراكات وباقات', icon: 'award', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-fit-pt', name: 'Personal Training', nameAr: 'تدريب خاص', icon: 'activity', isEnabled: true, orderIndex: 1),
      const CategoryModel(id: 'cat-fit-supps', name: 'Supplements & Drinks', nameAr: 'مكملات ومشروبات', icon: 'cup-soda', isEnabled: true, orderIndex: 2),
    ];

    final products = [
      const ProductModel(id: 'prod-fit-01', nameEn: 'Monthly Gym Pass', nameAr: 'اشتراك شهري للجيم', categoryId: 'cat-fit-pass', price: 750.0, cost: 0.0, stock: 999999, barcode: 'FIT-001', trackQty: false),
      const ProductModel(id: 'prod-fit-02', nameEn: '1-on-1 PT Session', nameAr: 'جلسة تدريب شخصي 1-على-1', categoryId: 'cat-fit-pt', price: 250.0, cost: 0.0, stock: 999999, barcode: 'FIT-002', trackQty: false),
      const ProductModel(id: 'prod-fit-03', nameEn: 'Yoga Drop-In Class', nameAr: 'حصة يوجا فردية', categoryId: 'cat-fit-pt', price: 150.0, cost: 0.0, stock: 999999, barcode: 'FIT-003', trackQty: false),
      const ProductModel(id: 'prod-fit-04', nameEn: 'Whey Protein Shake 500ml', nameAr: 'مشروب واي بروتين', categoryId: 'cat-fit-supps', price: 65.0, cost: 35.0, stock: 60, barcode: 'FIT-004', trackQty: true),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedHospitality() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-hosp-rooms', name: 'Rooms & Suites', nameAr: 'غرف وأجنحة', icon: 'hotel', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-hosp-events', name: 'Events & Venues', nameAr: 'قاعات ومناسبات', icon: 'calendar', isEnabled: true, orderIndex: 1),
      const CategoryModel(id: 'cat-hosp-dining', name: 'Room Service & Dining', nameAr: 'خدمة الغرف والمطعم', icon: 'utensils', isEnabled: true, orderIndex: 2),
    ];

    final products = [
      const ProductModel(id: 'prod-hosp-01', nameEn: 'Deluxe Single Room', nameAr: 'غرفة فندقية مفردة فاخرة', categoryId: 'cat-hosp-rooms', price: 1500.0, cost: 300.0, stock: 999999, barcode: 'HOSP-001', trackQty: false),
      const ProductModel(id: 'prod-hosp-02', nameEn: 'Suite Nightly Rate', nameAr: 'جناح فندقي ليلة كاملة', categoryId: 'cat-hosp-rooms', price: 2800.0, cost: 500.0, stock: 999999, barcode: 'HOSP-002', trackQty: false),
      const ProductModel(id: 'prod-hosp-03', nameEn: 'Banquet Hall Rental', nameAr: 'حجز قاعة احتفالات ومؤتمرات', categoryId: 'cat-hosp-events', price: 12000.0, cost: 2000.0, stock: 999999, barcode: 'HOSP-003', trackQty: false),
      const ProductModel(id: 'prod-hosp-04', nameEn: 'Continental Breakfast Buffet', nameAr: 'بوفيه إفطار كونتيننتال', categoryId: 'cat-hosp-dining', price: 300.0, cost: 100.0, stock: 999999, barcode: 'HOSP-004', trackQty: false),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedFoodBeverage() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-fb-coffee', name: 'Coffee & Drinks', nameAr: 'قهوة ومشروبات', icon: 'cup-soda', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-fb-food', name: 'Main Dishes & Pizza', nameAr: 'أطباق رئيسية وبيتزا', icon: 'utensils', isEnabled: true, orderIndex: 1),
      const CategoryModel(id: 'cat-fb-dessert', name: 'Desserts & Bakery', nameAr: 'حلويات ومخبوزات', icon: 'cake', isEnabled: true, orderIndex: 2),
    ];

    final products = [
      const ProductModel(id: 'prod-fb-01', nameEn: 'Espresso', nameAr: 'اسبريسو كلاسيك', categoryId: 'cat-fb-coffee', price: 35.0, cost: 10.0, stock: 999999, barcode: 'FB-001', trackQty: false),
      const ProductModel(id: 'prod-fb-02', nameEn: 'Club Sandwich', nameAr: 'كلوب ساندوتش دجاج', categoryId: 'cat-fb-food', price: 85.0, cost: 38.0, stock: 999999, barcode: 'FB-002', trackQty: false),
      const ProductModel(id: 'prod-fb-03', nameEn: 'Margherita Pizza', nameAr: 'بيتزا مارجريتا إيطالية', categoryId: 'cat-fb-food', price: 120.0, cost: 45.0, stock: 999999, barcode: 'FB-003', trackQty: false),
      const ProductModel(id: 'prod-fb-04', nameEn: 'Fresh Orange Juice', nameAr: 'عصير برتقال فريش', categoryId: 'cat-fb-coffee', price: 40.0, cost: 15.0, stock: 999999, barcode: 'FB-004', trackQty: false),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedMedicalDental() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-med-consult', name: 'Clinical Consultations', nameAr: 'استشارات وفحوصات', icon: 'stethoscope', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-med-restorative', name: 'Restorative & Fillings', nameAr: 'حشوات وعلاج تحفظي', icon: 'sparkles', isEnabled: true, orderIndex: 1),
      const CategoryModel(id: 'cat-med-preventive', name: 'Preventive & Scaling', nameAr: 'وقاية وتنظيف', icon: 'shield-check', isEnabled: true, orderIndex: 2),
      const CategoryModel(id: 'cat-med-endo', name: 'Endodontics & Roots', nameAr: 'علاج جذور وعصب', icon: 'activity', isEnabled: true, orderIndex: 3),
      const CategoryModel(id: 'cat-med-surgery', name: 'Oral Surgery & Extraction', nameAr: 'جراحة وخلع', icon: 'scissors', isEnabled: true, orderIndex: 4),
      const CategoryModel(id: 'cat-med-consumables', name: 'Consumables & Materials', nameAr: 'مستهلكات ومواد طبية', icon: 'boxes', isEnabled: true, orderIndex: 5),
    ];

    final products = [
      const ProductModel(id: 'prod-m-01', nameEn: 'Clinical Consultation', nameAr: 'كشف واستشارة طبية', categoryId: 'cat-med-consult', price: 250.0, cost: 0.0, stock: 999999, barcode: 'MED-001', trackQty: false),
      const ProductModel(id: 'prod-m-02', nameEn: 'Composite Tooth Filling', nameAr: 'حشو أسنان تجميلي كمبوزيت', categoryId: 'cat-med-restorative', price: 650.0, cost: 80.0, stock: 999999, barcode: 'MED-002', trackQty: false),
      const ProductModel(id: 'prod-m-03', nameEn: 'Scaling & Polishing', nameAr: 'تنظيف وتلميع أسنان', categoryId: 'cat-med-preventive', price: 450.0, cost: 30.0, stock: 999999, barcode: 'MED-003', trackQty: false),
      const ProductModel(id: 'prod-m-04', nameEn: 'Root Canal Treatment', nameAr: 'علاج جذور وعصب', categoryId: 'cat-med-endo', price: 1200.0, cost: 150.0, stock: 999999, barcode: 'MED-004', trackQty: false),
      const ProductModel(id: 'prod-m-05', nameEn: 'Simple Tooth Extraction', nameAr: 'خلع سن بسيط', categoryId: 'cat-med-surgery', price: 350.0, cost: 40.0, stock: 999999, barcode: 'MED-005', trackQty: false),
      const ProductModel(id: 'prod-m-06', nameEn: 'Sterile Medical Gloves Box', nameAr: 'علبة قفازات طبية معقمة', categoryId: 'cat-med-consumables', price: 120.0, cost: 75.0, stock: 80, barcode: 'MED-006', trackQty: true),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedProfessionalRealEstate() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-prof-consult', name: 'Advisory & Consultation', nameAr: 'استشارات مهنية', icon: 'briefcase', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-prof-appraisal', name: 'Appraisal & Valuation', nameAr: 'تقييم وتثمين', icon: 'home', isEnabled: true, orderIndex: 1),
      const CategoryModel(id: 'cat-prof-audit', name: 'Auditing & Accounting', nameAr: 'تدقيق ومحاسبة', icon: 'file-text', isEnabled: true, orderIndex: 2),
    ];

    final products = [
      const ProductModel(id: 'prod-prof-01', nameEn: 'Property Appraisal', nameAr: 'تقييم عقاري معتمد', categoryId: 'cat-prof-appraisal', price: 1800.0, cost: 200.0, stock: 999999, barcode: 'PROF-001', trackQty: false),
      const ProductModel(id: 'prod-prof-02', nameEn: 'Legal Consultation 1hr', nameAr: 'استشارة قانونية ساعة', categoryId: 'cat-prof-consult', price: 800.0, cost: 0.0, stock: 999999, barcode: 'PROF-002', trackQty: false),
      const ProductModel(id: 'prod-prof-03', nameEn: 'Accounting Audit', nameAr: 'مراجعة وتدقيق محاسبي', categoryId: 'cat-prof-audit', price: 2500.0, cost: 400.0, stock: 999999, barcode: 'PROF-003', trackQty: false),
      const ProductModel(id: 'prod-prof-04', nameEn: 'Tax Advisory Session', nameAr: 'جلسة استشارات ضريبية', categoryId: 'cat-prof-consult', price: 1200.0, cost: 0.0, stock: 999999, barcode: 'PROF-004', trackQty: false),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedEducation() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-edu-tutoring', name: 'Private Tutoring', nameAr: 'تدريس ودروس خصوصية', icon: 'book-open', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-edu-courses', name: 'Courses & Programs', nameAr: 'كورسات ودورات', icon: 'award', isEnabled: true, orderIndex: 1),
    ];

    final products = [
      const ProductModel(id: 'prod-edu-01', nameEn: '1-on-1 Academic Tutoring (1hr)', nameAr: 'حصة تدريس خصوصي ساعة', categoryId: 'cat-edu-tutoring', price: 200.0, cost: 0.0, stock: 999999, barcode: 'EDU-001', trackQty: false),
      const ProductModel(id: 'prod-edu-02', nameEn: 'Monthly Course Enrollment', nameAr: 'اشتراك كورس شهري', categoryId: 'cat-edu-courses', price: 1200.0, cost: 150.0, stock: 999999, barcode: 'EDU-002', trackQty: false),
      const ProductModel(id: 'prod-edu-03', nameEn: 'Mock Exam & Assessment', nameAr: 'امتحان تجريبي وتقييم', categoryId: 'cat-edu-courses', price: 150.0, cost: 20.0, stock: 999999, barcode: 'EDU-003', trackQty: false),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedHomeTrade() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-trade-repairs', name: 'Field Visits & Repairs', nameAr: 'زيارات وإصلاحات', icon: 'tool', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-trade-parts', name: 'Fixtures & Materials', nameAr: 'مستلزمات ومواد', icon: 'boxes', isEnabled: true, orderIndex: 1),
    ];

    final products = [
      const ProductModel(id: 'prod-tr-01', nameEn: 'Plumbing Maintenance Visit', nameAr: 'زيارة صيانة سباكة منزلية', categoryId: 'cat-trade-repairs', price: 250.0, cost: 50.0, stock: 999999, barcode: 'TRADE-001', trackQty: false),
      const ProductModel(id: 'prod-tr-02', nameEn: 'Electrical Diagnostic & Fix', nameAr: 'كشف وإصلاح أعطال كهرباء', categoryId: 'cat-trade-repairs', price: 300.0, cost: 60.0, stock: 999999, barcode: 'TRADE-002', trackQty: false),
      const ProductModel(id: 'prod-tr-03', nameEn: 'AC Deep Cleaning & Gas Charge', nameAr: 'صيانة وشحن فريون تكييف', categoryId: 'cat-trade-repairs', price: 550.0, cost: 180.0, stock: 999999, barcode: 'TRADE-003', trackQty: false),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedGeneralServices() async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    final categories = [
      const CategoryModel(id: 'cat-gen-serv', name: 'Service Packages', nameAr: 'باقات الخدمات', icon: 'layers', isEnabled: true, orderIndex: 0),
    ];

    final products = [
      const ProductModel(id: 'prod-gs-01', nameEn: 'Standard Service Hourly Rate', nameAr: 'ساعة عمل خدمة عامة', categoryId: 'cat-gen-serv', price: 200.0, cost: 0.0, stock: 999999, barcode: 'SERV-001', trackQty: false),
      const ProductModel(id: 'prod-gs-02', nameEn: 'Premium Service Package', nameAr: 'باقة خدمات متقدمة', categoryId: 'cat-gen-serv', price: 1500.0, cost: 200.0, stock: 999999, barcode: 'SERV-002', trackQty: false),
    ];

    for (final cat in categories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in products) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  Future<void> _seedDefaultRetail({bool force = false}) async {
    final catBox = await _categoriesBox;
    final prodBox = await _productsBox;

    if (!force && catBox.isNotEmpty && prodBox.isNotEmpty) return;

    final initialCategories = [
      const CategoryModel(id: 'cat-general', name: 'General Goods', nameAr: 'سلع عامة', icon: 'layers', isEnabled: true, orderIndex: 0),
      const CategoryModel(id: 'cat-beverages', name: 'Beverages', nameAr: 'مشروبات', icon: 'cup-soda', isEnabled: true, orderIndex: 1),
      const CategoryModel(id: 'cat-apparel', name: 'Apparel & Wear', nameAr: 'ملابس وأزياء', icon: 'shopping-bag', isEnabled: true, orderIndex: 2),
      const CategoryModel(id: 'cat-electronics', name: 'Electronics & Acc', nameAr: 'إلكترونيات وإكسسوارات', icon: 'smartphone', isEnabled: true, orderIndex: 3),
    ];

    final initialProducts = [
      const ProductModel(id: 'prod-ret-01', nameEn: 'Cotton Crewneck T-Shirt', nameAr: 'تيشيرت قطن فاخر', categoryId: 'cat-apparel', price: 250.0, cost: 110.0, stock: 50, barcode: '622100000001', trackQty: true),
      const ProductModel(id: 'prod-ret-02', nameEn: 'Slim Fit Denim Jeans', nameAr: 'بنطلون جينز كاجوال', categoryId: 'cat-apparel', price: 450.0, cost: 220.0, stock: 35, barcode: '622100000002', trackQty: true),
      const ProductModel(id: 'prod-ret-03', nameEn: 'Genuine Leather Wallet', nameAr: 'محفظة جلد طبيعي', categoryId: 'cat-general', price: 220.0, cost: 95.0, stock: 40, barcode: '622100000003', trackQty: true),
      const ProductModel(id: 'prod-ret-04', nameEn: 'Wireless Bluetooth Earbuds', nameAr: 'سماعات بلوتوث لاسلكية', categoryId: 'cat-electronics', price: 650.0, cost: 350.0, stock: 25, barcode: '622100000004', trackQty: true),
    ];

    for (final cat in initialCategories) {
      await catBox.put(cat.id, jsonEncode(cat.toJson()));
    }
    for (final p in initialProducts) {
      await prodBox.put(p.id, jsonEncode(p.toJson()));
    }
  }

  @override
  Future<List<ProductModel>> getProducts({
    String? categoryId,
    bool? onlyActive,
  }) async {
    try {
      await _ensureInitialSeed();
      final box = await _productsBox;
      final products = box.values
          .map((v) => ProductModel.fromJson(jsonDecode(v) as Map<String, dynamic>))
          .where((p) {
            if (categoryId != null && categoryId.isNotEmpty && p.categoryId != categoryId) {
              return false;
            }
            if (onlyActive == true && !p.isEnabled) {
              return false;
            }
            return true;
          })
          .toList();

      return products;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve products from local storage: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      await _ensureInitialSeed();
      final box = await _productsBox;
      final raw = box.get(id);
      if (raw == null) {
        throw CacheException(message: 'Product with ID "$id" not found.');
      }
      return ProductModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to retrieve product by ID "$id": $e');
    }
  }

  @override
  Future<ProductModel> getProductByBarcode(String barcode) async {
    try {
      await _ensureInitialSeed();
      final box = await _productsBox;
      final allProducts = box.values
          .map((v) => ProductModel.fromJson(jsonDecode(v) as Map<String, dynamic>));

      final product = allProducts.firstWhere(
        (p) => p.barcode.trim().toLowerCase() == barcode.trim().toLowerCase(),
        orElse: () => throw CacheException(
          message: 'Product with barcode "$barcode" not found in local catalog.',
        ),
      );

      return product;
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to retrieve product by barcode: $e');
    }
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      await _ensureInitialSeed();
      final box = await _productsBox;
      final lowerQuery = query.toLowerCase().trim();

      return box.values
          .map((v) => ProductModel.fromJson(jsonDecode(v) as Map<String, dynamic>))
          .where((p) =>
              p.nameEn.toLowerCase().contains(lowerQuery) ||
              (p.nameAr != null && p.nameAr!.toLowerCase().contains(lowerQuery)) ||
              p.barcode.toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to search products in local storage: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories({bool? onlyActive}) async {
    try {
      await _ensureInitialSeed();
      final box = await _categoriesBox;
      final categories = box.values
          .map((v) => CategoryModel.fromJson(jsonDecode(v) as Map<String, dynamic>))
          .where((c) {
            if (onlyActive == true && !c.isEnabled) {
              return false;
            }
            return true;
          })
          .toList();

      categories.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return categories;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve categories from local storage: $e');
    }
  }

  @override
  Future<void> saveProduct(ProductModel product) async {
    try {
      final box = await _productsBox;
      final encoded = jsonEncode(product.toJson());
      await box.put(product.id, encoded);
    } catch (e) {
      throw CacheException(message: 'Failed to save product "${product.nameEn}": $e');
    }
  }

  @override
  Future<void> deleteProduct(String id) async {
    try {
      final box = await _productsBox;
      if (!box.containsKey(id)) {
        throw CacheException(message: 'Cannot delete: Product ID "$id" does not exist.');
      }
      await box.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to delete product with ID "$id": $e');
    }
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    try {
      final box = await _categoriesBox;
      final encoded = jsonEncode(category.toJson());
      await box.put(category.id, encoded);
    } catch (e) {
      throw CacheException(message: 'Failed to save category "${category.name}": $e');
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      final box = await _categoriesBox;
      if (!box.containsKey(id)) {
        throw CacheException(message: 'Cannot delete: Category ID "$id" does not exist.');
      }
      await box.delete(id);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to delete category with ID "$id": $e');
    }
  }

  @override
  Future<void> toggleCategoryStatus(String id, bool isEnabled) async {
    try {
      final box = await _categoriesBox;
      final raw = box.get(id);
      if (raw == null) {
        throw CacheException(message: 'Category ID "$id" not found to toggle status.');
      }
      final cat = CategoryModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      final updated = CategoryModel.fromEntity(cat.copyWith(isEnabled: isEnabled));
      await box.put(id, jsonEncode(updated.toJson()));
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to toggle category status: $e');
    }
  }

  @override
  Future<void> updateStock(String productId, int quantityDelta) async {
    try {
      final box = await _productsBox;
      final raw = box.get(productId);
      if (raw == null) {
        throw CacheException(message: 'Product ID "$productId" not found to update stock.');
      }
      final product = ProductModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (!product.trackQty) return;

      final newStock = (product.stock + quantityDelta).clamp(0, 9999999);
      final updated = ProductModel.fromEntity(product.copyWith(stock: newStock));
      await box.put(productId, jsonEncode(updated.toJson()));
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(message: 'Failed to update stock for product "$productId": $e');
    }
  }
}
