import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_dimensions.dart';
import '../../../di/injection_container.dart';
import '../../domain/repositories/printer_repository.dart';

class HardwareDiagnosticsDialog extends StatelessWidget {
  final TextEditingController ipController;
  final TextEditingController portController;
  final TextEditingController barcodeInputController;
  final ValueNotifier<bool> isConnectingNotifier;
  final ValueNotifier<bool> isConnectedNotifier;
  final ValueNotifier<List<String>> scannedBarcodesNotifier;
  final ValueNotifier<List<String>> consoleLogsNotifier;
  final PrinterRepository printerRepository;

  const HardwareDiagnosticsDialog._({
    super.key,
    required this.ipController,
    required this.portController,
    required this.barcodeInputController,
    required this.isConnectingNotifier,
    required this.isConnectedNotifier,
    required this.scannedBarcodesNotifier,
    required this.consoleLogsNotifier,
    required this.printerRepository,
  });

  factory HardwareDiagnosticsDialog({Key? key, PrinterRepository? customRepo}) {
    final repo = customRepo ?? sl<PrinterRepository>();
    return HardwareDiagnosticsDialog._(
      key: key,
      ipController: TextEditingController(text: repo.currentDevice?.ipAddress ?? '192.168.1.200'),
      portController: TextEditingController(text: repo.currentDevice?.port.toString() ?? '9100'),
      barcodeInputController: TextEditingController(),
      isConnectingNotifier: ValueNotifier<bool>(false),
      isConnectedNotifier: ValueNotifier<bool>(repo.isConnected),
      scannedBarcodesNotifier: ValueNotifier<List<String>>([]),
      consoleLogsNotifier: ValueNotifier<List<String>>([
        'Hardware Diagnostics Console initialized.',
        'Initial Printer Status: ${repo.isConnected ? "CONNECTED" : "OFFLINE"}',
      ]),
      printerRepository: repo,
    );
  }

  void _addLog(String msg) {
    final time = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
    consoleLogsNotifier.value = [
      '[$time] $msg',
      ...consoleLogsNotifier.value,
    ];
  }

  Future<void> _testConnection() async {
    final ip = ipController.text.trim();
    final port = int.tryParse(portController.text.trim()) ?? 9100;
    if (ip.isEmpty) {
      _addLog('ERROR: IP address cannot be blank.');
      return;
    }

    isConnectingNotifier.value = true;
    _addLog('Attempting TCP connection to $ip:$port...');

    final success = await printerRepository.connectPrinter(ip, port: port);
    isConnectingNotifier.value = false;
    isConnectedNotifier.value = success;

    if (success) {
      _addLog('SUCCESS: Connected to ESC/POS Thermal Printer at $ip:$port');
    } else {
      _addLog('FAILED: Could not reach printer at $ip:$port. Check network and power.');
    }
  }

  Future<void> _printTestPage() async {
    if (!isConnectedNotifier.value) {
      _addLog('ERROR: Printer offline. Test connection first.');
      return;
    }

    try {
      _addLog('Sending ESC/POS test receipt and cut command [0x1D, 0x56, 0x41, 0x10]...');
      final testBytes = printerRepository.buildTestReceiptBytes();
      await printerRepository.printReceipt(testBytes);
      _addLog('SUCCESS: Test page sent to printer.');
    } catch (e) {
      _addLog('PRINT ERROR: $e');
    }
  }

  Future<void> _kickCashDrawer() async {
    if (!isConnectedNotifier.value) {
      _addLog('ERROR: Printer offline. RJ11 Drawer is attached via printer.');
      return;
    }

    try {
      _addLog('Triggering RJ11 Cash Drawer Pulse: [0x1B, 0x70, 0x00, 0x19, 0xFA]...');
      await printerRepository.kickCashDrawer();
      _addLog('SUCCESS: Cash drawer kick command dispatched.');
    } catch (e) {
      _addLog('DRAWER ERROR: $e');
    }
  }

