import 'package:equatable/equatable.dart';

enum ToothState {
  healthy,
  decayed,
  filled,
  crown,
  rootCanal,
  missing,
  extracted,
  impacted,
  bridge,
  implant,
  fractured,
  specialCase;

  String get displayName {
    switch (this) {
      case ToothState.healthy:
        return 'Healthy';
      case ToothState.decayed:
        return 'Decayed / Cavity';
      case ToothState.filled:
        return 'Filled';
      case ToothState.crown:
        return 'Crowned';
      case ToothState.rootCanal:
        return 'Root Canal Treated';
      case ToothState.missing:
        return 'Missing';
      case ToothState.extracted:
        return 'Extracted';
      case ToothState.impacted:
        return 'Impacted';
      case ToothState.bridge:
        return 'Bridge';
      case ToothState.implant:
        return 'Implant';
      case ToothState.fractured:
        return 'Fractured';
      case ToothState.specialCase:
        return 'Special Case';
    }
  }

  static ToothState fromString(String? val) {
    if (val == null) return ToothState.healthy;
    final lower = val.toLowerCase().replaceAll('_', '').replaceAll(' ', '').replaceAll('/', '');
    for (final s in ToothState.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    if (lower.contains('decay') || lower.contains('cavity')) return ToothState.decayed;
    if (lower.contains('fill')) return ToothState.filled;
    if (lower.contains('crown')) return ToothState.crown;
    if (lower.contains('rootcanal') || lower.contains('endo')) return ToothState.rootCanal;
    if (lower.contains('extract')) return ToothState.extracted;
    if (lower.contains('impact')) return ToothState.impacted;
    if (lower.contains('bridge')) return ToothState.bridge;
    if (lower.contains('implant')) return ToothState.implant;
    if (lower.contains('fractur') || lower.contains('chip')) return ToothState.fractured;
    if (lower.contains('special') || lower.contains('anomaly')) return ToothState.specialCase;
    if (lower.contains('miss')) return ToothState.missing;
    return ToothState.healthy;
  }
}

enum SpecialCaseType {
  supernumerary,
  congenitallyMissing,
  retainedPrimary,
  fusedGeminated,
  customOther;

  String get displayName {
    switch (this) {
      case SpecialCaseType.supernumerary:
        return 'Supernumerary / Double Tooth';
      case SpecialCaseType.congenitallyMissing:
        return 'Congenitally Missing';
      case SpecialCaseType.retainedPrimary:
        return 'Retained Primary Tooth';
      case SpecialCaseType.fusedGeminated:
        return 'Fused / Geminated';
      case SpecialCaseType.customOther:
        return 'Custom / Other';
    }
  }

  static SpecialCaseType fromString(String? val) {
    if (val == null) return SpecialCaseType.customOther;
    final lower = val.toLowerCase().replaceAll('_', '').replaceAll(' ', '').replaceAll('/', '');
    for (final s in SpecialCaseType.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    if (lower.contains('super')) return SpecialCaseType.supernumerary;
    if (lower.contains('congenital')) return SpecialCaseType.congenitallyMissing;
    if (lower.contains('retain')) return SpecialCaseType.retainedPrimary;
    if (lower.contains('fuse') || lower.contains('gemin')) return SpecialCaseType.fusedGeminated;
    return SpecialCaseType.customOther;
  }
}

enum ToothCategory {
  incisor,
  canine,
  premolar,
  molar;

  String get displayName {
    switch (this) {
      case ToothCategory.incisor:
        return 'Incisor';
      case ToothCategory.canine:
        return 'Canine';
      case ToothCategory.premolar:
        return 'Premolar';
      case ToothCategory.molar:
        return 'Molar';
    }
  }
}

class ToothHistoryEntry extends Equatable {
  final DateTime timestamp;
  final ToothState state;
  final String description;
  final String? doctorName;
  final SpecialCaseType? specialCaseType;

  const ToothHistoryEntry({
    required this.timestamp,
    required this.state,
    this.description = '',
    this.doctorName,
    this.specialCaseType,
  });

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp.toIso8601String(),
        'state': state.name,
        'description': description,
        'doctorName': doctorName,
        'specialCaseType': specialCaseType?.name,
      };

