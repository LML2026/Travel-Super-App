import '../repositories/trip_repository.dart';

class DeleteTrip {
  const DeleteTrip(this._repository);

  final TripRepository _repository;

  Future<void> call(String tripId) {
    return _repository.delete(tripId);
  }
}
