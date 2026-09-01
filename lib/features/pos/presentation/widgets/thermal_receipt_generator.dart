import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/pos_order_model.dart';
import '../../../../core/utils/currency_formatter.dart';

/// Printable Receipt Generator for 80mm Thermal Rolls & Standard A4 Invoices.
class ThermalReceiptGenerator {
  /// Generates raw PDF bytes for 80mm (72mm printable width) thermal receipt
  static Future<Uint8List> generate80mmReceiptBytes({
    required PosOrderModel order,
    required String storeName,
    String? storeTaxNumber,
    String? storeAddress,
    String? storePhone,
    double? patientRemainingDebt,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
    final totalTendered = order.payments.fold<double>(0.0, (s, p) => s + p.amount);
    final unpaidBalance = patientRemainingDebt ?? (order.cart.grandTotal - totalTendered);

    pdf.addPage(
      pw.Page(
        pageFormat: const PdfPageFormat(
          72 * PdfPageFormat.mm,
          double.infinity,
          marginAll: 4 * PdfPageFormat.mm,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  storeName.toUpperCase(),
                  style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (storeAddress != null)
                pw.Center(
                  child: pw.Text(
                    storeAddress,
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              if (storeTaxNumber != null)
                pw.Center(
                  child: pw.Text(
                    'Tax Reg: $storeTaxNumber',
                    style: const pw.TextStyle(fontSize: 8),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Order Meta
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Order: #${order.orderNumber}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text(dateFormat.format(order.createdAt), style: const pw.TextStyle(fontSize: 7)),
                ],
              ),
              if (order.customerName != null)
                pw.Text('Customer: ${order.customerName}', style: const pw.TextStyle(fontSize: 8)),
              if (order.customerPhone != null)
                pw.Text('Phone: ${order.customerPhone}', style: const pw.TextStyle(fontSize: 8)),
              if (order.cashierId != null)
                pw.Text('Cashier: ${order.cashierId}', style: const pw.TextStyle(fontSize: 7)),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Line Items
              pw.Row(
                children: [
                  pw.Expanded(flex: 5, child: pw.Text('Item', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 2, child: pw.Text('Qty', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 3, child: pw.Text('Total', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.SizedBox(height: 2),
              ...order.cart.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1),
                  child: pw.Row(
                    children: [
                      pw.Expanded(
                        flex: 5,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(item.name, style: const pw.TextStyle(fontSize: 8)),
                            if (item.department != null && item.department!.isNotEmpty)
                              pw.Text('[${item.department}]', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey700)),
                          ],
                        ),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text('${item.quantity}', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8)),
                      ),
                      pw.Expanded(
                        flex: 3,
                        child: pw.Text(CurrencyFormatter.format(item.total), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 8)),
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Financial Summary
              _buildSummaryRow('Subtotal', CurrencyFormatter.format(order.cart.subtotal)),
              if (order.cart.discountTotal > 0)
                _buildSummaryRow('Discount', '-${CurrencyFormatter.format(order.cart.discountTotal)}'),
              if (order.cart.taxTotal > 0)
                _buildSummaryRow('VAT / Tax', CurrencyFormatter.format(order.cart.taxTotal)),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                  pw.Text(CurrencyFormatter.format(order.cart.grandTotal), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                ],
              ),

              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // Payments Tendered
              pw.Text('PAYMENT TENDERS:', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
              ...order.payments.map((p) => _buildSummaryRow(p.tenderType.name.toUpperCase(), CurrencyFormatter.format(p.amount))),
              _buildSummaryRow('Total Paid', CurrencyFormatter.format(totalTendered)),
              if (order.changeGiven > 0)
                _buildSummaryRow('Change Returned', CurrencyFormatter.format(order.changeGiven)),

              // Outstanding Debt Alert
              if (unpaidBalance > 0.001) ...[
                pw.SizedBox(height: 3),
                pw.Container(
                  padding: const pw.EdgeInsets.all(3),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.5),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text('ACCOUNT REMAINING DEBT:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                      pw.Text(CurrencyFormatter.format(unpaidBalance), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                    ],
                  ),
                ),
              ],

              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text('Thank you for your visit!', style: const pw.TextStyle(fontSize: 8)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Direct print trigger to default or selected printer
  static Future<void> printReceipt({
    required PosOrderModel order,
    required String storeName,
    String? storeTaxNumber,
    String? storeAddress,
    String? storePhone,
    double? patientRemainingDebt,
  }) async {
    final bytes = await generate80mmReceiptBytes(
      order: order,
      storeName: storeName,
      storeTaxNumber: storeTaxNumber,
      storeAddress: storeAddress,
      storePhone: storePhone,
      patientRemainingDebt: patientRemainingDebt,
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => bytes,
      name: 'Receipt_${order.orderNumber}',
    );
  }

  static pw.Widget _buildSummaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 7.5)),
          pw.Text(value, style: const pw.TextStyle(fontSize: 7.5)),
        ],
      ),
    );
  }
}
