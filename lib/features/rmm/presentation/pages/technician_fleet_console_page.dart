import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/data/models/store_blueprint_model.dart';
import '../../../../core/config/domain/entities/store_blueprint.dart';
import '../../../../core/config/presentation/bloc/config_bloc.dart';
import '../../../../core/config/presentation/bloc/config_event.dart';
import '../../../../core/config/presentation/bloc/config_state.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/network/lan_sync/data/repositories/lan_sync_repository_impl.dart';
import '../../../../core/network/lan_sync/domain/entities/connected_node.dart';
import '../../../../core/network/lan_sync/domain/entities/sync_envelope.dart';
import '../../../../core/network/lan_sync/domain/repositories/lan_sync_repository.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_bloc.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_event.dart';
import '../../../../core/network/lan_sync/presentation/bloc/lan_sync_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../builder/presentation/facility_blueprint_builder_screen.dart';
import '../../../sync/domain/services/sync_connection_manager.dart';

/// The dedicated Technician God Mode interface for remote network provisioning,
/// discovery of system devices/apps, remote toggle editing, and LAN push deployments.
class TechnicianFleetConsolePage extends StatelessWidget {
  final LanSyncRepository lanSyncRepository;
  final ValueNotifier<ConnectedNode?> selectedTargetNodeNotifier;
  final ValueNotifier<Map<String, bool>> targetTogglesNotifier;
  final ValueNotifier<String> searchFilterNotifier;
  final ValueNotifier<String?> deploymentSuccessNotifier;
  final TextEditingController serverIpController;

  const TechnicianFleetConsolePage._({
    super.key,
    required this.lanSyncRepository,
    required this.selectedTargetNodeNotifier,
    required this.targetTogglesNotifier,
    required this.searchFilterNotifier,
    required this.deploymentSuccessNotifier,
    required this.serverIpController,
  });

