import '../entities/trip.dart';

abstract class TripRepository {
  Future<void> create(Trip trip);

  Future<void> update(Trip trip);

  Future<void> delete(String id);

  Stream<List<Trip>> watchAll();

  Future<Trip?> get(String id);
}