  factory ToothHistoryEntry.fromJson(Map<String, dynamic> json) {
    return ToothHistoryEntry(
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      state: ToothState.fromString(json['state']?.toString()),
      description: json['description']?.toString() ?? '',
      doctorName: json['doctorName']?.toString(),
      specialCaseType: json['specialCaseType'] != null
          ? SpecialCaseType.fromString(json['specialCaseType']?.toString())
          : null,
    );
  }

  @override
  List<Object?> get props => [timestamp, state, description, doctorName, specialCaseType];
}

class ToothChartEntry extends Equatable {
  static const List<String> primaryToothCodes = [
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J',
    'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T'
  ];

  static List<String> get permanentToothCodes =>
      List.generate(32, (i) => (i + 1).toString());

  final String toothCode; // "1"-"32" (Permanent) or "A"-"T" (Primary/Deciduous)
  final int toothNumber; // Numeric helper (1-32 or ordinal index)
  final bool isDeciduous; // True for pediatric/primary dentition
  final ToothState state;
  final int pocketDepthMm; // 1 to 9mm Periodontal depth
  final String surfaceNotation; // e.g. "MODBL"
  final String? notes;
  final SpecialCaseType? specialCaseType;
  final List<ToothHistoryEntry> history;

  const ToothChartEntry({
    required this.toothNumber,
    this.toothCode = '',
    this.isDeciduous = false,
    this.state = ToothState.healthy,
    this.pocketDepthMm = 2,
    this.surfaceNotation = '',
    this.notes,
    this.specialCaseType,
    this.history = const [],
  });

  String get effectiveToothCode =>
      toothCode.isNotEmpty ? toothCode : toothNumber.toString();

  /// Maps standard codes to FDI 2-digit international ISO notation
  String get fdiNumber {
    final code = effectiveToothCode.toUpperCase();
    if (isDeciduous) {
      const pMap = {
        'A': '55', 'B': '54', 'C': '53', 'D': '52', 'E': '51',
        'F': '61', 'G': '62', 'H': '63', 'I': '64', 'J': '65',
        'K': '75', 'L': '74', 'M': '73', 'N': '72', 'O': '71',
        'P': '81', 'Q': '82', 'R': '83', 'S': '84', 'T': '85',
      };
      return pMap[code] ?? code;
    }
    final numVal = int.tryParse(code);
    if (numVal != null) {
      if (numVal >= 1 && numVal <= 8) return (10 + (9 - numVal)).toString();
      if (numVal >= 9 && numVal <= 16) return (20 + (numVal - 8)).toString();
      if (numVal >= 17 && numVal <= 24) return (30 + (25 - numVal)).toString();
      if (numVal >= 25 && numVal <= 32) return (40 + (numVal - 24)).toString();
    }
    return code;
  }

