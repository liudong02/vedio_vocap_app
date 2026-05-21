import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary gradient endpoints
  static const primaryBlue = Color(0xFF4A90D9);
  static const primaryPurple = Color(0xFF7B61FF);

  // Gradient definitions
  static const primaryGradient = LinearGradient(
    colors: [primaryBlue, primaryPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [Color(0xFFF0F4FF), Color(0xFFF5F0FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Surface colors
  static const surface = Color(0xFFFFFFFF);
  static const surfaceLight = Color(0xFFF8F9FE);
  static const surfaceMuted = Color(0xFFF0F1F7);

  // Text hierarchy
  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecondary = Color(0xFF6B7080);
  static const textTertiary = Color(0xFF9CA3B4);

  // Semantic colors (review grades)
  static const gradeAgain = Color(0xFFE85D5D);
  static const gradeHard = Color(0xFFEE9B3B);
  static const gradeGood = Color(0xFF5B8DEF);
  static const gradeEasy = Color(0xFF4FBF7B);

  // Borders and accents
  static const borderLight = Color(0xFFE8EAF0);
  static const accentGlow = Color(0x1A7B61FF);
}
