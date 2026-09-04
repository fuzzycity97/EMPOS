import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/services/sync_connection_manager.dart';

/// Small persistent reactive UI element showing node connection status:
/// - ?? Green (#10B981) when connected: "Host Server (Port 3000)" or "Client (Connected - Xms)"
/// - ?? Red (#EF4444) when disconnected: "Disconnected (Reconnecting...)"
/// Tapping opens the reverse-chronological Connection Audit Changelog Drawer.
/// 100% [StatelessWidget] architecture.
class SyncConnectionPillBadge extends StatelessWidget {
  final SyncConnectionManager connectionManager;

  SyncConnectionPillBadge({
    super.key,
    SyncConnectionManager? connectionManager,
  }) : connectionManager = connectionManager ?? SyncConnectionManager();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: connectionManager,
      builder: (context, _) {
        final isOnline = connectionManager.isConnected;
        const greenColor = Color(0xFF10B981);
        const redColor = Color(0xFFEF4444);
        final color = isOnline ? greenColor : redColor;

        final String label;
        if (isOnline) {
          if (connectionManager.isHost) {
            final port = connectionManager.cachedProfile?.hostPort ?? 3000;
            label = 'Host Server (Port $port)';
          } else {
            label = 'Client (Connected - ${connectionManager.latencyMs}ms)';
          }
        } else {
          label = 'Disconnected (Reconnecting...)';
        }

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showAuditChangelogDrawer(context),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAuditChangelogDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.backgroundDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final logs = connectionManager.connectionChangelog;
        final profile = connectionManager.cachedProfile;

        return DraggableScrollableSheet(
          initialChildSize: 0.60,
          minChildSize: 0.35,
          maxChildSize: 0.90,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drawer drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.borderDark,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Header
                  Row(
                    children: [
                      const Icon(LucideIcons.activity, color: AppColors.primary, size: 18),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Connection Audit Changelog',
                          style: TextStyle(
                            color: AppColors.textPrimaryDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Text(
                          '${logs.length}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(LucideIcons.x, color: AppColors.textMutedDark, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),

                  // Node metadata status banner
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMetaItem(
                          'ROLE',
                          connectionManager.activeRole.name.toUpperCase(),
                          connectionManager.isHost ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                        ),
                        _buildMetaItem(
                          'STATUS',
                          connectionManager.state.name.toUpperCase(),
                          connectionManager.isConnected ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        _buildMetaItem(
                          'LATENCY',
                          '${connectionManager.latencyMs}ms',
                          AppColors.textPrimaryDark,
                        ),
                        if (profile != null)
                          _buildMetaItem(
                            'TARGET',
                            connectionManager.isHost ? 'Port ${profile.hostPort}' : profile.serverUrl,
                            AppColors.textMutedDark,
                          ),
                      ],
                    ),
                  ),

                  const Divider(color: AppColors.borderDark),

                  // Append-only audit events log
                  Expanded(
                    child: logs.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(LucideIcons.inbox, size: 36, color: AppColors.textMutedDark),
                                SizedBox(height: 8),
                                Text(
                                  'No connection audit events recorded yet.',
                                  style: TextStyle(color: AppColors.textMutedDark),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            itemCount: logs.length,
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.borderDark,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final log = logs[index];
                              final isSuccess = log['isSuccess'] as bool? ?? true;
                              final eventType = log['type'] as String? ?? 'EVENT';
                              final message = log['message'] as String? ?? '';
                              final timestamp = log['timestamp'] as String? ?? '';

                              final eventColor = isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444);

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(top: 3),
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: eventColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: eventColor.withValues(alpha: 0.15),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  eventType,
                                                  style: TextStyle(
                                                    color: eventColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                timestamp.length > 19 ? timestamp.substring(11, 19) : timestamp,
                                                style: const TextStyle(
                                                  color: AppColors.textMutedDark,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            message,
                                            style: const TextStyle(
                                              color: AppColors.textPrimaryDark,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
      },
    );
  }

  Widget _buildMetaItem(String label, String value, Color valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textMutedDark, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(fontSize: 12, color: valueColor, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}