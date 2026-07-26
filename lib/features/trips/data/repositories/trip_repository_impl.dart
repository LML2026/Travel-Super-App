import '../datasources/trip_firestore_datasource.dart';
import '../models/trip_model.dart';
import '../../domain/entities/trip.dart';
import '../../domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  TripRepositoryImpl({TripFirestoreDatasource? datasource})
      : _datasource = datasource ?? TripFirestoreDatasource();

  final TripFirestoreDatasource _datasource;

  @override
  Future<void> create(Trip trip) {
    return _datasource.create(TripModel.fromEntity(trip));
  }

  @override
  Future<void> update(Trip trip) {
    return _datasource.update(TripModel.fromEntity(trip));
  }

  @override
  Future<void> delete(String id) {
    return _datasource.delete(id);
  }

  @override
  Stream<List<Trip>> watchAll() {
    return _datasource.watchAll().map(
          (models) => models.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<Trip?> get(String id) async {
    final model = await _datasource.get(id);
    return model?.toEntity();
  }
}
