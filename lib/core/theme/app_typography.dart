import 'package:flutter/material.dart';

class AppTypography {
  AppTypography._();

  static TextTheme get light =>
      _base.apply(bodyColor: Colors.black87, displayColor: Colors.black87);
  static TextTheme get dark =>
      _base.apply(bodyColor: Colors.white, displayColor: Colors.white);

  static TextTheme get _base {
    final base = Typography.material2021().black;
    return base.copyWith(
      displayLarge: base.displayLarge?.copyWith(fontWeight: FontWeight.w700),
      displayMedium: base.displayMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: base.headlineMedium?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      titleLarge: base.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: base.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }
}
