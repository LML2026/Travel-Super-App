import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.navy,
      brightness: Brightness.light,
      primary: AppColors.navy,
      onPrimary: AppColors.warmWhite,
      secondary: AppColors.champagne,
      onSecondary: AppColors.midnight,
      tertiary: AppColors.navy600,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      error: AppColors.error,
      onError: AppColors.warmWhite,
    );
    final textTheme = _textTheme();
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      disabledColor: AppColors.disabledText,
      dividerColor: AppColors.border,
      fontFamily: AppTextStyles.fontFamily,
      iconTheme: const IconThemeData(color: AppColors.navy600, size: 22),
      primaryIconTheme:
          const IconThemeData(color: AppColors.warmWhite, size: 22),
      textTheme: textTheme,
      primaryTextTheme: textTheme.apply(bodyColor: AppColors.warmWhite),
      visualDensity: VisualDensity.standard,
      splashColor: AppColors.champagne.withValues(alpha: 0.12),
      highlightColor: AppColors.champagne.withValues(alpha: 0.08),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.warmWhite,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.midnight.withValues(alpha: 0.2),
        iconTheme: const IconThemeData(color: AppColors.warmWhite),
        actionsIconTheme: const IconThemeData(color: AppColors.warmWhite),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          color: AppColors.warmWhite,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardSurface,
        surfaceTintColor: Colors.transparent,
        shadowColor: AppColors.midnight.withValues(alpha: 0.16),
        elevation: 1.5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: AppSpacing.lg,
      ),
      filledButtonTheme: _filledButtonTheme(),
      elevatedButtonTheme: _elevatedButtonTheme(),
      outlinedButtonTheme: _outlinedButtonTheme(),
      textButtonTheme: _textButtonTheme(),
      iconButtonTheme: _iconButtonTheme(),
      inputDecorationTheme: _inputDecorationTheme(),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: AppColors.warmWhite,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.champagne100,
        shadowColor: AppColors.midnight.withValues(alpha: 0.1),
        elevation: 4,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.navy);
          }
          return const IconThemeData(color: AppColors.textMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final color = states.contains(WidgetState.selected)
              ? AppColors.navy
              : AppColors.textMuted;
          return AppTextStyles.label.copyWith(color: color);
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.warmWhite,
        selectedItemColor: AppColors.navy,
        unselectedItemColor: AppColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.navy50,
        selectedColor: AppColors.champagne100,
        disabledColor: AppColors.disabledFill,
        labelStyle: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        secondaryLabelStyle:
            AppTextStyles.label.copyWith(color: AppColors.navy),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.warmWhite,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.xl),
        ),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.midnight,
        contentTextStyle:
            AppTextStyles.body.copyWith(color: AppColors.warmWhite),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.md),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.champagne,
        linearTrackColor: AppColors.champagne100,
        circularTrackColor: AppColors.champagne100,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.navy,
        selectionColor: AppColors.champagne.withValues(alpha: 0.28),
        selectionHandleColor: AppColors.champagne,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.champagne;
          }
          return AppColors.textSubtle;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.champagne100;
          }
          return AppColors.disabledFill;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.navy;
          }
          return Colors.transparent;
        }),
        checkColor: const WidgetStatePropertyAll(AppColors.warmWhite),
        side: const BorderSide(color: AppColors.borderStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm / 2),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.navy;
          }
          return AppColors.textMuted;
        }),
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.navy600,
        textColor: AppColors.textPrimary,
        titleTextStyle: AppTextStyles.title,
        subtitleTextStyle: AppTextStyles.bodyMuted,
      ),
    );
  }

  static TextTheme _textTheme() {
    return const TextTheme(
      displayLarge: AppTextStyles.display,
      displayMedium: AppTextStyles.heading,
      displaySmall: AppTextStyles.title,
      headlineLarge: AppTextStyles.heading,
      headlineMedium: TextStyle(
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      headlineSmall: AppTextStyles.title,
      titleLarge: AppTextStyles.title,
      titleMedium: TextStyle(
        fontSize: 17,
        height: 1.32,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      titleSmall: AppTextStyles.label,
      bodyLarge: AppTextStyles.body,
      bodyMedium: TextStyle(
        fontSize: 14,
        height: 1.48,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
      ),
      bodySmall: AppTextStyles.bodyMuted,
      labelLarge: AppTextStyles.button,
      labelMedium: AppTextStyles.label,
      labelSmall: TextStyle(
        fontSize: 11,
        height: 1.25,
        fontWeight: FontWeight.w600,
        color: AppColors.textSubtle,
      ),
    );
  }

  static FilledButtonThemeData _filledButtonTheme() {
    return FilledButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.disabledFill;
          }
          return AppColors.navy;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.disabledText;
          }
          return AppColors.warmWhite;
        }),
        overlayColor: WidgetStatePropertyAll(
          AppColors.champagne.withValues(alpha: 0.14),
        ),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
        ),
        minimumSize: const WidgetStatePropertyAll(Size(64, 48)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.button),
          ),
        ),
        textStyle: const WidgetStatePropertyAll(AppTextStyles.button),
      ),
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.warmWhite,
        disabledBackgroundColor: AppColors.disabledFill,
        disabledForegroundColor: AppColors.disabledText,
        elevation: 1.5,
        shadowColor: AppColors.midnight.withValues(alpha: 0.2),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme() {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.navy,
        disabledForegroundColor: AppColors.disabledText,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        minimumSize: const Size(64, 48),
        side: const BorderSide(color: AppColors.borderStrong),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.navy,
        disabledForegroundColor: AppColors.disabledText,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: AppTextStyles.button,
      ),
    );
  }

  static IconButtonThemeData _iconButtonTheme() {
    return IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return AppColors.disabledText;
          }
          return AppColors.navy600;
        }),
        overlayColor: WidgetStatePropertyAll(
          AppColors.champagne.withValues(alpha: 0.12),
        ),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme() {
    final radius = BorderRadius.circular(AppRadii.input);
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.warmWhite,
      hoverColor: AppColors.navy50,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      labelStyle: AppTextStyles.bodyMuted,
      hintStyle: AppTextStyles.bodyMuted.copyWith(color: AppColors.textSubtle),
      prefixIconColor: AppColors.navy600,
      suffixIconColor: AppColors.textMuted,
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.champagne, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.error, width: 1.6),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.disabledFill),
      ),
    );
  }

  static ThemeData get lightTheme => light();
}
