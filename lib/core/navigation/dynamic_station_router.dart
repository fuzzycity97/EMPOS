import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../config/atomic_business_components.dart';
import '../config/facility_blueprint.dart';
import '../../features/auth/domain/entities/user_role.dart';

enum StationDestination {
  clinicalConsultation,
  diagnosticRadiology,
  pharmacyDispensing,
  tableFloorMap,
  appointmentScheduling,
  universalReceptionQueue,
  retailPosCheckout,
}

class StationTabRoute {
  final StationDestination destination;
  final String titleEn;
  final String titleAr;
  final IconData icon;
  final String departmentId;
  final Set<AtomicCapability> requiredCapabilities;
  final Set<UserRole> allowedRoles;

  const StationTabRoute({
    required this.destination,
    required this.titleEn,
    required this.titleAr,
    required this.icon,
    required this.departmentId,
    required this.requiredCapabilities,
    required this.allowedRoles,
  });
}

class DynamicStationRouter {
  DynamicStationRouter._();

  /// Resolves the visible navigation station tabs dynamically based on the active
  /// [FacilityBlueprint], active [DepartmentNode], and current [UserRole].
  static List<StationTabRoute> resolveRoutes({
    required FacilityBlueprint blueprint,
    required String activeDepartmentId,
    required UserRole userRole,
  }) {
    final department = blueprint.getDepartment(activeDepartmentId) ??
        (blueprint.departments.isNotEmpty ? blueprint.departments.first : null);

    if (department == null) return const [];

    final routes = <StationTabRoute>[];

    // 1. Universal Reception Queue Hub
    if (blueprint.supports(AtomicCapability.unifiedQueueDispatchHub) ||
        department.has(AtomicCapability.unifiedQueueDispatchHub)) {
      if (_hasRoleAccess(userRole, {UserRole.admin, UserRole.manager, UserRole.receptionist})) {
        routes.add(
          StationTabRoute(
            destination: StationDestination.universalReceptionQueue,
            titleEn: 'Reception & Queue',
            titleAr: 'الاستقبال وقائمة الانتظار',
            icon: Icons.confirmation_number_outlined,
            departmentId: department.departmentId,
            requiredCapabilities: {AtomicCapability.unifiedQueueDispatchHub},
            allowedRoles: {UserRole.admin, UserRole.manager, UserRole.receptionist},
          ),
        );
      }
    }

    // 2. Clinical Consultation & 3D Anatomical Station
    if (department.has(AtomicCapability.clinicalEncounter3dCanvas) ||
        department.has(AtomicCapability.specializedClinicalCharting)) {
      if (_hasRoleAccess(userRole, {UserRole.admin, UserRole.manager, UserRole.doctor})) {
        routes.add(
          StationTabRoute(
            destination: StationDestination.clinicalConsultation,
            titleEn: 'Doctor Station & 3D Canvas',
            titleAr: 'محطة الطبيب والفحص ثلاثي الأبعاد',
            icon: LucideIcons.stethoscope,
            departmentId: department.departmentId,
            requiredCapabilities: {AtomicCapability.clinicalEncounter3dCanvas},
            allowedRoles: {UserRole.admin, UserRole.manager, UserRole.doctor},
          ),
        );
      }
    }

    // 3. Diagnostic Radiology Lightbox & Lab Station
    if (department.has(AtomicCapability.diagnosticRadiologyLightbox) ||
        department.has(AtomicCapability.laboratorySpecimenTracking)) {
      if (_hasRoleAccess(userRole, {UserRole.admin, UserRole.manager, UserRole.doctor, UserRole.technician})) {
        routes.add(
          StationTabRoute(
            destination: StationDestination.diagnosticRadiology,
            titleEn: 'Imaging Lightbox & Lab',
            titleAr: 'عارض الأشعة والتحاليل',
            icon: Icons.science_outlined,
            departmentId: department.departmentId,
            requiredCapabilities: {AtomicCapability.diagnosticRadiologyLightbox},
            allowedRoles: {UserRole.admin, UserRole.manager, UserRole.doctor, UserRole.technician},
          ),
        );
      }
    }

    // 4. Pharmacy & FEFO Batch Dispensing Station
    if (department.has(AtomicCapability.fefoBatchInventory)) {
      if (_hasRoleAccess(userRole, {UserRole.admin, UserRole.manager, UserRole.cashier, UserRole.receptionist})) {
        routes.add(
          StationTabRoute(
            destination: StationDestination.pharmacyDispensing,
            titleEn: 'FEFO Drug Dispensing',
            titleAr: 'صرف الأدوية وتتبع الصلاحية',
            icon: Icons.medication_outlined,
            departmentId: department.departmentId,
            requiredCapabilities: {AtomicCapability.fefoBatchInventory},
            allowedRoles: {UserRole.admin, UserRole.manager, UserRole.cashier, UserRole.receptionist},
          ),
        );
      }
    }

    // 5. Table Floor Map & KDS Station
    if (department.has(AtomicCapability.tableFloorMapManagement)) {
      if (_hasRoleAccess(userRole, {UserRole.admin, UserRole.manager, UserRole.cashier})) {
        routes.add(
          StationTabRoute(
            destination: StationDestination.tableFloorMap,
            titleEn: 'Table Floor Map & KDS',
            titleAr: 'خريطة الطاولات وشاشات المطبخ',
            icon: Icons.table_restaurant_outlined,
            departmentId: department.departmentId,
            requiredCapabilities: {AtomicCapability.tableFloorMapManagement},
            allowedRoles: {UserRole.admin, UserRole.manager, UserRole.cashier},
          ),
        );
      }
    }

    // 6. Time-Slot Appointment Scheduling
    if (department.has(AtomicCapability.timeSlotAppointmentEngine)) {
      if (_hasRoleAccess(userRole, {UserRole.admin, UserRole.manager, UserRole.receptionist, UserRole.doctor})) {
        routes.add(
          StationTabRoute(
            destination: StationDestination.appointmentScheduling,
            titleEn: 'Calendar & Slots',
            titleAr: 'جدول المواعيد والحجوزات',
            icon: Icons.calendar_month_outlined,
            departmentId: department.departmentId,
            requiredCapabilities: {AtomicCapability.timeSlotAppointmentEngine},
            allowedRoles: {UserRole.admin, UserRole.manager, UserRole.receptionist, UserRole.doctor},
          ),
        );
      }
    }

    // 7. Retail POS & Barcode Checkout Station
    if (department.has(AtomicCapability.standardRetailBarcoding) ||
        blueprint.supports(AtomicCapability.unifiedCrossDepartmentCart)) {
      routes.add(
        StationTabRoute(
          destination: StationDestination.retailPosCheckout,
          titleEn: 'POS & Cross-Billing',
          titleAr: 'نقطة البيع والفوترة الموحدة',
          icon: Icons.point_of_sale_outlined,
          departmentId: department.departmentId,
          requiredCapabilities: {AtomicCapability.standardRetailBarcoding},
          allowedRoles: {UserRole.admin, UserRole.manager, UserRole.cashier, UserRole.receptionist},
        ),
      );
    }

    return routes;
  }

  static bool _hasRoleAccess(UserRole userRole, Set<UserRole> allowedRoles) {
    if (userRole == UserRole.admin || userRole == UserRole.manager) {
      return true; // Admin and Manager have global unrestricted access
    }
    return allowedRoles.contains(userRole);
  }
}
