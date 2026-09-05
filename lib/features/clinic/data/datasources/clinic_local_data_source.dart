import 'dart:convert';
import 'package:hive/hive.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/medical_risk_factor.dart';
import '../models/clinic_visit_model.dart';
import '../models/dental_treatment_plan_model.dart';
import '../models/medical_risk_factor_model.dart';
import '../models/patient_profile_model.dart';
import '../models/tooth_chart_entry_model.dart';

abstract class ClinicLocalDataSource {
  // Patients
  Future<List<PatientProfileModel>> getPatients();
  Future<PatientProfileModel?> getPatientById(String id);
  Future<void> savePatient(PatientProfileModel patient);

  // Visits & Queue
  Future<List<ClinicVisitModel>> getVisits();
  Future<ClinicVisitModel?> getVisitById(String id);
  Future<void> saveVisit(ClinicVisitModel visit);

  // Dental Tooth Charts & Treatment Plans
  Future<List<ToothChartEntryModel>> getToothChart(String patientId);
  Future<void> saveToothChart(String patientId, List<ToothChartEntryModel> entries);
  Future<List<DentalTreatmentPlanModel>> getDentalPlans(String patientId);
  Future<void> saveDentalPlan(DentalTreatmentPlanModel plan);

  // Medical Risk Factors
  Future<List<MedicalRiskFactorModel>> getMedicalRiskFactors();
  Future<void> saveMedicalRiskFactors(List<MedicalRiskFactorModel> factors);
}

class ClinicLocalDataSourceImpl implements ClinicLocalDataSource {
  static const String patientsBoxName = 'empos_clinic_patients_box';
  static const String visitsBoxName = 'empos_clinic_visits_box';
  static const String toothChartsBoxName = 'empos_dental_tooth_charts_box';
  static const String dentalPlansBoxName = 'empos_dental_plans_box';
  static const String riskFactorsBoxName = 'empos_clinic_risk_factors_box';

