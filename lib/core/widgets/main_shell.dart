import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../config/domain/entities/store_blueprint.dart';
import '../config/data/models/store_blueprint_model.dart';
import '../config/presentation/bloc/config_bloc.dart';
import '../config/presentation/bloc/config_state.dart';
import '../config/presentation/widgets/advanced_settings_dialog.dart';
import '../network/lan_sync/presentation/bloc/lan_sync_bloc.dart';
import '../network/lan_sync/presentation/bloc/lan_sync_state.dart';
import '../network/lan_sync/presentation/widgets/lan_sync_dialog.dart';
import '../../features/auth/domain/entities/user_role.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/widgets/pin_lock_screen.dart';
import '../../features/auth/presentation/widgets/role_guard_widget.dart';
import '../../features/catalog/presentation/pages/catalog_page.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';
import '../../features/customers/presentation/bloc/customer_event.dart';
import '../../features/customers/presentation/pages/customers_page.dart';
import '../../features/data_io/presentation/bloc/data_io_bloc.dart';
import '../../features/bookings/presentation/bloc/booking_bloc.dart';
import '../../features/bookings/presentation/bloc/booking_event.dart';
import '../../features/bookings/presentation/pages/bookings_calendar_page.dart';
import '../../features/work_orders/presentation/bloc/work_order_bloc.dart';
import '../../features/work_orders/presentation/bloc/work_order_event.dart';
import '../../features/work_orders/presentation/pages/work_orders_pipeline_page.dart';
import '../../features/finance_splits/presentation/bloc/finance_split_bloc.dart';
import '../../features/clinic/presentation/bloc/clinic_bloc.dart';
import '../../features/clinic/presentation/bloc/clinic_event.dart';
import '../../features/clinic/presentation/pages/clinic_reception_page.dart';
import '../../features/clinic/presentation/pages/doctor_station_page.dart';
import '../../features/erp/presentation/bloc/erp_bloc.dart';
import '../../features/erp/presentation/bloc/erp_event.dart';
import '../../features/erp/presentation/pages/boss_portal_page.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
import '../../features/orders/presentation/bloc/orders_event.dart';
import '../../features/orders/presentation/pages/orders_history_page.dart';
import '../../features/pos/presentation/bloc/pos_bloc.dart';
import '../../features/pos/presentation/bloc/pos_event.dart';
import '../../features/pos/presentation/pages/pos_page.dart';
import '../../features/shift/domain/entities/cash_transaction.dart';
import '../../features/shift/presentation/bloc/shift_bloc.dart';
import '../../features/shift/presentation/bloc/shift_event.dart';
import '../../features/shift/presentation/bloc/shift_state.dart';
import '../../features/shift/presentation/widgets/cash_transaction_dialog.dart';
import '../../features/shift/presentation/widgets/close_shift_dialog.dart';
import '../../features/shift/presentation/widgets/open_shift_dialog.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../di/injection_container.dart';
import '../utils/currency_formatter.dart';

class _NavItem {
  final String label;
  final IconData icon;
  final Widget page;
  final VoidCallback? onSelect;
  final List<UserRole> allowedRoles;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.page,
    this.onSelect,
    this.allowedRoles = const [
      UserRole.admin,
      UserRole.manager,
      UserRole.cashier,
      UserRole.doctor,
      UserRole.receptionist,
      UserRole.technician,
    ],
  });
}

class MainShell extends StatelessWidget {
  final ValueNotifier<int> selectedIndexNotifier;

  const MainShell._({super.key, required this.selectedIndexNotifier});

  factory MainShell({Key? key, int initialIndex = 0}) {
    return MainShell._(
      key: key,
      selectedIndexNotifier: ValueNotifier<int>(initialIndex),
    );
  }

