import 'package:equatable/equatable.dart';
import 'atomic_business_components.dart';

class DepartmentNode extends Equatable {
  final String departmentId; // e.g. "dept_dentistry", "dept_pharmacy", "dept_cafe"
  final String nameEn;
  final String nameAr;
  final Set<AtomicCapability> capabilities;
  final Map<String, dynamic> customConfig; // 3D asset profiles, tax rates, printer targets

  const DepartmentNode({
    required this.departmentId,
    required this.nameEn,
    required this.nameAr,
    required this.capabilities,
    this.customConfig = const {},
  });

  bool has(AtomicCapability cap) => capabilities.contains(cap);

  @override
  List<Object?> get props => [departmentId, nameEn, nameAr, capabilities, customConfig];
}

class FacilityBlueprint extends Equatable {
  final String facilityId;
  final String facilityName;
  final List<DepartmentNode> departments;
  final Set<AtomicCapability> sharedGlobalCapabilities;

  const FacilityBlueprint({
    required this.facilityId,
    required this.facilityName,
    required this.departments,
    this.sharedGlobalCapabilities = const {
      AtomicCapability.unifiedCrossDepartmentCart,
      AtomicCapability.unifiedQueueDispatchHub,
    },
  });

  /// Dynamically queries if ANY active department provides a specific capability
  bool supports(AtomicCapability capability) =>
      sharedGlobalCapabilities.contains(capability) ||
      departments.any((d) => d.has(capability));

  DepartmentNode? getDepartment(String id) {
    try {
      return departments.firstWhere((d) => d.departmentId == id);
    } catch (_) {
      return null;
    }
  }

  @override
  List<Object?> get props => [facilityId, facilityName, departments, sharedGlobalCapabilities];
}
