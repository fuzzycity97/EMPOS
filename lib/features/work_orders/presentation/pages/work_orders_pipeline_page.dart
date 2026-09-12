import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/localization/app_language.dart';
import '../../../../core/widgets/industry_components/universal_pipeline_kanban_widget.dart';
import '../../domain/entities/work_order_ticket.dart';
import '../bloc/work_order_bloc.dart';
import '../bloc/work_order_event.dart';
import '../bloc/work_order_state.dart';
import '../widgets/automotive_vehicle_3d_inspector_widget.dart';
import '../widgets/tattoo_piercing_3d_studio_widget.dart';
import '../widgets/retail_fashion_3d_showcase_widget.dart';
import '../widgets/real_estate_venue_3d_canvas_widget.dart';
import '../widgets/electronics_device_3d_inspector_widget.dart';

class WorkOrdersPipelinePage extends StatefulWidget {
  final WorkOrderBloc? bloc;
  final StoreBlueprint? blueprint;

  const WorkOrdersPipelinePage({super.key, this.bloc, this.blueprint});

  @override
  State<WorkOrdersPipelinePage> createState() => _WorkOrdersPipelinePageState();
}

class _WorkOrdersPipelinePageState extends State<WorkOrdersPipelinePage> {
  int _activeTabIndex = 0; // 0: Kanban Board, 1: 3D Professional Inspector/Canvas

