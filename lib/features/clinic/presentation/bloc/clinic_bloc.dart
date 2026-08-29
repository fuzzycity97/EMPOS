import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/lan_sync/data/message_routes.dart';
import '../../../../core/network/lan_sync/domain/entities/sync_envelope.dart';
import '../../../../core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import '../../data/models/clinic_visit_model.dart';
import '../../data/models/patient_profile_model.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/patient_profile.dart';
import '../../domain/entities/tooth_chart_entry.dart';
import '../../domain/repositories/clinic_repository.dart';
import '../../domain/usecases/check_in_patient_usecase.dart';
import '../../domain/usecases/complete_visit_usecase.dart';
import '../../domain/usecases/get_clinic_queue_usecase.dart';
import '../../domain/usecases/get_patient_tooth_chart_usecase.dart';
import '../../domain/usecases/get_patients_usecase.dart';
import '../../domain/usecases/get_rolling_mean_wait_usecase.dart';
import '../../domain/usecases/save_patient_usecase.dart';
import '../../domain/usecases/save_tooth_chart_usecase.dart';
import '../../domain/usecases/save_visit_usecase.dart';
import '../../domain/usecases/search_patients_usecase.dart';
import '../../domain/usecases/update_visit_status_usecase.dart';
import 'clinic_event.dart';
import 'clinic_state.dart';

class ClinicBloc extends Bloc<ClinicEvent, ClinicState> {
  final GetClinicQueueUseCase getClinicQueueUseCase;
  final CheckInPatientUseCase checkInPatientUseCase;
  final UpdateVisitStatusUseCase updateVisitStatusUseCase;
  final CompleteVisitUseCase completeVisitUseCase;
  final GetPatientToothChartUseCase getPatientToothChartUseCase;
  final SaveToothChartUseCase saveToothChartUseCase;
  final GetPatientsUseCase getPatientsUseCase;
  final SearchPatientsUseCase searchPatientsUseCase;
  final GetRollingMeanWaitUseCase getRollingMeanWaitUseCase;
  final SavePatientUseCase? savePatientUseCase;
  final SaveVisitUseCase? saveVisitUseCase;
  final ClinicRepository? clinicRepository;
  final LanSyncRepository? lanSyncRepository;

  StreamSubscription<SyncEnvelope>? _lanSyncSubscription;

  ClinicBloc({
    required this.getClinicQueueUseCase,
    required this.checkInPatientUseCase,
    required this.updateVisitStatusUseCase,
    required this.completeVisitUseCase,
    required this.getPatientToothChartUseCase,
    required this.saveToothChartUseCase,
    required this.getPatientsUseCase,
    required this.searchPatientsUseCase,
    required this.getRollingMeanWaitUseCase,
    this.savePatientUseCase,
    this.saveVisitUseCase,
    this.clinicRepository,
    this.lanSyncRepository,
  }) : super(ClinicInitial()) {
    on<LoadClinicQueueEvent>(_onLoadClinicQueue);
    on<CheckInPatientEvent>(_onCheckInPatient);
    on<UpdateVisitStatusEvent>(_onUpdateVisitStatus);
    on<CompleteVisitEvent>(_onCompleteVisit);
    on<LoadPatientToothChartEvent>(_onLoadPatientToothChart);
    on<UpdateToothChartEntryEvent>(_onUpdateToothChartEntry);
    on<SaveToothChartEvent>(_onSaveToothChart);
    on<SearchClinicPatientsEvent>(_onSearchClinicPatients);

    _initLanSyncListener();
  }

  Future<void> _savePatientLocally(PatientProfile patient) async {
    if (savePatientUseCase != null) {
      await savePatientUseCase!(patient);
    } else if (clinicRepository != null) {
      await clinicRepository!.savePatient(patient);
    }
  }

  Future<void> _saveVisitLocally(ClinicVisit visit) async {
    if (saveVisitUseCase != null) {
      await saveVisitUseCase!(visit);
    } else if (clinicRepository != null) {
      await clinicRepository!.saveVisit(visit);
    }
  }

  int _statusWeight(ClinicVisitStatus status) {
    switch (status) {
      case ClinicVisitStatus.completed:
        return 3;
      case ClinicVisitStatus.inExamination:
        return 2;
      case ClinicVisitStatus.waiting:
        return 1;
      case ClinicVisitStatus.cancelled:
      case ClinicVisitStatus.noShow:
        return 3;
    }
  }

