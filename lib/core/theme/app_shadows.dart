import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A071A2F),
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
  ];

  static const List<BoxShadow> subtle = [
    BoxShadow(
      color: Color(0x12071A2F),
      blurRadius: 12,
      offset: Offset(0, 6),
    ),
  ];

  static const Color shadowColor = AppColors.midnight;
}
