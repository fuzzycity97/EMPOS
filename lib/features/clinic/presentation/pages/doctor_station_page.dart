import 'clinic_reception_page.dart';
import '../widgets/patient_medical_history_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/config/presentation/bloc/config_bloc.dart';
import '../../../../core/config/presentation/bloc/config_state.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_bloc.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_event.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_state.dart';
import '../../../../core/network/lan_sync/presentation/widgets/lan_sync_dialog.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_state.dart';
import '../../../customers/presentation/widgets/customer_ledger_dialog.dart';
import '../../../bookings/domain/entities/booking_item.dart';
import '../../../bookings/presentation/bloc/booking_bloc.dart';
import '../../../bookings/presentation/bloc/booking_state.dart';
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

    StoreBlueprint currentBlueprint = blueprint;
    try {
      final configState = context.watch<ConfigBloc>().state;
      if (configState is ConfigLoaded) {
        currentBlueprint = configState.blueprint;
      }
    } catch (_) {}

    final selectedVisitNotifier = ValueNotifier<String?>(null);
    final loadedVisitIdNotifier = ValueNotifier<String?>(null);
    final clinicalNotesController = TextEditingController();
    final prescriptionController = TextEditingController();
    final totalFeeController = TextEditingController();
    final labResultsController = TextEditingController();
    final doctorAttachmentsNotifier = ValueNotifier<List<MedicalAttachment>>([]);

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
              clinicalNotesController.text = activeVisit.diagnosis ?? '';
              prescriptionController.text = activeVisit.prescriptions.join(', ');
              totalFeeController.text = activeVisit.totalFee > 0 ? activeVisit.totalFee.toStringAsFixed(2) : '';
              labResultsController.text = activeVisit.labResults ?? '';

              final existingAttachments = <MedicalAttachment>[];
              for (int i = 0; i < activeVisit.attachmentPaths.length; i++) {
                final path = activeVisit.attachmentPaths[i];
                final title = i < activeVisit.attachmentTitles.length ? activeVisit.attachmentTitles[i] : 'Attachment #${i + 1}';
                existingAttachments.add(MedicalAttachment(
                  id: 'att_${activeVisit.id}_$i',
                  title: title,
                  type: MedicalAttachmentType.xrayRadiograph,
                  uploadDate: activeVisit.checkInTime,
                  fileSize: 'Saved File',
                  doctorNotes: 'Consultation attachment',
                  filePath: path,
                ));
              }
              doctorAttachmentsNotifier.value = existingAttachments;

              if (blueprint.isDental) {
                final patientForAge = loadedState.patients.cast<PatientProfile?>().firstWhere(
                  (p) => p?.id == activeVisit.patientId,
                  orElse: () => null,
                );
                final age = patientForAge?.calculatedAge;
                final isPed = age != null && age < 12;
                if (activeVisit.toothChart.isNotEmpty) {
                  bloc.add(ResetToothChartEvent(initialEntries: activeVisit.toothChart));
                } else {
                  bloc.add(ResetToothChartEvent(isPediatric: isPed));
                }
              }
            } else if (activeVisit == null && loadedVisitIdNotifier.value != null) {
              loadedVisitIdNotifier.value = null;
              clinicalNotesController.clear();
              prescriptionController.clear();
              totalFeeController.clear();
              labResultsController.clear();
              doctorAttachmentsNotifier.value = [];
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(Icons.people_alt_outlined, color: theme.colorScheme.primary),
                                        const SizedBox(width: 8),
                                        Expanded(
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
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                                              foregroundColor: theme.colorScheme.primary,
                                              elevation: 0,
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                            ),
                                            icon: const Icon(Icons.person_search, size: 15),
                                            label: const Text(
                                              'Archive',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () => _showAllPatientsArchiveDialog(
                                              context,
                                              loadedState,
                                              selectedVisitNotifier,
                                              isDark,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: theme.colorScheme.primary,
                                              side: BorderSide(color: theme.colorScheme.primary),
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                                            ),
                                            icon: const Icon(LucideIcons.calendarDays, size: 14),
                                            label: const Text(
                                              'مواعيدي اليوم',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () => _showDoctorAppointmentsDialog(context, isDark),
                                          ),
                                        ),
                                      ],
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
                                                clinicalNotesController.text = visit.diagnosis ?? '';
                                                prescriptionController.text = visit.prescriptions.join(', ');
                                                totalFeeController.text = visit.totalFee > 0 ? visit.totalFee.toStringAsFixed(2) : '';
                                                labResultsController.text = visit.labResults ?? '';
                                                final exAtts = <MedicalAttachment>[];
                                                for (int i = 0; i < visit.attachmentPaths.length; i++) {
                                                  final path = visit.attachmentPaths[i];
                                                  final title = i < visit.attachmentTitles.length ? visit.attachmentTitles[i] : 'Attachment #${i + 1}';
                                                  exAtts.add(MedicalAttachment(
                                                    id: 'att_${visit.id}_$i',
                                                    title: title,
                                                    type: MedicalAttachmentType.xrayRadiograph,
                                                    uploadDate: visit.checkInTime,
                                                    fileSize: 'Saved File',
                                                    doctorNotes: 'Consultation attachment',
                                                    filePath: path,
                                                  ));
                                                }
                                                doctorAttachmentsNotifier.value = exAtts;
                                                if (blueprint.isDental) {
                                                  final isPed = (patient?.calculatedAge != null && patient!.calculatedAge! < 12);
                                                  if (visit.toothChart.isNotEmpty) {
                                                    bloc.add(ResetToothChartEvent(initialEntries: visit.toothChart));
                                                  } else {
                                                    bloc.add(ResetToothChartEvent(isPediatric: isPed));
                                                  }
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
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (visit.status == ClinicVisitStatus.waiting) ...[
                                                    ElevatedButton(
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: Colors.amber[800],
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        minimumSize: const Size(44, 24),
                                                      ),
                                                      onPressed: () {
                                                        bloc.add(
                                                          UpdateVisitStatusEvent(
                                                            visitId: visit.id,
                                                            status: ClinicVisitStatus.inExamination,
                                                          ),
                                                        );
                                                      },
                                                      child: const Text('Call', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold)),
                                                    ),
                                                    const SizedBox(width: 6),
                                                  ],
                                                  Container(
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
                                      if (currentBlueprint.isDental || currentBlueprint.isEnabled('sw.dental_tooth_chart_editor')) ...[
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
                                        labResultsController,
                                        isDark,
                                        patient: activePatient,
                                      ),
                                      const SizedBox(height: 20),
                                      DoctorAttachmentsLightbox(
                                        attachmentsNotifier: doctorAttachmentsNotifier,
                                      ),
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
                                            final attList = doctorAttachmentsNotifier.value;
                                            final attPaths = attList.map((a) => a.filePath ?? '').where((p) => p.isNotEmpty).toList();
                                            final attTitles = attList.where((a) => (a.filePath ?? '').isNotEmpty).map((a) => a.title).toList();
                                            final labResults = labResultsController.text.trim();

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
                                              labResults: labResults.isNotEmpty ? labResults : null,
                                              attachmentPaths: attPaths,
                                              attachmentTitles: attTitles,
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
                                            labResultsController.clear();
                                            doctorAttachmentsNotifier.value = [];
                                            if (blueprint.isDental) {
                                              bloc.add(const ResetToothChartEvent());
                                            }

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
                const Icon(LucideIcons.wifiOff, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'DISCONNECTED FROM LAN SERVER • Offline Mode (Attempting to reconnect...)',
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
                  icon: const Icon(LucideIcons.refreshCw, size: 14),
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
                  if (patient?.chronicConditions.isNotEmpty == true || patient?.allergies.isNotEmpty == true) ...[
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        for (final cond in patient?.chronicConditions ?? <String>[])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cond.toLowerCase().contains('diabet') || cond.toLowerCase().contains('smok')
                                  ? Colors.amber.withValues(alpha: 0.2)
                                  : Colors.purple.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cond.toLowerCase().contains('smok') ? '🚬 $cond' : (cond.toLowerCase().contains('diabet') ? '🩺 $cond' : cond),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: cond.toLowerCase().contains('diabet') || cond.toLowerCase().contains('smok')
                                    ? Colors.amber[800]
                                    : Colors.purple[300],
                              ),
                            ),
                          ),
                        for (final allergy in patient?.allergies ?? <String>[])
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '⚠️ Allergy: $allergy',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (visit.status == ClinicVisitStatus.waiting)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      icon: const Icon(Icons.volume_up, size: 16),
                      label: const Text('Call Patient', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        bloc.add(
                          UpdateVisitStatusEvent(
                            visitId: visit.id,
                            status: ClinicVisitStatus.inExamination,
                          ),
                        );
                      },
                    ),
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
                    icon: const Icon(Icons.favorite_border, size: 16),
                    label: const Text('Medical History', style: TextStyle(fontSize: 12)),
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => PatientMedicalHistoryDialog(
                        patient: patient ??
                            PatientProfile(
                              id: visit.patientId,
                              name: visit.patientName,
                              phone: '',
                              createdAt: DateTime.now(),
                            ),
                        bloc: bloc,
                        isDark: isDark,
                      ),
                    ),
                  ),
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

    // Find matching customer in CustomerBloc to sync live ledger debts & settlements
    Customer? matchedCustomer;
    try {
      final customerState = context.read<CustomerBloc>().state;
      if (customerState is CustomersLoaded) {
        matchedCustomer = customerState.allCustomers.where((c) {
          if (c.id == currentVisit.patientId) return true;
          if (patientPhone != null && patientPhone.isNotEmpty && c.phone.trim() == patientPhone) return true;
          if (c.name.trim().toLowerCase() == patientName) return true;
          return false;
        }).firstOrNull;
      }
    } catch (_) {}

    double totalPaid = 0.0;
    double totalPending = 0.0;
    for (final v in historicalVisits) {
      if (v.isPaid || v.totalFee <= 0.001) {
        totalPaid += v.totalFee;
      } else {
        totalPaid += v.insurancePaid;
        totalPending += v.patientCopay;
      }
    }

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
            if (matchedCustomer != null)
              TextButton.icon(
                style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => CustomerLedgerDialog(customer: matchedCustomer!),
                  );
                },
                icon: const Icon(LucideIcons.fileSpreadsheet, size: 14),
                label: const Text('Account Ledger', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
                        Text('EGP ${totalPaid.toStringAsFixed(2)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                    Container(height: 24, width: 1, color: Colors.white24),
                    Column(
                      children: [
                        const Text('UNPAID / DUE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          'EGP ${totalPending.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: totalPending > 0 ? Colors.amber : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    if (matchedCustomer != null && matchedCustomer.totalDebt > 0.001) ...[
                      Container(height: 24, width: 1, color: Colors.white24),
                      Column(
                        children: [
                          const Text('ACCOUNT DEBT', style: TextStyle(fontSize: 10, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text(
                            'EGP ${matchedCustomer.totalDebt.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          ),
                        ],
                      ),
                    ],
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
                          final isFullySettled = hVisit.isPaid || hVisit.totalFee <= 0.001;
                          final visitDue = isFullySettled ? 0.0 : hVisit.patientCopay;
                          final isInsuranceCovered = !isFullySettled && hVisit.insurancePaid > 0.001;
                          final insInfo = hVisit.insurancePaid > 0.001
                              ? ' (Ins: EGP ${hVisit.insurancePaid.toStringAsFixed(2)})'
                              : '';
                          final settlementInfo = isFullySettled
                              ? 'Copay Settled: EGP ${hVisit.patientCopay.toStringAsFixed(2)}'
                              : 'Due: EGP ${visitDue.toStringAsFixed(2)}$insInfo';

                          return InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (dCtx) => HistoricalVisitDetailsDialog(
                                  visit: hVisit,
                                  blueprint: blueprint,
                                  patient: patient,
                                  customer: matchedCustomer,
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
                                              color: isFullySettled
                                                  ? Colors.green.withValues(alpha: 0.2)
                                                  : (isInsuranceCovered
                                                      ? Colors.amber.withValues(alpha: 0.2)
                                                      : Colors.red.withValues(alpha: 0.2)),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              isFullySettled
                                                  ? 'PAID & SETTLED'
                                                  : (isInsuranceCovered
                                                      ? 'COPAY DUE'
                                                      : 'UNPAID'),
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isFullySettled
                                                    ? Colors.green
                                                    : (isInsuranceCovered ? Colors.amber : Colors.redAccent),
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
                                  Text(
                                    'Doctor: ${ClinicReceptionPage.formatDoctorName(hVisit.doctorName)}',
                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                  ),
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
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Fee: EGP ${hVisit.totalFee.toStringAsFixed(2)} • $settlementInfo',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isFullySettled
                                              ? Colors.green
                                              : (visitDue > 0.001 ? Colors.amber : Colors.white70),
                                        ),
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
    TextEditingController labResultsController,
    bool isDark, {
    PatientProfile? patient,
  }) {
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
          const Text('Laboratory Panels & Bloodwork (CBC / BMP / Pathology)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: labResultsController,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. WBC: 7.2 x10^3/uL, Hgb: 14.1 g/dL, Platelets: 240 K/uL, Glucose: 95 mg/dL...',
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
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: feeController,
            builder: (context, val, _) {
              final fee = double.tryParse(val.text.trim()) ?? 0.0;
              if (fee <= 0) return const SizedBox.shrink();
              final copayRatio = patient?.defaultCopayPercentage ?? 1.0;
              final patientCopay = fee * copayRatio;
              final insurancePaid = fee - patientCopay;
              final hasInsurance = patient?.insuranceProvider != null && insurancePaid > 0.001;

              return Container(
                margin: const EdgeInsets.only(top: 10),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.receipt_long, size: 18, color: Colors.teal),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 4,
                        children: [
                          Text(
                            'Patient Copay: EGP ${patientCopay.toStringAsFixed(2)} (${(copayRatio * 100).toInt()}%)',
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                          ),
                          if (hasInsurance)
                            Text(
                              'Insurance: EGP ${insurancePaid.toStringAsFixed(2)} (${patient!.insuranceProvider})',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                            ),
                          Text(
                            'Total Charge: EGP ${fee.toStringAsFixed(2)}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAllPatientsArchiveDialog(
    BuildContext context,
    ClinicLoaded loadedState,
    ValueNotifier<String?> selectedVisitNotifier,
    bool isDark,
  ) {
    final searchNotifier = ValueNotifier<String>('');
    final allPatients = loadedState.patients;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750, maxHeight: 620),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(Icons.folder_shared_outlined, color: Colors.blue, size: 24),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Central Patient Medical Archive & History',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  autofocus: true,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search patient by full name or phone number...',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => searchNotifier.value = val.trim().toLowerCase(),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ValueListenableBuilder<String>(
                    valueListenable: searchNotifier,
                    builder: (context, query, _) {
                      final filtered = allPatients.where((p) {
                        if (query.isEmpty) return true;
                        return p.name.toLowerCase().contains(query) || p.phone.contains(query);
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text(
                            'No registered patients found matching search criteria.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (context, idx) {
                          final patient = filtered[idx];
                          final patientVisits = loadedState.queue
                              .where((v) => v.patientId == patient.id)
                              .toList();
                          final activeVisit = patientVisits.cast<ClinicVisit?>().firstWhere(
                                (v) => v?.status == ClinicVisitStatus.waiting || v?.status == ClinicVisitStatus.inExamination,
                                orElse: () => null,
                              );

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.withValues(alpha: 0.2),
                              child: Text(
                                patient.name.isNotEmpty ? patient.name[0].toUpperCase() : 'P',
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                              ),
                            ),
                            title: Row(
                              children: [
                                Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                if (patient.gender != null) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '(${patient.gender}${patient.calculatedAge != null ? ', ${patient.calculatedAge}y' : ''})',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Text(
                              'Phone: ${patient.phone}${patient.insuranceProvider != null ? ' • Insured: ${patient.insuranceProvider}' : ''}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (activeVisit != null)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.green,
                                        side: const BorderSide(color: Colors.green),
                                      ),
                                      onPressed: () {
                                        Navigator.of(ctx).pop();
                                        selectedVisitNotifier.value = activeVisit.id;
                                      },
                                      child: const Text('Select in Queue', style: TextStyle(fontSize: 11)),
                                    ),
                                  ),
                                OutlinedButton.icon(
                                  icon: const Icon(Icons.history, size: 14),
                                  label: const Text('View File & Visits', style: TextStyle(fontSize: 11)),
                                  onPressed: () {
                                    final dummyVisit = patientVisits.isNotEmpty
                                        ? patientVisits.first
                                        : ClinicVisit(
                                            id: 'archive_${patient.id}',
                                            patientId: patient.id,
                                            patientName: patient.name,
                                            doctorName: 'Doctor',
                                            queueNumber: 0,
                                            chiefComplaint: 'Medical File Review',
                                            checkInTime: patient.createdAt,
                                          );
                                    _showPatientHistoryDialog(
                                      context,
                                      dummyVisit,
                                      patient,
                                      loadedState.queue,
                                      loadedState.activeToothChart,
                                    );
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDoctorAppointmentsDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) {
        return BlocBuilder<BookingBloc, BookingState>(
          builder: (bCtx, bState) {
            final bookings = bState is BookingLoaded ? bState.bookings : <BookingItem>[];
            final today = DateTime.now();
            final todayBookings = bookings.where((b) {
              return b.startTime.year == today.year &&
                  b.startTime.month == today.month &&
                  b.startTime.day == today.day &&
                  b.isActive;
            }).toList()
              ..sort((a, b) => a.startTime.compareTo(b.startTime));

            return Dialog(
              backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Container(
                width: 520,
                constraints: const BoxConstraints(maxHeight: 560),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.calendar_month, color: Colors.blue, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'مواعيد اليوم المجدولة',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Text(
                                'Scheduled Appointments for Today (${todayBookings.length})',
                                style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.of(ctx).pop(),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Expanded(
                      child: todayBookings.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calendar_today, size: 40, color: isDark ? Colors.white24 : Colors.black26),
                                  const SizedBox(height: 10),
                                  Text(
                                    'لا توجد مواعيد محجوزة اليوم',
                                    style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              itemCount: todayBookings.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 8),
                              itemBuilder: (context, idx) {
                                final item = todayBookings[idx];
                                final timeStr =
                                    '${item.startTime.hour.toString().padLeft(2, '0')}:${item.startTime.minute.toString().padLeft(2, '0')} - ${item.endTime.hour.toString().padLeft(2, '0')}:${item.endTime.minute.toString().padLeft(2, '0')}';

                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: isDark ? Colors.white10 : const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.blue.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          timeStr,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.blue),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item.customerName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                            Text(
                                              item.serviceName,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: isDark ? Colors.white60 : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (item.status.name == 'checkedIn'
                                                  ? Colors.teal
                                                  : (item.status.name == 'confirmed' ? Colors.blue : Colors.amber))
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          item.status.name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: item.status.name == 'checkedIn'
                                                ? Colors.teal
                                                : (item.status.name == 'confirmed' ? Colors.blue : Colors.amber),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
