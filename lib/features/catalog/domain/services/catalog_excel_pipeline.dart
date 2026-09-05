import 'dart:typed_data';
import 'package:excel/excel.dart';

class ExcelCatalogItemRow {
  final String category;
  final String nameEn;
  final String nameAr;
  final double price;
  final String barcode;
  final bool tracksQuantity;
  final double startingQty;
  final double lowStockThreshold;
  final String unit;
  final String? validationError;

  const ExcelCatalogItemRow({
    required this.category,
    required this.nameEn,
    required this.nameAr,
    required this.price,
    required this.barcode,
    required this.tracksQuantity,
    this.startingQty = 0.0,
    this.lowStockThreshold = 5.0,
    this.unit = 'PCS',
    this.validationError,
  });

  bool get isValid => validationError == null;
}

class CatalogExcelPipeline {
  CatalogExcelPipeline._();

  /// 1. Generate Excel Template (.xlsx) with styled headers and constraints explanation tab.
  static Uint8List generateCatalogTemplate() {
    final excel = Excel.createExcel();

    // Sheet 1: Catalog Import Data
    final Sheet dataSheet = excel['Catalog_Import_Template'];
    excel.setDefaultSheet('Catalog_Import_Template');

    final headers = [
      'Category',
      'Item Name (EN)',
      'Item Name (AR)',
      'Price',
      'Barcode',
      'Track Quantity? (Yes/No)',
      'Starting Qty',
      'Low Stock Threshold',
      'Unit',
    ];

    dataSheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Sample Example Rows
    dataSheet.appendRow([
      TextCellValue('Pharmaceuticals'),
      TextCellValue('Amoxicillin 500mg'),
      TextCellValue('اموكسيسيلين 500 مجم'),
      DoubleCellValue(85.0),
      TextCellValue('622100234501'),
      TextCellValue('Yes'),
      DoubleCellValue(100.0),
      DoubleCellValue(10.0),
      TextCellValue('BOX'),
    ]);

    dataSheet.appendRow([
      TextCellValue('Consultations'),
      TextCellValue('Specialist Clinical Consultation'),
      TextCellValue('كشف استشاري تخصصي'),
      DoubleCellValue(350.0),
      TextCellValue('SRV-CONSULT-01'),
      TextCellValue('No'),
      DoubleCellValue(0.0),
      DoubleCellValue(0.0),
      TextCellValue('SESSION'),
    ]);

    // Sheet 2: Field Instructions & Rules
    final Sheet instructionsSheet = excel['Instructions_and_Rules'];
    instructionsSheet.appendRow([TextCellValue('Column Name'), TextCellValue('Requirement'), TextCellValue('Rules & Allowed Values')]);
    instructionsSheet.appendRow([TextCellValue('Category'), TextCellValue('Required'), TextCellValue('Text name of group or department.')]);
    instructionsSheet.appendRow([TextCellValue('Item Name (EN)'), TextCellValue('Required'), TextCellValue('Primary English item description.')]);
    instructionsSheet.appendRow([TextCellValue('Price'), TextCellValue('Required'), TextCellValue('Numeric decimal value > 0.0 (e.g. 150.0).')]);
    instructionsSheet.appendRow([TextCellValue('Track Quantity?'), TextCellValue('Required'), TextCellValue('Yes for retail/physical stock; No for services & procedures.')]);

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? []);
  }

  /// 2. Parse and Validate Excel Catalog Bytes
  static List<ExcelCatalogItemRow> parseAndValidateCatalogBytes(Uint8List fileBytes) {
    final excel = Excel.decodeBytes(fileBytes);
    final rows = <ExcelCatalogItemRow>[];
    final seenBarcodes = <String>{};

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null || sheet.maxRows <= 1) continue;

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty) continue;

        final category = row.isNotEmpty ? row[0]?.value?.toString().trim() ?? '' : '';
        final nameEn = row.length > 1 ? row[1]?.value?.toString().trim() ?? '' : '';
        final nameAr = row.length > 2 ? row[2]?.value?.toString().trim() ?? '' : '';
        final priceStr = row.length > 3 ? row[3]?.value?.toString().trim() ?? '0' : '0';
        final barcode = row.length > 4 ? row[4]?.value?.toString().trim() ?? '' : '';
        final trackQtyStr = row.length > 5 ? row[5]?.value?.toString().trim().toLowerCase() ?? 'yes' : 'yes';
        final startQtyStr = row.length > 6 ? row[6]?.value?.toString().trim() ?? '0' : '0';
        final lowStockStr = row.length > 7 ? row[7]?.value?.toString().trim() ?? '5' : '5';
        final unit = row.length > 8 ? row[8]?.value?.toString().trim() ?? 'PCS' : 'PCS';

        if (nameEn.isEmpty && barcode.isEmpty) continue; // Skip empty trailing rows

        String? error;
        final price = double.tryParse(priceStr);
        if (price == null || price <= 0.0) {
          error = 'Invalid Price: must be a positive number';
        } else if (nameEn.isEmpty) {
          error = 'Missing required English item name';
        } else if (barcode.isNotEmpty && seenBarcodes.contains(barcode)) {
          error = 'Duplicate barcode detected: $barcode';
        }

        if (barcode.isNotEmpty) seenBarcodes.add(barcode);

        final tracksQuantity = trackQtyStr == 'yes' || trackQtyStr == 'true' || trackQtyStr == '1';
        final startingQty = double.tryParse(startQtyStr) ?? 0.0;
        final lowStockThreshold = double.tryParse(lowStockStr) ?? 5.0;

        rows.add(
          ExcelCatalogItemRow(
            category: category.isNotEmpty ? category : 'General',
            nameEn: nameEn,
            nameAr: nameAr.isNotEmpty ? nameAr : nameEn,
            price: price ?? 0.0,
            barcode: barcode.isNotEmpty ? barcode : 'GEN-${DateTime.now().millisecondsSinceEpoch}-$i',
            tracksQuantity: tracksQuantity,
            startingQty: startingQty,
            lowStockThreshold: lowStockThreshold,
            unit: unit,
            validationError: error,
          ),
        );
      }
      break; // Only parse primary first data sheet
    }

    return rows;
  }
}
