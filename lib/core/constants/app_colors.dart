import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Royal Indigo
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);
  static const Color primaryBg = Color(0xFFEEF2FF);

  // Accent Palette - Emerald Green (Signifies payments, success, growth)
  static const Color accent = Color(0xFF059669);
  static const Color accentLight = Color(0xFF34D399);
  static const Color accentBg = Color(0xFFECFDF5);

  // Amber / Gold (for Receipt branding, alerts)
  static const Color amber = Color(0xFFD97706);
  static const Color amberLight = Color(0xFFFBBF24);
  static const Color amberBg = Color(0xFFFFFBEB);

  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color destructive = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // WhatsApp Color
  static const Color whatsApp = Color(0xFF25D366);

  // Light Mode Surfaces
  static const Color lightBg = Color(0xFFF8FAFC);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0F172A);
  static const Color lightTextSecondary = Color(0xFF475569);
  static const Color lightTextMuted = Color(0xFF64748B);
  static const Color lightBorder = Color(0xFFCBD5E1);
  static const Color lightInputBg = Color(0xFFF1F5F9);

  // Dark Mode Surfaces (Sleek Obsidian)
  static const Color darkBg = Color(0xFF0B0F17);
  static const Color darkCard = Color(0xFF161E2E);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextMuted = Color(0xFF94A3B8);
  static const Color darkBorder = Color(0xFF26334D);
  static const Color darkInputBg = Color(0xFF1F293D);

  // Common aliases
  static const Color cardBackground = lightCard;
  static const Color textPrimary = lightTextPrimary;
  static const Color textSecondary = lightTextSecondary;
  static const Color textMuted = lightTextMuted;
  static const Color whatsappGreen = whatsApp;
}
