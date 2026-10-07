import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Large, high-contrast text for outdoor use.
abstract final class AppTextStyles {
  static const TextTheme textTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      fontFeatures: [FontFeature.tabularFigures()], // timers don't jitter
    ),
    headlineMedium: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
    ),
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    titleMedium: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    ),
    bodyLarge: TextStyle(fontSize: 17, color: AppColors.textPrimary),
    bodyMedium: TextStyle(fontSize: 15, color: AppColors.textSecondary),
    labelLarge: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    ),
  );
}
