import '../repositories/trip_repository.dart';

class DeleteTrip {
  const DeleteTrip(this._repository);

  final TripRepository _repository;

  Future<void> call(String id) {
    return _repository.deleteTrip(id);
  }
}