  Future<void> _handleSyncRequestActiveState(SyncEnvelope envelope) async {
    // Only Host server should answer full state requests to prevent client echo loops
    if (lanSyncRepository != null && !lanSyncRepository!.isHost) {
      return;
    }

    try {
      final queueResult = await getClinicQueueUseCase();
      final allVisits = queueResult.getOrElse(() => []);

      // Active visits: status waiting or inExamination
      final activeVisits = allVisits.where((v) =>
          v.status == ClinicVisitStatus.waiting ||
          v.status == ClinicVisitStatus.inExamination).toList();

      final patientsResult = await getPatientsUseCase();
      final allPatients = patientsResult.getOrElse(() => []);

      final List<Map<String, dynamic>> visitsJson = [];
      for (final v in activeVisits) {
        try {
          visitsJson.add(ClinicVisitModel.fromEntity(v).toJson());
        } catch (_) {}
      }

      final List<Map<String, dynamic>> patientsJson = [];
      for (final p in allPatients) {
        try {
          patientsJson.add(PatientProfileModel.fromEntity(p).toJson());
        } catch (_) {}
      }

      final responseEnvelope = SyncEnvelope.create(
        type: MessageRoutes.syncFullStateResponse,
        scope: 'clinic',
        senderId: 'hub_host',
        senderRole: 'host',
        payload: {
          'visits': visitsJson,
          'patients': patientsJson,
        },
      );

      await lanSyncRepository?.broadcast(responseEnvelope);
    } catch (_) {}
  }

  Future<void> _handleSyncFullStateResponse(SyncEnvelope envelope) async {
    // If this node is the host that sent the response, ignore to avoid redundant local upsert
    if (lanSyncRepository != null && lanSyncRepository!.isHost) {
      return;
    }

    final payload = envelope.payload;
    if (payload == null) return;

    try {
      // 1. Batch upsert patients
      if (payload['patients'] != null && payload['patients'] is List) {
        final patientsList = payload['patients'] as List;
        for (final item in patientsList) {
          try {
            Map<String, dynamic>? patientMap;
            if (item is Map) {
              patientMap = Map<String, dynamic>.from(item);
            } else if (item is String) {
              patientMap = Map<String, dynamic>.from(jsonDecode(item) as Map);
            }
            if (patientMap != null) {
              final patientModel = PatientProfileModel.fromJson(patientMap);
              await _savePatientLocally(patientModel);
            }
          } catch (_) {}
        }
      }

      // 2. Batch upsert visits with smart conflict resolution
      if (payload['visits'] != null && payload['visits'] is List) {
        final currentQueueResult = await getClinicQueueUseCase();
        final localVisits = currentQueueResult.getOrElse(() => []);

        final visitsList = payload['visits'] as List;
        for (final item in visitsList) {
          try {
            Map<String, dynamic>? visitMap;
            if (item is Map) {
              visitMap = Map<String, dynamic>.from(item);
            } else if (item is String) {
              visitMap = Map<String, dynamic>.from(jsonDecode(item) as Map);
            }
            if (visitMap != null) {
              final incomingVisit = ClinicVisitModel.fromJson(visitMap);
              final localVisit = localVisits.cast<ClinicVisit?>().firstWhere(
                (v) => v?.id == incomingVisit.id,
                orElse: () => null,
              );

              if (localVisit != null &&
                  _statusWeight(localVisit.status) > _statusWeight(incomingVisit.status)) {
                // Local state is newer than incoming stale state: do NOT overwrite.
                // Fire a counter-sync (visit.updated) back to the network so the stale node corrects itself.
                final existingPatients = (await getPatientsUseCase()).getOrElse(() => []);
                final patient = existingPatients.cast<PatientProfile?>().firstWhere(
                  (p) => p?.id == localVisit.patientId,
                  orElse: () => null,
                );

                final counterEnvelope = SyncEnvelope.create(
                  type: MessageRoutes.syncVisitUpdated,
                  scope: 'clinic',
                  senderId: lanSyncRepository?.isHost == true ? 'hub_host' : 'clinic_station',
                  senderRole: 'clinic',
                  payload: {
                    'visitId': localVisit.id,
                    'patientId': localVisit.patientId,
                    'patientName': localVisit.patientName,
                    'status': localVisit.status.name,
                    'patient': patient != null ? PatientProfileModel.fromEntity(patient).toJson() : null,
                    'visit': ClinicVisitModel.fromEntity(localVisit).toJson(),
                  },
                );
                await lanSyncRepository?.broadcast(counterEnvelope);
              } else {
                await _saveVisitLocally(incomingVisit);
              }
            }
          } catch (_) {}
        }
      }

      // 3. ONLY AFTER the database writes are complete, dispatch LoadClinicQueueEvent()
      add(const LoadClinicQueueEvent());
    } catch (_) {
      add(const LoadClinicQueueEvent());
    }
  }

