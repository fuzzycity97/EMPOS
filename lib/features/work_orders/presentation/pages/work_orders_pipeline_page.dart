import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/industry_components/universal_pipeline_kanban_widget.dart';
import '../../domain/entities/work_order_ticket.dart';
import '../bloc/work_order_bloc.dart';
import '../bloc/work_order_event.dart';
import '../bloc/work_order_state.dart';

class WorkOrdersPipelinePage extends StatelessWidget {
  final WorkOrderBloc? bloc;

  const WorkOrdersPipelinePage({super.key, this.bloc});

  @override
  Widget build(BuildContext context) {
    final workOrderBloc = bloc ?? context.read<WorkOrderBloc>();

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
                  Text('Error: ${state.message}', style: const TextStyle(color: Colors.red)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => workOrderBloc.add(const LoadWorkOrdersEvent()),
                    child: const Text('Retry'),
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
              // Top Action Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  border: Border(
                    bottom: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.view_kanban_outlined, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Service Orders & Job Pipeline (${loaded.tickets.length} Active)',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateTicketDialog(context, workOrderBloc),
                      icon: const Icon(Icons.add),
                      label: const Text('New Service Ticket'),
                    ),
                  ],
                ),
              ),

              // Kanban Board
              Expanded(
                child: UniversalPipelineKanbanWidget(
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

  void _showCreateTicketDialog(BuildContext context, WorkOrderBloc bloc) {
    final titleController = TextEditingController();
    final customerController = TextEditingController();
    final phoneController = TextEditingController();
    final estimateController = TextEditingController(text: '1500.0');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Create New Work Order Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Job Title / Service Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customerController,
                decoration: const InputDecoration(labelText: 'Customer Full Name', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Customer Phone', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: estimateController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Initial Estimate (EGP)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
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
              child: const Text('Create Ticket'),
            ),
          ],
        );
      },
    );
  }
}