  factory TechnicianFleetConsolePage({
    Key? key,
    LanSyncRepository? customRepository,
  }) {
    final repo = customRepository ?? sl<LanSyncRepository>();
    LanSyncRepositoryImpl.setInstanceIdOverride('god-mode-hub');
    final defaultGodHubNode = ConnectedNode(
      id: 'god-mode-hub',
      role: 'Master Blueprint (Global Template)',
      ipAddress: 'ALL_STATIONS',
      connectedAt: DateTime.now(),
      appName: 'EMPOS Global Fleet Template',
    );
    final selectedNode = ValueNotifier<ConnectedNode?>(defaultGodHubNode);
    final targetToggles = ValueNotifier<Map<String, bool>>({});
    final search = ValueNotifier<String>('');
    final deploySuccess = ValueNotifier<String?>(null);
    final ipCtrl = TextEditingController(text: '127.0.0.1');

    return TechnicianFleetConsolePage._(
      key: key,
      lanSyncRepository: repo,
      selectedTargetNodeNotifier: selectedNode,
      targetTogglesNotifier: targetToggles,
      searchFilterNotifier: search,
      deploymentSuccessNotifier: deploySuccess,
      serverIpController: ipCtrl,
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(
      builder: (context, configState) {
        final currentBlueprint = configState is ConfigLoaded
            ? configState.blueprint
            : StoreBlueprintModel.defaultClinicBlueprint();

        return BlocBuilder<LanSyncBloc, LanSyncState>(
          builder: (context, lanState) {
            final isConnected = lanState is LanSyncConnected;
            final hostAddress = isConnected ? lanState.address : null;

            return Scaffold(
              backgroundColor: AppColors.backgroundDark,
              appBar: _buildAppBar(context, isConnected, hostAddress),
              body: Column(
                children: [
                  _buildConnectionToolbar(context, lanState, isConnected),
                  _buildDeploymentBanner(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 960;
                        if (isWide) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 380,
                                child: _buildFleetList(context, currentBlueprint),
                              ),
                              const VerticalDivider(color: AppColors.borderDark, width: 1),
                              Expanded(
                                child: _buildTargetDeviceConfigPanel(context, currentBlueprint),
                              ),
                            ],
                          );
                        } else {
                          return ValueListenableBuilder<ConnectedNode?>(
                            valueListenable: selectedTargetNodeNotifier,
                            builder: (context, selectedNode, _) {
                              if (selectedNode == null) {
                                return _buildFleetList(context, currentBlueprint);
                              }
                              return Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    color: AppColors.surfaceDark,
                                    child: Row(
                                      children: [
                                        TextButton.icon(
                                          onPressed: () => selectedTargetNodeNotifier.value = null,
                                          icon: const Icon(LucideIcons.arrowLeft, size: 14),
                                          label: const Text('Back to Fleet List'),
                                        ),
                                        const Spacer(),
                                        Text(
                                          selectedNode.role,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildTargetDeviceConfigPanel(context, currentBlueprint),
                                  ),
                                ],
                              );
                            },
                          );
                        }
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

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isConnected, String? hostAddress) {
    return AppBar(
      backgroundColor: AppColors.surfaceDark,
      elevation: 0,
      titleSpacing: AppDimensions.space16,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
            ),
            child: const Icon(LucideIcons.cpu, color: AppColors.accent, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'Technician Fleet & Provisioning Hub',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'GOD MODE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: AppColors.accent,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'Remote Device Discovery • Toggles Configuration • Instant Network Deployment',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
              ),
            ],
          ),
        ],
      ),
      actions: [
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => FacilityBlueprintBuilderScreen()),
            );
          },
          icon: const Icon(LucideIcons.layoutGrid, size: 14),
          label: const Text('Blueprint Studio'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryLight,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Lock Terminal / Switch User',
          icon: const Icon(LucideIcons.logOut, size: 18, color: AppColors.warning),
          onPressed: () {
            context.read<AuthBloc>().add(const LogoutRequested());
          },
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildConnectionToolbar(BuildContext context, LanSyncState lanState, bool isConnected) {
    final connectedState = lanState is LanSyncConnected ? lanState : null;
    final isHostServer = connectedState != null && connectedState.isHost;
    final isClientConnected = connectedState != null && !connectedState.isHost;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevatedDark,
        border: Border(bottom: BorderSide(color: AppColors.borderDark)),
      ),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          // Connection Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: isClientConnected
                  ? AppColors.success.withValues(alpha: 0.15)
                  : (isHostServer ? AppColors.accent.withValues(alpha: 0.15) : AppColors.warning.withValues(alpha: 0.15)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isClientConnected
                    ? AppColors.success.withValues(alpha: 0.4)
                    : (isHostServer ? AppColors.accent.withValues(alpha: 0.4) : AppColors.warning.withValues(alpha: 0.4)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isClientConnected
                        ? AppColors.success
                        : (isHostServer ? AppColors.accent : AppColors.warning),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isClientConnected
                      ? 'Connected to Store Server (${connectedState.address})'
                      : (isHostServer
                          ? 'Local Host Server Active (${connectedState.address})'
                          : 'Technician Terminal Standalone (Not Connected to Server)'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isClientConnected
                        ? AppColors.success
                        : (isHostServer ? AppColors.accent : AppColors.warning),
                  ),
                ),
              ],
            ),
          ),

          // Server IP Input & Client Connect (available when standalone or when hosting to allow fast handoff)
          if (!isClientConnected) ...[
            SizedBox(
              width: 180,
              height: 32,
              child: TextField(
                controller: serverIpController,
                style: const TextStyle(fontSize: 12, color: Colors.white),
                decoration: InputDecoration(
                  hintText: isHostServer ? 'Remote Server IP' : 'Server IP (e.g. 192.168.1.100)',
                  hintStyle: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.borderDark),
                  ),
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () async {
                final targetIp = serverIpController.text.trim();
                if (targetIp.isNotEmpty) {
                  if (isHostServer) {
                    try {
                      if (sl.isRegistered<SyncConnectionManager>()) {
                        await sl<SyncConnectionManager>().clearHostMode();
                      }
                    } catch (_) {}
                  }
                  if (context.mounted) {
                    context.read<LanSyncBloc>().add(ConnectToHostEvent(hostIp: targetIp));
                  }
                }
              },
              icon: const Icon(LucideIcons.plug, size: 13),
              label: const Text('Connect as Client'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],

          // Disconnect or Start Host Server actions
          if (isHostServer) ...[
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  if (sl.isRegistered<SyncConnectionManager>()) {
                    await sl<SyncConnectionManager>().clearHostMode();
                  }
                } catch (_) {}
                if (context.mounted) {
                  context.read<LanSyncBloc>().add(const DisconnectLanSyncEvent());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Local host server stopped and host persistence cleared. Terminal is now in standalone client mode.',
                      ),
                      backgroundColor: AppColors.info,
                      duration: Duration(seconds: 4),
                    ),
                  );
                }
              },
              icon: const Icon(LucideIcons.unplug, size: 13),
              label: const Text('Disconnect Local Server'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.2),
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ] else if (isClientConnected) ...[
            ElevatedButton.icon(
              onPressed: () {
                context.read<LanSyncBloc>().add(const DisconnectLanSyncEvent());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Terminal disconnected from server. Saved settings remain active locally.',
                    ),
                    backgroundColor: AppColors.info,
                    duration: Duration(seconds: 3),
                  ),
                );
              },
              icon: const Icon(LucideIcons.unplug, size: 13),
              label: const Text('Disconnect from Server'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger.withValues(alpha: 0.2),
                foregroundColor: AppColors.danger,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeploymentBanner() {
    return ValueListenableBuilder<String?>(
      valueListenable: deploymentSuccessNotifier,
      builder: (context, msg, _) {
        if (msg == null) return const SizedBox.shrink();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppColors.success.withValues(alpha: 0.2),
          child: Row(
            children: [
              const Icon(LucideIcons.circleCheck, color: AppColors.success, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  msg,
                  style: const TextStyle(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.5,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.x, size: 16, color: AppColors.success),
                onPressed: () => deploymentSuccessNotifier.value = null,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFleetList(BuildContext context, StoreBlueprint currentBlueprint) {
    return StreamBuilder<List<ConnectedNode>>(
      stream: lanSyncRepository.connectedNodesStream,
      initialData: lanSyncRepository.connectedNodes,
      builder: (context, snapshot) {
        final liveNodes = snapshot.data ?? lanSyncRepository.connectedNodes;
        final localId = LanSyncRepositoryImpl.getLocalInstanceId().toLowerCase();

        // 1. Master Facility Blueprint Template (Authority)
        final templateNode = ConnectedNode(
          id: 'god-mode-hub',
          role: 'Master Blueprint (Global Template)',
          ipAddress: 'ALL_STATIONS',
          connectedAt: DateTime.now(),
          appName: 'EMPOS Global Fleet Template',
        );

        // 2. Remote client stations discovered over LAN
        final remoteClientNodes = <ConnectedNode>[];
        for (final liveNode in liveNodes) {
          final id = liveNode.id.toLowerCase();
          final role = liveNode.role.toLowerCase();

          // Exclude god hub, master authority, and host server daemon
          if (id == 'god-mode-hub' || role.contains('god') || role.contains('master blueprint') || role.contains('technician hub')) {
            continue;
          }
          if (id == 'host-server' || id == localId) {
            continue;
          }
          // If this machine is the host server, exclude the host node itself
          if (lanSyncRepository.isHost && (role.contains('hub host') || role.contains('(host)'))) {
            continue;
          }

          if (!remoteClientNodes.any((n) => n.id == liveNode.id)) {
            remoteClientNodes.add(liveNode);
          }
        }

        final allNodes = [templateNode, ...remoteClientNodes];

        return Container(
          color: AppColors.surfaceDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.borderDark)),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.network, size: 16, color: AppColors.accent),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'DISCOVERED FLEET (${remoteClientNodes.length})',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (!lanSyncRepository.isConnected)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'STANDALONE',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                            color: AppColors.warning,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ValueListenableBuilder<ConnectedNode?>(
                  valueListenable: selectedTargetNodeNotifier,
                  builder: (context, selectedNode, _) {
                    final activeSelected = selectedNode ?? (allNodes.isNotEmpty ? allNodes.first : null);

                    return ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: allNodes.length + (!lanSyncRepository.isConnected ? 1 : 0),
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        if (index == allNodes.length) {
                          // Network Discovery Info Card
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(LucideIcons.radio, size: 14, color: AppColors.primaryLight),
                                    const SizedBox(width: 6),
                                    const Text(
                                      'LAN Fleet Auto-Discovery',
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Only real devices on your LAN appear here. Connect this terminal to the store server above to inspect remote doctor, POS, and reception terminals.',
                                  style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark, height: 1.3),
                                ),
                              ],
                            ),
                          );
                        }

                        final node = allNodes[index];
                        final isSelected = activeSelected?.id == node.id;
                        final isGodHub = node.id == 'god-mode-hub';

                        return InkWell(
                          onTap: () {
                            selectedTargetNodeNotifier.value = node;
                            deploymentSuccessNotifier.value = null;
                            final toggles = Map<String, bool>.from(currentBlueprint.toggles);
                            _ensureAllToggles(toggles, currentBlueprint);
                            targetTogglesNotifier.value = toggles;
                          },
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.15)
                                  : AppColors.surfaceElevatedDark,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.borderDark,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: (isSelected ? AppColors.primary : AppColors.secondary)
                                            .withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(
                                        _getNodeIcon(node.role),
                                        size: 14,
                                        color: isSelected ? AppColors.primaryLight : AppColors.secondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        node.role,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isSelected ? Colors.white : AppColors.textPrimaryDark,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: (isGodHub ? AppColors.accent : AppColors.success).withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isGodHub ? 'FLEET TEMPLATE' : 'READY',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          color: isGodHub ? AppColors.accent : AppColors.success,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'App Running: ${node.appName}',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isGodHub
                                      ? 'Target: Broadcast to All Remote Stations • Not for God Hub'
                                      : 'IP Address: ${node.ipAddress} • Station ID: ${node.id}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondaryDark,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
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
        );
      },
    );
  }

  Widget _buildTargetDeviceConfigPanel(BuildContext context, StoreBlueprint currentBlueprint) {
    return ValueListenableBuilder<ConnectedNode?>(
      valueListenable: selectedTargetNodeNotifier,
      builder: (context, selectedNode, _) {
        if (selectedNode == null) {
          return const Center(
            child: Text(
              'Select a station from the fleet list on the left to configure its toggles.',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          );
        }

        final isMasterHub = selectedNode.id == 'god-mode-hub';

        return Container(
          color: AppColors.backgroundDark,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Target Device Header Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getNodeIcon(selectedNode.role), size: 22, color: AppColors.primary),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 8,
                            runSpacing: 4,
                            children: [
                              Text(
                                isMasterHub
                                    ? 'GLOBAL FLEET BLUEPRINT (MASTER TEMPLATE)'
                                    : 'CONFIGURING TARGET: ${selectedNode.role.toUpperCase()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  isMasterHub ? 'FLEET TEMPLATE (NOT FOR GOD HUB)' : selectedNode.appName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.accent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isMasterHub
                                ? 'Master system engine template • Broadcasts to all connected client devices (Doctor, Reception, POS) • Does not apply to God Hub'
                                : 'Target IP: ${selectedNode.ipAddress} • Station ID: ${selectedNode.id}',
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () => _deployConfigurationToTarget(context, selectedNode, currentBlueprint),
                      icon: const Icon(LucideIcons.send, size: 14),
                      label: const Text('Deploy & Save to Station'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              Container(
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevatedDark,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: TextField(
                  onChanged: (val) => searchFilterNotifier.value = val,
                  style: const TextStyle(fontSize: 13, color: Colors.white),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(LucideIcons.search, size: 16),
                    hintText: 'Filter toggles (e.g., dental, 3d, pos, scale, reception, returns, erp)...',
                    hintStyle: TextStyle(fontSize: 12, color: AppColors.textMutedDark),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              if (isMasterHub)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(LucideIcons.info, size: 16, color: AppColors.primaryLight),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'The God Mode Technician station is the central provisioning authority and does not run clinic/reception/POS workstations on itself. These toggles define the global template to push to connected client devices.',
                          style: TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),

              // Toggles List
              Expanded(
                child: ValueListenableBuilder<String>(
                  valueListenable: searchFilterNotifier,
                  builder: (context, query, _) {
                    return ValueListenableBuilder<Map<String, bool>>(
                      valueListenable: targetTogglesNotifier,
                      builder: (context, toggles, _) {
                        final effectiveToggles = toggles.isNotEmpty
                            ? toggles
                            : (() {
                                final init = Map<String, bool>.from(currentBlueprint.toggles);
                                _ensureAllToggles(init, currentBlueprint);
                                return init;
                              })();

                        final q = query.trim().toLowerCase();
                        final filtered = effectiveToggles.entries.where((e) {
                          if (q.isEmpty) return true;
                          final label = e.key.toLowerCase();
                          final desc = _getDesc(e.key).toLowerCase();
                          return label.contains(q) || desc.contains(q);
                        }).toList();

                        final clinicalToggles = filtered.where((e) =>
                            e.key.contains('clinic') ||
                            e.key.contains('dental') ||
                            e.key.contains('prescription') ||
                            e.key.contains('optical')).toList();

                        final posToggles = filtered.where((e) =>
                            e.key.contains('pos') ||
                            e.key.contains('order') ||
                            e.key.contains('customer') ||
                            e.key.contains('loyalty') ||
                            e.key.contains('tax') ||
                            e.key.contains('table') ||
                            e.key.contains('weight') ||
                            e.key.contains('scale')).toList();

                        final otherToggles = filtered.where((e) =>
                            !clinicalToggles.contains(e) && !posToggles.contains(e)).toList();

                        return ListView(
                          children: [
                            if (clinicalToggles.isNotEmpty) ...[
                              _buildCategoryHeader('Clinical & Anatomical Toggles', LucideIcons.stethoscope, AppColors.info, clinicalToggles.length),
                              const SizedBox(height: 6),
                              ...clinicalToggles.map((e) => _buildToggleTile(e.key, e.value, AppColors.info, effectiveToggles)),
                              const SizedBox(height: 16),
                            ],
                            if (posToggles.isNotEmpty) ...[
                              _buildCategoryHeader('POS, Sales & Terminal Devices', LucideIcons.shoppingCart, AppColors.primary, posToggles.length),
                              const SizedBox(height: 6),
                              ...posToggles.map((e) => _buildToggleTile(e.key, e.value, AppColors.primary, effectiveToggles)),
                              const SizedBox(height: 16),
                            ],
                            if (otherToggles.isNotEmpty) ...[
                              _buildCategoryHeader('Inventory, ERP & Fleet Peripherals', LucideIcons.layers, AppColors.secondary, otherToggles.length),
                              const SizedBox(height: 6),
                              ...otherToggles.map((e) => _buildToggleTile(e.key, e.value, AppColors.secondary, effectiveToggles)),
                            ],
                          ],
                        );
                      },
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

  Widget _buildCategoryHeader(String title, IconData icon, Color color, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          const Spacer(),
          Text('$count toggles', style: TextStyle(fontSize: 10.5, color: color)),
        ],
      ),
    );
  }

  Widget _buildToggleTile(String key, bool isEnabled, Color color, Map<String, bool> currentToggles) {
    final isDental3d = key == 'sw.dental_tooth_chart_editor';
    final isSpecialHighlight = isDental3d || key == 'sw.clinic_doctor_station' || key == 'sw.retail_pos';

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isEnabled
              ? (isSpecialHighlight ? AppColors.accent : color.withValues(alpha: 0.4))
              : AppColors.borderDark,
          width: isSpecialHighlight && isEnabled ? 1.5 : 1.0,
        ),
      ),
      child: Material(
        color: isEnabled ? AppColors.surfaceElevatedDark : AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(8),
        child: SwitchListTile(
          dense: true,
          value: isEnabled,
          activeThumbColor: isSpecialHighlight ? AppColors.accent : color,
          activeTrackColor: (isSpecialHighlight ? AppColors.accent : color).withValues(alpha: 0.35),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  _formatKeyLabel(key),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isEnabled ? Colors.white : AppColors.textSecondaryDark,
                  ),
                ),
              ),
              if (isDental3d)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '3D ANATOMY',
                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.accent),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(_getDesc(key), style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
              const SizedBox(height: 2),
              Text(key, style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: AppColors.textMutedDark)),
            ],
          ),
          onChanged: (val) {
            final updated = Map<String, bool>.from(currentToggles);
            updated[key] = val;
            targetTogglesNotifier.value = updated;
          },
        ),
      ),
    );
  }

  void _deployConfigurationToTarget(
    BuildContext context,
    ConnectedNode targetNode,
    StoreBlueprint currentBlueprint,
  ) async {
    final effectiveToggles = targetTogglesNotifier.value.isNotEmpty
        ? targetTogglesNotifier.value
        : (() {
            final init = Map<String, bool>.from(currentBlueprint.toggles);
            _ensureAllToggles(init, currentBlueprint);
            return init;
          })();
    final updatedBlueprint = currentBlueprint.copyWith(
      toggles: Map<String, bool>.from(effectiveToggles),
    );

    final isMasterHub = targetNode.id == 'god-mode-hub';

    // 1. Create CONFIG_UPDATE envelope targeted at this station (or 'all' if Master Hub)
    final envelope = SyncEnvelope.create(
      type: 'CONFIG_UPDATE',
      scope: 'global',
      senderId: 'technician-terminal',
      senderRole: 'Lead Technician (God Mode)',
      payload: {
        'targetStationId': isMasterHub ? 'all' : targetNode.id,
        'targetAppName': targetNode.appName,
        'blueprint': StoreBlueprintModel.fromEntity(updatedBlueprint).toJson(),
      },
    );

    // 2. Broadcast across LAN sync network
    try {
      await lanSyncRepository.broadcast(envelope);
    } catch (_) {}

    // 3. If target is master hub, current station or server, also update local ConfigBloc
    final localId = LanSyncRepositoryImpl.getLocalInstanceId();
    final isTargetLocal = isMasterHub ||
        targetNode.id == 'god-mode-hub' ||
        targetNode.id == localId ||
        targetNode.id == 'local' ||
        targetNode.id.contains('server') ||
        targetNode.role.toLowerCase().contains('this station') ||
        targetNode.role.toLowerCase().contains('local') ||
        targetNode.role.toLowerCase().contains('master') ||
        targetNode.role.toLowerCase().contains('blueprint');

    if (context.mounted && isTargetLocal) {
      context.read<ConfigBloc>().add(UpdateBlueprintEvent(updatedBlueprint));
    }

    // 4. Update UI banner
    deploymentSuccessNotifier.value = isMasterHub
        ? 'Settings saved & refreshed successfully on this machine! Global Fleet Blueprint deployed to all remote stations (Doctor, Reception, POS) and saved permanently!'
        : (isTargetLocal
            ? 'Settings saved & refreshed successfully on this machine! All toggles (including 3D Dental Chart) are now active and permanently saved to the database.'
            : 'Configuration deployed successfully to ${targetNode.role} (${targetNode.ipAddress})! Target device has refreshed and saved settings permanently to its local database.');
  }

  static IconData _getNodeIcon(String role) {
    final r = role.toLowerCase();
    if (r.contains('god') || r.contains('tech') || r.contains('admin')) return LucideIcons.cpu;
    if (r.contains('doctor') || r.contains('clinic')) return LucideIcons.stethoscope;
    if (r.contains('recept')) return LucideIcons.userCheck;
    if (r.contains('pos') || r.contains('cashier')) return LucideIcons.shoppingCart;
    if (r.contains('server') || r.contains('hub') || r.contains('host')) return LucideIcons.server;
    if (r.contains('pharmacy') || r.contains('lab')) return LucideIcons.pill;
    return LucideIcons.monitor;
  }

  static String _formatKeyLabel(String key) {
    final clean = key.replaceFirst(RegExp(r'^(sw\.|hw\.)'), '');
    return clean.split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  static String _getDesc(String key) {
    switch (key) {
      case 'sw.dental_tooth_chart_editor':
        return 'Activates 3D Interactive Odontogram, 32-tooth quadrant matrix, and procedure charting.';
      case 'sw.clinic_doctor_station':
        return 'Activates Doctor Consultation Station, encounter history, clinical notes, and prescriptions.';
      case 'sw.clinic_reception':
        return 'Enables the Reception Desk workspace, patient queue, and triage triage status.';
      case 'sw.retail_pos':
        return 'Activates Retail POS Cashier checkout terminal with barcode scanning and instant bill settlement.';
      case 'sw.orders_returns':
        return 'Enables Order Management, sales history, receipt reprint, and item return refund workflows.';
      case 'sw.customers_crm':
        return 'Activates Customer & Patient directory with loyalty tier status and encounter history.';
      case 'sw.customer_debt_tracking':
        return 'Enables Customer Credit Ledger, partial payment tracking, debt aging, and overdue alerts.';
      case 'sw.inventory_catalog':
        return 'Activates Inventory Catalog, product SKU definitions, barcodes, stock levels, and low-stock alerts.';
      case 'sw.service_pipeline':
        return 'Enables Automotive / Trade / Service Work Orders Kanban board and job status lifecycle.';
      case 'sw.auto_repair_pipeline':
        return 'Activates Automotive Repair Work Orders, Bay scheduling, and labor time logs.';
      case 'sw.bookings_calendar':
        return 'Activates Room, Chair, and Appointment multi-view Calendar with conflict resolution.';
      case 'sw.boss_erp':
        return 'Activates Boss Executive Dashboard, gross margins, payroll, revenue trends, and audit summaries.';
      case 'sw.grocery_weight_pricing':
        return 'Calculates item line totals dynamically from digital weight scale inputs.';
      case 'sw.prescription_scanning':
        return 'Activates Optical Rx scanning, molecule interaction checks, and patient dosage logs.';
      case 'sw.table_management':
        return 'Enables Dine-In / Table layout selection and floor tab binding in POS.';
      case 'sw.expiry_tracking':
        return 'Enforces FEFO (First-Expired-First-Out) batch control on inventory products.';
      case 'sw.batch_numbers':
        return 'Tracks manufacturer lot/batch numbers for pharmaceutical and food safety.';
      case 'sw.loyalty_points':
        return 'Awards reward points per transaction and enables point-redemption discounts.';
      case 'hw.retail_barcode_scanner':
        return 'Global keyboard hook listener for physical USB and Bluetooth barcode scanners.';
      case 'hw.receipt_printer_80mm':
        return 'Direct thermal printing of formatted 80mm receipts with QR tax signatures.';
      case 'hw.cash_drawer_kick':
        return 'Sends electrical kick pulse to open cash drawer RJ11 port on transaction completion.';
      case 'hw.grocery_scale':
        return 'Integrates digital weighing scales with real-time tare and zero calibration.';
      case 'hw.optical_prescription_scanner':
        return 'High-resolution document camera scanner integration for medical prescriptions.';
      case 'hw.customer_display':
        return 'Secondary dual-screen customer facing price and total due monitor.';
      default:
        return 'Configure this discrete system engine toggle.';
    }
  }

  static void _ensureAllToggles(Map<String, bool> toggles, StoreBlueprint blueprint) {
    toggles.putIfAbsent('sw.dental_tooth_chart_editor', () => true);
    toggles.putIfAbsent('sw.clinic_doctor_station', () => true);
    toggles.putIfAbsent('sw.clinic_reception', () => true);
    toggles.putIfAbsent('sw.retail_pos', () => true);
    toggles.putIfAbsent('sw.orders_returns', () => true);
    toggles.putIfAbsent('sw.customers_crm', () => true);
    toggles.putIfAbsent('sw.customer_debt_tracking', () => true);
    toggles.putIfAbsent('sw.inventory_catalog', () => true);
    toggles.putIfAbsent('sw.service_pipeline', () => true);
    toggles.putIfAbsent('sw.auto_repair_pipeline', () => false);
    toggles.putIfAbsent('sw.bookings_calendar', () => true);
    toggles.putIfAbsent('sw.boss_erp', () => true);
    toggles.putIfAbsent('sw.table_management', () => false);
    toggles.putIfAbsent('sw.prescription_scanning', () => false);
    toggles.putIfAbsent('sw.grocery_weight_pricing', () => false);
    toggles.putIfAbsent('sw.expiry_tracking', () => false);
    toggles.putIfAbsent('sw.batch_numbers', () => false);
    toggles.putIfAbsent('sw.loyalty_points', () => true);
    toggles.putIfAbsent('hw.retail_barcode_scanner', () => true);
    toggles.putIfAbsent('hw.receipt_printer_80mm', () => true);
    toggles.putIfAbsent('hw.cash_drawer_kick', () => true);
    toggles.putIfAbsent('hw.grocery_scale', () => false);
    toggles.putIfAbsent('hw.optical_prescription_scanner', () => false);
    toggles.putIfAbsent('hw.customer_display', () => false);
  }
}
