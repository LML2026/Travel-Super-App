import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../flights/models/saved_flight.dart';
import '../../flights/providers/flight_provider.dart';
import '../../hotels/models/saved_hotel.dart';
import '../../hotels/providers/hotel_provider.dart';
import '../../trips/models/trip.dart';
import '../../trips/providers/trip_provider.dart';
import '../../weather/models/weather_data.dart';
import '../../weather/providers/weather_provider.dart';
import '../models/dashboard_summary.dart';

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  final userName = _userName(user);

  final trips = await ref.watch(tripsProvider.future);
  final upcomingTrip = _upcomingTrip(trips);

  if (upcomingTrip == null) {
    return DashboardSummary(userName: userName);
  }

  final flights = await ref.watch(savedFlightsProvider.future);
  final hotels = await ref.watch(savedHotelsProvider.future);

  final linkedFlight = _findTripFlight(upcomingTrip, flights);
  final linkedHotel = _findTripHotel(upcomingTrip, hotels);

  WeatherData? weather;
  try {
    weather = await ref.watch(weatherProvider(upcomingTrip.destination).future);
  } catch (_) {
    weather = null;
  }

    final budget = upcomingTrip.budget > 0
      ? upcomingTrip.budget
      : _estimatedBudget(upcomingTrip, linkedFlight, linkedHotel);

  return DashboardSummary(
    userName: userName,
    upcomingTrip: upcomingTrip,
    linkedFlight: linkedFlight,
    linkedHotel: linkedHotel,
    weather: weather,
    budget: budget,
    currency: linkedHotel?.currency ?? linkedFlight?.currency ?? 'GBP',
  );
});

String _userName(User? user) {
  if (user?.displayName != null && user!.displayName!.isNotEmpty) {
    return user.displayName!.split(' ').first;
  }
  return user?.email?.split('@').first ?? 'Traveler';
}

String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 18) return 'Good Afternoon';
  return 'Good Evening';
}

Trip? _upcomingTrip(List<Trip> trips) {
  final now = DateTime.now();
  final upcoming = trips.where((trip) => trip.endDate.isAfter(now)).toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));

  return upcoming.isEmpty ? null : upcoming.first;
}

SavedFlight? _findTripFlight(Trip trip, List<SavedFlight> flights) {
  if (trip.flightId == null) {
    return null;
  }

  for (final flight in flights) {
    if (flight.flightId == trip.flightId) {
      return flight;
    }
  }
  return null;
}

SavedHotel? _findTripHotel(Trip trip, List<SavedHotel> hotels) {
  if (trip.hotelId == null) {
    return null;
  }

  for (final hotel in hotels) {
    if (hotel.hotelId == trip.hotelId) {
      return hotel;
    }
  }
  return null;
}

double _estimatedBudget(Trip trip, SavedFlight? flight, SavedHotel? hotel) {
  final flightCost = flight?.amount ?? 0;
  final hotelCost = hotel?.pricePerNight ?? 0;
  return flightCost + (hotelCost * trip.nights);
}
