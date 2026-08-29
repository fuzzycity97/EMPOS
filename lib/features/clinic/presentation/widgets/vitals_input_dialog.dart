import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/clinic_visit.dart';

/// Modal dialog allowing clinical staff/doctors to update patient vitals in real time.
/// 100% [StatelessWidget] following pure Clean Architecture.
class VitalsInputDialog extends StatelessWidget {
  final ClinicVisit visit;
  final TextEditingController bpController;
  final TextEditingController hrController;
  final TextEditingController spo2Controller;
  final TextEditingController tempController;
  final TextEditingController respController;
  final void Function({
    required String bloodPressure,
    required String heartRate,
    required String spo2,
    required String temperature,
    required String respiratoryRate,
  }) onSave;

  VitalsInputDialog({
    super.key,
    required this.visit,
    required this.onSave,
    TextEditingController? bpController,
    TextEditingController? hrController,
    TextEditingController? spo2Controller,
    TextEditingController? tempController,
    TextEditingController? respController,
  })  : bpController = bpController ?? TextEditingController(text: visit.bloodPressure),
        hrController = hrController ?? TextEditingController(text: visit.heartRate),
        spo2Controller = spo2Controller ?? TextEditingController(text: visit.spo2),
        tempController = tempController ?? TextEditingController(text: visit.temperature),
        respController = respController ?? TextEditingController(text: visit.respiratoryRate);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(LucideIcons.activity, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Update Patient Vitals',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Recording vitals for: ${visit.patientName}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18, color: AppColors.textSecondaryDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space20),

              // Blood Pressure & Heart Rate Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: bpController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Blood Pressure',
                        hintText: 'e.g. 120/80 mmHg',
                        prefixIcon: Icon(LucideIcons.gauge, size: 18, color: Colors.purple),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: TextField(
                      controller: hrController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Heart Rate',
                        hintText: 'e.g. 76 BPM',
                        prefixIcon: Icon(LucideIcons.heartPulse, size: 18, color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // SpO2 & Temperature Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: spo2Controller,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Blood Oxygen (SpO2)',
                        hintText: 'e.g. 99%',
                        prefixIcon: Icon(LucideIcons.wind, size: 18, color: Colors.teal),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: TextField(
                      controller: tempController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Temperature',
                        hintText: 'e.g. 36.8 °C',
                        prefixIcon: Icon(LucideIcons.thermometer, size: 18, color: Colors.amber),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Respiratory Rate
              TextField(
                controller: respController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Respiratory Rate',
                  hintText: 'e.g. 16 bpm',
                  prefixIcon: Icon(LucideIcons.timer, size: 18, color: Colors.blue),
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark)),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(LucideIcons.check, size: 16, color: Colors.white),
                    label: const Text(
                      'Save Vitals',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final bp = bpController.text.trim();
                      final hr = hrController.text.trim();
                      final spo2 = spo2Controller.text.trim();
                      final temp = tempController.text.trim();
                      final resp = respController.text.trim();

                      onSave(
                        bloodPressure: bp.isNotEmpty ? bp : '120/80 mmHg',
                        heartRate: hr.isNotEmpty ? hr : '76 BPM',
                        spo2: spo2.isNotEmpty ? spo2 : '99%',
                        temperature: temp.isNotEmpty ? temp : '36.8 °C',
                        respiratoryRate: resp.isNotEmpty ? resp : '16 bpm',
                      );

                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
