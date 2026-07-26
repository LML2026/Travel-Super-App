import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';
import '../models/trip_model.dart';
import '../services/trip_firestore_service.dart';

class FirestoreTripRepository implements TripRepository {
  FirestoreTripRepository({TripFirestoreService? service})
      : _service = service ?? TripFirestoreService();

  final TripFirestoreService _service;

  @override
  Stream<List<Trip>> watchTrips() {
    return _service.watchTrips();
  }

  @override
  Future<List<Trip>> getAll() {
    return _service.getAllTrips();
  }

  @override
  Future<Trip?> get(String id) {
    return _service.getTrip(id);
  }

  @override
  Future<void> createTrip(Trip trip) async {
    final model = TripModel.fromEntity(trip);
    await _service.createTrip(model);
  }

  @override
  Future<void> updateTrip(Trip trip) async {
    final model = TripModel.fromEntity(trip);
    await _service.updateTrip(model);
  }

  @override
  Future<void> deleteTrip(String id) async {
    await _service.deleteTrip(id);
  }

  @override
  Future<Trip?> getTrip(String tripId) {
    return get(tripId);
  }
}
