import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1565C0);
  static const Color secondary = Color(0xFF26A69A);

  static const Color success = Color(0xFF2E7D32);
  static const Color warning = Color(0xFFF9A825);
  static const Color error = Color(0xFFC62828);

  static const Color background = Color(0xFFF5F7FA);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);

  // Backward-compatible aliases used in existing features.
  static const Color card = surface;
  static const Color text = textPrimary;
  static const Color subtitle = textSecondary;
}
