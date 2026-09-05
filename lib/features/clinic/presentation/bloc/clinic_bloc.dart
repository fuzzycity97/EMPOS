import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/lan_sync/data/message_routes.dart';
import '../../../../core/network/lan_sync/domain/entities/sync_envelope.dart';
import '../../../../core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import '../../../customers/data/models/customer_ledger_entry_model.dart';
import '../../../customers/data/models/customer_model.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/domain/repositories/customer_repository.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../../data/models/clinic_visit_model.dart';
import '../../data/models/medical_risk_factor_model.dart';
import '../../data/models/patient_profile_model.dart';
import '../../domain/entities/clinic_visit.dart';
import '../../domain/entities/medical_risk_factor.dart';
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
  final CustomerRepository? customerRepository;
  final LanSyncRepository? lanSyncRepository;

  StreamSubscription? _lanSyncSubscription;

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
    this.customerRepository,
    this.lanSyncRepository,
  }) : super(ClinicInitial()) {
    on<LoadClinicQueueEvent>(_onLoadClinicQueue);
    on<CheckInPatientEvent>(_onCheckInPatient);
    on<UpdatePatientProfileEvent>(_onUpdatePatientProfile);
    on<UpdateVisitStatusEvent>(_onUpdateVisitStatus);
    on<CompleteVisitEvent>(_onCompleteVisit);
    on<ProcessVisitPaymentEvent>(_onProcessVisitPayment);
    on<UpdateVisitVitalsEvent>(_onUpdateVisitVitals);
    on<LoadPatientToothChartEvent>(_onLoadPatientToothChart);
    on<ResetToothChartEvent>(_onResetToothChart);
    on<UpdateToothChartEntryEvent>(_onUpdateToothChartEntry);
    on<SaveToothChartEvent>(_onSaveToothChart);
    on<SearchClinicPatientsEvent>(_onSearchClinicPatients);
    on<LoadMedicalRiskFactorsEvent>(_onLoadMedicalRiskFactors);
    on<UpdateMedicalRiskFactorsEvent>(_onUpdateMedicalRiskFactors);

    _initLanSyncListener();
  }

  Future<void> _savePatientLocally(PatientProfile patient) async {
    if (savePatientUseCase != null) {
      await savePatientUseCase!(patient);
    } else if (clinicRepository != null) {
      await clinicRepository!.savePatient(patient);
    }

    if (customerRepository != null) {
      try {
        final custRes = await customerRepository!.getCustomerById(patient.id);
        Customer? existingCust;
        custRes.fold((_) {}, (c) => existingCust = c);
        if (existingCust == null && patient.phone.isNotEmpty) {
          final allCustsRes = await customerRepository!.getCustomers();
          final allCusts = allCustsRes.getOrElse(() => []);
          existingCust = allCusts.cast<Customer?>().firstWhere(
            (c) => c?.phone.trim() == patient.phone.trim(),
            orElse: () => null,
          );
        }

        final customer = Customer(
          id: existingCust?.id ?? patient.id,
          name: patient.name,
          phone: patient.phone,
          address: existingCust?.address,
          totalDebt: existingCust?.totalDebt ?? 0.0,
          loyaltyPoints: existingCust?.loyaltyPoints ?? 0,
          notes: existingCust?.notes,
          createdAt: existingCust?.createdAt ?? patient.createdAt,
        );
        await customerRepository!.saveCustomer(customer);
        final ledgerRes = await customerRepository!.getCustomerLedger(customer.id);
        final ledgerEntries = ledgerRes.getOrElse(() => []);
        final envelope = SyncEnvelope.create(
          type: MessageRoutes.customerUpdated,
          scope: 'crm',
          senderId: lanSyncRepository?.isHost == true ? 'hub_host' : 'clinic_station',
          senderRole: 'clinic',
          payload: {
            'customer': CustomerModel.fromEntity(customer).toJson(),
            'ledgerEntries': ledgerEntries.map((e) => CustomerLedgerEntryModel.fromEntity(e).toJson()).toList(),
          },
        );
        await lanSyncRepository?.broadcast(envelope);
      } catch (_) {}
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

      // Collect all CRM customers and their ledger entries to guarantee complete CRM reconciliation
      final List<Map<String, dynamic>> customersJson = [];
      final List<Map<String, dynamic>> ledgerEntriesJson = [];
      if (customerRepository != null) {
        try {
          final custRes = await customerRepository!.getCustomers();
          final allCusts = custRes.getOrElse(() => []);
          for (final c in allCusts) {
            customersJson.add(CustomerModel.fromEntity(c).toJson());
            final ledgerRes = await customerRepository!.getCustomerLedger(c.id);
            final entries = ledgerRes.getOrElse(() => []);
            for (final e in entries) {
              ledgerEntriesJson.add(CustomerLedgerEntryModel.fromEntity(e).toJson());
            }
          }
        } catch (_) {}
      }

      // Collect all configured medical risk factors
      final List<Map<String, dynamic>> riskFactorsJson = [];
      if (clinicRepository != null) {
        try {
          final rfRes = await clinicRepository!.getMedicalRiskFactors();
          final rfList = rfRes.getOrElse(() => []);
          for (final f in rfList) {
            riskFactorsJson.add(MedicalRiskFactorModel.fromEntity(f).toJson());
          }
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
          'customers': customersJson,
          'customerLedgerEntries': ledgerEntriesJson,
          'riskFactors': riskFactorsJson,
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

      // 3. Batch upsert full CRM customers directory and ledger entries
      if (payload['customers'] != null && payload['customers'] is List && customerRepository != null) {
        final customersList = payload['customers'] as List;
        for (final item in customersList) {
          try {
            Map<String, dynamic>? customerMap;
            if (item is Map) {
              customerMap = Map<String, dynamic>.from(item);
            } else if (item is String) {
              customerMap = Map<String, dynamic>.from(jsonDecode(item) as Map);
            }
            if (customerMap != null) {
              final customerModel = CustomerModel.fromJson(customerMap);
              await customerRepository!.saveCustomer(customerModel);
            }
          } catch (_) {}
        }
      }

      if (payload['customerLedgerEntries'] != null && payload['customerLedgerEntries'] is List && customerRepository != null) {
        final ledgerList = payload['customerLedgerEntries'] as List;
        final List<CustomerLedgerEntryModel> ledgerModels = [];
        for (final item in ledgerList) {
          try {
            Map<String, dynamic>? entryMap;
            if (item is Map) {
              entryMap = Map<String, dynamic>.from(item);
            } else if (item is String) {
              entryMap = Map<String, dynamic>.from(jsonDecode(item) as Map);
            }
            if (entryMap != null) {
              ledgerModels.add(CustomerLedgerEntryModel.fromJson(entryMap));
            }
          } catch (_) {}
        }
        if (ledgerModels.isNotEmpty) {
          await customerRepository!.saveLedgerEntries(ledgerModels);
        }
      }

      // 4. Batch upsert medical risk factors
      if (payload['riskFactors'] != null && payload['riskFactors'] is List && clinicRepository != null) {
        final rfList = payload['riskFactors'] as List;
        final List<MedicalRiskFactorModel> rfModels = [];
        for (final item in rfList) {
          try {
            if (item is Map) {
              rfModels.add(MedicalRiskFactorModel.fromJson(Map<String, dynamic>.from(item)));
            } else if (item is String) {
              rfModels.add(MedicalRiskFactorModel.fromJson(Map<String, dynamic>.from(jsonDecode(item) as Map)));
            }
          } catch (_) {}
        }
        if (rfModels.isNotEmpty) {
          await clinicRepository!.saveMedicalRiskFactors(rfModels);
        }
      }

      // 5. ONLY AFTER the database writes are complete, dispatch LoadClinicQueueEvent()
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
      } else if (type == 'clinic.risk_factors_updated') {
        final payload = envelope.payload;
        if (payload != null && payload['riskFactors'] is List && clinicRepository != null) {
          try {
            final List<MedicalRiskFactorModel> rfModels = [];
            for (final item in payload['riskFactors']) {
              if (item is Map) {
                rfModels.add(MedicalRiskFactorModel.fromJson(Map<String, dynamic>.from(item)));
              }
            }
            if (rfModels.isNotEmpty) {
              await clinicRepository!.saveMedicalRiskFactors(rfModels);
              add(const LoadMedicalRiskFactorsEvent());
            }
          } catch (_) {}
        }
      } else if (type == MessageRoutes.customerUpdated) {
        final payload = envelope.payload;
        if (payload != null && customerRepository != null) {
          try {
            if (payload['ledgerEntries'] is List) {
              final ledgerList = payload['ledgerEntries'] as List;
              final List<CustomerLedgerEntryModel> ledgerModels = [];
              for (final item in ledgerList) {
                try {
                  Map<String, dynamic>? entryMap;
                  if (item is Map) {
                    entryMap = Map<String, dynamic>.from(item);
                  } else if (item is String) {
                    entryMap = Map<String, dynamic>.from(jsonDecode(item) as Map);
                  }
                  if (entryMap != null) {
                    ledgerModels.add(CustomerLedgerEntryModel.fromJson(entryMap));
                  }
                } catch (_) {}
              }
              if (ledgerModels.isNotEmpty) {
                await customerRepository!.saveLedgerEntries(ledgerModels);
              }
            }

            if (payload['customer'] != null) {
              Map<String, dynamic>? customerMap;
              if (payload['customer'] is Map) {
                customerMap = Map<String, dynamic>.from(payload['customer'] as Map);
              } else if (payload['customer'] is String) {
                customerMap = Map<String, dynamic>.from(jsonDecode(payload['customer'] as String) as Map);
              }
              if (customerMap != null) {
                final customerModel = CustomerModel.fromJson(customerMap);
                await customerRepository!.saveCustomer(customerModel);
              }
            }
          } catch (_) {}
        }
      } else if (type == MessageRoutes.syncVisitUpdated ||
          type == MessageRoutes.visitCompleted ||
          type == MessageRoutes.patientCheckedIn ||
          type == MessageRoutes.patientVitalsUpdated ||
          type == MessageRoutes.visitStarted || type == MessageRoutes.patientUpdated) {
        final payload = envelope.payload;

        if (payload != null) {
          // 1. Extract and explicitly insert patient entity into local DB
          PatientProfile? extractedPatient;
          if (payload['id'] != null && payload['name'] != null) { try { final pm = PatientProfileModel.fromJson(payload); extractedPatient = pm; await _savePatientLocally(pm); } catch (_) {} } else if (payload['patient'] != null) {
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

    final rfRes = clinicRepository != null
        ? await clinicRepository!.getMedicalRiskFactors()
        : null;
    final riskFactors = rfRes?.getOrElse(() => MedicalRiskFactor.defaultFactors) ?? MedicalRiskFactor.defaultFactors;

    queueResult.fold(
      (failure) => emit(ClinicError(failure.message)),
      (queue) {
        final patients = patientsResult.getOrElse(() => []);
        final waitMin = waitResult.getOrElse(() => 15);
        final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed && !v.isPaid).toList();
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
            riskFactors: riskFactors,
          ),
        );
      },
    );
  }

  Future<void> _onLoadMedicalRiskFactors(
    LoadMedicalRiskFactorsEvent event,
    Emitter<ClinicState> emit,
  ) async {
    if (state is ClinicLoaded && clinicRepository != null) {
      final currentState = state as ClinicLoaded;
      final factorsRes = await clinicRepository!.getMedicalRiskFactors();
      final factors = factorsRes.getOrElse(() => MedicalRiskFactor.defaultFactors);
      emit(currentState.copyWith(riskFactors: factors));
    }
  }

  Future<void> _onUpdateMedicalRiskFactors(
    UpdateMedicalRiskFactorsEvent event,
    Emitter<ClinicState> emit,
  ) async {
    if (clinicRepository != null) {
      await clinicRepository!.saveMedicalRiskFactors(event.factors);
    }
    if (state is ClinicLoaded) {
      final currentState = state as ClinicLoaded;
      emit(currentState.copyWith(riskFactors: event.factors));
    }

    // Broadcast updated factors over LAN
    if (lanSyncRepository != null) {
      try {
        final models = event.factors
            .map((f) => MedicalRiskFactorModel.fromEntity(f).toJson())
            .toList();
        final envelope = SyncEnvelope.create(
          type: 'clinic.risk_factors_updated',
          scope: 'clinic',
          senderId: lanSyncRepository?.isHost == true ? 'hub_host' : 'clinic_station',
          senderRole: 'clinic',
          payload: {
            'riskFactors': models,
          },
        );
        await lanSyncRepository!.broadcast(envelope);
      } catch (_) {}
    }
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
        final rawAge = event.age?.trim();
        final effectiveAge = (rawAge != null && rawAge.isNotEmpty) ? rawAge : null;

        if (patient == null) {
          patient = PatientProfile(
            id: event.patientId,
            name: event.patientName,
            phone: event.phone,
            dateOfBirth: effectiveAge,
            chronicConditions: event.chronicConditions,
            allergies: event.allergies,
            createdAt: DateTime.now(),
          );
          await _savePatientLocally(patient);
        } else {
          patient = patient.copyWith(
            name: event.patientName,
            phone: event.phone.isNotEmpty ? event.phone : patient.phone,
            dateOfBirth: effectiveAge ?? patient.dateOfBirth,
            chronicConditions: event.chronicConditions.isNotEmpty ? event.chronicConditions : patient.chronicConditions,
            allergies: event.allergies.isNotEmpty ? event.allergies : patient.allergies,
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
        final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed && !v.isPaid).toList();
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

  Future<void> _onUpdatePatientProfile(
    UpdatePatientProfileEvent event,
    Emitter<ClinicState> emit,
  ) async {
    await _savePatientLocally(event.patient);

    final envelope = SyncEnvelope.create(
      type: MessageRoutes.patientUpdated,
      scope: 'clinic',
      senderId: lanSyncRepository?.isHost == true ? 'hub_host' : 'clinic_station',
      senderRole: 'clinic',
      payload: PatientProfileModel.fromEntity(event.patient).toJson(),
    );
    await lanSyncRepository?.broadcast(envelope);

    if (state is ClinicLoaded) {
      final current = state as ClinicLoaded;
      final updatedList = current.patients.map((p) => p.id == event.patient.id ? event.patient : p).toList();
      if (!updatedList.any((p) => p.id == event.patient.id)) {
        updatedList.add(event.patient);
      }
      emit(current.copyWith(patients: updatedList));
    } else {
      add(const LoadClinicQueueEvent());
    }
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
        final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed && !v.isPaid).toList();
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
        final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed && !v.isPaid).toList();
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

  Future<void> _onProcessVisitPayment(
    ProcessVisitPaymentEvent event,
    Emitter<ClinicState> emit,
  ) async {
    emit(ClinicLoading());
    final queueResult = await getClinicQueueUseCase();
    final allVisits = queueResult.getOrElse(() => []);
    final visit = allVisits.cast<ClinicVisit?>().firstWhere(
      (v) => v?.id == event.visitId,
      orElse: () => null,
    );

    if (visit != null) {
      final existingPatients = (await getPatientsUseCase()).getOrElse(() => []);
      final patient = existingPatients.cast<PatientProfile?>().firstWhere(
        (p) => p?.id == visit.patientId,
        orElse: () => null,
      );

      final totalFee = visit.totalFee;
      final copayRatio = patient?.defaultCopayPercentage ?? 1.0;
      final expectedPatientShare = visit.patientCopay > 0 ? visit.patientCopay : (totalFee * copayRatio);

      final actualPaid = event.amountPaid ?? expectedPatientShare;
      final remainingDebt = (expectedPatientShare - actualPaid).clamp(0.0, double.infinity);

      final updatedVisit = visit.copyWith(
        isPaid: true,
        patientCopay: actualPaid,
      );
      await _saveVisitLocally(updatedVisit);

      // Sync debt charge and copay payment to CustomerRepository ledger if applicable
      if (customerRepository != null) {
        try {
          final customersRes = await customerRepository!.getCustomers();
          final customers = customersRes.getOrElse(() => []);
          final patientPhone = patient?.phone.trim();
          final existingCust = customers.cast<Customer?>().firstWhere(
            (c) => c?.id == visit.patientId || (patientPhone != null && patientPhone.isNotEmpty && c?.phone.trim() == patientPhone),
            orElse: () => null,
          );

          String targetCustId = visit.patientId;
          if (existingCust != null) {
            targetCustId = existingCust.id;
          } else {
            final newCust = Customer(
              id: visit.patientId,
              name: visit.patientName,
              phone: patient?.phone ?? '',
              totalDebt: 0.0,
              createdAt: DateTime.now(),
            );
            await customerRepository!.saveCustomer(newCust);
          }

          // 1. Record consultation charge in ledger if copay was due
          if (expectedPatientShare > 0) {
            await customerRepository!.chargeCustomerDebt(
              customerId: targetCustId,
              amount: expectedPatientShare,
              notes: 'Clinic Consultation Fee (Visit #${visit.id})',
            );
          }

          // 2. Record payment in ledger if actual payment was collected
          if (actualPaid > 0) {
            await customerRepository!.processDebtPayment(
              customerId: targetCustId,
              amount: actualPaid,
              paymentTender: TenderType.cash,
              notes: 'Copay Settlement at Reception (Visit #${visit.id})',
            );
          }

          final updatedCustRes = await customerRepository!.getCustomerById(targetCustId);
          final ledgerRes = await customerRepository!.getCustomerLedger(targetCustId);
          final ledgerEntries = ledgerRes.getOrElse(() => []);
          updatedCustRes.fold((_) {}, (savedCust) {
            final crmEnvelope = SyncEnvelope.create(
              type: MessageRoutes.customerUpdated,
              scope: 'crm',
              senderId: lanSyncRepository?.isHost == true ? 'hub_host' : 'reception_station',
              senderRole: 'receptionist',
              payload: {
                'customer': CustomerModel.fromEntity(savedCust).toJson(),
                'ledgerEntries': ledgerEntries.map((e) => CustomerLedgerEntryModel.fromEntity(e).toJson()).toList(),
              },
            );
            lanSyncRepository?.broadcast(crmEnvelope);
          });
        } catch (_) {}
      }

      final envelope = SyncEnvelope.create(
        type: MessageRoutes.syncVisitUpdated,
        scope: 'clinic',
        senderId: lanSyncRepository?.isHost == true ? 'hub_host' : 'clinic_station',
        senderRole: 'receptionist',
        payload: {
          'visitId': updatedVisit.id,
          'patientId': updatedVisit.patientId,
          'patientName': updatedVisit.patientName,
          'status': updatedVisit.status.name,
          'isPaid': true,
          'patientCopay': actualPaid,
          'remainingDebt': remainingDebt,
          'patient': patient != null ? PatientProfileModel.fromEntity(patient).toJson() : null,
          'visit': ClinicVisitModel.fromEntity(updatedVisit).toJson(),
        },
      );
      await lanSyncRepository?.broadcast(envelope);
    }

    final queue = (await getClinicQueueUseCase()).getOrElse(() => []);
    final patients = (await getPatientsUseCase()).getOrElse(() => []);
    final waitMin = (await getRollingMeanWaitUseCase(visit?.doctorName ?? 'General Practitioner')).getOrElse(() => 15);
    final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed && !v.isPaid).toList();
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
  }

  Future<void> _onUpdateVisitVitals(
    UpdateVisitVitalsEvent event,
    Emitter<ClinicState> emit,
  ) async {
    emit(ClinicLoading());
    final queueResult = await getClinicQueueUseCase();
    final allVisits = queueResult.getOrElse(() => []);
    final visit = allVisits.cast<ClinicVisit?>().firstWhere(
      (v) => v?.id == event.visitId,
      orElse: () => null,
    );

    if (visit != null) {
      final updatedVisit = visit.copyWith(
        bloodPressure: event.bloodPressure,
        heartRate: event.heartRate,
        spo2: event.spo2,
        temperature: event.temperature,
        respiratoryRate: event.respiratoryRate,
      );
      await _saveVisitLocally(updatedVisit);

      final existingPatients = (await getPatientsUseCase()).getOrElse(() => []);
      final patient = existingPatients.cast<PatientProfile?>().firstWhere(
        (p) => p?.id == updatedVisit.patientId,
        orElse: () => null,
      );

      final envelope = SyncEnvelope.create(
        type: MessageRoutes.syncVisitUpdated,
        scope: 'clinic',
        senderId: lanSyncRepository?.isHost == true ? 'hub_host' : 'clinic_station',
        senderRole: 'doctor',
        payload: {
          'visitId': updatedVisit.id,
          'patientId': updatedVisit.patientId,
          'patientName': updatedVisit.patientName,
          'status': updatedVisit.status.name,
          'patient': patient != null ? PatientProfileModel.fromEntity(patient).toJson() : null,
          'visit': ClinicVisitModel.fromEntity(updatedVisit).toJson(),
        },
      );
      await lanSyncRepository?.broadcast(envelope);
    }

    final queue = (await getClinicQueueUseCase()).getOrElse(() => []);
    final patients = (await getPatientsUseCase()).getOrElse(() => []);
    final waitMin = (await getRollingMeanWaitUseCase(visit?.doctorName ?? 'General Practitioner')).getOrElse(() => 15);
    final billingVisits = queue.where((v) => v.status == ClinicVisitStatus.completed && !v.isPaid).toList();
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

  void _onResetToothChart(
    ResetToothChartEvent event,
    Emitter<ClinicState> emit,
  ) {
    if (state is ClinicLoaded) {
      final current = state as ClinicLoaded;
      List<ToothChartEntry> baseTeeth;
      if (event.initialEntries != null && event.initialEntries!.isNotEmpty) {
        baseTeeth = List<ToothChartEntry>.from(event.initialEntries!);
      } else if (event.isPediatric) {
        baseTeeth = ToothChartEntry.primaryToothCodes.asMap().entries.map((entry) {
          return ToothChartEntry(
            toothNumber: entry.key + 1,
            toothCode: entry.value,
            isDeciduous: true,
            state: ToothState.healthy,
          );
        }).toList();
      } else {
        baseTeeth = List.generate(
          32,
          (index) => ToothChartEntry(
            toothNumber: index + 1,
            toothCode: (index + 1).toString(),
            isDeciduous: false,
            state: ToothState.healthy,
          ),
        );
      }
      emit(current.copyWith(activeToothChart: baseTeeth));
    }
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
