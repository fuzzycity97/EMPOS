import '../widgets/patient_medical_history_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_bloc.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_event.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_state.dart';
import '../../../../core/network/lan_sync/presentation/widgets/lan_sync_dialog.dart';
import '../../../customers/presentation/bloc/customer_bloc.dart';
import '../../../customers/presentation/bloc/customer_event.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';
import '../bloc/clinic_bloc.dart';
import '../bloc/clinic_event.dart';
import '../bloc/clinic_state.dart';
import '../widgets/patient_intake_dialog.dart';
import '../widgets/payment_checkout_dialog.dart';

class ClinicReceptionPage extends StatelessWidget {
  final ClinicBloc bloc;
  final StoreBlueprint blueprint;

  const ClinicReceptionPage({
    super.key,
    required this.bloc,
    required this.blueprint,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final selectedTabNotifier = ValueNotifier<int>(0); // 0 = Live Queue, 1 = Checkout & Billing

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildConnectionBanner(context, isDark),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── TOP KPI BANNER (Granular BlocBuilder) ─────────────────────
                  _buildKpiBanner(context, isDark),
                  const SizedBox(height: 20),

            // â”€â”€ TAB HEADER & CHECK-IN BUTTON â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _buildTabHeaderAndActions(context, isDark, selectedTabNotifier),
            const SizedBox(height: 16),

            // â”€â”€ TAB CONTENT LIST VIEW (Granular BlocBuilder) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: selectedTabNotifier,
                builder: (context, selectedTab, _) {
                  return BlocBuilder<ClinicBloc, ClinicState>(
                    bloc: bloc,
                    buildWhen: (prev, curr) => curr is ClinicLoaded || curr is ClinicError,
                    builder: (context, state) {
                      if (state is ClinicLoading && state is! ClinicLoaded) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (state is ClinicError) {
                        return Center(
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
                        );
                      }

                      if (state is ClinicLoaded) {
                        final waitingList = state.waitingQueue;
                        final inExaminationList = state.inExaminationQueue;
                        final completedList = state.billingVisits ?? state.completedQueue;

                        return selectedTab == 0
                            ? _buildQueueTab(context, waitingList, inExaminationList, state.patients, isDark)
                            : _buildBillingTab(context, completedList, state.patients, isDark);
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),
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

  Widget _buildKpiBanner(BuildContext context, bool isDark) {
    return BlocBuilder<ClinicBloc, ClinicState>(
      bloc: bloc,
      buildWhen: (prev, curr) => curr is ClinicLoaded || curr is ClinicInitial,
      builder: (context, state) {
        int waitMinutes = 15;
        int waitingCount = 0;
        int inExamCount = 0;
        int completedCount = 0;

        if (state is ClinicLoaded) {
          waitMinutes = state.rollingMeanWaitMinutes ?? 15;
          waitingCount = state.waitingQueue.length;
          inExamCount = state.inExaminationQueue.length;
          completedCount = (state.billingVisits ?? state.completedQueue).length;
        }

        final cards = [
          _buildKpiCard(
            'Estimated Patient Wait',
            '$waitMinutes mins',
            '5-Visit Rolling Mean',
            Icons.timer_outlined,
            Colors.amber,
            isDark,
          ),
          _buildKpiCard(
            'Waiting in Lobby',
            '$waitingCount',
            'Ready for consultation',
            Icons.hourglass_top,
            Colors.blue,
            isDark,
          ),
          _buildKpiCard(
            'In Examination',
            '$inExamCount',
            'With Medical Staff',
            Icons.medical_services_outlined,
            Colors.purple,
            isDark,
          ),
          _buildKpiCard(
            'Awaiting Checkout',
            '$completedCount',
            'Ready for Copay & Billing',
            Icons.receipt_long,
            Colors.teal,
            isDark,
          ),
        ];

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (int i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                Expanded(child: cards[i]),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabHeaderAndActions(
    BuildContext context,
    bool isDark,
    ValueNotifier<int> selectedTabNotifier,
  ) {
    return ValueListenableBuilder<int>(
      valueListenable: selectedTabNotifier,
      builder: (context, selectedTab, _) {
        return BlocBuilder<ClinicBloc, ClinicState>(
          bloc: bloc,
          buildWhen: (prev, curr) => curr is ClinicLoaded,
          builder: (context, state) {
            int liveCount = 0;
            int checkoutCount = 0;
            List<PatientProfile> patients = [];

            if (state is ClinicLoaded) {
              liveCount = state.waitingQueue.length + state.inExaminationQueue.length;
              checkoutCount = (state.billingVisits ?? state.completedQueue).length;
              patients = state.patients;
            }

            return Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChoiceChip(
                      label: Text('Live Queue ($liveCount)'),
                      selected: selectedTab == 0,
                      onSelected: (_) => selectedTabNotifier.value = 0,
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text('Checkout & Billing ($checkoutCount)'),
                      selected: selectedTab == 1,
                      onSelected: (_) => selectedTabNotifier.value = 1,
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showCheckInDialog(context, patients),
                  icon: const Icon(Icons.person_add_alt_1),
                  label: const Text('Patient Intake & Check-In'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildKpiCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String formatDoctorName(String doctorIdOrName) {
    switch (doctorIdOrName.toLowerCase().trim()) {
      case 'usr_doctor':
        return 'Dr. Sarah Connor';
      case 'usr_doctor_2':
      case 'usr_doctor_tarek':
        return 'Dr. Tarek Dental Lead';
      case 'usr_doctor_oncall':
        return 'Dr. On-Call Physician';
      default:
        if (doctorIdOrName.startsWith('usr_')) {
          final clean = doctorIdOrName.replaceFirst('usr_', '').replaceAll('_', ' ');
          return 'Dr. ${clean.split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ')}';
        }
        return doctorIdOrName;
    }
  }

  Widget _buildQueueTab(
    BuildContext context,
    List<ClinicVisit> waiting,
    List<ClinicVisit> inExamination,
    List<PatientProfile> patients,
    bool isDark,
  ) {
    final allActive = [...inExamination, ...waiting];

    if (allActive.isEmpty) {
      return const Center(child: Text('No active patients in clinic queue.'));
    }

    return ListView.builder(
      itemCount: allActive.length,
      itemBuilder: (context, index) {
        final visit = allActive[index];
        final isInRoom = visit.status == ClinicVisitStatus.inExamination;

        return Card(
          key: ValueKey('queue_visit_${visit.id}'),
          margin: const EdgeInsets.only(bottom: 10),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isInRoom ? Colors.amber.withValues(alpha: 0.2) : Colors.blue.withValues(alpha: 0.2),
              child: Icon(
                isInRoom ? Icons.meeting_room : Icons.person_outline,
                color: isInRoom ? Colors.amber[800] : Colors.blue,
              ),
            ),
            title: Text(visit.patientName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Doctor: ${formatDoctorName(visit.doctorName)} • Complaint: ${visit.chiefComplaint}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.folder_shared_outlined, color: Colors.blue),
                  tooltip: 'View Patient File',
                  onPressed: () => _showPatientFileDialog(context, visit, patients),
                ),
                if (!isInRoom)
                  ElevatedButton(
                    onPressed: () {
                      bloc.add(
                        UpdateVisitStatusEvent(
                          visitId: visit.id,
                          status: ClinicVisitStatus.inExamination,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[800]),
                    child: const Text('Call In', style: TextStyle(color: Colors.white)),
                  ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  onPressed: () {
                    bloc.add(
                      UpdateVisitStatusEvent(
                        visitId: visit.id,
                        status: ClinicVisitStatus.cancelled,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBillingTab(
    BuildContext context,
    List<ClinicVisit> completed,
    List<PatientProfile> patients,
    bool isDark,
  ) {
    if (completed.isEmpty) {
      return const Center(child: Text('No visits awaiting billing settlement.'));
    }

    return ListView.builder(
      itemCount: completed.length,
      itemBuilder: (context, index) {
        final visit = completed[index];
        final patient = patients.cast<PatientProfile?>().firstWhere(
              (p) => p?.id == visit.patientId,
              orElse: () => null,
            );

        final totalFee = visit.totalFee;
        final copayRatio = patient?.defaultCopayPercentage ?? 1.0;
        final patientShare = visit.patientCopay > 0 ? visit.patientCopay : (totalFee * copayRatio);
        final insuranceShare = visit.insurancePaid > 0 ? visit.insurancePaid : (totalFee - patientShare);

        return Card(
          key: ValueKey('billing_visit_${visit.id}'),
          margin: const EdgeInsets.only(bottom: 12),
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        visit.patientName,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text('Doctor: ${formatDoctorName(visit.doctorName)} • Diagnosis: ${visit.diagnosis ?? "Standard Consultation"}'),
                      const SizedBox(height: 6),
                      if (patient?.insuranceProvider != null)
                        Text(
                          'Insurance: ${patient!.insuranceProvider} • Copay Split: ${(copayRatio * 100).toInt()}% Patient / ${((1 - copayRatio) * 100).toInt()}% Carrier',
                          style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Patient Copay: ${patientShare.toStringAsFixed(2)} EGP',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    if (insuranceShare > 0)
                      Text(
                        'Carrier Claim: ${insuranceShare.toStringAsFixed(2)} EGP',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => PaymentCheckoutDialog(
                            visit: visit,
                            patient: patient,
                            totalFee: totalFee,
                            patientShare: patientShare,
                            insuranceShare: insuranceShare,
                            onSubmit: (amountPaid) {
                              bloc.add(ProcessVisitPaymentEvent(visit.id, amountPaid: amountPaid));
                              try {
                                context.read<CustomerBloc>().add(const LoadCustomersEvent());
                              } catch (_) {}
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Payment processed: ${amountPaid.toStringAsFixed(2)} EGP collected. Printing 80mm receipt...',
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.print, size: 16),
                      label: const Text('Pay & Print Receipt'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCheckInDialog(BuildContext context, List<PatientProfile> patients) {
    showDialog(
      context: context,
      builder: (ctx) => PatientIntakeDialog(
        bloc: bloc,
        existingPatients: patients,
      ),
    );
  }

  void _showPatientFileDialog(BuildContext context, ClinicVisit visit, List<PatientProfile> patients) {
    final patient = patients.cast<PatientProfile?>().firstWhere(
      (p) => p?.id == visit.patientId,
      orElse: () => null,
    );

    String statusDisplay;
    switch (visit.status) {
      case ClinicVisitStatus.waiting:
        statusDisplay = 'Waiting in Lobby';
        break;
      case ClinicVisitStatus.inExamination:
        statusDisplay = 'In Consultation / Room';
        break;
      case ClinicVisitStatus.completed:
        statusDisplay = 'Completed & Ready for Billing';
        break;
      case ClinicVisitStatus.cancelled:
        statusDisplay = 'Cancelled';
        break;
      case ClinicVisitStatus.noShow:
        statusDisplay = 'No Show';
        break;
    }

    final formattedTime = DateFormat('hh:mm a').format(visit.checkInTime);
    final ageVal = patient?.calculatedAge?.toString() ??
        RegExp(r'Age:\s*(\d+)').firstMatch(visit.chiefComplaint)?.group(1) ??
        patient?.dateOfBirth;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.folder_shared, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(child: Text('Patient File: ${visit.patientName}', overflow: TextOverflow.ellipsis)),
          ],
        ),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFileRow('Patient ID:', visit.patientId),
              _buildFileRow('Phone:', patient?.phone.isNotEmpty == true ? patient!.phone : 'Not recorded'),
              _buildFileRow('Age:', ageVal != null ? '$ageVal years' : 'Not recorded'),
              _buildFileRow('Medical Status / Risk:', (patient?.chronicConditions.isNotEmpty == true) ? patient!.chronicConditions.join(', ') : 'None reported'),
              _buildFileRow('Known Allergies:', (patient?.allergies.isNotEmpty == true) ? patient!.allergies.join(', ') : 'None reported'),
              _buildFileRow('Assigned Doctor:', formatDoctorName(visit.doctorName)),
              _buildFileRow('Room / Station:', visit.roomNumber),
              _buildFileRow('Chief Complaint:', visit.chiefComplaint.isNotEmpty ? visit.chiefComplaint : 'Standard checkup'),
              _buildFileRow('Status:', statusDisplay),
              if (patient?.insuranceProvider != null)
                _buildFileRow('Insurance Carrier:', '${patient!.insuranceProvider} (${((1 - patient.defaultCopayPercentage) * 100).toInt()}% coverage)'),
              _buildFileRow('Check-In Time:', formattedTime),
            ],
          ),
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.edit_note, size: 16),
            label: const Text('Edit Medical History'),
            onPressed: () {
              Navigator.of(ctx).pop();
              showDialog(
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
                  isDark: Theme.of(context).brightness == Brightness.dark,
                ),
              );
            },
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildFileRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
