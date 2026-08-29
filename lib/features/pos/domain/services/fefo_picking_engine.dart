import '../../../catalog/domain/entities/product_batch.dart';

class FefoPickResult {
  final List<ProductBatch> updatedBatches;
  final Map<String, int> deductedPerBatch; // batchId -> quantityDeducted
  final int remainingUnfulfilledQuantity;

  const FefoPickResult({
    required this.updatedBatches,
    required this.deductedPerBatch,
    required this.remainingUnfulfilledQuantity,
  });
}

class FefoPickingEngine {
  /// Picks inventory according to First-Expired, First-Out (FEFO) principles.
  /// Batches are sorted ascending by expiryDate (oldest / earliest expiring first).
  static FefoPickResult pickBatches({
    required List<ProductBatch> availableBatches,
    required int quantityToDeduct,
  }) {
    if (quantityToDeduct <= 0) {
      return FefoPickResult(
        updatedBatches: List.from(availableBatches),
        deductedPerBatch: const {},
        remainingUnfulfilledQuantity: 0,
      );
    }

    // Sort batches by expiryDate ascending (earliest expiry first)
    final sortedBatches = List<ProductBatch>.from(availableBatches)
      ..sort((a, b) => a.expiryDate.compareTo(b.expiryDate));

    final updated = <ProductBatch>[];
    final deducted = <String, int>{};
    int remainingToPick = quantityToDeduct;

    for (final batch in sortedBatches) {
      if (remainingToPick <= 0) {
        updated.add(batch);
        continue;
      }

      if (batch.quantity <= 0) {
        updated.add(batch);
        continue;
      }

      final toDeduct = batch.quantity >= remainingToPick ? remainingToPick : batch.quantity;
      final newQty = batch.quantity - toDeduct;
      remainingToPick -= toDeduct;
      deducted[batch.id] = toDeduct;

      updated.add(batch.copyWith(quantity: newQty));
    }

    return FefoPickResult(
      updatedBatches: updated,
      deductedPerBatch: deducted,
      remainingUnfulfilledQuantity: remainingToPick,
    );
  }
}
