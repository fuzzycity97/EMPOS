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
        width: 700,
        height: 600,
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: BlocBuilder<CustomerBloc, CustomerState>(
          builder: (context, state) {
            Customer currentCustomer = customer;
            List<CustomerLedgerEntry> ledger = [];

            if (state is CustomersLoaded) {
              if (state.selectedCustomer != null &&
                  state.selectedCustomer!.id == customer.id) {
                currentCustomer = state.selectedCustomer!;
              } else {
                final found = state.allCustomers
                    .where((c) => c.id == customer.id)
                    .firstOrNull;
                if (found != null) currentCustomer = found;
              }
              ledger = state.selectedCustomerLedger;
            }

            final hasDebt = currentCustomer.totalDebt > 0.001;

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
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusSmall),
                      ),
                      child: const Icon(
                        LucideIcons.fileSpreadsheet,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.space12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${currentCustomer.name} — Account Ledger',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimaryDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Phone: ${currentCustomer.phone} • Points: ${currentCustomer.loyaltyPoints}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(LucideIcons.x, size: 18),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.space16),

                // Balance Banner & Settle Button
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space16),
                  decoration: BoxDecoration(
                    color: hasDebt
                        ? AppColors.danger.withValues(alpha: 0.10)
                        : AppColors.success.withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(
                      color: hasDebt
                          ? AppColors.danger.withValues(alpha: 0.3)
                          : AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasDebt ? LucideIcons.badgeAlert : LucideIcons.circleCheck,
                        color: hasDebt ? AppColors.danger : AppColors.success,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          Text(
                            CurrencyFormatter.format(currentCustomer.totalDebt),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color:
                                  hasDebt ? AppColors.danger : AppColors.success,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      if (hasDebt)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => BlocProvider.value(
                                value: context.read<CustomerBloc>(),
                                child: DebtPaymentDialog(
                                  customer: currentCustomer,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(LucideIcons.handCoins, size: 16),
                          label: const Text(
                            'SETTLE DEBT / PAY',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.space16),

                const Text(
                  'Transaction Audit History',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondaryDark,
                  ),
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
                            ],
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevatedDark,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMedium,
                            ),
                            child: ListView.separated(
                              itemCount: ledger.length,
                              separatorBuilder: (ctx, i) => Divider(
                                height: 1,
                                color: AppColors.borderDark
                                    .withValues(alpha: 0.5),
                              ),
                              itemBuilder: (context, index) {
                                final entry = ledger[index];
                                final isPayment = entry.type ==
                                    CustomerLedgerType.debtPayment;

                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: [
                                      // Date
                                      SizedBox(
                                        width: 120,
                                        child: Text(
                                          DateFormatter.formatDateTime(
                                            entry.timestamp,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textMutedDark,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),

                                      // Type Badge
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isPayment
                                              ? AppColors.success
                                                  .withValues(alpha: 0.15)
                                              : AppColors.danger
                                                  .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusSmall,
                                          ),
                                        ),
                                        child: Text(
                                          isPayment
                                              ? 'DEBT PAYMENT'
                                              : 'CHARGE (+DEBT)',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: isPayment
                                                ? AppColors.success
                                                : AppColors.danger,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),

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
                                      const SizedBox(width: 12),

                                      // Amount
                                      Text(
                                        '${isPayment ? "-" : "+"}${CurrencyFormatter.format(entry.amount)}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                          color: isPayment
                                              ? AppColors.success
                                              : AppColors.danger,
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
