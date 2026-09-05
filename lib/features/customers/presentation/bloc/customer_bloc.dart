import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/lan_sync/data/message_routes.dart';
import '../../../../core/network/lan_sync/domain/entities/sync_envelope.dart';
import '../../../../core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/customer_ledger_entry_model.dart';
import '../../data/models/customer_model.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../domain/usecases/charge_customer_debt_usecase.dart';
import '../../domain/usecases/get_customer_by_id_usecase.dart';
import '../../domain/usecases/get_customer_ledger_usecase.dart';
import '../../domain/usecases/get_customers_usecase.dart';
import '../../domain/usecases/process_debt_payment_usecase.dart';
import '../../domain/usecases/save_customer_usecase.dart';
import 'customer_event.dart';
import 'customer_state.dart';

class CustomerBloc extends Bloc<CustomerEvent, CustomerState> {
  final GetCustomersUseCase getCustomersUseCase;
  final GetCustomerByIdUseCase getCustomerByIdUseCase;
  final SaveCustomerUseCase saveCustomerUseCase;
  final ChargeCustomerDebtUseCase chargeCustomerDebtUseCase;
  final ProcessDebtPaymentUseCase processDebtPaymentUseCase;
  final GetCustomerLedgerUseCase getCustomerLedgerUseCase;
  final LanSyncRepository? lanSyncRepository;
  final CustomerRepository? customerRepository;

