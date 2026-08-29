import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_cash_transaction_usecase.dart';
import '../../domain/usecases/close_shift_usecase.dart';
import '../../domain/usecases/generate_z_report_usecase.dart';
import '../../domain/usecases/get_cash_transactions_usecase.dart';
import '../../domain/usecases/get_current_shift_usecase.dart';
import '../../domain/usecases/open_shift_usecase.dart';
import 'shift_event.dart';
import 'shift_state.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final GetCurrentShiftUseCase getCurrentShiftUseCase;
  final OpenShiftUseCase openShiftUseCase;
  final CloseShiftUseCase closeShiftUseCase;
  final AddCashTransactionUseCase addCashTransactionUseCase;
  final GetCashTransactionsUseCase getCashTransactionsUseCase;
  final GenerateZReportUseCase generateZReportUseCase;

  ShiftBloc({
    required this.getCurrentShiftUseCase,
    required this.openShiftUseCase,
    required this.closeShiftUseCase,
    required this.addCashTransactionUseCase,
    required this.getCashTransactionsUseCase,
    required this.generateZReportUseCase,
  }) : super(const ShiftInitial()) {
    on<CheckCurrentShiftEvent>(_onCheckCurrentShift);
    on<OpenShiftEvent>(_onOpenShift);
    on<CloseShiftEvent>(_onCloseShift);
    on<AddCashTxEvent>(_onAddCashTx);
    on<GenerateZReportEvent>(_onGenerateZReport);
    on<DismissZReportEvent>(_onDismissZReport);
  }

  Future<void> _onCheckCurrentShift(
    CheckCurrentShiftEvent event,
    Emitter<ShiftState> emit,
  ) async {
    emit(const ShiftLoading());

    final result = await getCurrentShiftUseCase();

    await result.fold(
      (failure) async => emit(ShiftError(failure.message)),
      (shift) async {
        if (shift == null || shift.isClosed) {
          emit(const NoActiveShift());
        } else {
          final txResult = await getCashTransactionsUseCase(shift.id);
          final txList = txResult.getOrElse(() => []);
          emit(ActiveShiftReady(shift: shift, transactions: txList));
        }
      },
    );
  }

  Future<void> _onOpenShift(
    OpenShiftEvent event,
    Emitter<ShiftState> emit,
  ) async {
    emit(const ShiftLoading());

    final result = await openShiftUseCase(
      OpenShiftParams(
        cashierId: event.cashierId,
        cashierName: event.cashierName,
        startingCash: event.startingCash,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) => emit(ShiftError(failure.message)),
      (shift) => emit(
        ActiveShiftReady(
          shift: shift,
          transactions: const [],
          toastMessage: 'Shift opened with initial float of ${shift.startingCash.toStringAsFixed(2)} EGP.',
        ),
      ),
    );
  }

  Future<void> _onCloseShift(
    CloseShiftEvent event,
    Emitter<ShiftState> emit,
  ) async {
    if (state is ActiveShiftReady) {
      final current = state as ActiveShiftReady;
      emit(current.copyWith(isProcessing: true));
    }

    final closeResult = await closeShiftUseCase(
      CloseShiftParams(
        shiftId: event.shiftId,
        actualCash: event.actualCash,
        notes: event.notes,
      ),
    );

    await closeResult.fold(
      (failure) async => emit(ShiftError(failure.message)),
      (closedShift) async {
        final zReportResult = await generateZReportUseCase(closedShift.id);
        zReportResult.fold(
          (failure) => emit(const NoActiveShift(message: 'Shift closed successfully.')),
          (zReport) => emit(ZReportGenerated(zReport)),
        );
      },
    );
  }

  Future<void> _onAddCashTx(
    AddCashTxEvent event,
    Emitter<ShiftState> emit,
  ) async {
    if (state is! ActiveShiftReady) return;
    final current = state as ActiveShiftReady;

    final result = await addCashTransactionUseCase(
      AddCashTransactionParams(
        shiftId: event.shiftId,
        type: event.type,
        amount: event.amount,
        reason: event.reason,
      ),
    );

    await result.fold(
      (failure) async => emit(current.copyWith(toastMessage: () => failure.message)),
      (tx) async {
        final updatedTxResult = await getCashTransactionsUseCase(current.shift.id);
        final txList = updatedTxResult.getOrElse(() => []);

        // Refresh dynamic drawer balance
        final shiftResult = await getCurrentShiftUseCase();
        final refreshedShift = shiftResult.getOrElse(() => current.shift) ?? current.shift;

        emit(current.copyWith(
          shift: refreshedShift,
          transactions: txList,
          toastMessage: () => '${event.type.name.toUpperCase()} of ${event.amount.toStringAsFixed(2)} EGP recorded.',
        ));
      },
    );
  }

  Future<void> _onGenerateZReport(
    GenerateZReportEvent event,
    Emitter<ShiftState> emit,
  ) async {
    emit(const ShiftLoading());

    final result = await generateZReportUseCase(event.shiftId);

    result.fold(
      (failure) => emit(ShiftError(failure.message)),
      (zReport) => emit(ZReportGenerated(zReport)),
    );
  }

  void _onDismissZReport(
    DismissZReportEvent event,
    Emitter<ShiftState> emit,
  ) {
    emit(const NoActiveShift());
  }
}
