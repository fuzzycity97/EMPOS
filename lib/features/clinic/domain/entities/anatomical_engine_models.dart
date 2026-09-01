import 'dart:ui';
import 'package:flutter/material.dart';

enum AnatomicalSeverity { normal, mild, moderate, severe, critical, treated }

class Anatomical3dVector {
  final double x;
  final double y;
  final double z;

  const Anatomical3dVector(this.x, this.y, this.z);
}

class AnatomicalRegionData {
  final String id;
  final String labelEn;
  final String labelAr;
  final Anatomical3dVector centroid;
  final double radius;
  final AnatomicalSeverity severity;
  final Map<String, dynamic> metadata;

  const AnatomicalRegionData({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    required this.centroid,
    required this.radius,
    this.severity = AnatomicalSeverity.normal,
    this.metadata = const {},
  });

  AnatomicalRegionData copyWith({
    AnatomicalSeverity? severity,
    Map<String, dynamic>? metadata,
  }) {
    return AnatomicalRegionData(
      id: id,
      labelEn: labelEn,
      labelAr: labelAr,
      centroid: centroid,
      radius: radius,
      severity: severity ?? this.severity,
      metadata: metadata ?? this.metadata,
    );
  }
}

class Specialty3DProfile {
  final String verticalId;
  final String titleEn;
  final String titleAr;
  final List<AnatomicalRegionData> regions;
  final Map<String, Anatomical3dVector> cameraPresets;
  final double defaultFov;

  const Specialty3DProfile({
    required this.verticalId,
    required this.titleEn,
    required this.titleAr,
    required this.regions,
    required this.cameraPresets,
    this.defaultFov = 45.0,
  });
}
