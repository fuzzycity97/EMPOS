import 'package:equatable/equatable.dart';

enum TenderType {
  cash,
  card,
  instapay,
  vodafoneCash,
  customerAccount,
}

class PaymentDetail extends Equatable {
  final TenderType tenderType;
  final double amount;
  final String? referenceNumber;
  final String? note;

  const PaymentDetail({
    required this.tenderType,
    required this.amount,
    this.referenceNumber,
    this.note,
  });

  String get tenderName {
    switch (tenderType) {
      case TenderType.cash:
        return 'Cash';
      case TenderType.card:
        return 'Credit / Debit Card';
      case TenderType.instapay:
        return 'Instapay';
      case TenderType.vodafoneCash:
        return 'Vodafone Cash';
      case TenderType.customerAccount:
        return 'Customer Account / Credit';
    }
  }

  @override
  List<Object?> get props => [tenderType, amount, referenceNumber, note];
}
