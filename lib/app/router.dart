import 'package:go_router/go_router.dart';

import '../core/models/destination.dart';
import '../features/auth/auth_gate.dart';
import '../features/trip_planner/pages/trip_planner_page.dart';
import '../features/flights/pages/flights_page.dart';
import '../features/navigation/main_navigation_page.dart';
import '../features/destinations/destination_detail_page.dart';
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

    GoRoute(
      path: '/trips',
      builder: (context, state) => const TripPlannerPage(),
    ),

    GoRoute(
      path: '/flights',
      builder: (context, state) => const FlightsPage(),
    ),

    GoRoute(
      path: '/destination',
      builder: (context, state) {
        final destination = state.extra as Destination;
        return DestinationDetailPage(destination: destination);
      },
    ),

  ],
);
