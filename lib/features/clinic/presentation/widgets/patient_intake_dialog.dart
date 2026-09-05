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

/// Patient intake and queue check-in modal dialog.
/// Supports returning patient search/autocomplete by phone or name,
/// dynamic configurable risk factors, and allergies.
/// Follows strict Clean Architecture and is 100% [StatelessWidget].
class PatientIntakeDialog extends StatelessWidget {
  final ClinicBloc? bloc;
  final List<PatientProfile> existingPatients;
  final List<MedicalRiskFactor>? riskFactors;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController complaintController;
  final TextEditingController allergiesController;
  final ValueNotifier<String> doctorNotifier;
  final ValueNotifier<String?> selectedPatientIdNotifier;
  final ValueNotifier<Set<String>> selectedConditionsNotifier;
  final ValueNotifier<bool> diabetesNotifier;
  final ValueNotifier<bool> smokingNotifier;
  final ValueNotifier<bool> hypertensionNotifier;

  PatientIntakeDialog({
    super.key,
    this.bloc,
    this.existingPatients = const [],
    this.riskFactors,
    TextEditingController? nameController,
    TextEditingController? ageController,
    TextEditingController? phoneController,
    TextEditingController? complaintController,
    TextEditingController? allergiesController,
    ValueNotifier<String>? doctorNotifier,
    ValueNotifier<String?>? selectedPatientIdNotifier,
    ValueNotifier<Set<String>>? selectedConditionsNotifier,
    ValueNotifier<bool>? diabetesNotifier,
    ValueNotifier<bool>? smokingNotifier,
    ValueNotifier<bool>? hypertensionNotifier,
  })  : nameController = nameController ?? TextEditingController(),
        ageController = ageController ?? TextEditingController(),
        phoneController = phoneController ?? TextEditingController(),
        complaintController = complaintController ?? TextEditingController(),
        allergiesController = allergiesController ?? TextEditingController(),
        doctorNotifier = doctorNotifier ?? ValueNotifier<String>('usr_doctor'),
        selectedPatientIdNotifier = selectedPatientIdNotifier ?? ValueNotifier<String?>(null),
        selectedConditionsNotifier = selectedConditionsNotifier ?? ValueNotifier<Set<String>>({
          if (diabetesNotifier?.value == true) 'Diabetes',
          if (smokingNotifier?.value == true) 'Smoking / Tobacco',
          if (hypertensionNotifier?.value == true) 'Hypertension',
        }),
        diabetesNotifier = diabetesNotifier ?? ValueNotifier<bool>(false),
        smokingNotifier = smokingNotifier ?? ValueNotifier<bool>(false),
        hypertensionNotifier = hypertensionNotifier ?? ValueNotifier<bool>(false);

  // Seeded doctor accounts for deterministic LAN routing
  static const List<Map<String, String>> doctors = [
    {'id': 'usr_doctor', 'name': 'Dr. Sarah Connor (General / Dental Lead)'},
    {'id': 'usr_doctor_tarek', 'name': 'Dr. Tarek Dental Specialist'},
    {'id': 'usr_doctor_oncall', 'name': 'Dr. On-Call Physician'},
  ];

