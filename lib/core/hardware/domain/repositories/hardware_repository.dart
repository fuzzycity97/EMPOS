import 'package:empos/core/config/domain/entities/store_blueprint.dart';
import 'package:empos/features/pos/domain/entities/order.dart';

abstract class HardwareRepository {
  /// Stream emitting barcodes scanned by physical USB/Bluetooth scanners.
  Stream<String> get barcodeScanStream;

  /// Generates and triggers native 80mm thermal receipt printing.
  Future<void> printReceipt(PosOrder order, StoreBlueprint blueprint);

  /// Disposes keyboard listeners and controllers.
  void dispose();
}
