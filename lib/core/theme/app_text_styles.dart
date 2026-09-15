import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const String? fontFamily = null;

  static const display = TextStyle(
    fontSize: 34,
    height: 1.12,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const heading = TextStyle(
    fontSize: 26,
    height: 1.18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const title = TextStyle(
    fontSize: 20,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const subtitle = TextStyle(
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const body = TextStyle(
    fontSize: 15,
    height: 1.48,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const bodyMuted = TextStyle(
    fontSize: 14,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const label = TextStyle(
    fontSize: 13,
    height: 1.25,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static const button = TextStyle(
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w700,
  );

  static const price = TextStyle(
    fontSize: 22,
    height: 1.16,
    fontWeight: FontWeight.w700,
    color: AppColors.navy,
  );
}
