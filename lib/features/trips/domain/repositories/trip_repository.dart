import '../entities/trip.dart';

abstract class TripRepository {
  /// Live stream of all trips
  Stream<List<Trip>> watchTrips();

  /// Returns all trips once
  Future<List<Trip>> getAll();

  /// Returns one trip by ID
  Future<Trip?> get(String id);

  /// Creates a new trip
  Future<void> createTrip(Trip trip);

  /// Updates an existing trip
  Future<void> updateTrip(Trip trip);

  /// Deletes a trip
  Future<void> deleteTrip(String id);
}
