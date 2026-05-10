import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primaire
  static const primary      = Color(0xFF2D8A8A);
  static const primaryLight = Color(0xFF3FA5A5);
  static const primaryDark  = Color(0xFF1F6060);

  // Secondaire
  static const secondary     = Color(0xFFF4D03F);
  static const secondaryDark = Color(0xFFD4AF37);

  // Accents
  static const accentGreen     = Color(0xFF27AE60);
  static const accentDarkGreen = Color(0xFF1E8449);

  // Sémantiques
  static const success = Color(0xFF10B981);
  static const error   = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info    = Color(0xFF3B82F6);

  // Neutres
  static const white   = Color(0xFFFFFFFF);
  static const gray50  = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray300 = Color(0xFFD1D5DB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const gray900 = Color(0xFF111827);
  static const black   = Color(0xFF000000);

  // Dark mode surfaces
  static const darkBg      = Color(0xFF111827);
  static const darkSurface = Color(0xFF1F2937);
  static const darkCard    = Color(0xFF374151);
}
