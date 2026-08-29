import '../../domain/entities/patient_profile.dart';

class PatientProfileModel extends PatientProfile {
  const PatientProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    super.dateOfBirth,
    super.gender,
    super.bloodType,
    super.allergies = const [],
    super.chronicConditions = const [],
    super.currentMedications = const [],
    super.insuranceProvider,
    super.policyNumber,
    super.defaultCopayPercentage = 0.0,
    required super.createdAt,
  });

  factory PatientProfileModel.fromJson(Map<String, dynamic> json) {
    return PatientProfileModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString() ?? json['dob']?.toString(),
      gender: json['gender']?.toString(),
      bloodType: json['bloodType']?.toString(),
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      chronicConditions: (json['chronicConditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      currentMedications: (json['currentMedications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      insuranceProvider: json['insuranceProvider']?.toString() ?? json['insurance']?.toString(),
      policyNumber: json['policyNumber']?.toString(),
      defaultCopayPercentage: (json['defaultCopayPercentage'] as num?)?.toDouble() ?? 0.0,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'bloodType': bloodType,
      'allergies': allergies,
      'chronicConditions': chronicConditions,
      'currentMedications': currentMedications,
      'insuranceProvider': insuranceProvider,
      'policyNumber': policyNumber,
      'defaultCopayPercentage': defaultCopayPercentage,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PatientProfileModel.fromEntity(PatientProfile entity) {
    return PatientProfileModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      dateOfBirth: entity.dateOfBirth,
      gender: entity.gender,
      bloodType: entity.bloodType,
      allergies: entity.allergies,
      chronicConditions: entity.chronicConditions,
      currentMedications: entity.currentMedications,
      insuranceProvider: entity.insuranceProvider,
      policyNumber: entity.policyNumber,
      defaultCopayPercentage: entity.defaultCopayPercentage,
      createdAt: entity.createdAt,
    );
  }
}

typedef PatientModel = PatientProfileModel;
