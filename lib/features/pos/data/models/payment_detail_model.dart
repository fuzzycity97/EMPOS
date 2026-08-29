import '../../domain/entities/payment_detail.dart';

class PaymentDetailModel extends PaymentDetail {
  const PaymentDetailModel({
    required super.tenderType,
    required super.amount,
    super.referenceNumber,
    super.note,
  });

  factory PaymentDetailModel.fromJson(Map<String, dynamic> json) {
    final typeStr = json['tenderType']?.toString().toLowerCase();
    TenderType type = TenderType.cash;
    if (typeStr == 'card') {
      type = TenderType.card;
    } else if (typeStr == 'instapay') {
      type = TenderType.instapay;
    } else if (typeStr == 'vodafonecash' || typeStr == 'vodafone') {
      type = TenderType.vodafoneCash;
    } else if (typeStr == 'customeraccount' || typeStr == 'account') {
      type = TenderType.customerAccount;
    }

    return PaymentDetailModel(
      tenderType: type,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      referenceNumber: json['referenceNumber']?.toString(),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tenderType': tenderType.name,
      'amount': amount,
      'referenceNumber': referenceNumber,
      'note': note,
    };
  }

  factory PaymentDetailModel.fromEntity(PaymentDetail entity) {
    return PaymentDetailModel(
      tenderType: entity.tenderType,
      amount: entity.amount,
      referenceNumber: entity.referenceNumber,
      note: entity.note,
    );
  }
}
