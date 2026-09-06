import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../clinic/domain/entities/doctor_roster.dart';
import '../../../clinic/domain/entities/patient_profile.dart';
import '../../domain/entities/booking_item.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';

/// Clinical appointment booking modal dialog for receptionists.
/// 100% [StatelessWidget] following pure Clean Architecture.
class ClinicalBookingDialog extends StatelessWidget {
  final BookingBloc bloc;
  final DateTime selectedDate;
  final List<DoctorRoster> availableDoctors;
  final DoctorRoster? preselectedDoctor;
  final DateTime? initialSlotTime;
  final List<PatientProfile> existingPatients;

  const ClinicalBookingDialog({
    super.key,
    required this.bloc,
    required this.selectedDate,
    required this.availableDoctors,
    this.preselectedDoctor,
    this.initialSlotTime,
    this.existingPatients = const [],
  });

  static const List<String> clinicalProcedures = [
    'Periodic Dental Checkup & Odontogram',
    'Scaling, Polishing & Dental Prophylaxis',
    'Composite / Resin Filling Restoration',
    'Root Canal Treatment (Endodontics)',
    'Tooth Extraction & Oral Surgery',
    'Orthodontic Wire Adjustment & Inspection',
    'Crown / Bridge Fitting & Impression',
    'Dental Implant Assessment & Placement',
    'Urgent Toothache & Triage Consultation',
    'Pediatric Dental Examination',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();

    final selectedDoctorNotifier = ValueNotifier<DoctorRoster>(
      preselectedDoctor ?? (availableDoctors.isNotEmpty ? availableDoctors.first : DoctorRoster.defaultRosters.first),
    );

    final defaultHour = initialSlotTime?.hour ?? selectedDoctorNotifier.value.shiftStartHour;
    final selectedTimeNotifier = ValueNotifier<DateTime>(
      initialSlotTime ?? DateTime(selectedDate.year, selectedDate.month, selectedDate.day, defaultHour, 0),
    );

    final selectedServiceNotifier = ValueNotifier<String>(clinicalProcedures.first);
    final selectedPatientIdNotifier = ValueNotifier<String?>(null);
    final patientSearchResultsNotifier = ValueNotifier<List<PatientProfile>>([]);

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: SingleChildScrollView(
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
                        color: Colors.teal.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: const Icon(LucideIcons.calendarPlus, color: Colors.teal, size: 22),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Book Clinic Patient Appointment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Schedule consultation slot for returning or new clinic patient.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Doctor Selection
                const Text('Doctor & Consulting Specialist *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ValueListenableBuilder<DoctorRoster>(
                  valueListenable: selectedDoctorNotifier,
                  builder: (context, currentDoctor, _) {
                    return DropdownButtonFormField<DoctorRoster>(
                      initialValue: currentDoctor,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(LucideIcons.stethoscope, size: 18),
                        border: OutlineInputBorder(),
                      ),
                      items: availableDoctors.map((doc) {
                        return DropdownMenuItem<DoctorRoster>(
                          value: doc,
                          child: Text(
                            '${doc.doctorName} (${doc.specialty}) • ${doc.roomName}',
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (newDoc) {
                        if (newDoc != null) {
                          selectedDoctorNotifier.value = newDoc;
                          selectedTimeNotifier.value = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            newDoc.shiftStartHour,
                            0,
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.space14),

                // Patient Autocomplete Search & Phone
                const Text('Patient Information *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Patient Phone Number *',
                    hintText: 'e.g. 01211789493',
                    prefixIcon: Icon(LucideIcons.phone, size: 18),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (query) {
                    final q = query.trim();
                    if (q.length >= 3) {
                      patientSearchResultsNotifier.value = existingPatients
                          .where((p) => p.phone.contains(q) || p.name.toLowerCase().contains(q.toLowerCase()))
                          .toList();
                    } else {
                      patientSearchResultsNotifier.value = [];
                    }
                  },
                ),
                ValueListenableBuilder<List<PatientProfile>>(
                  valueListenable: patientSearchResultsNotifier,
                  builder: (context, matches, _) {
                    if (matches.isEmpty) return const SizedBox.shrink();

                    return Container(
                      margin: const EdgeInsets.only(top: 4, bottom: 8),
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.teal.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Existing Patients Found (Tap to select):', style: TextStyle(fontSize: 10, color: Colors.teal, fontWeight: FontWeight.bold)),
                          ...matches.take(3).map((p) {
                            return ListTile(
                              dense: true,
                              visualDensity: VisualDensity.compact,
                              leading: const Icon(LucideIcons.userCheck, size: 16, color: Colors.teal),
                              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text(p.phone, style: const TextStyle(fontSize: 11)),
                              onTap: () {
                                nameController.text = p.name;
                                phoneController.text = p.phone;
                                selectedPatientIdNotifier.value = p.id;
                                patientSearchResultsNotifier.value = [];
                              },
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Patient Full Name *',
                    hintText: 'Enter patient full name',
                    prefixIcon: Icon(LucideIcons.user, size: 18),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: AppDimensions.space14),

                // Procedure / Reason for Visit
                const Text('Procedure / Service *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ValueListenableBuilder<String>(
                  valueListenable: selectedServiceNotifier,
                  builder: (context, currentService, _) {
                    return DropdownButtonFormField<String>(
                      initialValue: currentService,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(LucideIcons.activity, size: 18),
                        border: OutlineInputBorder(),
                      ),
                      items: clinicalProcedures.map((proc) {
                        return DropdownMenuItem<String>(
                          value: proc,
                          child: Text(proc, style: const TextStyle(fontSize: 13), overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) selectedServiceNotifier.value = val;
                      },
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.space14),

                // Appointment Slot Time
                const Text('Appointment Time Slot *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                ValueListenableBuilder<DoctorRoster>(
                  valueListenable: selectedDoctorNotifier,
                  builder: (context, doc, _) {
                    final slots = doc.getSlotsForDate(selectedDate);
                    if (slots.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'Doctor is off-duty on this day. Working days: ${doc.workingDays.map((d) => getDayName(d)).join(", ")}',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      );
                    }

                    return ValueListenableBuilder<DateTime>(
                      valueListenable: selectedTimeNotifier,
                      builder: (context, currentSlot, _) {
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: slots.map((slot) {
                            final isSelected = slot.hour == currentSlot.hour && slot.minute == currentSlot.minute;
                            final period = slot.hour >= 12 ? 'PM' : 'AM';
                            final hour12 = slot.hour > 12 ? slot.hour - 12 : (slot.hour == 0 ? 12 : slot.hour);
                            final label = '${hour12.toString().padLeft(2, '0')}:${slot.minute.toString().padLeft(2, '0')} $period';

                            return ChoiceChip(
                              label: Text(label, style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                              selected: isSelected,
                              selectedColor: Colors.teal.withValues(alpha: 0.25),
                              checkmarkColor: Colors.teal,
                              onSelected: (selected) {
                                if (selected) selectedTimeNotifier.value = slot;
                              },
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                const SizedBox(height: AppDimensions.space14),

                // Chief Complaint / Notes
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Chief Complaint / Clinical Notes',
                    hintText: 'e.g. Complaining of severe pain in upper right molar since yesterday...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Icon(LucideIcons.fileText, size: 18),
                    ),
                    border: OutlineInputBorder(),
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
                        backgroundColor: Colors.teal,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      ),
                      icon: const Icon(LucideIcons.check, size: 16, color: Colors.white),
                      label: const Text(
                        'Confirm Appointment',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        if (name.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter patient name.')),
                          );
                          return;
                        }

                        final doctor = selectedDoctorNotifier.value;
                        final startTime = selectedTimeNotifier.value;
                        final endTime = startTime.add(Duration(minutes: doctor.slotDurationMinutes));
                        final patId = selectedPatientIdNotifier.value ?? 'pat_${DateTime.now().millisecondsSinceEpoch}';

                        bloc.add(
                          CreateBookingEvent(
                            BookingItem(
                              id: 'book_${DateTime.now().millisecondsSinceEpoch}',
                              customerOrPatientId: patId,
                              customerName: name,
                              customerPhone: phone,
                              resourceId: doctor.doctorId,
                              resourceName: doctor.doctorName,
                              serviceName: selectedServiceNotifier.value,
                              startTime: startTime,
                              endTime: endTime,
                              status: BookingStatus.confirmed,
                              notes: notesController.text.trim(),
                              createdAt: DateTime.now(),
                            ),
                          ),
                        );

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Appointment scheduled for $name with ${doctor.doctorName}'),
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
      ),
    );
  }

  static String getDayName(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    if (day >= 1 && day <= 7) return days[day - 1];
    return '';
  }
}
