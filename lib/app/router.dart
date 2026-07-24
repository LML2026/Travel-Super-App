import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth_gate.dart';
import '../features/home/home_page.dart';
import '../features/navigation/main_navigation_page.dart';
import '../features/splash/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',

  routes: [

    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),

    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthGate(),
    ),

    GoRoute(
      path: '/home',
      builder: (context, state) => const MainNavigationPage(),
    ),

  ],
);