  @override
  Widget build(BuildContext context) {
    final workOrderBloc = widget.bloc ?? context.read<WorkOrderBloc>();
    final isAutomotive = widget.blueprint?.isAutomotive == true ||
        widget.blueprint?.isEnabled('sw.auto_vehicle_3d_inspector') == true ||
        widget.blueprint?.isEnabled('sw.auto_repair_pipeline') == true;

    final isTattoo = widget.blueprint?.isTattooStudio == true ||
        widget.blueprint?.isEnabled('sw.tattoo_3d_body_canvas') == true;

    final isFashion = widget.blueprint?.isClothingBoutique == true ||
        widget.blueprint?.isEnabled('sw.fashion_3d_fitting_showcase') == true;

    final isRealEstate = widget.blueprint?.isRealEstate == true ||
        widget.blueprint?.isHospitality == true ||
        widget.blueprint?.isEnabled('sw.realty_3d_architectural_canvas') == true;

    final isElectronics = widget.blueprint?.isElectronicsPhoneShop == true ||
        widget.blueprint?.isEnabled('sw.device_3d_diagnostic_inspector') == true;

    final has3DWorkspace = isAutomotive || isTattoo || isFashion || isRealEstate || isElectronics;

    String headerTitle(int activeTickets) {
      if (isAutomotive) {
        return AppLanguage.tr(
          'Automotive Workshop & Pipeline ($activeTickets Active)',
          'مركز صيانة السيارات وخط العمليات ($activeTickets نشط)',
        );
      }
      if (isTattoo) {
        return AppLanguage.tr(
          'Tattoo & Piercing Studio Pipeline ($activeTickets Active)',
          'استوديو الوشم والبيرسينج وخط العمليات ($activeTickets نشط)',
        );
      }
      if (isFashion) {
        return AppLanguage.tr(
          'Fashion Boutique & Tailoring Pipeline ($activeTickets Active)',
          'بوتيك الأزياء والتفصيل وخط العمليات ($activeTickets نشط)',
        );
      }
      if (isRealEstate) {
        return AppLanguage.tr(
          'Real Estate & Venue Pipeline ($activeTickets Active)',
          'إدارة العقارات والقاعات والمشاريع ($activeTickets نشط)',
        );
      }
      if (isElectronics) {
        return AppLanguage.tr(
          'Electronics & Device Repair Pipeline ($activeTickets Active)',
          'صيانة الإلكترونيات والأجهزة الذكية وخط العمليات ($activeTickets نشط)',
        );
      }
      return AppLanguage.tr(
        'Service Orders & Job Pipeline ($activeTickets Active)',
        'أوامر الخدمة ومتابعة العمليات ($activeTickets نشط)',
      );
    }

    IconData headerIcon() {
      if (isAutomotive) return Icons.directions_car_filled;
      if (isTattoo) return Icons.brush;
      if (isFashion) return Icons.checkroom;
      if (isRealEstate) return Icons.apartment;
      if (isElectronics) return Icons.devices;
      return Icons.view_kanban_outlined;
    }

    String secondaryTabLabel() {
      if (isAutomotive) return AppLanguage.tr('3D Vehicle Inspector', 'فاحص المركبة 3D');
      if (isTattoo) return AppLanguage.tr('3D Body Canvas', 'رسم الجسم 3D');
      if (isFashion) return AppLanguage.tr('3D Mannequin & Fit', 'مانيكان الأزياء 3D');
      if (isRealEstate) return AppLanguage.tr('3D Architectural Floor', 'المخطط المعماري 3D');
      if (isElectronics) return AppLanguage.tr('3D Device Diagnostic', 'فحص الجهاز 3D');
      return AppLanguage.tr('3D Inspector', 'معاينة 3D');
    }

    IconData secondaryTabIcon() {
      if (isAutomotive) return Icons.car_repair;
      if (isTattoo) return Icons.accessibility_new;
      if (isFashion) return Icons.dry_cleaning;
      if (isRealEstate) return Icons.architecture;
      if (isElectronics) return Icons.phonelink_setup;
      return Icons.view_in_ar;
    }

    return BlocBuilder<WorkOrderBloc, WorkOrderState>(
      bloc: workOrderBloc,
      builder: (context, state) {
        if (state is WorkOrderInitial || state is WorkOrderLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is WorkOrderError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${AppLanguage.tr("Error", "خطأ")}: ${state.message}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => workOrderBloc.add(const LoadWorkOrdersEvent()),
                    child: Text(AppLanguage.tr('Retry', 'إعادة المحاولة')),
                  ),
                ],
              ),
            ),
          );
        }

        final loaded = state as WorkOrderLoaded;

        return Scaffold(
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Action Header with Dynamic Profession Switcher
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            headerIcon(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              headerTitle(loaded.tickets.length),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (has3DWorkspace) ...[
                          SegmentedButton<int>(
                            segments: [
                              ButtonSegment<int>(
                                value: 0,
                                icon: const Icon(Icons.view_kanban_outlined, size: 16),
                                label: Text(AppLanguage.tr('Kanban Pipeline', 'لوحة العمليات')),
                              ),
                              ButtonSegment<int>(
                                value: 1,
                                icon: Icon(secondaryTabIcon(), size: 16),
                                label: Text(secondaryTabLabel()),
                              ),
                            ],
                            selected: {_activeTabIndex},
                            onSelectionChanged: (selected) {
                              setState(() {
                                _activeTabIndex = selected.first;
                              });
                            },
                          ),
                          const SizedBox(width: 12),
                        ],
                        ElevatedButton.icon(
                          onPressed: () => _showCreateTicketDialog(context, workOrderBloc),
                          icon: const Icon(Icons.add),
                          label: Text(
                            isAutomotive
                                ? AppLanguage.tr('New Repair Order', 'أمر صيانة جديد')
                                : isTattoo
                                    ? AppLanguage.tr('New Tattoo Order', 'طلب وشم جديد')
                                    : isFashion
                                        ? AppLanguage.tr('New Tailoring Order', 'أمر تفصيل جديد')
                                        : AppLanguage.tr('New Service Ticket', 'تذكرة خدمة جديدة'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Main Workspace: 3D Professional Inspector or Universal Kanban
              Expanded(
                child: (has3DWorkspace && _activeTabIndex == 1)
                    ? _buildActive3DWorkspace(context, workOrderBloc, isAutomotive, isTattoo, isFashion, isRealEstate)
                    : UniversalPipelineKanbanWidget(
                        pipeline: loaded.pipeline,
                        onAdvanceStage: (ticket, targetStage) {
                          workOrderBloc.add(
                            AdvanceStageEvent(
                              ticketId: ticket.id,
                              newStage: targetStage,
                              note: 'Stage advanced from Kanban board',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActive3DWorkspace(
    BuildContext context,
    WorkOrderBloc workOrderBloc,
    bool isAutomotive,
    bool isTattoo,
    bool isFashion,
    bool isRealEstate,
  ) {
    if (isAutomotive) {
      return AutomotiveVehicle3DInspectorWidget(
        onFindingAddedToTicket: (point) {
          workOrderBloc.add(
            CreateWorkOrderEvent(
              WorkOrderTicket(
                id: 'wo_${DateTime.now().millisecondsSinceEpoch}',
                title: '[${point.severity.name.toUpperCase()}] ${point.title} - ${point.systemCategory}',
                customerId: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                customerName: 'Bay Intake Client',
                customerPhone: '01000000000',
                currentStage: WorkOrderStage.intake,
                totalEstimate: point.estimatedRepairCost,
                createdAt: DateTime.now(),
              ),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                AppLanguage.tr(
                  'Defect "${point.title}" added to Service Intake pipeline!',
                  'تمت إضافة العطل "${point.title}" إلى خط الاستلام والصيانة!',
                ),
              ),
              backgroundColor: const Color(0xFF0D9488),
            ),
          );
        },
      );
    }
    if (isTattoo) {
      return TattooPiercing3DStudioWidget(
        onDesignCommitted: (design) {
          workOrderBloc.add(
            CreateWorkOrderEvent(
              WorkOrderTicket(
                id: 'wo_${DateTime.now().millisecondsSinceEpoch}',
                title: '[TATTOO] ${design.title} (${design.style.localized})',
                customerId: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                customerName: 'Studio Client',
                customerPhone: '01000000000',
                currentStage: WorkOrderStage.intake,
                totalEstimate: design.priceEgp,
                createdAt: DateTime.now(),
              ),
            ),
          );
        },
      );
    }
    if (isFashion) {
      return RetailFashion3DShowcaseWidget(
        onOrderCommitted: (garment, pins) {
          workOrderBloc.add(
            CreateWorkOrderEvent(
              WorkOrderTicket(
                id: 'wo_${DateTime.now().millisecondsSinceEpoch}',
                title: '[BESPOKE] ${garment.name} (${pins.length} alterations)',
                customerId: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                customerName: 'Boutique Client',
                customerPhone: '01000000000',
                currentStage: WorkOrderStage.intake,
                totalEstimate: garment.priceEgp,
                createdAt: DateTime.now(),
              ),
            ),
          );
        },
      );
    }
    if (isRealEstate) {
      return RealEstateVenue3DCanvasWidget(
        onListingCommitted: (unit) {
          workOrderBloc.add(
            CreateWorkOrderEvent(
              WorkOrderTicket(
                id: 'wo_${DateTime.now().millisecondsSinceEpoch}',
                title: '[REALTY] ${unit.name} (${unit.zoneType.localized})',
                customerId: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                customerName: 'Property Prospect',
                customerPhone: '01000000000',
                currentStage: WorkOrderStage.intake,
                totalEstimate: unit.priceEgp,
                createdAt: DateTime.now(),
              ),
            ),
          );
        },
      );
    }
    return ElectronicsDevice3DInspectorWidget(
      onOrderCommitted: (device, pins) {
        workOrderBloc.add(
          CreateWorkOrderEvent(
            WorkOrderTicket(
              id: 'wo_${DateTime.now().millisecondsSinceEpoch}',
              title: '[REPAIR] ${device.brand} ${device.modelName} (${pins.length} faults)',
              customerId: 'cust_${DateTime.now().millisecondsSinceEpoch}',
              customerName: 'Tech Client',
              customerPhone: '01000000000',
              currentStage: WorkOrderStage.intake,
              totalEstimate: device.diagnosticFeeEgp +
                  pins.fold(0.0, (acc, p) => acc + p.repairEstimateEgp),
              createdAt: DateTime.now(),
            ),
          ),
        );
      },
    );
  }

  void _showCreateTicketDialog(BuildContext context, WorkOrderBloc bloc) {
    final titleController = TextEditingController();
    final customerController = TextEditingController();
    final phoneController = TextEditingController();
    final estimateController = TextEditingController(text: '1500.0');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLanguage.tr('Create New Service Ticket', 'إنشاء تذكرة صيانة جديدة')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: AppLanguage.tr('Job Title / Service Description', 'وصف المهمة / الخدمة المطلوبة'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customerController,
                decoration: InputDecoration(
                  labelText: AppLanguage.tr('Customer Full Name', 'اسم العميل بالكامل'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: AppLanguage.tr('Customer Phone', 'رقم هاتف العميل'),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: estimateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: AppLanguage.tr('Initial Estimate (EGP)', 'التقدير المالي الأولي (ج.م)'),
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(AppLanguage.tr('Cancel', 'إلغاء')),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                final cust = customerController.text.trim();
                if (title.isEmpty || cust.isEmpty) return;

                final estimate = double.tryParse(estimateController.text.trim()) ?? 0.0;

                bloc.add(
                  CreateWorkOrderEvent(
                    WorkOrderTicket(
                      id: 'wo_${DateTime.now().millisecondsSinceEpoch}',
                      title: title,
                      customerId: 'cust_${DateTime.now().millisecondsSinceEpoch}',
                      customerName: cust,
                      customerPhone: phoneController.text.trim(),
                      currentStage: WorkOrderStage.intake,
                      totalEstimate: estimate,
                      createdAt: DateTime.now(),
                    ),
                  ),
                );

                Navigator.of(ctx).pop();
              },
              child: Text(AppLanguage.tr('Create Ticket', 'إنشاء التذكرة')),
            ),
          ],
        );
      },
    );
  }
}
