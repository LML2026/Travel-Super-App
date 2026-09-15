import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_super_app/core/theme/theme.dart';

void main() {
  group('AppTheme', () {
    test('uses ITAREVO light brand palette', () {
      final theme = AppTheme.light();

      expect(theme.colorScheme.primary, AppColors.navy);
      expect(theme.colorScheme.secondary, AppColors.champagne);
      expect(theme.scaffoldBackgroundColor, AppColors.ivory);
      expect(theme.cardTheme.color, AppColors.cardSurface);
      expect(theme.textTheme.bodyLarge?.color, AppColors.textPrimary);
    });

    test('applies global component foundation', () {
      final theme = AppTheme.light();

      expect(theme.appBarTheme.backgroundColor, AppColors.navy);
      expect(theme.appBarTheme.foregroundColor, AppColors.warmWhite);
      expect(theme.inputDecorationTheme.fillColor, AppColors.warmWhite);
      expect(theme.navigationBarTheme.backgroundColor, AppColors.warmWhite);

      final cardShape = theme.cardTheme.shape;
      expect(cardShape, isA<RoundedRectangleBorder>());
      expect(
        (cardShape as RoundedRectangleBorder).borderRadius,
        BorderRadius.circular(AppRadii.card),
      );
    });
  });
}
