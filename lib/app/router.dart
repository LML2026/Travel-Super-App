import 'package:go_router/go_router.dart';

import 'app_routes.dart';
import 'route_groups/auth_routes.dart';
import 'route_groups/core_routes.dart';
import 'route_groups/flight_routes.dart';
import 'route_groups/hotel_routes.dart';
import 'route_groups/trip_routes.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoute.splash.path,
    routes: [
      ...buildCoreRoutes(),
      ...buildAuthRoutes(),
      ...buildFlightRoutes(),
      ...buildHotelRoutes(),
      ...buildTripRoutes(),
    ],
  );
}
