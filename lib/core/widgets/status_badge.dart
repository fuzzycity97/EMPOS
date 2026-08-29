import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory StatusBadge.paid() {
    return const StatusBadge(
      label: 'PAID',
      backgroundColor: AppColors.successLight,
      textColor: AppColors.success,
    );
  }

  factory StatusBadge.refunded() {
    return const StatusBadge(
      label: 'REFUNDED',
      backgroundColor: AppColors.dangerLight,
      textColor: AppColors.danger,
    );
  }

  factory StatusBadge.pending() {
    return const StatusBadge(
      label: 'PENDING',
      backgroundColor: AppColors.warningLight,
      textColor: AppColors.warning,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.space8,
        vertical: AppDimensions.space4,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: AppDimensions.space4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
