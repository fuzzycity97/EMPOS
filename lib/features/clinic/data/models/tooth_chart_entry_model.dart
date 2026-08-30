import '../../domain/entities/tooth_chart_entry.dart';

class ToothChartEntryModel extends ToothChartEntry {
  const ToothChartEntryModel({
    required super.toothNumber,
    super.toothCode,
    super.isDeciduous = false,
    super.state = ToothState.healthy,
    super.pocketDepthMm = 2,
    super.surfaceNotation = '',
    super.notes,
    super.specialCaseType,
    super.history = const [],
  });

  factory ToothChartEntryModel.fromJson(Map<String, dynamic> json) {
    final tNum = (json['toothNumber'] as num?)?.toInt() ?? 1;
    final tCode = json['toothCode']?.toString() ?? tNum.toString();
    final isDec = json['isDeciduous'] == true ||
        ToothChartEntry.primaryToothCodes.contains(tCode.toUpperCase());

    final histRaw = json['history'] as List<dynamic>?;
    final historyList = histRaw != null
        ? histRaw
            .whereType<Map<String, dynamic>>()
            .map((h) => ToothHistoryEntry.fromJson(h))
            .toList()
        : <ToothHistoryEntry>[];

    return ToothChartEntryModel(
      toothNumber: tNum,
      toothCode: tCode,
      isDeciduous: isDec,
      state: ToothState.fromString(json['state']?.toString()),
      pocketDepthMm: (json['pocketDepthMm'] as num?)?.toInt() ?? 2,
      surfaceNotation: json['surfaceNotation']?.toString() ?? '',
      notes: json['notes']?.toString(),
      specialCaseType: json['specialCaseType'] != null
          ? SpecialCaseType.fromString(json['specialCaseType']?.toString())
          : null,
      history: historyList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'toothNumber': toothNumber,
      'toothCode': toothCode,
      'isDeciduous': isDeciduous,
      'state': state.name,
      'pocketDepthMm': pocketDepthMm,
      'surfaceNotation': surfaceNotation,
      'notes': notes,
      'specialCaseType': specialCaseType?.name,
      'history': history.map((h) => h.toJson()).toList(),
    };
  }

  factory ToothChartEntryModel.fromEntity(ToothChartEntry entity) {
    return ToothChartEntryModel(
      toothNumber: entity.toothNumber,
      toothCode: entity.toothCode,
      isDeciduous: entity.isDeciduous,
      state: entity.state,
      pocketDepthMm: entity.pocketDepthMm,
      surfaceNotation: entity.surfaceNotation,
      notes: entity.notes,
      specialCaseType: entity.specialCaseType,
      history: entity.history,
    );
  }
}

