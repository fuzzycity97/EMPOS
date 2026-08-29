import 'package:equatable/equatable.dart';

class DividendPayout extends Equatable {
  final String id;
  final String partnerId;
  final String? partnerName;
  final double amount;
  final DateTime payoutDate;
  final bool isPaidFromDrawer;
  final String? shiftId;
  final String? notes;

  const DividendPayout({
    required this.id,
    required this.partnerId,
    this.partnerName,
    required this.amount,
    required this.payoutDate,
    this.isPaidFromDrawer = false,
    this.shiftId,
    this.notes,
  });

  DividendPayout copyWith({
    String? id,
    String? partnerId,
    String? partnerName,
    double? amount,
    DateTime? payoutDate,
    bool? isPaidFromDrawer,
    String? shiftId,
    String? notes,
  }) {
    return DividendPayout(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      partnerName: partnerName ?? this.partnerName,
      amount: amount ?? this.amount,
      payoutDate: payoutDate ?? this.payoutDate,
      isPaidFromDrawer: isPaidFromDrawer ?? this.isPaidFromDrawer,
      shiftId: shiftId ?? this.shiftId,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        partnerId,
        partnerName,
        amount,
        payoutDate,
        isPaidFromDrawer,
        shiftId,
        notes,
      ];
}
