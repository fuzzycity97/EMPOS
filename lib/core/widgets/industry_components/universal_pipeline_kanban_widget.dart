import 'package:flutter/material.dart';
import '../../../features/work_orders/domain/entities/work_order_ticket.dart';

class UniversalPipelineKanbanWidget extends StatelessWidget {
  final Map<WorkOrderStage, List<WorkOrderTicket>> pipeline;
  final void Function(WorkOrderTicket ticket, WorkOrderStage targetStage)? onAdvanceStage;
  final void Function(WorkOrderTicket ticket)? onTicketTapped;

  const UniversalPipelineKanbanWidget({
    super.key,
    required this.pipeline,
    this.onAdvanceStage,
    this.onTicketTapped,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stages = WorkOrderStage.values.where((s) => s != WorkOrderStage.cancelled).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: stages.map((stage) {
              final tickets = pipeline[stage] ?? [];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Column Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        border: Border(
                          bottom: BorderSide(
                            color: isDark ? Colors.white10 : Colors.black12,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _getStageColor(stage),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              stage.label,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStageColor(stage).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${tickets.length}',
                              style: TextStyle(
                                color: _getStageColor(stage),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Cards List
                    Container(
                      constraints: BoxConstraints(
                        maxHeight: constraints.maxHeight > 100 ? constraints.maxHeight - 80 : 500,
                      ),
                      child: tickets.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                child: Text(
                                  'No tickets',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: isDark ? Colors.white38 : Colors.black38,
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(10),
                              itemCount: tickets.length,
                              itemBuilder: (context, index) {
                                final ticket = tickets[index];
                                return _WorkOrderCard(
                                  ticket: ticket,
                                  isDark: isDark,
                                  onTap: () => onTicketTapped?.call(ticket),
                                  onAdvance: () {
                                    final nextStage = _getNextStage(ticket.currentStage);
                                    if (nextStage != null) {
                                      onAdvanceStage?.call(ticket, nextStage);
                                    }
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Color _getStageColor(WorkOrderStage stage) {
    switch (stage) {
      case WorkOrderStage.intake:
        return Colors.blue;
      case WorkOrderStage.inspection:
        return Colors.amber;
      case WorkOrderStage.inProgress:
        return Colors.indigo;
      case WorkOrderStage.qualityCheck:
        return Colors.purple;
      case WorkOrderStage.ready:
        return Colors.teal;
      case WorkOrderStage.delivered:
        return Colors.green;
      case WorkOrderStage.cancelled:
        return Colors.red;
    }
  }

  WorkOrderStage? _getNextStage(WorkOrderStage current) {
    switch (current) {
      case WorkOrderStage.intake:
        return WorkOrderStage.inspection;
      case WorkOrderStage.inspection:
        return WorkOrderStage.inProgress;
      case WorkOrderStage.inProgress:
        return WorkOrderStage.qualityCheck;
      case WorkOrderStage.qualityCheck:
        return WorkOrderStage.ready;
      case WorkOrderStage.ready:
        return WorkOrderStage.delivered;
      case WorkOrderStage.delivered:
      case WorkOrderStage.cancelled:
        return null;
    }
  }
}

class _WorkOrderCard extends StatelessWidget {
  final WorkOrderTicket ticket;
  final bool isDark;
  final VoidCallback? onTap;
  final VoidCallback? onAdvance;

  const _WorkOrderCard({
    required this.ticket,
    required this.isDark,
    this.onTap,
    this.onAdvance,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                ticket.title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.customerName,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark ? Colors.white70 : Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              if (ticket.customMetadata.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: ticket.customMetadata.entries.take(2).map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Estimate',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ),
                      Text(
                        '${ticket.totalEstimate.toStringAsFixed(0)} EGP',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  if (ticket.currentStage != WorkOrderStage.delivered &&
                      ticket.currentStage != WorkOrderStage.cancelled)
                    ElevatedButton.icon(
                      onPressed: onAdvance,
                      icon: const Icon(Icons.arrow_forward, size: 12),
                      label: const Text('Advance', style: TextStyle(fontSize: 11)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
