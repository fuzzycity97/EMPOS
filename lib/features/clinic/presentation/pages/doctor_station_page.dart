import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_bloc.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_event.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_state.dart';
import '../../../../core/network/lan_sync/presentation/widgets/lan_sync_dialog.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/entities/procedure_item.dart';
import '../../domain/entities/tooth_chart_entry.dart';
import '../bloc/clinic_bloc.dart';
import '../bloc/clinic_event.dart';
import '../bloc/clinic_state.dart';
import '../widgets/dental_tooth_matrix_widget.dart';
import '../widgets/doctor_attachments_lightbox.dart';
import '../widgets/historical_visit_details_dialog.dart';
import '../widgets/vitals_input_dialog.dart';

class DoctorStationPage extends StatelessWidget {
  final ClinicBloc bloc;
  final StoreBlueprint blueprint;

  const DoctorStationPage({
    super.key,
    required this.bloc,
    required this.blueprint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final selectedVisitNotifier = ValueNotifier<String?>(null);
    final loadedVisitIdNotifier = ValueNotifier<String?>(null);
    final clinicalNotesController = TextEditingController();
    final prescriptionController = TextEditingController();
    final totalFeeController = TextEditingController();

    return BlocBuilder<ClinicBloc, ClinicState>(
      bloc: bloc,
      builder: (context, state) {
        if (state is ClinicInitial || state is ClinicLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is ClinicError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => bloc.add(const LoadClinicQueueEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        final loadedState = state as ClinicLoaded;
        final activeQueue = loadedState.queue
            .where((v) => v.status == ClinicVisitStatus.waiting || v.status == ClinicVisitStatus.inExamination)
            .toList();

        return ValueListenableBuilder<String?>(
          valueListenable: selectedVisitNotifier,
          builder: (context, selectedVisitId, _) {
            final activeVisit = activeQueue.cast<ClinicVisit?>().firstWhere(
                  (v) => v?.id == selectedVisitId,
                  orElse: () => activeQueue.isNotEmpty ? activeQueue.first : null,
                );

            // Reset inputs & auto-load tooth chart when active visit changes (taking in a patient)
            if (activeVisit != null && activeVisit.id != loadedVisitIdNotifier.value) {
              loadedVisitIdNotifier.value = activeVisit.id;
              clinicalNotesController.clear();
              prescriptionController.clear();
              totalFeeController.clear();
              if (blueprint.isDental) {
                bloc.add(LoadPatientToothChartEvent(activeVisit.patientId));
              }
            } else if (activeVisit == null && loadedVisitIdNotifier.value != null) {
              loadedVisitIdNotifier.value = null;
              clinicalNotesController.clear();
              prescriptionController.clear();
              totalFeeController.clear();
            }

            final activePatient = activeVisit != null
                ? loadedState.patients.cast<PatientProfile?>().firstWhere(
                      (p) => p?.id == activeVisit.patientId,
                      orElse: () => null,
                    )
                : null;

            int? patientAge = activePatient?.calculatedAge;
            if (patientAge == null && activeVisit != null) {
              final ageMatch = RegExp(r'Age:\s*(\d+)').firstMatch(activeVisit.chiefComplaint);
              if (ageMatch != null) {
                patientAge = int.tryParse(ageMatch.group(1)!);
              }
            }
            final isPediatric = (patientAge != null && patientAge < 12);

            return Scaffold(
              body: Column(
                children: [
                  // Prominent LAN Connection & Offline Warning Banner
                  _buildConnectionBanner(context, isDark),

                  Expanded(
                    child: Row(
                      children: [
                        // LEFT SIDEBAR: LIVE QUEUE
                        Container(
                          width: 320,
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                            border: Border(
                              right: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Queue Header
                              Container(
                                padding: const EdgeInsets.all(16),
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                child: Row(
                                  children: [
                                    Icon(Icons.people_alt_outlined, color: theme.colorScheme.primary),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        'Patient Queue (${activeQueue.length})',
                                        style: theme.textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Queue List
                              Expanded(
                                child: activeQueue.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(24),
                                          child: Text(
                                            'No patients in waiting queue',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isDark ? Colors.white38 : Colors.black38,
                                            ),
                                          ),
                                        ),
                                      )
                                    : ListView.builder(
                                        itemCount: activeQueue.length,
                                        itemBuilder: (context, index) {
                                          final visit = activeQueue[index];
                                          final patient = loadedState.patients.cast<PatientProfile?>().firstWhere(
                                                (p) => p?.id == visit.patientId,
                                                orElse: () => null,
                                              );
                                          final isSelected = activeVisit?.id == visit.id;

                                          return Material(
                                            color: Colors.transparent,
                                            child: ListTile(
                                              selected: isSelected,
                                              selectedTileColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                                              onTap: () {
                                                selectedVisitNotifier.value = visit.id;
                                                loadedVisitIdNotifier.value = visit.id;
                                                clinicalNotesController.clear();
                                                prescriptionController.clear();
                                                totalFeeController.clear();
                                                if (blueprint.isDental) {
                                                  bloc.add(LoadPatientToothChartEvent(visit.patientId));
                                                }
                                              },
                                              title: Text(
                                                visit.patientName,
                                                style: TextStyle(
                                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    visit.chiefComplaint,
                                                    style: const TextStyle(fontSize: 12),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  if (patient?.allergies.isNotEmpty == true)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: Colors.red.withValues(alpha: 0.2),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        'Allergy: ${patient!.allergies.join(", ")}',
                                                        style: const TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              trailing: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: visit.status == ClinicVisitStatus.inExamination
                                                      ? Colors.amber.withValues(alpha: 0.2)
                                                      : Colors.blue.withValues(alpha: 0.2),
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(
                                                  visit.status == ClinicVisitStatus.inExamination ? 'In Room' : 'Waiting',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: visit.status == ClinicVisitStatus.inExamination ? Colors.amber[800] : Colors.blue,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),

                        // CENTRAL WORKSPACE
                        Expanded(
                          child: activeVisit == null
                              ? Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.medical_information_outlined, size: 64, color: isDark ? Colors.white24 : Colors.black26),
                                      const SizedBox(height: 16),
                                      const Text('Select a patient from the queue to begin clinical consultation'),
                                    ],
                                  ),
                                )
                              : SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Patient Profile Card & Vitals
                                      _buildPatientVitalsCard(context, activeVisit, activePatient, loadedState.queue, loadedState.activeToothChart, isDark),
                                      const SizedBox(height: 20),

                                      // Dental vs General Workspace
                                      if (blueprint.isDental) ...[
                                        DentalToothMatrixWidget(
                                          toothChart: loadedState.activeToothChart ?? [],
                                          isPediatric: isPediatric,
                                          doctorName: activeVisit.doctorName,
                                          onToothUpdated: (updatedEntry) {
                                            bloc.add(
                                              UpdateToothChartEntryEvent(
                                                patientId: activeVisit.patientId,
                                                entry: updatedEntry,
                                              ),
                                            );
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                      ],

                                      // General Clinical Form (Notes, Prescriptions, Fee)
                                      _buildClinicalForm(
                                        context,
                                        clinicalNotesController,
                                        prescriptionController,
                                        totalFeeController,
                                        isDark,
                                      ),
                                      const SizedBox(height: 20),
                                      DoctorAttachmentsLightbox(),
                                      const SizedBox(height: 24),

                                      // Action Footer
                                      SizedBox(
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            final totalFee = double.tryParse(totalFeeController.text.trim()) ?? 0.0;
                                            final notes = clinicalNotesController.text.trim();
                                            final meds = prescriptionController.text.trim().isNotEmpty
                                                ? prescriptionController.text.trim().split(',')
                                                : <String>[];

                                            final copayRatio = activePatient?.defaultCopayPercentage ?? 1.0;
                                            final patientCopay = totalFee * copayRatio;
                                            final insurancePaid = totalFee - patientCopay;

                                            final currentToothSnapshot = loadedState.activeToothChart ?? [];

                                            final completedVisit = activeVisit.copyWith(
                                              status: ClinicVisitStatus.completed,
                                              completionTime: DateTime.now(),
                                              diagnosis: notes,
                                              prescriptions: meds,
                                              toothChart: currentToothSnapshot,
                                              appliedProcedures: [
                                                ProcedureItem(
                                                  id: 'proc_${DateTime.now().millisecondsSinceEpoch}',
                                                  code: blueprint.isDental ? 'D0120' : '99213',
                                                  name: blueprint.isDental ? 'Periodic Oral Evaluation & Odontogram' : 'Clinical Examination',
                                                  standardFee: totalFee,
                                                ),
                                              ],
                                              totalFee: totalFee,
                                              patientCopay: patientCopay,
                                              insurancePaid: insurancePaid,
                                            );

                                            bloc.add(CompleteVisitEvent(completedVisit));

                                            if (blueprint.isDental && currentToothSnapshot.isNotEmpty) {
                                              bloc.add(
                                                SaveToothChartEvent(
                                                  patientId: activeVisit.patientId,
                                                  entries: currentToothSnapshot,
                                                ),
                                              );
                                            }

                                            // Clear form inputs after completion
                                            loadedVisitIdNotifier.value = null;
                                            clinicalNotesController.clear();
                                            prescriptionController.clear();
                                            totalFeeController.clear();

                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Consultation completed and sent to reception billing')),
                                            );
                                          },
                                          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                                          label: const Text(
                                            'Complete & Send to Reception',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                                          ),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.teal,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildConnectionBanner(BuildContext context, bool isDark) {
    return BlocBuilder<LanSyncBloc, LanSyncState>(
      builder: (context, lanState) {
        final isConnected = lanState is LanSyncConnected;
        final isHost = isConnected && lanState.isHost;

        if (!isConnected) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFB91C1C),
            child: Row(
              children: [
                const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '⚠️ DISCONNECTED FROM LAN SERVER — Offline Mode (Local changes saved, will sync upon reconnect)',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFFB91C1C),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: const Icon(Icons.refresh, size: 14),
                  label: const Text('Reconnect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  onPressed: () {
                    context.read<LanSyncBloc>().add(const AutoRestoreLanSyncEvent());
                  },
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    visualDensity: VisualDensity.compact,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => BlocProvider.value(
                        value: context.read<LanSyncBloc>(),
                        child: LanSyncDialog(),
                      ),
                    );
                  },
                  child: const Text('Network Hub', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            border: Border(
              bottom: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF10B981),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isHost
                        ? '● LAN Sync Hub Online (Host Station)'
                        : '● Connected to LAN Server (${lanState.address}:${lanState.port})',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF10B981)),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => BlocProvider.value(
                      value: context.read<LanSyncBloc>(),
                      child: LanSyncDialog(),
                    ),
                  );
                },
                child: Row(
                  children: [
                    Icon(Icons.settings_ethernet, size: 14, color: isDark ? Colors.white60 : Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      'LAN Settings',
                      style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatientVitalsCard(
    BuildContext context,
    ClinicVisit visit,
    PatientProfile? patient,
    List<ClinicVisit> allVisits,
    List<ToothChartEntry>? activeToothChart,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 12,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visit.patientName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Chief Complaint: ${visit.chiefComplaint}',
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.black87,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (patient?.insuranceProvider != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Insurance: ${patient!.insuranceProvider} (${(patient.defaultCopayPercentage * 100).toInt()}% Copay)',
                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.history, size: 16),
                    label: const Text('View Patient History', style: TextStyle(fontSize: 12)),
                    onPressed: () => _showPatientHistoryDialog(context, visit, patient, allVisits, activeToothChart),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.edit_note, size: 16),
                    label: const Text('Edit Vitals', style: TextStyle(fontSize: 12)),
                    onPressed: () => _showEditVitalsDialog(context, visit),
                  ),
                ],
              ),
            ],
          ),
          const Divider(height: 20),

          // Vitals Monitor Grid (Clickable)
          InkWell(
            onTap: () => _showEditVitalsDialog(context, visit),
            borderRadius: BorderRadius.circular(8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _vitalChip('Heart Rate', visit.heartRate, Icons.favorite, Colors.red, isDark),
                  const SizedBox(width: 12),
                  _vitalChip('Blood Pressure', visit.bloodPressure, Icons.speed, Colors.purple, isDark),
                  const SizedBox(width: 12),
                  _vitalChip('SpO2', visit.spo2, Icons.air, Colors.teal, isDark),
                  const SizedBox(width: 12),
                  _vitalChip('Temperature', visit.temperature, Icons.thermostat, Colors.amber, isDark),
                  const SizedBox(width: 12),
                  _vitalChip('Respiration', visit.respiratoryRate, Icons.timer, Colors.blue, isDark),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPatientHistoryDialog(
    BuildContext context,
    ClinicVisit currentVisit,
    PatientProfile? patient,
    List<ClinicVisit> allVisits,
    List<ToothChartEntry>? cumulativeToothChart,
  ) {
    final patientPhone = patient?.phone.trim();
    final patientName = currentVisit.patientName.trim().toLowerCase();

    final historicalVisits = allVisits
        .where((v) {
          if (v.id == currentVisit.id) return false;
          if (v.patientId == currentVisit.patientId) return true;
          if (patientPhone != null && patientPhone.isNotEmpty && v.chiefComplaint.contains(patientPhone)) return true;
          if (v.patientName.trim().toLowerCase() == patientName) return true;
          return false;
        })
        .toList()
      ..sort((a, b) => (b.completionTime ?? b.checkInTime).compareTo(a.completionTime ?? a.checkInTime));

    final totalPaid = historicalVisits
        .where((v) => v.isPaid)
        .fold<double>(0.0, (sum, v) => sum + v.patientCopay);
    final totalPending = historicalVisits
        .where((v) => !v.isPaid && v.status == ClinicVisitStatus.completed)
        .fold<double>(0.0, (sum, v) => sum + (v.patientCopay > 0 ? v.patientCopay : v.totalFee));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.history_edu, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Medical History & Payment Logs: ${currentVisit.patientName}',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: 640,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Financial & Visit Summary Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('PAST VISITS', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('${historicalVisits.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(height: 24, width: 1, color: Colors.white24),
                    Column(
                      children: [
                        const Text('TOTAL SETTLED', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('E£ ${totalPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    Container(height: 24, width: 1, color: Colors.white24),
                    Column(
                      children: [
                        const Text('UNPAID / DUE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text('E£ ${totalPending.toStringAsFixed(2)}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: totalPending > 0 ? Colors.amber : Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Visit List
              SizedBox(
                height: 400,
                child: historicalVisits.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text(
                            'No prior historical visits recorded for this patient.\n(First recorded consultation)',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                    : ListView.separated(
                        itemCount: historicalVisits.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, idx) {
                          final hVisit = historicalVisits[idx];
                          final dateStr = DateFormat('yyyy-MM-dd • hh:mm a').format(hVisit.checkInTime);
                          final treatedTeeth = hVisit.toothChart.where((t) => t.state != ToothState.healthy).toList();

                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (dCtx) => HistoricalVisitDetailsDialog(
                                  visit: hVisit,
                                  blueprint: blueprint,
                                  patient: patient,
                                  cumulativeToothChart: cumulativeToothChart,
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.white12),
                                color: Colors.white.withValues(alpha: 0.03),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        dateStr,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // Payment Status Tag
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: hVisit.isPaid
                                                  ? Colors.green.withValues(alpha: 0.2)
                                                  : Colors.amber.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              hVisit.isPaid ? 'PAID & SETTLED' : 'UNPAID',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: hVisit.isPaid ? Colors.green : Colors.amber,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              hVisit.status.name.toUpperCase(),
                                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue),
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text('Doctor: ${hVisit.doctorName}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  if (hVisit.diagnosis != null && hVisit.diagnosis!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('Notes / Diagnosis: ${hVisit.diagnosis}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.teal)),
                                    ),
                                  if (hVisit.prescriptions.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('Prescriptions: ${hVisit.prescriptions.join(", ")}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    ),
                                  if (hVisit.appliedProcedures.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('Procedures: ${hVisit.appliedProcedures.map((p) => p.name).join(", ")}', style: const TextStyle(fontSize: 11, color: Colors.cyan)),
                                    ),
                                  if (treatedTeeth.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2),
                                      child: Text('Dental Chart: ${treatedTeeth.map((t) => "#${t.effectiveToothCode} (${t.state.displayName})").join(", ")}', style: const TextStyle(fontSize: 11, color: Colors.amber)),
                                    ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Fee: E£ ${hVisit.totalFee.toStringAsFixed(2)} • Copay Paid: E£ ${hVisit.patientCopay.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white70),
                                      ),
                                      const Text(
                                        'View record & 3D chart >',
                                        style: TextStyle(fontSize: 10, color: Colors.blueAccent, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showEditVitalsDialog(BuildContext context, ClinicVisit visit) {
    showDialog(
      context: context,
      builder: (ctx) => VitalsInputDialog(
        visit: visit,
        onSave: ({
          required bloodPressure,
          required heartRate,
          required respiratoryRate,
          required spo2,
          required temperature,
        }) {
          bloc.add(
            UpdateVisitVitalsEvent(
              visitId: visit.id,
              bloodPressure: bloodPressure,
              heartRate: heartRate,
              spo2: spo2,
              temperature: temperature,
              respiratoryRate: respiratoryRate,
            ),
          );
        },
      ),
    );
  }

  Widget _vitalChip(String label, String value, IconData icon, Color color, bool isDark) {
    return SizedBox(
      width: 160,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(fontSize: 10, color: isDark ? Colors.white60 : Colors.black54)),
                  Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClinicalForm(
    BuildContext context,
    TextEditingController notesController,
    TextEditingController prescriptionController,
    TextEditingController feeController,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Clinical Notes & Diagnosis', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: notesController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Enter clinical observations, diagnosis, and treatment recommendations...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Rx Prescriptions (comma separated)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: prescriptionController,
            decoration: const InputDecoration(
              hintText: 'e.g. Amoxicillin 500mg (1x3), Ibuprofen 400mg PRN',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Consultation / Procedure Fee (EGP)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: feeController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              prefixText: 'EGP ',
              hintText: '0.00 (Enter amount to charge)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
