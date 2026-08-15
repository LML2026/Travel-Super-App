import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_elevation.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = AppColors.ink;
  static const Color background = AppColors.lightBackground;
  static const Color surface = AppColors.lightSurface;

  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      textTheme: AppTypography.light,
    );
  }

  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      textTheme: AppTypography.dark,
    );
  }

  static ColorScheme get _lightColorScheme =>
      ColorScheme.fromSeed(
        seedColor: AppColors.ocean,
        brightness: Brightness.light,
      ).copyWith(
        primary: AppColors.ink,
        onPrimary: Colors.white,
        secondary: AppColors.ocean,
        onSecondary: Colors.white,
        tertiary: AppColors.jade,
        onTertiary: Colors.white,
        error: AppColors.lightError,
        surface: AppColors.lightSurface,
        surfaceContainerHighest: AppColors.lightSurfaceVariant,
        outline: AppColors.lightOutline,
      );

  static ColorScheme get _darkColorScheme =>
      ColorScheme.fromSeed(
        seedColor: AppColors.ocean,
        brightness: Brightness.dark,
      ).copyWith(
        primary: Color(0xFF9CC7D8),
        onPrimary: AppColors.ink,
        secondary: Color(0xFF9CC7D8),
        onSecondary: AppColors.ink,
        tertiary: Color(0xFF8FD0B9),
        onTertiary: AppColors.ink,
        error: AppColors.darkError,
        surface: AppColors.darkSurface,
        surfaceContainerHighest: AppColors.darkSurfaceVariant,
        outline: AppColors.darkOutline,
      );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required ColorScheme colorScheme,
    required TextTheme textTheme,
  }) {
    final isLight = brightness == Brightness.light;
    final backgroundColor = isLight
        ? AppColors.lightBackground
        : AppColors.darkBackground;
    final surfaceColor = isLight
        ? AppColors.lightSurface
        : AppColors.darkSurface;
    final mutedColor = colorScheme.onSurface.withAlpha(isLight ? 150 : 180);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundColor,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundColor,
        foregroundColor: colorScheme.onSurface,
        elevation: AppElevation.flat,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: AppElevation.flat,
        color: surfaceColor,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: AppRadii.mediumBorder.copyWith(
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          shape: const WidgetStatePropertyAll(AppRadii.smallBorder),
          tapTargetSize: MaterialTapTargetSize.padded,
          overlayColor: WidgetStatePropertyAll(
            colorScheme.onPrimary.withAlpha(28),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          ),
          shape: const WidgetStatePropertyAll(AppRadii.smallBorder),
          side: WidgetStatePropertyAll(BorderSide(color: colorScheme.outline)),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          shape: const WidgetStatePropertyAll(AppRadii.smallBorder),
          tapTargetSize: MaterialTapTargetSize.padded,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: const WidgetStatePropertyAll(Size.square(48)),
          tapTargetSize: MaterialTapTargetSize.padded,
          shape: const WidgetStatePropertyAll(AppRadii.smallBorder),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        labelStyle: TextStyle(color: mutedColor),
        hintStyle: TextStyle(color: mutedColor),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.small)),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.small)),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.small)),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.small)),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.small)),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: AppElevation.flat,
        backgroundColor: surfaceColor,
        indicatorColor: colorScheme.secondaryContainer,
        labelTextStyle: WidgetStatePropertyAll(textTheme.labelMedium),
      ),
      dialogTheme: DialogThemeData(
        elevation: AppElevation.dialog,
        shape: AppRadii.largeBorder,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: AppSpacing.lg,
      ),
    );
  }
}
