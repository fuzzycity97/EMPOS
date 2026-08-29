import 'package:equatable/equatable.dart';

class ProductBatch extends Equatable {
  final String id;
  final String productId;
  final String batchNumber;
  final DateTime expiryDate;
  final int quantity;
  final double? costPrice;

  const ProductBatch({
    required this.id,
    required this.productId,
    required this.batchNumber,
    required this.expiryDate,
    required this.quantity,
    this.costPrice,
  });

  ProductBatch copyWith({
    String? id,
    String? productId,
    String? batchNumber,
    DateTime? expiryDate,
    int? quantity,
    double? costPrice,
  }) {
    return ProductBatch(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      batchNumber: batchNumber ?? this.batchNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      quantity: quantity ?? this.quantity,
      costPrice: costPrice ?? this.costPrice,
    );
  }

  factory ProductBatch.fromJson(Map<String, dynamic> json) {
    return ProductBatch(
      id: json['id']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      batchNumber: json['batchNumber']?.toString() ?? '',
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'].toString())
          : DateTime.now().add(const Duration(days: 365)),
      quantity: int.tryParse(json['quantity']?.toString() ?? '0') ?? 0,
      costPrice: json['costPrice'] != null
          ? double.tryParse(json['costPrice'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'batchNumber': batchNumber,
      'expiryDate': expiryDate.toIso8601String(),
      'quantity': quantity,
      if (costPrice != null) 'costPrice': costPrice,
    };
  }

  @override
  List<Object?> get props => [id, productId, batchNumber, expiryDate, quantity, costPrice];
}