  void _initLanSyncListener() {
    _lanSyncSubscription = lanSyncRepository?.incomingEvents.listen((envelope) async {
      final type = envelope.type;

      if (type == MessageRoutes.syncRequestActiveState) {
        await _handleSyncRequestActiveState(envelope);
      } else if (type == MessageRoutes.syncFullStateResponse) {
        await _handleSyncFullStateResponse(envelope);
      } else if (type == MessageRoutes.syncVisitUpdated ||
          type == MessageRoutes.visitCompleted ||
          type == MessageRoutes.patientCheckedIn ||
          type == MessageRoutes.patientVitalsUpdated ||
          type == MessageRoutes.visitStarted) {
        final payload = envelope.payload;

        if (payload != null) {
          // 1. Extract and explicitly insert patient entity into local DB
          PatientProfile? extractedPatient;
          if (payload['patient'] != null) {
            try {
              Map<String, dynamic>? patientMap;
              if (payload['patient'] is Map) {
                patientMap = Map<String, dynamic>.from(payload['patient'] as Map);
              } else if (payload['patient'] is String) {
                patientMap = Map<String, dynamic>.from(jsonDecode(payload['patient'] as String) as Map);
              }
              if (patientMap != null) {
                final patientModel = PatientProfileModel.fromJson(patientMap);
                extractedPatient = patientModel;
                await _savePatientLocally(patientModel);
              }
            } catch (_) {}
          }

          // 2. Extract and explicitly insert visit entity into local DB with weight check
          ClinicVisit? incomingVisit;
          if (payload['visit'] != null) {
            try {
              Map<String, dynamic>? visitMap;
              if (payload['visit'] is Map) {
                visitMap = Map<String, dynamic>.from(payload['visit'] as Map);
              } else if (payload['visit'] is String) {
                visitMap = Map<String, dynamic>.from(jsonDecode(payload['visit'] as String) as Map);
              }
              if (visitMap != null) {
                incomingVisit = ClinicVisitModel.fromJson(visitMap);
                final queueResult = await getClinicQueueUseCase();
                final localVisits = queueResult.getOrElse(() => []);
                final localVisit = localVisits.cast<ClinicVisit?>().firstWhere(
                  (v) => v?.id == incomingVisit?.id,
                  orElse: () => null,
                );

                if (localVisit != null &&
                    _statusWeight(localVisit.status) > _statusWeight(incomingVisit.status)) {
                  // Do not overwrite newer local state with stale incoming data
                } else {
                  await _saveVisitLocally(incomingVisit);
                }
              }
            } catch (_) {}
          }

          // 3. Guarantee patient existence if payload['patient'] was omitted or partial
          if (extractedPatient == null) {
            final patId = incomingVisit?.patientId ?? payload['patientId'] as String?;
            final patName = incomingVisit?.patientName ?? payload['patientName'] as String? ?? 'Patient';
            if (patId != null) {
              final existingPatients = (await getPatientsUseCase()).getOrElse(() => []);
              final exists = existingPatients.any((p) => p.id == patId);
              if (!exists) {
                final fallbackPatient = PatientProfile(
                  id: patId,
                  name: patName,
                  phone: '',
                  createdAt: DateTime.now(),
                );
                await _savePatientLocally(fallbackPatient);
              }
            }
          }
        }

        // 4. Trigger queue reload so UI immediately sees new/updated entities
        add(const LoadClinicQueueEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _lanSyncSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadClinicQueue(
    LoadClinicQueueEvent event,
    Emitter<ClinicState> emit,
  ) async {
    emit(ClinicLoading());
    final queueResult = await getClinicQueueUseCase();
    final patientsResult = await getPatientsUseCase();
    final waitResult = await getRollingMeanWaitUseCase(event.doctorName ?? 'General Practitioner');

    queueResult.fold(
      (failure) => emit(ClinicError(failure.message)),
      (queue) {
        final patients = patientsResult.getOrElse(() => []);
        final waitMin = waitResult.getOrElse(() => 15);
        final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed).toList();
        billingVisits.sort((a, b) {
          final timeA = a.completionTime ?? a.checkInTime;
          final timeB = b.completionTime ?? b.checkInTime;
          return timeB.compareTo(timeA);
        });

        emit(
          ClinicLoaded(
            queue: queue,
            patients: patients,
            billingVisits: billingVisits,
            rollingMeanWaitMinutes: waitMin,
          ),
        );
      },
    );
  }

  Future<void> _onCheckInPatient(
    CheckInPatientEvent event,
    Emitter<ClinicState> emit,
  ) async {
    emit(ClinicLoading());
    final currentQueue = (await getClinicQueueUseCase()).getOrElse(() => []);
    final queueNumber = currentQueue.length + 1;

    final visit = ClinicVisit(
      id: 'vis_${DateTime.now().millisecondsSinceEpoch}',
      patientId: event.patientId,
      patientName: event.patientName,
      doctorName: event.doctorName,
      roomNumber: event.roomNumber,
      queueNumber: queueNumber,
      status: ClinicVisitStatus.waiting,
      checkInTime: DateTime.now(),
      chiefComplaint: event.chiefComplaint,
    );

    final result = await checkInPatientUseCase(visit);

    await result.fold(
      (failure) async => emit(ClinicError(failure.message)),
      (savedVisit) async {
        // Ensure patient exists in local repository or create default profile
        final existingPatients = (await getPatientsUseCase()).getOrElse(() => []);
        var patient = existingPatients.cast<PatientProfile?>().firstWhere(
          (p) => p?.id == event.patientId,
          orElse: () => null,
        );
        if (patient == null) {
          patient = PatientProfile(
            id: event.patientId,
            name: event.patientName,
            phone: '',
            createdAt: DateTime.now(),
          );
          await _savePatientLocally(patient);
        }

        // Broadcast patient checked in event with FULL DATA PAYLOAD to all LAN stations
        final envelope = SyncEnvelope.create(
          type: MessageRoutes.patientCheckedIn,
          scope: 'clinic',
          senderId: 'reception_desk',
          senderRole: 'receptionist',
          payload: {
            'visitId': savedVisit.id,
            'patientId': savedVisit.patientId,
            'patientName': savedVisit.patientName,
            'queueNumber': savedVisit.queueNumber,
            'patient': PatientProfileModel.fromEntity(patient).toJson(),
            'visit': ClinicVisitModel.fromEntity(savedVisit).toJson(),
          },
        );
        await lanSyncRepository?.broadcast(envelope);

        final queue = (await getClinicQueueUseCase()).getOrElse(() => []);
        final patients = (await getPatientsUseCase()).getOrElse(() => []);
        final waitMin = (await getRollingMeanWaitUseCase(event.doctorName)).getOrElse(() => 15);
        final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed).toList();
        billingVisits.sort((a, b) {
          final timeA = a.completionTime ?? a.checkInTime;
          final timeB = b.completionTime ?? b.checkInTime;
          return timeB.compareTo(timeA);
        });

        emit(
          ClinicLoaded(
            queue: queue,
            patients: patients,
            billingVisits: billingVisits,
            rollingMeanWaitMinutes: waitMin,
            activeVisitId: savedVisit.id,
            activePatientId: savedVisit.patientId,
          ),
        );
      },
    );
  }

  Future<void> _onUpdateVisitStatus(
    UpdateVisitStatusEvent event,
    Emitter<ClinicState> emit,
  ) async {
    emit(ClinicLoading());
    final result = await updateVisitStatusUseCase(event.visitId, event.status);

    await result.fold(
      (failure) async => emit(ClinicError(failure.message)),
      (updated) async {
        // Look up patient for full payload sync
        final existingPatients = (await getPatientsUseCase()).getOrElse(() => []);
        var patient = existingPatients.cast<PatientProfile?>().firstWhere(
          (p) => p?.id == updated.patientId,
          orElse: () => null,
        );
        if (patient == null) {
          patient = PatientProfile(
            id: updated.patientId,
            name: updated.patientName,
            phone: '',
            createdAt: DateTime.now(),
          );
          await _savePatientLocally(patient);
        }

        // Broadcast visit.updated event with FULL DATA PAYLOAD
        final envelope = SyncEnvelope.create(
          type: MessageRoutes.syncVisitUpdated,
          scope: 'clinic',
          senderId: lanSyncRepository?.isHost == true ? 'hub_host' : 'clinic_station',
          senderRole: 'clinic',
          payload: {
            'visitId': updated.id,
            'patientId': updated.patientId,
            'patientName': updated.patientName,
            'status': updated.status.name,
            'patient': PatientProfileModel.fromEntity(patient).toJson(),
            'visit': ClinicVisitModel.fromEntity(updated).toJson(),
          },
        );
        await lanSyncRepository?.broadcast(envelope);

        final queue = (await getClinicQueueUseCase()).getOrElse(() => []);
        final patients = (await getPatientsUseCase()).getOrElse(() => []);
        final waitMin = (await getRollingMeanWaitUseCase(updated.doctorName)).getOrElse(() => 15);
        final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed).toList();
        billingVisits.sort((a, b) {
          final timeA = a.completionTime ?? a.checkInTime;
          final timeB = b.completionTime ?? b.checkInTime;
          return timeB.compareTo(timeA);
        });

        emit(
          ClinicLoaded(
            queue: queue,
            patients: patients,
            billingVisits: billingVisits,
            rollingMeanWaitMinutes: waitMin,
            activeVisitId: event.visitId,
          ),
        );
      },
    );
  }

  Future<void> _onCompleteVisit(
    CompleteVisitEvent event,
    Emitter<ClinicState> emit,
  ) async {
    emit(ClinicLoading());
    final result = await completeVisitUseCase(event.visit);

    await result.fold(
      (failure) async => emit(ClinicError(failure.message)),
      (completed) async {
        // Look up patient for full payload sync
        final existingPatients = (await getPatientsUseCase()).getOrElse(() => []);
        var patient = existingPatients.cast<PatientProfile?>().firstWhere(
          (p) => p?.id == completed.patientId,
          orElse: () => null,
        );
        if (patient == null) {
          patient = PatientProfile(
            id: completed.patientId,
            name: completed.patientName,
            phone: '',
            createdAt: DateTime.now(),
          );
          await _savePatientLocally(patient);
        }

        // Broadcast visit completed event with FULL DATA PAYLOAD to reception desk and other stations
        final envelope = SyncEnvelope.create(
          type: MessageRoutes.visitCompleted,
          scope: 'clinic',
          senderId: 'doctor_station_1',
          senderRole: 'doctor',
          payload: {
            'visitId': completed.id,
            'patientId': completed.patientId,
            'patientName': completed.patientName,
            'totalFee': completed.totalFee,
            'patient': PatientProfileModel.fromEntity(patient).toJson(),
            'visit': ClinicVisitModel.fromEntity(completed).toJson(),
          },
        );
        await lanSyncRepository?.broadcast(envelope);

        final queue = (await getClinicQueueUseCase()).getOrElse(() => []);
        final patients = (await getPatientsUseCase()).getOrElse(() => []);
        final waitMin = (await getRollingMeanWaitUseCase(completed.doctorName)).getOrElse(() => 15);
        final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed).toList();
        billingVisits.sort((a, b) {
          final timeA = a.completionTime ?? a.checkInTime;
          final timeB = b.completionTime ?? b.checkInTime;
          return timeB.compareTo(timeA);
        });

        emit(
          ClinicLoaded(
            queue: queue,
            patients: patients,
            billingVisits: billingVisits,
            rollingMeanWaitMinutes: waitMin,
          ),
        );
      },
    );
  }

  Future<void> _onLoadPatientToothChart(
    LoadPatientToothChartEvent event,
    Emitter<ClinicState> emit,
  ) async {
    final result = await getPatientToothChartUseCase(event.patientId);

    result.fold(
      (failure) => emit(ClinicError(failure.message)),
      (teeth) {
        if (state is ClinicLoaded) {
          final current = state as ClinicLoaded;
          emit(
            current.copyWith(
              activeToothChart: teeth,
              activePatientId: event.patientId,
            ),
          );
        }
      },
    );
  }

  void _onUpdateToothChartEntry(
    UpdateToothChartEntryEvent event,
    Emitter<ClinicState> emit,
  ) {
    if (state is ClinicLoaded) {
      final current = state as ClinicLoaded;
      final existingChart = List<ToothChartEntry>.from(current.activeToothChart ?? []);
      final index = existingChart.indexWhere(
        (t) => t.effectiveToothCode == event.entry.effectiveToothCode,
      );
      if (index != -1) {
        existingChart[index] = event.entry;
      } else {
        existingChart.add(event.entry);
      }
      emit(current.copyWith(activeToothChart: existingChart));
    }
  }

  Future<void> _onSaveToothChart(
    SaveToothChartEvent event,
    Emitter<ClinicState> emit,
  ) async {
    final result = await saveToothChartUseCase(event.patientId, event.entries);

    result.fold(
      (failure) => emit(ClinicError(failure.message)),
      (_) {
        if (state is ClinicLoaded) {
          final current = state as ClinicLoaded;
          emit(current.copyWith(activeToothChart: event.entries));
        }
      },
    );
  }

  Future<void> _onSearchClinicPatients(
    SearchClinicPatientsEvent event,
    Emitter<ClinicState> emit,
  ) async {
    final result = await searchPatientsUseCase(event.query);

    result.fold(
      (failure) => emit(ClinicError(failure.message)),
      (patients) {
        if (state is ClinicLoaded) {
          final current = state as ClinicLoaded;
          emit(current.copyWith(patients: patients));
        }
      },
    );
  }
}
