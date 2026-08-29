import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../domain/entities/fleet_node.dart';
import '../../domain/repositories/rmm_repository.dart';

class DeveloperConsolePage extends StatelessWidget {
  final RmmRepository repository;
  final ValueNotifier<List<FleetNode>> nodesNotifier;
  final ValueNotifier<List<String>> logsNotifier;
  final TextEditingController commandController;
  final TextEditingController updateVersionController;

  const DeveloperConsolePage._({
    super.key,
    required this.repository,
    required this.nodesNotifier,
    required this.logsNotifier,
    required this.commandController,
    required this.updateVersionController,
  });

  factory DeveloperConsolePage({
    Key? key,
    RmmRepository? customRepository,
  }) {
    final repo = customRepository ?? sl<RmmRepository>();
    final nodesNotifier = ValueNotifier<List<FleetNode>>(repo.currentNodes);
    final logsNotifier = ValueNotifier<List<String>>([
      '[${DateTime.now().toIso8601String().substring(11, 19)}] RMM Fleet Supervisor Engine Initialized.',
      '[${DateTime.now().toIso8601String().substring(11, 19)}] Connected to local WebSocket hub gateway.',
    ]);
    final commandCtrl = TextEditingController(text: 'system.diagnostics.health_check');
    final versionCtrl = TextEditingController(text: 'v2.4.0');

    repo.fleetNodesStream.listen((nodes) {
      nodesNotifier.value = nodes;
    });

    return DeveloperConsolePage._(
      key: key,
      repository: repo,
      nodesNotifier: nodesNotifier,
      logsNotifier: logsNotifier,
      commandController: commandCtrl,
      updateVersionController: versionCtrl,
    );
  }

