import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/data/datasources/config_local_data_source.dart';
import '../config/data/repositories/config_repository_impl.dart';
import '../config/domain/repositories/config_repository.dart';
import '../config/domain/usecases/get_feature_toggle_usecase.dart';
import '../config/domain/usecases/load_store_blueprint_usecase.dart';
import '../config/domain/usecases/save_store_blueprint_usecase.dart';
import '../config/presentation/bloc/config_bloc.dart';
import '../hardware/data/repositories/hardware_repository_impl.dart';
import '../hardware/domain/repositories/hardware_repository.dart';
import '../hardware/data/repositories/printer_repository_impl.dart';
import '../hardware/domain/repositories/printer_repository.dart';
import '../network/lan_sync/data/repositories/lan_sync_repository_impl.dart';
import '../network/lan_sync/domain/repositories/lan_sync_repository.dart';
import '../network/lan_sync/presentation/bloc/lan_sync_bloc.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/rmm/data/repositories/rmm_repository_impl.dart';
import '../../features/rmm/domain/repositories/rmm_repository.dart';

import '../../features/data_io/data/repositories/data_io_repository_impl.dart';
import '../../features/data_io/domain/repositories/data_io_repository.dart';
import '../../features/data_io/domain/usecases/export_catalog_usecase.dart';
import '../../features/data_io/domain/usecases/generate_template_usecase.dart';
import '../../features/data_io/domain/usecases/import_catalog_usecase.dart';
import '../../features/data_io/presentation/bloc/data_io_bloc.dart';

import '../../features/catalog/data/datasources/catalog_local_data_source.dart';
import '../../features/catalog/data/repositories/catalog_repository_impl.dart';
import '../../features/catalog/domain/repositories/catalog_repository.dart';
import '../../features/catalog/domain/usecases/delete_product_usecase.dart';
import '../../features/catalog/domain/usecases/get_categories_usecase.dart';
import '../../features/catalog/domain/usecases/get_product_by_barcode_usecase.dart';
import '../../features/catalog/domain/usecases/get_products_usecase.dart';
import '../../features/catalog/domain/usecases/save_category_usecase.dart';
import '../../features/catalog/domain/usecases/save_product_usecase.dart';
import '../../features/catalog/domain/usecases/search_products_usecase.dart';
import '../../features/catalog/domain/usecases/toggle_category_status_usecase.dart';
import '../../features/catalog/presentation/bloc/catalog_bloc.dart';
import '../../features/pos/presentation/bloc/pos_bloc.dart';
import '../../features/shift/presentation/bloc/shift_bloc.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';

import '../../features/pos/data/datasources/pos_local_data_source.dart';
import '../../features/pos/data/repositories/pos_repository_impl.dart';
import '../../features/pos/domain/repositories/pos_repository.dart';
import '../../features/pos/domain/usecases/add_item_to_cart_usecase.dart';
import '../../features/pos/domain/usecases/apply_cart_discount_usecase.dart';
import '../../features/pos/domain/usecases/clear_cart_usecase.dart';
import '../../features/pos/domain/usecases/delete_held_tab_usecase.dart';
import '../../features/pos/domain/usecases/get_active_cart_usecase.dart';
import '../../features/pos/domain/usecases/get_held_tabs_usecase.dart';
import '../../features/pos/domain/usecases/hold_tab_usecase.dart';
import '../../features/pos/domain/usecases/process_checkout_usecase.dart';
import '../../features/pos/domain/usecases/remove_item_from_cart_usecase.dart';
import '../../features/pos/domain/usecases/resume_held_tab_usecase.dart';
import '../../features/pos/domain/usecases/update_cart_quantity_usecase.dart';

import '../../features/shift/data/datasources/shift_local_data_source.dart';
import '../../features/shift/data/repositories/shift_repository_impl.dart';
import '../../features/shift/domain/repositories/shift_repository.dart';
import '../../features/shift/domain/usecases/add_cash_transaction_usecase.dart';
import '../../features/shift/domain/usecases/close_shift_usecase.dart';
import '../../features/shift/domain/usecases/generate_z_report_usecase.dart';
import '../../features/shift/domain/usecases/generate_consolidated_z_report_usecase.dart';
import '../../features/shift/domain/usecases/get_cash_transactions_usecase.dart';
import '../../features/shift/domain/usecases/get_current_shift_usecase.dart';
import '../../features/shift/domain/usecases/get_shift_history_usecase.dart';
import '../../features/shift/domain/usecases/open_shift_usecase.dart';

