import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class MedicalRiskFactor extends Equatable {
  final String id;
  final String label;
  final int colorValue;
  final String iconName;
  final bool isEnabled;

  const MedicalRiskFactor({
    required this.id,
    required this.label,
    required this.colorValue,
    required this.iconName,
    this.isEnabled = true,
  });

  MedicalRiskFactor copyWith({
    String? id,
    String? label,
    int? colorValue,
    String? iconName,
    bool? isEnabled,
  }) {
    return MedicalRiskFactor(
      id: id ?? this.id,
      label: label ?? this.label,
      colorValue: colorValue ?? this.colorValue,
      iconName: iconName ?? this.iconName,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  static const List<MedicalRiskFactor> defaultFactors = [
    MedicalRiskFactor(
      id: 'diabetes',
      label: 'Diabetes',
      colorValue: 0xFFEAB308, // Colors.amber
      iconName: 'activity',
      isEnabled: true,
    ),
    MedicalRiskFactor(
      id: 'smoking',
      label: 'Smoking / Tobacco',
      colorValue: 0xFFF97316, // Colors.orange
      iconName: 'cigarette',
      isEnabled: true,
    ),
    MedicalRiskFactor(
      id: 'hypertension',
      label: 'Hypertension (High BP)',
      colorValue: 0xFFEF4444, // Colors.red
      iconName: 'heartPulse',
      isEnabled: true,
    ),
    MedicalRiskFactor(
      id: 'heart_disease',
      label: 'Heart Disease',
      colorValue: 0xFFF43F5E, // Colors.rose
      iconName: 'heart',
      isEnabled: true,
    ),
    MedicalRiskFactor(
      id: 'bleeding_risk',
      label: 'Bleeding Risk / Anticoagulants',
      colorValue: 0xFF06B6D4, // Colors.cyan
      iconName: 'droplet',
      isEnabled: true,
    ),
    MedicalRiskFactor(
      id: 'asthma_respiratory',
      label: 'Asthma / Respiratory',
      colorValue: 0xFF6366F1, // Colors.indigo
      iconName: 'wind',
      isEnabled: true,
    ),
    MedicalRiskFactor(
      id: 'pregnancy_nursing',
      label: 'Pregnancy / Nursing',
      colorValue: 0xFFA855F7, // Colors.purple
      iconName: 'baby',
      isEnabled: true,
    ),
  ];

  Color get color => Color(colorValue);

  IconData get iconData {
    switch (iconName) {
      case 'cigarette':
        return LucideIcons.cigarette;
      case 'heartPulse':
        return LucideIcons.heartPulse;
      case 'heart':
        return LucideIcons.heart;
      case 'droplet':
        return LucideIcons.droplet;
      case 'wind':
        return LucideIcons.wind;
      case 'baby':
        return LucideIcons.baby;
      case 'pill':
        return LucideIcons.pill;
      case 'shieldAlert':
        return LucideIcons.shieldAlert;
      case 'alertTriangle':
        return LucideIcons.triangleAlert;
      case 'dna':
        return LucideIcons.dna;
      case 'bone':
        return LucideIcons.bone;
      case 'eye':
        return LucideIcons.eye;
      case 'brain':
        return LucideIcons.brain;
      case 'apple':
        return LucideIcons.apple;
      case 'activity':
      default:
        return LucideIcons.activity;
    }
  }

  @override
  List<Object?> get props => [id, label, colorValue, iconName, isEnabled];
}