  bool _isTabEnabled(StoreBlueprint? blueprint, List<String> toggleKeys, {required bool defaultValue}) {
    if (blueprint == null) return defaultValue;
    for (final key in toggleKeys) {
      if (blueprint.toggles.containsKey(key)) {
        return blueprint.toggles[key] == true;
      }
    }
    return defaultValue;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<PosBloc>()..add(const InitPosSession())),
        BlocProvider(create: (_) => sl<ShiftBloc>()..add(const CheckCurrentShiftEvent())),
        BlocProvider(create: (_) => sl<OrdersBloc>()..add(const LoadOrdersEvent())),
        BlocProvider(create: (_) => sl<CustomerBloc>()..add(const LoadCustomersEvent())),
        BlocProvider(create: (_) => sl<ErpBloc>()..add(const LoadErpDataEvent())),
        BlocProvider(create: (_) => sl<DataIoBloc>()),
        BlocProvider(create: (_) => sl<BookingBloc>()..add(const LoadBookingsEvent())),
        BlocProvider(create: (_) => sl<WorkOrderBloc>()..add(const LoadWorkOrdersEvent())),
        BlocProvider(create: (_) => sl<FinanceSplitBloc>()),
        BlocProvider(create: (_) => sl<ClinicBloc>()..add(const LoadClinicQueueEvent())),
        BlocProvider(create: (_) => sl<LanSyncBloc>()),
        BlocProvider(create: (_) => sl<AuthBloc>()..add(const AppStarted())),
      ],
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is! AuthAuthenticated) {
            return PinLockScreen();
          }
          final currentUser = authState.user;

          return BlocBuilder<ConfigBloc, ConfigState>(
            builder: (context, configState) {
              final blueprint = configState is ConfigLoaded ? configState.blueprint : null;

              // Compute Dynamic Navigation Items strictly based on Blueprint Toggles
              final List<_NavItem> allNavItems = [];

              // 1. Reception Desk
              if (_isTabEnabled(
                blueprint,
                ['sw.clinic_reception', 'sw.clinic_queue'],
                defaultValue: blueprint?.isMedical == true || blueprint?.isDental == true,
              )) {
                allNavItems.add(
                  _NavItem(
                    label: 'Reception Desk',
                    icon: LucideIcons.userCheck,
                    page: ClinicReceptionPage(
                      bloc: context.read<ClinicBloc>(),
                      blueprint: blueprint ?? StoreBlueprintModel.defaultClinicBlueprint(),
                    ),
                    onSelect: () => context.read<ClinicBloc>().add(const LoadClinicQueueEvent()),
                    allowedRoles: const [UserRole.admin, UserRole.receptionist, UserRole.manager],
                  ),
                );
              }

              // 2. Doctor / Specialist
              if (_isTabEnabled(
                blueprint,
                ['sw.clinic_doctor_station', 'sw.dental_tooth_chart_editor'],
                defaultValue: blueprint?.isMedical == true || blueprint?.isDental == true,
              )) {
                allNavItems.add(
                  _NavItem(
                    label: 'Doctor / Specialist',
                    icon: LucideIcons.stethoscope,
                    page: DoctorStationPage(
                      bloc: context.read<ClinicBloc>(),
                      blueprint: blueprint ?? StoreBlueprintModel.defaultClinicBlueprint(),
                    ),
                    onSelect: () => context.read<ClinicBloc>().add(const LoadClinicQueueEvent()),
                    allowedRoles: const [UserRole.admin, UserRole.doctor],
                  ),
                );
              }

              // 3. Pipeline & Orders
              if (_isTabEnabled(
                blueprint,
                [
                  'sw.service_pipeline',
                  'sw.auto_repair_pipeline',
                  'sw.realty_pipeline',
                  'sw.work_orders_pipeline',
                  'sw.auto_repair_vin_lookup',
                  'sw.realty_listing_pipeline_active_pending',
                ],
                defaultValue: blueprint?.isAutomotive == true ||
                    blueprint?.isRealEstate == true ||
                    blueprint?.isHomeTrade == true ||
                    blueprint?.isServices == true,
              )) {
                allNavItems.add(
                  _NavItem(
                    label: 'Pipeline & Orders',
                    icon: LucideIcons.kanban,
                    page: const WorkOrdersPipelinePage(),
                    onSelect: () => context.read<WorkOrderBloc>().add(const LoadWorkOrdersEvent()),
                    allowedRoles: const [UserRole.admin, UserRole.technician, UserRole.manager, UserRole.receptionist],
                  ),
                );
              }

              // 4. Schedule & Bookings
              if (_isTabEnabled(
                blueprint,
                [
                  'sw.bookings_calendar',
                  'sw.hotel_room_booking_calendar',
                  'sw.salon_booking',
                  'sw.salon_chair_appointment_scheduler',
                ],
                defaultValue: blueprint?.isHospitality == true ||
                    blueprint?.isBeautySpa == true ||
                    blueprint?.isFitness == true,
              )) {
                allNavItems.add(
                  _NavItem(
                    label: 'Schedule & Bookings',
                    icon: LucideIcons.calendarDays,
                    page: const BookingsCalendarPage(),
                    onSelect: () => context.read<BookingBloc>().add(const LoadBookingsEvent()),
                    allowedRoles: const [UserRole.admin, UserRole.receptionist, UserRole.manager, UserRole.doctor],
                  ),
                );
              }

              // 5. POS Cashier
              if (_isTabEnabled(
                blueprint,
                ['sw.retail_pos'],
                defaultValue: blueprint == null ||
                    blueprint.isRetail ||
                    blueprint.isFoodBeverage ||
                    blueprint.isSupermarket ||
                    blueprint.isPharmacy,
              )) {
                allNavItems.add(
                  const _NavItem(
                    label: 'POS Cashier',
                    icon: LucideIcons.shoppingCart,
                    page: PosPage(),
                    allowedRoles: [UserRole.admin, UserRole.manager, UserRole.cashier],
                  ),
                );
              }

              // 6. Orders & Returns
              if (_isTabEnabled(
                blueprint,
                ['sw.orders_returns'],
                defaultValue: blueprint == null ||
                    blueprint.isRetail ||
                    blueprint.isFoodBeverage ||
                    blueprint.isSupermarket ||
                    blueprint.isPharmacy,
              )) {
                allNavItems.add(
                  _NavItem(
                    label: 'Orders & Returns',
                    icon: LucideIcons.history,
                    page: const OrdersHistoryPage(),
                    onSelect: () => context.read<OrdersBloc>().add(const LoadOrdersEvent()),
                    allowedRoles: const [UserRole.admin, UserRole.manager, UserRole.cashier],
                  ),
                );
              }

              // 7. Customers / Clients
              if (_isTabEnabled(
                blueprint,
                [
                  'sw.customers_crm',
                  'sw.patient_crm',
                  'sw.gym_membership',
                  'sw.gym_membership_recurring_billing',
                  'sw.clinic_returning_patient_detection',
                  'sw.customer_debt_tracking',
                ],
                defaultValue: true,
              )) {
                allNavItems.add(
                  _NavItem(
                    label: 'Customers / Clients',
                    icon: LucideIcons.users,
                    page: const CustomersPage(),
                    onSelect: () => context.read<CustomerBloc>().add(const LoadCustomersEvent()),
                    allowedRoles: const [UserRole.admin, UserRole.manager, UserRole.cashier, UserRole.receptionist, UserRole.doctor],
                  ),
                );
              }

              // 8. Catalog & Stock
              if (_isTabEnabled(
                blueprint,
                [
                  'sw.inventory_catalog',
                  'sw.clinic_inventory_management',
                  'sw.auto_parts_stock',
                  'sw.auto_stock_restock_on_refund',
                ],
                defaultValue: true,
              )) {
                allNavItems.add(
                  const _NavItem(
                    label: 'Catalog & Stock',
                    icon: LucideIcons.boxes,
                    page: CatalogPage(),
                    allowedRoles: [UserRole.admin, UserRole.manager],
                  ),
                );
              }

              // 9. Boss ERP & Payroll
              if (_isTabEnabled(
                blueprint,
                [
                  'sw.boss_erp',
                  'sw.partner_equity_profit_sharing',
                  'sw.shift_drawer_reconciliation',
                ],
                defaultValue: true,
              )) {
                allNavItems.add(
                  _NavItem(
                    label: 'Boss ERP & Payroll',
                    icon: LucideIcons.briefcase,
                    page: const BossPortalPage(),
                    onSelect: () => context.read<ErpBloc>().add(const LoadErpDataEvent()),
                    allowedRoles: const [UserRole.admin, UserRole.manager],
                  ),
                );
              }

              // Filter nav items by currentUser role
              final navItems = allNavItems
                  .where((item) => item.allowedRoles.contains(currentUser.role))
                  .toList();

              // Fallback if all filtered tabs are empty
              if (navItems.isEmpty) {
                navItems.add(
                  _NavItem(
                    label: 'Authorized Station',
                    icon: LucideIcons.shieldCheck,
                    page: Scaffold(
                      backgroundColor: AppColors.backgroundDark,
                      body: Center(
                        child: Text(
                          'No workspaces currently enabled for ${currentUser.role.displayName}.',
                          style: const TextStyle(color: AppColors.textSecondaryDark),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return ValueListenableBuilder<int>(
                valueListenable: selectedIndexNotifier,
                builder: (context, selectedIndex, _) {
              final screenWidth = MediaQuery.of(context).size.width;
              final showTabLabels = screenWidth >= 1000;
              final showBrandText = screenWidth >= 720;
              final safeIndex = selectedIndex < navItems.length ? selectedIndex : 0;

              return Scaffold(
                backgroundColor: AppColors.backgroundDark,
                appBar: AppBar(
                  backgroundColor: AppColors.surfaceDark,
                  elevation: 0,
                  titleSpacing: AppDimensions.space12,
                  title: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                        ),
                        child: const Icon(
                          LucideIcons.store,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      if (showBrandText) ...[
                        const SizedBox(width: AppDimensions.space8),
                        const Text(
                          'EMPOS™ Enterprise',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                      const SizedBox(width: AppDimensions.space12),

                      // Responsive Navigation Tabs in Header (Dynamic List)
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: navItems.asMap().entries.map((entry) {
                              final index = entry.key;
                              final item = entry.value;

                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: _NavHeaderButton(
                                  label: item.label,
                                  icon: item.icon,
                                  isSelected: safeIndex == index,
                                  showLabel: showTabLabels,
                                  onTap: () {
                                    selectedIndexNotifier.value = index;
                                    item.onSelect?.call();
                                  },
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    // Live Shift & Drawer Status in App Header
                    BlocBuilder<ShiftBloc, ShiftState>(
                      builder: (context, shiftState) {
                        if (shiftState is ActiveShiftReady) {
                          return Row(
                            children: [
                              PopupMenuButton<String>(
                                color: AppColors.surfaceElevatedDark,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                ),
                                icon: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: AppColors.success.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                    border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.success,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Shift #${shiftState.shift.id.substring(0, 6)}',
                                        style: const TextStyle(
                                          color: AppColors.success,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(LucideIcons.chevronDown, size: 12, color: AppColors.success),
                                    ],
                                  ),
                                ),
                                itemBuilder: (ctx) => [
                                  PopupMenuItem(
                                    value: 'drawer_balance',
                                    child: Row(
                                      children: [
                                        const Icon(LucideIcons.wallet, size: 16, color: AppColors.textSecondaryDark),
                                        const SizedBox(width: 8),
                                        Text('Drawer: ${CurrencyFormatter.format(shiftState.shift.expectedCash)}'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'pay_in',
                                    child: const Row(
                                      children: [
                                        Icon(LucideIcons.arrowDownLeft, size: 16, color: AppColors.success),
                                        SizedBox(width: 8),
                                        Text('Cash In (Deposit)'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'pay_out',
                                    child: const Row(
                                      children: [
                                        Icon(LucideIcons.arrowUpRight, size: 16, color: AppColors.warning),
                                        SizedBox(width: 8),
                                        Text('Cash Out (Expense)'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuDivider(),
                                  PopupMenuItem(
                                    value: 'close_shift',
                                    child: const Row(
                                      children: [
                                        Icon(LucideIcons.lock, size: 16, color: AppColors.danger),
                                        SizedBox(width: 8),
                                        Text('Close Shift (Z-Report)', style: TextStyle(color: AppColors.danger)),
                                      ],
                                    ),
                                  ),
                                ],
                                onSelected: (value) {
                                  if (value == 'pay_in') {
                                    showDialog(
                                      context: context,
                                      builder: (_) => CashTransactionDialog(
                                        shiftId: shiftState.shift.id,
                                        initialType: CashTransactionType.payIn,
                                      ),
                                    );
                                  } else if (value == 'pay_out') {
                                    showDialog(
                                      context: context,
                                      builder: (_) => CashTransactionDialog(
                                        shiftId: shiftState.shift.id,
                                        initialType: CashTransactionType.payOut,
                                      ),
                                    );
                                  } else if (value == 'close_shift') {
                                    showDialog(
                                      context: context,
                                      builder: (_) => CloseShiftDialog(shift: shiftState.shift),
                                    );
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          );
                        } else {
                          return Row(
                            children: [
                              TextButton.icon(
                                style: TextButton.styleFrom(
                                  backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                icon: const Icon(LucideIcons.lock, size: 14, color: AppColors.warning),
                                label: const Text(
                                  'Open Shift',
                                  style: TextStyle(
                                    color: AppColors.warning,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => OpenShiftDialog(),
                                  );
                                },
                              ),
                              const SizedBox(width: 8),
                            ],
                          );
                        }
                      },
                    ),

                    // LAN Real-Time Sync Status & Network Hub Controls
                    BlocBuilder<LanSyncBloc, LanSyncState>(
                      builder: (context, lanState) {
                        final isConnected = lanState is LanSyncConnected;
                        final isHost = isConnected && lanState.isHost;

                        return IconButton(
                          icon: Icon(
                            isConnected ? (isHost ? LucideIcons.server : LucideIcons.wifi) : LucideIcons.wifiOff,
                            size: 18,
                            color: isConnected
                                ? (isHost ? AppColors.success : AppColors.info)
                                : AppColors.textSecondaryDark,
                          ),
                          tooltip: isConnected
                              ? (isHost ? 'LAN Hub Host (Active)' : 'LAN Client (${lanState.address})')
                              : 'LAN Real-Time Sync (Offline)',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => BlocProvider.value(
                                value: context.read<LanSyncBloc>(),
                                child: LanSyncDialog(),
                              ),
                            );
                          },
                        );
                      },
                    ),

                    // Current Authenticated User Badge & Station Lock
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevatedDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            currentUser.role == UserRole.admin
                                ? LucideIcons.shieldCheck
                                : currentUser.role == UserRole.doctor
                                    ? LucideIcons.stethoscope
                                    : currentUser.role == UserRole.manager
                                        ? LucideIcons.briefcase
                                        : currentUser.role == UserRole.receptionist
                                            ? LucideIcons.userCheck
                                            : currentUser.role == UserRole.technician
                                                ? LucideIcons.wrench
                                                : LucideIcons.user,
                            size: 14,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${currentUser.name} (${currentUser.role.displayName})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () {
                              context.read<AuthBloc>().add(const LogoutRequested());
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: const Tooltip(
                              message: 'Lock Station / Switch User',
                              child: Padding(
                                padding: EdgeInsets.all(2),
                                child: Icon(
                                  LucideIcons.lock,
                                  size: 14,
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Store Config & Advanced Settings (Admin & Manager only)
                    RoleGuardWidget(
                      allowedRoles: const [UserRole.admin, UserRole.manager],
                      child: IconButton(
                        icon: const Icon(LucideIcons.settings, size: 18),
                        tooltip: 'Advanced Settings & Industry Toggles',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AdvancedSettingsDialog(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
                body: IndexedStack(
                  index: safeIndex,
                  children: navItems.map((e) => e.page).toList(),
                ),
              );
            },
          );
        },
      );
    },
  ),
);
}
}

class _NavHeaderButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool showLabel;
  final VoidCallback onTap;

  const _NavHeaderButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.showLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: showLabel ? AppDimensions.space12 : AppDimensions.space8,
          vertical: AppDimensions.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondaryDark,
            ),
            if (showLabel) ...[
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textSecondaryDark,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