  StreamSubscription<SyncEnvelope>? _lanSyncSubscription;

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.getCustomerByIdUseCase,
    required this.saveCustomerUseCase,
    required this.chargeCustomerDebtUseCase,
    required this.processDebtPaymentUseCase,
    required this.getCustomerLedgerUseCase,
    this.lanSyncRepository,
    this.customerRepository,
  }) : super(const CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<SearchCustomersEvent>(_onSearchCustomers);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<SaveCustomerEvent>(_onSaveCustomer);
    on<ProcessDebtPaymentEvent>(_onProcessDebtPayment);
    on<ChargeDebtEvent>(_onChargeDebt);

    _initLanSyncListener();
  }

  void _initLanSyncListener() {
    _lanSyncSubscription = lanSyncRepository?.incomingEvents.listen((envelope) async {
      final type = envelope.type;
      if (type == MessageRoutes.customerUpdated ||
          type == MessageRoutes.syncFullStateResponse ||
          type == MessageRoutes.patientCheckedIn ||
          type == MessageRoutes.syncVisitUpdated ||
          type == MessageRoutes.visitCompleted) {
        final payload = envelope.payload;
        if (payload != null && customerRepository != null) {
          try {
            // 1. Ingest single customer
            if (payload['customer'] != null) {
              final cMap = payload['customer'] is Map
                  ? Map<String, dynamic>.from(payload['customer'] as Map)
                  : Map<String, dynamic>.from(jsonDecode(payload['customer'] as String) as Map);
              final cust = CustomerModel.fromJson(cMap);
              await customerRepository!.saveCustomer(cust);
            }
            // 2. Ingest batch customers
            if (payload['customers'] is List) {
              for (final cJson in payload['customers'] as List) {
                try {
                  final cMap = cJson is Map
                      ? Map<String, dynamic>.from(cJson)
                      : Map<String, dynamic>.from(jsonDecode(cJson as String) as Map);
                  final cust = CustomerModel.fromJson(cMap);
                  await customerRepository!.saveCustomer(cust);
                } catch (_) {}
              }
            }
            // 3. Ingest ledger entries
            final List<CustomerLedgerEntryModel> ledgerModels = [];
            final rawLedger = payload['ledgerEntries'] ?? payload['customerLedgerEntries'];
            if (rawLedger is List) {
              for (final eJson in rawLedger) {
                try {
                  final eMap = eJson is Map
                      ? Map<String, dynamic>.from(eJson)
                      : Map<String, dynamic>.from(jsonDecode(eJson as String) as Map);
                  ledgerModels.add(CustomerLedgerEntryModel.fromJson(eMap));
                } catch (_) {}
              }
            }
            if (ledgerModels.isNotEmpty) {
              await customerRepository!.saveLedgerEntries(ledgerModels);
            }
          } catch (_) {}
        }
        add(const LoadCustomersEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _lanSyncSubscription?.cancel();
    return super.close();
  }


  Future<void> _onLoadCustomers(
    LoadCustomersEvent event,
    Emitter<CustomerState> emit,
  ) async {
    emit(const CustomerLoading());
    final result = await getCustomersUseCase();
    result.fold(
      (failure) => emit(CustomerError(failure.message)),
      (customers) => emit(
        CustomersLoaded(
          allCustomers: customers,
          displayedCustomers: customers,
        ),
      ),
    );
  }

  void _onSearchCustomers(
    SearchCustomersEvent event,
    Emitter<CustomerState> emit,
  ) {
    if (state is! CustomersLoaded) return;
    final currentState = state as CustomersLoaded;
    final query = event.query.trim().toLowerCase();

    if (query.isEmpty) {
      emit(currentState.copyWith(
        searchQuery: '',
        displayedCustomers: currentState.allCustomers,
      ));
      return;
    }

    final filtered = currentState.allCustomers.where((c) {
      final nameMatch = c.name.toLowerCase().contains(query);
      final phoneMatch = c.phone.toLowerCase().contains(query);
      return nameMatch || phoneMatch;
    }).toList();

    emit(currentState.copyWith(
      searchQuery: event.query,
      displayedCustomers: filtered,
    ));
  }

  Future<void> _onSelectCustomer(
    SelectCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is! CustomersLoaded) return;
    final currentState = state as CustomersLoaded;

    if (event.customerId == null) {
      emit(currentState.copyWith(
        clearSelectedCustomer: true,
        selectedCustomerLedger: const [],
      ));
      return;
    }

    final customerRes = await getCustomerByIdUseCase(event.customerId!);
    final ledgerRes = await getCustomerLedgerUseCase(event.customerId!);

    Customer? selectedCustomer;
    customerRes.fold((_) {}, (c) => selectedCustomer = c);

    ledgerRes.fold(
      (_) => emit(currentState.copyWith(
        selectedCustomer: selectedCustomer,
        selectedCustomerLedger: const [],
      )),
      (ledger) => emit(currentState.copyWith(
        selectedCustomer: selectedCustomer,
        selectedCustomerLedger: ledger,
      )),
    );
  }

  Future<void> _onSaveCustomer(
    SaveCustomerEvent event,
    Emitter<CustomerState> emit,
  ) async {
    final saveRes = await saveCustomerUseCase(event.customer);
    await saveRes.fold(
      (failure) async {
        if (state is CustomersLoaded) {
          emit((state as CustomersLoaded).copyWith(
            toastMessage: 'Failed to save customer: ${failure.message}',
          ));
        } else {
          emit(CustomerError(failure.message));
        }
      },
      (savedCustomer) async {
        final allRes = await getCustomersUseCase();
        allRes.fold(
          (f) => emit(CustomerError(f.message)),
          (customers) {
            final query = state is CustomersLoaded
                ? (state as CustomersLoaded).searchQuery
                : '';
            final filtered = query.isEmpty
                ? customers
                : customers.where((c) {
                    final nameMatch = c.name.toLowerCase().contains(query.toLowerCase());
                    final phoneMatch = c.phone.toLowerCase().contains(query.toLowerCase());
                    return nameMatch || phoneMatch;
                  }).toList();

            emit(CustomersLoaded(
              allCustomers: customers,
              displayedCustomers: filtered,
              searchQuery: query,
              toastMessage: 'Customer "${savedCustomer.name}" saved successfully.',
            ));

            // Broadcast customer update to all LAN peers
            final envelope = SyncEnvelope.create(
              type: MessageRoutes.customerUpdated,
              scope: 'crm',
              senderId: 'crm_station',
              senderRole: 'staff',
              payload: {
                'customer': CustomerModel.fromEntity(savedCustomer).toJson(),
              },
            );
            lanSyncRepository?.broadcast(envelope);
          },
        );
      },
    );
  }

  Future<void> _onProcessDebtPayment(
    ProcessDebtPaymentEvent event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is CustomersLoaded) {
      emit((state as CustomersLoaded).copyWith(isProcessing: true));
    }

    final payRes = await processDebtPaymentUseCase(
      ProcessDebtPaymentParams(
        customerId: event.customerId,
        amount: event.amount,
        paymentTender: event.paymentTender,
        notes: event.notes,
      ),
    );

    await payRes.fold(
      (failure) async {
        if (state is CustomersLoaded) {
          emit((state as CustomersLoaded).copyWith(
            isProcessing: false,
            toastMessage: 'Debt payment failed: ${failure.message}',
          ));
        }
      },
      (ledgerEntry) async {
        // Refresh customer list & selected customer ledger
        final allRes = await getCustomersUseCase();
        final customerRes = await getCustomerByIdUseCase(event.customerId);
        final ledgerRes = await getCustomerLedgerUseCase(event.customerId);

        List<Customer> allCustomers = [];
        Customer? updatedCust;
        allRes.fold((_) {}, (list) => allCustomers = list);
        customerRes.fold((_) {}, (c) => updatedCust = c);

        final currentLedger = ledgerRes.getOrElse(() => []);
        if (updatedCust != null) {
          final envelope = SyncEnvelope.create(
            type: MessageRoutes.customerUpdated,
            scope: 'crm',
            senderId: 'crm_station',
            senderRole: 'staff',
            payload: {
              'customer': CustomerModel.fromEntity(updatedCust!).toJson(),
              'ledgerEntries': currentLedger.map((e) => CustomerLedgerEntryModel.fromEntity(e).toJson()).toList(),
            },
          );
          lanSyncRepository?.broadcast(envelope);
        }

        final query = state is CustomersLoaded
            ? (state as CustomersLoaded).searchQuery
            : '';
        final filtered = query.isEmpty
            ? allCustomers
            : allCustomers.where((c) {
                final nameMatch = c.name.toLowerCase().contains(query.toLowerCase());
                final phoneMatch = c.phone.toLowerCase().contains(query.toLowerCase());
                return nameMatch || phoneMatch;
              }).toList();

        final remainingMsg = updatedCust != null
            ? (updatedCust!.totalDebt > 0.001
                ? ' Remaining debt: ${CurrencyFormatter.format(updatedCust!.totalDebt)}'
                : ' Debt fully settled.')
            : '';

        ledgerRes.fold(
          (_) => emit(CustomersLoaded(
            allCustomers: allCustomers,
            displayedCustomers: filtered,
            searchQuery: query,
            selectedCustomer: updatedCust,
            selectedCustomerLedger: const [],
            isProcessing: false,
            toastMessage: 'Payment of ${CurrencyFormatter.format(event.amount)} recorded successfully.$remainingMsg',
          )),
          (ledger) => emit(CustomersLoaded(
            allCustomers: allCustomers,
            displayedCustomers: filtered,
            searchQuery: query,
            selectedCustomer: updatedCust,
            selectedCustomerLedger: ledger,
            isProcessing: false,
            toastMessage: 'Payment of ${CurrencyFormatter.format(event.amount)} recorded successfully.$remainingMsg',
          )),
        );
      },
    );
  }

  Future<void> _onChargeDebt(
    ChargeDebtEvent event,
    Emitter<CustomerState> emit,
  ) async {
    if (state is CustomersLoaded) {
      emit((state as CustomersLoaded).copyWith(isProcessing: true));
    }

    final chargeRes = await chargeCustomerDebtUseCase(
      ChargeCustomerDebtParams(
        customerId: event.customerId,
        amount: event.amount,
        relatedOrderId: event.relatedOrderId,
        notes: event.notes,
      ),
    );

    await chargeRes.fold(
      (failure) async {
        if (state is CustomersLoaded) {
          emit((state as CustomersLoaded).copyWith(
            isProcessing: false,
            toastMessage: 'Failed to charge debt: ${failure.message}',
          ));
        }
      },
      (ledgerEntry) async {
        final allRes = await getCustomersUseCase();
        final customerRes = await getCustomerByIdUseCase(event.customerId);
        final ledgerRes = await getCustomerLedgerUseCase(event.customerId);

        List<Customer> allCustomers = [];
        Customer? updatedCust;
        allRes.fold((_) {}, (list) => allCustomers = list);
        customerRes.fold((_) {}, (c) => updatedCust = c);

        final currentLedger = ledgerRes.getOrElse(() => []);
        if (updatedCust != null) {
          final envelope = SyncEnvelope.create(
            type: MessageRoutes.customerUpdated,
            scope: 'crm',
            senderId: 'crm_station',
            senderRole: 'staff',
            payload: {
              'customer': CustomerModel.fromEntity(updatedCust!).toJson(),
              'ledgerEntries': currentLedger.map((e) => CustomerLedgerEntryModel.fromEntity(e).toJson()).toList(),
            },
          );
          lanSyncRepository?.broadcast(envelope);
        }

        final query = state is CustomersLoaded
            ? (state as CustomersLoaded).searchQuery
            : '';
        final filtered = query.isEmpty
            ? allCustomers
            : allCustomers.where((c) {
                final nameMatch = c.name.toLowerCase().contains(query.toLowerCase());
                final phoneMatch = c.phone.toLowerCase().contains(query.toLowerCase());
                return nameMatch || phoneMatch;
              }).toList();

        ledgerRes.fold(
          (_) => emit(CustomersLoaded(
            allCustomers: allCustomers,
            displayedCustomers: filtered,
            searchQuery: query,
            selectedCustomer: updatedCust,
            selectedCustomerLedger: const [],
            isProcessing: false,
            toastMessage: 'Charge of ${CurrencyFormatter.format(event.amount)} added to account debt.',
          )),
          (ledger) => emit(CustomersLoaded(
            allCustomers: allCustomers,
            displayedCustomers: filtered,
            searchQuery: query,
            selectedCustomer: updatedCust,
            selectedCustomerLedger: ledger,
            isProcessing: false,
            toastMessage: 'Charge of ${CurrencyFormatter.format(event.amount)} added to account debt.',
          )),
        );
      },
    );
  }
}
