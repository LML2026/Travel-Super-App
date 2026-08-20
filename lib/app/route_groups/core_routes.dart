import 'package:go_router/go_router.dart';

import '../../core/models/destination.dart';
import '../../core/models/booking.dart';
import '../../core/presentation/pages/booking_status_page.dart';
import '../../core/presentation/pages/confirmed_booking_details_page.dart';
import '../../features/ai/screens/ai_assistant_page.dart';
import '../../features/destinations/destination_detail_page.dart';
import '../../features/discovery/presentation/screens/travel_discovery_page.dart';
import '../../features/live_trip/presentation/screens/live_trip_page.dart';
import '../../features/maps/models/places_prefill.dart';
import '../../features/maps/presentation/screens/maps_hub_page.dart';
import '../../features/nearby/models/nearby_service_type.dart';
import '../../features/nearby/presentation/nearby_essentials_page.dart';
import '../../features/navigation/main_navigation_page.dart';
import '../../features/profile/profile_page.dart';
import '../../features/saved_items/presentation/screens/saved_items_page.dart';
import '../../features/bookings/presentation/screens/my_bookings_page.dart';
import '../../features/splash/splash_page.dart';
import '../../features/transport/presentation/screens/transport_hub_page.dart';
import '../../features/taxi/domain/entities/taxi_ride_request.dart';
import '../../features/taxi/presentation/screens/saved_rides_page.dart';
import '../../features/taxi/presentation/screens/taxi_booking_details_page.dart';
import '../../features/taxi/presentation/screens/taxi_results_page.dart';
import '../../features/taxi/presentation/screens/taxi_search_page.dart';
import '../../features/translator/domain/translation_models.dart';
import '../../features/translator/presentation/screens/translator_page.dart';
import '../../features/trips/domain/entities/trip.dart' as domain;
import '../../features/trips/presentation/screens/trip_bookings_page.dart';
import '../../features/wallet/presentation/screens/wallet_page.dart';
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
      name: AppRoute.wallet.routeName,
      path: AppRoute.wallet.path,
      builder: (context, state) => const WalletPage(),
    ),
    GoRoute(
      name: AppRoute.liveTrip.routeName,
      path: AppRoute.liveTrip.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra != null && extra is! domain.Trip) {
          return const RouteErrorPage(
            message: 'Live Trip received an invalid trip payload.',
          );
        }
        return LiveTripPage(trip: extra as domain.Trip?);
      },
    ),
    GoRoute(
      name: AppRoute.travelDiscovery.routeName,
      path: AppRoute.travelDiscovery.path,
      builder: (context, state) => const TravelDiscoveryPage(),
    ),
    GoRoute(
      name: AppRoute.savedItems.routeName,
      path: AppRoute.savedItems.path,
      builder: (context, state) => const SavedItemsPage(),
    ),
    GoRoute(
      name: AppRoute.myBookings.routeName,
      path: AppRoute.myBookings.path,
      builder: (context, state) => const MyBookingsPage(),
    ),
    GoRoute(
      name: AppRoute.transport.routeName,
      path: AppRoute.transport.path,
      builder: (context, state) => const TransportHubPage(),
    ),
    GoRoute(
      name: AppRoute.taxi.routeName,
      path: AppRoute.taxi.path,
      builder: (context, state) => const TaxiSearchPage(),
    ),
    GoRoute(
      name: AppRoute.taxiResults.routeName,
      path: AppRoute.taxiResults.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! TaxiRideRequest) {
          return const RouteErrorPage(
            message: 'Taxi results route requires a TaxiRideRequest payload.',
          );
        }

        return TaxiResultsPage(request: extra);
      },
    ),
    GoRoute(
      name: AppRoute.taxiBookingDetails.routeName,
      path: AppRoute.taxiBookingDetails.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! TaxiBookingRouteArgs) {
          return const RouteErrorPage(
            message:
                'Taxi booking details route requires a TaxiBookingRouteArgs payload.',
          );
        }

        return TaxiBookingDetailsPage(args: extra);
      },
    ),
    GoRoute(
      name: AppRoute.savedRides.routeName,
      path: AppRoute.savedRides.path,
      builder: (context, state) => const SavedRidesPage(),
    ),
    GoRoute(
      name: AppRoute.weather.routeName,
      path: AppRoute.weather.path,
      builder: (context, state) => const WeatherPage(),
    ),
    GoRoute(
      name: AppRoute.maps.routeName,
      path: AppRoute.maps.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra != null && extra is! PlacesPrefill) {
          return const RouteErrorPage(
            message: 'Maps route received an invalid places prefill payload.',
          );
        }

        return MapsHubPage(prefill: extra as PlacesPrefill?);
      },
    ),
    GoRoute(
      name: AppRoute.nearbyEssentials.routeName,
      path: AppRoute.nearbyEssentials.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra != null && extra is! NearbyServiceType) {
          return const RouteErrorPage(
            message:
                'Nearby Essentials expects an optional NearbyServiceType payload.',
          );
        }

        return NearbyEssentialsPage(
            initialService: extra as NearbyServiceType?);
      },
    ),
    GoRoute(
      name: AppRoute.aiAssistant.routeName,
      path: AppRoute.aiAssistant.path,
      builder: (context, state) => const AiAssistantPage(),
    ),
    GoRoute(
      name: AppRoute.translator.routeName,
      path: AppRoute.translator.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra != null && extra is! TranslatorContext) {
          return const RouteErrorPage(
            message: 'Translator received an invalid context payload.',
          );
        }
        return TranslatorPage(context: extra as TranslatorContext?);
      },
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
    GoRoute(
      name: AppRoute.bookingStatus.routeName,
      path: AppRoute.bookingStatus.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! BookingType) {
          return const RouteErrorPage(
            message:
                'Booking status route requires a BookingType extra payload.',
          );
        }
        return BookingStatusPage(type: extra);
      },
    ),
    GoRoute(
      name: AppRoute.tripBookings.routeName,
      path: AppRoute.tripBookings.path,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null) {
          return const RouteErrorPage(
              message: 'Trip ID is required for bookings.');
        }
        return TripBookingsPage(tripId: id);
      },
    ),
    GoRoute(
      name: AppRoute.confirmedBookingDetails.routeName,
      path: AppRoute.confirmedBookingDetails.path,
      builder: (context, state) {
        final extra = state.extra;
        if (extra is! Booking) {
          return const RouteErrorPage(
            message:
                'Confirmed booking details route requires a Booking extra payload.',
          );
        }
        return ConfirmedBookingDetailsPage(booking: extra);
      },
    ),
  ];
}
