import '../entities/trip.dart';
import '../repositories/trip_repository.dart';

class GetTrip {
  const GetTrip(this._repository);

  final TripRepository _repository;

  Future<Trip?> call(String id) {
    return _repository.get(id);
  }
}
