import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/data/models/store_blueprint_model.dart';
import '../../../../core/config/domain/entities/industry_type.dart';
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
  final ValueNotifier<SpecificIndustry?> targetProfessionNotifier;
  final ValueNotifier<String> searchFilterNotifier;
  final ValueNotifier<String?> deploymentSuccessNotifier;
  final TextEditingController serverIpController;

  const TechnicianFleetConsolePage._({
    super.key,
    required this.lanSyncRepository,
    required this.selectedTargetNodeNotifier,
    required this.targetTogglesNotifier,
    required this.targetProfessionNotifier,
    required this.searchFilterNotifier,
    required this.deploymentSuccessNotifier,
    required this.serverIpController,
  });

  factory TechnicianFleetConsolePage({
    Key? key,
    LanSyncRepository? customRepository,
    ValueNotifier<SpecificIndustry?>? customTargetProfessionNotifier,
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
    final targetProfession = customTargetProfessionNotifier ?? ValueNotifier<SpecificIndustry?>(null);
    final search = ValueNotifier<String>('');
    final deploySuccess = ValueNotifier<String?>(null);
    final ipCtrl = TextEditingController(text: '127.0.0.1');

    return TechnicianFleetConsolePage._(
      key: key,
      lanSyncRepository: repo,
      selectedTargetNodeNotifier: selectedNode,
      targetTogglesNotifier: targetToggles,
      targetProfessionNotifier: targetProfession,
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
                            targetProfessionNotifier.value = _determineNodeProfession(node, currentBlueprint);
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
                                Builder(
                                  builder: (context) {
                                    final nodeProf = _determineNodeProfession(node, currentBlueprint);
                                    return Text(
                                      isGodHub
                                          ? 'App Running: ${node.appName}'
                                          : 'App Running: ${node.appName} • ${nodeProf.label}',
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.accent,
                                      ),
                                    );
                                  },
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

        return ValueListenableBuilder<SpecificIndustry?>(
          valueListenable: targetProfessionNotifier,
          builder: (context, explicitProfession, _) {
            final activeProfession = explicitProfession ?? _determineNodeProfession(selectedNode, currentBlueprint);

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
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
                        const SizedBox(height: 12),
                        // Station Profession / Specialty Selector Bar
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevatedDark,
                            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(LucideIcons.briefcase, size: 14, color: AppColors.primaryLight),
                              const SizedBox(width: 8),
                              const Text(
                                'Station Profession / Specialty:',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: DropdownButtonHideUnderline(
                                  child: Builder(
                                    builder: (context) {
                                      final professionOptions = SpecificIndustry.values.map((s) {
                                        return DropdownMenuItem<SpecificIndustry>(
                                          value: s,
                                          child: Text(
                                            s.label,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        );
                                      }).toList();

                                      final safeValue = professionOptions.any((it) => it.value == activeProfession)
                                          ? activeProfession
                                          : SpecificIndustry.clinic;

                                      return DropdownButton<SpecificIndustry>(
                                        value: safeValue,
                                        isExpanded: true,
                                        dropdownColor: AppColors.surfaceElevatedDark,
                                        icon: const Icon(LucideIcons.chevronDown, size: 14, color: AppColors.accent),
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.accent),
                                        onChanged: (newProf) {
                                          if (newProf != null) {
                                            targetProfessionNotifier.value = newProf;
                                          }
                                        },
                                        items: professionOptions,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
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
                              final label = _formatKeyLabel(e.key, activeProfession).toLowerCase();
                              final rawKey = e.key.toLowerCase();
                              final desc = _getDesc(e.key, activeProfession).toLowerCase();
                              return label.contains(q) || rawKey.contains(q) || desc.contains(q);
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
                                  ...clinicalToggles.map((e) => _buildToggleTile(context, e.key, e.value, AppColors.info, effectiveToggles, currentBlueprint, selectedNode, activeProfession)),
                                  const SizedBox(height: 16),
                                ],
                                if (posToggles.isNotEmpty) ...[
                                  _buildCategoryHeader('POS, Sales & Terminal Devices', LucideIcons.shoppingCart, AppColors.primary, posToggles.length),
                                  const SizedBox(height: 6),
                                  ...posToggles.map((e) => _buildToggleTile(context, e.key, e.value, AppColors.primary, effectiveToggles, currentBlueprint, selectedNode, activeProfession)),
                                  const SizedBox(height: 16),
                                ],
                                if (otherToggles.isNotEmpty) ...[
                                  _buildCategoryHeader('Inventory, ERP & Fleet Peripherals', LucideIcons.layers, AppColors.secondary, otherToggles.length),
                                  const SizedBox(height: 6),
                                  ...otherToggles.map((e) => _buildToggleTile(context, e.key, e.value, AppColors.secondary, effectiveToggles, currentBlueprint, selectedNode, activeProfession)),
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

  Widget _buildToggleTile(
    BuildContext context,
    String key,
    bool isEnabled,
    Color color,
    Map<String, bool> currentToggles,
    StoreBlueprint currentBlueprint,
    ConnectedNode? targetNode,
    SpecificIndustry? activeProfession,
  ) {
    final isDental3d = key == 'sw.dental_tooth_chart_editor';
    final isSpecialHighlight = isDental3d || key == 'sw.clinic_doctor_station' || key == 'sw.retail_pos';
    final anatomyInfo = _getSpecialtyAnatomyInfo(activeProfession);

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
                  _formatKeyLabel(key, activeProfession),
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
                  child: Text(
                    anatomyInfo.badge,
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.accent),
                  ),
                ),
            ],
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text(_getDesc(key, activeProfession), style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
              const SizedBox(height: 2),
              Text(key, style: const TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: AppColors.textMutedDark)),
            ],
          ),
          onChanged: (val) {
            final updated = Map<String, bool>.from(currentToggles);
            updated[key] = val;
            targetTogglesNotifier.value = updated;

            // Immediately apply to local ConfigBloc when configuring Master Hub or local station
            final isMasterOrLocal = targetNode == null ||
                targetNode.id == 'god-mode-hub' ||
                targetNode.id == 'local' ||
                targetNode.id == LanSyncRepositoryImpl.getLocalInstanceId();
            if (isMasterOrLocal) {
              final newBp = currentBlueprint.copyWith(
                toggles: updated,
                specificIndustry: activeProfession,
                vertical: activeProfession?.vertical,
              );
              context.read<ConfigBloc>().add(UpdateBlueprintEvent(newBp));
            }
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
    final activeProfession = targetProfessionNotifier.value ?? _determineNodeProfession(targetNode, currentBlueprint);
    final updatedBlueprint = currentBlueprint.copyWith(
      toggles: Map<String, bool>.from(effectiveToggles),
      specificIndustry: activeProfession,
      vertical: activeProfession.vertical,
      industryType: activeProfession.vertical == IndustryVertical.medical
          ? IndustryType.medical
          : (activeProfession.vertical == IndustryVertical.automotive
              ? IndustryType.automotive
              : currentBlueprint.industryType),
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

    // 3. Always update local ConfigBloc so this workstation has these settings saved & applied immediately
    if (context.mounted) {
      context.read<ConfigBloc>().add(UpdateBlueprintEvent(updatedBlueprint));
    }

    // 4. Update UI banner
    final anatomyLabel = _getSpecialtyAnatomyInfo(activeProfession).label;
    deploymentSuccessNotifier.value = isMasterHub
        ? 'Settings saved & refreshed successfully on this machine! Global Fleet Blueprint deployed to all remote stations (Doctor, Reception, POS) and saved permanently!'
        : 'Configuration deployed successfully to ${targetNode.role} (${targetNode.ipAddress}) with profession [${activeProfession.label}] and saved to this machine! All toggles (including $anatomyLabel) are now active and permanently saved.';
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

  static SpecificIndustry _determineNodeProfession(
    ConnectedNode? node,
    StoreBlueprint currentBlueprint,
  ) {
    if (node != null && node.profession != null && node.profession!.isNotEmpty) {
      return SpecificIndustry.fromString(node.profession);
    }
    final combined = '${node?.role ?? ''} ${node?.appName ?? ''}'.toLowerCase();
    if (combined.contains('ophthalm') || combined.contains('eye') || combined.contains('optom')) {
      return SpecificIndustry.ophthalmologyClinic;
    }
    if (combined.contains('ortho') || combined.contains('bone') || combined.contains('joint') || combined.contains('skelet')) {
      return SpecificIndustry.orthopedicClinic;
    }
    if (combined.contains('cardio') || combined.contains('heart')) {
      return SpecificIndustry.cardiologyClinic;
    }
    if (combined.contains('derma') || combined.contains('skin') || combined.contains('hair')) {
      return SpecificIndustry.dermatologyClinic;
    }
    if (combined.contains('physio') || combined.contains('rehab') || combined.contains('chiro')) {
      return SpecificIndustry.physiotherapyRehab;
    }
    if (combined.contains('gastro') || combined.contains('digest') || combined.contains('endoscop')) {
      return SpecificIndustry.gastroClinic;
    }
    if (combined.contains('neuro') || combined.contains('brain')) {
      return SpecificIndustry.neurologyClinic;
    }
    if (combined.contains('ent') || combined.contains('sinus') || combined.contains('rhino')) {
      return SpecificIndustry.rhinologySinusEnt;
    }
    if (combined.contains('pulmon') || combined.contains('respir') || combined.contains('lung')) {
      return SpecificIndustry.pulmonologyRespiratory;
    }
    if (combined.contains('uro') || combined.contains('prostate')) {
      return SpecificIndustry.urologyMensHealth;
    }
    if (combined.contains('obgyn') || combined.contains('gyne') || combined.contains('fertility')) {
      return SpecificIndustry.obgynFertilityRei;
    }
    if (combined.contains('dental') || combined.contains('tooth') || combined.contains('dentist')) {
      return SpecificIndustry.dentalClinic;
    }
    if (combined.contains('vet') || combined.contains('animal') || combined.contains('pet')) {
      return SpecificIndustry.veterinaryClinic;
    }
    if (combined.contains('lab') || combined.contains('pathology') || combined.contains('dicom')) {
      return SpecificIndustry.diagnosticLab;
    }
    if (combined.contains('psych') || combined.contains('mental') || combined.contains('counsel')) {
      return SpecificIndustry.mentalHealthCounseling;
    }
    if (combined.contains('pharm') || combined.contains('rx') || combined.contains('drug')) {
      return SpecificIndustry.pharmacy;
    }
    if (combined.contains('auto') || combined.contains('garage') || combined.contains('mechanic')) {
      return SpecificIndustry.autoRepairGarage;
    }
    if (combined.contains('wash') || combined.contains('detail')) {
      return SpecificIndustry.carWashDetailing;
    }
    if (combined.contains('tire') || combined.contains('wheel')) {
      return SpecificIndustry.tireShop;
    }
    if (combined.contains('salon') || combined.contains('barber')) {
      return SpecificIndustry.hairSalonBarbershop;
    }
    if (combined.contains('nail') || combined.contains('brow')) {
      return SpecificIndustry.nailSalon;
    }
    if (combined.contains('spa') || combined.contains('wellness') || combined.contains('massage')) {
      return SpecificIndustry.spaWellnessCenter;
    }
    if (combined.contains('tattoo') || combined.contains('piercing')) {
      return SpecificIndustry.tattooPiercingStudio;
    }
    if (combined.contains('gym') || combined.contains('fitness')) {
      return SpecificIndustry.gymFitnessCenter;
    }
    if (combined.contains('training') || combined.contains('trainer') || combined.contains('workout')) {
      return SpecificIndustry.personalTraining1on1;
    }
    if (combined.contains('yoga') || combined.contains('pilates')) {
      return SpecificIndustry.yogaPilatesStudio;
    }
    if (combined.contains('bake') || combined.contains('patisserie')) {
      return SpecificIndustry.bakeryPatisserie;
    }
    if (combined.contains('bar') || combined.contains('pub') || combined.contains('lounge')) {
      return SpecificIndustry.barPub;
    }
    if (combined.contains('cafe') || combined.contains('coffee') || combined.contains('barista')) {
      return SpecificIndustry.cafeCoffeeshop;
    }
    if (combined.contains('cloud') || combined.contains('kitchen')) {
      return SpecificIndustry.cloudKitchenDelivery;
    }
    if (combined.contains('dine') || combined.contains('restaurant')) {
      return SpecificIndustry.restaurantDinein;
    }
    if (combined.contains('clean') || combined.contains('maid')) {
      return SpecificIndustry.cleaningService;
    }
    if (combined.contains('hvac') || combined.contains('plumb') || combined.contains('electr')) {
      return SpecificIndustry.fieldTradesHvac;
    }
    if (combined.contains('lawn') || combined.contains('landscape')) {
      return SpecificIndustry.landscapingLawncare;
    }
    if (combined.contains('law') || combined.contains('legal') || combined.contains('attorney')) {
      return SpecificIndustry.lawFirm;
    }
    if (combined.contains('account') || combined.contains('tax') || combined.contains('bookkeep')) {
      return SpecificIndustry.accountingBookkeeping;
    }
    if (combined.contains('photo') || combined.contains('camera')) {
      return SpecificIndustry.photographyStudio;
    }
    if (combined.contains('real_estate') || combined.contains('realtor') || combined.contains('property')) {
      return SpecificIndustry.realEstateAgency;
    }
    if (combined.contains('grocer') || combined.contains('market') || combined.contains('supermarket')) {
      return SpecificIndustry.grocerySupermarket;
    }
    if (combined.contains('kiosk') || combined.contains('convenience')) {
      return SpecificIndustry.convenienceKiosk;
    }
    if (combined.contains('cloth') || combined.contains('boutique') || combined.contains('fashion')) {
      return SpecificIndustry.clothingBoutique;
    }
    if (combined.contains('phone') || combined.contains('electronic')) {
      return SpecificIndustry.electronicsPhoneShop;
    }
    if (combined.contains('book') || combined.contains('stationery')) {
      return SpecificIndustry.bookstoreStationery;
    }
    if (currentBlueprint.specificIndustry != SpecificIndustry.cashierPos) {
      return currentBlueprint.specificIndustry;
    }
    if (currentBlueprint.isMedical) {
      return SpecificIndustry.dentalClinic;
    }
    return SpecificIndustry.cashierPos;
  }

  static ({String label, String description, String badge}) _getSpecialtyAnatomyInfo(
    SpecificIndustry? profession,
  ) {
    if (profession == null) {
      return (
        label: 'Dental Tooth Chart Editor',
        description: 'Activates 3D Interactive Odontogram, 32-tooth quadrant matrix, and procedure charting.',
        badge: '3D ANATOMY',
      );
    }
    switch (profession) {
      // 1. Head, Brain & Neurological Specialties
      case SpecificIndustry.neurologyClinic:
        return (
          label: 'Neurology 3D Intracranial Brain Visualizer',
          description: 'Activates 3D intracranial brain layers, cranial nerves, and Circle of Willis mapping.',
          badge: '3D NEURO',
        );
      case SpecificIndustry.neurologyNeurosurgery:
        return (
          label: 'Neurosurgery 3D Stereotactic Cranial Visualizer',
          description: 'Activates 3D craniotomy boundary planning, stereotactic neuronavigation, and ventriculostomy.',
          badge: '3D NEUROSURGERY',
        );
      case SpecificIndustry.neuroOtologyBalance:
        return (
          label: 'Neuro-Otology 3D Vestibular & Labyrinth Visualizer',
          description: 'Activates 3D inner ear semicircular canals, otolith organs, and Dix-Hallpike nystagmus examination.',
          badge: '3D VESTIBULAR',
        );
      case SpecificIndustry.neuroPsychiatryTms:
        return (
          label: 'Neuro-Psychiatry 3D TMS Brain Network Visualizer',
          description: 'Activates 3D dorsolateral prefrontal cortex (dlPFC) coil targeting and psychiatric scoring.',
          badge: '3D TMS BRAIN',
        );

      // 2. Eye, ENT, Dental & Face Clinics
      case SpecificIndustry.ophthalmologyClinic:
      case SpecificIndustry.optometryClinic:
        return (
          label: 'Ophthalmology 3D Ocular Visualizer',
          description: 'Activates 3D Eye Globe, sliced ocular layers, and fundus C:D examination.',
          badge: '3D OCULAR',
        );
      case SpecificIndustry.entClinic:
        return (
          label: 'ENT Ear, Nose & Throat 3D Airway Visualizer',
          description: 'Activates 3D auditory canal, tympanic membrane, larynx, and vocal cords assessment.',
          badge: '3D ENT',
        );
      case SpecificIndustry.rhinologySinusEnt:
        return (
          label: 'ENT & Rhinology 3D Sinus Visualizer',
          description: 'Activates 3D paranasal sinuses, nasal septum, and airway visualizer.',
          badge: '3D SINUS',
        );
      case SpecificIndustry.dentalClinic:
        return (
          label: 'Dental Tooth Chart Editor',
          description: 'Activates 3D Interactive Odontogram, 32-tooth quadrant matrix, and procedure charting.',
          badge: '3D ANATOMY',
        );
      case SpecificIndustry.endodonticsDental:
        return (
          label: 'Endodontics & Dental CBCT Visualizer',
          description: 'Activates 3D root canal pulp chamber, CBCT volume slice, and periapical lesion tracking.',
          badge: '3D CBCT',
        );

      // 3. Cardiovascular, Thoracic & Vein Clinics
      case SpecificIndustry.cardiologyClinic:
        return (
          label: 'Cardiology 3D Heart & Vascular Visualizer',
          description: 'Activates 3D cardiovascular heart anatomy, coronary arteries, and hemodynamic tracking.',
          badge: '3D CARDIAC',
        );
      case SpecificIndustry.veinVascularPhlebology:
        return (
          label: 'Vascular & Vein Phlebology Visualizer',
          description: 'Activates venous reflux mapping (CEAP C1-C6), saphenous vein duplex, and sclerotherapy pins.',
          badge: '3D VASCULAR',
        );
      case SpecificIndustry.pulmonologyRespiratory:
        return (
          label: 'Pulmonology 3D Respiratory & Lung Visualizer',
          description: 'Activates 3D bronchial tree, lung parenchyma, and EBUS biopsy mapping.',
          badge: '3D PULMONARY',
        );
      case SpecificIndustry.endocrinologyClinic:
        return (
          label: 'Endocrinology 3D Glandular & Thyroid Visualizer',
          description: 'Activates 3D thyroid TIRADS nodule scoring, adrenal glands, and HbA1c glycemic sensor logs.',
          badge: '3D ENDOCRINE',
        );

      // 4. Abdominal, Pelvic & Endocrine Clinics
      case SpecificIndustry.gastroClinic:
        return (
          label: 'Gastroenterology 3D Digestive & Endoscopy Visualizer',
          description: 'Activates 3D gastrointestinal tract, endoscopy options, and digestive organ mapping.',
          badge: '3D DIGESTIVE',
        );
      case SpecificIndustry.urologyMensHealth:
        return (
          label: 'Urology 3D Viscera & Men\'s Health Visualizer',
          description: 'Activates 3D pelvic viscera, urinary bladder, and prostate peripheral zone mapping.',
          badge: '3D UROLOGY',
        );
      case SpecificIndustry.obgynFertilityRei:
        return (
          label: 'OB/GYN 3D Reproductive & Pelvic Visualizer',
          description: 'Activates 3D uterine cavity, ovaries, fallopian tubes, and pelvic floor anatomy.',
          badge: '3D OB/GYN',
        );

      // 5. Musculoskeletal, Sports & Physical Rehab
      case SpecificIndustry.orthopedicClinic:
        return (
          label: 'Orthopedics 3D Skeleton & Bone Explorer',
          description: 'Activates 3D interactive skeletal bone explorer, goniometer, and joint motion tracking.',
          badge: '3D SKELETAL',
        );
      case SpecificIndustry.orthopedicSportsTrauma:
        return (
          label: 'Orthopedic Trauma & Sports Joint Explorer',
          description: 'Activates ligament tear grading (ACL/MCL), fracture classification, and post-op implant pins.',
          badge: '3D TRAUMA',
        );
      case SpecificIndustry.physiotherapyRehab:
        return (
          label: 'Physiotherapy 3D Muscle & Musculoskeletal Viewer',
          description: 'Activates 3D muscular anatomy, rehab motion vectors, and trigger point charting.',
          badge: '3D MUSCULAR',
        );
      case SpecificIndustry.physiotherapyChiropractic:
        return (
          label: 'Chiropractic & Spine Alignment Visualizer',
          description: 'Activates 3D spinal column vertebra subluxation map, posture grid, and Cobb angle tracker.',
          badge: '3D SPINE',
        );
      case SpecificIndustry.podiatryOrthotics:
        return (
          label: 'Podiatry 3D Foot & Ankle Biomechanics Viewer',
          description: 'Activates 3D tarsal/metatarsal anatomy, gait baropodometry, and orthotic insole pressure map.',
          badge: '3D PODIATRY',
        );

      // 6. Plastic Surgery, Aesthetics & Dermatology
      case SpecificIndustry.plasticSurgeryCosmetic:
        return (
          label: 'Cosmetic & Plastic Surgery 3D Face Visualizer',
          description: 'Activates 3D facial vectors, rhinoplasty contouring, blepharoplasty, and breast implant sizing.',
          badge: '3D PLASTIC',
        );
      case SpecificIndustry.medicalAestheticsInjectors:
        return (
          label: 'Aesthetics 3D Facial Injector & Botulinum Mapper',
          description: 'Activates facial danger zones, dermal filler micro-droplets, and neurotoxin unit dosing.',
          badge: '3D INJECTORS',
        );
      case SpecificIndustry.dermatologyClinic:
        return (
          label: 'Dermatology 3D Dermatome & Skin Viewer',
          description: 'Activates 3D dermatome mapping, Fitzpatrick phototyping, and skin lesion tracking.',
          badge: '3D DERMATOME',
        );
      case SpecificIndustry.dermatologyHairRestoration:
        return (
          label: 'Trichology & Hair Follicle Density Mapper',
          description: 'Activates Norwood/Ludwig scalp hair restoration grid, FUE graft count, and follicle density.',
          badge: '3D TRICHOLOGY',
        );

      // 7. Interventional Pain, Anesthesia & Allied Specialties
      case SpecificIndustry.interventionalPainManagement:
        return (
          label: 'Pain Management 3D Nerve Block & Spine Visualizer',
          description: 'Activates C-arm fluoroscopy needle trajectories, epidural/facet blocks, and pain dermatome map.',
          badge: '3D PAIN BLOCK',
        );
      case SpecificIndustry.acupunctureEasternMedicine:
        return (
          label: 'Acupuncture 3D Meridian & Acupoint Visualizer',
          description: 'Activates 3D twelve primary meridian channels, 361 acupoints, and pulse diagnosis notes.',
          badge: '3D MERIDIAN',
        );
      case SpecificIndustry.speechLanguagePathology:
        return (
          label: 'Speech Pathology 3D Vocal Tract & Articulatory Visualizer',
          description: 'Activates 3D pharyngeal/laryngeal articulation, swallowing videofluoroscopy (FEES), and phonetics.',
          badge: '3D VOCAL TRACT',
        );
      case SpecificIndustry.pediatricClinic:
        return (
          label: 'Pediatrics 3D Child Anatomy & Growth Visualizer',
          description: 'Activates WHO/CDC growth percentile curves, pediatric vaccine milestones, and child anatomy.',
          badge: '3D PEDIATRIC',
        );
      case SpecificIndustry.diagnosticLab:
        return (
          label: 'Diagnostic Lab & DICOM Medical Imaging Station',
          description: 'Activates automated clinical pathology analyzer feeds, DICOM PACS imaging, and lab worklists.',
          badge: 'DICOM LAB',
        );
      case SpecificIndustry.mentalHealthCounseling:
        return (
          label: 'Mental Health & Psychotherapy Assessment Suite',
          description: 'Activates DSM-5 diagnostic criteria, PHQ-9/GAD-7 psychometric scales, and therapy notes.',
          badge: 'PSYCH SUITE',
        );
      case SpecificIndustry.pharmacy:
        return (
          label: 'Pharmacy Prescription & Molecule Dispensing Engine',
          description: 'Activates e-Prescription drug interaction checks, pill blister packaging, and NDC barcode scanner.',
          badge: 'PHARMACY RX',
        );
      case SpecificIndustry.veterinaryClinic:
        return (
          label: 'Veterinary 3D Canine & Feline Anatomical Visualizer',
          description: 'Activates 3D canine/feline skeletal anatomy, veterinary dental charting, and microchip scanner.',
          badge: '3D VETERINARY',
        );
      case SpecificIndustry.clinic:
        return (
          label: 'Multi-Specialty 3D Anatomical Visualizer',
          description: 'Activates interactive 3D anatomical exploration, layers, and clinical pin observations.',
          badge: '3D ANATOMY',
        );

      // Automotive
      case SpecificIndustry.autoRepairGarage:
        return (
          label: 'Automotive 3D Vehicle & Bay Inspection Pipeline',
          description: 'Activates 3D vehicle inspection points, bay lift scheduling, and VIN work orders.',
          badge: '3D VEHICLE',
        );
      case SpecificIndustry.carWashDetailing:
        return (
          label: 'Car Wash & Auto Detailing Bay Workflow Manager',
          description: 'Activates auto detailing bay queue, wash tier packages, and vehicle readiness tracker.',
          badge: 'AUTO DETAILING',
        );
      case SpecificIndustry.tireShop:
        return (
          label: 'Tire Shop & 3D Wheel Alignment Diagnostic Engine',
          description: 'Activates 3D wheel camber/toe alignment, tire tread depth analysis, and rim mounting.',
          badge: '3D ALIGNMENT',
        );

      // Beauty & Personal Care
      case SpecificIndustry.hairSalonBarbershop:
        return (
          label: 'Hair Salon & Barbershop Style & Chair Manager',
          description: 'Activates barber chair queue, stylist appointment board, and cut/color formulas.',
          badge: 'SALON CHAIR',
        );
      case SpecificIndustry.nailSalon:
        return (
          label: 'Nail Salon & Brow Bar Service Board',
          description: 'Activates manicure/pedicure station tracking, polish color catalog, and technician tips.',
          badge: 'NAIL & BROW',
        );
      case SpecificIndustry.spaWellnessCenter:
        return (
          label: 'Spa & Wellness Hydrotherapy & Room Manager',
          description: 'Activates sauna/massage suite allocations, aromatherapy packages, and therapist scheduling.',
          badge: 'SPA WELLNESS',
        );
      case SpecificIndustry.tattooPiercingStudio:
        return (
          label: 'Tattoo & Piercing 3D Body Art Placement Visualizer',
          description: 'Activates 3D skin canvas stencil placement, needle gauge selection, and sterile consent forms.',
          badge: '3D BODY ART',
        );

      // Education & Tutoring
      case SpecificIndustry.drivingSchool:
        return (
          label: 'Driving School Dual-Control Fleet & Slot Manager',
          description: 'Activates instructor dual-control vehicle fleet, road test simulations, and student permits.',
          badge: 'DRIVING FLEET',
        );
      case SpecificIndustry.tutoringLearningCenter:
        return (
          label: 'Tutoring Center & Academy Classroom Board',
          description: 'Activates classroom seating charts, curriculum progress tracking, and student gradebooks.',
          badge: 'ACADEMY CLASS',
        );

      // Events & Hospitality
      case SpecificIndustry.eventVenueBanquet:
        return (
          label: 'Event Venue 3D Floor & Banquet Seating Visualizer',
          description: 'Activates 3D banquet hall floor layouts, table reservations, and catering timeline planner.',
          badge: '3D BANQUET',
        );
      case SpecificIndustry.hotelGuesthouse:
        return (
          label: 'Hotel & Guesthouse Room & Reservation Grid',
          description: 'Activates room occupancy grid, housekeeping status, check-in keycards, and folio billing.',
          badge: 'ROOM GRID',
        );

      // Fitness & Sports
      case SpecificIndustry.gymFitnessCenter:
        return (
          label: 'Gym & Fitness Member Turnstile & Class Scheduler',
          description: 'Activates RFID turnstile access, gym membership tiers, and group fitness class bookings.',
          badge: 'GYM PASS',
        );
      case SpecificIndustry.personalTraining1on1:
        return (
          label: 'Personal Training 3D Muscle & Workout Tracker',
          description: 'Activates 3D body muscle targeting, 1-on-1 hypertrophy programs, and caliper body fat logs.',
          badge: '3D WORKOUT',
        );
      case SpecificIndustry.yogaPilatesStudio:
        return (
          label: 'Yoga & Pilates Mat & Reformer Studio Manager',
          description: 'Activates reformer apparatus booking, yoga mat alignment grids, and instructor roster.',
          badge: 'YOGA STUDIO',
        );

      // Food & Beverage
      case SpecificIndustry.bakeryPatisserie:
        return (
          label: 'Bakery & Artisan Patisserie Fresh Batch Tracker',
          description: 'Activates baking oven timer schedules, pastry batch yields, and morning shelf-life rotation.',
          badge: 'BAKERY BATCH',
        );
      case SpecificIndustry.barPub:
        return (
          label: 'Bar, Pub & Lounge Tab & Tap Line Monitor',
          description: 'Activates draft beer keg levels, cocktail recipe cards, and split bar tab management.',
          badge: 'BAR TAB',
        );
      case SpecificIndustry.cafeCoffeeshop:
        return (
          label: 'Cafe & Barista Quick-Order Speed Dispatch',
          description: 'Activates espresso shot extraction metrics, milk steam presets, and barista queue display.',
          badge: 'COFFEE BARISTA',
        );
      case SpecificIndustry.cloudKitchenDelivery:
        return (
          label: 'Cloud Kitchen Multi-Brand Order Aggregator',
          description: 'Activates delivery platform webhook aggregator, packaging station, and courier handoff.',
          badge: 'CLOUD KITCHEN',
        );
      case SpecificIndustry.restaurantDinein:
        return (
          label: 'Restaurant 3D Dining Table & Floor Layout Manager',
          description: 'Activates 3D dining room floor plan, course firing triggers, and server section zoning.',
          badge: '3D DINE-IN',
        );

      // General Services
      case SpecificIndustry.generalServices:
        return (
          label: 'General Services & Business Flow Manager',
          description: 'Activates multi-purpose service appointment tickets, customer check-in, and billing.',
          badge: 'GENERAL SERVICES',
        );

      // Home & Trade Field Services
      case SpecificIndustry.cleaningService:
        return (
          label: 'Residential & Commercial Cleaning Crew Dispatcher',
          description: 'Activates cleaning team checklist, square-footage pricing calculator, and route dispatch.',
          badge: 'CREW DISPATCH',
        );
      case SpecificIndustry.fieldTradesHvac:
        return (
          label: 'HVAC, Plumbing & Electrical Field Work Dispatcher',
          description: 'Activates truck inventory tracking, emergency service dispatch, and job site work orders.',
          badge: 'FIELD TRADE',
        );
      case SpecificIndustry.landscapingLawncare:
        return (
          label: 'Landscaping & Lawn Route Maintenance Planner',
          description: 'Activates lawn mowing route optimizer, seasonal pruning schedule, and yard acreage quotes.',
          badge: 'LANDSCAPE ROUTE',
        );

      // Professional Services
      case SpecificIndustry.accountingBookkeeping:
        return (
          label: 'Accounting & Tax Preparation Ledger Console',
          description: 'Activates double-entry general ledger, balance sheet audit trail, and VAT tax filings.',
          badge: 'TAX ACCOUNTING',
        );
      case SpecificIndustry.lawFirm:
        return (
          label: 'Law Firm Case & Billable Hours Legal Manager',
          description: 'Activates litigation docket calendar, billable timer increments, and client trust accounting.',
          badge: 'LEGAL PRACTICE',
        );
      case SpecificIndustry.photographyStudio:
        return (
          label: 'Photography Studio Shoot & Equipment Scheduler',
          description: 'Activates photo session timeline, camera/lens gear checkout, and proofing gallery delivery.',
          badge: 'PHOTO STUDIO',
        );
      case SpecificIndustry.realEstateAgency:
        return (
          label: 'Real Estate Property Pipeline & Commission Board',
          description: 'Activates MLS property listing catalog, buyer escrow milestones, and broker commission splits.',
          badge: 'REAL ESTATE',
        );

      // Retail & Supermarkets
      case SpecificIndustry.bookstoreStationery:
        return (
          label: 'Bookstore ISBN Catalog & Lending Tracker',
          description: 'Activates 13-digit ISBN barcode scanner, author/genre taxonomy, and reserved book orders.',
          badge: 'BOOKSTORE ISBN',
        );
      case SpecificIndustry.cashierPos:
        return (
          label: 'General Retail & Cashier POS Checkout Terminal',
          description: 'Activates multi-lane POS barcode scanner, receipt thermal printer, and cash drawer kick.',
          badge: 'RETAIL POS',
        );
      case SpecificIndustry.clothingBoutique:
        return (
          label: 'Fashion Boutique 3D Size-Color Matrix & Fitting',
          description: 'Activates apparel SKU variant matrix (Size/Color), fitting room queue, and garment tags.',
          badge: 'BOUTIQUE FITTING',
        );
      case SpecificIndustry.convenienceKiosk:
        return (
          label: 'Convenience Store & Kiosk Rapid Checkout Terminal',
          description: 'Activates rapid-tap speed keys, grab-and-go barcode register, and lotto ticket accounting.',
          badge: 'RAPID KIOSK',
        );
      case SpecificIndustry.electronicsPhoneShop:
        return (
          label: 'Electronics & Phone Repair Work Order Pipeline',
          description: 'Activates IMEI device intake, cracked screen/battery repair status, and spare parts stock.',
          badge: 'DEVICE REPAIR',
        );
      case SpecificIndustry.grocerySupermarket:
        return (
          label: 'Supermarket Dynamic Scale & Barcode Checkout',
          description: 'Activates RS-232 deli scale integration, weighted produce PLU lookups, and conveyor belt lanes.',
          badge: 'SUPERMARKET POS',
        );
    }
  }

  static String _formatKeyLabel(String key, [SpecificIndustry? profession]) {
    if (key == 'sw.dental_tooth_chart_editor') {
      return _getSpecialtyAnatomyInfo(profession).label;
    }
    final clean = key.replaceFirst(RegExp(r'^(sw\.|hw\.)'), '');
    return clean.split('_').map((w) => w.isEmpty ? '' : w[0].toUpperCase() + w.substring(1)).join(' ');
  }

  static String _getDesc(String key, [SpecificIndustry? profession]) {
    if (key == 'sw.dental_tooth_chart_editor') {
      return _getSpecialtyAnatomyInfo(profession).description;
    }
    switch (key) {
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

  @visibleForTesting
  static SpecificIndustry determineNodeProfessionForTest(
    ConnectedNode? node,
    StoreBlueprint currentBlueprint,
  ) => _determineNodeProfession(node, currentBlueprint);

  @visibleForTesting
  static ({String label, String description, String badge}) getSpecialtyAnatomyInfoForTest(
    SpecificIndustry? profession,
  ) => _getSpecialtyAnatomyInfo(profession);
}
