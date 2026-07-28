import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../core/models/destination.dart';
import '../features/taxi/domain/entities/taxi_ride_option.dart';
import '../features/taxi/domain/entities/taxi_ride_request.dart';
import '../features/flights/models/flight.dart';
import '../features/flights/models/saved_flight.dart';
import '../features/hotels/models/hotel.dart';
import '../features/hotels/models/saved_hotel.dart';
import '../features/trips/domain/entities/trip.dart';

class TripCreateRouteArgs {
  const TripCreateRouteArgs({
    this.initialTrip,
    this.forceCreateMode = false,
  });

  final Trip? initialTrip;
  final bool forceCreateMode;
}

class TaxiBookingRouteArgs {
  const TaxiBookingRouteArgs({
    required this.request,
    required this.option,
  });

  final TaxiRideRequest request;
  final TaxiRideOption option;
}

enum AppRoute {
  splash,
  login,
  register,
  forgotPassword,
  emailVerification,
  home,
  wallet,
  transport,
  taxi,
  taxiResults,
  taxiBookingDetails,
  savedRides,
  flights,
  flightSearch,
  flightRecent,
  flightSaved,
  flightDetails,
  savedFlightDetails,
  hotels,
  hotelRecent,
  hotelSaved,
  hotelDetails,
  savedHotelDetails,
  weather,
  aiAssistant,
  trips,
  tripCreate,
  tripDetails,
  tripEdit,
  tripNotes,
  tripDocuments,
  tripActivities,
  profile,
  destination,
}

extension AppRouteConfig on AppRoute {
  String get routeName => name;

  String get path {
    switch (this) {
      case AppRoute.splash:
        return '/';
      case AppRoute.login:
        return '/login';
      case AppRoute.register:
        return '/register';
      case AppRoute.forgotPassword:
        return '/forgot-password';
      case AppRoute.emailVerification:
        return '/email-verification';
      case AppRoute.home:
        return '/home';
      case AppRoute.wallet:
        return '/wallet';
      case AppRoute.transport:
        return '/transport';
      case AppRoute.taxi:
        return '/transport/taxi';
      case AppRoute.taxiResults:
        return '/transport/taxi/results';
      case AppRoute.taxiBookingDetails:
        return '/transport/taxi/booking-details';
      case AppRoute.savedRides:
        return '/transport/taxi/saved';
      case AppRoute.flights:
        return '/flights';
      case AppRoute.flightSearch:
        return '/flights/search';
      case AppRoute.flightRecent:
        return '/flights/recent';
      case AppRoute.flightSaved:
        return '/flights/saved';
      case AppRoute.flightDetails:
        return '/flights/details';
      case AppRoute.savedFlightDetails:
        return '/flights/saved/details';
      case AppRoute.hotels:
        return '/hotels';
      case AppRoute.hotelRecent:
        return '/hotels/recent';
      case AppRoute.hotelSaved:
        return '/hotels/saved';
      case AppRoute.hotelDetails:
        return '/hotels/details';
      case AppRoute.savedHotelDetails:
        return '/hotels/saved/details';
      case AppRoute.weather:
        return '/weather';
      case AppRoute.aiAssistant:
        return '/ai';
      case AppRoute.trips:
        return '/trips';
      case AppRoute.tripCreate:
        return '/trips/create';
      case AppRoute.tripDetails:
        return '/trips/:id';
      case AppRoute.tripEdit:
        return '/trips/:id/edit';
      case AppRoute.tripNotes:
        return '/trips/:id/notes';
      case AppRoute.tripDocuments:
        return '/trips/:id/documents';
      case AppRoute.tripActivities:
        return '/trips/:id/activities';
      case AppRoute.profile:
        return '/profile';
      case AppRoute.destination:
        return '/destination';
    }
  }
}

extension AppNavigation on BuildContext {
  void goSplash() => goNamed(AppRoute.splash.routeName);

  void goLogin() => goNamed(AppRoute.login.routeName);

  void goHome() => goNamed(AppRoute.home.routeName);

  Future<T?> pushWallet<T>() => pushNamed<T>(AppRoute.wallet.routeName);

  Future<T?> pushTransport<T>() =>
      pushNamed<T>(AppRoute.transport.routeName);

    Future<T?> pushTaxi<T>() => pushNamed<T>(AppRoute.taxi.routeName);

