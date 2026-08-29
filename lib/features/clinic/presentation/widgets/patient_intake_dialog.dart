import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../bloc/clinic_bloc.dart';
import '../bloc/clinic_event.dart';

/// Patient intake and queue check-in modal dialog.
/// Follows strict Clean Architecture and is 100% [StatelessWidget].
class PatientIntakeDialog extends StatelessWidget {
  final ClinicBloc? bloc;
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController phoneController;
  final TextEditingController complaintController;
  final ValueNotifier<String> doctorNotifier;

  PatientIntakeDialog({
    super.key,
    this.bloc,
    TextEditingController? nameController,
    TextEditingController? ageController,
    TextEditingController? phoneController,
    TextEditingController? complaintController,
    ValueNotifier<String>? doctorNotifier,
  })  : nameController = nameController ?? TextEditingController(),
        ageController = ageController ?? TextEditingController(),
        phoneController = phoneController ?? TextEditingController(),
        complaintController = complaintController ?? TextEditingController(),
        doctorNotifier = doctorNotifier ?? ValueNotifier<String>('usr_doctor');

  // Seeded doctor accounts for deterministic LAN routing
  static const List<Map<String, String>> doctors = [
    {'id': 'usr_doctor', 'name': 'Dr. Sarah Connor (General / Dental Lead)'},
    {'id': 'usr_doctor_tarek', 'name': 'Dr. Tarek Dental Specialist'},
    {'id': 'usr_doctor_oncall', 'name': 'Dr. On-Call Physician'},
  ];

  @override
  Widget build(BuildContext context) {
    final activeBloc = bloc ?? context.read<ClinicBloc>();

    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
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
                          'Register new queue ticket and route to doctor station',
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
              const SizedBox(height: AppDimensions.space20),

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
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        hintText: 'e.g. +20 100 123 4567',
                        prefixIcon: Icon(LucideIcons.phone, size: 18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space12),

              // Assigned Doctor (Dropdown to seeded doctor ID)
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

                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter the patient full name.'),
                            backgroundColor: AppColors.error,
                          ),
                        );
                        return;
                      }

                      // Build formatted complaint metadata if age/phone supplied
                      final detailsList = <String>[];
                      if (age.isNotEmpty) detailsList.add('Age: $age');
                      if (phone.isNotEmpty) detailsList.add('Tel: $phone');
                      final metaStr = detailsList.isNotEmpty ? ' [${detailsList.join(', ')}]' : '';
                      final fullComplaint = complaint.isNotEmpty
                          ? '$complaint$metaStr'
                          : 'General Clinical Examination$metaStr';

                      // Dispatch check-in event using seeded doctor ID for exact LAN routing
                      activeBloc.add(
                        CheckInPatientEvent(
                          patientId: 'pat_${DateTime.now().millisecondsSinceEpoch}',
                          patientName: name,
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
