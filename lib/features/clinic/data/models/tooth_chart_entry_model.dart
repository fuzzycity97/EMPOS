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
  });

  factory ToothChartEntryModel.fromJson(Map<String, dynamic> json) {
    final tNum = (json['toothNumber'] as num?)?.toInt() ?? 1;
    final tCode = json['toothCode']?.toString() ?? tNum.toString();
    final isDec = json['isDeciduous'] == true ||
        ToothChartEntry.primaryToothCodes.contains(tCode.toUpperCase());

    return ToothChartEntryModel(
      toothNumber: tNum,
      toothCode: tCode,
      isDeciduous: isDec,
      state: ToothState.fromString(json['state']?.toString()),
      pocketDepthMm: (json['pocketDepthMm'] as num?)?.toInt() ?? 2,
      surfaceNotation: json['surfaceNotation']?.toString() ?? '',
      notes: json['notes']?.toString(),
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
    );
  }
}
