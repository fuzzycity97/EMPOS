import '../entities/printer_device.dart';

abstract class PrinterRepository {
  PrinterDevice? get currentDevice;
  bool get isConnected;

  Future<bool> connectPrinter(String ip, {int port = 9100});
  Future<void> printReceipt(List<int> rawEscPosBytes);
  Future<void> kickCashDrawer();
  Future<void> disconnectPrinter();
  List<int> buildTestReceiptBytes();
}
