import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../catalog/presentation/bloc/catalog_bloc.dart';
import '../../../catalog/presentation/bloc/catalog_event.dart';
import '../bloc/data_io_bloc.dart';
import '../bloc/data_io_event.dart';
import '../bloc/data_io_state.dart';

class DataIoManagerDialog extends StatelessWidget {
  final VoidCallback? onImportCompleted;

  const DataIoManagerDialog({super.key, this.onImportCompleted});

  Future<String?> _getSavePath({
    required String defaultFileName,
    required String dialogTitle,
  }) async {
    try {
      final path = await FilePicker.platform.saveFile(
        dialogTitle: dialogTitle,
        fileName: defaultFileName,
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );
      if (path != null && path.isNotEmpty) {
        return path.endsWith('.csv') ? path : '$path.csv';
      }
    } catch (_) {}

    try {
      final dir = await getApplicationDocumentsDirectory();
      return '${dir.path}/$defaultFileName';
    } catch (_) {
      return defaultFileName;
    }
  }

  Future<void> _handleDownloadTemplate(BuildContext context) async {
    final path = await _getSavePath(
      defaultFileName: 'empos_catalog_template.csv',
      dialogTitle: 'Save Catalog CSV Template',
    );
    if (path != null && context.mounted) {
      context.read<DataIoBloc>().add(GenerateTemplateEvent(path));
    }
  }

  Future<void> _handleExportCatalog(BuildContext context) async {
    final now = DateTime.now();
    final timestamp = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    final path = await _getSavePath(
      defaultFileName: 'empos_inventory_export_$timestamp.csv',
      dialogTitle: 'Export Inventory CSV',
    );
    if (path != null && context.mounted) {
      context.read<DataIoBloc>().add(ExportCatalogEvent(path));
    }
  }

  Future<void> _handlePickAndImportCsv(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: 'Select Products CSV to Import',
      );

      if (result != null && result.files.isNotEmpty && context.mounted) {
        final filePath = result.files.single.path;
        if (filePath != null && filePath.isNotEmpty) {
          context.read<DataIoBloc>().add(ImportCatalogEvent(filePath));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open file picker: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 720),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: BlocConsumer<DataIoBloc, DataIoState>(
            listener: (context, state) {
              if (state is DataIoSuccess && state.importResult != null) {
                // Refresh catalog immediately upon successful import
                try {
                  context.read<CatalogBloc>().add(const LoadCatalog());
                } catch (_) {}
                onImportCompleted?.call();
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Dialog Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: Icon(
                          LucideIcons.fileSpreadsheet,
                          color: primaryColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: AppDimensions.space12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CSV Smart Import & Export Engine',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Bulk manage inventory with Excel & Sheets compatible CSV files',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(LucideIcons.x, size: 20),
                        tooltip: 'Close',
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.space16),
                  const Divider(color: AppColors.borderDark, height: 1),
                  const SizedBox(height: AppDimensions.space16),

                  // Action Cards Row / Grid
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _ActionCard(
                            title: '1. Download Blank CSV Template',
                            description: 'Standard Excel-ready format with 7 required columns (Barcode, Name_EN, Name_AR, Category, CostPrice, RetailPrice, StockQty).',
                            icon: LucideIcons.fileDown,
                            accentColor: AppColors.secondary,
                            buttonLabel: 'DOWNLOAD TEMPLATE',
                            isLoading: state is DataIoLoading && state.operation.contains('Template'),
                            onTap: () => _handleDownloadTemplate(context),
                          ),
                          const SizedBox(height: AppDimensions.space12),
                          _ActionCard(
                            title: '2. Export Current Inventory',
                            description: 'Extract all products and active stock balances directly from your local database into a downloadable CSV.',
                            icon: LucideIcons.download,
                            accentColor: primaryColor,
                            buttonLabel: 'EXPORT INVENTORY',
                            isLoading: state is DataIoLoading && state.operation.contains('Export'),
                            onTap: () => _handleExportCatalog(context),
                          ),
                          const SizedBox(height: AppDimensions.space12),
                          _ActionCard(
                            title: '3. Bulk Import Products CSV',
                            description: 'Auto-generates 8-digit barcodes for empty fields & skips invalid rows safely without crashing.',
                            icon: LucideIcons.uploadCloud,
                            accentColor: AppColors.warning,
                            buttonLabel: 'SELECT & IMPORT CSV',
                            isLoading: state is DataIoLoading && state.operation.contains('Import'),
                            onTap: () => _handlePickAndImportCsv(context),
                          ),

                          // State Feedback Section
                          if (state is DataIoLoading) ...[
                            const SizedBox(height: AppDimensions.space16),
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.space16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevatedDark,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                border: Border.all(color: primaryColor.withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: AppDimensions.space12),
                                  Expanded(
                                    child: Text(
                                      state.operation,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (state is DataIoError) ...[
                            const SizedBox(height: AppDimensions.space16),
                            Container(
                              padding: const EdgeInsets.all(AppDimensions.space12),
                              decoration: BoxDecoration(
                                color: AppColors.danger.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                                border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.circleAlert, color: AppColors.danger, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(color: AppColors.danger, fontSize: 12.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          if (state is DataIoSuccess) ...[
                            const SizedBox(height: AppDimensions.space16),
                            _SuccessResultView(state: state),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: AppDimensions.space16),
                  const Divider(color: AppColors.borderDark, height: 1),
                  const SizedBox(height: AppDimensions.space12),

                  // Bottom Close Button
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(LucideIcons.check, size: 16),
                      label: const Text('DONE'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String buttonLabel;
  final bool isLoading;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.buttonLabel,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryDark),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.space12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
            ),
            onPressed: isLoading ? null : onTap,
            child: isLoading
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    buttonLabel,
                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }
}

class _SuccessResultView extends StatelessWidget {
  final DataIoSuccess state;

  const _SuccessResultView({required this.state});

  @override
  Widget build(BuildContext context) {
    final importResult = state.importResult;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.circleCheck, color: AppColors.success, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  state.message,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          if (state.filePath != null) ...[
            const SizedBox(height: 4),
            Text(
              'File: ${state.filePath}',
              style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
              overflow: TextOverflow.ellipsis,
            ),
          ],
          if (importResult != null) ...[
            const SizedBox(height: AppDimensions.space12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text('Successfully Imported', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark)),
                        const SizedBox(height: 2),
                        Text(
                          '${importResult.successCount}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.success),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: importResult.failCount > 0
                          ? AppColors.danger.withValues(alpha: 0.12)
                          : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(
                        color: importResult.failCount > 0
                            ? AppColors.danger.withValues(alpha: 0.3)
                            : AppColors.borderDark,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Text('Skipped / Errors', style: TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark)),
                        const SizedBox(height: 2),
                        Text(
                          '${importResult.failCount}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: importResult.failCount > 0 ? AppColors.danger : AppColors.textMutedDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (importResult.hasErrors) ...[
              const SizedBox(height: AppDimensions.space8),
              const Text(
                'Skipped Rows Log:',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.warning),
              ),
              const SizedBox(height: 4),
              Container(
                constraints: const BoxConstraints(maxHeight: 120),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: importResult.errorMessages.length,
                  itemBuilder: (context, idx) {
                    return Text(
                      '• ${importResult.errorMessages[idx]}',
                      style: const TextStyle(fontSize: 10.5, fontFamily: 'monospace', color: AppColors.danger),
                    );
                  },
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
