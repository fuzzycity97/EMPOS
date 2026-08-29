import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';
import '../bloc/clinic_bloc.dart';
import '../bloc/clinic_event.dart';
import '../bloc/clinic_state.dart';
import '../widgets/patient_intake_dialog.dart';

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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TOP KPI BANNER (Granular BlocBuilder) ─────────────────────────
            _buildKpiBanner(context, isDark),
            const SizedBox(height: 20),

            // ── TAB HEADER & CHECK-IN BUTTON ─────────────────────────────────
            _buildTabHeaderAndActions(context, isDark, selectedTabNotifier),
            const SizedBox(height: 16),

            // ── TAB CONTENT LIST VIEW (Granular BlocBuilder) ─────────────────
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
                            ? _buildQueueTab(context, waitingList, inExaminationList, isDark)
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

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildKpiCard(
                'Estimated Patient Wait',
                '$waitMinutes mins',
                '5-Visit Rolling Mean',
                Icons.timer_outlined,
                Colors.amber,
                isDark,
              ),
              const SizedBox(width: 14),
              _buildKpiCard(
                'Waiting in Lobby',
                '$waitingCount',
                'Ready for consultation',
                Icons.hourglass_top,
                Colors.blue,
                isDark,
              ),
              const SizedBox(width: 14),
              _buildKpiCard(
                'In Examination',
                '$inExamCount',
                'With Medical Staff',
                Icons.medical_services_outlined,
                Colors.purple,
                isDark,
              ),
              const SizedBox(width: 14),
              _buildKpiCard(
                'Awaiting Checkout',
                '$completedCount',
                'Ready for Copay & Billing',
                Icons.receipt_long,
                Colors.teal,
                isDark,
              ),
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
    return SizedBox(
      width: 190,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 11, color: isDark ? Colors.white60 : Colors.black54)),
                  const SizedBox(height: 2),
                  Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Payment processed: ${patientShare.toStringAsFixed(2)} EGP collected. Printing 80mm receipt...',
                            ),
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
      builder: (ctx) => PatientIntakeDialog(bloc: bloc),
    );
  }
}
