import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'router.dart';

class TravelSuperApp extends StatelessWidget {
  const TravelSuperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Travel Super App',
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