import '../../features/orders/data/datasources/orders_local_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/get_order_by_id_usecase.dart';
import '../../features/orders/domain/usecases/get_orders_history_usecase.dart';
import '../../features/orders/domain/usecases/get_refund_transactions_usecase.dart';
import '../../features/orders/domain/usecases/process_refund_usecase.dart';

import '../../features/customers/data/datasources/customer_local_data_source.dart';
import '../../features/customers/data/repositories/customer_repository_impl.dart';
import '../../features/customers/domain/repositories/customer_repository.dart';
import '../../features/customers/domain/usecases/add_customer_usecase.dart';
import '../../features/customers/domain/usecases/charge_customer_debt_usecase.dart';
import '../../features/customers/domain/usecases/get_customer_by_id_usecase.dart';
import '../../features/customers/domain/usecases/get_customer_ledger_usecase.dart';
import '../../features/customers/domain/usecases/get_customers_usecase.dart';
import '../../features/customers/domain/usecases/process_debt_payment_usecase.dart';
import '../../features/customers/domain/usecases/save_customer_usecase.dart';
import '../../features/customers/presentation/bloc/customer_bloc.dart';

import '../../features/erp/data/datasources/erp_local_data_source.dart';
import '../../features/erp/data/repositories/erp_repository_impl.dart';
import '../../features/erp/domain/repositories/erp_repository.dart';
import '../../features/erp/domain/usecases/add_capital_injection_usecase.dart';
import '../../features/erp/domain/usecases/add_cash_advance_usecase.dart';
import '../../features/erp/domain/usecases/calculate_net_profit_report_usecase.dart';
import '../../features/erp/domain/usecases/calculate_salary_slip_usecase.dart';
import '../../features/erp/domain/usecases/delete_employee_usecase.dart';
import '../../features/erp/domain/usecases/delete_partner_usecase.dart';
import '../../features/erp/domain/usecases/get_cash_advances_usecase.dart';
import '../../features/erp/domain/usecases/get_dividend_payouts_usecase.dart';
import '../../features/erp/domain/usecases/get_employees_usecase.dart';
import '../../features/erp/domain/usecases/get_expenses_usecase.dart';
import '../../features/erp/domain/usecases/get_partners_usecase.dart';
import '../../features/erp/domain/usecases/record_dividend_payout_usecase.dart';
import '../../features/erp/domain/usecases/record_expense_usecase.dart';
import '../../features/erp/domain/usecases/save_employee_usecase.dart';
import '../../features/erp/domain/usecases/save_partner_usecase.dart';
import '../../features/erp/presentation/bloc/erp_bloc.dart';

import '../../features/clinic/data/datasources/clinic_local_data_source.dart';
import '../../features/clinic/data/repositories/clinic_repository_impl.dart';
import '../../features/clinic/data/repositories/dental_repository_impl.dart';
import '../../features/clinic/domain/repositories/clinic_repository.dart';
import '../../features/clinic/domain/repositories/dental_repository.dart';
import '../../features/clinic/domain/usecases/check_in_patient_usecase.dart';
import '../../features/clinic/domain/usecases/complete_visit_usecase.dart';
import '../../features/clinic/domain/usecases/get_clinic_queue_usecase.dart';
import '../../features/clinic/domain/usecases/get_patient_tooth_chart_usecase.dart';
import '../../features/clinic/domain/usecases/get_patients_usecase.dart';
import '../../features/clinic/domain/usecases/get_rolling_mean_wait_usecase.dart';
import '../../features/clinic/domain/usecases/get_treatment_plans_usecase.dart';
import '../../features/clinic/domain/usecases/save_patient_usecase.dart';
import '../../features/clinic/domain/usecases/save_tooth_chart_usecase.dart';
import '../../features/clinic/domain/usecases/save_treatment_plan_usecase.dart';
import '../../features/clinic/domain/usecases/save_visit_usecase.dart';
import '../../features/clinic/domain/usecases/search_patients_usecase.dart';
import '../../features/clinic/domain/usecases/update_visit_status_usecase.dart';

