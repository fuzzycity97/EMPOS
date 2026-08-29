import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../entities/dividend_payout.dart';
import '../repositories/erp_repository.dart';

class RecordDividendPayoutParams extends Equatable {
  final String partnerId;
  final double amount;
  final DateTime payoutDate;
  final bool isPaidFromDrawer;
  final String? notes;

  const RecordDividendPayoutParams({
    required this.partnerId,
    required this.amount,
    required this.payoutDate,
    this.isPaidFromDrawer = false,
    this.notes,
  });

  @override
  List<Object?> get props => [
        partnerId,
        amount,
        payoutDate,
        isPaidFromDrawer,
        notes,
      ];
}

class RecordDividendPayoutUseCase {
  final ErpRepository repository;

  RecordDividendPayoutUseCase(this.repository);

  Future<Either<Failure, DividendPayout>> call(
    RecordDividendPayoutParams params,
  ) async {
    return await repository.recordDividendPayout(
      partnerId: params.partnerId,
      amount: params.amount,
      payoutDate: params.payoutDate,
      isPaidFromDrawer: params.isPaidFromDrawer,
      notes: params.notes,
    );
  }
}
