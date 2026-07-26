import '../entities/trip.dart';

abstract class TripRepository {
  /// Create a trip.
  Future<void> create(Trip trip);

  /// Fetch a trip by id. Returns null when not found.
  Future<Trip?> get(String id);

  /// Update an existing trip.
  Future<void> update(Trip trip);

  /// Delete a trip by id.
  Future<void> delete(String id);

  /// Stream all trips for the current user.
  Stream<List<Trip>> watchAll();
}
