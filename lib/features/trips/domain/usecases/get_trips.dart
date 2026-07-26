import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTrips {
  const GetTrips(this._repository);

  final TripRepository _repository;

  Stream<List<Trip>> call() {
    return _repository.watchTrips();
  }

  Future<List<Trip>> once() {
    return _repository.getAll();
  }
}
