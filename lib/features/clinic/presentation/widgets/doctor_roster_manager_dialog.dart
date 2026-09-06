import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/lan_sync/domain/entities/sync_envelope.dart';
import '../../../../core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import '../../data/datasources/clinic_local_data_source.dart';
import '../../data/models/doctor_roster_model.dart';
import '../../domain/entities/doctor_roster.dart';

/// Admin & Manager Switchboard for managing clinic doctor rosters, working shifts, and clinic rooms.
/// 100% [StatelessWidget] following pure Clean Architecture.
class DoctorRosterManagerDialog extends StatelessWidget {
  final ValueNotifier<List<DoctorRoster>> rostersNotifier;
  final VoidCallback? onRostersSaved;

  DoctorRosterManagerDialog({
    super.key,
    List<DoctorRoster>? initialRosters,
    this.onRostersSaved,
  }) : rostersNotifier = ValueNotifier<List<DoctorRoster>>(
          initialRosters ?? List.from(DoctorRoster.defaultRosters),
        );

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Dialog(
      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: BorderSide(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 780, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space20),
          child: Column(
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
                    child: const Icon(LucideIcons.calendarClock, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Doctor Shifts & Roster Schedule Manager',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Configure clinical working days, shift hours, and consultation rooms for each doctor.',
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

              // Roster List
              Expanded(
                child: ValueListenableBuilder<List<DoctorRoster>>(
                  valueListenable: rostersNotifier,
                  builder: (context, rosters, _) {
                    return ListView.separated(
                      itemCount: rosters.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final roster = rosters[index];
                        return _buildDoctorCard(context, roster, index, isDark);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: AppDimensions.space16),

              // Footer Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(LucideIcons.userPlus, size: 16),
                    label: const Text('Add Doctor Shift Roster', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => _addNewDoctorRoster(context),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryDark)),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                        ),
                        icon: const Icon(LucideIcons.check, size: 16, color: Colors.white),
                        label: const Text(
                          'Save & Propagate Rosters',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => _saveAndPropagate(context),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, DoctorRoster roster, int index, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                    child: Text(
                      roster.doctorName.isNotEmpty ? roster.doctorName.replaceAll('Dr. ', '')[0] : 'D',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        roster.doctorName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${roster.specialty} • ${roster.roomName}',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    roster.isActive ? 'Active' : 'Off-Duty',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: roster.isActive ? Colors.green : Colors.grey,
                    ),
                  ),
                  Switch(
                    value: roster.isActive,
                    activeThumbColor: Colors.green,
                    onChanged: (val) {
                      final updated = List<DoctorRoster>.from(rostersNotifier.value);
                      updated[index] = roster.copyWith(isActive: val);
                      rostersNotifier.value = updated;
                    },
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 16, color: Colors.white12),

          // Working Days Selection
          const Text(
            'Working Days in Clinic:',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondaryDark),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(7, (dIdx) {
              final dayNumber = dIdx + 1; // 1 = Mon ... 7 = Sun
              final isSelected = roster.workingDays.contains(dayNumber);

              return FilterChip(
                label: Text(_dayNames[dIdx], style: TextStyle(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                selected: isSelected,
                selectedColor: AppColors.primary.withValues(alpha: 0.25),
                checkmarkColor: AppColors.primary,
                onSelected: (selected) {
                  final updatedDays = List<int>.from(roster.workingDays);
                  if (selected) {
                    updatedDays.add(dayNumber);
                    updatedDays.sort();
                  } else {
                    updatedDays.remove(dayNumber);
                  }
                  final updated = List<DoctorRoster>.from(rostersNotifier.value);
                  updated[index] = roster.copyWith(workingDays: updatedDays);
                  rostersNotifier.value = updated;
                },
              );
            }),
          ),
          const SizedBox(height: 10),

          // Shift Hours & Slot Configuration
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(LucideIcons.clock, size: 14, color: AppColors.textSecondaryDark),
                    const SizedBox(width: 6),
                    Text(
                      'Shift: ${roster.formatShiftHours()}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  visualDensity: VisualDensity.compact,
                ),
                icon: const Icon(LucideIcons.edit2, size: 12),
                label: const Text('Edit Shift & Room', style: TextStyle(fontSize: 11)),
                onPressed: () => _editShiftDetails(context, roster, index),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _editShiftDetails(BuildContext context, DoctorRoster roster, int index) {
    final startController = TextEditingController(text: roster.shiftStartHour.toString());
    final endController = TextEditingController(text: roster.shiftEndHour.toString());
    final slotController = TextEditingController(text: roster.slotDurationMinutes.toString());
    final roomController = TextEditingController(text: roster.roomName);
    final specialtyController = TextEditingController(text: roster.specialty);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Shift: ${roster.doctorName}'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty / Field', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(labelText: 'Consultation Room / Suite', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: startController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Start Hour (0-23)', border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: endController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'End Hour (0-23)', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: slotController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Slot Duration (Mins: 30 or 60)', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final start = int.tryParse(startController.text.trim()) ?? roster.shiftStartHour;
              final end = int.tryParse(endController.text.trim()) ?? roster.shiftEndHour;
              final slot = int.tryParse(slotController.text.trim()) ?? roster.slotDurationMinutes;
              final room = roomController.text.trim();
              final spec = specialtyController.text.trim();

              final updated = List<DoctorRoster>.from(rostersNotifier.value);
              updated[index] = roster.copyWith(
                shiftStartHour: start.clamp(0, 23),
                shiftEndHour: end.clamp(1, 24),
                slotDurationMinutes: slot.clamp(15, 120),
                roomName: room.isNotEmpty ? room : roster.roomName,
                specialty: spec.isNotEmpty ? spec : roster.specialty,
              );
              rostersNotifier.value = updated;
              Navigator.of(ctx).pop();
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _addNewDoctorRoster(BuildContext context) {
    final nameController = TextEditingController();
    final specialtyController = TextEditingController(text: 'Dental Consultant');
    final roomController = TextEditingController(text: 'Suite 3');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Doctor Shift Roster'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Doctor Full Name *',
                  hintText: 'e.g. Dr. Hossam Dental Specialist',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: specialtyController,
                decoration: const InputDecoration(labelText: 'Specialty / Field', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: roomController,
                decoration: const InputDecoration(labelText: 'Room / Suite', border: OutlineInputBorder()),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;

              final id = 'usr_doc_${DateTime.now().millisecondsSinceEpoch}';
              final newRoster = DoctorRoster(
                id: 'roster_$id',
                doctorId: id,
                doctorName: name.startsWith('Dr.') ? name : 'Dr. $name',
                specialty: specialtyController.text.trim(),
                roomName: roomController.text.trim(),
                workingDays: const [6, 1, 3], // Sat, Mon, Wed
                shiftStartHour: 10,
                shiftEndHour: 18,
                slotDurationMinutes: 60,
              );

              rostersNotifier.value = [...rostersNotifier.value, newRoster];
              Navigator.of(ctx).pop();
            },
            child: const Text('Add Roster'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAndPropagate(BuildContext context) async {
    try {
      final list = rostersNotifier.value;
      final localSource = sl<ClinicLocalDataSource>();
      await localSource.saveDoctorRosters(
        list.map((r) => DoctorRosterModel.fromEntity(r)).toList(),
      );

      // Broadcast over LAN mesh
      try {
        final lanRepo = sl<LanSyncRepository>();
        final envelope = SyncEnvelope.create(
          type: 'clinic.doctor_rosters_updated',
          scope: 'clinic',
          senderId: 'manager_station',
          senderRole: 'manager',
          payload: {
            'rosters': list.map((r) => DoctorRosterModel.fromEntity(r).toJson()).toList(),
          },
        );
        lanRepo.broadcast(envelope);
      } catch (_) {}

      onRostersSaved?.call();
      if (context.mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Doctor shift rosters saved and synchronized across clinic stations.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save rosters: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }
}