  void _populatePatientData(PatientProfile patient) {
    selectedPatientIdNotifier.value = patient.id;
    nameController.text = patient.name;
    phoneController.text = patient.phone;

    // Resolve age from calculated age or stored date of birth / age string
    final resolvedAge = patient.calculatedAge?.toString() ?? patient.dateOfBirth;
    if (resolvedAge != null && resolvedAge.isNotEmpty) {
      ageController.text = resolvedAge;
    }

    // Populate medical history flags
    final conditions = patient.chronicConditions;
    selectedConditionsNotifier.value = Set.from(conditions);
    diabetesNotifier.value = conditions.any((c) => c.toLowerCase().contains('diabet'));
    smokingNotifier.value = conditions.any((c) => c.toLowerCase().contains('smok'));
    hypertensionNotifier.value = conditions.any((c) => c.toLowerCase().contains('hyper') || c.toLowerCase().contains('bp'));
    allergiesController.text = patient.allergies.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final activeBloc = bloc ?? context.read<ClinicBloc>();
    final state = activeBloc.state;
    final activeRiskFactors = riskFactors ??
        (state is ClinicLoaded ? state.riskFactors : MedicalRiskFactor.defaultFactors);

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
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
                    child: const Icon(LucideIcons.userPlus, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Patient Intake & Check-In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Register queue ticket with complete medical history',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
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
              const SizedBox(height: AppDimensions.space16),

              // Returning Patient Search Field
              if (existingPatients.isNotEmpty) ...[
                Autocomplete<PatientProfile>(
                  displayStringForOption: (p) => '${p.name} (${p.phone.isNotEmpty ? p.phone : "No Phone"})',
                  optionsBuilder: (textEditingValue) {
                    final query = textEditingValue.text.toLowerCase().trim();
                    if (query.isEmpty) {
                      return const Iterable<PatientProfile>.empty();
                    }
                    return existingPatients.where(
                      (p) => p.name.toLowerCase().contains(query) || p.phone.contains(query),
                    );
                  },
                  onSelected: _populatePatientData,
                  fieldViewBuilder: (context, searchController, focusNode, onFieldSubmitted) {
                    return TextField(
                      controller: searchController,
                      focusNode: focusNode,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Search Returning Patient (Phone / Name)',
                        hintText: 'Type phone or name to autofill existing profile...',
                        prefixIcon: Icon(LucideIcons.search, size: 18, color: AppColors.primaryLight),
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.space12),
              ],

              // Patient Name
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Patient Full Name *',
                  hintText: 'e.g. Johnathan Doe',
                  prefixIcon: Icon(LucideIcons.user, size: 18),
                ),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Age & Phone Number Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: ageController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Age (Years)',
                        hintText: 'e.g. 34',
                        prefixIcon: Icon(LucideIcons.calendar, size: 18),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          controller: phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            hintText: 'e.g. +20 100 123 4567',
                            prefixIcon: Icon(LucideIcons.phone, size: 18),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: Listenable.merge([phoneController, selectedPatientIdNotifier]),
                          builder: (context, _) {
                            final rawPhone = phoneController.text.trim();
                            if (rawPhone.isEmpty) return const SizedBox.shrink();

                            final allPatients = (state is ClinicLoaded) ? state.patients : <PatientProfile>[];
                            final duplicate = allPatients.cast<PatientProfile?>().firstWhere(
                              (p) => p != null && p.phone.trim() == rawPhone && p.id != selectedPatientIdNotifier.value,
                              orElse: () => null,
                            );

                            if (duplicate == null) return const SizedBox.shrink();

                            return Container(
                              margin: const EdgeInsets.only(top: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(LucideIcons.alertCircle, size: 14, color: Colors.redAccent),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Already registered to "${duplicate.name}"',
                                      style: const TextStyle(fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  TextButton(
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    ),
                                    onPressed: () => _populatePatientData(duplicate),
                                    child: const Text('Select', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.amber)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Patient Medical Status & Risk History
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(LucideIcons.heartPulse, size: 16, color: AppColors.primaryLight),
                        SizedBox(width: 8),
                        Text(
                          'Patient Medical Status & Risk History',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ValueListenableBuilder<Set<String>>(
                      valueListenable: selectedConditionsNotifier,
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
                              avatar: Icon(factor.iconData, size: 14, color: isSelected ? factor.color : Colors.white70),
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
                                selectedConditionsNotifier.value = updated;
                                if (factor.label.toLowerCase().contains('diabet')) diabetesNotifier.value = val;
                                if (factor.label.toLowerCase().contains('smok')) smokingNotifier.value = val;
                                if (factor.label.toLowerCase().contains('hyper')) hypertensionNotifier.value = val;
                              },
                              selectedColor: factor.color.withValues(alpha: 0.3),
                              checkmarkColor: factor.color,
                              labelStyle: TextStyle(
                                color: isSelected ? factor.color : Colors.white70,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                fontSize: 11,
                              ),
                              backgroundColor: AppColors.surfaceElevatedDark,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                                side: BorderSide(
                                  color: isSelected ? factor.color : AppColors.borderDark,
                                  width: isSelected ? 1.5 : 1.0,
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: allergiesController,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      decoration: const InputDecoration(
                        labelText: 'Known Drug Allergies',
                        hintText: 'e.g. Penicillin, Sulfa, None',
                        prefixIcon: Icon(LucideIcons.triangleAlert, size: 16, color: AppColors.error),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppDimensions.space12),

              // Assigned Doctor
              ValueListenableBuilder<String>(
                valueListenable: doctorNotifier,
                builder: (context, selectedDoctorId, _) {
                  return DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedDoctorId,
                    dropdownColor: AppColors.surfaceElevatedDark,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: const InputDecoration(
                      labelText: 'Assigned Doctor / Practitioner *',
                      prefixIcon: Icon(LucideIcons.stethoscope, size: 18),
                    ),
                    items: doctors.map((doc) {
                      return DropdownMenuItem<String>(
                        value: doc['id'],
                        child: Text(
                          doc['name']!,
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        doctorNotifier.value = val;
                      }
                    },
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space12),

              // Chief Complaint
              TextField(
                controller: complaintController,
                maxLines: 2,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  labelText: 'Chief Complaint / Reason for Visit',
                  hintText: 'e.g. Severe toothache on lower right quadrant, needs examination',
                  prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(LucideIcons.clipboardList, size: 18),
                  ),
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
                      'Check In Patient',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final age = ageController.text.trim();
                      final phone = phoneController.text.trim();
                      final complaint = complaintController.text.trim();
                      final doctorId = doctorNotifier.value;
                      final existingId = selectedPatientIdNotifier.value;

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter the patient full name.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      if (phone.isNotEmpty && existingId == null) {
                        final duplicate = existingPatients.cast<PatientProfile?>().firstWhere(
                          (p) => p != null && p.phone.trim() == phone,
                          orElse: () => null,
                        );
                        if (duplicate != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Phone number is already registered to "${duplicate.name}". Please confirm using existing profile.'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          _populatePatientData(duplicate);
                          return;
                        }
                      }

                      // Compile chronic conditions list
                      final chronicList = <String>[...selectedConditionsNotifier.value];
                      if (diabetesNotifier.value && !chronicList.any((c) => c.toLowerCase().contains('diabet'))) {
                        chronicList.add('Diabetes');
                      }
                      if (smokingNotifier.value && !chronicList.any((c) => c.toLowerCase().contains('smok'))) {
                        chronicList.add('Smoking');
                      }
                      if (hypertensionNotifier.value && !chronicList.any((c) => c.toLowerCase().contains('hyper'))) {
                        chronicList.add('Hypertension');
                      }

                      final allergiesList = allergiesController.text
                          .split(',')
                          .map((s) => s.trim())
                          .where((s) => s.isNotEmpty)
                          .toList();

                      // Build formatted complaint metadata if age/phone supplied
                      final detailsList = <String>[];
                      if (age.isNotEmpty) detailsList.add('Age: $age');
                      if (phone.isNotEmpty) detailsList.add('Tel: $phone');
                      final metaStr = detailsList.isNotEmpty ? ' [${detailsList.join(', ')}]' : '';
                      final fullComplaint = complaint.isNotEmpty
                          ? '$complaint$metaStr'
                          : 'General Clinical Examination$metaStr';

                      // Resolve patient ID: use autocomplete selection or fallback to matching by phone/name in existing records
                      String? resolvedPatientId = existingId;
                      if (resolvedPatientId == null && existingPatients.isNotEmpty) {
                        final matched = existingPatients.cast<PatientProfile?>().firstWhere(
                          (p) => (phone.isNotEmpty && p?.phone.trim() == phone) ||
                                 (name.isNotEmpty && p?.name.trim().toLowerCase() == name.toLowerCase()),
                          orElse: () => null,
                        );
                        if (matched != null) {
                          resolvedPatientId = matched.id;
                          if (age.isEmpty && (matched.calculatedAge != null || matched.dateOfBirth != null)) {
                            // Recover age
                          }
                        }
                      }
                      final targetPatientId = resolvedPatientId ?? 'pat_${DateTime.now().millisecondsSinceEpoch}';

                      // Dispatch check-in event using seeded doctor ID for exact LAN routing
                      activeBloc.add(
                        CheckInPatientEvent(
                          patientId: targetPatientId,
                          patientName: name,
                          phone: phone,
                          age: age.isNotEmpty ? age : null,
                          chronicConditions: chronicList,
                          allergies: allergiesList,
                          doctorName: doctorId,
                          chiefComplaint: fullComplaint,
                        ),
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
