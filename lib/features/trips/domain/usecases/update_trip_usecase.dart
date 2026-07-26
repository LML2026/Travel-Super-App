import '../entities/trip_entity.dart';
import '../repositories/trip_repository_contract.dart';

class UpdateTripUseCase {
  const UpdateTripUseCase(this._repository);

  final TripRepositoryContract _repository;

  Future<void> call(TripEntity trip) {
    return _repository.updateTrip(trip);
  }
}