    Future<T?> pushTaxiResults<T>(TaxiRideRequest request) =>
      pushNamed<T>(AppRoute.taxiResults.routeName, extra: request);

    Future<T?> pushTaxiBookingDetails<T>(TaxiBookingRouteArgs args) =>
      pushNamed<T>(AppRoute.taxiBookingDetails.routeName, extra: args);

    Future<T?> pushSavedRides<T>() =>
      pushNamed<T>(AppRoute.savedRides.routeName);

  Future<T?> pushRegister<T>() => pushNamed<T>(AppRoute.register.routeName);

  Future<T?> pushForgotPassword<T>() =>
      pushNamed<T>(AppRoute.forgotPassword.routeName);

  void goEmailVerification() => goNamed(AppRoute.emailVerification.routeName);

  Future<T?> pushEmailVerification<T>() =>
      pushNamed<T>(AppRoute.emailVerification.routeName);

  Future<T?> pushFlights<T>() => pushNamed<T>(AppRoute.flights.routeName);

  Future<T?> pushFlightSearch<T>() =>
      pushNamed<T>(AppRoute.flightSearch.routeName);

  Future<T?> pushRecentFlights<T>() =>
      pushNamed<T>(AppRoute.flightRecent.routeName);

  Future<T?> pushSavedFlights<T>() =>
      pushNamed<T>(AppRoute.flightSaved.routeName);

  Future<T?> pushFlightDetails<T>(Flight flight) =>
      pushNamed<T>(AppRoute.flightDetails.routeName, extra: flight);

  Future<T?> pushSavedFlightDetails<T>(SavedFlight flight) =>
      pushNamed<T>(AppRoute.savedFlightDetails.routeName, extra: flight);

  Future<T?> pushHotels<T>() => pushNamed<T>(AppRoute.hotels.routeName);

  Future<T?> pushRecentHotelSearches<T>() =>
      pushNamed<T>(AppRoute.hotelRecent.routeName);

  Future<T?> pushSavedHotels<T>() =>
      pushNamed<T>(AppRoute.hotelSaved.routeName);

  Future<T?> pushHotelDetails<T>(Hotel hotel) =>
      pushNamed<T>(AppRoute.hotelDetails.routeName, extra: hotel);

  Future<T?> pushSavedHotelDetails<T>(SavedHotel hotel) =>
      pushNamed<T>(AppRoute.savedHotelDetails.routeName, extra: hotel);

  Future<T?> pushWeather<T>() => pushNamed<T>(AppRoute.weather.routeName);

  Future<T?> pushAiAssistant<T>() =>
      pushNamed<T>(AppRoute.aiAssistant.routeName);

  Future<T?> pushTrips<T>() => pushNamed<T>(AppRoute.trips.routeName);

  Future<T?> pushCreateTrip<T>({
    Trip? initialTrip,
    bool forceCreateMode = false,
  }) =>
      pushNamed<T>(
        AppRoute.tripCreate.routeName,
        extra: TripCreateRouteArgs(
          initialTrip: initialTrip,
          forceCreateMode: forceCreateMode,
        ),
      );

  Future<T?> pushTripDetails<T>(Trip trip) => pushNamed<T>(
        AppRoute.tripDetails.routeName,
        pathParameters: {'id': trip.id},
        extra: trip,
      );

  Future<T?> pushEditTrip<T>(String tripId, {Trip? initialTrip}) =>
      pushNamed<T>(
        AppRoute.tripEdit.routeName,
        pathParameters: {'id': tripId},
        extra: initialTrip,
      );

  Future<T?> pushTripNotes<T>(String tripId) => pushNamed<T>(
        AppRoute.tripNotes.routeName,
        pathParameters: {'id': tripId},
      );

  Future<T?> pushTripDocuments<T>(String tripId) => pushNamed<T>(
        AppRoute.tripDocuments.routeName,
        pathParameters: {'id': tripId},
      );

  Future<T?> pushTripActivities<T>(String tripId) => pushNamed<T>(
        AppRoute.tripActivities.routeName,
        pathParameters: {'id': tripId},
      );

  Future<T?> pushProfile<T>() => pushNamed<T>(AppRoute.profile.routeName);

  Future<T?> pushDestination<T>(Destination destination) =>
      pushNamed<T>(AppRoute.destination.routeName, extra: destination);
}
