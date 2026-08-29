import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
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

  CustomerBloc({
    required this.getCustomersUseCase,
    required this.getCustomerByIdUseCase,
    required this.saveCustomerUseCase,
    required this.chargeCustomerDebtUseCase,
    required this.processDebtPaymentUseCase,
    required this.getCustomerLedgerUseCase,
  }) : super(const CustomerInitial()) {
    on<LoadCustomersEvent>(_onLoadCustomers);
    on<SearchCustomersEvent>(_onSearchCustomers);
    on<SelectCustomerEvent>(_onSelectCustomer);
    on<SaveCustomerEvent>(_onSaveCustomer);
    on<ProcessDebtPaymentEvent>(_onProcessDebtPayment);
    on<ChargeDebtEvent>(_onChargeDebt);
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
            toastMessage: 'Payment of \$${event.amount.toStringAsFixed(2)} processed successfully.',
          )),
          (ledger) => emit(CustomersLoaded(
            allCustomers: allCustomers,
            displayedCustomers: filtered,
            searchQuery: query,
            selectedCustomer: updatedCust,
            selectedCustomerLedger: ledger,
            isProcessing: false,
            toastMessage: 'Payment of \$${event.amount.toStringAsFixed(2)} processed successfully.',
          )),
        );
      },
    );
  }

  Future<void> _onChargeDebt(
    ChargeDebtEvent event,
    Emitter<CustomerState> emit,
  ) async {
    final chargeRes = await chargeCustomerDebtUseCase(
      ChargeCustomerDebtParams(
        customerId: event.customerId,
        amount: event.amount,
        relatedOrderId: event.relatedOrderId,
        notes: event.notes,
      ),
    );

    chargeRes.fold(
      (_) {},
      (_) async {
        final allRes = await getCustomersUseCase();
        allRes.fold((_) {}, (customers) {
          if (state is CustomersLoaded) {
            final query = (state as CustomersLoaded).searchQuery;
            final filtered = query.isEmpty
                ? customers
                : customers.where((c) {
                    final nameMatch = c.name.toLowerCase().contains(query.toLowerCase());
                    final phoneMatch = c.phone.toLowerCase().contains(query.toLowerCase());
                    return nameMatch || phoneMatch;
                  }).toList();

            emit((state as CustomersLoaded).copyWith(
              allCustomers: customers,
              displayedCustomers: filtered,
            ));
          }
        });
      },
    );
  }
}
