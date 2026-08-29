import 'package:equatable/equatable.dart';

class PatientProfile extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? dateOfBirth;
  final String? gender;
  final String? bloodType;
  final List<String> allergies;
  final List<String> chronicConditions;
  final List<String> currentMedications;
  final String? insuranceProvider;
  final String? policyNumber;
  final double defaultCopayPercentage;
  final DateTime createdAt;

  const PatientProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.dateOfBirth,
    this.gender,
    this.bloodType,
    this.allergies = const [],
    this.chronicConditions = const [],
    this.currentMedications = const [],
    this.insuranceProvider,
    this.policyNumber,
    this.defaultCopayPercentage = 0.0,
    required this.createdAt,
  });

  PatientProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? dateOfBirth,
    String? gender,
    String? bloodType,
    List<String>? allergies,
    List<String>? chronicConditions,
    List<String>? currentMedications,
    String? insuranceProvider,
    String? policyNumber,
    double? defaultCopayPercentage,
    DateTime? createdAt,
  }) {
    return PatientProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      chronicConditions: chronicConditions ?? this.chronicConditions,
      currentMedications: currentMedications ?? this.currentMedications,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      policyNumber: policyNumber ?? this.policyNumber,
      defaultCopayPercentage: defaultCopayPercentage ?? this.defaultCopayPercentage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        dateOfBirth,
        gender,
        bloodType,
        allergies,
        chronicConditions,
        currentMedications,
        insuranceProvider,
        policyNumber,
        defaultCopayPercentage,
        createdAt,
      ];
}

typedef Patient = PatientProfile;
