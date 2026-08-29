import 'dart:convert';
import 'dart:io';
import '../../domain/entities/printer_device.dart';
import '../../domain/repositories/printer_repository.dart';

class PrinterRepositoryImpl implements PrinterRepository {
  Socket? _socket;
  PrinterDevice? _currentDevice;

  @override
  PrinterDevice? get currentDevice => _currentDevice;

  @override
  bool get isConnected => _socket != null && (_currentDevice?.isConnected ?? false);

  @override
  Future<bool> connectPrinter(String ip, {int port = 9100}) async {
    try {
      await disconnectPrinter();
      final targetIp = ip.trim();
      final socket = await Socket.connect(
        targetIp,
        port,
        timeout: const Duration(seconds: 3),
      );

      _socket = socket;
      _currentDevice = PrinterDevice(
        id: 'escpos_$targetIp',
        name: 'ESC/POS Thermal Printer ($targetIp)',
        ipAddress: targetIp,
        port: port,
        isConnected: true,
      );

      // Handle remote socket close
      _socket?.done.then((_) {
        _socket = null;
        if (_currentDevice != null) {
          _currentDevice = _currentDevice!.copyWith(isConnected: false);
        }
      }).catchError((_) {});

      return true;
    } catch (e) {
      _socket = null;
      _currentDevice = PrinterDevice(
        id: 'escpos_${ip.trim()}',
        name: 'ESC/POS Thermal Printer (${ip.trim()})',
        ipAddress: ip.trim(),
        port: port,
        isConnected: false,
      );
      return false;
    }
  }

  @override
  Future<void> printReceipt(List<int> rawEscPosBytes) async {
    if (_socket == null) {
      throw Exception('Printer is not connected. Connect before sending raw bytes.');
    }
    _socket!.add(rawEscPosBytes);
    await _socket!.flush();
  }

  @override
  Future<void> kickCashDrawer() async {
    // Standard ESC/POS RJ11 kick pulse: ESC p 0 25 250
    final kickPulse = [0x1B, 0x70, 0x00, 0x19, 0xFA];
    await printReceipt(kickPulse);
  }

  @override
  Future<void> disconnectPrinter() async {
    if (_socket != null) {
      try {
        await _socket!.close();
        _socket!.destroy();
      } catch (_) {}
      _socket = null;
    }
    if (_currentDevice != null) {
      _currentDevice = _currentDevice!.copyWith(isConnected: false);
    }
  }

  @override
  List<int> buildTestReceiptBytes() {
    final bytes = <int>[];

    // ESC @: Initialize Printer
    bytes.addAll([0x1B, 0x40]);

    // ESC a 1: Center Alignment
    bytes.addAll([0x1B, 0x61, 0x01]);

    // GS ! 17: Double Width & Double Height
    bytes.addAll([0x1D, 0x21, 0x11]);
    bytes.addAll(utf8.encode('EMPOS™ POS\n'));

    // GS ! 0: Normal Font
    bytes.addAll([0x1D, 0x21, 0x00]);

    // ESC E 1: Bold On
    bytes.addAll([0x1B, 0x45, 0x01]);
    bytes.addAll(utf8.encode('HARDWARE DIAGNOSTICS TEST\n'));
    bytes.addAll([0x1B, 0x45, 0x00]);

    bytes.addAll(utf8.encode('================================\n'));

    // ESC a 0: Left Alignment
    bytes.addAll([0x1B, 0x61, 0x00]);
    bytes.addAll(utf8.encode('Protocol: ESC/POS Thermal\n'));
    bytes.addAll(utf8.encode('Interface: TCP Port 9100\n'));
    bytes.addAll(utf8.encode('Printer IP: ${_currentDevice?.ipAddress ?? "Unknown"}\n'));
    bytes.addAll(utf8.encode('Date/Time: ${DateTime.now().toString().split(".")[0]}\n'));
    bytes.addAll(utf8.encode('Status: CONNECTED & ONLINE\n'));
    bytes.addAll(utf8.encode('================================\n'));

    // ESC a 1: Center
    bytes.addAll([0x1B, 0x61, 0x01]);
    bytes.addAll(utf8.encode('Cash Drawer RJ11 Port Ready\n'));
    bytes.addAll(utf8.encode('*** EMPOS HARDWARE PASSED ***\n\n\n'));

    // Feed & Paper Full Cut: GS V A 16
    bytes.addAll([0x1D, 0x56, 0x41, 0x10]);

    return bytes;
  }
}
