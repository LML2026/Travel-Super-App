import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    cardTheme: const CardThemeData(
      elevation: 3,
      margin: EdgeInsets.all(8),
    ),
  );
}