  void _onBarcodeSubmitted(String code) {
    if (code.trim().isEmpty) return;
    final time = DateTime.now().toIso8601String().split('T')[1].split('.')[0];
    scannedBarcodesNotifier.value = [
      '[$time] Barcode: ${code.trim()} (length: ${code.trim().length})',
      ...scannedBarcodesNotifier.value,
    ];
    _addLog('Scanned Barcode captured: ${code.trim()}');
    barcodeInputController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        width: 820,
        constraints: const BoxConstraints(maxHeight: 700),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
          border: Border.all(color: AppColors.borderDark),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space16,
              ),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(LucideIcons.printer, color: AppColors.primary, size: 20),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hardware & Peripherals Diagnostics',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'Physical ESC/POS Thermal Printers, RJ11 Cash Drawers & Barcode Scanners',
                          style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AppColors.textSecondaryDark, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // ── BODY ────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.space20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── SECTION A: BARCODE SCANNER ──────────────────────────
                    _buildSectionHeader(
                      icon: LucideIcons.scanLine,
                      title: '1. Barcode & QR Wedge Scanner Test',
                      subtitle: 'Connect your USB/Bluetooth scanner and scan any barcode.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: barcodeInputController,
                            autofocus: true,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            onSubmitted: _onBarcodeSubmitted,
                            decoration: InputDecoration(
                              hintText: 'Click here and scan a product or type barcode + Enter...',
                              hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                              filled: true,
                              fillColor: AppColors.surfaceElevatedDark,
                              prefixIcon: const Icon(LucideIcons.barcode, color: AppColors.primary, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                borderSide: const BorderSide(color: AppColors.borderDark),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: () => _onBarcodeSubmitted(barcodeInputController.text),
                          icon: const Icon(LucideIcons.cornerDownLeft, size: 16),
                          label: const Text('Capture'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<List<String>>(
                      valueListenable: scannedBarcodesNotifier,
                      builder: (context, barcodes, _) {
                        if (barcodes.isEmpty) {
                          return const Text(
                            'No barcodes scanned yet.',
                            style: TextStyle(color: AppColors.textMutedDark, fontSize: 11.5),
                          );
                        }
                        return Container(
                          height: 80,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundDark,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: ListView.builder(
                            itemCount: barcodes.length,
                            itemBuilder: (context, index) {
                              return Text(
                                barcodes[index],
                                style: const TextStyle(
                                  color: AppColors.success,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppDimensions.space24),

                    // ── SECTION B: ESC/POS NETWORK THERMAL PRINTER ──────────
                    _buildSectionHeader(
                      icon: LucideIcons.printer,
                      title: '2. ESC/POS LAN Thermal Printer (TCP 9100)',
                      subtitle: 'Direct TCP socket driver for generic 80mm/58mm thermal receipt printers.',
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: ipController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Printer IP Address',
                              labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                              hintText: '192.168.1.200',
                              filled: true,
                              fillColor: AppColors.surfaceElevatedDark,
                              prefixIcon: const Icon(LucideIcons.globe, color: AppColors.textSecondaryDark, size: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                borderSide: const BorderSide(color: AppColors.borderDark),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: portController,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Port',
                              labelStyle: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                              hintText: '9100',
                              filled: true,
                              fillColor: AppColors.surfaceElevatedDark,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                borderSide: const BorderSide(color: AppColors.borderDark),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        ValueListenableBuilder<bool>(
                          valueListenable: isConnectingNotifier,
                          builder: (context, isConnecting, _) {
                            return ValueListenableBuilder<bool>(
                              valueListenable: isConnectedNotifier,
                              builder: (context, isConnected, _) {
                                return ElevatedButton.icon(
                                  onPressed: isConnecting ? null : _testConnection,
                                  icon: isConnecting
                                      ? const SizedBox(
                                          width: 14,
                                          height: 14,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Icon(
                                          isConnected ? LucideIcons.checkCircle : LucideIcons.plug,
                                          size: 16,
                                        ),
                                  label: Text(
                                    isConnecting
                                        ? 'Connecting...'
                                        : isConnected
                                            ? 'Re-Test'
                                            : 'Connect',
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isConnected ? AppColors.success : AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Actions Row: Print Test Page & Kick Drawer
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _printTestPage,
                            icon: const Icon(LucideIcons.fileText, size: 16),
                            label: const Text('Print Test Page (ESC/POS)'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppColors.borderDark),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _kickCashDrawer,
                            icon: const Icon(LucideIcons.archive, size: 16),
                            label: const Text('Kick Cash Drawer (RJ11)'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.warning,
                              side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppDimensions.space24),

                    // ── SECTION C: REAL-TIME CONSOLE LOGS ───────────────────
                    _buildSectionHeader(
                      icon: LucideIcons.terminal,
                      title: '3. Diagnostics Console Stream',
                      subtitle: 'Real-time telemetry and binary socket status events.',
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 130,
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppDimensions.space10),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: ValueListenableBuilder<List<String>>(
                        valueListenable: consoleLogsNotifier,
                        builder: (context, logs, _) {
                          return ListView.builder(
                            itemCount: logs.length,
                            itemBuilder: (context, index) {
                              final line = logs[index];
                              final isError = line.contains('ERROR') || line.contains('FAILED');
                              final isSuccess = line.contains('SUCCESS');

                              return Text(
                                line,
                                style: TextStyle(
                                  color: isError
                                      ? AppColors.danger
                                      : isSuccess
                                          ? AppColors.success
                                          : AppColors.textSecondaryDark,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── FOOTER ──────────────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.space20,
                vertical: AppDimensions.space12,
              ),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderDark)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ValueListenableBuilder<bool>(
                    valueListenable: isConnectedNotifier,
                    builder: (context, isConnected, _) {
                      return Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isConnected ? AppColors.success : AppColors.danger,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isConnected ? 'Printer Online (Port 9100)' : 'Printer Offline',
                            style: TextStyle(
                              color: isConnected ? AppColors.success : AppColors.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
