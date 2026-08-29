import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/calculate_distribution_usecase.dart';
import '../../domain/usecases/get_settlement_logs_usecase.dart';
import '../../domain/usecases/record_settlement_usecase.dart';
import 'finance_split_event.dart';
import 'finance_split_state.dart';

class FinanceSplitBloc extends Bloc<FinanceSplitEvent, FinanceSplitState> {
  final CalculateDistributionUseCase calculateDistributionUseCase;
  final RecordSettlementUseCase recordSettlementUseCase;
  final GetSettlementLogsUseCase getSettlementLogsUseCase;

  FinanceSplitBloc({
    required this.calculateDistributionUseCase,
    required this.recordSettlementUseCase,
    required this.getSettlementLogsUseCase,
  }) : super(FinanceSplitInitial()) {
    on<CalculateSplitsEvent>(_onCalculateSplits);
    on<RecordSettlementEvent>(_onRecordSettlement);
    on<LoadSettlementLogsEvent>(_onLoadSettlementLogs);
  }

  void _onCalculateSplits(
    CalculateSplitsEvent event,
    Emitter<FinanceSplitState> emit,
  ) {
    emit(FinanceSplitLoading());
    final result = calculateDistributionUseCase(event.totalAmount, event.rules);

    result.fold(
      (failure) => emit(FinanceSplitError(failure.message)),
      (results) {
        final totalDistributed = results.fold<double>(
          0.0,
          (sum, r) => sum + r.calculatedAmount,
        );
        final netOwnerAmount = double.parse(
          (event.totalAmount - totalDistributed).toStringAsFixed(2),
        );

        emit(
          FinanceSplitCalculated(
            totalAmount: event.totalAmount,
            results: results,
            netOwnerAmount: netOwnerAmount,
          ),
        );
      },
    );
  }

  Future<void> _onRecordSettlement(
    RecordSettlementEvent event,
    Emitter<FinanceSplitState> emit,
  ) async {
    emit(FinanceSplitLoading());
    final result = await recordSettlementUseCase(event.settlement);

    await result.fold(
      (failure) async => emit(FinanceSplitError(failure.message)),
      (saved) async {
        final logsResult = await getSettlementLogsUseCase(referenceId: event.settlement.referenceId);
        logsResult.fold(
          (failure) => emit(FinanceSplitError(failure.message)),
          (logs) => emit(FinanceSettlementsLoaded(logs)),
        );
      },
    );
  }

  Future<void> _onLoadSettlementLogs(
    LoadSettlementLogsEvent event,
    Emitter<FinanceSplitState> emit,
  ) async {
    emit(FinanceSplitLoading());
    final result = await getSettlementLogsUseCase(referenceId: event.referenceId);

    result.fold(
      (failure) => emit(FinanceSplitError(failure.message)),
      (logs) => emit(FinanceSettlementsLoaded(logs)),
    );
  }
}
