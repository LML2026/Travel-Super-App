import 'package:go_router/go_router.dart';

import '../../features/flights/models/flight.dart';
import '../../features/flights/models/saved_flight.dart';
import '../../features/flights/pages/flight_details_page.dart';
import '../../features/flights/pages/flight_search_page.dart';
import '../../features/flights/pages/flights_page.dart';
import '../../features/flights/screens/recent_flight_searches_page.dart';
import '../../features/flights/screens/saved_flight_details_page.dart';
import '../../features/flights/screens/saved_flights_page.dart';
import '../app_routes.dart';
import '../route_error_page.dart';

List<RouteBase> buildFlightRoutes() {
  return [
    GoRoute(
      name: AppRoute.flights.routeName,
      path: AppRoute.flights.path,
      builder: (context, state) => const FlightsPage(),
    ),
    GoRoute(
      name: AppRoute.flightSearch.routeName,
      path: AppRoute.flightSearch.path,
      builder: (context, state) => const FlightSearchPage(),
    ),
    GoRoute(
      name: AppRoute.flightRecent.routeName,
      path: AppRoute.flightRecent.path,
      builder: (context, state) => const RecentFlightSearchesPage(),
    ),
    GoRoute(
      name: AppRoute.flightSaved.routeName,
      path: AppRoute.flightSaved.path,
      builder: (context, state) => const SavedFlightsPage(),
    ),
    GoRoute(
      name: AppRoute.flightDetails.routeName,
      path: AppRoute.flightDetails.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! Flight) {
          return const RouteErrorPage(
            message: 'Flight details route requires a Flight extra payload.',
          );
        }
        return FlightDetailsPage(flight: extra);
      },
    ),
    GoRoute(
      name: AppRoute.savedFlightDetails.routeName,
      path: AppRoute.savedFlightDetails.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! SavedFlight) {
          return const RouteErrorPage(
            message: 'Saved flight details route requires a SavedFlight extra payload.',
          );
        }
        return SavedFlightDetailsPage(flight: extra);
      },
    ),
  ];
}
