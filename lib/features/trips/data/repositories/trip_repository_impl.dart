import '../datasources/trip_firestore_datasource.dart';
import '../models/trip_model.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({TripFirestoreDatasource? datasource})
      : _datasource = datasource ?? TripFirestoreDatasource();

  final TripFirestoreDatasource _datasource;

  @override
  Future<void> createTrip(Trip trip) {
    return _datasource.create(TripModel.fromEntity(trip));
  }

  @override
  Future<void> updateTrip(Trip trip) {
    return _datasource.update(TripModel.fromEntity(trip));
  }

  @override
  Future<void> deleteTrip(String tripId) {
    return _datasource.delete(tripId);
  }

  @override
  Stream<List<Trip>> watchTrips() {
    return _datasource.watchAll().map(
          (models) => models.cast<Trip>(),
        );
  }

  @override
  Future<Trip?> getTrip(String tripId) async {
    final model = await _datasource.get(tripId);
    return model;
  }
}
