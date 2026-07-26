import '../entities/trip.dart';

abstract class TripRepository {
  /// Create a new trip
  Future<void> createTrip(Trip trip);

  /// Update an existing trip
  Future<void> updateTrip(Trip trip);

  /// Delete a trip
  Future<void> deleteTrip(String tripId);

  /// Get a single trip
  Future<Trip?> getTrip(String tripId);

  /// Watch all trips in real time
  Stream<List<Trip>> watchTrips();
}
