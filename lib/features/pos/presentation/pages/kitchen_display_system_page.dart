import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

enum KdsTicketStatus { newOrder, cooking, ready, served }

class KdsTicketItem {
  final String name;
  final int quantity;
  final String? modifierNotes;

  const KdsTicketItem({
    required this.name,
    required this.quantity,
    this.modifierNotes,
  });
}

class KdsTicket {
  final String id;
  final String orderNumber;
  final String tableOrCustomer;
  final String serverName;
  final DateTime orderTime;
  final KdsTicketStatus status;
  final List<KdsTicketItem> items;
  final bool isRush;

  const KdsTicket({
    required this.id,
    required this.orderNumber,
    required this.tableOrCustomer,
    required this.serverName,
    required this.orderTime,
    required this.status,
    required this.items,
    this.isRush = false,
  });

  KdsTicket copyWith({
    String? id,
    String? orderNumber,
    String? tableOrCustomer,
    String? serverName,
    DateTime? orderTime,
    KdsTicketStatus? status,
    List<KdsTicketItem>? items,
    bool? isRush,
  }) {
    return KdsTicket(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      tableOrCustomer: tableOrCustomer ?? this.tableOrCustomer,
      serverName: serverName ?? this.serverName,
      orderTime: orderTime ?? this.orderTime,
      status: status ?? this.status,
      items: items ?? this.items,
      isRush: isRush ?? this.isRush,
    );
  }
}

/// Kitchen Display System (KDS) interactive horizontal order rail.
/// 100% [StatelessWidget] following pure Clean Architecture.
class KitchenDisplaySystemPage extends StatelessWidget {
  final ValueNotifier<List<KdsTicket>> ticketsNotifier;
  final ValueNotifier<String> filterNotifier;

  KitchenDisplaySystemPage({
    super.key,
    ValueNotifier<List<KdsTicket>>? ticketsNotifier,
    ValueNotifier<String>? filterNotifier,
  })  : ticketsNotifier = ticketsNotifier ??
            ValueNotifier<List<KdsTicket>>(_seededTickets),
        filterNotifier = filterNotifier ?? ValueNotifier<String>('ALL');

