import 'dart:convert';
import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.category,
    required super.amount,
    required super.date,
    required super.description,
    super.isPaidFromDrawer = false,
    super.shiftId,
  });

  factory ExpenseModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse ExpenseModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return ExpenseModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return ExpenseModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for ExpenseModel: ${raw.runtimeType}');
  }

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final catStr = json['category']?.toString().toLowerCase();
    ExpenseCategory category = ExpenseCategory.other;
    if (catStr == 'rent') {
      category = ExpenseCategory.rent;
    } else if (catStr == 'utilities') {
      category = ExpenseCategory.utilities;
    } else if (catStr == 'logistics') {
      category = ExpenseCategory.logistics;
    } else if (catStr == 'maintenance') {
      category = ExpenseCategory.maintenance;
    } else if (catStr == 'supplies') {
      category = ExpenseCategory.supplies;
    }

    return ExpenseModel(
      id: json['id']?.toString() ?? '',
      category: category,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      description: json['description']?.toString() ?? '',
      isPaidFromDrawer: json['isPaidFromDrawer'] as bool? ?? false,
      shiftId: json['shiftId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'isPaidFromDrawer': isPaidFromDrawer,
      'shiftId': shiftId,
    };
  }

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      category: entity.category,
      amount: entity.amount,
      date: entity.date,
      description: entity.description,
      isPaidFromDrawer: entity.isPaidFromDrawer,
      shiftId: entity.shiftId,
    );
  }

  @override
  ExpenseModel copyWith({
    String? id,
    ExpenseCategory? category,
    double? amount,
    DateTime? date,
    String? description,
    bool? isPaidFromDrawer,
    String? shiftId,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      isPaidFromDrawer: isPaidFromDrawer ?? this.isPaidFromDrawer,
      shiftId: shiftId ?? this.shiftId,
    );
  }
}
