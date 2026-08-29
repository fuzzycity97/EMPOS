import 'package:equatable/equatable.dart';

enum ShiftStatus { open, closed }

class Shift extends Equatable {
  final String id;
  final String cashierId;
  final String? cashierName;
  final DateTime startTime;
  final DateTime? endTime;
  final double startingCash;
  final double expectedCash;
  final double? actualCash;
  final double difference; // actualCash - expectedCash
  final ShiftStatus status;
  final String? notes;

  const Shift({
    required this.id,
    required this.cashierId,
    this.cashierName,
    required this.startTime,
    this.endTime,
    required this.startingCash,
    this.expectedCash = 0.0,
    this.actualCash,
    this.difference = 0.0,
    this.status = ShiftStatus.open,
    this.notes,
  });

  bool get isOpen => status == ShiftStatus.open;
  bool get isClosed => status == ShiftStatus.closed;

  bool get isBalanced => difference == 0.0;
  bool get isShortage => difference < 0.0;
  bool get isSurplus => difference > 0.0;

  Shift copyWith({
    String? id,
    String? cashierId,
    String? cashierName,
    DateTime? startTime,
    DateTime? endTime,
    double? startingCash,
    double? expectedCash,
    double? actualCash,
    double? difference,
    ShiftStatus? status,
    String? notes,
  }) {
    return Shift(
      id: id ?? this.id,
      cashierId: cashierId ?? this.cashierId,
      cashierName: cashierName ?? this.cashierName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      startingCash: startingCash ?? this.startingCash,
      expectedCash: expectedCash ?? this.expectedCash,
      actualCash: actualCash ?? this.actualCash,
      difference: difference ?? this.difference,
      status: status ?? this.status,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        cashierId,
        cashierName,
        startTime,
        endTime,
        startingCash,
        expectedCash,
        actualCash,
        difference,
        status,
        notes,
      ];
}
