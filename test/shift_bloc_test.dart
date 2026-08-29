import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:empos/features/shift/domain/entities/cash_transaction.dart';
import 'package:empos/features/shift/domain/entities/shift.dart';
import 'package:empos/features/shift/domain/usecases/add_cash_transaction_usecase.dart';
import 'package:empos/features/shift/domain/usecases/close_shift_usecase.dart';
import 'package:empos/features/shift/domain/usecases/generate_z_report_usecase.dart';
import 'package:empos/features/shift/domain/usecases/get_cash_transactions_usecase.dart';
import 'package:empos/features/shift/domain/usecases/get_current_shift_usecase.dart';
import 'package:empos/features/shift/domain/usecases/open_shift_usecase.dart';
import 'package:empos/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:empos/features/shift/presentation/bloc/shift_event.dart';
import 'package:empos/features/shift/presentation/bloc/shift_state.dart';

class MockGetCurrentShiftUseCase extends Mock implements GetCurrentShiftUseCase {}
class MockOpenShiftUseCase extends Mock implements OpenShiftUseCase {}
class MockCloseShiftUseCase extends Mock implements CloseShiftUseCase {}
class MockAddCashTransactionUseCase extends Mock implements AddCashTransactionUseCase {}
class MockGetCashTransactionsUseCase extends Mock implements GetCashTransactionsUseCase {}
class MockGenerateZReportUseCase extends Mock implements GenerateZReportUseCase {}

void main() {
  late MockGetCurrentShiftUseCase mockGetCurrentShift;
  late MockOpenShiftUseCase mockOpenShift;
  late MockCloseShiftUseCase mockCloseShift;
  late MockAddCashTransactionUseCase mockAddCashTx;
  late MockGetCashTransactionsUseCase mockGetCashTxList;
  late MockGenerateZReportUseCase mockGenerateZReport;
  late ShiftBloc shiftBloc;

  final tShift = Shift(
    id: 'SHIFT-1',
    cashierId: 'cashier-1',
    cashierName: 'Ahmed',
    startTime: DateTime(2026, 8, 27, 8, 0),
    startingCash: 500.0,
    expectedCash: 500.0,
    status: ShiftStatus.open,
  );

  setUpAll(() {
    registerFallbackValue(const OpenShiftParams(
      cashierId: 'cashier-1',
      startingCash: 500.0,
    ));
    registerFallbackValue(const CloseShiftParams(
      shiftId: 'SHIFT-1',
      actualCash: 500.0,
    ));
    registerFallbackValue(const AddCashTransactionParams(
      shiftId: 'SHIFT-1',
      type: CashTransactionType.payIn,
      amount: 100.0,
      reason: 'Change float',
    ));
  });

  setUp(() {
    mockGetCurrentShift = MockGetCurrentShiftUseCase();
    mockOpenShift = MockOpenShiftUseCase();
    mockCloseShift = MockCloseShiftUseCase();
    mockAddCashTx = MockAddCashTransactionUseCase();
    mockGetCashTxList = MockGetCashTransactionsUseCase();
    mockGenerateZReport = MockGenerateZReportUseCase();

    shiftBloc = ShiftBloc(
      getCurrentShiftUseCase: mockGetCurrentShift,
      openShiftUseCase: mockOpenShift,
      closeShiftUseCase: mockCloseShift,
      addCashTransactionUseCase: mockAddCashTx,
      getCashTransactionsUseCase: mockGetCashTxList,
      generateZReportUseCase: mockGenerateZReport,
    );
  });

  tearDown(() {
    shiftBloc.close();
  });

  group('ShiftBloc Tests', () {
    test('initial state should be ShiftInitial', () {
      expect(shiftBloc.state, equals(const ShiftInitial()));
    });

    blocTest<ShiftBloc, ShiftState>(
      'emits [ShiftLoading, NoActiveShift] when CheckCurrentShift finds no active shift',
      build: () {
        when(() => mockGetCurrentShift()).thenAnswer((_) async => const Right(null));
        return shiftBloc;
      },
      act: (b) => b.add(const CheckCurrentShiftEvent()),
      expect: () => [
        const ShiftLoading(),
        const NoActiveShift(),
      ],
    );

    blocTest<ShiftBloc, ShiftState>(
      'emits [ShiftLoading, ActiveShiftReady] when CheckCurrentShift finds open shift',
      build: () {
        when(() => mockGetCurrentShift()).thenAnswer((_) async => Right(tShift));
        when(() => mockGetCashTxList('SHIFT-1')).thenAnswer((_) async => const Right([]));
        return shiftBloc;
      },
      act: (b) => b.add(const CheckCurrentShiftEvent()),
      expect: () => [
        const ShiftLoading(),
        ActiveShiftReady(shift: tShift, transactions: const []),
      ],
    );

    blocTest<ShiftBloc, ShiftState>(
      'opens a new shift and emits ActiveShiftReady',
      build: () {
        when(() => mockOpenShift(any())).thenAnswer((_) async => Right(tShift));
        return shiftBloc;
      },
      act: (b) => b.add(const OpenShiftEvent(
        cashierId: 'cashier-1',
        cashierName: 'Ahmed',
        startingCash: 500.0,
      )),
      expect: () => [
        const ShiftLoading(),
        ActiveShiftReady(
          shift: tShift,
          transactions: const [],
          toastMessage: 'Shift opened with initial float of 500.00 EGP.',
        ),
      ],
    );
  });
}
