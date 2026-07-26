import '../../repositories/trip_repository.dart';
import '../../services/trip_service.dart';
import '../../domain/entities/trip_entity.dart';
import '../../domain/repositories/trip_repository_contract.dart';

class TripRepositoryAdapter implements TripRepositoryContract {
  TripRepositoryAdapter(this._repository);

  final TripRepository _repository;

  factory TripRepositoryAdapter.fromService(TripService service) {
    return TripRepositoryAdapter(TripRepository(service));
  }

  @override
  Stream<List<TripEntity>> watchTrips() {
    return _repository.watchTrips();
  }

  @override
  Future<void> saveTrip(TripEntity trip) {
    return _repository.saveTrip(trip);
  }

  @override
  Future<void> updateTrip(TripEntity trip) {
    return _repository.updateTrip(trip);
  }

  @override
  Future<void> deleteTrip(String tripId) {
    return _repository.deleteTrip(tripId);
  }
}
