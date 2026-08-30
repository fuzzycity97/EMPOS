import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_dimensions.dart';
import '../../domain/entities/connected_node.dart';
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
      child: Container(
        width: 620,
        height: 600,
        padding: const EdgeInsets.all(AppDimensions.space24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        const Text(
                          'LAN Real-Time Sync Engine',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Peer-to-peer WebSocket event bus for Doctor, Reception & POS stations',
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
                  String statusTitle = 'Offline / Standalone Mode';
                  String statusSubtitle = 'Local database active. Connect to host or start server to sync.';
                  IconData statusIcon = LucideIcons.wifiOff;

                  if (state is LanSyncConnecting) {
                    statusColor = AppColors.warning;
                    statusTitle = 'Connecting to ${state.targetAddress ?? 'Host'}...';
                    statusSubtitle = 'Verifying WebSocket connection and peer handshake...';
                    statusIcon = LucideIcons.refreshCw;
                  } else if (isConnected) {
                    if (isHost) {
                      statusColor = AppColors.success;
                      statusTitle = 'Hub Server Active (Listening on port ${state.port})';
                      final clientCount = state.nodes.where((n) => !n.role.toLowerCase().contains('host')).length;
                      statusSubtitle = 'Host LAN IP: ${state.address} • Connected Client Stations: $clientCount';
                      statusIcon = LucideIcons.server;
                    } else {
                      statusColor = AppColors.info;
                      statusTitle = 'Station Connected to ${state.address}:${state.port}';
                      final idDisplay = state.localStationId.isNotEmpty ? state.localStationId : 'Doctor';
                      final roleDisplay = state.localStationRole.isNotEmpty ? state.localStationRole : 'Doctor Station';
                      statusSubtitle = 'Local Station: $idDisplay ($roleDisplay) • ${state.nodes.length} Network Nodes Active';
                      statusIcon = LucideIcons.laptop;
                    }
                  } else if (state is LanSyncError) {
                    statusColor = AppColors.danger;
                    statusTitle = 'Connection Error';
                    statusSubtitle = state.message;
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
                        Icon(statusIcon, color: statusColor, size: 22),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                statusTitle,
                                style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                statusSubtitle,
                                style: const TextStyle(
                                  color: AppColors.textSecondaryDark,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (isConnected || state is LanSyncConnecting) ...[
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.danger.withValues(alpha: 0.2),
                              foregroundColor: AppColors.danger,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            icon: const Icon(LucideIcons.power, size: 14),
                            label: Text(isHost ? 'Stop Server' : 'Disconnect'),
                            onPressed: () {
                              context.read<LanSyncBloc>().add(const DisconnectLanSyncEvent());
                            },
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.space20),

              // ── HOST / CLIENT CONTROLS & PEERS LIST ───────────────────────
              Expanded(
                child: BlocBuilder<LanSyncBloc, LanSyncState>(
                  builder: (context, state) {
                    if (state is LanSyncConnected) {
                      // Filter stations: for host, show client stations primarily; for client show all network nodes
                      final isHost = state.isHost;
                      final displayNodes = isHost
                          ? state.nodes.where((n) => !n.role.toLowerCase().contains('host')).toList()
                          : state.nodes;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  isHost
                                      ? 'Connected Client Stations (${displayNodes.length})'
                                      : 'Connected Stations in Network (${displayNodes.length})',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.success.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: AppColors.success,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      isHost ? 'Hub Host Mode' : 'Station Connected',
                                      style: const TextStyle(
                                        color: AppColors.success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: displayNodes.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          LucideIcons.radio,
                                          size: 32,
                                          color: AppColors.textSecondaryDark.withValues(alpha: 0.5),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          isHost
                                              ? 'No client stations connected yet.'
                                              : 'Waiting for network nodes...',
                                          style: const TextStyle(
                                            color: AppColors.textSecondaryDark,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          isHost
                                              ? 'Have Doctor / POS stations connect to ${state.address}:${state.port}'
                                              : 'Listening for live synchronization events from Hub Server.',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: AppColors.textSecondaryDark.withValues(alpha: 0.7),
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: displayNodes.length,
                                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                                    itemBuilder: (ctx, idx) {
                                      final node = displayNodes[idx];
                                      return _StationNodeCard(node: node);
                                    },
                                  ),
                          ),
                        ],
                      );
                    }

                    // Not connected: Show Host Server & Client Connect options
                    return SingleChildScrollView(
                      child: Column(
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
                                    Expanded(
                                      child: Text(
                                        'Start as Central Hub Host (Reception / Server)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
                                    Expanded(
                                      child: Text(
                                        'Connect to Existing Host (Doctor Station / Peer)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
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
}

class _StationNodeCard extends StatelessWidget {
  final ConnectedNode node;

  const _StationNodeCard({required this.node});

  @override
  Widget build(BuildContext context) {
    final isHostNode = node.role.toLowerCase().contains('host');
    final isDoctor = node.role.toLowerCase().contains('doc') || node.id.toLowerCase().contains('doc');

    final badgeColor = isHostNode
        ? AppColors.primary
        : (isDoctor ? AppColors.success : AppColors.info);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            ),
            child: Icon(
              isHostNode ? LucideIcons.server : LucideIcons.monitor,
              size: 16,
              color: badgeColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        node.id,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        node.role,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'IP: ${node.ipAddress}',
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.checkCircle2, size: 12, color: AppColors.success),
                SizedBox(width: 4),
                Text(
                  'Online',
                  style: TextStyle(color: AppColors.success, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
