import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';

/// Professional 80mm Thermal Receipt Generator for Clinic Reception & Patient Billing.
class ClinicReceiptGenerator {
  /// Generates raw PDF bytes formatted for standard 80mm thermal rolls (72mm printable width)
  static Future<Uint8List> generate80mmReceiptBytes({
    required ClinicVisit visit,
    PatientProfile? patient,
    required double amountPaid,
    required StoreBlueprint blueprint,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');
    final visitDate = visit.completionTime ?? visit.checkInTime;

    final totalFee = visit.totalFee;
    final copayRatio = patient?.defaultCopayPercentage ?? 1.0;
    final patientShare = visit.patientCopay > 0 ? visit.patientCopay : (totalFee * copayRatio);
    final insuranceShare = visit.insurancePaid > 0 ? visit.insurancePaid : (totalFee - patientShare);
    final remainingDebt = math.max(0.0, patientShare - amountPaid);
    final isFullyPaid = remainingDebt <= 0.001;

    final shortId = visit.id.length > 8 ? visit.id.substring(0, 8).toUpperCase() : visit.id.toUpperCase();

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
              // ── CLINIC HEADER ──
              pw.Center(
                child: pw.Text(
                  blueprint.storeName.toUpperCase(),
                  style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Center(
                child: pw.Text(
                  '${blueprint.storeBranch} - Medical Reception Desk',
                  style: const pw.TextStyle(fontSize: 7.5),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              if (blueprint.serverSyncUrl != null && blueprint.serverSyncUrl!.isNotEmpty)
                pw.Center(
                  child: pw.Text(
                    'Online Sync: ${blueprint.serverSyncUrl}',
                    style: const pw.TextStyle(fontSize: 6.5),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // ── ENCOUNTER & PATIENT METADATA ──
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('RECEIPT: #REC-$shortId', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  pw.Text(dateFormat.format(visitDate), style: const pw.TextStyle(fontSize: 7)),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text('Patient: ${visit.patientName}', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
              if (patient != null && patient.phone.isNotEmpty)
                pw.Text('Phone: ${patient.phone}', style: const pw.TextStyle(fontSize: 7.5)),
              pw.Text('Attending Doctor: ${visit.doctorName}', style: const pw.TextStyle(fontSize: 7.5)),
              pw.Text('Station / Room: ${visit.roomNumber} (Queue #${visit.queueNumber})', style: const pw.TextStyle(fontSize: 7)),
              if (visit.diagnosis != null && visit.diagnosis!.isNotEmpty)
                pw.Text('Diagnosis: ${visit.diagnosis}', style: const pw.TextStyle(fontSize: 7.5)),
              if (patient?.insuranceProvider != null && patient!.insuranceProvider!.isNotEmpty)
                pw.Text(
                  'Insurance: ${patient.insuranceProvider} (${((1 - copayRatio) * 100).toInt()}% Carrier Claim)',
                  style: const pw.TextStyle(fontSize: 7),
                ),

              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // ── PROCEDURES & CONSULTATION LINE ITEMS ──
              pw.Row(
                children: [
                  pw.Expanded(flex: 5, child: pw.Text('Service / Procedure', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 2, child: pw.Text('Code', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold))),
                  pw.Expanded(flex: 3, child: pw.Text('Fee (${blueprint.currency})', textAlign: pw.TextAlign.right, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold))),
                ],
              ),
              pw.SizedBox(height: 2),
              if (visit.appliedProcedures.isNotEmpty)
                ...visit.appliedProcedures.map((proc) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(vertical: 1),
                    child: pw.Row(
                      children: [
                        pw.Expanded(flex: 5, child: pw.Text(proc.name, style: const pw.TextStyle(fontSize: 7))),
                        pw.Expanded(flex: 2, child: pw.Text(proc.code, textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 6.5))),
                        pw.Expanded(flex: 3, child: pw.Text(proc.standardFee.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7))),
                      ],
                    ),
                  );
                })
              else
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 1),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 5, child: pw.Text('Clinical Consultation & Evaluation', style: const pw.TextStyle(fontSize: 7))),
                      pw.Expanded(flex: 2, child: pw.Text('99213', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 6.5))),
                      pw.Expanded(flex: 3, child: pw.Text(totalFee.toStringAsFixed(2), textAlign: pw.TextAlign.right, style: const pw.TextStyle(fontSize: 7))),
                    ],
                  ),
                ),

              pw.SizedBox(height: 3),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // ── BILLING & COPAY BREAKDOWN ──
              _buildReceiptRow('Total Encounter Fee', '${totalFee.toStringAsFixed(2)} ${blueprint.currency}'),
              if (insuranceShare > 0)
                _buildReceiptRow('Insurance Claim Covered', '- ${insuranceShare.toStringAsFixed(2)} ${blueprint.currency}'),
              _buildReceiptRow('Patient Copay Share', '${patientShare.toStringAsFixed(2)} ${blueprint.currency}', isBold: true),
              _buildReceiptRow('Amount Paid at Reception', '${amountPaid.toStringAsFixed(2)} ${blueprint.currency}', isBold: true),
              if (remainingDebt > 0)
                _buildReceiptRow('Remaining Account Debt', '${remainingDebt.toStringAsFixed(2)} ${blueprint.currency}', isAlert: true),

              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(width: 0.8),
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                  ),
                  child: pw.Text(
                    isFullyPaid ? '*** SETTLED & PAID IN FULL ***' : '! PARTIAL PAYMENT RECORDED !',
                    style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold),
                  ),
                ),
              ),

              // ── PRESCRIPTIONS SUMMARY ──
              if (visit.prescriptions.isNotEmpty) ...[
                pw.SizedBox(height: 3),
                pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),
                pw.Text('Prescribed Rx (${visit.prescriptions.length}):', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
                ...visit.prescriptions.take(3).map(
                  (rx) => pw.Text('- $rx', style: const pw.TextStyle(fontSize: 6.5)),
                ),
              ],

              // ── RECALL FOLLOW UP ──
              if (visit.recallDate != null) ...[
                pw.SizedBox(height: 2),
                pw.Text('Next Appointment Recall: ${DateFormat('yyyy-MM-dd').format(visit.recallDate!)}', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold)),
              ],

              pw.SizedBox(height: 4),
              pw.Divider(thickness: 0.5, borderStyle: pw.BorderStyle.dashed),

              // ── QR CODE & FOOTER ──
              pw.SizedBox(height: 3),
              pw.Center(
                child: pw.BarcodeWidget(
                  barcode: pw.Barcode.qrCode(),
                  data: 'EMPOS:REC:$shortId:PAT:${visit.patientId}:AMT:${amountPaid.toStringAsFixed(2)}',
                  width: 38,
                  height: 38,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Center(
                child: pw.Text(
                  'Thank you for your visit - Get well soon!',
                  style: const pw.TextStyle(fontSize: 7),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              pw.Center(
                child: pw.Text(
                  'EMPOS Omnichannel Healthcare Platform',
                  style: const pw.TextStyle(fontSize: 6),
                  textAlign: pw.TextAlign.center,
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Direct one-tap print invocation using the Printing package
  static Future<bool> printReceipt({
    required ClinicVisit visit,
    PatientProfile? patient,
    required double amountPaid,
    required StoreBlueprint blueprint,
  }) async {
    try {
      final bytes = await generate80mmReceiptBytes(
        visit: visit,
        patient: patient,
        amountPaid: amountPaid,
        blueprint: blueprint,
      );

      final shortId = visit.id.length > 8 ? visit.id.substring(0, 8).toUpperCase() : visit.id.toUpperCase();

      return await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => bytes,
        name: 'Clinic_Receipt_$shortId',
      );
    } catch (e) {
      debugPrint('[ClinicReceiptGenerator] Printing failed: $e');
      return false;
    }
  }

  static pw.Widget _buildReceiptRow(String label, String value, {bool isBold = false, bool isAlert = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 0.8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: isBold ? 8 : 7,
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: isBold ? 8.5 : 7,
              fontWeight: isBold || isAlert ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
