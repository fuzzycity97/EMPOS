import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_ledger_entry.dart';

abstract class CustomerState extends Equatable {
  const CustomerState();

  @override
  List<Object?> get props => [];
}

class CustomerInitial extends CustomerState {
  const CustomerInitial();
}

class CustomerLoading extends CustomerState {
  const CustomerLoading();
}

class CustomersLoaded extends CustomerState {
  final List<Customer> allCustomers;
  final List<Customer> displayedCustomers;
  final String searchQuery;
  final Customer? selectedCustomer;
  final List<CustomerLedgerEntry> selectedCustomerLedger;
  final bool isProcessing;
  final String? toastMessage;

  const CustomersLoaded({
    required this.allCustomers,
    required this.displayedCustomers,
    this.searchQuery = '',
    this.selectedCustomer,
    this.selectedCustomerLedger = const [],
    this.isProcessing = false,
    this.toastMessage,
  });

  double get totalOutstandingDebt =>
      allCustomers.fold(0.0, (sum, c) => sum + c.totalDebt);

  int get totalDebtorCount =>
      allCustomers.where((c) => c.totalDebt > 0.001).length;

  CustomersLoaded copyWith({
    List<Customer>? allCustomers,
    List<Customer>? displayedCustomers,
    String? searchQuery,
    Customer? selectedCustomer,
    bool clearSelectedCustomer = false,
    List<CustomerLedgerEntry>? selectedCustomerLedger,
    bool? isProcessing,
    String? toastMessage,
    bool clearToast = false,
  }) {
    return CustomersLoaded(
      allCustomers: allCustomers ?? this.allCustomers,
      displayedCustomers: displayedCustomers ?? this.displayedCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCustomer: clearSelectedCustomer
          ? null
          : (selectedCustomer ?? this.selectedCustomer),
      selectedCustomerLedger:
          selectedCustomerLedger ?? this.selectedCustomerLedger,
      isProcessing: isProcessing ?? this.isProcessing,
      toastMessage: clearToast ? null : (toastMessage ?? this.toastMessage),
    );
  }

  @override
  List<Object?> get props => [
        allCustomers,
        displayedCustomers,
        searchQuery,
        selectedCustomer,
        selectedCustomerLedger,
        isProcessing,
        toastMessage,
      ];
}

class CustomerError extends CustomerState {
  final String message;

  const CustomerError(this.message);

  @override
  List<Object?> get props => [message];
}
