import 'dart:convert';
import '../../domain/entities/dividend_payout.dart';

class DividendPayoutModel extends DividendPayout {
  const DividendPayoutModel({
    required super.id,
    required super.partnerId,
    super.partnerName,
    required super.amount,
    required super.payoutDate,
    super.isPaidFromDrawer = false,
    super.shiftId,
    super.notes,
  });

  factory DividendPayoutModel.fromRaw(dynamic raw) {
    if (raw == null) {
      throw ArgumentError('Cannot parse DividendPayoutModel from null');
    }
    if (raw is String) {
      final decoded = jsonDecode(raw);
      return DividendPayoutModel.fromJson(Map<String, dynamic>.from(decoded as Map));
    }
    if (raw is Map) {
      return DividendPayoutModel.fromJson(Map<String, dynamic>.from(raw));
    }
    throw ArgumentError('Unsupported raw type for DividendPayoutModel: ${raw.runtimeType}');
  }

  factory DividendPayoutModel.fromJson(Map<String, dynamic> json) {
    return DividendPayoutModel(
      id: json['id']?.toString() ?? '',
      partnerId: json['partnerId']?.toString() ?? '',
      partnerName: json['partnerName']?.toString(),
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      payoutDate: DateTime.tryParse(json['payoutDate']?.toString() ?? '') ?? DateTime.now(),
      isPaidFromDrawer: json['isPaidFromDrawer'] as bool? ?? false,
      shiftId: json['shiftId']?.toString(),
      notes: json['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'partnerName': partnerName,
      'amount': amount,
      'payoutDate': payoutDate.toIso8601String(),
      'isPaidFromDrawer': isPaidFromDrawer,
      'shiftId': shiftId,
      'notes': notes,
    };
  }

  factory DividendPayoutModel.fromEntity(DividendPayout entity) {
    return DividendPayoutModel(
      id: entity.id,
      partnerId: entity.partnerId,
      partnerName: entity.partnerName,
      amount: entity.amount,
      payoutDate: entity.payoutDate,
      isPaidFromDrawer: entity.isPaidFromDrawer,
      shiftId: entity.shiftId,
      notes: entity.notes,
    );
  }

  @override
  DividendPayoutModel copyWith({
    String? id,
    String? partnerId,
    String? partnerName,
    double? amount,
    DateTime? payoutDate,
    bool? isPaidFromDrawer,
    String? shiftId,
    String? notes,
  }) {
    return DividendPayoutModel(
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
}
