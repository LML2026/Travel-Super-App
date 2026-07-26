import '../entities/trip_entity.dart';

abstract class TripRepositoryContract {
  Stream<List<TripEntity>> watchTrips();
  Future<void> saveTrip(TripEntity trip);
  Future<void> updateTrip(TripEntity trip);
  Future<void> deleteTrip(String tripId);
}
