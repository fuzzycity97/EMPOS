import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/expense.dart';
import '../repositories/erp_repository.dart';

class GetExpensesUseCase {
  final ErpRepository repository;

  GetExpensesUseCase(this.repository);

  Future<Either<Failure, List<Expense>>> call({
    ExpenseCategory? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getExpenses(
      category: category,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
