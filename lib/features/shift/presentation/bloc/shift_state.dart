import 'package:equatable/equatable.dart';
import '../../domain/entities/cash_transaction.dart';
import '../../domain/entities/shift.dart';
import '../../domain/entities/z_report.dart';

abstract class ShiftState extends Equatable {
  const ShiftState();

  @override
  List<Object?> get props => [];
}

class ShiftInitial extends ShiftState {
  const ShiftInitial();
}

class ShiftLoading extends ShiftState {
  const ShiftLoading();
}

class NoActiveShift extends ShiftState {
  final String? message;

  const NoActiveShift({this.message});

  @override
  List<Object?> get props => [message];
}

class ActiveShiftReady extends ShiftState {
  final Shift shift;
  final List<CashTransaction> transactions;
  final String? toastMessage;
  final bool isProcessing;

  const ActiveShiftReady({
    required this.shift,
    this.transactions = const [],
    this.toastMessage,
    this.isProcessing = false,
  });

  ActiveShiftReady copyWith({
    Shift? shift,
    List<CashTransaction>? transactions,
    String? Function()? toastMessage,
    bool? isProcessing,
  }) {
    return ActiveShiftReady(
      shift: shift ?? this.shift,
      transactions: transactions ?? this.transactions,
      toastMessage: toastMessage != null ? toastMessage() : this.toastMessage,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }

  @override
  List<Object?> get props => [shift, transactions, toastMessage, isProcessing];
}

class ZReportGenerated extends ShiftState {
  final ZReport zReport;

  const ZReportGenerated(this.zReport);

  @override
  List<Object?> get props => [zReport];
}

class ShiftError extends ShiftState {
  final String message;

  const ShiftError(this.message);

  @override
  List<Object?> get props => [message];
}
