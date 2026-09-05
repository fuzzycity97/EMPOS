import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../domain/entities/medical_risk_factor.dart';
import '../../domain/entities/patient_profile.dart';
import '../bloc/clinic_bloc.dart';
import '../bloc/clinic_event.dart';
import '../bloc/clinic_state.dart';
import 'medical_risk_factor_manager_dialog.dart';

/// Modal dialog allowing both Receptionist and Doctor to view and edit
/// a patient's foundational medical status & chronic conditions history
/// with dynamically configurable clinical indicators.
/// 100% StatelessWidget compliant.
class PatientMedicalHistoryDialog extends StatelessWidget {
  final PatientProfile patient;
  final ClinicBloc bloc;
  final bool isDark;
  final List<MedicalRiskFactor>? riskFactors;

  final ValueNotifier<Set<String>> selectedFactorsNotifier;
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
    this.riskFactors,
  })  : selectedFactorsNotifier = ValueNotifier<Set<String>>(Set.from(patient.chronicConditions)),
        diabetesNotifier = ValueNotifier<bool>(
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
    final activeRiskFactors = riskFactors ??
        (bloc.state is ClinicLoaded ? (bloc.state as ClinicLoaded).riskFactors : MedicalRiskFactor.defaultFactors);

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
                        Text(
                          '${patient.name} • Tel: ${patient.phone.isNotEmpty ? patient.phone : "Not recorded"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.textSecondaryDark : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 20, color: AppColors.textMutedDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Patient Age Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13),
                      decoration: InputDecoration(
                        labelText: 'Patient Age (Years)',
                        hintText: 'e.g. 35',
                        prefixIcon: const Icon(LucideIcons.calendar, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space16),

              // Core Clinical Risk Toggles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Clinical Risk Indicators & Lifestyle Factors',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => BlocProvider.value(
                          value: bloc,
                          child: MedicalRiskFactorManagerDialog(currentFactors: activeRiskFactors),
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(LucideIcons.settings2, size: 14, color: AppColors.primaryLight),
                        SizedBox(width: 4),
                        Text(
                          'Manage Factors',
                          style: TextStyle(fontSize: 11, color: AppColors.primaryLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space8),
              ValueListenableBuilder<Set<String>>(
                valueListenable: selectedFactorsNotifier,
                builder: (context, selectedConditions, _) {
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: activeRiskFactors.where((f) => f.isEnabled).map((factor) {
                      final isSelected = selectedConditions.any((c) =>
                          c.toLowerCase() == factor.label.toLowerCase() ||
                          factor.label.toLowerCase().contains(c.toLowerCase()) ||
                          c.toLowerCase().contains(factor.label.toLowerCase()));
                      return FilterChip(
                        avatar: Icon(factor.iconData, size: 14, color: isSelected ? factor.color : (isDark ? Colors.white70 : Colors.black54)),
                        label: Text(factor.label),
                        selected: isSelected,
                        onSelected: (val) {
                          final updated = Set<String>.from(selectedConditions);
                          if (val) {
                            updated.add(factor.label);
                          } else {
                            updated.removeWhere((c) =>
                                c.toLowerCase() == factor.label.toLowerCase() ||
                                factor.label.toLowerCase().contains(c.toLowerCase()) ||
                                c.toLowerCase().contains(factor.label.toLowerCase()));
                          }
                          selectedFactorsNotifier.value = updated;
                          if (factor.label.toLowerCase().contains('diabet')) diabetesNotifier.value = val;
                          if (factor.label.toLowerCase().contains('smok')) smokingNotifier.value = val;
                          if (factor.label.toLowerCase().contains('hyper')) hypertensionNotifier.value = val;
                          if (factor.label.toLowerCase().contains('heart')) heartDiseaseNotifier.value = val;
                          if (factor.label.toLowerCase().contains('bleed')) bleedingRiskNotifier.value = val;
                          if (factor.label.toLowerCase().contains('asthma')) asthmaNotifier.value = val;
                          if (factor.label.toLowerCase().contains('pregnan')) pregnantNotifier.value = val;
                        },
                        selectedColor: factor.color.withValues(alpha: 0.3),
                        checkmarkColor: factor.color,
                        labelStyle: TextStyle(
                          color: isSelected ? factor.color : (isDark ? Colors.white70 : Colors.black87),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 11,
                        ),
                        backgroundColor: isDark ? AppColors.surfaceElevatedDark : Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color: isSelected ? factor.color : (isDark ? AppColors.borderDark : Colors.black12),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
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
                      final updatedConditions = <String>[...selectedFactorsNotifier.value];
                      if (diabetesNotifier.value && !updatedConditions.any((c) => c.toLowerCase().contains('diabet'))) {
                        updatedConditions.add('Diabetes');
                      }
                      if (smokingNotifier.value && !updatedConditions.any((c) => c.toLowerCase().contains('smok'))) {
                        updatedConditions.add('Smoking / Tobacco');
                      }
                      if (hypertensionNotifier.value && !updatedConditions.any((c) => c.toLowerCase().contains('hyper'))) {
                        updatedConditions.add('Hypertension (High BP)');
                      }
                      if (heartDiseaseNotifier.value && !updatedConditions.any((c) => c.toLowerCase().contains('heart'))) {
                        updatedConditions.add('Heart Disease');
                      }
                      if (bleedingRiskNotifier.value && !updatedConditions.any((c) => c.toLowerCase().contains('bleed'))) {
                        updatedConditions.add('Bleeding Risk / Anticoagulants');
                      }
                      if (asthmaNotifier.value && !updatedConditions.any((c) => c.toLowerCase().contains('asthma'))) {
                        updatedConditions.add('Asthma / Respiratory');
                      }
                      if (pregnantNotifier.value && !updatedConditions.any((c) => c.toLowerCase().contains('pregnan'))) {
                        updatedConditions.add('Pregnancy / Nursing');
                      }

                      final extra = otherNotesController.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty);
                      for (final ex in extra) {
                        if (!updatedConditions.contains(ex)) updatedConditions.add(ex);
                      }

                      final allergies = allergiesController.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList();

                      final medications = medicationsController.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
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
}