import '../../features/bookings/data/datasources/booking_local_data_source.dart';
import '../../features/bookings/data/repositories/booking_repository_impl.dart';
import '../../features/bookings/domain/repositories/booking_repository.dart';
import '../../features/bookings/domain/usecases/cancel_booking_usecase.dart';
import '../../features/bookings/domain/usecases/check_availability_usecase.dart';
import '../../features/bookings/domain/usecases/get_bookings_usecase.dart';
import '../../features/bookings/domain/usecases/save_booking_usecase.dart';

import '../../features/work_orders/data/datasources/work_order_local_data_source.dart';
import '../../features/work_orders/data/repositories/work_order_repository_impl.dart';
import '../../features/work_orders/domain/repositories/work_order_repository.dart';
import '../../features/work_orders/domain/usecases/get_work_orders_usecase.dart';
import '../../features/work_orders/domain/usecases/save_work_order_usecase.dart';
import '../../features/work_orders/domain/usecases/transition_stage_usecase.dart';

import '../../features/finance_splits/data/datasources/finance_split_local_data_source.dart';
import '../../features/finance_splits/data/repositories/finance_split_repository_impl.dart';
import '../../features/finance_splits/domain/repositories/finance_split_repository.dart';
import '../../features/finance_splits/domain/usecases/calculate_distribution_usecase.dart';
import '../../features/finance_splits/domain/usecases/get_settlement_logs_usecase.dart';
import '../../features/finance_splits/domain/usecases/record_settlement_usecase.dart';

import '../../features/bookings/presentation/bloc/booking_bloc.dart';
import '../../features/work_orders/presentation/bloc/work_order_bloc.dart';
import '../../features/finance_splits/presentation/bloc/finance_split_bloc.dart';
import '../../features/clinic/presentation/bloc/clinic_bloc.dart';

final sl = GetIt.instance;

