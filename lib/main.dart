import 'package:flutter/material.dart';

import 'core/maps_config.dart';
import 'core/maps_loader.dart';
import 'core/theme/app_theme.dart';
import 'shells/app_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadGoogleMaps(MapsConfig.apiKey);
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
