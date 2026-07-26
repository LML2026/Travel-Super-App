import '../domain/entities/trip.dart';
import '../services/trip_service.dart';

class TripRepository {
  TripRepository(this._service);

  final TripService _service;

  Stream<List<Trip>> watchTrips() {
    return _service.watchTrips();
  }

  Future<void> saveTrip(Trip trip) {
    return _service.saveTrip(trip);
  }

  Future<void> updateTrip(Trip trip) {
    return _service.updateTrip(trip);
  }

  Future<void> deleteTrip(String tripId) {
    return _service.deleteTrip(tripId);
  }
}
