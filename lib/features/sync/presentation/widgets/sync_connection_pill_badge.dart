import 'package:flutter/material.dart';
import '../../domain/services/sync_connection_manager.dart';

class SyncConnectionPillBadge extends StatelessWidget {
  final SyncConnectionManager connectionManager;

  const SyncConnectionPillBadge({super.key, required this.connectionManager});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: connectionManager,
      builder: (context, _) {
        final isOnline = connectionManager.isConnected;
        final color = isOnline ? const Color(0xFF10B981) : const Color(0xFFEF4444);
        final label = isOnline
            ? 'Connected (${connectionManager.latencyMs}ms)'
            : 'Disconnected (Retrying...)';

        return InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showChangelogModal(context),
          child: Container(
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
                      BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 4, spreadRadius: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showChangelogModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        final logs = connectionManager.connectionChangelog;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Connection Lifecycle Changelog', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              Expanded(
                child: logs.isEmpty
                    ? const Center(child: Text('No connection events recorded yet.'))
                    : ListView.builder(
                        itemCount: logs.length,
                        itemBuilder: (context, index) {
                          final log = logs[index];
                          final isSuccess = log['isSuccess'] as bool;
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              isSuccess ? Icons.check_circle : Icons.error,
                              color: isSuccess ? Colors.green : Colors.red,
                              size: 20,
                            ),
                            title: Text(log['type'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${log['message']}\n${log['timestamp']}'),
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
}
