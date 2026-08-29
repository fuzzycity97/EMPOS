import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/erp_repository.dart';

class RecordExpenseParams extends Equatable {
  final ExpenseCategory category;
  final double amount;
  final String description;
  final DateTime date;
  final bool paidFromDrawer;

  const RecordExpenseParams({
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    this.paidFromDrawer = false,
  });

  @override
  List<Object?> get props => [
        category,
        amount,
        description,
        date,
        paidFromDrawer,
      ];
}

class RecordExpenseUseCase {
  final ErpRepository repository;

  RecordExpenseUseCase(this.repository);

  Future<Either<Failure, Expense>> call(RecordExpenseParams params) async {
    return await repository.recordExpense(
      category: params.category,
      amount: params.amount,
      description: params.description,
      date: params.date,
      paidFromDrawer: params.paidFromDrawer,
    );
  }
}