  static final List<KdsTicket> _seededTickets = [
    KdsTicket(
      id: 'kds_1',
      orderNumber: '#101',
      tableOrCustomer: 'Table 2 (Dine-in)',
      serverName: 'Ahmed K.',
      orderTime: DateTime.now().subtract(const Duration(minutes: 4)),
      status: KdsTicketStatus.newOrder,
      isRush: true,
      items: const [
        KdsTicketItem(name: 'Double Cheeseburger', quantity: 2, modifierNotes: 'Medium rare, no onions'),
        KdsTicketItem(name: 'Crispy Truffle Fries', quantity: 1, modifierNotes: 'Extra dipping sauce'),
        KdsTicketItem(name: 'Classic Lemonade', quantity: 2),
      ],
    ),
    KdsTicket(
      id: 'kds_2',
      orderNumber: '#102',
      tableOrCustomer: 'Booth 6 (Dine-in)',
      serverName: 'Sara M.',
      orderTime: DateTime.now().subtract(const Duration(minutes: 12)),
      status: KdsTicketStatus.cooking,
      items: const [
        KdsTicketItem(name: 'Ribeye Steak 300g', quantity: 1, modifierNotes: 'Medium well with garlic butter'),
        KdsTicketItem(name: 'Creamy Mushroom Pasta', quantity: 1),
        KdsTicketItem(name: 'Sparkling Water 750ml', quantity: 1),
      ],
    ),
    KdsTicket(
      id: 'kds_3',
      orderNumber: '#103',
      tableOrCustomer: 'Takeaway #12',
      serverName: 'Counter Cashier',
      orderTime: DateTime.now().subtract(const Duration(minutes: 18)),
      status: KdsTicketStatus.ready,
      items: const [
        KdsTicketItem(name: 'BBQ Chicken Wings (8pcs)', quantity: 2, modifierNotes: 'Extra napkins packed'),
        KdsTicketItem(name: 'Spicy Coleslaw', quantity: 2),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP KDS BAR ──────────────────────────────────────────────────
            _buildKdsHeader(context),
            const Divider(height: 1, color: AppColors.borderDark),

            // ── KANBAN COLUMNS ───────────────────────────────────────────────
            Expanded(
              child: ValueListenableBuilder<List<KdsTicket>>(
                valueListenable: ticketsNotifier,
                builder: (context, tickets, _) {
                  final newTickets = tickets.where((t) => t.status == KdsTicketStatus.newOrder).toList();
                  final cookingTickets = tickets.where((t) => t.status == KdsTicketStatus.cooking).toList();
                  final readyTickets = tickets.where((t) => t.status == KdsTicketStatus.ready).toList();
                  final servedTickets = tickets.where((t) => t.status == KdsTicketStatus.served).toList();

                  return Padding(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _buildColumn(context, 'NEW ORDERS', newTickets, AppColors.error, LucideIcons.bellRing)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildColumn(context, 'IN PREPARATION', cookingTickets, AppColors.warning, LucideIcons.flame)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildColumn(context, 'READY FOR EXPO', readyTickets, AppColors.success, LucideIcons.checkCircle)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildColumn(context, 'SERVED / ARCHIVE', servedTickets, AppColors.textSecondaryDark, LucideIcons.history)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKdsHeader(BuildContext context) {
    return ValueListenableBuilder<List<KdsTicket>>(
      valueListenable: ticketsNotifier,
      builder: (context, tickets, _) {
        final pendingCount = tickets.where((t) => t.status != KdsTicketStatus.served).length;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppDimensions.space20, vertical: AppDimensions.space12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  ),
                  child: const Icon(LucideIcons.chefHat, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: AppDimensions.space12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kitchen Display System (KDS)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      'Real-Time Kitchen Cook Rail & Order Expediter',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                    ),
                  ],
                ),
                const SizedBox(width: 24),

                // Metric Badges
                _buildHeaderBadge('$pendingCount ACTIVE ORDERS', AppColors.primary),
                const SizedBox(width: 10),
                _buildHeaderBadge('AVG COOK: 11 MIN', AppColors.success),
                const SizedBox(width: 10),

                // Add Quick Ticket simulation
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: AppColors.borderDark),
                  ),
                  icon: const Icon(LucideIcons.plus, size: 14),
                  label: const Text('Simulate Order Ticket'),
                  onPressed: () {
                    final list = List<KdsTicket>.from(ticketsNotifier.value);
                    final nextNum = 100 + list.length + 1;
                    list.insert(
                      0,
                      KdsTicket(
                        id: 'kds_${DateTime.now().millisecondsSinceEpoch}',
                        orderNumber: '#$nextNum',
                        tableOrCustomer: 'Table ${(nextNum % 8) + 1} (Dine-in)',
                        serverName: 'Ahmed K.',
                        orderTime: DateTime.now(),
                        status: KdsTicketStatus.newOrder,
                        items: const [
                          KdsTicketItem(name: 'Gourmet Burger Combo', quantity: 1, modifierNotes: 'Extra pickles'),
                          KdsTicketItem(name: 'Iced Latte', quantity: 1),
                        ],
                      ),
                    );
                    ticketsNotifier.value = list;
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeaderBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildColumn(BuildContext context, String title, List<KdsTicket> columnTickets, Color accentColor, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusMedium)),
              border: Border(bottom: BorderSide(color: accentColor.withValues(alpha: 0.3))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: accentColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${columnTickets.length}',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          // Tickets List
          Expanded(
            child: columnTickets.isEmpty
                ? Center(
                    child: Text(
                      'No tickets in this lane',
                      style: TextStyle(color: AppColors.textSecondaryDark.withValues(alpha: 0.5), fontSize: 12),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(10),
                    itemCount: columnTickets.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, idx) {
                      final ticket = columnTickets[idx];
                      return _buildTicketCard(context, ticket);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(BuildContext context, KdsTicket ticket) {
    final elapsedMinutes = DateTime.now().difference(ticket.orderTime).inMinutes;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(
          color: ticket.isRush ? AppColors.error : AppColors.borderDark,
          width: ticket.isRush ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Ticket Number & Elapsed Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    ticket.orderNumber,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white),
                  ),
                  if (ticket.isRush) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('RUSH', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
              Row(
                children: [
                  Icon(LucideIcons.clock, size: 12, color: elapsedMinutes > 15 ? AppColors.error : AppColors.textSecondaryDark),
                  const SizedBox(width: 4),
                  Text(
                    '${elapsedMinutes}m ago',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: elapsedMinutes > 15 ? AppColors.error : AppColors.textSecondaryDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Table & Server
          Text(
            '${ticket.tableOrCustomer} • ${ticket.serverName}',
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
          ),
          const Divider(height: 14, color: AppColors.borderDark),

          // Order Items
          ...ticket.items.map((item) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text('${item.quantity}x', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  if (item.modifierNotes != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 24, top: 1),
                      child: Text(
                        '↳ ${item.modifierNotes}',
                        style: const TextStyle(color: AppColors.warning, fontSize: 10, fontStyle: FontStyle.italic),
                      ),
                    ),
                ],
              ),
            );
          }),
          const SizedBox(height: 10),

          // Advance Status Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (ticket.status == KdsTicketStatus.newOrder)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                  icon: const Icon(LucideIcons.flame, size: 12, color: Colors.white),
                  label: const Text('Start Cook', style: TextStyle(fontSize: 11, color: Colors.white)),
                  onPressed: () => _updateTicketStatus(ticket.id, KdsTicketStatus.cooking),
                )
              else if (ticket.status == KdsTicketStatus.cooking)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                  icon: const Icon(LucideIcons.check, size: 12, color: Colors.white),
                  label: const Text('Mark Ready', style: TextStyle(fontSize: 11, color: Colors.white)),
                  onPressed: () => _updateTicketStatus(ticket.id, KdsTicketStatus.ready),
                )
              else if (ticket.status == KdsTicketStatus.ready)
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6)),
                  icon: const Icon(LucideIcons.checkCheck, size: 12, color: Colors.white),
                  label: const Text('Served', style: TextStyle(fontSize: 11, color: Colors.white)),
                  onPressed: () => _updateTicketStatus(ticket.id, KdsTicketStatus.served),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _updateTicketStatus(String ticketId, KdsTicketStatus nextStatus) {
    final currentList = List<KdsTicket>.from(ticketsNotifier.value);
    final idx = currentList.indexWhere((t) => t.id == ticketId);
    if (idx != -1) {
      currentList[idx] = currentList[idx].copyWith(status: nextStatus);
      ticketsNotifier.value = currentList;
    }
  }
}
