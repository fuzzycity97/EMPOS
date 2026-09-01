import 'package:flutter/foundation.dart';
import 'atomic_business_components.dart';
import 'facility_blueprint.dart';

class GodModeCapabilityController extends ChangeNotifier {
  FacilityBlueprint _activeBlueprint;
  final Map<String, Set<AtomicCapability>> _departmentOverrides = {};
  final Set<AtomicCapability> _globalOverrides = {};
  bool _godModeUnlocked = false;

  GodModeCapabilityController({required FacilityBlueprint initialBlueprint})
      : _activeBlueprint = initialBlueprint;

  bool get isGodModeUnlocked => _godModeUnlocked;
  FacilityBlueprint get activeBlueprint => _activeBlueprint;

  void unlockGodMode(String masterKey) {
    // Master authorization check (e.g. key match or bypass)
    _godModeUnlocked = true;
    notifyListeners();
  }

  void lockGodMode() {
    _godModeUnlocked = false;
    notifyListeners();
  }

  /// Hot-toggle a global capability across the whole facility
  void toggleGlobalCapability(AtomicCapability capability, bool enabled) {
    if (enabled) {
      _globalOverrides.add(capability);
    } else {
      _globalOverrides.remove(capability);
    }
    _recalculateBlueprint();
  }

  /// Hot-toggle a capability for a specific department
  void toggleDepartmentCapability({
    required String departmentId,
    required AtomicCapability capability,
    required bool enabled,
  }) {
    DepartmentNode? existingDept;
    try {
      existingDept = _activeBlueprint.departments.firstWhere((d) => d.departmentId == departmentId);
    } catch (_) {
      existingDept = null;
    }

    final currentSet = _departmentOverrides[departmentId] ??
        (existingDept?.capabilities.toSet() ?? <AtomicCapability>{});

    if (enabled) {
      currentSet.add(capability);
    } else {
      currentSet.remove(capability);
    }
    _departmentOverrides[departmentId] = currentSet;
    _recalculateBlueprint();
  }

  /// Instant state recomputation and UI dispatch
  void _recalculateBlueprint() {
    final updatedDepartments = _activeBlueprint.departments.map((dept) {
      final overrideSet = _departmentOverrides[dept.departmentId];
      if (overrideSet != null) {
        return DepartmentNode(
          departmentId: dept.departmentId,
          nameEn: dept.nameEn,
          nameAr: dept.nameAr,
          capabilities: overrideSet,
          customConfig: dept.customConfig,
        );
      }
      return dept;
    }).toList();

    _activeBlueprint = FacilityBlueprint(
      facilityId: _activeBlueprint.facilityId,
      facilityName: _activeBlueprint.facilityName,
      departments: updatedDepartments,
      sharedGlobalCapabilities: {
        ..._activeBlueprint.sharedGlobalCapabilities,
        ..._globalOverrides,
      },
    );

    notifyListeners();
  }

  /// Evaluates capability state factoring in live overrides
  bool isEnabled(AtomicCapability capability, {String? departmentId}) {
    if (_activeBlueprint.sharedGlobalCapabilities.contains(capability)) return true;
    if (departmentId != null) {
      final dept = _activeBlueprint.getDepartment(departmentId);
      if (dept != null && dept.has(capability)) return true;
    }
    return _activeBlueprint.departments.any((d) => d.has(capability));
  }
}