Future<void> initServiceLocator() async {
  // ---------------------------------------------------------------------------
  // External & Third Party Services
  // ---------------------------------------------------------------------------
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    return dio;
  });

  // ---------------------------------------------------------------------------
  // Feature: Catalog & Inventory
  // ---------------------------------------------------------------------------
  // Data Sources
  sl.registerLazySingleton<CatalogLocalDataSource>(
    () => CatalogLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<CatalogRepository>(
    () => CatalogRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => SaveProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => SaveCategoryUseCase(sl()));
  sl.registerLazySingleton(() => ToggleCategoryStatusUseCase(sl()));

  // Presentation Bloc (Factory for fresh instances per page lifecycle)
  sl.registerFactory(
    () => CatalogBloc(
      getProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
      searchProductsUseCase: sl(),
      saveProductUseCase: sl(),
      deleteProductUseCase: sl(),
      saveCategoryUseCase: sl(),
      toggleCategoryStatusUseCase: sl(),
      catalogRepository: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Feature: POS Cashier
  // ---------------------------------------------------------------------------
  // Data Sources
  sl.registerLazySingleton<PosLocalDataSource>(
    () => PosLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<PosRepository>(
    () => PosRepositoryImpl(
      localDataSource: sl(),
      catalogLocalDataSource: sl(),
      customerRepository: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetActiveCartUseCase(sl()));
  sl.registerLazySingleton(() => AddItemToCartUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCartQuantityUseCase(sl()));
  sl.registerLazySingleton(() => RemoveItemFromCartUseCase(sl()));
  sl.registerLazySingleton(() => ApplyCartDiscountUseCase(sl()));
  sl.registerLazySingleton(() => ClearCartUseCase(sl()));
  sl.registerLazySingleton(() => HoldTabUseCase(sl()));
  sl.registerLazySingleton(() => GetHeldTabsUseCase(sl()));
  sl.registerLazySingleton(() => ResumeHeldTabUseCase(sl()));
  sl.registerLazySingleton(() => DeleteHeldTabUseCase(sl()));
  sl.registerLazySingleton(() => ProcessCheckoutUseCase(sl()));

  // Core Hardware Peripherals (Barcode Scanner & Thermal Printer)
  sl.registerLazySingleton<HardwareRepository>(
    () => HardwareRepositoryImpl(),
  );

  // Presentation Bloc (Factory for fresh instances per cashier session)
  sl.registerFactory(
    () => PosBloc(
      getActiveCartUseCase: sl(),
      addItemToCartUseCase: sl(),
      updateCartQuantityUseCase: sl(),
      removeItemFromCartUseCase: sl(),
      applyCartDiscountUseCase: sl(),
      clearCartUseCase: sl(),
      holdTabUseCase: sl(),
      getHeldTabsUseCase: sl(),
      resumeHeldTabUseCase: sl(),
      deleteHeldTabUseCase: sl(),
      processCheckoutUseCase: sl(),
      getProductsUseCase: sl(),
      getCategoriesUseCase: sl(),
      getProductByBarcodeUseCase: sl(),
      hardwareRepository: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Feature: Shift & Cash Drawer Module
  // ---------------------------------------------------------------------------
  // Data Sources
  sl.registerLazySingleton<ShiftLocalDataSource>(
    () => ShiftLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<ShiftRepository>(
    () => ShiftRepositoryImpl(
      localDataSource: sl(),
      posLocalDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCurrentShiftUseCase(sl()));
  sl.registerLazySingleton(() => OpenShiftUseCase(sl()));
  sl.registerLazySingleton(() => CloseShiftUseCase(sl()));
  sl.registerLazySingleton(() => AddCashTransactionUseCase(sl()));
  sl.registerLazySingleton(() => GetCashTransactionsUseCase(sl()));
  sl.registerLazySingleton(() => GenerateZReportUseCase(sl()));
  sl.registerLazySingleton(() => GenerateConsolidatedZReportUseCase(sl()));
  sl.registerLazySingleton(() => GetShiftHistoryUseCase(sl()));

  // Presentation Bloc (Factory for fresh shift management lifecycle)
  sl.registerFactory(
    () => ShiftBloc(
      getCurrentShiftUseCase: sl(),
      openShiftUseCase: sl(),
      closeShiftUseCase: sl(),
      addCashTransactionUseCase: sl(),
      getCashTransactionsUseCase: sl(),
      generateZReportUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Feature: Orders History & Refunds Module
  // ---------------------------------------------------------------------------
  // Data Sources
  sl.registerLazySingleton<OrdersLocalDataSource>(
    () => OrdersLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<OrdersRepository>(
    () => OrdersRepositoryImpl(
      localDataSource: sl(),
      catalogLocalDataSource: sl(),
      shiftLocalDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetOrdersHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => ProcessRefundUseCase(sl()));
  sl.registerLazySingleton(() => GetRefundTransactionsUseCase(sl()));

  // Presentation Bloc
  sl.registerFactory(
    () => OrdersBloc(
      getOrdersHistoryUseCase: sl(),
      getOrderByIdUseCase: sl(),
      processRefundUseCase: sl(),
      getRefundTransactionsUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Feature: Customers & Debts Module
  // ---------------------------------------------------------------------------
  // Data Sources
  sl.registerLazySingleton<CustomerLocalDataSource>(
    () => CustomerLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(
      localDataSource: sl(),
      shiftLocalDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetCustomersUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerByIdUseCase(sl()));
  sl.registerLazySingleton(() => SaveCustomerUseCase(sl()));
  sl.registerLazySingleton(() => AddCustomerUseCase(sl()));
  sl.registerLazySingleton(() => ChargeCustomerDebtUseCase(sl()));
  sl.registerLazySingleton(() => ProcessDebtPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetCustomerLedgerUseCase(sl()));

  // Presentation Bloc
  sl.registerFactory(
    () => CustomerBloc(
      getCustomersUseCase: sl(),
      getCustomerByIdUseCase: sl(),
      saveCustomerUseCase: sl(),
      chargeCustomerDebtUseCase: sl(),
      processDebtPaymentUseCase: sl(),
      getCustomerLedgerUseCase: sl(),
      lanSyncRepository: sl.isRegistered<LanSyncRepository>() ? sl<LanSyncRepository>() : null,
    ),
  );

  // ---------------------------------------------------------------------------
  // Feature: Store Operational Expenses & Staff Payroll Module (ERP)
  // ---------------------------------------------------------------------------
  // Data Sources
  sl.registerLazySingleton<ErpLocalDataSource>(
    () => ErpLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<ErpRepository>(
    () => ErpRepositoryImpl(
      localDataSource: sl(),
      shiftLocalDataSource: sl(),
      ordersLocalDataSource: sl(),
    ),
  );

  // Use Cases
  sl.registerLazySingleton(() => GetEmployeesUseCase(sl()));
  sl.registerLazySingleton(() => SaveEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => DeleteEmployeeUseCase(sl()));
  sl.registerLazySingleton(() => AddCashAdvanceUseCase(sl()));
  sl.registerLazySingleton(() => GetCashAdvancesUseCase(sl()));
  sl.registerLazySingleton(() => RecordExpenseUseCase(sl()));
  sl.registerLazySingleton(() => GetExpensesUseCase(sl()));
  sl.registerLazySingleton(() => CalculateSalarySlipUseCase(sl()));

  // Business Partners & Net Profit Use Cases
  sl.registerLazySingleton(() => GetPartnersUseCase(sl()));
  sl.registerLazySingleton(() => SavePartnerUseCase(sl()));
  sl.registerLazySingleton(() => DeletePartnerUseCase(sl()));
  sl.registerLazySingleton(() => AddCapitalInjectionUseCase(sl()));
  sl.registerLazySingleton(() => RecordDividendPayoutUseCase(sl()));
  sl.registerLazySingleton(() => GetDividendPayoutsUseCase(sl()));
  sl.registerLazySingleton(() => CalculateNetProfitReportUseCase(sl()));

  // Presentation Bloc
  sl.registerFactory(
    () => ErpBloc(
      getEmployeesUseCase: sl(),
      saveEmployeeUseCase: sl(),
      deleteEmployeeUseCase: sl(),
      addCashAdvanceUseCase: sl(),
      getCashAdvancesUseCase: sl(),
      recordExpenseUseCase: sl(),
      getExpensesUseCase: sl(),
      calculateSalarySlipUseCase: sl(),
      getPartnersUseCase: sl(),
      savePartnerUseCase: sl(),
      deletePartnerUseCase: sl(),
      addCapitalInjectionUseCase: sl(),
      recordDividendPayoutUseCase: sl(),
      getDividendPayoutsUseCase: sl(),
      calculateNetProfitReportUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Core Feature: Dynamic Store Blueprint & Feature Toggle Engine
  // ---------------------------------------------------------------------------
  // Data Source
  sl.registerLazySingleton<ConfigLocalDataSource>(
    () => ConfigLocalDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<ConfigRepository>(
    () => ConfigRepositoryImpl(localDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoadStoreBlueprintUseCase(sl()));
  sl.registerLazySingleton(() => SaveStoreBlueprintUseCase(sl()));
  sl.registerLazySingleton(() => GetFeatureToggleUseCase(sl()));

  // Presentation Bloc
  sl.registerFactory(
    () => ConfigBloc(
      loadStoreBlueprintUseCase: sl(),
      saveStoreBlueprintUseCase: sl(),
      getFeatureToggleUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Feature: CSV Smart Data I/O & Catalog Batch Import/Export
  // ---------------------------------------------------------------------------
  // Repository
  sl.registerLazySingleton<DataIoRepository>(
    () => DataIoRepositoryImpl(catalogLocalDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => GenerateTemplateUseCase(sl()));
  sl.registerLazySingleton(() => ExportCatalogUseCase(sl()));
  sl.registerLazySingleton(() => ImportCatalogUseCase(sl()));

  // Presentation Bloc
  sl.registerFactory(
    () => DataIoBloc(
      generateTemplateUseCase: sl(),
      exportCatalogUseCase: sl(),
      importCatalogUseCase: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Feature: Medical & Dental Practice (Clinic System)
  // ---------------------------------------------------------------------------
  // Data Source
  sl.registerLazySingleton<ClinicLocalDataSource>(
    () => ClinicLocalDataSourceImpl(),
  );

  // Repositories
  sl.registerLazySingleton<ClinicRepository>(
    () => ClinicRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<DentalRepository>(
    () => DentalRepositoryImpl(localDataSource: sl()),
  );

  // Clinic Use Cases
  sl.registerLazySingleton(() => GetPatientsUseCase(sl()));
  sl.registerLazySingleton(() => SavePatientUseCase(sl()));
  sl.registerLazySingleton(() => SaveVisitUseCase(sl()));
  sl.registerLazySingleton(() => SearchPatientsUseCase(sl()));
  sl.registerLazySingleton(() => GetClinicQueueUseCase(sl()));
  sl.registerLazySingleton(() => CheckInPatientUseCase(sl()));
  sl.registerLazySingleton(() => UpdateVisitStatusUseCase(sl()));
  sl.registerLazySingleton(() => CompleteVisitUseCase(sl(), sl<CatalogRepository>()));
  sl.registerLazySingleton(() => GetRollingMeanWaitUseCase(sl()));

  // Dental Use Cases
  sl.registerLazySingleton(() => GetPatientToothChartUseCase(sl()));
  sl.registerLazySingleton(() => SaveToothChartUseCase(sl()));
  sl.registerLazySingleton(() => GetTreatmentPlansUseCase(sl()));
  sl.registerLazySingleton(() => SaveTreatmentPlanUseCase(sl()));

  // ---------------------------------------------------------------------------
  // Feature: Universal Booking & Calendar Engine
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<BookingLocalDataSource>(
    () => BookingLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<BookingRepository>(
    () => BookingRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetBookingsUseCase(sl()));
  sl.registerLazySingleton(() => SaveBookingUseCase(sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(sl()));
  sl.registerLazySingleton(() => CheckAvailabilityUseCase(sl()));

  // ---------------------------------------------------------------------------
  // Feature: Universal Work Order & Service Pipeline Engine
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<WorkOrderLocalDataSource>(
    () => WorkOrderLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<WorkOrderRepository>(
    () => WorkOrderRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => GetWorkOrdersUseCase(sl()));
  sl.registerLazySingleton(() => SaveWorkOrderUseCase(sl()));
  sl.registerLazySingleton(() => TransitionStageUseCase(sl()));

  // ---------------------------------------------------------------------------
  // Feature: Universal Multi-Party Split & Commission Engine
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<FinanceSplitLocalDataSource>(
    () => FinanceSplitLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<FinanceSplitRepository>(
    () => FinanceSplitRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton(() => CalculateDistributionUseCase(sl()));
  sl.registerLazySingleton(() => RecordSettlementUseCase(sl()));
  sl.registerLazySingleton(() => GetSettlementLogsUseCase(sl()));

  // ---------------------------------------------------------------------------
  // Presentation BLoCs
  // ---------------------------------------------------------------------------
  sl.registerFactory(
    () => BookingBloc(
      getBookingsUseCase: sl(),
      saveBookingUseCase: sl(),
      cancelBookingUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => WorkOrderBloc(
      getWorkOrdersUseCase: sl(),
      saveWorkOrderUseCase: sl(),
      transitionStageUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FinanceSplitBloc(
      calculateDistributionUseCase: sl(),
      recordSettlementUseCase: sl(),
      getSettlementLogsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ClinicBloc(
      getClinicQueueUseCase: sl(),
      checkInPatientUseCase: sl(),
      updateVisitStatusUseCase: sl(),
      completeVisitUseCase: sl(),
      getPatientToothChartUseCase: sl(),
      saveToothChartUseCase: sl(),
      getPatientsUseCase: sl(),
      searchPatientsUseCase: sl(),
      getRollingMeanWaitUseCase: sl(),
      savePatientUseCase: sl(),
      saveVisitUseCase: sl(),
      clinicRepository: sl(),
      customerRepository: sl(),
      lanSyncRepository: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Core Network: LAN Sync WebSocket Hub & BLoC
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<LanSyncRepository>(
    () => LanSyncRepositoryImpl(),
  );

  sl.registerFactory(
    () => LanSyncBloc(
      lanSyncRepository: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Feature: Authentication & RBAC
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  sl.registerFactory(
    () => AuthBloc(authRepository: sl()),
  );

  // ---------------------------------------------------------------------------
  // Core Hardware: ESC/POS & Cash Drawer Driver
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(),
  );

  // ---------------------------------------------------------------------------
  // Feature: Developer RMM Fleet Management Console
  // ---------------------------------------------------------------------------
  sl.registerLazySingleton<RmmRepository>(
    () => RmmRepositoryImpl(lanSyncRepository: sl()),
  );
}



