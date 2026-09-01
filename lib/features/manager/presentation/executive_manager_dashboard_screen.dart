import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../domain/entities/manager_profit_split_engine.dart';

/// Real-Time Executive Manager Operations & Monitoring Dashboard.
/// 100% [StatelessWidget] architecture.
class ExecutiveManagerDashboardScreen extends StatelessWidget {
  final ValueNotifier<List<StaffPayrollEntry>> payrollNotifier;
  final ValueNotifier<List<Map<String, dynamic>>> liveSalesNotifier;
  final ValueNotifier<List<Map<String, dynamic>>> inventoryAlertsNotifier;
  final ValueNotifier<int> onlineTerminalsNotifier;
  final VoidCallback? onSettlePayroll;

  ExecutiveManagerDashboardScreen({
    super.key,
    ValueNotifier<List<StaffPayrollEntry>>? payrollNotifier,
    ValueNotifier<List<Map<String, dynamic>>>? liveSalesNotifier,
    ValueNotifier<List<Map<String, dynamic>>>? inventoryAlertsNotifier,
    ValueNotifier<int>? onlineTerminalsNotifier,
    this.onSettlePayroll,
  })  : payrollNotifier = payrollNotifier ?? ValueNotifier<List<StaffPayrollEntry>>(_samplePayroll),
        liveSalesNotifier = liveSalesNotifier ?? ValueNotifier<List<Map<String, dynamic>>>(_sampleLiveSales),
        inventoryAlertsNotifier = inventoryAlertsNotifier ?? ValueNotifier<List<Map<String, dynamic>>>(_sampleAlerts),
        onlineTerminalsNotifier = onlineTerminalsNotifier ?? ValueNotifier<int>(3);

  static final List<StaffPayrollEntry> _samplePayroll = [
    const StaffPayrollEntry(
      staffId: 'stf_01',
      staffName: 'Dr. Sarah Hassan (Dentist)',
      baseSalary: 12000.0,
      commissions: 3400.0,
      unsettledAdvances: 1500.0,
      bonuses: 500.0,
    ),
    const StaffPayrollEntry(
      staffId: 'stf_02',
      staffName: 'Ahmed Nabil (Pharmacist)',
      baseSalary: 7500.0,
      commissions: 800.0,
      unsettledAdvances: 0.0,
      bonuses: 200.0,
    ),
    const StaffPayrollEntry(
      staffId: 'stf_03',
      staffName: 'Mona Youssef (Reception Lead)',
      baseSalary: 5500.0,
      commissions: 450.0,
      unsettledAdvances: 800.0,
      bonuses: 0.0,
    ),
  ];

  static final List<Map<String, dynamic>> _sampleLiveSales = [
    {
      'invoiceId': 'INV-2026-901',
      'dept': 'Dental Wing',
      'patient': 'Kareem Tarek',
      'amount': 1850.0,
      'time': 'Just now',
      'status': 'PAID',
    },
    {
      'invoiceId': 'INV-2026-900',
      'dept': 'In-House Pharmacy',
      'patient': 'Nourhan Adel',
      'amount': 240.0,
      'time': '2m ago',
      'status': 'PAID',
    },
    {
      'invoiceId': 'INV-2026-899',
      'dept': 'Optical Boutique',
      'patient': 'Mahmoud Reda',
      'amount': 2100.0,
      'time': '6m ago',
      'status': 'PARTIAL',
    },
  ];

