import '../entities/trip_entity.dart';
import '../repositories/trip_repository_contract.dart';

class WatchTripsUseCase {
  const WatchTripsUseCase(this._repository);

  final TripRepositoryContract _repository;

  Stream<List<TripEntity>> call() {
    return _repository.watchTrips();
  }
}
