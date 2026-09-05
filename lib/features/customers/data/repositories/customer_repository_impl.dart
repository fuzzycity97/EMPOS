import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../pos/domain/entities/payment_detail.dart';
import '../../../shift/data/datasources/shift_local_data_source.dart';
import '../../../shift/data/models/cash_transaction_model.dart';
import '../../../shift/domain/entities/cash_transaction.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_ledger_entry.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_local_data_source.dart';
import '../models/customer_ledger_entry_model.dart';
import '../models/customer_model.dart';

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerLocalDataSource localDataSource;
  final ShiftLocalDataSource shiftLocalDataSource;

  CustomerRepositoryImpl({
    required this.localDataSource,
    required this.shiftLocalDataSource,
  });

  @override
  Future<Either<Failure, List<Customer>>> getCustomers({
    String? searchQuery,
  }) async {
    try {
      final customers = await localDataSource.getCustomers();

      final customerActivityPairs = await Future.wait(customers.map((c) async {
        DateTime lastActivity = c.createdAt;
        try {
          final ledger = await localDataSource.getLedgerEntries(c.id);
          if (ledger.isNotEmpty) {
            double totalCharges = 0.0;
            double totalPayments = 0.0;
            for (final e in ledger) {
              if (e.type == CustomerLedgerType.debtCharge) {
                totalCharges += e.amount;
              } else if (e.type == CustomerLedgerType.debtPayment) {
                totalPayments += e.amount;
              }
              if (e.timestamp.isAfter(lastActivity)) {
                lastActivity = e.timestamp;
              }
            }
            final net = totalCharges - totalPayments;
            final accurateDebt = net > 0.001 ? net : 0.0;
            if ((c.totalDebt - accurateDebt).abs() > 0.001) {
              final updated = c.copyWith(totalDebt: accurateDebt);
              await localDataSource.saveCustomer(CustomerModel.fromEntity(updated));
              return (customer: updated, lastActivity: lastActivity);
            }
          }
        } catch (_) {}
        return (customer: c, lastActivity: lastActivity);
      }));

      // Sort reverse-chronologically by newest activity/creation date (newest first)
      customerActivityPairs.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      final reconciledCustomers = customerActivityPairs.map((pair) => pair.customer).toList();

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final query = searchQuery.trim().toLowerCase();
        final filtered = reconciledCustomers.where((c) {
          final matchName = c.name.toLowerCase().contains(query);
          final matchPhone = c.phone.toLowerCase().contains(query);
          return matchName || matchPhone;
        }).toList();
        return Right(filtered);
      }
      return Right(reconciledCustomers);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve customers: $e'));
    }
  }

  @override
  Future<Either<Failure, Customer>> getCustomerById(String customerId) async {
    try {
      final customer = await localDataSource.getCustomerById(customerId);
      if (customer == null) {
        return const Left(CacheFailure(message: 'Customer not found.'));
      }
      try {
        final ledger = await localDataSource.getLedgerEntries(customer.id);
        if (ledger.isNotEmpty) {
          double totalCharges = 0.0;
          double totalPayments = 0.0;
          for (final e in ledger) {
            if (e.type == CustomerLedgerType.debtCharge) {
              totalCharges += e.amount;
            } else if (e.type == CustomerLedgerType.debtPayment) {
              totalPayments += e.amount;
            }
          }
          final net = totalCharges - totalPayments;
          final accurateDebt = net > 0.001 ? net : 0.0;
          if ((customer.totalDebt - accurateDebt).abs() > 0.001) {
            final updated = customer.copyWith(totalDebt: accurateDebt);
            await localDataSource.saveCustomer(CustomerModel.fromEntity(updated));
            return Right(updated);
          }
        }
      } catch (_) {}
      return Right(customer);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve customer $customerId: $e'));
    }
  }

  @override
  Future<Either<Failure, Customer>> saveCustomer(Customer customer) async {
    try {
      final model = CustomerModel.fromEntity(customer);
      await localDataSource.saveCustomer(model);

      // If customer has a positive total debt and zero ledger entries, auto-create an opening ledger record
      if (customer.totalDebt > 0.001) {
        final existingEntries = await localDataSource.getLedgerEntries(customer.id);
        if (existingEntries.isEmpty) {
          final openingCharge = CustomerLedgerEntryModel(
            id: 'LEDGER-OPEN-${DateTime.now().millisecondsSinceEpoch}',
            customerId: customer.id,
            type: CustomerLedgerType.debtCharge,
            amount: customer.totalDebt,
            notes: 'Opening / Initial Debt Balance',
            timestamp: customer.createdAt,
          );
          await localDataSource.saveLedgerEntry(openingCharge);
        }
      }

      return Right(model);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save customer: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCustomer(String customerId) async {
    try {
      await localDataSource.deleteCustomer(customerId);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to delete customer: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CustomerLedgerEntry>>> getCustomerLedger(
    String customerId,
  ) async {
    try {
      final entries = await localDataSource.getLedgerEntries(customerId);
      return Right(entries);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to retrieve customer ledger: $e'));
    }
  }

  @override
  Future<Either<Failure, CustomerLedgerEntry>> chargeCustomerDebt({
    required String customerId,
    required double amount,
    String? relatedOrderId,
    String? notes,
  }) async {
    try {
      final customer = await localDataSource.getCustomerById(customerId);
      if (customer == null) {
        return const Left(CacheFailure(message: 'Customer not found.'));
      }

      if (amount <= 0) {
        return const Left(CacheFailure(message: 'Debt charge amount must be greater than zero.'));
      }

      // 1. Record ledger charge entry
      final entry = CustomerLedgerEntryModel(
        id: 'LEDGER-CHG-${DateTime.now().millisecondsSinceEpoch}',
        customerId: customer.id,
        type: CustomerLedgerType.debtCharge,
        amount: amount,
        relatedOrderId: relatedOrderId,
        notes: notes ?? (relatedOrderId != null ? 'Store Credit Charge (Order #$relatedOrderId)' : 'Account Debit Charge'),
        timestamp: DateTime.now(),
      );
      await localDataSource.saveLedgerEntry(entry);

      // 2. Compute updated total debt
      final calculatedDebt = customer.totalDebt + amount;

      // 3. Persist updated customer totalDebt
      final updatedCustomer = customer.copyWith(totalDebt: calculatedDebt);
      await localDataSource.saveCustomer(CustomerModel.fromEntity(updatedCustomer));

      return Right(entry);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to charge customer debt: $e'));
    }
  }

  @override
  Future<Either<Failure, CustomerLedgerEntry>> processDebtPayment({
    required String customerId,
    required double amount,
    required TenderType paymentTender,
    String? notes,
  }) async {
    try {
      final customer = await localDataSource.getCustomerById(customerId);
      if (customer == null) {
        return const Left(CacheFailure(message: 'Customer not found.'));
      }

      if (amount <= 0) {
        return const Left(CacheFailure(message: 'Payment amount must be greater than zero.'));
      }

      // 1. Record ledger payment entry
      final entry = CustomerLedgerEntryModel(
        id: 'LEDGER-PAY-${DateTime.now().millisecondsSinceEpoch}',
        customerId: customer.id,
        type: CustomerLedgerType.debtPayment,
        amount: amount,
        notes: notes ?? 'Debt Payment (${paymentTender.name.toUpperCase()})',
        timestamp: DateTime.now(),
      );
      await localDataSource.saveLedgerEntry(entry);

      // 2. Compute updated total debt
      final newDebt = (customer.totalDebt - amount).clamp(0.0, double.infinity);

      // 3. Persist updated customer totalDebt
      final updatedCustomer = customer.copyWith(totalDebt: newDebt);
      await localDataSource.saveCustomer(CustomerModel.fromEntity(updatedCustomer));

      // 3. Record Pay-In to active Shift Drawer if payment tender is Cash
      if (paymentTender == TenderType.cash) {
        try {
          final activeShift = await shiftLocalDataSource.getActiveShift();
          if (activeShift != null && activeShift.isOpen) {
            final cashTx = CashTransactionModel(
              id: 'CTX-DEBT-${DateTime.now().millisecondsSinceEpoch}',
              shiftId: activeShift.id,
              type: CashTransactionType.payIn,
              amount: amount,
              reason: 'Debt Settlement from ${customer.name}: ${notes ?? "Cash"}',
              timestamp: DateTime.now(),
            );
            await shiftLocalDataSource.saveCashTransaction(cashTx);
          }
        } catch (_) {}
      }

      return Right(entry);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to process debt payment: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLedgerEntry(CustomerLedgerEntry entry) async {
    try {
      await localDataSource.saveLedgerEntry(CustomerLedgerEntryModel.fromEntity(entry));
      final cust = await localDataSource.getCustomerById(entry.customerId);
      if (cust != null) {
        final ledger = await localDataSource.getLedgerEntries(cust.id);
        double totalCharges = 0.0;
        double totalPayments = 0.0;
        for (final e in ledger) {
          if (e.type == CustomerLedgerType.debtCharge) {
            totalCharges += e.amount;
          } else if (e.type == CustomerLedgerType.debtPayment) {
            totalPayments += e.amount;
          }
        }
        final net = totalCharges - totalPayments;
        final accurateDebt = net > 0.001 ? net : 0.0;
        if ((cust.totalDebt - accurateDebt).abs() > 0.001) {
          final updated = cust.copyWith(totalDebt: accurateDebt);
          await localDataSource.saveCustomer(CustomerModel.fromEntity(updated));
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save ledger entry: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveLedgerEntries(List<CustomerLedgerEntry> entries) async {
    try {
      final customerIds = <String>{};
      for (final entry in entries) {
        await localDataSource.saveLedgerEntry(CustomerLedgerEntryModel.fromEntity(entry));
        customerIds.add(entry.customerId);
      }
      for (final custId in customerIds) {
        final cust = await localDataSource.getCustomerById(custId);
        if (cust != null) {
          final ledger = await localDataSource.getLedgerEntries(cust.id);
          double totalCharges = 0.0;
          double totalPayments = 0.0;
          for (final e in ledger) {
            if (e.type == CustomerLedgerType.debtCharge) {
              totalCharges += e.amount;
            } else if (e.type == CustomerLedgerType.debtPayment) {
              totalPayments += e.amount;
            }
          }
          final net = totalCharges - totalPayments;
          final accurateDebt = net > 0.001 ? net : 0.0;
          if ((cust.totalDebt - accurateDebt).abs() > 0.001) {
            final updated = cust.copyWith(totalDebt: accurateDebt);
            await localDataSource.saveCustomer(CustomerModel.fromEntity(updated));
          }
        }
      }
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(message: 'Failed to save ledger entries: $e'));
    }
  }
}