  static final List<Map<String, dynamic>> _sampleAlerts = [
    {
      'name': 'Amoxicillin 500mg (Batch #AMX-22)',
      'dept': 'Pharmacy FEFO',
      'type': 'EXPIRING_SOON',
      'info': 'Expires in 18 days (Qty: 45)',
      'severity': 'HIGH',
    },
    {
      'name': 'Dental Composite Resin A2',
      'dept': 'Clinic Consumables',
      'type': 'LOW_STOCK',
      'info': 'Only 2 tubes remaining (Threshold: 5)',
      'severity': 'MEDIUM',
    },
    {
      'name': 'Ray-Ban Aviator Gold Frame',
      'dept': 'Optical Retail',
      'type': 'OUT_OF_STOCK',
      'info': '0 units on shelf',
      'severity': 'CRITICAL',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(LucideIcons.barChart3, size: 20, color: AppColors.primaryLight),
            SizedBox(width: 10),
            Text(
              'Executive Operations & Real-Time Sync Dashboard',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          ValueListenableBuilder<int>(
            valueListenable: onlineTerminalsNotifier,
            builder: (context, terminals, _) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$terminals Terminals Online',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TOP KPI ROW ──────────────────────────────────────────
            Row(
              children: [
                Expanded(child: _kpiCard('Gross Revenue Today', '14,850.00 EGP', '+18.4% vs avg', LucideIcons.dollarSign, AppColors.success, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _kpiCard('Net Operating Profit', '8,920.00 EGP', 'Pool Mode: Net', LucideIcons.trendingUp, AppColors.primaryLight, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _kpiCard('Unsettled Advances', '2,300.00 EGP', '3 Employees', LucideIcons.receipt, AppColors.warning, isDark)),
                const SizedBox(width: 12),
                Expanded(child: _kpiCard('Critical Inventory Alerts', '3 Items', 'Action Required', LucideIcons.alertTriangle, AppColors.danger, isDark)),
              ],
            ),
            const SizedBox(height: 20),

            // ── MAIN SPLIT VIEW ──────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT: LIVE SALES STREAM & INVENTORY ALERTS ───────
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      // Live Sales Stream
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.radio, size: 16, color: AppColors.success),
                                SizedBox(width: 8),
                                Text('Live WebSocket Sales Stream', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: liveSalesNotifier,
                              builder: (context, sales, _) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: sales.length,
                                  separatorBuilder: (_, _) => const Divider(height: 12),
                                  itemBuilder: (ctx, idx) {
                                    final item = sales[idx];
                                    return Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                          ),
                                          child: const Icon(LucideIcons.shoppingBag, size: 16, color: AppColors.primaryLight),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${item['invoiceId']} • ${item['patient']}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                                              ),
                                              Text(
                                                '${item['dept']} • ${item['time']}',
                                                style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              '${(item['amount'] as num).toStringAsFixed(2)} EGP',
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, fontFamily: 'monospace'),
                                            ),
                                            Text(
                                              item['status'],
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                                color: item['status'] == 'PAID' ? AppColors.success : AppColors.warning,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cross-Department Inventory Alerts
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.boxes, size: 16, color: AppColors.warning),
                                SizedBox(width: 8),
                                Text('Cross-Department Inventory & Expiry Watch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ValueListenableBuilder<List<Map<String, dynamic>>>(
                              valueListenable: inventoryAlertsNotifier,
                              builder: (context, alerts, _) {
                                return ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: alerts.length,
                                  separatorBuilder: (_, _) => const Divider(height: 12),
                                  itemBuilder: (ctx, idx) {
                                    final alert = alerts[idx];
                                    final isHigh = alert['severity'] == 'CRITICAL' || alert['severity'] == 'HIGH';
                                    return Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: (isHigh ? AppColors.danger : AppColors.warning).withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Icon(
                                            isHigh ? LucideIcons.alertOctagon : LucideIcons.alertCircle,
                                            size: 16,
                                            color: isHigh ? AppColors.danger : AppColors.warning,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(alert['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                              Text('${alert['dept']} • ${alert['info']}', style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // ── RIGHT: STAFF PAYROLL & ADVANCE SETTLEMENT ────────
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.users, size: 16, color: AppColors.primaryLight),
                                SizedBox(width: 8),
                                Text('Staff Payroll & Advance Deductions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              icon: const Icon(LucideIcons.checkCheck, size: 14),
                              label: const Text('Settle Period', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              onPressed: () {
                                final current = List<StaffPayrollEntry>.from(payrollNotifier.value);
                                payrollNotifier.value = current.map((p) => p.copyWithSettled()).toList();
                                onSettlePayroll?.call();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    backgroundColor: AppColors.success,
                                    content: Text('Payroll period settled and all employee advances cleared!'),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ValueListenableBuilder<List<StaffPayrollEntry>>(
                          valueListenable: payrollNotifier,
                          builder: (context, payroll, _) {
                            return ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: payroll.length,
                              separatorBuilder: (_, _) => const Divider(height: 16),
                              itemBuilder: (ctx, idx) {
                                final p = payroll[idx];
                                return Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                    border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(p.staffName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
                                          Text(
                                            'Net: ${p.netPayable.toStringAsFixed(2)} EGP',
                                            style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontFamily: 'monospace', fontSize: 12.5),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Base: ${p.baseSalary.toStringAsFixed(0)} EGP', style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark)),
                                          Text('Commission: +${p.commissions.toStringAsFixed(0)} EGP', style: const TextStyle(fontSize: 10.5, color: AppColors.primaryLight)),
                                          Text(
                                            'Advance: -${p.unsettledAdvances.toStringAsFixed(0)} EGP',
                                            style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: p.unsettledAdvances > 0 ? AppColors.danger : AppColors.textMutedDark),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _kpiCard(String title, String value, String sub, IconData icon, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.textMutedDark)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
