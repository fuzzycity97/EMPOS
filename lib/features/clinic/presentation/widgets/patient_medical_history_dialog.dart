import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/patient_profile.dart';
import '../bloc/clinic_bloc.dart';
import '../bloc/clinic_event.dart';

/// Modal dialog allowing both Receptionist and Doctor to view and edit
/// a patient''s foundational medical status & chronic conditions history
/// (e.g. Diabetes, Smoking, Hypertension, Heart Disease, Allergies).
/// 100% StatelessWidget compliant.
class PatientMedicalHistoryDialog extends StatelessWidget {
  final PatientProfile patient;
  final ClinicBloc bloc;
  final bool isDark;

  final ValueNotifier<bool> diabetesNotifier;
  final ValueNotifier<bool> smokingNotifier;
  final ValueNotifier<bool> hypertensionNotifier;
  final ValueNotifier<bool> heartDiseaseNotifier;
  final ValueNotifier<bool> bleedingRiskNotifier;
  final ValueNotifier<bool> asthmaNotifier;
  final ValueNotifier<bool> pregnantNotifier;
  final TextEditingController allergiesController;
  final TextEditingController medicationsController;
  final TextEditingController otherNotesController;
  final TextEditingController ageController;

  PatientMedicalHistoryDialog({
    super.key,
    required this.patient,
    required this.bloc,
    this.isDark = true,
  })  : diabetesNotifier = ValueNotifier<bool>(
          patient.chronicConditions.any((c) => c.toLowerCase().contains('diabet')),
        ),
        smokingNotifier = ValueNotifier<bool>(
          patient.chronicConditions.any((c) => c.toLowerCase().contains('smok')),
        ),
        hypertensionNotifier = ValueNotifier<bool>(
          patient.chronicConditions.any((c) => c.toLowerCase().contains('hyper') || c.toLowerCase().contains('high bp')),
        ),
        heartDiseaseNotifier = ValueNotifier<bool>(
          patient.chronicConditions.any((c) => c.toLowerCase().contains('heart') || c.toLowerCase().contains('cardio')),
        ),
        bleedingRiskNotifier = ValueNotifier<bool>(
          patient.chronicConditions.any((c) => c.toLowerCase().contains('bleed') || c.toLowerCase().contains('anticoag')),
        ),
        asthmaNotifier = ValueNotifier<bool>(
          patient.chronicConditions.any((c) => c.toLowerCase().contains('asthma') || c.toLowerCase().contains('resp')),
        ),
        pregnantNotifier = ValueNotifier<bool>(
          patient.chronicConditions.any((c) => c.toLowerCase().contains('pregnan') || c.toLowerCase().contains('nurs')),
        ),
        allergiesController = TextEditingController(text: patient.allergies.join(', ')),
        medicationsController = TextEditingController(text: patient.currentMedications.join(', ')),
        otherNotesController = TextEditingController(
          text: patient.chronicConditions
              .where((c) =>
                  !c.toLowerCase().contains('diabet') &&
                  !c.toLowerCase().contains('smok') &&
                  !c.toLowerCase().contains('hyper') &&
                  !c.toLowerCase().contains('high bp') &&
                  !c.toLowerCase().contains('heart') &&
                  !c.toLowerCase().contains('cardio') &&
                  !c.toLowerCase().contains('bleed') &&
                  !c.toLowerCase().contains('anticoag') &&
                  !c.toLowerCase().contains('asthma') &&
                  !c.toLowerCase().contains('resp') &&
                  !c.toLowerCase().contains('pregnan') &&
                  !c.toLowerCase().contains('nurs'))
              .join(', '),
        ),
        ageController = TextEditingController(
          text: patient.calculatedAge?.toString() ?? patient.dateOfBirth ?? '',
        );

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: BorderSide(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: SingleChildScrollView(
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
                    child: const Icon(LucideIcons.heartPulse, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Medical Status & History',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${patient.name} • Tel: ${patient.phone.isNotEmpty ? patient.phone : "N/A"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(LucideIcons.x, size: 18, color: isDark ? AppColors.textSecondaryDark : Colors.black54),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Age Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Patient Age (Years)',
                        hintText: 'e.g. 42',
                        prefixIcon: const Icon(LucideIcons.calendar, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Core Clinical Risk Toggles
              Text(
                'Clinical Risk Indicators & Lifestyle Factors',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: AppDimensions.space8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildToggleChip('Diabetes', LucideIcons.activity, diabetesNotifier, Colors.amber),
                  _buildToggleChip('Smoking / Tobacco', LucideIcons.cigarette, smokingNotifier, Colors.orange),
                  _buildToggleChip('Hypertension (High BP)', LucideIcons.heartPulse, hypertensionNotifier, Colors.red),
                  _buildToggleChip('Heart Disease', LucideIcons.heart, heartDiseaseNotifier, Colors.deepOrange),
                  _buildToggleChip('Bleeding Risk / Anticoagulants', LucideIcons.droplet, bleedingRiskNotifier, Colors.purple),
                  _buildToggleChip('Asthma / Respiratory', LucideIcons.wind, asthmaNotifier, Colors.teal),
                  _buildToggleChip('Pregnancy / Nursing', LucideIcons.baby, pregnantNotifier, Colors.pink),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Known Allergies
              TextField(
                controller: allergiesController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Known Drug & Material Allergies (Comma-separated)',
                  hintText: 'e.g. Penicillin, Sulfa, Latex, NSAIDs',
                  prefixIcon: const Icon(LucideIcons.triangleAlert, size: 18, color: AppColors.error),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Current Medications
              TextField(
                controller: medicationsController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Current Medications (Comma-separated)',
                  hintText: 'e.g. Metformin 500mg, Lisinopril 10mg, Aspirin',
                  prefixIcon: const Icon(LucideIcons.pill, size: 18, color: AppColors.secondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Other Chronic Conditions / Medical Notes
              TextField(
                controller: otherNotesController,
                maxLines: 2,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Other Chronic Conditions / Clinical Background',
                  hintText: 'e.g. Renal impairment, Thyroid disorders, previous surgeries',
                  prefixIcon: const Icon(LucideIcons.fileText, size: 18),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(height: AppDimensions.space20),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cancel', style: TextStyle(color: isDark ? AppColors.textSecondaryDark : Colors.black54)),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    icon: const Icon(LucideIcons.check, size: 16),
                    label: const Text('Save Medical History', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () {
                      final updatedConditions = <String>[];
                      if (diabetesNotifier.value) updatedConditions.add('Diabetes');
                      if (smokingNotifier.value) updatedConditions.add('Smoking');
                      if (hypertensionNotifier.value) updatedConditions.add('Hypertension');
                      if (heartDiseaseNotifier.value) updatedConditions.add('Heart Disease');
                      if (bleedingRiskNotifier.value) updatedConditions.add('Bleeding Risk');
                      if (asthmaNotifier.value) updatedConditions.add('Asthma');
                      if (pregnantNotifier.value) updatedConditions.add('Pregnancy/Nursing');

                      final extra = otherNotesController.text
                          .split(',')
                          .map((s) => s.trim())
                          .filter((s) => s.isNotEmpty);
                      updatedConditions.addAll(extra);

                      final allergies = allergiesController.text
                          .split(',')
                          .map((s) => s.trim())
                          .filter((s) => s.isNotEmpty)
                          .toList();

                      final medications = medicationsController.text
                          .split(',')
                          .map((s) => s.trim())
                          .filter((s) => s.isNotEmpty)
                          .toList();

                      final ageText = ageController.text.trim();

                      final updated = patient.copyWith(
                        dateOfBirth: ageText.isNotEmpty ? ageText : patient.dateOfBirth,
                        chronicConditions: updatedConditions,
                        allergies: allergies,
                        currentMedications: medications,
                      );

                      bloc.add(UpdatePatientProfileEvent(updated));
                      Navigator.of(context).pop();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Medical history updated for ${patient.name}'),
                          backgroundColor: AppColors.success,
                        ),
                      );
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

  Widget _buildToggleChip(
    String label,
    IconData icon,
    ValueNotifier<bool> notifier,
    Color activeColor,
  ) {
    return ValueListenableBuilder<bool>(
      valueListenable: notifier,
      builder: (context, isActive, _) {
        return FilterChip(
          avatar: Icon(icon, size: 14, color: isActive ? activeColor : (isDark ? Colors.white70 : Colors.black87)),
          label: Text(label),
          selected: isActive,
          onSelected: (val) => notifier.value = val,
          selectedColor: activeColor.withValues(alpha: 0.25),
          checkmarkColor: activeColor,
          labelStyle: TextStyle(
            color: isActive ? activeColor : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 12,
          ),
          backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isActive ? activeColor : (isDark ? Colors.white10 : Colors.black12),
            ),
          ),
        );
      },
    );
  }
}

extension _FilterExt on Iterable<String> {
  Iterable<String> filter(bool Function(String) test) => where(test);
}
