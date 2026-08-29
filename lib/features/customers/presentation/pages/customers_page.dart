import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/customer.dart';
import '../bloc/customer_bloc.dart';
import '../bloc/customer_event.dart';
import '../bloc/customer_state.dart';
import '../widgets/customer_form_dialog.dart';
import '../widgets/customer_ledger_dialog.dart';
import '../widgets/debt_payment_dialog.dart';

class CustomersPage extends StatelessWidget {
  final CustomerBloc? bloc;

  const CustomersPage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    if (bloc != null) {
      return BlocProvider<CustomerBloc>.value(
        value: bloc!,
        child: const _CustomersView(),
      );
    }

    try {
      context.read<CustomerBloc>();
      return const _CustomersView();
    } catch (_) {
      return BlocProvider(
        create: (_) => sl<CustomerBloc>()..add(const LoadCustomersEvent()),
        child: const _CustomersView(),
      );
    }
  }
}

class _CustomersView extends StatelessWidget {
  const _CustomersView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: BlocConsumer<CustomerBloc, CustomerState>(
        listener: (context, state) {
          if (state is CustomersLoaded && state.toastMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.toastMessage!),
                backgroundColor: AppColors.surfaceElevatedDark,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is CustomerError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.circleAlert, color: AppColors.danger, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load customers',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => context.read<CustomerBloc>().add(const LoadCustomersEvent()),
                    icon: const Icon(LucideIcons.refreshCw, size: 16),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is CustomersLoaded) {
            return Padding(
              padding: const EdgeInsets.all(AppDimensions.space16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KPI Metric Cards
                  _buildMetricsRow(context, state),
                  const SizedBox(height: AppDimensions.space16),

                  // Search Bar & Add Customer Button
                  _buildSearchAndActions(context, state),
                  const SizedBox(height: AppDimensions.space16),

                  // Customers Table
                  Expanded(
                    child: state.displayedCustomers.isEmpty
                        ? _buildEmptyState(state)
                        : _buildCustomersTable(context, state),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildMetricsRow(BuildContext context, CustomersLoaded state) {
    return Row(
      children: [
        _metricCard(
          title: 'Total Customers',
          value: '${state.allCustomers.length}',
          icon: LucideIcons.users,
          color: AppColors.primary,
        ),
        const SizedBox(width: AppDimensions.space12),
        _metricCard(
          title: 'Active Debtors',
          value: '${state.totalDebtorCount}',
          icon: LucideIcons.userX,
          color: AppColors.warning,
        ),
        const SizedBox(width: AppDimensions.space12),
        _metricCard(
          title: 'Total Outstanding Debt',
          value: CurrencyFormatter.format(state.totalOutstandingDebt),
          icon: LucideIcons.badgeAlert,
          color: AppColors.danger,
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: AppColors.borderDark),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppDimensions.space12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndActions(BuildContext context, CustomersLoaded state) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.space12),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          // Search Input
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: TextField(
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  prefixIcon: Icon(LucideIcons.search, size: 16, color: AppColors.textMutedDark),
                  hintText: 'Search customer by name or phone number...',
                  hintStyle: TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (val) {
                  context.read<CustomerBloc>().add(SearchCustomersEvent(val));
                },
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.space12),

          // Add Customer Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => BlocProvider.value(
                  value: context.read<CustomerBloc>(),
                  child: CustomerFormDialog(),
                ),
              );
            },
            icon: const Icon(LucideIcons.userPlus, size: 16),
            label: const Text(
              'ADD NEW CUSTOMER',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(CustomersLoaded state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.userRoundX, size: 48, color: AppColors.textMutedDark),
          const SizedBox(height: 12),
          Text(
            state.searchQuery.isNotEmpty
                ? 'No customers found matching "${state.searchQuery}"'
                : 'No customers recorded yet.',
            style: const TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomersTable(BuildContext context, CustomersLoaded state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        child: ListView.separated(
          itemCount: state.displayedCustomers.length,
          separatorBuilder: (ctx, i) => Divider(
            height: 1,
            color: AppColors.borderDark.withValues(alpha: 0.5),
          ),
          itemBuilder: (context, index) {
            final customer = state.displayedCustomers[index];
            final hasDebt = customer.totalDebt > 0.001;

            return InkWell(
              onTap: () => _openCustomerLedger(context, customer),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Avatar Icon
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: Text(
                        customer.name.isNotEmpty ? customer.name[0].toUpperCase() : 'C',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Name & Phone
                    SizedBox(
                      width: 180,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimaryDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customer.phone,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Address / Notes
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customer.address ?? 'No physical address provided',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (customer.notes != null)
                            Text(
                              customer.notes!,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: AppColors.textMutedDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Loyalty Points
                    SizedBox(
                      width: 110,
                      child: Row(
                        children: [
                          const Icon(LucideIcons.star, size: 14, color: AppColors.warning),
                          const SizedBox(width: 4),
                          Text(
                            '${customer.loyaltyPoints} Pts',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Outstanding Debt Badge
                    SizedBox(
                      width: 130,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: hasDebt
                              ? AppColors.danger.withValues(alpha: 0.15)
                              : AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: Text(
                          hasDebt
                              ? CurrencyFormatter.format(customer.totalDebt)
                              : 'CLEARED (0.00)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: hasDebt ? AppColors.danger : AppColors.success,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Quick Actions
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // View Ledger History
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(LucideIcons.fileSpreadsheet, size: 16),
                          tooltip: 'View Account Ledger',
                          onPressed: () => _openCustomerLedger(context, customer),
                        ),

                        // Settle Debt
                        if (hasDebt)
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            icon: const Icon(LucideIcons.handCoins, size: 16, color: AppColors.success),
                            tooltip: 'Settle Debt / Pay Balance',
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (ctx) => BlocProvider.value(
                                  value: context.read<CustomerBloc>(),
                                  child: DebtPaymentDialog(customer: customer),
                                ),
                              );
                            },
                          ),

                        // Edit Profile
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(LucideIcons.pencil, size: 16),
                          tooltip: 'Edit Profile',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => BlocProvider.value(
                                value: context.read<CustomerBloc>(),
                                child: CustomerFormDialog(customer: customer),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openCustomerLedger(BuildContext context, Customer customer) {
    context.read<CustomerBloc>().add(SelectCustomerEvent(customer.id));
    showDialog(
      context: context,
      builder: (ctx) => BlocProvider.value(
        value: context.read<CustomerBloc>(),
        child: CustomerLedgerDialog(customer: customer),
      ),
    );
  }
}
