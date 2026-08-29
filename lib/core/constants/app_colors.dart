import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand Palette
  static const Color primary = Color(0xFF2563EB); // Modern Royal Blue
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFF60A5FA);
  static const Color primaryGradientStart = Color(0xFF3B82F6);
  static const Color primaryGradientEnd = Color(0xFF1D4ED8);

  // Secondary & Accents
  static const Color secondary = Color(0xFF0D9488); // Teal
  static const Color accent = Color(0xFF8B5CF6); // Purple

  // Neutral / Backgrounds
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceElevatedLight = Color(0xFFF1F5F9);
  static const Color borderLight = Color(0xFFE2E8F0);

  // Dark Mode Surfaces (Deep Slate & Charcoal)
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color surfaceDark = Color(0xFF1E293B);
  static const Color surfaceElevatedDark = Color(0xFF334155);
  static const Color borderDark = Color(0xFF334155);

  // Typography
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textMutedLight = Color(0xFF94A3B8);

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);
  static const Color textMutedDark = Color(0xFF64748B);

  // Status & Feedback
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color emerald = success;
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444); // Rose/Red
  static const Color error = danger;
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9); // Sky blue
  static const Color cyan = info;
  static const Color infoLight = Color(0xFFE0F2FE);

  // POS Payment Method Tender Badges
  static const Color tenderCash = Color(0xFF10B981);
  static const Color tenderCard = Color(0xFF3B82F6);
  static const Color tenderInstapay = Color(0xFFEC4899);
  static const Color tenderVodafone = Color(0xFFE11D48);
  static const Color tenderAccount = Color(0xFF8B5CF6);

  // POS Status
  static const Color statusPaid = Color(0xFF10B981);
  static const Color statusRefunded = Color(0xFFEF4444);
  static const Color statusPending = Color(0xFFF59E0B);
  static const Color statusParked = Color(0xFF6366F1);
}
