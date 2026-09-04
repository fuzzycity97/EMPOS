import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_ledger_entry.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_state.dart';
import 'customer_ledger_dialog.dart';

/// Reactive Debt Badge that live-listens to [CustomerBloc] balance updates.
/// Displays 'CLEARED (0.00)' in green when balance == 0,
/// or 'DEBT (EGP X,XXX.XX)' in bold amber/red when balance > 0.001.
class CustomerDebtBadge extends StatelessWidget {
  final Customer customer;
  final bool showPartialStatusText;

  const CustomerDebtBadge({
    super.key,
    required this.customer,
    this.showPartialStatusText = false,
  });

  @override
  Widget build(BuildContext context) {
    CustomerBloc? bloc;
    try {
      bloc = context.read<CustomerBloc>();
    } catch (_) {}

    if (bloc != null) {
      return BlocBuilder<CustomerBloc, CustomerState>(
        bloc: bloc,
        builder: (context, state) {
          final resolved = _resolveCustomer(state, customer);
          return _buildBadge(context, resolved);
        },
      );
    }

    return _buildBadge(context, customer);
  }

  static Customer _resolveCustomer(CustomerState state, Customer fallback) {
    if (state is! CustomersLoaded) return fallback;

    Customer current = fallback;
    if (state.selectedCustomer != null &&
        (state.selectedCustomer!.id == fallback.id || state.selectedCustomer!.phone == fallback.phone)) {
      current = state.selectedCustomer!;
    } else {
      final found = state.allCustomers
          .where((c) => c.id == fallback.id || c.phone == fallback.phone)
          .firstOrNull;
      if (found != null) current = found;
    }

    // If selected customer ledger is available, compute net dynamic balance directly
    if (state.selectedCustomer != null &&
        (state.selectedCustomer!.id == current.id || state.selectedCustomer!.phone == current.phone) &&
        state.selectedCustomerLedger.isNotEmpty) {
      double totalCharges = 0.0;
      double totalPayments = 0.0;
      for (final e in state.selectedCustomerLedger) {
        if (e.type == CustomerLedgerType.debtCharge) {
          totalCharges += e.amount;
        } else if (e.type == CustomerLedgerType.debtPayment) {
          totalPayments += e.amount;
        }
      }
      final net = totalCharges - totalPayments;
      final accurate = net > 0.001 ? net : 0.0;
      return current.copyWith(totalDebt: accurate);
    }

    return current;
  }

  Widget _buildBadge(BuildContext context, Customer cust) {
    final balance = cust.totalDebt;
    final hasDebt = balance > 0.001;

    final Color badgeColor = hasDebt
        ? const Color(0xFFF59E0B) // Bold Amber / Red alert
        : const Color(0xFF10B981); // Green

    final String badgeLabel = hasDebt
        ? 'DEBT (${CurrencyFormatter.format(balance)})'
        : 'CLEARED (0.00)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: badgeColor, width: 1),
      ),
      child: Text(
        badgeLabel,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w900,
          color: badgeColor,
          fontFamily: 'monospace',
        ),
      ),
    );
  }
}

/// Reactive Patient / Customer Banner Widget.
/// Listens to CustomerBloc balance updates and displays live header information
/// with customer details, loyalty points, and color-coded status badge.
class CustomerBanner extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onOpenLedger;
  final bool showActions;

  const CustomerBanner({
    super.key,
    required this.customer,
    this.onOpenLedger,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    CustomerBloc? bloc;
    try {
      bloc = context.read<CustomerBloc>();
    } catch (_) {}

    if (bloc != null) {
      return BlocBuilder<CustomerBloc, CustomerState>(
        bloc: bloc,
        builder: (context, state) {
          final resolved = CustomerDebtBadge._resolveCustomer(state, customer);
          return _buildBannerContent(context, resolved, isDark);
        },
      );
    }

    return _buildBannerContent(context, customer, isDark);
  }

  Widget _buildBannerContent(BuildContext context, Customer currentCustomer, bool isDark) {
    final balance = currentCustomer.totalDebt;
    final hasDebt = balance > 0.001;
    final bannerBorder = hasDebt ? const Color(0xFFF59E0B) : AppColors.borderDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: bannerBorder.withValues(alpha: hasDebt ? 0.4 : 1.0)),
      ),
      child: Row(
        children: [
          // Avatar Initial
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              currentCustomer.name.isNotEmpty ? currentCustomer.name[0].toUpperCase() : 'C',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Name, Phone & Loyalty
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        currentCustomer.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(LucideIcons.star, size: 12, color: AppColors.warning),
                          const SizedBox(width: 3),
                          Text(
                            ' Pts',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Phone: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.textSecondaryDark : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Live Reactive Debt Badge
          CustomerDebtBadge(customer: currentCustomer),

          if (showActions) ...[
            const SizedBox(width: 12),
            IconButton(
              icon: const Icon(LucideIcons.fileSpreadsheet, size: 18),
              tooltip: 'View Account Ledger',
              onPressed: onOpenLedger ?? () => _openLedgerDialog(context, currentCustomer),
            ),
          ],
        ],
      ),
    );
  }

  void _openLedgerDialog(BuildContext context, Customer cust) {
    showDialog(
      context: context,
      builder: (ctx) {
        CustomerBloc? bloc;
        try {
          bloc = context.read<CustomerBloc>();
        } catch (_) {}

        if (bloc != null) {
          return BlocProvider.value(
            value: bloc,
            child: CustomerLedgerDialog(customer: cust),
          );
        }
        return CustomerLedgerDialog(customer: cust);
      },
    );
  }
}

/// Type alias for clinical / patient contexts.
typedef PatientHeaderCard = CustomerBanner;
