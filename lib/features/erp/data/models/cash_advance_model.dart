import 'dart:convert';
import '../../domain/entities/cash_advance.dart';

class CashAdvanceModel extends CashAdvance {
  const CashAdvanceModel({
    required super.id,
    required super.employeeId,
    super.employeeName,
    required super.amount,
    required super.date,
    required super.reason,
    super.shiftId,
    super.isDeducted = false,
  });

  factory CashAdvanceModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse CashAdvanceModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return CashAdvanceModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return CashAdvanceModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for CashAdvanceModel: ${raw.runtimeType}');
  }

  factory CashAdvanceModel.fromJson(Map<String, dynamic> json) {
    return CashAdvanceModel(
      id: json['id']?.toString() ?? '',
      employeeId: json['employeeId']?.toString() ?? '',
      employeeName: json['employeeName']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      reason: json['reason']?.toString() ?? '',
      shiftId: json['shiftId']?.toString(),
      isDeducted: json['isDeducted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'amount': amount,
      'date': date.toIso8601String(),
      'reason': reason,
      'shiftId': shiftId,
      'isDeducted': isDeducted,
    };
  }

  factory CashAdvanceModel.fromEntity(CashAdvance entity) {
    return CashAdvanceModel(
      id: entity.id,
      employeeId: entity.employeeId,
      employeeName: entity.employeeName,
      amount: entity.amount,
      date: entity.date,
      reason: entity.reason,
      shiftId: entity.shiftId,
      isDeducted: entity.isDeducted,
    );
  }

  @override
  CashAdvanceModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    double? amount,
    DateTime? date,
    String? reason,
    String? shiftId,
    bool? isDeducted,
  }) {
    return CashAdvanceModel(
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
}
