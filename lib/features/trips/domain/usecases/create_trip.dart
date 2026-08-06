import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class CreateTrip {
  const CreateTrip(this._repository);

  final TripRepository _repository;

  Future<void> call(Trip trip) {
    return _repository.createTrip(trip);
  }
}
