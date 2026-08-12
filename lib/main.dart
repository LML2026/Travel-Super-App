import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'shells/app_shell.dart';

void main() {
  runApp(const ItarevoApp());
}

class ItarevoApp extends StatelessWidget {
  const ItarevoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ITAREVO',
      theme: AppTheme.lightTheme,
      home: const AppShell(),
    );
  }
}
