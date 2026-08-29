import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

enum MedicalAttachmentType {
  xrayRadiograph,
  dicomScan,
  ultrasound,
  labReport,
  prescriptionPhoto,
}

class MedicalAttachment {
  final String id;
  final String title;
  final MedicalAttachmentType type;
  final DateTime uploadDate;
  final String fileSize;
  final String doctorNotes;

  const MedicalAttachment({
    required this.id,
    required this.title,
    required this.type,
    required this.uploadDate,
    required this.fileSize,
    required this.doctorNotes,
  });
}

/// Medical attachments dock and radiograph lightbox viewer for Doctor Station.
/// 100% [StatelessWidget] following pure Clean Architecture.
class DoctorAttachmentsLightbox extends StatelessWidget {
  final ValueNotifier<List<MedicalAttachment>> attachmentsNotifier;
  final ValueNotifier<MedicalAttachment?> activeViewingNotifier;
  final ValueNotifier<double> zoomNotifier;
  final ValueNotifier<int> rotationNotifier;
  final ValueNotifier<bool> invertGrayscaleNotifier;

  DoctorAttachmentsLightbox({
    super.key,
    ValueNotifier<List<MedicalAttachment>>? attachmentsNotifier,
    ValueNotifier<MedicalAttachment?>? activeViewingNotifier,
    ValueNotifier<double>? zoomNotifier,
    ValueNotifier<int>? rotationNotifier,
    ValueNotifier<bool>? invertGrayscaleNotifier,
  })  : attachmentsNotifier = attachmentsNotifier ??
            ValueNotifier<List<MedicalAttachment>>(_defaultAttachments),
        activeViewingNotifier =
            activeViewingNotifier ?? ValueNotifier<MedicalAttachment?>(null),
        zoomNotifier = zoomNotifier ?? ValueNotifier<double>(1.0),
        rotationNotifier = rotationNotifier ?? ValueNotifier<int>(0),
        invertGrayscaleNotifier =
            invertGrayscaleNotifier ?? ValueNotifier<bool>(false);

