import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/sync_network_client.dart';

enum SyncConnectionMode {
  localLan,
  globalCloud,
}

/// First-Run Database & Real-Time Sync Configuration Wizard.
/// 100% [StatelessWidget] architecture.
class FirstRunSyncWizardPage extends StatelessWidget {
  final ValueNotifier<SyncConnectionMode> modeNotifier;
  final ValueNotifier<ServerHealthResult?> healthResultNotifier;
  final ValueNotifier<bool> isTestingNotifier;
  final TextEditingController urlController;
  final TextEditingController apiKeyController;
  final SyncNetworkClient networkClient;
  final void Function(String verifiedUrl, String? apiKey)? onConnectionEstablished;

  FirstRunSyncWizardPage({
    super.key,
    ValueNotifier<SyncConnectionMode>? modeNotifier,
    ValueNotifier<ServerHealthResult?>? healthResultNotifier,
    ValueNotifier<bool>? isTestingNotifier,
    TextEditingController? urlController,
    TextEditingController? apiKeyController,
    SyncNetworkClient? networkClient,
    this.onConnectionEstablished,
  })  : modeNotifier = modeNotifier ?? ValueNotifier<SyncConnectionMode>(SyncConnectionMode.localLan),
        healthResultNotifier = healthResultNotifier ?? ValueNotifier<ServerHealthResult?>(null),
        isTestingNotifier = isTestingNotifier ?? ValueNotifier<bool>(false),
        urlController = urlController ?? TextEditingController(text: 'http://192.168.1.100:3000'),
        apiKeyController = apiKeyController ?? TextEditingController(),
        networkClient = networkClient ?? SyncNetworkClient();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF1F5F9),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
                border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo & Heading
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.radioTower, size: 36, color: AppColors.primaryLight),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'OmniTrack Real-Time Sync Setup',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Connect this terminal to the central database server to sync inventory, sales, and clinical queues.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 24),

                  // Mode Selector Tabs
                  ValueListenableBuilder<SyncConnectionMode>(
                    valueListenable: modeNotifier,
                    builder: (context, mode, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: _modeOptionButton(
                              title: 'Local (LAN Mode)',
                              subtitle: 'High-speed local network',
                              icon: LucideIcons.network,
                              isSelected: mode == SyncConnectionMode.localLan,
                              onTap: () {
                                modeNotifier.value = SyncConnectionMode.localLan;
                                if (urlController.text.contains('cloudflare') || urlController.text.isEmpty) {
                                  urlController.text = 'http://192.168.1.100:3000';
                                }
                                healthResultNotifier.value = null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _modeOptionButton(
                              title: 'Global (Cloud Mode)',
                              subtitle: 'Cloudflare / Public URL',
                              icon: LucideIcons.cloud,
                              isSelected: mode == SyncConnectionMode.globalCloud,
                              onTap: () {
                                modeNotifier.value = SyncConnectionMode.globalCloud;
                                if (!urlController.text.startsWith('https://')) {
                                  urlController.text = 'https://omni-sync.example.com';
                                }
                                healthResultNotifier.value = null;
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // URL Input
                  const Text('SERVER BASE ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMutedDark)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: urlController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(LucideIcons.globe, size: 18),
                      hintText: 'http://192.168.1.100:3000',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Optional API Key
                  ValueListenableBuilder<SyncConnectionMode>(
                    valueListenable: modeNotifier,
                    builder: (context, mode, _) {
                      if (mode == SyncConnectionMode.localLan) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('PAIRING TOKEN / API KEY (OPTIONAL)', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMutedDark)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: apiKeyController,
                            obscureText: true,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(LucideIcons.key, size: 18),
                              hintText: 'Bearer token or pairing key',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
                              filled: true,
                              fillColor: isDark ? const Color(0xFF030712) : const Color(0xFFF8FAFC),
                            ),
                          ),
                          const SizedBox(height: 14),
                        ],
                      );
                    },
                  ),

                  // Health Check Status Feedback
                  ValueListenableBuilder<ServerHealthResult?>(
                    valueListenable: healthResultNotifier,
                    builder: (context, health, _) {
                      if (health == null) return const SizedBox.shrink();

                      final isOnline = health.isOnline;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isOnline ? AppColors.success.withValues(alpha: 0.12) : AppColors.danger.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                          border: Border.all(color: isOnline ? AppColors.success.withValues(alpha: 0.3) : AppColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            Icon(isOnline ? LucideIcons.checkCircle2 : LucideIcons.alertTriangle, size: 18, color: isOnline ? AppColors.success : AppColors.danger),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isOnline ? 'Server Online (${health.latencyMs}ms)' : 'Connection Failed',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5, color: isOnline ? AppColors.success : AppColors.danger),
                                  ),
                                  Text(
                                    isOnline
                                        ? 'Engine v${health.version ?? "1.0.0"} • Active Terminals: ${health.connectedClients}'
                                        : (health.errorMessage ?? 'Target address is unreachable.'),
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                  // Actions: Test & Connect
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<bool>(
                          valueListenable: isTestingNotifier,
                          builder: (context, isTesting, _) {
                            return OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
                              ),
                              icon: isTesting
                                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                  : const Icon(LucideIcons.activity, size: 16),
                              label: Text(isTesting ? 'Testing...' : 'Test Connection'),
                              onPressed: isTesting ? null : () => _performHealthCheck(context),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ValueListenableBuilder<ServerHealthResult?>(
                          valueListenable: healthResultNotifier,
                          builder: (context, health, _) {
                            final isVerified = health?.isOnline == true;
                            return ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isVerified ? AppColors.success : AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
                              ),
                              icon: const Icon(LucideIcons.arrowRight, size: 16),
                              label: const Text('Proceed to App', style: TextStyle(fontWeight: FontWeight.bold)),
                              onPressed: isVerified
                                  ? () => onConnectionEstablished?.call(urlController.text.trim(), apiKeyController.text.trim())
                                  : null,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeOptionButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : const Color(0xFF030712),
          borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
          border: Border.all(
            color: isSelected ? AppColors.primaryLight : AppColors.borderDark,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: isSelected ? AppColors.primaryLight : AppColors.textSecondaryDark),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: isSelected ? AppColors.primaryLight : Colors.white)),
                  Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performHealthCheck(BuildContext context) async {
    final url = urlController.text.trim();
    if (url.isEmpty) return;

    isTestingNotifier.value = true;
    final res = await networkClient.checkServerHealth(url, apiKey: apiKeyController.text.trim());
    isTestingNotifier.value = false;
    healthResultNotifier.value = res;
  }
}
