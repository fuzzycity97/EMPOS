import 'package:equatable/equatable.dart';

class CashAdvance extends Equatable {
  final String id;
  final String employeeId;
  final String? employeeName;
  final double amount;
  final DateTime date;
  final String reason;
  final String? shiftId;
  final bool isDeducted;

  const CashAdvance({
    required this.id,
    required this.employeeId,
    this.employeeName,
    required this.amount,
    required this.date,
    required this.reason,
    this.shiftId,
    this.isDeducted = false,
  });

  CashAdvance copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    double? amount,
    DateTime? date,
    String? reason,
    String? shiftId,
    bool? isDeducted,
  }) {
    return CashAdvance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      shiftId: shiftId ?? this.shiftId,
      isDeducted: isDeducted ?? this.isDeducted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        employeeId,
        employeeName,
        amount,
        date,
        reason,
        shiftId,
        isDeducted,
      ];
}
