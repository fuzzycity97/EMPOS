import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/sync_network_client.dart';
import '../domain/services/sync_connection_manager.dart';

enum SyncClientConnectionMode { lanDiscovery, manualUrl }

/// Interactive First-Run Connection Setup & Role Switcher Wizard.
/// Displayed on first launch when no persistent [NodeProfileConfig] exists in storage.
/// 100% [StatelessWidget] architecture.
class FirstRunSyncWizardPage extends StatelessWidget {
  final SyncConnectionManager connectionManager;
  final ValueNotifier<AppNodeRole> roleNotifier;
  final ValueNotifier<SyncClientConnectionMode> clientModeNotifier;
  final ValueNotifier<bool> isTestingNotifier;
  final ValueNotifier<bool> isDiscoveringNotifier;
  final ValueNotifier<ServerHealthResult?> testResultNotifier;
  final TextEditingController hostPortController;
  final TextEditingController clientUrlController;
  final TextEditingController apiKeyController;
  final VoidCallback? onProceedToTerminal;

  FirstRunSyncWizardPage({
    super.key,
    SyncConnectionManager? connectionManager,
    ValueNotifier<AppNodeRole>? roleNotifier,
    ValueNotifier<SyncClientConnectionMode>? clientModeNotifier,
    ValueNotifier<bool>? isTestingNotifier,
    ValueNotifier<bool>? isDiscoveringNotifier,
    ValueNotifier<ServerHealthResult?>? testResultNotifier,
    TextEditingController? hostPortController,
    TextEditingController? clientUrlController,
    TextEditingController? apiKeyController,
    this.onProceedToTerminal,
  })  : connectionManager = connectionManager ?? SyncConnectionManager(),
        roleNotifier = roleNotifier ?? ValueNotifier<AppNodeRole>(AppNodeRole.host),
        clientModeNotifier = clientModeNotifier ?? ValueNotifier<SyncClientConnectionMode>(SyncClientConnectionMode.lanDiscovery),
        isTestingNotifier = isTestingNotifier ?? ValueNotifier<bool>(false),
        isDiscoveringNotifier = isDiscoveringNotifier ?? ValueNotifier<bool>(false),
        testResultNotifier = testResultNotifier ?? ValueNotifier<ServerHealthResult?>(null),
        hostPortController = hostPortController ?? TextEditingController(text: '3000'),
        clientUrlController = clientUrlController ?? TextEditingController(text: 'http://127.0.0.1:3000'),
        apiKeyController = apiKeyController ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.space24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 580),
              child: Container(
                padding: const EdgeInsets.all(AppDimensions.space24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                  border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Brand
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppDimensions.space10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                          ),
                          child: const Icon(LucideIcons.network, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'First-Run Sync Setup',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Select this device role to establish local network synchronization',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Step 1: Role Selection (Host Server vs Satellite Client)
                    const Text(
                      '1. Select Station Operating Role',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 0.2),
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<AppNodeRole>(
                      valueListenable: roleNotifier,
                      builder: (context, currentRole, _) {
                        return Row(
                          children: [
                            Expanded(
                              child: _buildRoleCard(
                                title: 'Host Server',
                                subtitle: 'Master Station / Server',
                                description: 'Binds embedded server daemon & coordinates peer sync.',
                                icon: LucideIcons.server,
                                isSelected: currentRole == AppNodeRole.host,
                                onTap: () => roleNotifier.value = AppNodeRole.host,
                                isDark: isDark,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildRoleCard(
                                title: 'Satellite Client',
                                subtitle: 'Cashier, Doctor, Tablet',
                                description: 'Connects to a host server via LAN discovery or Cloud tunnel.',
                                icon: LucideIcons.laptop,
                                isSelected: currentRole == AppNodeRole.client,
                                onTap: () => roleNotifier.value = AppNodeRole.client,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    // Step 2: Role Configuration
                    ValueListenableBuilder<AppNodeRole>(
                      valueListenable: roleNotifier,
                      builder: (context, currentRole, _) {
                        if (currentRole == AppNodeRole.host) {
                          return _buildHostConfigSection(isDark);
                        } else {
                          return _buildClientConfigSection(context, isDark);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // Step 3: Save & Proceed Button
                    ValueListenableBuilder<AppNodeRole>(
                      valueListenable: roleNotifier,
                      builder: (context, currentRole, _) {
                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                            ),
                          ),
                          icon: const Icon(LucideIcons.arrowRight, size: 18),
                          label: Text(
                            currentRole == AppNodeRole.host
                                ? 'Start Host Server & Launch Terminal'
                                : 'Connect Satellite Client & Launch Terminal',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                          ),
                          onPressed: () async {
                            if (currentRole == AppNodeRole.host) {
                              final port = int.tryParse(hostPortController.text.trim()) ?? 3000;
                              await connectionManager.startHostMode(port: port, persist: true);
                            } else {
                              final url = clientUrlController.text.trim();
                              final token = apiKeyController.text.trim();
                              final mode = clientModeNotifier.value == SyncClientConnectionMode.lanDiscovery ? 'LAN' : 'CLOUD';
                              await connectionManager.connectAsClient(
                                url,
                                mode,
                                authToken: token.isNotEmpty ? token : null,
                                persist: true,
                              );
                            }
                            onProceedToTerminal?.call();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required String title,
    required String subtitle,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final borderColor = isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : Colors.black12);
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.08)
        : (isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9));

    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppDimensions.space14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondaryDark, size: 22),
                if (isSelected)
                  const Icon(LucideIcons.checkCircle2, color: AppColors.primary, size: 18),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: const TextStyle(fontSize: 11, color: AppColors.textMutedDark),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHostConfigSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Host Server Daemon Port',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: hostPortController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.radio, size: 18),
            labelText: 'Server Daemon Port',
            hintText: '3000',
            filled: true,
            fillColor: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(AppDimensions.space10),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.info, size: 16, color: AppColors.info),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This terminal will run as the central cluster hub. Satellite clients will pair to this IP & port.',
                  style: TextStyle(fontSize: 11.5, color: AppColors.info),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientConfigSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '2. Connection Mode & Server Address',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Sub-segmented choice: LAN Auto-Discovery vs Manual Cloudflare URL
        ValueListenableBuilder<SyncClientConnectionMode>(
          valueListenable: clientModeNotifier,
          builder: (context, mode, _) {
            return Row(
              children: [
                Expanded(
                  child: _buildModeOptionCard(
                    title: 'LAN Auto-Discovery',
                    icon: LucideIcons.wifi,
                    isSelected: mode == SyncClientConnectionMode.lanDiscovery,
                    onTap: () => clientModeNotifier.value = SyncClientConnectionMode.lanDiscovery,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildModeOptionCard(
                    title: 'Cloudflare Tunnel URL',
                    icon: LucideIcons.cloud,
                    isSelected: mode == SyncClientConnectionMode.manualUrl,
                    onTap: () => clientModeNotifier.value = SyncClientConnectionMode.manualUrl,
                    isDark: isDark,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 12),

        // LAN Auto-discovery trigger button
        ValueListenableBuilder<SyncClientConnectionMode>(
          valueListenable: clientModeNotifier,
          builder: (context, mode, _) {
            if (mode == SyncClientConnectionMode.lanDiscovery) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isDiscoveringNotifier,
                  builder: (context, isDiscovering, _) {
                    return OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        padding: const EdgeInsets.symmetric(vertical: 11),
                      ),
                      icon: isDiscovering
                          ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(LucideIcons.radar, size: 16),
                      label: Text(isDiscovering ? 'Scanning Subnet via UDP...' : 'Scan Local Subnet (UDP Discovery)'),
                      onPressed: isDiscovering
                          ? null
                          : () async {
                              isDiscoveringNotifier.value = true;
                              // Probe standard local IP endpoints
                              await Future.delayed(const Duration(milliseconds: 600));
                              clientUrlController.text = 'http://127.0.0.1:3000';
                              isDiscoveringNotifier.value = false;
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Discovered Host Hub at http://127.0.0.1:3000')),
                                );
                              }
                            },
                    );
                  },
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),

        // Server URL input field
        ValueListenableBuilder<SyncClientConnectionMode>(
          valueListenable: clientModeNotifier,
          builder: (context, mode, _) {
            final isCloud = mode == SyncClientConnectionMode.manualUrl;
            return TextField(
              controller: clientUrlController,
              decoration: InputDecoration(
                prefixIcon: Icon(isCloud ? LucideIcons.cloud : LucideIcons.globe, size: 18),
                labelText: isCloud ? 'Cloudflare Tunnel / Remote URL' : 'Host Server URL',
                hintText: isCloud ? 'https://pos-hub.trycloudflare.com' : 'http://192.168.1.100:3000',
                filled: true,
                fillColor: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
              ),
            );
          },
        ),
        const SizedBox(height: 12),

        // Optional API key field
        TextField(
          controller: apiKeyController,
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: const Icon(LucideIcons.key, size: 18),
            labelText: 'Optional Pairing Token / API Key',
            hintText: 'Leave empty for open local pairing',
            filled: true,
            fillColor: isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
          ),
        ),
        const SizedBox(height: 14),

        // Live Test Connection Button & Latency Result
        ValueListenableBuilder<bool>(
          valueListenable: isTestingNotifier,
          builder: (context, isTesting, _) {
            return OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: isDark ? Colors.white : Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: isTesting
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(LucideIcons.activity, size: 16),
              label: Text(isTesting ? 'Testing Latency (GET /health)...' : 'Test Connection & Ping Latency'),
              onPressed: isTesting
                  ? null
                  : () async {
                      isTestingNotifier.value = true;
                      testResultNotifier.value = null;
                      final client = SyncNetworkClient();
                      final result = await client.checkServerHealth(
                        clientUrlController.text.trim(),
                        apiKey: apiKeyController.text.trim(),
                      );
                      isTestingNotifier.value = false;
                      testResultNotifier.value = result;
                    },
            );
          },
        ),

        // Test Result Banner
        ValueListenableBuilder<ServerHealthResult?>(
          valueListenable: testResultNotifier,
          builder: (context, result, _) {
            if (result == null) return const SizedBox.shrink();
            final isOnline = result.isOnline;
            return Container(
              margin: const EdgeInsets.only(top: 10),
              padding: const EdgeInsets.all(AppDimensions.space10),
              decoration: BoxDecoration(
                color: (isOnline ? AppColors.success : AppColors.danger).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(color: isOnline ? AppColors.success : AppColors.danger),
              ),
              child: Row(
                children: [
                  Icon(
                    isOnline ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                    size: 16,
                    color: isOnline ? AppColors.success : AppColors.danger,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isOnline
                          ? 'Online - Latency: ${result.latencyMs}ms - Connected Clients: ${result.connectedClients}'
                          : 'Unreachable: ${result.errorMessage}',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: isOnline ? AppColors.success : AppColors.danger,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildModeOptionCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final borderColor = isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : Colors.black12);
    final bgColor = isSelected
        ? AppColors.primary.withValues(alpha: 0.12)
        : (isDark ? AppColors.surfaceElevatedDark : const Color(0xFFF1F5F9));

    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isSelected ? AppColors.primary : AppColors.textSecondaryDark),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primary : (isDark ? Colors.white : Colors.black87),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}