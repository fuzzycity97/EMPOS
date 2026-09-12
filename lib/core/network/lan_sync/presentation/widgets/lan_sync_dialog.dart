import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_dimensions.dart';
import '../../data/services/lan_discovery_service.dart';
import '../../domain/entities/connected_node.dart';
import '../../domain/repositories/lan_sync_repository.dart';
import '../bloc/lan_sync_bloc.dart';
import '../bloc/lan_sync_event.dart';
import '../bloc/lan_sync_state.dart';

class LanSyncDialog extends StatefulWidget {
  final String defaultIp;
  final String defaultPort;

  const LanSyncDialog({
    super.key,
    this.defaultIp = '192.168.1.10',
    this.defaultPort = '9090',
  });

  @override
  State<LanSyncDialog> createState() => _LanSyncDialogState();
}

class _LanSyncDialogState extends State<LanSyncDialog> {
  late final TextEditingController _ipController;
  late final TextEditingController _portController;
  String? _ipValidationError;
  LanSyncRepository? _repository;

  @override
  void initState() {
    super.initState();
    _ipController = TextEditingController(text: widget.defaultIp);
    _portController = TextEditingController(text: widget.defaultPort);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      try {
        _repository = context.read<LanSyncBloc>().lanSyncRepository;
        _repository?.startDiscoveryScanner();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    try {
      _repository?.stopDiscoveryScanner();
    } catch (_) {}
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  String? _validateIp(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return 'IP address cannot be empty.';
    }
    final parts = trimmed.split('.');
    if (parts.length != 4) {
      return 'Enter a valid IPv4 address (e.g. 192.168.1.50 or 127.0.0.1).';
    }
    for (final part in parts) {
      final num = int.tryParse(part);
      if (num == null || num < 0 || num > 255) {
        return 'Each part must be a number between 0 and 255.';
      }
    }
    return null;
  }

  void _handleConnect(BuildContext context) {
    final ip = _ipController.text.trim();
    final validation = _validateIp(ip);
    if (validation != null) {
      setState(() {
        _ipValidationError = validation;
      });
      return;
    }
    setState(() {
      _ipValidationError = null;
    });

    final port = int.tryParse(_portController.text.trim()) ?? 9090;
    context.read<LanSyncBloc>().add(ConnectToHostEvent(hostIp: ip, port: port));
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
        width: 640,
        constraints: const BoxConstraints(maxHeight: 700),
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
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'LAN Real-Time Sync Engine',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
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
            const SizedBox(height: AppDimensions.space16),

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
                  statusSubtitle = 'Performing TCP diagnostic ping and WebSocket handshake...';
                  statusIcon = LucideIcons.refreshCw;
                } else if (isConnected) {
                  if (isHost) {
                    statusColor = AppColors.success;
                    statusTitle = 'Hub Server Active (Listening on port ${state.port})';
                    final clientCount = state.nodes.where((n) => !n.role.toLowerCase().contains('host')).length;
                    statusSubtitle = 'Host LAN IP: ${state.address} • Connected Client Stations: $clientCount • UDP Discovery Beacon Active (Port 9091)';
                    statusIcon = LucideIcons.server;
                  } else {
                    statusColor = AppColors.info;
                    statusTitle = 'Station Connected to ${state.address}:${state.port}';
                    final idDisplay = state.localStationId.isNotEmpty ? state.localStationId : 'Station';
                    final roleDisplay = state.localStationRole.isNotEmpty ? state.localStationRole : 'Client Station';
                    statusSubtitle = 'Local Station: $idDisplay ($roleDisplay) • ${state.nodes.length} Network Nodes Active • Heartbeat Active';
                    statusIcon = LucideIcons.laptop;
                  }
                } else if (state is LanSyncError) {
                  statusColor = AppColors.danger;
                  statusTitle = state.failedIp != null
                      ? 'Cannot Reach Server (${state.failedIp})'
                      : 'Connection Error';
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
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (state is LanSyncError &&
                                (state.message.contains('10048') ||
                                 state.message.contains('already in use') ||
                                 state.message.contains('Port')))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.info,
                                    side: const BorderSide(color: AppColors.info),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  ),
                                  icon: const Icon(LucideIcons.link, size: 12),
                                  label: const Text(
                                    'Connect as Client to Local Host (127.0.0.1:9090)',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () {
                                    _ipController.text = '127.0.0.1';
                                    _portController.text = '9090';
                                    context.read<LanSyncBloc>().add(
                                      const ConnectToHostEvent(hostIp: '127.0.0.1', port: 9090),
                                    );
                                  },
                                ),
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
            const SizedBox(height: AppDimensions.space16),

            // ── HOST / CLIENT CONTROLS & PEERS LIST ───────────────────────
            Expanded(
              child: BlocBuilder<LanSyncBloc, LanSyncState>(
                builder: (context, state) {
                  if (state is LanSyncConnected) {
                    final isHost = state.isHost;
                    final rawNodes = isHost
                        ? state.nodes.where((n) {
                            final r = n.role.toLowerCase();
                            final id = n.id.toLowerCase();
                            return !r.contains('host') &&
                                !r.contains('god') &&
                                !r.contains('technician hub') &&
                                id != state.localStationId.toLowerCase() &&
                                id != 'god-mode-hub' &&
                                id != 'host-server';
                          }).toList()
                        : state.nodes;

                    final seen = <String>{};
                    final displayNodes = <ConnectedNode>[];
                    for (final node in rawNodes) {
                      final id = node.id.toLowerCase();
                      if (!seen.contains(id)) {
                        seen.add(id);
                        displayNodes.add(node);
                      }
                    }

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
                                            ? 'Have Doctor / POS stations connect to ${state.address}:${state.port}\nAuto-discovery beacon broadcasting on port 9091'
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

                  // Not connected: Show Host Server, Auto-Discovery & Manual Client Connect options
                  final isConnecting = state is LanSyncConnecting;
                  final repo = _repository ?? context.read<LanSyncBloc>().lanSyncRepository;

                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                                'Spawns a WebSocket server on port 9090 with UDP broadcast on port 9091 so client stations find this host automatically.',
                                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  minimumSize: const Size(double.infinity, 38),
                                ),
                                icon: isConnecting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(LucideIcons.play, size: 16, color: Colors.white),
                                label: const Text(
                                  'Start as Host Server',
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                onPressed: isConnecting
                                    ? null
                                    : () {
                                        context.read<LanSyncBloc>().add(const StartHostServerEvent(port: 9090));
                                      },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppDimensions.space16),

                        // OPTION 2: Auto-Discovery Scanner
                        StreamBuilder<List<DiscoveredHost>>(
                          stream: repo.discoveredHostsStream,
                          initialData: repo.discoveredHosts,
                          builder: (context, snapshot) {
                            final discovered = snapshot.data ?? [];
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(AppDimensions.space16),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceElevatedDark,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                border: Border.all(
                                  color: discovered.isNotEmpty
                                      ? AppColors.success.withValues(alpha: 0.4)
                                      : AppColors.borderDark,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        LucideIcons.radio,
                                        size: 18,
                                        color: discovered.isNotEmpty ? AppColors.success : AppColors.info,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Auto-Discovered LAN Servers (${discovered.length})',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 10,
                                            height: 10,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: discovered.isNotEmpty ? AppColors.success : AppColors.info,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            discovered.isNotEmpty ? 'Active' : 'Scanning...',
                                            style: const TextStyle(
                                              color: AppColors.textSecondaryDark,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  if (discovered.isEmpty)
                                    const Text(
                                      'Listening on Wi-Fi broadcast port 9091. When an EMPOS Host Server is active on this network, it will appear here automatically for 1-tap connection.',
                                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                                    )
                                  else ...[
                                    const Text(
                                      'Found EMPOS Host Server on local network:',
                                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                                    ),
                                    const SizedBox(height: 8),
                                    ...discovered.map((host) => Container(
                                          margin: const EdgeInsets.only(bottom: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceDark,
                                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(6),
                                                decoration: BoxDecoration(
                                                  color: AppColors.success.withValues(alpha: 0.15),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(LucideIcons.server, size: 14, color: AppColors.success),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      host.id,
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${host.role} • ${host.ip}:${host.port}',
                                                      style: const TextStyle(
                                                        color: AppColors.textSecondaryDark,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: AppColors.success,
                                                  foregroundColor: Colors.white,
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                  minimumSize: const Size(80, 32),
                                                ),
                                                icon: const Icon(LucideIcons.zap, size: 12),
                                                label: const Text(
                                                  '1-Tap Connect',
                                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                ),
                                                onPressed: isConnecting
                                                    ? null
                                                    : () {
                                                        _ipController.text = host.ip;
                                                        _portController.text = host.port.toString();
                                                        context.read<LanSyncBloc>().add(
                                                              ConnectToHostEvent(hostIp: host.ip, port: host.port),
                                                            );
                                                      },
                                              ),
                                            ],
                                          ),
                                        )),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.space16),

                        // OPTION 3: Manual Client Connect
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppDimensions.space16),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevatedDark,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            border: Border.all(
                              color: state is LanSyncError
                                  ? AppColors.danger.withValues(alpha: 0.6)
                                  : AppColors.borderDark,
                            ),
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
                                      'Manual Connect to Host IP',
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
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: TextField(
                                      controller: _ipController,
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                      decoration: InputDecoration(
                                        labelText: 'Host Server IP Address',
                                        hintText: 'e.g. 192.168.1.100 or 127.0.0.1',
                                        prefixIcon: const Icon(LucideIcons.globe, size: 16),
                                        errorText: _ipValidationError,
                                      ),
                                      onChanged: (_) {
                                        if (_ipValidationError != null) {
                                          setState(() {
                                            _ipValidationError = null;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    flex: 1,
                                    child: TextField(
                                      controller: _portController,
                                      style: const TextStyle(color: Colors.white, fontSize: 13),
                                      decoration: const InputDecoration(
                                        labelText: 'Port',
                                        hintText: '9090',
                                        prefixIcon: Icon(LucideIcons.hash, size: 16),
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Diagnostic Error Box when connection fails
                              if (state is LanSyncError) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.5)),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.triangleAlert, size: 16, color: AppColors.danger),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              state.failedIp != null
                                                  ? 'No Server at ${state.failedIp}:${_portController.text.trim()}'
                                                  : 'Host Connection Failed',
                                              style: const TextStyle(
                                                color: AppColors.danger,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        state.message,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 11,
                                          height: 1.3,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(color: AppColors.borderDark, height: 1),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Diagnostic Troubleshooting Checklist:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      _buildTroubleshootItem('1. Ensure the Host device is running and clicked "Start as Host Server".'),
                                      _buildTroubleshootItem('2. Verify both devices are connected to the SAME Wi-Fi or LAN subnet.'),
                                      _buildTroubleshootItem('3. Verify the IP address matches what is shown on the Host screen.'),
                                      _buildTroubleshootItem('4. Ensure Windows/OS Firewall allows incoming TCP port 9090.'),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton.icon(
                                            style: TextButton.styleFrom(
                                              foregroundColor: AppColors.danger,
                                              visualDensity: VisualDensity.compact,
                                            ),
                                            icon: const Icon(LucideIcons.refreshCw, size: 12),
                                            label: const Text(
                                              'Retry Connection',
                                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                            onPressed: () => _handleConnect(context),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],

                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.info,
                                  minimumSize: const Size(double.infinity, 38),
                                ),
                                icon: isConnecting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(LucideIcons.link, size: 16, color: Colors.white),
                                label: Text(
                                  isConnecting ? 'Connecting...' : 'Connect to Hub Server',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                onPressed: isConnecting ? null : () => _handleConnect(context),
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

  static Widget _buildTroubleshootItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 10)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 10),
            ),
          ),
        ],
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
