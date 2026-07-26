import '../entities/trip_entity.dart';
import '../repositories/trip_repository_contract.dart';

class SaveTripUseCase {
  const SaveTripUseCase(this._repository);

  final TripRepositoryContract _repository;

  Future<void> call(TripEntity trip) {
    return _repository.saveTrip(trip);
  }
}