  void _addLog(String msg) {
    final time = DateTime.now().toIso8601String().substring(11, 19);
    logsNotifier.value = [
      '[$time] $msg',
      ...logsNotifier.value,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: const Icon(LucideIcons.terminal, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              'RMM Fleet Developer Console',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: const Text(
                'SUPERVISOR MODE',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, color: AppColors.textSecondaryDark, size: 18),
            tooltip: 'Refresh Fleet',
            onPressed: () {
              nodesNotifier.value = List.from(repository.currentNodes);
              _addLog('Manual fleet telemetry refresh requested.');
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ValueListenableBuilder<List<FleetNode>>(
        valueListenable: nodesNotifier,
        builder: (context, nodes, _) {
          final onlineCount = nodes.where((n) => n.isOnline).length;
          final offlineCount = nodes.where((n) => n.isOffline).length;
          final syncingCount = nodes.where((n) => n.isSyncing).length;

          return Padding(
            padding: const EdgeInsets.all(AppDimensions.space20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── KPI SUMMARY CARDS ───────────────────────────────────────
                Row(
                  children: [
                    _buildKpiCard(
                      title: 'TOTAL FLEET NODES',
                      value: '${nodes.length}',
                      subtitle: 'Active Hub: 192.168.1.100:9090',
                      color: AppColors.primary,
                      icon: LucideIcons.network,
                    ),
                    const SizedBox(width: 12),
                    _buildKpiCard(
                      title: 'ONLINE / ACTIVE',
                      value: '$onlineCount',
                      subtitle: 'Heartbeat response < 30ms',
                      color: AppColors.success,
                      icon: LucideIcons.wifi,
                    ),
                    const SizedBox(width: 12),
                    _buildKpiCard(
                      title: 'OFFLINE / DISCONNECTED',
                      value: '$offlineCount',
                      subtitle: 'Requires technician review',
                      color: offlineCount > 0 ? AppColors.danger : AppColors.textMutedDark,
                      icon: LucideIcons.wifiOff,
                    ),
                    const SizedBox(width: 12),
                    _buildKpiCard(
                      title: 'SYNCING PEERS',
                      value: '$syncingCount',
                      subtitle: 'Database delta replication',
                      color: AppColors.accent,
                      icon: LucideIcons.refreshCw,
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.space20),

                // ── REMOTE COMMAND & UPDATE ACTION BAR ──────────────────────
                Container(
                  padding: const EdgeInsets.all(AppDimensions.space12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevatedDark,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                    border: Border.all(color: AppColors.borderDark),
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.command, color: AppColors.primary, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: commandController,
                          style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'monospace'),
                          decoration: const InputDecoration(
                            isDense: true,
                            hintText: 'Enter remote command (e.g. system.flush_cache, db.vacuum)...',
                            hintStyle: TextStyle(color: AppColors.textMutedDark, fontSize: 12),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final cmd = commandController.text.trim();
                          if (cmd.isNotEmpty) {
                            await repository.sendRemoteCommand('*', cmd);
                            _addLog('Broadcast command dispatched: "$cmd" to all fleet nodes.');
                          }
                        },
                        icon: const Icon(LucideIcons.send, size: 14),
                        label: const Text('Broadcast Command'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final ver = updateVersionController.text.trim();
                          await repository.pushSoftwareUpdate(ver);
                          _addLog('OTA Update deployment broadcast triggered for version $ver.');
                        },
                        icon: const Icon(LucideIcons.arrowUpCircle, size: 14),
                        label: const Text('Push OTA Update'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppDimensions.space20),

                // ── FLEET NODES DATA TABLE ──────────────────────────────────
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.borderDark)),
                          ),
                          child: const Row(
                            children: [
                              Icon(LucideIcons.server, color: AppColors.primary, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'REGISTERED FLEET STATIONS & GATEWAYS',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ListView.separated(
                            itemCount: nodes.length,
                            separatorBuilder: (_, _) => const Divider(height: 1, color: AppColors.borderDark),
                            itemBuilder: (context, index) {
                              final node = nodes[index];
                              return _buildNodeRow(node);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: AppDimensions.space16),

                // ── DIAGNOSTIC CONSOLE STREAM ───────────────────────────────
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: AppColors.borderDark)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(LucideIcons.terminal, color: AppColors.success, size: 14),
                                  SizedBox(width: 8),
                                  Text(
                                    'RMM LIVE TELEMETRY & AUDIT STREAM',
                                    style: TextStyle(
                                      color: AppColors.textSecondaryDark,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                              TextButton(
                                onPressed: () => logsNotifier.value = [],
                                child: const Text('Clear Console', style: TextStyle(fontSize: 11, color: AppColors.textMutedDark)),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: ValueListenableBuilder<List<String>>(
                            valueListenable: logsNotifier,
                            builder: (context, logs, _) {
                              return ListView.builder(
                                padding: const EdgeInsets.all(12),
                                itemCount: logs.length,
                                itemBuilder: (context, idx) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2),
                                    child: Text(
                                      logs[idx],
                                      style: const TextStyle(
                                        color: Color(0xFF38BDF8),
                                        fontSize: 11.5,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNodeRow(FleetNode node) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Status indicator dot
          _buildStatusDot(node.status),
          const SizedBox(width: 12),

          // Node ID & Branch
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.id,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  node.branchName,
                  style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
                ),
              ],
            ),
          ),

          // Role badge
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevatedDark,
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: AppColors.borderDark),
              ),
              child: Text(
                node.role.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondaryDark,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // IP Address
          Expanded(
            flex: 2,
            child: Text(
              node.ipAddress,
              style: const TextStyle(
                color: AppColors.textSecondaryDark,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),

          // Latency & Last Heartbeat
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${node.latencyMs} ms',
                  style: TextStyle(
                    color: node.latencyMs < 20 ? AppColors.success : AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                Text(
                  'Seen ${DateTime.now().difference(node.lastHeartbeat).inSeconds}s ago',
                  style: const TextStyle(color: AppColors.textMutedDark, fontSize: 10.5),
                ),
              ],
            ),
          ),

          // Action Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              OutlinedButton.icon(
                onPressed: () async {
                  final ms = await repository.pingNode(node.id);
                  _addLog('PING response from ${node.id} (${node.ipAddress}): $ms ms.');
                },
                icon: const Icon(LucideIcons.activity, size: 13),
                label: const Text('Ping', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: AppColors.borderDark),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await repository.forceDbSync(node.id);
                  _addLog('FORCE SYNC command dispatched to node ${node.id}.');
                },
                icon: const Icon(LucideIcons.refreshCw, size: 13),
                label: const Text('Sync DB', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  await repository.restartNode(node.id);
                  _addLog('RESTART order sent to node ${node.id}.');
                },
                icon: const Icon(LucideIcons.power, size: 13),
                label: const Text('Restart', style: TextStyle(fontSize: 11)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDot(FleetNodeStatus status) {
    final color = status == FleetNodeStatus.online
        ? AppColors.success
        : status == FleetNodeStatus.syncing
            ? AppColors.accent
            : AppColors.danger;

    return Container(
      width: 10,
      height: 10,
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
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppDimensions.space16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevatedDark,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondaryDark,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, color: color, size: 16),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.outfit(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
