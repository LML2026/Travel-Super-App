import '../entities/trip.dart';

abstract class TripRepository {
  Stream<List<Trip>> watchTrips();

  Future<List<Trip>> getAll();

  Future<Trip?> get(String id);

  Future<void> createTrip(Trip trip);

  Future<void> updateTrip(Trip trip);

  Future<void> deleteTrip(String id);
}
