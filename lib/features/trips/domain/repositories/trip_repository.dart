import '../entities/trip.dart';

abstract class TripRepository {
  /// Watch all trips in real time.
  Stream<List<Trip>> watchTrips();

  /// Get all trips once.
  Future<List<Trip>> getAll() async {
    return watchTrips().first;
  }

  /// Get a single trip by id.
  Future<Trip?> get(String id) => getTrip(id);

  /// Create a new trip
  Future<void> createTrip(Trip trip);

  /// Update an existing trip
  Future<void> updateTrip(Trip trip);

  /// Delete a trip
  Future<void> deleteTrip(String id);

  /// Backward-compatible legacy read method.
  Future<Trip?> getTrip(String tripId);
}
