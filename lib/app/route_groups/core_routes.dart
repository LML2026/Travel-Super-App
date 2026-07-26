import 'package:go_router/go_router.dart';

import '../../core/models/destination.dart';
import '../../features/ai/screens/ai_assistant_page.dart';
import '../../features/destinations/destination_detail_page.dart';
import '../../features/navigation/main_navigation_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/weather/pages/weather_page.dart';
import '../app_routes.dart';
import '../route_error_page.dart';

List<RouteBase> buildCoreRoutes() {
  return [
    GoRoute(
      name: AppRoute.splash.routeName,
      path: AppRoute.splash.path,
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      name: AppRoute.home.routeName,
      path: AppRoute.home.path,
      builder: (context, state) => const MainNavigationPage(),
    ),
    GoRoute(
      name: AppRoute.weather.routeName,
      path: AppRoute.weather.path,
      builder: (context, state) => const WeatherPage(),
    ),
    GoRoute(
      name: AppRoute.aiAssistant.routeName,
      path: AppRoute.aiAssistant.path,
      builder: (context, state) => const AiAssistantPage(),
    ),
    GoRoute(
      name: AppRoute.profile.routeName,
      path: AppRoute.profile.path,
      builder: (context, state) => const ProfilePage(),
    ),
    GoRoute(
      name: AppRoute.destination.routeName,
      path: AppRoute.destination.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! Destination) {
          return const RouteErrorPage(
            message: 'Destination route requires a Destination extra payload.',
          );
        }
        return DestinationDetailPage(destination: extra);
      },
    ),
  ];
}
