import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/customer.dart';
import '../../domain/entities/customer_ledger_entry.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_state.dart';
import 'charge_customer_debt_dialog.dart';
import 'debt_payment_dialog.dart';

class CustomerLedgerDialog extends StatelessWidget {
  final Customer customer;

  const CustomerLedgerDialog({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: Container(
        width: 780,
        height: 640,
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            Customer currentCustomer = customer;
            List<CustomerLedgerEntry> ledger = [];

            if (state is CustomersLoaded) {
              if (state.selectedCustomer != null &&
                  (state.selectedCustomer!.id == customer.id || state.selectedCustomer!.phone == customer.phone)) {
                currentCustomer = state.selectedCustomer!;
              } else {
                final found = state.allCustomers
                    .where((c) => c.id == customer.id || c.phone == customer.phone)
                    .firstOrNull;
                if (found != null) currentCustomer = found;
              }
              ledger = state.selectedCustomerLedger;
            }

            // Dynamic net balance computation directly from audit ledger:
            // netOutstanding = sum(charges) - sum(payments)
            double totalCharges = 0.0;
            double totalPayments = 0.0;
            for (final e in ledger) {
              if (e.type == CustomerLedgerType.debtCharge) {
                totalCharges += e.amount;
              } else if (e.type == CustomerLedgerType.debtPayment) {
                totalPayments += e.amount;
              }
            }
            final double net = totalCharges - totalPayments;
            final double netOutstanding = ledger.isNotEmpty
                ? (net > 0.001 ? net : 0.0)
                : (currentCustomer.totalDebt > 0.001 ? currentCustomer.totalDebt : 0.0);

            final hasDebt = netOutstanding > 0.001;
            final hasPayments = ledger.any((e) => e.type == CustomerLedgerType.debtPayment && e.amount > 0.001);

            Color bannerColor = const Color(0xFF10B981); // Green
            String statusBadgeLabel = 'CLEARED';
            if (hasDebt) {
              if (hasPayments) {
                bannerColor = const Color(0xFFF59E0B); // Bold Amber
                statusBadgeLabel = 'PARTIALLY SETTLED';
              } else {
                bannerColor = const Color(0xFFEF4444); // Bold Red
                statusBadgeLabel = 'ACTIVE DEBT';
              }
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: const Icon(
                        LucideIcons.fileSpreadsheet,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '${currentCustomer.name} — Account Ledger',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimaryDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: bannerColor.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: bannerColor.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  statusBadgeLabel,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: bannerColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Phone: ${currentCustomer.phone} • Loyalty Points: ${currentCustomer.loyaltyPoints} Pts',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Balance Banner & Actions
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: bannerColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(
                      color: bannerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasDebt
                            ? (hasPayments ? LucideIcons.circleDashed : LucideIcons.badgeAlert)
                            : LucideIcons.circleCheck,
                        color: bannerColor,
                        size: 26,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Outstanding Debt Balance',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                CurrencyFormatter.format(netOutstanding),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                  color: bannerColor,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Action 1: Add Debit / Charge
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: BorderSide(color: AppColors.danger.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          backgroundColor: AppColors.danger.withValues(alpha: 0.08),
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => BlocProvider.value(
                              value: context.read<CustomerBloc>(),
                              child: ChargeCustomerDebtDialog(customer: currentCustomer),
                            ),
                          );
                        },
                        icon: const Icon(LucideIcons.filePlus2, size: 14),
                        label: const Text(
                          '+ CHARGE DEBT',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Action 2: Settle Debt / Pay
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: hasDebt ? AppColors.success : AppColors.surfaceElevatedDark,
                          foregroundColor: hasDebt ? Colors.white : AppColors.textMutedDark,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                        onPressed: hasDebt
                            ? () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => BlocProvider.value(
                                    value: context.read<CustomerBloc>(),
                                    child: DebtPaymentDialog(
                                      customer: currentCustomer,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        icon: const Icon(LucideIcons.handCoins, size: 15),
                        label: const Text(
                          'COLLECT PAYMENT',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                // Transaction Audit Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Transaction Audit History (${ledger.length} entries)',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (ledger.isNotEmpty)
                      const Text(
                        'Append-Only Audit Log',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textMutedDark,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Ledger Table
                Expanded(
                  child: ledger.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                LucideIcons.receiptText,
                                size: 40,
                                color: AppColors.textMutedDark,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'No ledger entries recorded yet.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondaryDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Use "+ CHARGE DEBT" to add a debit charge or "COLLECT PAYMENT" to settle.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMutedDark,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevatedDark,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            child: ListView.separated(
                              itemCount: ledger.length,
                              separatorBuilder: (ctx, i) => Divider(
                                height: 1,
                                color: AppColors.borderDark.withValues(alpha: 0.5),
                              ),
                              itemBuilder: (context, index) {
                                final entry = ledger[index];
                                final isPayment = entry.type == CustomerLedgerType.debtPayment;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      // Date
                                      SizedBox(
                                        width: 130,
                                        child: Text(
                                          DateFormatter.formatDateTime(entry.timestamp),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMutedDark,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Type Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPayment
                                              ? AppColors.success.withValues(alpha: 0.15)
                                              : AppColors.danger.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusSmall,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              isPayment ? LucideIcons.arrowDownLeft : LucideIcons.arrowUpRight,
                                              size: 11,
                                              color: isPayment ? AppColors.success : AppColors.danger,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              isPayment ? 'DEBT PAYMENT' : 'CHARGE (+DEBT)',
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: isPayment ? AppColors.success : AppColors.danger,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Details / Notes
                                      Expanded(
                                        child: Text(
                                          entry.notes ??
                                              (entry.relatedOrderId != null
                                                  ? 'Order #${entry.relatedOrderId}'
                                                  : 'Account Adjustment'),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textPrimaryDark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 10),

                                      // Amount
                                      Text(
                                        '${isPayment ? "-" : "+"}${CurrencyFormatter.format(entry.amount)}',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w900,
                                          color: isPayment ? AppColors.success : AppColors.danger,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