  static final List<MedicalAttachment> _defaultAttachments = [
    MedicalAttachment(
      id: 'att_1',
      title: 'Periapical X-Ray Tooth #19 & #20',
      type: MedicalAttachmentType.xrayRadiograph,
      uploadDate: DateTime.now().subtract(const Duration(hours: 2)),
      fileSize: '4.2 MB',
      doctorNotes: 'Shows deep radiolucency on distal root apex #19. Requires root canal therapy.',
    ),
    MedicalAttachment(
      id: 'att_2',
      title: 'Panoramic OPG Radiograph Scan',
      type: MedicalAttachmentType.dicomScan,
      uploadDate: DateTime.now().subtract(const Duration(days: 1)),
      fileSize: '18.5 MB',
      doctorNotes: 'Full maxillary & mandibular survey. Impacted third molar #32 noted.',
    ),
    MedicalAttachment(
      id: 'att_3',
      title: 'Complete Blood Count (CBC) Lab Panel',
      type: MedicalAttachmentType.labReport,
      uploadDate: DateTime.now().subtract(const Duration(days: 3)),
      fileSize: '650 KB',
      doctorNotes: 'WBC 8.4 (Normal), Platelets 260K (Normal). Cleared for surgical extraction.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── HEADER ────────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  const Icon(LucideIcons.fileImage, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Medical Imaging & Attachments Dock',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(LucideIcons.upload, size: 14),
                    label: const Text('Attach X-Ray / DICOM', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () => _simulateAddAttachment(context),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.borderDark),

          // ── ATTACHMENTS LIST DOCK ──────────────────────────────────────────
          ValueListenableBuilder<List<MedicalAttachment>>(
            valueListenable: attachmentsNotifier,
            builder: (context, attachments, _) {
              if (attachments.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No attachments uploaded for active patient session.',
                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: 110,
                child: ListView.separated(
                  padding: const EdgeInsets.all(10),
                  scrollDirection: Axis.horizontal,
                  itemCount: attachments.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, idx) {
                    final item = attachments[idx];
                    return _buildAttachmentThumbnail(context, item);
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentThumbnail(BuildContext context, MedicalAttachment item) {
    IconData icon;
    Color color;

    switch (item.type) {
      case MedicalAttachmentType.xrayRadiograph:
      case MedicalAttachmentType.dicomScan:
        icon = LucideIcons.scanLine;
        color = AppColors.info;
        break;
      case MedicalAttachmentType.ultrasound:
        icon = LucideIcons.activity;
        color = AppColors.primary;
        break;
      case MedicalAttachmentType.labReport:
        icon = LucideIcons.flaskConical;
        color = AppColors.warning;
        break;
      case MedicalAttachmentType.prescriptionPhoto:
        icon = LucideIcons.fileSignature;
        color = AppColors.success;
        break;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      onTap: () => _openLightboxViewer(context, item),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Center(
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Text(
                          item.fileSize,
                          style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark, fontFamily: 'JetBrains Mono'),
                        ),
                        const SizedBox(width: 6),
                        const Text('•', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryDark)),
                        const SizedBox(width: 6),
                        const Text(
                          'View Full',
                          style: TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openLightboxViewer(BuildContext context, MedicalAttachment item) {
    zoomNotifier.value = 1.0;
    rotationNotifier.value = 0;
    invertGrayscaleNotifier.value = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF020617),
          insetPadding: const EdgeInsets.all(24),
          child: Container(
            width: 900,
            height: 650,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                // ── LIGHTBOX HEADER & CONTROLS ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.info.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(LucideIcons.scanLine, size: 16, color: AppColors.info),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            'Digital Radiograph / DICOM Lightbox Viewer • ${item.fileSize}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                      const Spacer(),

                      // Zoom Out
                      IconButton(
                        tooltip: 'Zoom Out',
                        icon: const Icon(LucideIcons.zoomOut, size: 18, color: Colors.white),
                        onPressed: () {
                          if (zoomNotifier.value > 0.6) {
                            zoomNotifier.value -= 0.2;
                          }
                        },
                      ),
                      // Zoom In
                      IconButton(
                        tooltip: 'Zoom In',
                        icon: const Icon(LucideIcons.zoomIn, size: 18, color: Colors.white),
                        onPressed: () {
                          if (zoomNotifier.value < 3.0) {
                            zoomNotifier.value += 0.2;
                          }
                        },
                      ),
                      // Rotate
                      IconButton(
                        tooltip: 'Rotate 90°',
                        icon: const Icon(LucideIcons.rotateCw, size: 18, color: Colors.white),
                        onPressed: () {
                          rotationNotifier.value = (rotationNotifier.value + 1) % 4;
                        },
                      ),
                      // Invert Grayscale
                      ValueListenableBuilder<bool>(
                        valueListenable: invertGrayscaleNotifier,
                        builder: (context, isInverted, _) {
                          return IconButton(
                            tooltip: 'Invert Radiograph Contrast',
                            icon: Icon(
                              LucideIcons.contrast,
                              size: 18,
                              color: isInverted ? AppColors.warning : Colors.white,
                            ),
                            onPressed: () {
                              invertGrayscaleNotifier.value = !isInverted;
                            },
                          );
                        },
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textSecondaryDark),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.borderDark),

                // ── LIGHTBOX INSPECTION VIEWPORT ────────────────────────────
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: ValueListenableBuilder<double>(
                        valueListenable: zoomNotifier,
                        builder: (context, zoom, _) {
                          return ValueListenableBuilder<int>(
                            valueListenable: rotationNotifier,
                            builder: (context, rot, _) {
                              return ValueListenableBuilder<bool>(
                                valueListenable: invertGrayscaleNotifier,
                                builder: (context, isInverted, _) {
                                  return Transform.rotate(
                                    angle: rot * 1.5708, // 90 degrees in radians
                                    child: Transform.scale(
                                      scale: zoom,
                                      child: ColorFiltered(
                                        colorFilter: isInverted
                                            ? const ColorFilter.matrix([
                                                -1, 0, 0, 0, 255,
                                                0, -1, 0, 0, 255,
                                                0, 0, -1, 0, 255,
                                                0, 0, 0, 1, 0,
                                              ])
                                            : const ColorFilter.mode(
                                                Colors.transparent,
                                                BlendMode.dst,
                                              ),
                                        child: _buildSimulatedRadiograph(item),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ── DIAGNOSTIC NOTES BAR ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: const BoxDecoration(
                    color: Color(0xFF0F172A),
                    border: Border(top: BorderSide(color: AppColors.borderDark)),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.stethoscope, size: 16, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Practitioner Findings: ${item.doctorNotes}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSimulatedRadiograph(MedicalAttachment item) {
    return Container(
      width: 480,
      height: 380,
      decoration: BoxDecoration(
        color: const Color(0xFF111827),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Grayscale Radiograph Grid & Bone Silhouette Simulation
          CustomPaint(
            size: const Size(480, 380),
            painter: _RadiographSilhouettePainter(),
          ),
          Positioned(
            bottom: 12,
            left: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                    letterSpacing: 1,
                  ),
                ),
                const Text(
                  'DICOM 3.0 RVG • 16-BIT GRAYSCALE • 40 KVp / 7 mA',
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, color: Colors.white54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _simulateAddAttachment(BuildContext context) {
    final list = List<MedicalAttachment>.from(attachmentsNotifier.value);
    list.insert(
      0,
      MedicalAttachment(
        id: 'att_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Bite-Wing Radiograph #${list.length + 1}',
        type: MedicalAttachmentType.xrayRadiograph,
        uploadDate: DateTime.now(),
        fileSize: '3.8 MB',
        doctorNotes: 'Freshly attached radiograph from intraoral sensor.',
      ),
    );
    attachmentsNotifier.value = list;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Attached digital radiograph to patient consultation file.'),
        backgroundColor: AppColors.success,
      ),
    );
  }
}

class _RadiographSilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bonePaint = Paint()
      ..color = const Color(0xFFCBD5E1).withValues(alpha: 0.85)
      ..style = PaintingStyle.fill;

    final rootPaint = Paint()
      ..color = const Color(0xFF94A3B8).withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    // Draw simulated tooth crowns
    for (int i = 0; i < 4; i++) {
      final cx = 90.0 + (i * 95.0);
      final cy = 150.0;

      // Crown
      final crownRRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 70, height: 60),
        const Radius.circular(12),
      );
      canvas.drawRRect(crownRRect, bonePaint);

      // Roots
      final root1 = Rect.fromLTWH(cx - 26, cy + 30, 18, 90);
      final root2 = Rect.fromLTWH(cx + 8, cy + 30, 18, 90);
      canvas.drawRRect(RRect.fromRectAndRadius(root1, const Radius.circular(8)), rootPaint);
      canvas.drawRRect(RRect.fromRectAndRadius(root2, const Radius.circular(8)), rootPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
