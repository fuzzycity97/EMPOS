import 'dart:async';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:empos/core/config/domain/entities/store_blueprint.dart';
import 'package:empos/core/hardware/domain/repositories/hardware_repository.dart';
import 'package:empos/core/utils/currency_formatter.dart';
import 'package:empos/core/utils/date_formatter.dart';
import 'package:empos/features/pos/domain/entities/order.dart';

class HardwareRepositoryImpl implements HardwareRepository {
  final StreamController<String> _barcodeScanController = StreamController<String>.broadcast();
  final StringBuffer _buffer = StringBuffer();
  DateTime _lastKeyTime = DateTime.now();

  static const int _maxKeyIntervalMs = 85;

  HardwareRepositoryImpl() {
    _initKeyboardListener();
  }

  void _initKeyboardListener() {
    HardwareKeyboard.instance.addHandler(_handleKeyEvent);
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return false;

    final now = DateTime.now();
    final isEnter = event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter;

    if (isEnter) {
      if (_buffer.isNotEmpty && _buffer.length >= 3) {
        final scannedBarcode = _buffer.toString().trim();
        _barcodeScanController.add(scannedBarcode);
      }
      _buffer.clear();
      return false;
    }

    final elapsed = now.difference(_lastKeyTime).inMilliseconds;
    if (elapsed > _maxKeyIntervalMs && _buffer.isNotEmpty) {
      _buffer.clear();
    }
    _lastKeyTime = now;

    final char = event.character;
    if (char != null && char.isNotEmpty && RegExp(r'[a-zA-Z0-9\-_]').hasMatch(char)) {
      _buffer.write(char);
    }

    return false;
  }

  @override
  Stream<String> get barcodeScanStream => _barcodeScanController.stream;

  @override
  Future<void> printReceipt(PosOrder order, StoreBlueprint blueprint) async {
    final doc = pw.Document();

    final roll80 = const PdfPageFormat(
      80 * PdfPageFormat.mm,
      double.infinity,
      marginAll: 4 * PdfPageFormat.mm,
    );

    doc.addPage(
      pw.Page(
        pageFormat: roll80,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              // Store Header
              pw.Text(
                blueprint.storeName.toUpperCase(),
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              if (blueprint.storeBranch.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Text(
                  blueprint.storeBranch,
                  style: const pw.TextStyle(fontSize: 9),
                  textAlign: pw.TextAlign.center,
                ),
              ],
              pw.SizedBox(height: 4),
              pw.Text(
                'TAX INVOICE / RECEIPT',
                style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Metadata Row
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Txn: #${order.orderNumber}', style: const pw.TextStyle(fontSize: 8)),
                  pw.Text(DateFormatter.formatDateTime(order.createdAt), style: const pw.TextStyle(fontSize: 8)),
                ],
              ),
              if (order.customerName != null && order.customerName!.isNotEmpty) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Customer: ${order.customerName}', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(order.customerPhone ?? '', style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],
              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Items Table Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(flex: 3, child: pw.Text('ITEM', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 1, child: pw.Text('QTY', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 2, child: pw.Text('PRICE', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 2, child: pw.Text('TOTAL', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5),

              // Items Rows
              ...order.cart.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(
                          item.product.nameEn,
                          style: const pw.TextStyle(fontSize: 8),
                          maxLines: 2,
                        ),
                      ),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Text(
                          '${item.quantity}',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          CurrencyFormatter.format(item.unitPrice),
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          CurrencyFormatter.format(item.lineTotal),
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 6),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Totals
              _buildTotalRow('Subtotal:', CurrencyFormatter.format(order.cart.subtotal)),
              if (order.cart.discountAmount > 0)
                _buildTotalRow('Discount:', '-${CurrencyFormatter.format(order.cart.discountAmount)}'),
              _buildTotalRow('Tax (VAT):', CurrencyFormatter.format(order.cart.taxAmount)),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 1.0),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL:', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
                  pw.Text(
                    CurrencyFormatter.format(order.cart.grandTotal),
                    style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
                  ),
                ],
              ),
              pw.Divider(thickness: 1.0),
              pw.SizedBox(height: 6),

              // Payment Details
              ...order.payments.map((p) => pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Tender: ${p.tenderType.name.toUpperCase()}',
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                      pw.Text(
                        CurrencyFormatter.format(p.amount),
                        style: const pw.TextStyle(fontSize: 8),
                      ),
                    ],
                  )),

              if (order.changeGiven > 0) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Change Due:', style: const pw.TextStyle(fontSize: 8)),
                    pw.Text(CurrencyFormatter.format(order.changeGiven), style: const pw.TextStyle(fontSize: 8)),
                  ],
                ),
              ],

              pw.SizedBox(height: 10),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
              pw.SizedBox(height: 4),
              pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Powered by EMPOS™ Cloud Engine',
                style: const pw.TextStyle(fontSize: 7),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      name: 'Receipt_${order.orderNumber}',
      onLayout: (format) async => doc.save(),
    );
  }

  pw.Widget _buildTotalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 8.5)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 8.5)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);
    _barcodeScanController.close();
  }
}
