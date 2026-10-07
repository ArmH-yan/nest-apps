import 'package:flutter/material.dart';

/// Construction-safety palette. Widgets never hard-code colors; they use
/// `Theme.of(context)` or these tokens (CLAUDE.md, WORKER_APP_SPEC "Design system").
abstract final class AppColors {
  static const Color primary = Color(0xFFFFC400); // construction yellow
  static const Color onPrimary = Color(0xFF1A1A1A);
  static const Color charcoal = Color(0xFF1F2124);
  static const Color background = Color(0xFFF4F5F6); // light gray
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color outline = Color(0xFFD5D8DC);

  static const Color success = Color(0xFF1E8E3E);
  static const Color warning = Color(0xFFE37400);
  static const Color error = Color(0xFFC5221F);

  /// Status colors that must never be confused on the Work screen.
  static const Color working = success;
  static const Color onBreak = Color(0xFF1A73E8);
}
