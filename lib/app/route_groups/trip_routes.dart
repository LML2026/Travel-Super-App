import 'package:go_router/go_router.dart';

import '../../features/trips/models/trip.dart';
import '../../features/trips/presentation/screens/create_trip_page.dart';
import '../../features/trips/presentation/screens/trip_details_page.dart';
import '../../features/trips/presentation/screens/trip_list_page.dart';
import '../app_routes.dart';
import '../route_error_page.dart';

List<RouteBase> buildTripRoutes() {
  return [
    GoRoute(
      name: AppRoute.trips.routeName,
      path: AppRoute.trips.path,
      builder: (context, state) => const TripListPage(),
    ),
    GoRoute(
      name: AppRoute.tripCreate.routeName,
      path: AppRoute.tripCreate.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra != null && extra is! TripCreateRouteArgs) {
          return const RouteErrorPage(
            message: 'Create trip route received an invalid payload.',
          );
        }

        final args = extra is TripCreateRouteArgs
            ? extra
            : const TripCreateRouteArgs();

        return CreateTripPage(
          initialTrip: args.initialTrip,
          forceCreateMode: args.forceCreateMode,
        );
      },
    ),
    GoRoute(
      name: AppRoute.tripDetails.routeName,
      path: AppRoute.tripDetails.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! Trip) {
          return const RouteErrorPage(
            message: 'Trip details route requires a Trip extra payload.',
          );
        }
        return TripDetailsPage(trip: extra);
      },
    ),
  ];
}
