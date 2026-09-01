import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Connection Audit Event Model
class ConnectionLogEntry {
  final DateTime timestamp;
  final String eventType; // 'CONNECTED', 'DISCONNECTED', 'SERVER_SHUTDOWN', 'RECONNECTING'
  final String message;
  final String? latencyMs;
  final bool isSuccess;

  const ConnectionLogEntry({
    required this.timestamp,
    required this.eventType,
    required this.message,
    this.latencyMs,
    required this.isSuccess,
  });
}

/// Dynamic Connection Status Badge Pill (Green / Red) with Real-Time Changelog Sheet.
/// 100% [StatelessWidget] architecture.
class SyncConnectionStatusBadge extends StatelessWidget {
  final ValueNotifier<bool> isConnectedNotifier;
  final ValueNotifier<String> serverUrlNotifier;
  final ValueNotifier<int?> latencyMsNotifier;
  final ValueNotifier<List<ConnectionLogEntry>> connectionLogsNotifier;

  SyncConnectionStatusBadge({
    super.key,
    ValueNotifier<bool>? isConnectedNotifier,
    ValueNotifier<String>? serverUrlNotifier,
    ValueNotifier<int?>? latencyMsNotifier,
    ValueNotifier<List<ConnectionLogEntry>>? connectionLogsNotifier,
  })  : isConnectedNotifier = isConnectedNotifier ?? ValueNotifier<bool>(true),
        serverUrlNotifier = serverUrlNotifier ?? ValueNotifier<String>('192.168.1.100:3000 (LAN)'),
        latencyMsNotifier = latencyMsNotifier ?? ValueNotifier<int?>(14),
        connectionLogsNotifier = connectionLogsNotifier ??
            ValueNotifier<List<ConnectionLogEntry>>([
              ConnectionLogEntry(
                timestamp: DateTime.now(),
                eventType: 'CONNECTED',
                message: 'WebSocket session established with 192.168.1.100:3000',
                latencyMs: '14ms',
                isSuccess: true,
              ),
              ConnectionLogEntry(
                timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
                eventType: 'RECONNECTING',
                message: 'TCP keep-alive acknowledged by host daemon',
                latencyMs: '18ms',
                isSuccess: true,
              ),
            ]);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isConnectedNotifier,
      builder: (context, isConnected, _) {
        return ValueListenableBuilder<int?>(
          valueListenable: latencyMsNotifier,
          builder: (context, latency, _) {
            final color = isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444);

            return InkWell(
              borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
              onTap: () => _showConnectionChangelogSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                  border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withValues(alpha: 0.6),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 7),
                    Icon(
                      isConnected ? LucideIcons.radio : LucideIcons.radioTower,
                      size: 13,
                      color: color,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      isConnected
                          ? 'Online ${latency != null ? "• ${latency}ms" : ""}'
                          : 'Disconnected • Reconnecting...',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showConnectionChangelogSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF090D16) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusLarge)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(AppDimensions.space20),
          constraints: const BoxConstraints(maxHeight: 520),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.activity, size: 18, color: AppColors.primaryLight),
                      SizedBox(width: 8),
                      Text(
                        'Live Connection Lifecycle & Audit Stream',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.x, size: 18),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
              const Divider(height: 16),
              ValueListenableBuilder<List<ConnectionLogEntry>>(
                valueListenable: connectionLogsNotifier,
                builder: (context, logs, _) {
                  if (logs.isEmpty) {
                    return const Expanded(
                      child: Center(
                        child: Text(
                          'No connection events logged yet.',
                          style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                        ),
                      ),
                    );
                  }

                  return Expanded(
                    child: ListView.separated(
                      itemCount: logs.length,
                      separatorBuilder: (_, _) => const Divider(height: 12),
                      itemBuilder: (c, idx) {
                        final log = logs[idx];
                        final timeStr = DateFormat('HH:mm:ss').format(log.timestamp);
                        final badgeColor = log.isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: badgeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.eventType,
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                  color: badgeColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    log.message,
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    timeStr + (log.latencyMs != null ? ' • Latency: ${log.latencyMs}' : ''),
                                    style: const TextStyle(fontSize: 10.5, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
