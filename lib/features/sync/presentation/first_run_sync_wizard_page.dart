import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/network/sync_network_client.dart';
import '../../domain/services/sync_connection_manager.dart';

enum SyncConnectionMode { lan, cloud }

/// Interactive First-Run Connection Setup & Role Switcher Wizard.
/// 100% [StatelessWidget] architecture.
class FirstRunSyncWizardPage extends StatelessWidget {
  final SyncConnectionManager connectionManager;
  final ValueNotifier<AppNodeRole> roleNotifier;
  final ValueNotifier<SyncConnectionMode> modeNotifier;
  final ValueNotifier<bool> isTestingNotifier;
  final ValueNotifier<ServerHealthResult?> testResultNotifier;
  final TextEditingController hostPortController;
  final TextEditingController clientUrlController;
  final TextEditingController apiKeyController;
  final VoidCallback? onProceedToTerminal;

  FirstRunSyncWizardPage({
    super.key,
    SyncConnectionManager? connectionManager,
    ValueNotifier<AppNodeRole>? roleNotifier,
    ValueNotifier<SyncConnectionMode>? modeNotifier,
    ValueNotifier<bool>? isTestingNotifier,
    ValueNotifier<ServerHealthResult?>? testResultNotifier,
    TextEditingController? hostPortController,
    TextEditingController? clientUrlController,
    TextEditingController? apiKeyController,
    this.onProceedToTerminal,
  })  : connectionManager = connectionManager ?? SyncConnectionManager(),
        roleNotifier = roleNotifier ?? ValueNotifier<AppNodeRole>(AppNodeRole.client),
        modeNotifier = modeNotifier ?? ValueNotifier<SyncConnectionMode>(SyncConnectionMode.lan),
        isTestingNotifier = isTestingNotifier ?? ValueNotifier<bool>(false),
        testResultNotifier = testResultNotifier ?? ValueNotifier<ServerHealthResult?>(null),
        hostPortController = hostPortController ?? TextEditingController(text: '3000'),
        clientUrlController = clientUrlController ?? TextEditingController(text: 'http://192.168.1.100:3000'),
        apiKeyController = apiKeyController ?? TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF090D16) : const Color(0xFFF8FAFC),
      body: Center(
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
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header Icon & Title ─────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
                        ),
                        child: const Icon(LucideIcons.network, size: 28, color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Device Role & Database Sync Setup',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Select whether this terminal is the Main Hub or a Satellite Station.',
                              style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // ── Role Switcher: Host vs. Client ──────────────────
                  const Text('Device Operating Role', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ValueListenableBuilder<AppNodeRole>(
                    valueListenable: roleNotifier,
                    builder: (context, currentRole, _) {
                      return Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => roleNotifier.value = AppNodeRole.host,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: currentRole == AppNodeRole.host
                                      ? AppColors.primary.withValues(alpha: 0.15)
                                      : (isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                  border: Border.all(
                                    color: currentRole == AppNodeRole.host ? AppColors.primaryLight : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      LucideIcons.server,
                                      size: 24,
                                      color: currentRole == AppNodeRole.host ? AppColors.primaryLight : AppColors.textMutedDark,
                                    ),
                                    const SizedBox(height: 6),
                                    const Text('Host Server (Hub)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const Text('Hosts DB & Sync Daemon', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryDark)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => roleNotifier.value = AppNodeRole.client,
                              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: currentRole == AppNodeRole.client
                                      ? AppColors.primary.withValues(alpha: 0.15)
                                      : (isDark ? const Color(0xFF030712) : const Color(0xFFF1F5F9)),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                  border: Border.all(
                                    color: currentRole == AppNodeRole.client ? AppColors.primaryLight : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      LucideIcons.laptop,
                                      size: 24,
                                      color: currentRole == AppNodeRole.client ? AppColors.primaryLight : AppColors.textMutedDark,
                                    ),
                                    const SizedBox(height: 6),
                                    const Text('Client Terminal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    const Text('Doctor / Cashier Station', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryDark)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ── Host vs Client Parameters ───────────────────────
                  ValueListenableBuilder<AppNodeRole>(
                    valueListenable: roleNotifier,
                    builder: (context, role, _) {
                      if (role == AppNodeRole.host) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Daemon Listen Port', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: hostPortController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixIcon: Icon(LucideIcons.hash, size: 16),
                                hintText: '3000',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.info.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              ),
                              child: const Row(
                                children: [
                                  Icon(LucideIcons.info, size: 16, color: AppColors.info),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'This device will act as the master sync hub on 0.0.0.0:3000 for all client stations.',
                                      style: TextStyle(fontSize: 11, color: AppColors.info),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }

                      // Client Mode Form
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Host Server URL', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: clientUrlController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(LucideIcons.globe, size: 16),
                              hintText: 'http://192.168.1.100:3000',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text('Optional Pairing Token / API Key', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: apiKeyController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(LucideIcons.key, size: 16),
                              hintText: 'Leave blank for open LAN pairing',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Test Connection Button
                          ValueListenableBuilder<bool>(
                            valueListenable: isTestingNotifier,
                            builder: (context, isTesting, _) {
                              return ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                  foregroundColor: isDark ? Colors.white : Colors.black87,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: isTesting
                                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(LucideIcons.activity, size: 16),
                                label: Text(isTesting ? 'Pinging Host...' : 'Test Connection'),
                                onPressed: isTesting
                                    ? null
                                    : () async {
                                        isTestingNotifier.value = true;
                                        final client = SyncNetworkClient(clientUrlController.text);
                                        final result = await client.checkServerHealth();
                                        isTestingNotifier.value = false;
                                        testResultNotifier.value = result;
                                      },
                              );
                            },
                          ),

                          // Test Result Badge
                          ValueListenableBuilder<ServerHealthResult?>(
                            valueListenable: testResultNotifier,
                            builder: (context, result, _) {
                              if (result == null) return const SizedBox.shrink();
                              final isSuccess = result.isSuccess;
                              return Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: (isSuccess ? AppColors.success : AppColors.danger).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                                  border: Border.all(color: isSuccess ? AppColors.success : AppColors.danger),
                                ),
                                child: Row(
                                  children: [
                                    Icon(isSuccess ? LucideIcons.checkCircle : LucideIcons.alertCircle, size: 16, color: isSuccess ? AppColors.success : AppColors.danger),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        isSuccess
                                            ? 'Connected • Latency: ${result.latencyMs}ms • v${result.version ?? "1.0.0"}'
                                            : 'Connection Failed: ${result.errorMessage}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: isSuccess ? AppColors.success : AppColors.danger,
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
                    },
                  ),
                  const SizedBox(height: 24),

                  // ── Save & Proceed Button ───────────────────────────
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.radiusSmall)),
                    ),
                    onPressed: () async {
                      final role = roleNotifier.value;
                      if (role == AppNodeRole.host) {
                        final port = int.tryParse(hostPortController.text) ?? 3000;
                        await connectionManager.startHostMode(port: port, persist: true);
                      } else {
                        final url = clientUrlController.text.trim();
                        final token = apiKeyController.text.trim();
                        await connectionManager.connectAsClient(
                          url,
                          'LAN',
                          authToken: token.isNotEmpty ? token : null,
                          persist: true,
                        );
                      }
                      onProceedToTerminal?.call();
                    },
                    child: const Text('Save Configuration & Launch Terminal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
