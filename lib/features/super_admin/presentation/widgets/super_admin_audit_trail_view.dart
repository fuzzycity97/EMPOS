import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/config/subscription/subscription_audit_log.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class SuperAdminAuditTrailView extends StatelessWidget {
  final String? accountIdFilter;

  const SuperAdminAuditTrailView({
    super.key,
    this.accountIdFilter,
  });

  @override
  Widget build(BuildContext context) {
    final auditLog = SubscriptionAuditLog.instance;
    final records = accountIdFilter != null
        ? auditLog.getRecordsForAccount(accountIdFilter!)
        : auditLog.records;

    if (records.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppDimensions.space32),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.fileClock, size: 48, color: AppColors.textMutedDark.withValues(alpha: 0.4)),
            const SizedBox(height: AppDimensions.space16),
            Text(
              'No audit records recorded yet.',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textMutedDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All capability overrides and tier mutations write an immutable log here.',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.textMutedDark.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const ClampingScrollPhysics(),
      itemCount: records.length,
      separatorBuilder: (_, _) => const Divider(color: AppColors.borderDark, height: 1),
      itemBuilder: (context, index) {
        final record = records[index];
        return _AuditRecordTile(record: record);
      },
    );
  }
}

class _AuditRecordTile extends StatelessWidget {
  final SubscriptionAuditRecord record;

  const _AuditRecordTile({required this.record});

  Color _getActionColor() {
    switch (record.action) {
      case SubscriptionAuditAction.tierChanged:
        return const Color(0xFF6366F1); // Indigo
      case SubscriptionAuditAction.overrideSet:
        return const Color(0xFF10B981); // Emerald
      case SubscriptionAuditAction.overrideCleared:
        return const Color(0xFFF59E0B); // Amber
      case SubscriptionAuditAction.overridesReset:
        return const Color(0xFFEF4444); // Red
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionColor = _getActionColor();
        final ts = record.timestamp;
    final timeStr = '${ts.year}-${ts.month.toString().padLeft(2, '0')}-${ts.day.toString().padLeft(2, '0')} ${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space16,
        vertical: AppDimensions.space12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppDimensions.space8),
            decoration: BoxDecoration(
              color: actionColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
              border: Border.all(color: actionColor.withValues(alpha: 0.3)),
            ),
            child: Icon(LucideIcons.shieldCheck, size: 16, color: actionColor),
          ),
          const SizedBox(width: AppDimensions.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: actionColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        record.actionLabel,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: actionColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'by ${record.adminId}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.textMutedDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeStr,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: AppColors.textMutedDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Target: ',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textMutedDark,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        record.targetKey,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 12,
                          color: AppColors.textPrimaryDark,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Text(
                        record.oldValue,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          color: AppColors.textMutedDark,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(LucideIcons.arrowRight, size: 12, color: AppColors.textMutedDark),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: actionColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: actionColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        record.newValue,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: actionColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
