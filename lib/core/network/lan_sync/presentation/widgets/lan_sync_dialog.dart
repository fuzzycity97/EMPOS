import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_dimensions.dart';
import '../bloc/lan_sync_bloc.dart';
import '../bloc/lan_sync_event.dart';
import '../bloc/lan_sync_state.dart';

class LanSyncDialog extends StatelessWidget {
  final TextEditingController ipController;
  final TextEditingController portController;

  const LanSyncDialog._({
    super.key,
    required this.ipController,
    required this.portController,
  });

  factory LanSyncDialog({Key? key, String defaultIp = '192.168.1.10'}) {
    return LanSyncDialog._(
      key: key,
      ipController: TextEditingController(text: defaultIp),
      portController: TextEditingController(text: '9090'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        side: const BorderSide(color: AppColors.borderDark),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 680),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── DIALOG HEADER ─────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    ),
                    child: const Icon(LucideIcons.wifi, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: AppDimensions.space12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LAN Real-Time Sync Engine',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Peer-to-peer WebSocket event bus for Doctor & Reception stations',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondaryDark),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.space20),

              // ── CURRENT CONNECTION STATUS CARD ────────────────────────────
              BlocBuilder<LanSyncBloc, LanSyncState>(
                builder: (context, state) {
                  final isConnected = state is LanSyncConnected;
                  final isHost = isConnected && state.isHost;

                  Color statusColor = AppColors.textSecondaryDark;
                  String statusLabel = 'Offline / Standalone Mode';
                  IconData statusIcon = LucideIcons.wifiOff;

                  if (state is LanSyncConnecting) {
                    statusColor = AppColors.warning;
                    statusLabel = 'Connecting...';
                    statusIcon = LucideIcons.refreshCw;
                  } else if (isConnected) {
                    statusColor = isHost ? AppColors.success : AppColors.info;
                    statusLabel = isHost
                        ? 'Hub Server Active (Listening on port ${state.port})'
                        : 'Station Connected to ${state.address}';
                    statusIcon = isHost ? LucideIcons.server : LucideIcons.laptop;
                  } else if (state is LanSyncError) {
                    statusColor = AppColors.danger;
                    statusLabel = 'Error: ${state.message}';
                    statusIcon = LucideIcons.alertCircle;
                  }

                  return Container(
                    padding: const EdgeInsets.all(AppDimensions.space16),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                statusLabel,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              if (isConnected) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Active Peers: ${state.nodes.length}',
                                  style: const TextStyle(
                                    color: AppColors.textSecondaryDark,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isConnected)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger.withValues(alpha: 0.2),
                              foregroundColor: AppColors.danger,
                              elevation: 0,
                            ),
                            icon: const Icon(LucideIcons.power, size: 14),
                            label: const Text('Disconnect'),
                            onPressed: () {
                              context.read<LanSyncBloc>().add(const DisconnectLanSyncEvent());
                            },
                          ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space20),

              // ── HOST / CLIENT CONTROLS ─────────────────────────────────────
              BlocBuilder<LanSyncBloc, LanSyncState>(
                builder: (context, state) {
                  final isConnected = state is LanSyncConnected;

                  if (isConnected) {
                    // Show Connected Peers Grid
                    return Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Connected Stations in Network',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: ListView.separated(
                              itemCount: state.nodes.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 6),
                              itemBuilder: (ctx, idx) {
                                final node = state.nodes[idx];
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceElevatedDark,
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(LucideIcons.monitor, size: 16, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${node.id} (${node.role})',
                                          style: const TextStyle(color: Colors.white, fontSize: 12),
                                        ),
                                      ),
                                      Text(
                                        node.ipAddress,
                                        style: const TextStyle(
                                          color: AppColors.textSecondaryDark,
                                          fontSize: 11,
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
                  }

                  // Not connected: Show Host Server & Client Connect options
                  return Column(
                    children: [
                      // OPTION 1: Host Server
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevatedDark,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.server, size: 18, color: AppColors.primary),
                                SizedBox(width: 8),
                                Text(
                                  'Host LAN Sync Hub (Primary Reception/Server)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Spawns a local WebSocket server on port 9090 to broadcast live events across Doctor and Reception stations.',
                              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                minimumSize: const Size(double.infinity, 38),
                              ),
                              icon: const Icon(LucideIcons.play, size: 16, color: Colors.white),
                              label: const Text(
                                'Start as Host Server',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                context.read<LanSyncBloc>().add(const StartHostServerEvent(port: 9090));
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.space16),

                      // OPTION 2: Client Connect
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppDimensions.space16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevatedDark,
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(LucideIcons.laptop, size: 18, color: AppColors.info),
                                SizedBox(width: 8),
                                Text(
                                  'Connect to Existing Host (Doctor Station / Peer)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: ipController,
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                              decoration: const InputDecoration(
                                labelText: 'Host Server IP Address',
                                hintText: 'e.g. 192.168.1.100 or 127.0.0.1',
                                prefixIcon: Icon(LucideIcons.globe, size: 16),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.info,
                                minimumSize: const Size(double.infinity, 38),
                              ),
                              icon: const Icon(LucideIcons.link, size: 16, color: Colors.white),
                              label: const Text(
                                'Connect to Hub Server',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                              onPressed: () {
                                final ip = ipController.text.trim();
                                if (ip.isNotEmpty) {
                                  context.read<LanSyncBloc>().add(ConnectToHostEvent(hostIp: ip, port: 9090));
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
