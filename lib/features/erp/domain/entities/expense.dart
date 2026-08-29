import 'package:equatable/equatable.dart';

enum ExpenseCategory {
  rent,
  utilities,
  logistics,
  maintenance,
  supplies,
  other,
}

class Expense extends Equatable {
  final String id;
  final ExpenseCategory category;
  final double amount;
  final DateTime date;
  final String description;
  final bool isPaidFromDrawer;
  final String? shiftId;

  const Expense({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
    this.isPaidFromDrawer = false,
    this.shiftId,
  });

  Expense copyWith({
    String? id,
    ExpenseCategory? category,
    double? amount,
    DateTime? date,
    String? description,
    bool? isPaidFromDrawer,
    String? shiftId,
  }) {
    return Expense(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      isPaidFromDrawer: isPaidFromDrawer ?? this.isPaidFromDrawer,
      shiftId: shiftId ?? this.shiftId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        category,
        amount,
        date,
        description,
        isPaidFromDrawer,
        shiftId,
      ];
}
