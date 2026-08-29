import 'package:equatable/equatable.dart';

enum ToothState {
  healthy,
  decayed,
  filled,
  missing,
  crown,
  implant,
  rootCanal;

  static ToothState fromString(String? val) {
    if (val == null) return ToothState.healthy;
    final lower = val.toLowerCase().replaceAll('_', '');
    for (final s in ToothState.values) {
      if (s.name.toLowerCase() == lower) return s;
    }
    return ToothState.healthy;
  }
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

  const ToothChartEntry({
    required this.toothNumber,
    this.toothCode = '',
    this.isDeciduous = false,
    this.state = ToothState.healthy,
    this.pocketDepthMm = 2,
    this.surfaceNotation = '',
    this.notes,
  });

  String get effectiveToothCode =>
      toothCode.isNotEmpty ? toothCode : toothNumber.toString();

  ToothChartEntry copyWith({
    int? toothNumber,
    String? toothCode,
    bool? isDeciduous,
    ToothState? state,
    int? pocketDepthMm,
    String? surfaceNotation,
    String? notes,
  }) {
    return ToothChartEntry(
      toothNumber: toothNumber ?? this.toothNumber,
      toothCode: toothCode ?? this.toothCode,
      isDeciduous: isDeciduous ?? this.isDeciduous,
      state: state ?? this.state,
      pocketDepthMm: pocketDepthMm ?? this.pocketDepthMm,
      surfaceNotation: surfaceNotation ?? this.surfaceNotation,
      notes: notes ?? this.notes,
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
      ];
}