  Future<Box<dynamic>> _openBox(String boxName) async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<dynamic>(boxName);
    }
    return await Hive.openBox<dynamic>(boxName);
  }

  Future<Box<dynamic>> get _patientsBox async => _openBox(patientsBoxName);
  Future<Box<dynamic>> get _visitsBox async => _openBox(visitsBoxName);
  Future<Box<dynamic>> get _toothChartsBox async => _openBox(toothChartsBoxName);
  Future<Box<dynamic>> get _dentalPlansBox async => _openBox(dentalPlansBoxName);
  Future<Box<dynamic>> get _riskFactorsBox async => _openBox(riskFactorsBoxName);

  // Patients
  @override
  Future<List<PatientProfileModel>> getPatients() async {
    try {
      final box = await _patientsBox;
      final List<PatientProfileModel> list = [];
      for (final raw in box.values) {
        if (raw != null) {
          if (raw is String) {
            list.add(PatientProfileModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)));
          } else if (raw is Map) {
            list.add(PatientProfileModel.fromJson(Map<String, dynamic>.from(raw)));
          }
        }
      }
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve clinic patients: $e');
    }
  }

  @override
  Future<PatientProfileModel?> getPatientById(String id) async {
    try {
      final box = await _patientsBox;
      final raw = box.get(id);
      if (raw == null) return null;
      if (raw is String) {
        return PatientProfileModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
      }
      return PatientProfileModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve patient $id: $e');
    }
  }

  @override
  Future<void> savePatient(PatientProfileModel patient) async {
    try {
      final box = await _patientsBox;
      await box.put(patient.id, jsonEncode(patient.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save patient: $e');
    }
  }

  // Visits
  @override
  Future<List<ClinicVisitModel>> getVisits() async {
    try {
      final box = await _visitsBox;
      final List<ClinicVisitModel> list = [];
      for (final raw in box.values) {
        if (raw != null) {
          if (raw is String) {
            list.add(ClinicVisitModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map)));
          } else if (raw is Map) {
            list.add(ClinicVisitModel.fromJson(Map<String, dynamic>.from(raw)));
          }
        }
      }
      list.sort((a, b) => a.checkInTime.compareTo(b.checkInTime));
      return list;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve clinic visits: $e');
    }
  }

  @override
  Future<ClinicVisitModel?> getVisitById(String id) async {
    try {
      final box = await _visitsBox;
      final raw = box.get(id);
      if (raw == null) return null;
      if (raw is String) {
        return ClinicVisitModel.fromJson(Map<String, dynamic>.from(jsonDecode(raw) as Map));
      }
      return ClinicVisitModel.fromJson(Map<String, dynamic>.from(raw as Map));
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve visit $id: $e');
    }
  }

  @override
  Future<void> saveVisit(ClinicVisitModel visit) async {
    try {
      final box = await _visitsBox;
      await box.put(visit.id, jsonEncode(visit.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save visit: $e');
    }
  }

  // Tooth Charts
  @override
  Future<List<ToothChartEntryModel>> getToothChart(String patientId) async {
    try {
      final box = await _toothChartsBox;
      final raw = box.get(patientId);
      if (raw == null) return [];
      final List<dynamic> decoded = raw is String ? jsonDecode(raw) as List<dynamic> : raw as List<dynamic>;
      return decoded.map((e) => ToothChartEntryModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve tooth chart for patient $patientId: $e');
    }
  }

  @override
  Future<void> saveToothChart(String patientId, List<ToothChartEntryModel> entries) async {
    try {
      final box = await _toothChartsBox;
      final listJson = entries.map((e) => e.toJson()).toList();
      await box.put(patientId, jsonEncode(listJson));
    } catch (e) {
      throw CacheException(message: 'Failed to save tooth chart: $e');
    }
  }

  // Dental Plans
  @override
  Future<List<DentalTreatmentPlanModel>> getDentalPlans(String patientId) async {
    try {
      final box = await _dentalPlansBox;
      final List<DentalTreatmentPlanModel> plans = [];
      for (final raw in box.values) {
        if (raw != null) {
          final Map<String, dynamic> json = raw is String
              ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
              : Map<String, dynamic>.from(raw as Map);
          final plan = DentalTreatmentPlanModel.fromJson(json);
          if (plan.patientId == patientId) {
            plans.add(plan);
          }
        }
      }
      plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return plans;
    } catch (e) {
      throw CacheException(message: 'Failed to retrieve dental plans for patient $patientId: $e');
    }
  }

  @override
  Future<void> saveDentalPlan(DentalTreatmentPlanModel plan) async {
    try {
      final box = await _dentalPlansBox;
      await box.put(plan.id, jsonEncode(plan.toJson()));
    } catch (e) {
      throw CacheException(message: 'Failed to save dental plan: $e');
    }
  }

  // Medical Risk Factors
  @override
  Future<List<MedicalRiskFactorModel>> getMedicalRiskFactors() async {
    try {
      final box = await _riskFactorsBox;
      if (box.isEmpty) {
        final defaultList = MedicalRiskFactor.defaultFactors
            .map((e) => MedicalRiskFactorModel.fromEntity(e))
            .toList();
        await saveMedicalRiskFactors(defaultList);
        return defaultList;
      }
      final List<MedicalRiskFactorModel> list = [];
      for (final raw in box.values) {
        if (raw != null) {
          final Map<String, dynamic> json = raw is String
              ? Map<String, dynamic>.from(jsonDecode(raw) as Map)
              : Map<String, dynamic>.from(raw as Map);
          list.add(MedicalRiskFactorModel.fromJson(json));
        }
      }
      return list;
    } catch (e) {
      return MedicalRiskFactor.defaultFactors
          .map((e) => MedicalRiskFactorModel.fromEntity(e))
          .toList();
    }
  }

  @override
  Future<void> saveMedicalRiskFactors(List<MedicalRiskFactorModel> factors) async {
    try {
      final box = await _riskFactorsBox;
      await box.clear();
      for (final factor in factors) {
        await box.put(factor.id, jsonEncode(factor.toJson()));
      }
    } catch (e) {
      throw CacheException(message: 'Failed to save medical risk factors: $e');
    }
  }
}
