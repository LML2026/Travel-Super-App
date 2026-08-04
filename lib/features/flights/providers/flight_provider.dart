import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/result.dart';
import '../models/flight.dart';
import '../models/flight_search_request.dart';
import '../models/recent_search.dart';
import '../models/saved_flight.dart';
import '../repositories/flight_repository.dart';
import '../services/flight_firestore_service.dart';

export '../models/flight_search_request.dart';

// ── Repository provider ────────────────────────────────────────────────────
final flightRepositoryProvider = Provider<FlightRepository>(
  (ref) => FlightRepository(),
);

// ── Firestore service provider ─────────────────────────────────────────────
final flightFirestoreServiceProvider = Provider<FlightFirestoreService>(
  (ref) => FlightFirestoreService(),
);

// ── Search provider ────────────────────────────────────────────────────────
/// FutureProvider.family — Riverpod manages loading / data / error.
/// UI calls: ref.watch(flightSearchProvider(request))
final flightSearchProvider =
    FutureProvider.family<List<Flight>, FlightSearchRequest>((ref, request) async {
  final result = await ref.read(flightRepositoryProvider).searchFlights(request);
  return switch (result) {
    Success(:final data) => data,
    Failure(:final message) => throw Exception(message),
  };
});

// ── Recent Searches provider ───────────────────────────────────────────────
/// Stream of recent flight searches ordered by newest first
final recentFlightSearchesProvider = StreamProvider<List<RecentSearch>>((ref) {
  return ref.read(flightFirestoreServiceProvider).getRecentSearches();
});

// ── Save Recent Search provider ────────────────────────────────────────────
/// Mutation provider to save a search
final saveRecentSearchProvider =
    FutureProvider.family<void, FlightSearchRequest>((ref, request) async {
  await ref.read(flightFirestoreServiceProvider).saveRecentSearch(
    from: request.from,
    to: request.to,
    departureDate: request.departureDate,
    returnDate: request.returnDate,
    passengers: request.passengers,
    cabinClass: request.cabinClass,
  );
  // Invalidate the recent searches stream to refetch
  ref.invalidate(recentFlightSearchesProvider);
});

// ── Delete Recent Search provider ──────────────────────────────────────────
/// Mutation provider to delete a recent search
final deleteRecentSearchProvider =
    FutureProvider.family<void, String>((ref, searchId) async {
  await ref.read(flightFirestoreServiceProvider).deleteRecentSearch(searchId);
  // Invalidate the recent searches stream to refetch
  ref.invalidate(recentFlightSearchesProvider);
});

// ── Saved Flights provider ─────────────────────────────────────────────────
/// Stream of saved flights ordered by newest first
final savedFlightsProvider = StreamProvider<List<SavedFlight>>((ref) {
  return ref.read(flightFirestoreServiceProvider).getSavedFlights();
});

// ── Save Flight provider ───────────────────────────────────────────────────
/// Mutation provider to save a flight
final saveFlightProvider = FutureProvider.family<void, SavedFlight>((ref, savedFlight) async {
  await ref.read(flightFirestoreServiceProvider).saveFlight(
    flightId: savedFlight.flightId,
    airline: savedFlight.airline,
    airlineLogo: savedFlight.airlineLogo,
    flightNumber: savedFlight.flightNumber,
    origin: savedFlight.origin,
    destination: savedFlight.destination,
    departureAt: savedFlight.departureAt,
    arrivalAt: savedFlight.arrivalAt,
    duration: savedFlight.duration,
    stops: savedFlight.stops,
    amount: savedFlight.amount,
    currency: savedFlight.currency,
    cabinClass: savedFlight.cabinClass,
  );
  // Invalidate the saved flights stream to refetch
  ref.invalidate(savedFlightsProvider);
});

// ── Remove Saved Flight provider ───────────────────────────────────────────
/// Mutation provider to remove a saved flight
final removeSavedFlightProvider =
    FutureProvider.family<void, String>((ref, saveId) async {
  await ref.read(flightFirestoreServiceProvider).removeSavedFlight(saveId);
  // Invalidate the saved flights stream to refetch
  ref.invalidate(savedFlightsProvider);
});

// ── Check if Flight is Saved provider ──────────────────────────────────────
/// Check if a specific flight is saved
final isFlightSavedProvider = FutureProvider.family<bool, String>((ref, flightId) async {
  return ref.read(flightFirestoreServiceProvider).isFlightSaved(flightId);
});

// ── Get Save ID provider ───────────────────────────────────────────────────
/// Get the save document ID for a flight
final getSavedFlightIdProvider = FutureProvider.family<String?, String>((ref, flightId) async {
  return ref.read(flightFirestoreServiceProvider).getSavedFlightId(flightId);
});