  /// Plain-language anatomical position description
  String get plainLanguagePosition {
    final code = effectiveToothCode.toUpperCase();
    if (isDeciduous) {
      const pNames = {
        'A': 'Upper Right 2nd Primary Molar (FDI 55)',
        'B': 'Upper Right 1st Primary Molar (FDI 54)',
        'C': 'Upper Right Primary Canine (FDI 53)',
        'D': 'Upper Right Primary Lateral Incisor (FDI 52)',
        'E': 'Upper Right Primary Central Incisor (FDI 51)',
        'F': 'Upper Left Primary Central Incisor (FDI 61)',
        'G': 'Upper Left Primary Lateral Incisor (FDI 62)',
        'H': 'Upper Left Primary Canine (FDI 63)',
        'I': 'Upper Left Primary 1st Molar (FDI 64)',
        'J': 'Upper Left Primary 2nd Molar (FDI 65)',
        'K': 'Lower Left Primary 2nd Molar (FDI 75)',
        'L': 'Lower Left Primary 1st Molar (FDI 74)',
        'M': 'Lower Left Primary Canine (FDI 73)',
        'N': 'Lower Left Primary Lateral Incisor (FDI 72)',
        'O': 'Lower Left Primary Central Incisor (FDI 71)',
        'P': 'Lower Right Primary Central Incisor (FDI 81)',
        'Q': 'Lower Right Primary Lateral Incisor (FDI 82)',
        'R': 'Lower Right Primary Canine (FDI 83)',
        'S': 'Lower Right Primary 1st Molar (FDI 84)',
        'T': 'Lower Right Primary 2nd Molar (FDI 85)',
      };
      return pNames[code] ?? 'Primary Tooth $code (FDI $fdiNumber)';
    }

    final numVal = int.tryParse(code);
    if (numVal != null) {
      const aNames = {
        1: 'Upper Right 3rd Molar / Wisdom (FDI 18)',
        2: 'Upper Right 2nd Molar (FDI 17)',
        3: 'Upper Right 1st Molar (FDI 16)',
        4: 'Upper Right 2nd Premolar (FDI 15)',
        5: 'Upper Right 1st Premolar (FDI 14)',
        6: 'Upper Right Canine / Cuspid (FDI 13)',
        7: 'Upper Right Lateral Incisor (FDI 12)',
        8: 'Upper Right Central Incisor (FDI 11)',
        9: 'Upper Left Central Incisor (FDI 21)',
        10: 'Upper Left Lateral Incisor (FDI 22)',
        11: 'Upper Left Canine / Cuspid (FDI 23)',
        12: 'Upper Left 1st Premolar (FDI 24)',
        13: 'Upper Left 2nd Premolar (FDI 25)',
        14: 'Upper Left 1st Molar (FDI 26)',
        15: 'Upper Left 2nd Molar (FDI 27)',
        16: 'Upper Left 3rd Molar / Wisdom (FDI 28)',
        17: 'Lower Left 3rd Molar / Wisdom (FDI 38)',
        18: 'Lower Left 2nd Molar (FDI 37)',
        19: 'Lower Left 1st Molar (FDI 36)',
        20: 'Lower Left 2nd Premolar (FDI 35)',
        21: 'Lower Left 1st Premolar (FDI 34)',
        22: 'Lower Left Canine / Cuspid (FDI 33)',
        23: 'Lower Left Lateral Incisor (FDI 32)',
        24: 'Lower Left Central Incisor (FDI 31)',
        25: 'Lower Right Central Incisor (FDI 41)',
        26: 'Lower Right Lateral Incisor (FDI 42)',
        27: 'Lower Right Canine / Cuspid (FDI 43)',
        28: 'Lower Right 1st Premolar (FDI 44)',
        29: 'Lower Right 2nd Premolar (FDI 45)',
        30: 'Lower Right 1st Molar (FDI 46)',
        31: 'Lower Right 2nd Molar (FDI 47)',
        32: 'Lower Right 3rd Molar / Wisdom (FDI 48)',
      };
      return aNames[numVal] ?? 'Tooth #$code (FDI $fdiNumber)';
    }

    return 'Tooth #$code (FDI $fdiNumber)';
  }

  ToothCategory get category {
    final code = effectiveToothCode.toUpperCase();
    if (isDeciduous) {
      if (['E', 'D', 'F', 'G', 'O', 'N', 'P', 'Q'].contains(code)) {
        return ToothCategory.incisor;
      }
      if (['C', 'H', 'M', 'R'].contains(code)) {
        return ToothCategory.canine;
      }
      return ToothCategory.molar;
    }
    final numVal = int.tryParse(code);
    if (numVal != null) {
      if ([7, 8, 9, 10, 23, 24, 25, 26].contains(numVal)) {
        return ToothCategory.incisor;
      }
      if ([6, 11, 22, 27].contains(numVal)) {
        return ToothCategory.canine;
      }
      if ([4, 5, 12, 13, 20, 21, 28, 29].contains(numVal)) {
        return ToothCategory.premolar;
      }
      return ToothCategory.molar;
    }
    return ToothCategory.incisor;
  }

  ToothChartEntry copyWith({
    int? toothNumber,
    String? toothCode,
    bool? isDeciduous,
    ToothState? state,
    int? pocketDepthMm,
    String? surfaceNotation,
    String? notes,
    SpecialCaseType? specialCaseType,
    List<ToothHistoryEntry>? history,
  }) {
    return ToothChartEntry(
      toothNumber: toothNumber ?? this.toothNumber,
      toothCode: toothCode ?? this.toothCode,
      isDeciduous: isDeciduous ?? this.isDeciduous,
      state: state ?? this.state,
      pocketDepthMm: pocketDepthMm ?? this.pocketDepthMm,
      surfaceNotation: surfaceNotation ?? this.surfaceNotation,
      notes: notes ?? this.notes,
      specialCaseType: specialCaseType ?? this.specialCaseType,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        toothNumber,
        toothCode,
        isDeciduous,
        state,
        pocketDepthMm,
        surfaceNotation,
        notes,
        specialCaseType,
        history,
      ];
}

