import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../flights/models/saved_flight.dart';
import '../../../flights/providers/flight_provider.dart';
import '../../../hotels/models/saved_hotel.dart';
import '../../../hotels/providers/hotel_provider.dart';
import '../../domain/entities/trip.dart';
import 'trip_provider.dart';

class TripBudgetSummary {
  const TripBudgetSummary({
    required this.currency,
    required this.budget,
    required this.spent,
  });

  final String currency;
  final double budget;
  final double spent;

  double get remaining => budget - spent;
}

final tripLiveProvider = StreamProvider.family<Trip?, String>((ref, tripId) {
  final repository = ref.watch(tripRepositoryProvider);
  return repository.watchTrips().map((trips) {
    for (final trip in trips) {
      if (trip.id == tripId) {
        return trip;
      }
    }
    return null;
  });
});

final tripFlightsProvider = Provider.family<AsyncValue<SavedFlight?>, String>((ref, tripId) {
  final tripAsync = ref.watch(tripLiveProvider(tripId));
  final flightsAsync = ref.watch(savedFlightsProvider);

  if (tripAsync.hasError) {
    return AsyncValue<SavedFlight?>.error(
      tripAsync.error!,
      tripAsync.stackTrace ?? StackTrace.current,
    );
  }

  if (flightsAsync.hasError) {
    return AsyncValue<SavedFlight?>.error(
      flightsAsync.error!,
      flightsAsync.stackTrace ?? StackTrace.current,
    );
  }

  if (tripAsync.isLoading || flightsAsync.isLoading) {
    return const AsyncValue<SavedFlight?>.loading();
  }

  final trip = tripAsync.valueOrNull;
  final linkedFlightId = trip?.selectedFlightId;
  if (trip == null || linkedFlightId == null || linkedFlightId.isEmpty) {
    return const AsyncValue<SavedFlight?>.data(null);
  }

  final flights = flightsAsync.valueOrNull ?? const <SavedFlight>[];
  for (final flight in flights) {
    if (flight.flightId == linkedFlightId) {
      return AsyncValue<SavedFlight?>.data(flight);
    }
  }

  return const AsyncValue<SavedFlight?>.data(null);
});

final tripHotelProvider = Provider.family<AsyncValue<SavedHotel?>, String>((ref, tripId) {
  final tripAsync = ref.watch(tripLiveProvider(tripId));
  final hotelsAsync = ref.watch(savedHotelsProvider);

  if (tripAsync.hasError) {
    return AsyncValue<SavedHotel?>.error(
      tripAsync.error!,
      tripAsync.stackTrace ?? StackTrace.current,
    );
  }

  if (hotelsAsync.hasError) {
    return AsyncValue<SavedHotel?>.error(
      hotelsAsync.error!,
      hotelsAsync.stackTrace ?? StackTrace.current,
    );
  }

  if (tripAsync.isLoading || hotelsAsync.isLoading) {
    return const AsyncValue<SavedHotel?>.loading();
  }

  final trip = tripAsync.valueOrNull;
  final linkedHotelId = trip?.selectedHotelId;
  if (trip == null || linkedHotelId == null || linkedHotelId.isEmpty) {
    return const AsyncValue<SavedHotel?>.data(null);
  }

  final hotels = hotelsAsync.valueOrNull ?? const <SavedHotel>[];
  for (final hotel in hotels) {
    if (hotel.hotelId == linkedHotelId) {
      return AsyncValue<SavedHotel?>.data(hotel);
    }
  }

  return const AsyncValue<SavedHotel?>.data(null);
});

final tripBudgetProvider = Provider.family<AsyncValue<TripBudgetSummary>, String>((ref, tripId) {
  final tripAsync = ref.watch(tripLiveProvider(tripId));
  final flightAsync = ref.watch(tripFlightsProvider(tripId));
  final hotelAsync = ref.watch(tripHotelProvider(tripId));

  if (tripAsync.hasError) {
    return AsyncValue<TripBudgetSummary>.error(
      tripAsync.error!,
      tripAsync.stackTrace ?? StackTrace.current,
    );
  }

  if (flightAsync.hasError) {
    return AsyncValue<TripBudgetSummary>.error(
      flightAsync.error!,
      flightAsync.stackTrace ?? StackTrace.current,
    );
  }

  if (hotelAsync.hasError) {
    return AsyncValue<TripBudgetSummary>.error(
      hotelAsync.error!,
      hotelAsync.stackTrace ?? StackTrace.current,
    );
  }

  if (tripAsync.isLoading || flightAsync.isLoading || hotelAsync.isLoading) {
    return const AsyncValue<TripBudgetSummary>.loading();
  }

  final trip = tripAsync.valueOrNull;
  if (trip == null) {
    return AsyncValue<TripBudgetSummary>.error(
      StateError('Trip not found'),
      StackTrace.current,
    );
  }

  final spent = (flightAsync.valueOrNull?.amount ?? 0) +
      (hotelAsync.valueOrNull?.totalPrice ?? 0);

  return AsyncValue<TripBudgetSummary>.data(
    TripBudgetSummary(
      currency: trip.currency,
      budget: trip.budget,
      spent: spent,
    ),
  );
});
