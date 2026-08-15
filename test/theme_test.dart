import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:itarevo/core/theme/app_colors.dart';
import 'package:itarevo/core/theme/app_radii.dart';
import 'package:itarevo/core/theme/app_spacing.dart';
import 'package:itarevo/core/theme/app_theme.dart';

void main() {
  test('spacing and radius scales are ordered', () {
    expect([
      AppSpacing.xxs,
      AppSpacing.xs,
      AppSpacing.sm,
      AppSpacing.md,
      AppSpacing.lg,
      AppSpacing.xl,
      AppSpacing.xxl,
    ], orderedEquals([4, 8, 12, 16, 24, 32, 48]));
    expect([
      AppRadii.small,
      AppRadii.medium,
      AppRadii.large,
    ], orderedEquals([8, 12, 16]));
  });

  test('light and dark themes expose semantic Material roles', () {
    final light = AppTheme.lightTheme;
    final dark = AppTheme.darkTheme;

    expect(light.useMaterial3, isTrue);
    expect(dark.useMaterial3, isTrue);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
    expect(light.colorScheme.primary, AppColors.ink);
    expect(light.colorScheme.secondary, AppColors.ocean);
    expect(light.colorScheme.tertiary, AppColors.jade);
    expect(light.filledButtonTheme.style, isNotNull);
    expect(light.outlinedButtonTheme.style, isNotNull);
    expect(light.textButtonTheme.style, isNotNull);
    expect(light.iconButtonTheme.style, isNotNull);
    expect(light.inputDecorationTheme.border, isA<OutlineInputBorder>());
    expect(light.cardTheme.shape, isNotNull);
    expect(dark.scaffoldBackgroundColor, isNot(light.scaffoldBackgroundColor));
  });

  testWidgets('representative international scripts build under both themes', (
    tester,
  ) async {
    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: const Column(
            children: [
              Text('العربية فارسی Русский'),
              Text('中文 日本語 한국어'),
              Text('हिन्दी ქართული Հայերեն'),
            ],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Text), findsNWidgets(3));
    }
  });
}
