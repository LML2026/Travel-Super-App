import '../repositories/trip_repository_contract.dart';

class DeleteTripUseCase {
  const DeleteTripUseCase(this._repository);

  final TripRepositoryContract _repository;

  Future<void> call(String tripId) {
    return _repository.deleteTrip(tripId);
  }
}
