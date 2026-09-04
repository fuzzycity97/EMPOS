import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/config/domain/entities/industry_type.dart';
import '../../../../core/config/subscription/subscription_tier_models.dart';
import '../../../../core/config/subscription/subscription_tier_controller.dart';
import '../../domain/entities/super_admin_models.dart';
import '../widgets/super_admin_account_detail_view.dart';

/// Super-Admin Subscription Management Page.
/// Provides exhaustive account listing, real-time search, multi-faceted filtering,
/// live usage signal telemetry, persistent notes, and granular capability management.
class SuperAdminSubscriptionManagementPage extends StatefulWidget {
  final SuperAdminSession? session;
  final SubscriptionTierController controller;

  const SuperAdminSubscriptionManagementPage({
    super.key,
    required this.session,
    required this.controller,
  });

  @override
  State<SuperAdminSubscriptionManagementPage> createState() =>
      _SuperAdminSubscriptionManagementPageState();
}

class _SuperAdminSubscriptionManagementPageState
    extends State<SuperAdminSubscriptionManagementPage> {
  String _searchQuery = '';
  IndustryVertical? _selectedVertical;
  SubscriptionPlanTier? _selectedTier;
  bool? _selectedActiveStatus;
  String? _selectedAccountId;

  @override
  void initState() {
    super.initState();
    _seedDefaultAccountsIfEmpty();
  }

  void _seedDefaultAccountsIfEmpty() {
    if (widget.controller.getAllAccounts().isEmpty) {
      widget.controller.getOrCreateAccount(
        accountId: 'acc_cairo_dental',
        businessName: 'Cairo Dental Excellence & Implant Center',
        vertical: IndustryVertical.medical,
        initialTier: SubscriptionPlanTier.pro,
      );
      widget.controller.getOrCreateAccount(
        accountId: 'acc_nile_pharmacy',
        businessName: 'Nile Community Pharmacy & Compounding',
        vertical: IndustryVertical.medical,
        initialTier: SubscriptionPlanTier.basic,
      );
      widget.controller.getOrCreateAccount(
        accountId: 'acc_pyramids_gym',
        businessName: 'Pyramids Performance Athletic Gym',
        vertical: IndustryVertical.fitnessSports,
        initialTier: SubscriptionPlanTier.free,
      );
      widget.controller.getOrCreateAccount(
        accountId: 'acc_alex_bistro',
        businessName: 'Alexandria Mediterranean Dine-In Bistro',
        vertical: IndustryVertical.foodBeverage,
        initialTier: SubscriptionPlanTier.enterprise,
      );
      widget.controller.getOrCreateAccount(
        accountId: 'acc_redsea_salon',
        businessName: 'Red Sea Luxury Spa & Wellness Salon',
        vertical: IndustryVertical.beautyPersonalCare,
        initialTier: SubscriptionPlanTier.basic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Strict Vendor Operator Access Control Barrier
    if (widget.session == null || !widget.session!.isValid) {
      return _buildAccessDeniedBarrier(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              ),
              child: const Icon(LucideIcons.shieldCheck, size: 20, color: AppColors.primaryLight),
            ),
            const SizedBox(width: 12),
            const Flexible(
              child: Text(
                'Super-Admin Subscription & Capability Fleet Console',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  widget.session!.vendorOrganization,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
              ],
            ),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, _) {
          final allAccounts = widget.controller.getAllAccounts();
          final filteredAccounts = _applyFilters(allAccounts);

          // Auto-select first if none selected
          if (_selectedAccountId == null && filteredAccounts.isNotEmpty) {
            _selectedAccountId = filteredAccounts.first.accountId;
          }

          final selectedAccount = allAccounts.firstWhere(
            (a) => a.accountId == _selectedAccountId,
            orElse: () => filteredAccounts.isNotEmpty
                ? filteredAccounts.first
                : allAccounts.first,
          );

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Top Search & Multi-Filter Bar
                    _buildSearchAndFilterBar(context, isDark, allAccounts.length, filteredAccounts.length),
                    const SizedBox(height: 16),

                    // Main Content Split View
                    Expanded(
                      child: isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Left Pane: Filtered Account List View
                                Expanded(
                                  flex: 4,
                                  child: _buildAccountListView(
                                    context,
                                    filteredAccounts,
                                    isDark,
                                  ),
                                ),
                                const SizedBox(width: 16),

                                // Right Pane: Active Account Detailed Inspection View
                                Expanded(
                                  flex: 6,
                                  child: allAccounts.isEmpty
                                      ? const Center(child: Text('No accounts found'))
                                      : SuperAdminAccountDetailView(
                                          key: ValueKey(selectedAccount.accountId),
                                          account: selectedAccount,
                                          controller: widget.controller,
                                        ),
                                ),
                              ],
                            )
                          : _buildNarrowScreenLayout(
                              context,
                              filteredAccounts,
                              selectedAccount,
                              isDark,
                            ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  List<AccountSubscriptionProfile> _applyFilters(
    List<AccountSubscriptionProfile> accounts,
  ) {
    return accounts.where((acc) {
      // 1. Search Query Filter
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.trim().toLowerCase();
        final matchName = acc.businessName.toLowerCase().contains(q);
        final matchId = acc.accountId.toLowerCase().contains(q);
        if (!matchName && !matchId) return false;
      }

      // 2. Vertical Category Filter
      if (_selectedVertical != null && acc.vertical != _selectedVertical) {
        return false;
      }

      // 3. Plan Tier Filter
      if (_selectedTier != null && acc.assignedTier != _selectedTier) {
        return false;
      }

      // 4. Active Status Filter
      if (_selectedActiveStatus != null && acc.isActive != _selectedActiveStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildSearchAndFilterBar(
    BuildContext context,
    bool isDark,
    int totalCount,
    int filteredCount,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Search Input
              Expanded(
                flex: 3,
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(LucideIcons.search, size: 16),
                    hintText: 'Search business name or account ID...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: const OutlineInputBorder(),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(LucideIcons.x, size: 14),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              const SizedBox(width: 12),

              // Filter by Vertical
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<IndustryVertical?>(
                  isExpanded: true,
                  initialValue: _selectedVertical,
                  decoration: const InputDecoration(
                    labelText: 'Vertical Category',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Verticals')),
                    ...IndustryVertical.values.map((v) {
                      return DropdownMenuItem(value: v, child: Text(v.label));
                    }),
                  ],
                  onChanged: (v) => setState(() => _selectedVertical = v),
                ),
              ),
              const SizedBox(width: 12),

              // Filter by Tier
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<SubscriptionPlanTier?>(
                  isExpanded: true,
                  initialValue: _selectedTier,
                  decoration: const InputDecoration(
                    labelText: 'Plan Tier',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Tiers')),
                    ...SubscriptionPlanTier.values.map((t) {
                      return DropdownMenuItem(value: t, child: Text(t.label));
                    }),
                  ],
                  onChanged: (t) => setState(() => _selectedTier = t),
                ),
              ),
              const SizedBox(width: 12),

              // Filter by Status
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<bool?>(
                  isExpanded: true,
                  initialValue: _selectedActiveStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: true, child: Text('Active Only')),
                    DropdownMenuItem(value: false, child: Text('Suspended Only')),
                  ],
                  onChanged: (s) => setState(() => _selectedActiveStatus = s),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Showing $filteredCount of $totalCount registered tenant accounts',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  icon: const Icon(LucideIcons.rotateCcw, size: 12),
                  label: const Text('Clear All Filters', style: TextStyle(fontSize: 11)),
                  onPressed: _clearFilters,
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _selectedVertical != null ||
      _selectedTier != null ||
      _selectedActiveStatus != null;

  void _clearFilters() {
    setState(() {
      _searchQuery = '';
      _selectedVertical = null;
      _selectedTier = null;
      _selectedActiveStatus = null;
    });
  }

  Widget _buildAccountListView(
    BuildContext context,
    List<AccountSubscriptionProfile> accounts,
    bool isDark,
  ) {
    if (accounts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(LucideIcons.searchX, size: 36, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            const SizedBox(height: 10),
            const Text(
              'No matching accounts found',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            const Text('Try adjusting your search terms or filter selections.', style: TextStyle(fontSize: 12)),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        border: Border.all(color: isDark ? AppColors.borderDark : Colors.black12),
      ),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: accounts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (ctx, idx) {
          final account = accounts[idx];
          final isSelected = account.accountId == _selectedAccountId;

          final tierColor = _getTierBadgeColor(account.assignedTier);
          final createdDate = account.createdAt.toIso8601String().substring(0, 10);
          final lastActiveDate = account.updatedAt.toIso8601String().substring(0, 10);

          return InkWell(
            onTap: () {
              setState(() {
                _selectedAccountId = account.accountId;
              });
            },
            borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.08)
                    : isDark
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryLight
                      : isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0),
                  width: isSelected ? 1.5 : 1.0,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tier Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: tierColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: tierColor.withValues(alpha: 0.5)),
                        ),
                        child: Text(
                          account.assignedTier.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: tierColor,
                          ),
                        ),
                      ),
                      // Status Pill
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: account.isActive ? AppColors.success : AppColors.danger,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            account.isActive ? 'Active' : 'Suspended',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: account.isActive ? AppColors.success : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Business Name
                  Text(
                    account.businessName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  // Vertical Category Breadcrumb
                  Text(
                    account.vertical.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Creation & Last Active Timestamps
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Created: $createdDate',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                      Text(
                        'Last Active: $lastActiveDate',
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNarrowScreenLayout(
    BuildContext context,
    List<AccountSubscriptionProfile> filteredAccounts,
    AccountSubscriptionProfile selectedAccount,
    bool isDark,
  ) {
    return Column(
      children: [
        Expanded(
          flex: 4,
          child: _buildAccountListView(context, filteredAccounts, isDark),
        ),
        const SizedBox(height: 12),
        Expanded(
          flex: 6,
          child: SuperAdminAccountDetailView(
            key: ValueKey(selectedAccount.accountId),
            account: selectedAccount,
            controller: widget.controller,
          ),
        ),
      ],
    );
  }

  Color _getTierBadgeColor(SubscriptionPlanTier tier) {
    switch (tier) {
      case SubscriptionPlanTier.free:
        return const Color(0xFF64748B); // Slate
      case SubscriptionPlanTier.basic:
        return const Color(0xFF3B82F6); // Blue
      case SubscriptionPlanTier.pro:
        return const Color(0xFF8B5CF6); // Purple
      case SubscriptionPlanTier.enterprise:
        return const Color(0xFFF59E0B); // Amber
      case SubscriptionPlanTier.custom:
        return const Color(0xFF06B6D4); // Cyan
    }
  }

  Widget _buildAccessDeniedBarrier(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          constraints: const BoxConstraints(maxWidth: 480),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(LucideIcons.shieldAlert, size: 48, color: AppColors.danger),
              const SizedBox(height: 16),
              const Text(
                'Super-Admin Access Denied',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'This subscription capability console is restricted exclusively to authenticated EMPOS platform vendor operators. Clinic administrators and staff roles cannot access this panel.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
