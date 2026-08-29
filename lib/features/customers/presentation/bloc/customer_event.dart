import 'package:equatable/equatable.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../../domain/entities/customer.dart';

abstract class CustomerEvent extends Equatable {
  const CustomerEvent();

  @override
  List<Object?> get props => [];
}

class LoadCustomersEvent extends CustomerEvent {
  const LoadCustomersEvent();
}

class SearchCustomersEvent extends CustomerEvent {
  final String query;

  const SearchCustomersEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectCustomerEvent extends CustomerEvent {
  final String? customerId;

  const SelectCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class SaveCustomerEvent extends CustomerEvent {
  final Customer customer;

  const SaveCustomerEvent(this.customer);

  @override
  List<Object?> get props => [customer];
}

class DeleteCustomerEvent extends CustomerEvent {
  final String customerId;

  const DeleteCustomerEvent(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class ProcessDebtPaymentEvent extends CustomerEvent {
  final String customerId;
  final double amount;
  final TenderType paymentTender;
  final String? notes;

  const ProcessDebtPaymentEvent({
    required this.customerId,
    required this.amount,
    required this.paymentTender,
    this.notes,
  });

  @override
  List<Object?> get props => [
        customerId,
        amount,
        paymentTender,
        notes,
      ];
}

class ChargeDebtEvent extends CustomerEvent {
  final String customerId;
  final double amount;
  final String? relatedOrderId;
  final String? notes;

  const ChargeDebtEvent({
    required this.customerId,
    required this.amount,
    this.relatedOrderId,
    this.notes,
  });

  @override
  List<Object?> get props => [
        customerId,
        amount,
        relatedOrderId,
        notes,
      ];
}
