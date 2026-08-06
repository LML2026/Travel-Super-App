import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class UpdateTrip {
  const UpdateTrip(this._repository);

  final TripRepository _repository;

  Future<void> call(Trip trip) {
    return _repository.updateTrip(trip);
  }
}
