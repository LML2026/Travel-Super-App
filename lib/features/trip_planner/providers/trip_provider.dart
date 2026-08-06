import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/saved_trip.dart';
import '../services/local_storage_service.dart';

// Local Storage Service provider
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

// Saved trips provider
final savedTripsProvider = FutureProvider<List<SavedTrip>>((ref) async {
  final storage = ref.watch(localStorageServiceProvider);
  return storage.loadTrips();
});

// Function to add a new trip
Future<void> addTrip(
  WidgetRef ref, {
  required String destination,
  required DateTime departureDate,
  required DateTime returnDate,
  required int travelers,
  double? totalBudget,
  List<String> flightIds = const [],
  List<String> hotelIds = const [],
}) async {
  final storage = ref.read(localStorageServiceProvider);

  const uuid = Uuid();
  final trip = SavedTrip(
    id: uuid.v4(),
    destination: destination,
    departureDate: departureDate,
    returnDate: returnDate,
    travelers: travelers,
    flightIds: flightIds,
    hotelIds: hotelIds,
    totalBudget: totalBudget ?? 0.0,
    createdAt: DateTime.now(),
  );

  await storage.addTrip(trip);

  // Refresh the trips list
  ref.invalidate(savedTripsProvider);
}

// Function to delete a trip
Future<void> deleteTrip(WidgetRef ref, String tripId) async {
  final storage = ref.read(localStorageServiceProvider);
  await storage.deleteTrip(tripId);

  // Refresh the trips list
  ref.invalidate(savedTripsProvider);
}

// Function to update a trip
Future<void> updateTrip(WidgetRef ref, SavedTrip trip) async {
  final storage = ref.read(localStorageServiceProvider);
  await storage.updateTrip(trip);

  // Refresh the trips list
  ref.invalidate(savedTripsProvider);
}
