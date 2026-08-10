import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import 'providers.dart';

class TravelSuperApp extends ConsumerWidget {
  const TravelSuperApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ITAREVO',
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
